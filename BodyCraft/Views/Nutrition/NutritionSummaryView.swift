import SwiftUI

struct NutritionSummaryView: View {
    @State private var showingScanner = false
    
    // Mock Data based on UI
    let consumedCalories = 1420.0
    let targetCalories = 2200.0
    let protein = (current: 115.0, target: 165.0)
    let carbs = (current: 140.0, target: 220.0)
    let fat = (current: 50.0, target: 73.0)
    
    // Mock Meals
    let meals = [
        MealRecord(title: "Breakfast", time: "07:00", calories: "520 kcal", p: "40g", c: "55g", f: "18g", isCompleted: true),
        MealRecord(title: "Morning Snack", time: "10:00", calories: "250 kcal", p: "25g", c: "20g", f: "10g", isCompleted: true),
        MealRecord(title: "Lunch", time: "12:30", calories: "650 kcal", p: "50g", c: "65g", f: "22g", isCompleted: true),
        MealRecord(title: "Pre-Workout", time: "15:30", calories: "200 kcal", p: "15g", c: "30g", f: "5g", isCompleted: false),
        MealRecord(title: "Post-Workout", time: "18:00", calories: "350 kcal", p: "40g", c: "35g", f: "8g", isCompleted: false)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nutrition")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            Text("Meal plan for your aesthetic body")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding(.horizontal)
                        
                        // Main Calorie & Macro Card
                        VStack(spacing: 20) {
                            HStack {
                                Text("Today's Calories")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(consumedCalories)) / \(Int(targetCalories)) kcal")
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppTheme.background)
                                        .frame(height: 12)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.green)
                                        .frame(width: geo.size.width * (consumedCalories / targetCalories), height: 12)
                                }
                            }
                            .frame(height: 12)
                            
                            Text("\(Int(targetCalories - consumedCalories)) kcal remaining")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.secondaryText)
                            
                            HStack(spacing: 20) {
                                MacroTracker(name: "Protein", current: protein.current, target: protein.target, color: .red)
                                MacroTracker(name: "Carbs", current: carbs.current, target: carbs.target, color: .yellow)
                                MacroTracker(name: "Fat", current: fat.current, target: fat.target, color: .blue)
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Meal Plan List
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Meal Plan")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(meals.count) meals")
                                    .foregroundColor(AppTheme.secondaryText)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal)
                            
                            Button(action: { showingScanner = true }) {
                                HStack {
                                    Image(systemName: "camera.viewfinder")
                                    Text("Scan Food")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.primary)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(meals) { meal in
                                    MealCard(meal: meal)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingScanner) {
                // Instantiates the FoodScanner flow within Nutrition
                FoodScannerView()
            }
        }
    }
}

// Reusable Components
struct MacroTracker: View {
    let name: String
    let current: Double
    let target: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(name)
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppTheme.background)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * (current / target), height: 6)
                }
            }
            .frame(height: 6)
            
            HStack(spacing: 0) {
                Text("\(Int(current))g ")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("/ \(Int(target))g")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
    }
}

struct MealRecord: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let calories: String
    let p: String
    let c: String
    let f: String
    let isCompleted: Bool
}

struct MealCard: View {
    let meal: MealRecord
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(meal.isCompleted ? .green : .clear)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.white)
                        .opacity(meal.isCompleted ? 1 : 0)
                )
                .overlay(
                    Circle()
                        .stroke(meal.isCompleted ? .clear : AppTheme.secondaryText, lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.title)
                    .font(.headline)
                    .foregroundColor(meal.isCompleted ? .green : .white)
                
                HStack(spacing: 8) {
                    Text(meal.calories)
                        .foregroundColor(.cyan)
                    Text("P:\(meal.p)")
                    Text("C:\(meal.c)")
                    Text("F:\(meal.f)")
                }
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(meal.time)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
                Image(systemName: "chevron.down")
                    .foregroundColor(AppTheme.secondaryText)
                    .font(.caption)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(meal.isCompleted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct NutritionSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionSummaryView()
    }
}
