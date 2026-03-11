import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileStore: UserProfileStore
    @State private var currentPhase = "Cutting"
    let phases = ["Cutting", "Bulking", "Maintain"]

    private var profile: UserProfile { profileStore.profile }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // ── User Header ───────────────────────────────────
                        HStack(spacing: 16) {
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(AppTheme.primary)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text(profile.initials.isEmpty ? "?" : profile.initials)
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .bold()
                                    )

                                Circle()
                                    .fill(AppTheme.surface)
                                    .frame(width: 24, height: 24)
                                    .overlay(Image(systemName: "pencil").font(.caption2).foregroundColor(.white))
                                    .offset(x: 4, y: 4)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.name.isEmpty ? "Your Name" : profile.name)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)

                                Text(profile.goal.isEmpty ? "Aesthetic Body Journey" : profile.goal)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.secondaryText)

                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    Text("Level 1 · \(profile.fitnessLevel.isEmpty ? "Beginner" : profile.fitnessLevel)")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                        .bold()
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)

                        // ── Lifetime Stats ────────────────────────────────
                        HStack(spacing: 12) {
                            StatBox(icon: "calendar", value: "0", label: "Days", iconColor: AppTheme.primary)
                            StatBox(icon: "figure.run", value: "0", label: "Workouts", iconColor: .cyan)
                            StatBox(icon: "flame", value: "0", label: "Calories", iconColor: .orange)
                            StatBox(icon: "chart.line.uptrend.xyaxis", value: "0", label: "PRs", iconColor: .green)
                        }
                        .padding(.horizontal)

                        // ── Current Goal Phase ────────────────────────────
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Current Goal")
                                .font(.headline)
                                .foregroundColor(.white)

                            HStack(spacing: 0) {
                                ForEach(phases, id: \.self) { phase in
                                    Button(action: { currentPhase = phase }) {
                                        Text(phase)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity)
                                            .background(currentPhase == phase ? AppTheme.primary : AppTheme.surface)
                                            .foregroundColor(currentPhase == phase ? .white : AppTheme.secondaryText)
                                    }
                                }
                            }
                            .clipShape(Capsule())

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Phase: \(currentPhase)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(phaseDescription(for: currentPhase))
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.secondaryText)
                                    .lineSpacing(4)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)

                        // ── Body Stats ────────────────────────────────────
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Body Stats")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    StaticStatCard(
                                        title: "Height",
                                        value: profile.height.isEmpty ? "—" : "\(profile.height) cm"
                                    )
                                    StaticStatCard(
                                        title: "Weight",
                                        value: profile.weight.isEmpty ? "—" : "\(profile.weight) kg"
                                    )
                                }
                                HStack(spacing: 12) {
                                    StaticStatCard(title: "Age", value: profile.age.isEmpty ? "—" : "\(profile.age) yr")
                                    StaticStatCard(title: "BMI", value: profile.bmi)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // ── Workout Preferences ───────────────────────────
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Workout Preferences")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    StaticStatCard(
                                        title: "Sessions / Week",
                                        value: profile.sessionsPerWeek == 0 ? "—" : "\(profile.sessionsPerWeek)x"
                                    )
                                    StaticStatCard(
                                        title: "Duration",
                                        value: profile.durationPerSession.isEmpty ? "—" : profile.durationPerSession
                                    )
                                }
                                HStack(spacing: 12) {
                                    StaticStatCard(
                                        title: "Activity Level",
                                        value: profile.activityLevel.isEmpty ? "—" : profile.activityLevel
                                    )
                                    StaticStatCard(
                                        title: "Equipment",
                                        value: profile.equipment.isEmpty ? "—" : profile.equipment
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)

                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
    }

    func phaseDescription(for phase: String) -> String {
        switch phase {
        case "Cutting": return "Caloric deficit of 300-500 kcal to reduce body fat while preserving muscle mass.\nTarget: 12% body fat."
        case "Bulking": return "Caloric surplus of 300-500 kcal combined with progressive overload to build muscle mass."
        case "Maintain": return "Eating at maintenance calories to hold current muscle mass and body fat percentage."
        default: return ""
        }
    }
}

// MARK: - Subviews

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

struct StaticStatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserProfileStore())
    }
}
