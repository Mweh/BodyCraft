import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    @EnvironmentObject var profileStore:  UserProfileStore
    @EnvironmentObject var streakStore:   WorkoutStreakStore

    private var profile: UserProfile { profileStore.profile }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default:      return "Good Evening"
        }
    }

    // The current day is now managed by workout streak store
    private var todayDayNumber: Int { streakStore.currentDayNumber }

    @State private var showingGoalPreset  = false   // Edit button → preset modal
    @State private var showingUpdateStats = false   // Update Progress button
    @State private var expandedDay: Int?  = nil     // Which day's exercises are expanded

    @AppStorage("savedWorkoutPlanData") private var savedWorkoutPlanData: Data = Data()
    
    var aiWorkoutPlan: AIWorkoutResponse? {
        if savedWorkoutPlanData.isEmpty { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(AIWorkoutResponse.self, from: savedWorkoutPlanData)
    }
    
    var dailyCalorieTarget: Int {
        aiWorkoutPlan?.dailyCalories ?? 600
    }
    
    var nextWorkoutFocus: String {
        aiWorkoutPlan?.weeklyWorkoutPlan.first?.focus ?? "Create your personalized workout plan"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // ── User Header ───────────────────────────────────
                        HStack {
                            VStack(alignment: .leading) {
                                Text(greeting)
                                    .foregroundColor(AppTheme.secondaryText)
                                    .font(.subheadline)
                                Text(profile.name.isEmpty ? "Athlete" : profile.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Circle()
                                .fill(AppTheme.primary)
                                .frame(width: 50, height: 50)
                                .overlay(Text(profile.initials).foregroundColor(.white).bold())
                        }
                        .padding(.horizontal)
                        
                        // ── Streak ────────────────────────────────────────
                        StreakCard(
                            todayDayNumber: todayDayNumber,
                            expandedDay:    $expandedDay,
                            streakStore:    streakStore
                        )
                        
                        // Calories Burned
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "flame.fill").foregroundColor(.orange)
                                    .padding(8).background(AppTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                Spacer()
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Calories intake target")
                                    .foregroundColor(AppTheme.secondaryText)
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("\(dailyCalorieTarget)")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("kcal by AI")
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                            }
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Daily goal calculated based on profile")
                                    Spacer()
                                }
                                .font(.caption).foregroundColor(AppTheme.secondaryText)
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppTheme.background)
                                            .frame(height: 8)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.green)
                                            .frame(width: geo.size.width * (Double(dailyCalorieTarget) > 0 ? (486.0 / Double(dailyCalorieTarget)) : 0.8), height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }
                        .padding().background(AppTheme.surface).cornerRadius(16).padding(.horizontal)

                        // ── Body Goals ────────────────────────────────────
                        BodyGoalsSection(
                            profile: profile,
                            onEditGoal:     { showingGoalPreset = true },
                            onUpdateStats:  { showingUpdateStats = true }
                        )
                        .padding(.horizontal)

                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
            // Modal 1: Edit Goal Preset
            .sheet(isPresented: $showingGoalPreset) {
                GoalPresetSheet(profileStore: profileStore)
            }
            // Modal 2: Update current stats (progress)
            .sheet(isPresented: $showingUpdateStats) {
                UpdateGoalsSheet(profileStore: profileStore)
            }
        }
    }
}

// MARK: - Body Goals Section

struct BodyGoalsSection: View {
    let profile: UserProfile
    var onEditGoal: () -> Void
    var onUpdateStats: () -> Void

    private var overallProgress: Double { profile.overallGoalProgress }

