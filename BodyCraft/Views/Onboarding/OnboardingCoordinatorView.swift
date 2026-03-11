import SwiftUI

struct OnboardingCoordinatorView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var profileStore: UserProfileStore
    @State private var currentStep = 0

    // Shared State for onboarding data
    @State private var name = ""
    @State private var goal = "Build Muscle"
    @State private var activityLevel = "Sedentary"
    @State private var fitnessLevel = "Beginner"
    @State private var age = "22"
    @State private var gender = "Male"
    @State private var height = "180"
    @State private var weight = "85"
    @State private var bodyFat: Double = 20.0
    @State private var sessionsPerWeek = 4.0
    @State private var durationPerSession = "45 min"
    @State private var equipment = "No Equipment"

    private let totalSteps = 10

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack {
                // Header Progress
                if currentStep > 0 {
                    HStack {
                        Button(action: { currentStep -= 1 }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Text("\(currentStep) of \(totalSteps - 1)")
                            .foregroundColor(AppTheme.secondaryText)
                            .font(.footnote)

                        Spacer()

                        Button("Skip") {
                            hasCompletedOnboarding = true
                        }
                        .foregroundColor(AppTheme.secondaryText)
                        .font(.footnote)
                    }
                    .padding(.horizontal)

                    ProgressView(value: Double(currentStep), total: Double(totalSteps - 1))
                        .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.primary))
                        .padding(.horizontal)
                        .padding(.top, 8)
                }

                // Steps Content
                Spacer()

                switch currentStep {
                case 0:
                    WelcomeStepView(nextAction: { currentStep += 1 })
                case 1:
                    GoalStepView(selectedGoal: $goal, nextAction: { currentStep += 1 })
                case 2:
                    ActivityStepView(selectedActivity: $activityLevel, nextAction: { currentStep += 1 })
                case 3:
                    FitnessLevelStepView(selectedFitness: $fitnessLevel, nextAction: { currentStep += 1 })
                case 4:
                    AboutYouStepView(age: $age, gender: $gender, nextAction: { currentStep += 1 })
                case 5:
                    BodyMeasurementsStepView(height: $height, weight: $weight, nextAction: { currentStep += 1 })
                case 6:
                    // NEW: Body Fat step
                    BodyFatStepView(bodyFat: $bodyFat, nextAction: { currentStep += 1 })
                case 7:
                    WorkoutPreferencesStepView(sessions: $sessionsPerWeek, duration: $durationPerSession, nextAction: { currentStep += 1 })
                case 8:
                    EquipmentStepView(selectedEquipment: $equipment, nextAction: { currentStep += 1 })
                case 9:
                    SummaryStepView(
                        goal: goal, activity: activityLevel, fitness: fitnessLevel,
                        age: age, gender: gender, height: height, weight: weight,
                        bodyFat: bodyFat,
                        frequency: Int(sessionsPerWeek), duration: durationPerSession,
                        equipment: equipment,
                        finishAction: {
                            profileStore.save(UserProfile(
                                name: name.isEmpty ? gender : name,
                                age: age,
                                gender: gender,
                                height: height,
                                weight: weight,
                                goal: goal,
                                activityLevel: activityLevel,
                                fitnessLevel: fitnessLevel,
                                bodyFat: bodyFat,
                                sessionsPerWeek: Int(sessionsPerWeek),
                                durationPerSession: durationPerSession,
                                equipment: equipment
                            ))
                            hasCompletedOnboarding = true
                        }
                    )
                default:
                    EmptyView()
                }

                Spacer()
            }
            .padding(.top)
        }
    }
}
