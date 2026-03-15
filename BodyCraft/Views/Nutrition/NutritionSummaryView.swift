import SwiftUI

// MARK: - NutritionSummaryView

struct NutritionSummaryView: View {
    @EnvironmentObject var profileStore:   UserProfileStore
    @EnvironmentObject var nutritionStore: NutritionStore

    @State private var showingScanner     = false
    @State private var showingAddManually = false
    @State private var showingHistory     = false
    @State private var editingEntry: FoodLogEntry? = nil

    private var profile: UserProfile { profileStore.profile }
    private var goals:   DailyNutritionGoals { profile.dailyNutritionGoals }

    private var kcalLeft: Double {
        max(goals.calories - nutritionStore.totalCalories, 0)
    }

    private var calorieProgress: Double {
        guard goals.calories > 0 else { return 0 }
        return min(nutritionStore.totalCalories / goals.calories, 1.0)
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // ── Page Header ──────────────────────────
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Nutrition")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Track your calories and macros")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                            Spacer()
                            // History button
                            Button {
                                showingHistory = true
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text("History")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(AppTheme.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(AppTheme.primary.opacity(0.12))
                                .clipShape(Capsule())
                            }
                            .padding(.top, 6)
                        }
                        .padding(.horizontal)

                        // ── Today's Calories Card ─────────────────
                        todaysCaloriesCard
                            .padding(.horizontal)

                        // ── Action Buttons ───────────────────────
                        VStack(spacing: 12) {
                            Button {
                                showingScanner = true
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Scan Food")
                                        .font(.headline).fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.primary)
                                .cornerRadius(14)
                            }

