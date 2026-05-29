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
    
    private let geminiService = GeminiNutritionService.shared
    
    func processImage(_ image: UIImage) {
        self.selectedImage = image
        self.lastSelectionTime = Date()
        self.state = .processingImage
        
        Task {
            do {
                let nutritionInfo = try await geminiService.analyzeFoodImage(image)
                self.state = .resultCalculated(nutritionInfo)
            } catch {
                self.state = .error("Nutrition analysis failed: \(error.localizedDescription)")
            }
        }
    }
    
    func confirmFood(_ foodResult: FoodResult) {
        // This is no longer needed in the new Gemini-direct flow, 
        // but kept for compatibility or manual overrides if needed.
        self.state = .fetchingNutrition
        
        // ... implementation omitted or simplified
    }
    
    func reset() {
        self.selectedImage = nil
        self.state = .idle
    }
}
