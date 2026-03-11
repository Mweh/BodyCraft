import SwiftUI

struct HomeView: View {
    @EnvironmentObject var profileStore: UserProfileStore

    private var profile: UserProfile { profileStore.profile }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default:      return "Good Evening"
        }
    }

    let streakDays = [
        ("Mon", true), ("Tue", true), ("Wed", true), ("Thu", true),
        ("Fri", false), ("Sat", false), ("Sun", false)
    ]

    // Edit sheet state
    @State private var showingGoalEdit = false

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
                                .overlay(
                                    Text(profile.initials)
                                        .foregroundColor(.white)
                                        .bold()
                                )
                        }
                        .padding(.horizontal)

                        // ── AI Workout Quick Link ─────────────────────────
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(AppTheme.primary)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Workout Plan")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                Text("Create your personalized workout plan")
                                    .foregroundColor(AppTheme.secondaryText)
                                    .font(.caption)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // ── 4 Day Streak ──────────────────────────────────
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "bolt.fill").foregroundColor(.yellow)
                                Text("4 Day Streak")
                                    .fontWeight(.semibold).foregroundColor(.white)
                                Spacer()
                                Text("This Week")
                                    .foregroundColor(AppTheme.secondaryText).font(.caption)
                            }

                            HStack(spacing: 12) {
                                ForEach(streakDays, id: \.0) { day in
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(day.1 ? AppTheme.primary : AppTheme.surface)
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.white)
                                                    .font(.caption)
                                                    .opacity(day.1 ? 1 : 0)
                                            )
                                        Text(day.0)
                                            .font(.caption)
                                            .foregroundColor(day.1 ? .white : AppTheme.secondaryText)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // ── Calories Burned ───────────────────────────────
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                    .padding(8)
                                    .background(AppTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                Spacer()
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Calories burned today")
                                    .foregroundColor(AppTheme.secondaryText)
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("0")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("kcal").foregroundColor(AppTheme.secondaryText)
                                }
                            }
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Daily goal")
                                    Spacer()
                                    Text("0 / 600 kcal")
                                }
                                .font(.caption).foregroundColor(AppTheme.secondaryText)

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppTheme.background).frame(height: 8)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.green)
                                            .frame(width: 0, height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // ── Body Goals ────────────────────────────────────
                        BodyGoalsSection(profile: profile, onEdit: { showingGoalEdit = true })
                            .padding(.horizontal)

                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
            // Native iOS modal sheet
            .sheet(isPresented: $showingGoalEdit) {
                UpdateGoalsSheet(profileStore: profileStore)
            }
        }
    }
}

// MARK: - Body Goals Section

struct BodyGoalsSection: View {
    let profile: UserProfile
    var onEdit: () -> Void

    private var overallProgress: Double { profile.overallGoalProgress }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header row
            HStack {
                Image(systemName: "target").foregroundColor(.green)
                Text("Body Goals")
                    .fontWeight(.semibold).foregroundColor(.white)
                Spacer()

                // Native iOS Edit button (replaces "Just started")
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.primary)
                }
            }

            // Overall progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.background).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(colors: [.green, .cyan],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: max(4, geo.size.width * CGFloat(overallProgress)), height: 8)
                        .animation(.spring(), value: overallProgress)
                }
            }
            .frame(height: 8)

            // Three goal metric cards
            HStack(spacing: 10) {
                BodyGoalCard(
                    icon: "scalemass",
                    title: "Weight",
                    current:  profile.weight.isEmpty ? "—" : "\(profile.weight) kg",
                    target:   profile.targetWeight == 0 ? "—" : "→ \(profile.targetWeightString)",
                    progress: profile.weightProgress,
                    color:    .blue
                )
                BodyGoalCard(
                    icon: "percent",
                    title: "Body Fat",
                    current:  profile.bodyFat == 0 ? "—" : "\(Int(profile.bodyFat))%",
                    target:   "→ \(profile.targetBodyFatString)",
                    progress: profile.bodyFatProgress,
                    color:    .orange
                )
                BodyGoalCard(
                    icon: "figure.stand",
                    title: "BMI",
                    current:  profile.bmi,
                    target:   "→ \(profile.targetBMIString)",
                    progress: profile.bmiProgress,
                    color:    .purple
                )
            }

            // Auto-calculated target explanation
            if !profile.height.isEmpty && !profile.weight.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppTheme.primary)
                        .font(.caption)
                    Text("Targets: BMI 22.0 · Body Fat \(profile.targetBodyFatString) · Weight \(profile.targetWeightString)")
                        .font(.caption2)
                        .foregroundColor(AppTheme.secondaryText)
                        .lineSpacing(3)
                }
                .padding(10)
                .background(AppTheme.primary.opacity(0.08))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

