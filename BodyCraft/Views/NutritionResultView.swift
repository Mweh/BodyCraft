import SwiftUI

struct NutritionResultView: View {
    @EnvironmentObject var nutritionStore: NutritionStore
    let nutritionInfo: NutritionInfo
    let capturedImage: UIImage?
    let onReset: () -> Void
    let onDismiss: () -> Void
    
    @State private var portionMultiplier: Double = 1.0
    
    // We'll let the user choose grams
    // e.g., Base is 100g. If user eats 150g -> multiplier is 1.5
    @State private var portionGrams: Double = 100.0
    
    var calculatedCalories: Double { nutritionInfo.calories * portionMultiplier }
    var calculatedProtein: Double { nutritionInfo.protein * portionMultiplier }
    var calculatedCarbs: Double { nutritionInfo.carbs * portionMultiplier }
    var calculatedFat: Double { nutritionInfo.fat * portionMultiplier }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                        .padding(.top, 20)
                }
                
                Text(nutritionInfo.foodName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Portion Control
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Portion Size")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(portionGrams))g")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $portionGrams, in: 10...500, step: 10) { _ in
                        portionMultiplier = portionGrams / nutritionInfo.baseQuantityGrams
                    }
                }
                .padding()
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
                
                VStack(spacing: 12) {
                    Button(action: logMeal) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Log Meal")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    
                    Button(action: onReset) {
                        Text("Scan Another")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            portionMultiplier = portionGrams / nutritionInfo.baseQuantityGrams
        }
    }
    
    private func logMeal() {
        let entry = FoodLogEntry(
            name: nutritionInfo.foodName,
            iconName: "fork.knife",
            calories: calculatedCalories,
            protein: calculatedProtein,
            carbs: calculatedCarbs,
            fat: calculatedFat,
            time: Date(),
            servings: 1.0 // We use base amounts * multiplier
        )
        nutritionStore.add(entry: entry)
        onDismiss()
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
