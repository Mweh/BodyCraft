import Foundation

struct NutritionInfo: Equatable {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    
    /// Default portions assumed to be per 100g, but we keep this flexible
    var baseQuantityGrams: Double = 100.0
    var foodName: String
}

// MARK: - USDA API Response Models

struct USDASearchResponse: Codable {
    let totalHits: Int
    let foods: [USDAFoodItem]
}

struct USDAFoodItem: Codable {
    let fdcId: Int
    let description: String
    let foodNutrients: [USDANutrient]
}

struct USDANutrient: Codable {
    let nutrientId: Int
    let nutrientName: String
    let value: Double?
}