    private var presetBadgeColor: Color {
        switch profile.goalPreset {
        case "Cutting": return .cyan
        case "Bulking":  return .orange
        case "Manual":  return .purple
        default:        return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // ── Header ────────────────────────────────────────────────────
            HStack(spacing: 8) {
                Image(systemName: "target").foregroundColor(.green)
                Text("Body Goals").fontWeight(.semibold).foregroundColor(.white)

                // Active preset badge
                Text(profile.goalPreset)
                    .font(.caption2).fontWeight(.bold)
                    .foregroundColor(presetBadgeColor)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(presetBadgeColor.opacity(0.15))
                    .clipShape(Capsule())

                Spacer()

                // iOS-native Edit button → Goal Preset modal
                Button(action: onEditGoal) {
                    HStack(spacing: 3) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(AppTheme.primary)
                }
            }

            // ── Overall progress bar ──────────────────────────────────────
            VStack(spacing: 4) {
                HStack {
                    Text("Overall progress")
                        .font(.caption2).foregroundColor(AppTheme.secondaryText)
                    Spacer()
                    Text("\(Int(overallProgress * 100))%")
                        .font(.caption2).fontWeight(.bold)
                        .foregroundColor(overallProgress > 0 ? .green : AppTheme.secondaryText)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(AppTheme.background).frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(colors: [.green, .cyan], startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(4, geo.size.width * CGFloat(overallProgress)), height: 8)
                            .animation(.spring(), value: overallProgress)
                    }
                }
                .frame(height: 8)
            }

            // ── Three metric cards ────────────────────────────────────────
            HStack(spacing: 10) {
                BodyGoalCard(icon: "scalemass", title: "Weight",
                             current: profile.weight.isEmpty ? "—" : "\(profile.weight) kg",
                             target: profile.targetWeight == 0 ? "—" : "→ \(profile.targetWeightString)",
                             progress: profile.weightProgress, color: .blue)
                BodyGoalCard(icon: "percent", title: "Body Fat",
                             current: profile.bodyFat == 0 ? "—" : "\(Int(profile.bodyFat))%",
                             target: "→ \(profile.targetBodyFatString)",
                             progress: profile.bodyFatProgress, color: .orange)
                BodyGoalCard(icon: "figure.stand", title: "BMI",
                             current: profile.bmi,
                             target: "→ \(profile.targetBMIString)",
                             progress: profile.bmiProgress, color: .purple)
            }

            // ── Auto-target info strip ────────────────────────────────────
            if !profile.height.isEmpty && !profile.weight.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles").foregroundColor(AppTheme.primary).font(.caption)
                    Text("Targets: BMI \(profile.targetBMIString) · Fat \(profile.targetBodyFatString) · Weight \(profile.targetWeightString)")
                        .font(.caption2).foregroundColor(AppTheme.secondaryText).lineSpacing(3)
                }
                .padding(10).background(AppTheme.primary.opacity(0.08)).cornerRadius(10)
            }

            // ── Update Progress button ────────────────────────────────────
            Button(action: onUpdateStats) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("Update Progress")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

// MARK: - Goal Preset Sheet (Edit button)

struct GoalPresetSheet: View {
    let profileStore: UserProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var selected: String = "Current"
    @State private var manualTargetWeight: String = ""
    @State private var manualTargetBodyFat: Double = 15.0

    private var profile: UserProfile { profileStore.profile }

    private struct Preset: Identifiable {
        let id: String
        let icon: String
        let color: Color
        let headline: String
        let bmiTarget: String
        let fatTarget: String
        let description: String
    }