                            Button {
                                showingAddManually = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Add Food Manually")
                                        .font(.headline).fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.surface)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AppTheme.secondaryText.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)

                        // ── Today's Food Log ──────────────────────
                        foodLogSection

                        // ── Daily Insight ─────────────────────────
                        dailyInsightCard.padding(.horizontal)

                        // ── Nutrition Tips ────────────────────────
                        nutritionTipsSection

                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingScanner) {
                FoodScannerView()
            }
            .sheet(isPresented: $showingAddManually) {
                AddFoodManuallySheet()
                    .environmentObject(nutritionStore)
            }
            .sheet(item: $editingEntry) { entry in
                EditFoodEntrySheet(entry: entry)
                    .environmentObject(nutritionStore)
            }
            .sheet(isPresented: $showingHistory) {
                NutritionHistoryView()
                    .environmentObject(nutritionStore)
            }
        }
    }

    // MARK: - Today's Calories Card

    private var todaysCaloriesCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Calories")
                    .foregroundColor(.white)
                    .font(.subheadline).fontWeight(.medium)
                Spacer()
            }

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("\(Int(nutritionStore.totalCalories))")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                Text("/ \(Int(goals.calories)) kcal")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppTheme.background).frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.8), .green],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * calorieProgress, height: 10)
                        .animation(.spring(response: 0.5), value: calorieProgress)
                }
            }
            .frame(height: 10)

            HStack(spacing: 0) {
                NutritionMacroTracker(name: "Protein", current: nutritionStore.totalProtein, target: goals.protein, color: .red)
                NutritionMacroTracker(name: "Carbs",   current: nutritionStore.totalCarbs,   target: goals.carbs,   color: Color(red:1,green:0.8,blue:0.1))
                NutritionMacroTracker(name: "Fat",     current: nutritionStore.totalFat,     target: goals.fat,     color: .cyan)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(20)
    }

    // MARK: - Food Log Section

    private var foodLogSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Today's Food Log")
                    .font(.title3).fontWeight(.bold).foregroundColor(.white)
                Spacer()
                if !nutritionStore.todayEntries.isEmpty {
                    Text("\(nutritionStore.todayEntries.count) item\(nutritionStore.todayEntries.count != 1 ? "s" : "")")
                        .font(.caption).foregroundColor(AppTheme.secondaryText)
                }
            }
            .padding(.horizontal)

            if nutritionStore.todayEntries.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.secondaryText.opacity(0.4))
                        Text("No food logged yet")
                            .foregroundColor(AppTheme.secondaryText)
                            .font(.subheadline)
                        Text("Tap \"Add Food Manually\" or \"Scan Food\" to get started")
                            .foregroundColor(AppTheme.secondaryText.opacity(0.6))
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 32)
                    Spacer()
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 10) {
                    ForEach(nutritionStore.todayEntries) { entry in
                        FoodLogCard(entry: entry) {
                            editingEntry = entry
                        } onDelete: {
                            nutritionStore.deleteByID(entry.id)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Daily Insight Card

    private var dailyInsightCard: some View {
        let proteinLeft  = max(goals.protein - nutritionStore.totalProtein, 0)
        let caloriesLeft = max(goals.calories - nutritionStore.totalCalories, 0)

        let text: String
        if nutritionStore.todayEntries.isEmpty {
            text = "Log your first meal to start tracking today's nutrition."
        } else if proteinLeft > 5 {
            text = "You still need \(Int(proteinLeft))g of protein to reach today's goal."
        } else if caloriesLeft > 100 {
            text = "You have \(Int(caloriesLeft)) kcal remaining. Keep it up!"
        } else if nutritionStore.totalCalories > goals.calories {
            text = "You've exceeded today's calorie goal by \(Int(nutritionStore.totalCalories - goals.calories)) kcal."
        } else {
            text = "Great job! You're on track with today's nutrition goals. 💪"
        }

        return HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(Color.yellow.opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Insight")
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                Text(text)
                    .font(.caption).foregroundColor(AppTheme.secondaryText).lineSpacing(3)
            }
            Spacer()
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
    }

    // MARK: - Nutrition Tips Section

    private var nutritionTipsSection: some View {
        let tips = [
            "Consume 1.6–2.2g of protein per kg of body weight for optimal muscle growth",
            "Eat in a 300–500 calorie surplus for bulking, or a 300–500 deficit for cutting",
            "Prioritize whole foods — aim for at least 80% of your total intake",
            "Nutrient timing: Consume protein every 3–4 hours for optimal protein synthesis"
        ]

        return VStack(alignment: .leading, spacing: 14) {
            Text("Nutrition Tips")
                .font(.title3).fontWeight(.bold).foregroundColor(.white)
                .padding(.horizontal)

            VStack(spacing: 10) {
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle().fill(Color.green.opacity(0.12)).frame(width: 36, height: 36)
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                        }
                        Text(tip)
                            .font(.subheadline).foregroundColor(AppTheme.secondaryText).lineSpacing(3)
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - NutritionMacroTracker

struct NutritionMacroTracker: View {
    let name: String
    let current: Double
    let target: Double
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 7, height: 7)
                Text(name).font(.caption2).foregroundColor(AppTheme.secondaryText)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(AppTheme.background).frame(height: 5)
                    RoundedRectangle(cornerRadius: 4).fill(color)
                        .frame(width: geo.size.width * CGFloat(progress), height: 5)
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 5)
            HStack(spacing: 0) {
                Text("\(Int(current))g ").font(.caption).fontWeight(.bold).foregroundColor(.white)
                Text("/ \(Int(target))g").font(.caption).foregroundColor(AppTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - FoodLogCard

struct FoodLogCard: View {
    let entry: FoodLogEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var iconColor: Color {
        foodIconOptions.first { $0.id == entry.iconName }?.color ?? AppTheme.secondaryText
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: entry.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                    .lineLimit(1)
                Text(entry.timeString)
                    .font(.caption).foregroundColor(AppTheme.secondaryText)

                HStack(spacing: 8) {
                    Text("\(Int(entry.calories * entry.servings)) kcal")
                        .font(.caption).fontWeight(.bold).foregroundColor(AppTheme.primary)
                    macroLabel("P:", value: entry.protein * entry.servings, color: .red)
                    macroLabel("C:", value: entry.carbs   * entry.servings, color: Color(red:1,green:0.8,blue:0.1))
                    macroLabel("F:", value: entry.fat     * entry.servings, color: .cyan)
                }
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption).foregroundColor(AppTheme.secondaryText)
                }
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption).foregroundColor(AppTheme.secondaryText.opacity(0.7))
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
    }

    @ViewBuilder
    private func macroLabel(_ prefix: String, value: Double, color: Color) -> some View {
        HStack(spacing: 0) {
            Text(prefix).font(.caption).foregroundColor(AppTheme.secondaryText)
            Text("\(Int(value))g").font(.caption).fontWeight(.semibold).foregroundColor(color)
        }
    }
}

// MARK: - Edit Food Entry Sheet

struct EditFoodEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var nutritionStore: NutritionStore

    let entry: FoodLogEntry

    @State private var foodName: String
    @State private var caloriesText: String
    @State private var proteinText: String
    @State private var carbsText: String
    @State private var fatText: String
    @State private var selectedIconID: String
    @State private var servingSize: Double

    private let servingOptions: [(label: String, value: Double)] = [
        ("0.5 serving", 0.5), ("1 serving", 1.0),
        ("1.5 servings", 1.5), ("2 servings", 2.0), ("3 servings", 3.0)
    ]

    init(entry: FoodLogEntry) {
        self.entry = entry
        _foodName      = State(initialValue: entry.name)
        _caloriesText  = State(initialValue: String(Int(entry.calories)))
        _proteinText   = State(initialValue: String(Int(entry.protein)))
        _carbsText     = State(initialValue: String(Int(entry.carbs)))
        _fatText       = State(initialValue: String(Int(entry.fat)))
        _selectedIconID = State(initialValue: entry.iconName)
        _servingSize   = State(initialValue: entry.servings)
    }

    private var isFormValid: Bool {
        !foodName.trimmingCharacters(in: .whitespaces).isEmpty && Double(caloriesText) != nil
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                Capsule()
                    .fill(AppTheme.secondaryText.opacity(0.4))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12).padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Text("Edit Entry")
                                .font(.title2).fontWeight(.bold).foregroundColor(.white)
                            Spacer()
                            Button { dismiss() } label: {
                                ZStack {
                                    Circle().fill(AppTheme.surface).frame(width: 32, height: 32)
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                            }
                        }

                        // Icon picker
                        Text("Food Icon")
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundColor(AppTheme.secondaryText)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(foodIconOptions) { icon in
                                    let isSelected = selectedIconID == icon.id
                                    Button { selectedIconID = icon.id } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(isSelected ? icon.color.opacity(0.2) : AppTheme.surface)
                                                .frame(width: 48, height: 48)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(isSelected ? icon.color : Color.clear, lineWidth: 1.5)
                                                )
                                            Image(systemName: icon.id)
                                                .font(.system(size: 20))
                                                .foregroundColor(isSelected ? icon.color : AppTheme.secondaryText)
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Food Name").font(.subheadline).fontWeight(.medium).foregroundColor(AppTheme.secondaryText)
                            TextField("Food name", text: $foodName)
                                .padding().background(AppTheme.surface).cornerRadius(12)
                                .foregroundColor(.white).tint(AppTheme.primary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Calories (kcal)").font(.subheadline).fontWeight(.medium).foregroundColor(AppTheme.secondaryText)
                            TextField("e.g. 350", text: $caloriesText)
                                .keyboardType(.decimalPad)
                                .padding().background(AppTheme.surface).cornerRadius(12)
                                .foregroundColor(.white).tint(AppTheme.primary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Macros (g)").font(.subheadline).fontWeight(.medium).foregroundColor(AppTheme.secondaryText)
                            HStack(spacing: 10) {
                                MacroInputField(label: "Protein", color: .red, text: $proteinText)
                                MacroInputField(label: "Carbs", color: Color(red:1,green:0.8,blue:0.1), text: $carbsText)
                                MacroInputField(label: "Fat", color: .cyan, text: $fatText)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Serving Size").font(.subheadline).fontWeight(.medium).foregroundColor(AppTheme.secondaryText)
                            Menu {
                                ForEach(servingOptions, id: \.label) { opt in
                                    Button(opt.label) { servingSize = opt.value }
                                }
                            } label: {
                                HStack {
                                    Text(servingOptions.first { $0.value == servingSize }?.label ?? "1 serving")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down").foregroundColor(AppTheme.secondaryText).font(.caption)
                                }
                                .padding().background(AppTheme.surface).cornerRadius(12)
                            }
                        }

                        Spacer().frame(height: 8)
                    }
                    .padding(.horizontal, 20)
                }

                HStack(spacing: 12) {
                    Button("Cancel") { dismiss() }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(AppTheme.surface).foregroundColor(.white).cornerRadius(14)
                    Button("Save Changes") { saveChanges() }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(isFormValid ? AppTheme.primary : AppTheme.primary.opacity(0.4))
                        .foregroundColor(.white).fontWeight(.semibold).cornerRadius(14)
                        .disabled(!isFormValid)
                }
                .padding(.horizontal, 20).padding(.vertical, 16).background(AppTheme.background)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func saveChanges() {
        guard let cal = Double(caloriesText) else { return }
        var updated      = entry
        updated.name     = foodName.trimmingCharacters(in: .whitespaces)
        updated.iconName = selectedIconID
        updated.calories = cal
        updated.protein  = Double(proteinText) ?? 0
        updated.carbs    = Double(carbsText)   ?? 0
        updated.fat      = Double(fatText)     ?? 0
        updated.servings = servingSize
        nutritionStore.update(entry: updated)
        dismiss()
    }
}

// MARK: - Preview

struct NutritionSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionSummaryView()
            .environmentObject(UserProfileStore())
            .environmentObject(NutritionStore())
            .preferredColorScheme(.dark)
    }
}
