import Foundation
import Vision
import CoreImage

class FoodRecognitionService {
    
    // To keep this free, we'll use Apple's built-in object recognition model for now
    // In the future you can replace VNCoreMLModel with your own CoreML food model here
    
    func analyzeImage(_ image: CGImage, completion: @escaping (Result<[FoodResult], Error>) -> Void) {
        
        // Setup Vision Request
        let request = VNClassifyImageRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNClassificationObservation] else {
                completion(.success([]))
                return
            }
            
            // Filter observations (e.g., limit to top 3 predictions)
            let topObservations = observations.prefix(3)
            
            let results: [FoodResult] = topObservations.map { observation in
                return FoodResult(
                    name: observation.identifier.capitalized,
                    confidence: observation.confidence
                )
            }
            
            // Vision analysis runs on a background thread already if we use perform() on background Q
            DispatchQueue.main.async {
                completion(.success(results))
            }
        }
        
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
        
        // Execute request
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
