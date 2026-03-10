import SwiftUI

struct NutritionResultView: View {
    let nutritionInfo: NutritionInfo
    let onReset: () -> Void
    
    @State private var portionMultiplier: Double = 1.0
    
    // We'll let the user choose grams
    // e.g., Base is 100g. If user eats 150g -> multiplier is 1.5
    @State private var portionGrams: Double = 100.0
    
    var calculatedCalories: Double { nutritionInfo.calories * portionMultiplier }
    var calculatedProtein: Double { nutritionInfo.protein * portionMultiplier }
    var calculatedCarbs: Double { nutritionInfo.carbs * portionMultiplier }
    var calculatedFat: Double { nutritionInfo.fat * portionMultiplier }
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            Text(nutritionInfo.foodName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Portion Control
            VStack {
                Text("Portion Size: \(Int(portionGrams))g")
                    .font(.headline)
                
                Slider(value: $portionGrams, in: 10...500, step: 10) { _ in
                    portionMultiplier = portionGrams / nutritionInfo.baseQuantityGrams
                }
                .padding()
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Macros Layout
            VStack(spacing: 16) {
                MacroRow(title: "Calories", value: String(format: "%.0f kcal", calculatedCalories), color: .orange)
                MacroRow(title: "Protein", value: String(format: "%.1f g", calculatedProtein), color: .red)
                MacroRow(title: "Carbs", value: String(format: "%.1f g", calculatedCarbs), color: .blue)
                MacroRow(title: "Fat", value: String(format: "%.1f g", calculatedFat), color: .yellow)
            }
            .padding()
            
            Spacer()
            
            Button(action: onReset) {
                Text("Track Another Meal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .onAppear {
            portionMultiplier = portionGrams / nutritionInfo.baseQuantityGrams
        }
    }
}

struct MacroRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}
