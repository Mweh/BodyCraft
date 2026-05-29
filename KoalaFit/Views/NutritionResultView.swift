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
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Image Preview - constrained to ~25% height
                    if let image = capturedImage {
                        GeometryReader { geo in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: 240) // Fixed height for 25% feel
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .frame(height: 240)
                        .padding(.horizontal)
                        .padding(.top, 24)
                    }
                    
                    VStack(spacing: 8) {
                        Text(nutritionInfo.foodName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Nutrition Insight")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding(.horizontal)
                    
                    // Portion Control Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Portion Size")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(Int(portionGrams))g")
                                .font(.subheadline).bold()
                                .foregroundColor(AppTheme.primary)
                        }
                        
                        Slider(value: $portionGrams, in: 10...500, step: 10) { _ in
                            portionMultiplier = portionGrams / nutritionInfo.baseQuantityGrams
                        }
                        .tint(AppTheme.primary)
                    }
                    .padding(20)
                    .background(AppTheme.surface)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Macros Grid-like Layout
                    VStack(spacing: 12) {
                        MacroRow(title: "Calories", value: String(format: "%.0f kcal", calculatedCalories), color: .orange)
                        MacroRow(title: "Protein", value: String(format: "%.1f g", calculatedProtein), color: .red)
                        MacroRow(title: "Carbs", value: String(format: "%.1f g", calculatedCarbs), color: Color(red:1,green:0.8,blue:0.1))
                        MacroRow(title: "Fat", value: String(format: "%.1f g", calculatedFat), color: .cyan)
                    }
                    .padding(20)
                    .background(AppTheme.surface)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Button(action: logMeal) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Log to Today")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.primary)
                            .cornerRadius(16)
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        Button(action: onReset) {
                            Text("Retake Photo")
                                .font(.subheadline).bold()
                                .foregroundColor(AppTheme.secondaryText)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
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