    private func presets(for p: UserProfile) -> [Preset] {
        let isFemale = p.gender.lowercased() == "female"
        return [
            Preset(id: "Current",
                   icon: "person.fill", color: .green,
                   headline: "Current Goals",
                   bmiTarget: "22.0", fatTarget: isFemale ? "18%" : "10%",
                   description: "Balanced healthy body composition. Default targets based on your profile."),
            Preset(id: "Cutting",
                   icon: "flame.fill", color: .cyan,
                   headline: "Cutting",
                   bmiTarget: "20.5", fatTarget: isFemale ? "15%" : "8%",
                   description: "Reduce body fat while preserving muscle. Lower calorie phase with higher cardio output."),
            Preset(id: "Bulking",
                   icon: "dumbbell.fill", color: .orange,
                   headline: "Bulking",
                   bmiTarget: "24.0", fatTarget: isFemale ? "22%" : "15%",
                   description: "Build muscle mass with a caloric surplus. Ideal for strength & size goals."),
            Preset(id: "Manual",
                   icon: "slider.horizontal.3", color: .purple,
                   headline: "Edit Manually",
                   bmiTarget: "—", fatTarget: "—",
                   description: "Set your own custom target weight and body fat percentage.")
        ]
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {

                        Text("Choose a goal plan that fits your current phase.")
                            .font(.subheadline).foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal).padding(.top, 8)

                        ForEach(presets(for: profile)) { preset in
                            Button(action: { selected = preset.id }) {
                                HStack(spacing: 14) {
                                    Image(systemName: preset.icon)
                                        .font(.title3).foregroundColor(preset.color)
                                        .frame(width: 42, height: 42)
                                        .background(preset.color.opacity(0.15))
                                        .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(preset.headline)
                                                .fontWeight(.semibold).foregroundColor(.white)
                                            if preset.id == profile.goalPreset {
                                                Text("Active")
                                                    .font(.caption2).fontWeight(.bold)
                                                    .foregroundColor(preset.color)
                                                    .padding(.horizontal, 7).padding(.vertical, 2)
                                                    .background(preset.color.opacity(0.15))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                        if preset.id != "Manual" {
                                            HStack(spacing: 12) {
                                                Label("BMI \(preset.bmiTarget)", systemImage: "figure.stand")
                                                Label("Fat \(preset.fatTarget)", systemImage: "percent")
                                            }
                                            .font(.caption2).foregroundColor(preset.color.opacity(0.8))
                                        }
                                        Text(preset.description)
                                            .font(.caption).foregroundColor(AppTheme.secondaryText)
                                            .lineSpacing(2)
                                    }

                                    Spacer(minLength: 0)

                                    if selected == preset.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(preset.color).font(.title3)
                                    } else {
                                        Circle()
                                            .stroke(AppTheme.secondaryText.opacity(0.3), lineWidth: 1.5)
                                            .frame(width: 22, height: 22)
                                    }
                                }
                                .padding(14)
                                .background(AppTheme.surface)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selected == preset.id ? preset.color.opacity(0.5) : Color.clear, lineWidth: 1.5)
                                )
                            }
                        }

                        // Manual fields (only shown when Manual is selected)
                        if selected == "Manual" {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Custom Targets")
                                    .fontWeight(.semibold).foregroundColor(.white)

                                HStack {
                                    TextField("Target weight", text: $manualTargetWeight)
                                        .keyboardType(.decimalPad)
                                        .padding().background(AppTheme.background).cornerRadius(12)
                                        .foregroundColor(.white)
                                    Text("kg").foregroundColor(AppTheme.secondaryText)
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Target Body Fat").foregroundColor(.white)
                                        Spacer()
                                        Text(String(format: "%.0f%%", manualTargetBodyFat))
                                            .fontWeight(.bold).foregroundColor(.purple)
                                    }
                                    Slider(value: $manualTargetBodyFat, in: 5...40, step: 1)
                                        .accentColor(.purple)
                                }
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal)
                    .animation(.easeInOut(duration: 0.2), value: selected)
                }
            }
            .navigationTitle("Goal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(AppTheme.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        profileStore.update { p in
                            p.goalPreset = selected
                            if selected == "Manual" {
                                p.customTargetWeight  = manualTargetWeight
                                p.customTargetBodyFat = manualTargetBodyFat
                            }
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold).foregroundColor(AppTheme.primary)
                }
            }
        }
        .onAppear {
            selected           = profile.goalPreset
            manualTargetWeight = profile.customTargetWeight
            manualTargetBodyFat = profile.customTargetBodyFat > 0 ? profile.customTargetBodyFat : 15.0
        }
    }
}

// MARK: - Update Stats Sheet (Update Progress button)

struct UpdateGoalsSheet: View {
    let profileStore: UserProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var weightInput: String = ""
    @State private var bodyFatInput: Double = 20.0

    private var profile: UserProfile { profileStore.profile }

    private var previewBMI: String {
        guard let h = Double(profile.height), h > 0, let w = Double(weightInput) else { return "—" }
        let bmi = w / ((h / 100) * (h / 100))
        return String(format: "%.1f", bmi)
    }

