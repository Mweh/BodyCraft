import Foundation

struct FoodResult: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let confidence: Float
    
    var formattedConfidence: String {
        return String(format: "%.1f%%", confidence * 100)
    }
}