// MARK: - Update Goals Sheet (modal)

struct UpdateGoalsSheet: View {
    let profileStore: UserProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var weightInput: String = ""
    @State private var bodyFatInput: Double = 20.0

    private var profile: UserProfile { profileStore.profile }

    // Live BMI preview from the edited weight
    private var previewBMI: String {
        guard let h = Double(profile.height), h > 0,
              let w = Double(weightInput) else { return "—" }
        let bmi = w / ((h / 100) * (h / 100))
        return String(format: "%.1f", bmi)
    }

    private var bmiCategory: String {
        guard let val = Double(previewBMI) else { return "" }
        switch val {
        case ..<18.5: return "Underweight"
        case ..<25.0: return "Normal ✓"
        case ..<30.0: return "Overweight"
        default:      return "Obese"
        }
    }

    private var bmiColor: Color {
        guard let val = Double(previewBMI) else { return .white }
        switch val {
        case 18.5..<25.0: return .green
        case 25.0..<30.0: return .orange
        default:           return .red
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // ── Description ───────────────────────────────────
                        Text("Update your current body stats. BMI is calculated automatically from your weight and saved height.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        // ── Weight Input ──────────────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Current Weight", systemImage: "scalemass")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)

                            HStack {
                                TextField("e.g. 80", text: $weightInput)
                                    .keyboardType(.decimalPad)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(AppTheme.background)
                                    .cornerRadius(12)

                                Text("kg")
                                    .foregroundColor(AppTheme.secondaryText)
                                    .font(.title3)
                            }
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // ── Body Fat Slider ───────────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Current Body Fat", systemImage: "percent")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)

                            HStack {
                                Text(String(format: "%.0f%%", bodyFatInput))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 56, alignment: .leading)

                                Slider(value: $bodyFatInput, in: 5...45, step: 1)
                                    .accentColor(BodyFatCategory.category(for: bodyFatInput).color)
                            }

                            // Category badge
                            Text(BodyFatCategory.category(for: bodyFatInput).label)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(BodyFatCategory.category(for: bodyFatInput).color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(BodyFatCategory.category(for: bodyFatInput).color.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // ── Live BMI Preview ──────────────────────────────
                        if !weightInput.isEmpty {
                            HStack(spacing: 16) {
                                VStack(spacing: 4) {
                                    Text("BMI Preview")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.secondaryText)
                                    Text(previewBMI)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text(bmiCategory)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(bmiColor)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(14)

                                VStack(spacing: 4) {
                                    Text("Target BMI")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.secondaryText)
                                    Text("22.0")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Healthy ✓")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(14)
                            }
                            .padding(.horizontal)
                        }

                        Spacer().frame(height: 20)
                    }
                }
            }
            .navigationTitle("Update Body Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveUpdates()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.primary)
                    .disabled(weightInput.isEmpty)
                }
            }
        }
        .onAppear {
            // Pre-fill with current values
            weightInput = profile.weight
            bodyFatInput = profile.bodyFat
        }
    }

    private func saveUpdates() {
        profileStore.update { p in
            if !weightInput.isEmpty {
                p.weight = weightInput
            }
            p.bodyFat = bodyFatInput
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
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .padding(6)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: progress)

                Text(progress == 0 ? "0%" : "\(Int(progress * 100))%")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 36, height: 36)

            Text(title)
                .font(.caption2)
                .foregroundColor(AppTheme.secondaryText)

            Text(current)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(target)
                .font(.system(size: 9))
                .foregroundColor(color.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.background)
        .cornerRadius(14)
    }
}

// MARK: - Legacy GoalMetricCard
struct GoalMetricCard: View {
    let title: String
    let current: String
    let target: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundColor(AppTheme.secondaryText)
            Text(current).fontWeight(.bold).foregroundColor(.white)
            Text(target).font(.caption2).foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserProfileStore())
    }
}
