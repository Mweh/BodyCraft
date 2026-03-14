import Foundation
import UIKit

class GeminiNutritionService {
    static let shared = GeminiNutritionService()
    
    private let apiKey = "AIzaSyDGmAJ2tiL1uOFjbujglcrwxwJfPA1pk2I" // punya Otniel
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"
    
    func analyzeFoodImage(_ image: UIImage) async throws -> NutritionInfo {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AIError.invalidResponse // Reusing AIError or create a new one
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let prompt = """
        Analyze this image of food and provide the estimated nutritional information.
        Return ONLY valid JSON matching this schema:
        {
          "calories": number,
          "protein": number,
          "carbs": number,
          "fat": number,
          "foodName": "string",
          "baseQuantityGrams": number
        }
        If multiple items are present, provide the total for the entire meal shown.
        """
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.2,
                "response_mime_type": "application/json"
            ]
        ]
        
        guard let url = URL(string: endpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-goog-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown API Error"
            print("Gemini Nutrition API Error: \(errorString)")
            throw AIError.apiError("HTTP status \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        }
        
        // Decode Gemini envelope
        struct GeminiResponse: Decodable {
            let candidates: [Candidate]
            struct Candidate: Decodable {
                let content: Content
            }
            struct Content: Decodable {
                let parts: [Part]
            }
            struct Part: Decodable {
                let text: String
            }
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let jsonString = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw AIError.invalidResponse
        }
        
        // Decode NutritionInfo
        guard let payloadData = jsonString.data(using: .utf8) else {
            throw AIError.invalidResponse
        }
        
        let nutritionInfo = try JSONDecoder().decode(NutritionInfoResponse.self, from: payloadData)
        return NutritionInfo(
            calories: nutritionInfo.calories,
            protein: nutritionInfo.protein,
            carbs: nutritionInfo.carbs,
            fat: nutritionInfo.fat,
            baseQuantityGrams: nutritionInfo.baseQuantityGrams,
            foodName: nutritionInfo.foodName
        )
    }
}

// Internal helper for decoding since NutritionInfo might not be Decodable directly if it lacks CodingKeys for the JSON
struct NutritionInfoResponse: Decodable {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let foodName: String
    let baseQuantityGrams: Double
}
