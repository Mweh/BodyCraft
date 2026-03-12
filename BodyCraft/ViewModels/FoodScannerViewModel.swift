import SwiftUI
import CoreImage
import Combine

enum AppState {
    case idle
    case processingImage
    case analysisComplete([FoodResult])
    case fetchingNutrition
    case resultCalculated(NutritionInfo)
    case error(String)
}

@MainActor
class FoodScannerViewModel: ObservableObject {
    @Published var state: AppState = .idle
    @Published var selectedImage: UIImage? = nil
    @Published var lastSelectionTime: Date? = nil
    
    private let recognitionService = FoodRecognitionService()
    private let nutritionClient = NutritionAPIClient()
    
    func processImage(_ image: UIImage) {
        self.selectedImage = image
        self.lastSelectionTime = Date()
        self.state = .processingImage
        
        guard let cgImage = image.cgImage else {
            self.state = .error("Failed to read image data format.")
            return
        }
        
        recognitionService.analyzeImage(cgImage) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let foodResults):
                if let topPrediction = foodResults.first {
                    // Auto-confirm the best match
                    self.confirmFood(topPrediction)
                } else {
                    self.state = .error("No food detected in the image.")
                }
            case .failure(let error):
                self.state = .error("Image analysis failed: \(error.localizedDescription)")
            }
        }
    }
    
    func confirmFood(_ foodResult: FoodResult) {
        self.state = .fetchingNutrition
        
        // Use the food's identified name to query the API
        // Removing specific traits or numbers can help the generic USDA search
        let query = foodResult.name.components(separatedBy: ",").first ?? foodResult.name
        
        nutritionClient.fetchNutrition(for: query) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let nutritionInfo):
                self.state = .resultCalculated(nutritionInfo)
            case .failure(let error):
                self.state = .error("Failed to load nutrition data: \(error.localizedDescription). (Note: Demo API keys have rate limits)")
            }
        }
    }
    
    func reset() {
        self.selectedImage = nil
        self.state = .idle
    }
}