    private var bmiCategory: (label: String, color: Color) {
        guard let val = Double(previewBMI) else { return ("—", .white) }
        switch val {
        case ..<18.5: return ("Underweight", .yellow)
        case ..<25.0: return ("Normal ✓", .green)
        case ..<30.0: return ("Overweight", .orange)
        default:      return ("Obese", .red)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Log your current body stats to update your progress rings.")
                            .font(.subheadline).foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center).padding(.horizontal).padding(.top, 8)

                        // Weight
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Current Weight", systemImage: "scalemass")
                                .foregroundColor(.white).fontWeight(.semibold)
                            HStack {
                                TextField("e.g. 80", text: $weightInput)
                                    .keyboardType(.decimalPad)
                                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
                                    .padding().background(AppTheme.background).cornerRadius(12)
                                Text("kg").foregroundColor(AppTheme.secondaryText).font(.title3)
                            }
                        }
                        .padding().background(AppTheme.surface).cornerRadius(16).padding(.horizontal)

                        // Body Fat
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Current Body Fat", systemImage: "percent")
                                .foregroundColor(.white).fontWeight(.semibold)
                            HStack {
                                Text(String(format: "%.0f%%", bodyFatInput))
                                    .font(.title2).fontWeight(.bold).foregroundColor(.white).frame(width: 56, alignment: .leading)
                                Slider(value: $bodyFatInput, in: 5...45, step: 1)
                                    .accentColor(BodyFatCategory.category(for: bodyFatInput).color)
                            }
                            Text(BodyFatCategory.category(for: bodyFatInput).label)
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(BodyFatCategory.category(for: bodyFatInput).color)
                                .padding(.horizontal, 12).padding(.vertical, 4)
                                .background(BodyFatCategory.category(for: bodyFatInput).color.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .padding().background(AppTheme.surface).cornerRadius(16).padding(.horizontal)

                        // Live BMI preview
                        if !weightInput.isEmpty {
                            HStack(spacing: 12) {
                                VStack(spacing: 4) {
                                    Text("BMI Preview").font(.caption).foregroundColor(AppTheme.secondaryText)
                                    Text(previewBMI).font(.title).fontWeight(.bold).foregroundColor(.white)
                                    Text(bmiCategory.label).font(.caption).fontWeight(.semibold).foregroundColor(bmiCategory.color)
                                }
                                .frame(maxWidth: .infinity).padding().background(AppTheme.surface).cornerRadius(14)

                                VStack(spacing: 4) {
                                    Text("Target BMI").font(.caption).foregroundColor(AppTheme.secondaryText)
                                    Text(profile.targetBMIString).font(.title).fontWeight(.bold).foregroundColor(.white)
                                    Text("Goal").font(.caption).fontWeight(.semibold).foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity).padding().background(AppTheme.surface).cornerRadius(14)
                            }
                            .padding(.horizontal)
                        }

                        Spacer().frame(height: 20)
                    }
                }
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(AppTheme.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        profileStore.update { p in
                            if !weightInput.isEmpty { p.weight = weightInput }
                            p.bodyFat = bodyFatInput
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold).foregroundColor(AppTheme.primary)
                    .disabled(weightInput.isEmpty)
                }
            }
        }
        .onAppear {
            weightInput  = profile.weight
            bodyFatInput = profile.bodyFat
        }
    }
}

// MARK: - BodyGoalCard

struct BodyGoalCard: View {
    let icon: String
    let title: String
    let current: String
    let target: String
    let progress: Double
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.caption).foregroundColor(color)
                .padding(6).background(color.opacity(0.15)).clipShape(Circle())

            ZStack {
                Circle().stroke(color.opacity(0.15), lineWidth: 4)
                Circle().trim(from: 0, to: CGFloat(progress))
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: progress)
                Text(progress == 0 ? "0%" : "\(Int(progress * 100))%")
                    .font(.system(size: 9, weight: .bold)).foregroundColor(.white)
            }
            .frame(width: 36, height: 36)

            Text(title).font(.caption2).foregroundColor(AppTheme.secondaryText)
            Text(current).font(.caption).fontWeight(.bold).foregroundColor(.white)
            Text(target).font(.system(size: 9)).foregroundColor(color.opacity(0.8)).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(AppTheme.background).cornerRadius(14)
    }
}

// MARK: - Legacy GoalMetricCard
struct GoalMetricCard: View {
    let title: String; let current: String; let target: String
    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundColor(AppTheme.secondaryText)
            Text(current).fontWeight(.bold).foregroundColor(.white)
            Text(target).font(.caption2).foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - StreakCard

struct StreakCard: View {
    let todayDayNumber: Int
    @Binding var expandedDay: Int?
    @ObservedObject var streakStore: WorkoutStreakStore

