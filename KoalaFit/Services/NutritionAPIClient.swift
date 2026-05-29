import Foundation

enum APIError: Error {
    case invalidURL
    case decodableError
    case requestFailed
    case noData
}

class NutritionAPIClient {
    // Note: To use the USDA API, get a free API key from fdc.nal.usda.gov
    // We'll use DEMO_KEY for initial testing, but it has strict rate limits.
    private let apiKey = "DEMO_KEY"
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"
    
    func fetchNutrition(for query: String, completion: @escaping (Result<NutritionInfo, Error>) -> Void) {
        // Prepare URL
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/foods/search?query=\(encodedQuery)&api_key=\(apiKey)&pageSize=3") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(APIError.noData)) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(USDASearchResponse.self, from: data)
                
                // For simplicity, grab the first relevant food item
                if let firstFood = result.foods.first {
                    
                    var calories: Double = 0
                    var protein: Double = 0
                    var carbs: Double = 0
                    var fat: Double = 0
                    
                    for nutrient in firstFood.foodNutrients {
                        // Based on USDA nutrient IDs or names
                        let name = nutrient.nutrientName.lowercased()
                        let val = nutrient.value ?? 0
                        
                        if name.contains("energy") || name.contains("calories") {
                            calories = val
                        } else if name.contains("protein") {
                            protein = val
                        } else if name.contains("carbohydrate") {
                            carbs = val
                        } else if name.contains("total lipid") || name.contains("fat") {
                            fat = val
                        }
                    }
                    
                    // Values are typically per 100g in the USDA FDC API for foundation foods
                    let info = NutritionInfo(
                        calories: calories,
                        protein: protein,
                        carbs: carbs,
                        fat: fat,
                        baseQuantityGrams: 100.0,
                        foodName: firstFood.description.capitalized
                    )
                    
                    DispatchQueue.main.async { completion(.success(info)) }
                } else {
                    DispatchQueue.main.async { completion(.failure(APIError.noData)) } // Or a custom "Not Found" error
                }
                
            } catch {
                DispatchQueue.main.async { completion(.failure(APIError.decodableError)) }
            }
        }
        
        task.resume()
    }
}
