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
                        BodyGoalsSection(profile: profile)
                            .padding(.horizontal)

                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Body Goals Section

struct BodyGoalsSection: View {
    let profile: UserProfile

    private var overallProgress: Double { profile.overallGoalProgress }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            HStack {
                Image(systemName: "target").foregroundColor(.green)
                Text("Body Goals")
                    .fontWeight(.semibold).foregroundColor(.white)
                Spacer()
                Text(overallProgress == 0 ? "Just started 🚀" : "\(Int(overallProgress * 100))%")
                    .foregroundColor(overallProgress == 0 ? AppTheme.secondaryText : .green)
                    .fontWeight(.bold)
                    .font(.subheadline)
            }

            // Overall progress bar (starts at 0)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.background).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(colors: [.green, .cyan],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        // minimum 4pt so bar is always visible even at 0%
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

            // Auto-calculated target explanation strip
            if !profile.height.isEmpty && !profile.weight.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppTheme.primary)
                        .font(.caption)
                    Text("Targets auto-calculated: BMI 22.0 · Body Fat \(profile.targetBodyFatString) · Weight \(profile.targetWeightString)")
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

// MARK: - BodyGoalCard

struct BodyGoalCard: View {
    let icon: String
    let title: String
    let current: String
    let target: String
    let progress: Double   // 0.0–1.0
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .padding(6)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            // Ring progress indicator
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