    private var streakCount: Int { streakStore.streakCount }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // ── Header ─────────────────────────────────────────────
            HStack {
                Image(systemName: "bolt.fill").foregroundColor(.yellow)
                Text(streakCount == 0 ? "No Streak Yet" : "\(streakCount) Day Streak")
                    .fontWeight(.semibold).foregroundColor(.white)
                Spacer()
                Text("Week Program").foregroundColor(AppTheme.secondaryText).font(.caption)
            }

            // ── Day Circles ──────────────────────────────────────
            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    let isToday     = day == todayDayNumber
                    let isCompleted = streakStore.isDayCompleted(day: day)
                    let isExpanded  = expandedDay == day

                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            expandedDay = isExpanded ? nil : day
                        }
                    }) {
                        StreakDayCircle(
                            day: day,
                            isToday: isToday,
                            isCompleted: isCompleted,
                            isExpanded: isExpanded
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // ── Expanded Exercise List ──────────────────────────────
            if let day = expandedDay,
               let workout = WorkoutPlanData.workout(for: day) {

                VStack(alignment: .leading, spacing: 0) {

                    // Day title bar
                    HStack {
                        Text("Day \(day): \(workout.title)")
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                        Spacer()
                        let done  = workout.exercises.filter { streakStore.isExerciseCompleted(day: day, exerciseId: $0.id) }.count
                        let total = workout.exercises.count
                        Text("\(done)/\(total)")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundColor(done == total ? .green : AppTheme.secondaryText)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppTheme.primary.opacity(0.12))
                    .cornerRadius(10)

                    // Exercise rows
                    let isFutureDay = day > todayDayNumber
                    ForEach(workout.exercises) { exercise in
                        HomeExerciseRow(
                            exercise: exercise,
                            isChecked: streakStore.isExerciseCompleted(day: day, exerciseId: exercise.id),
                            isDisabled: isFutureDay,
                            onToggle: { streakStore.toggle(day: day, exercise: exercise) }
                        )
                    }
                }
                .background(AppTheme.background.opacity(0.6))
                .cornerRadius(12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

// MARK: - StreakDayCircle

struct StreakDayCircle: View {
    let day: Int
    let isToday: Bool
    let isCompleted: Bool
    let isExpanded: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Background ring for today
                if isToday {
                    Circle()
                        .stroke(AppTheme.primary, lineWidth: 2)
                        .frame(width: 40, height: 40)
                }

                Circle()
                    .fill(isCompleted ? AppTheme.primary : (isExpanded ? AppTheme.primary.opacity(0.25) : AppTheme.background))
                    .frame(width: 36, height: 36)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(day)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isToday ? AppTheme.primary : AppTheme.secondaryText)
                }
            }

            Text(isToday ? "Today" : "Day \(day)")
                .font(.system(size: 9, weight: isToday ? .bold : .regular))
                .foregroundColor(isToday ? AppTheme.primary : AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - HomeExerciseRow

struct HomeExerciseRow: View {
    let exercise: Exercise
    let isChecked: Bool
    let isDisabled: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isChecked ? AppTheme.primary : AppTheme.secondaryText.opacity(isDisabled ? 0.1 : 0.4), lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isChecked ? AppTheme.primary : Color.clear)
                        )
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // Exercise name
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isChecked ? AppTheme.secondaryText : (isDisabled ? AppTheme.secondaryText.opacity(0.5) : .white))
                        .strikethrough(isChecked)
                    Text(exercise.detail)
                        .font(.caption2)
                        .foregroundColor(AppTheme.secondaryText.opacity(isDisabled ? 0.5 : 1.0))
                }

                Spacer()

                // Sets badge
                Text("\(exercise.sets)x\(exercise.reps)")
                    .font(.caption2).fontWeight(.bold)
                    .foregroundColor(isChecked ? .green : (isDisabled ? AppTheme.secondaryText.opacity(0.5) : AppTheme.primary))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background((isChecked ? Color.green : (isDisabled ? AppTheme.secondaryText : AppTheme.primary)).opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        Divider().background(AppTheme.secondaryText.opacity(0.1)).padding(.leading, 50)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserProfileStore())
            .environmentObject(WorkoutStreakStore())
    }
}
