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

    @State private var isLoadingTarget = false
    @State private var errorMessage: String? = nil
    
    // We will store the AI result in AppStorage as JSON data to read entirely from HomeView.
    @AppStorage("savedWorkoutPlanData") private var savedWorkoutPlanData: Data = Data()
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack {
                // Header Progress
                if currentStep > 0 && !isLoadingTarget {
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
                
                if isLoadingTarget {
                    VStack(spacing: 24) {
                        ProgressView()
                            .scaleEffect(2)
                            .tint(AppTheme.primary)
                        
                        Text("Designing Your Program...")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Our AI is creating a hyper-personalized workout and nutrition plan based on your profile.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppTheme.secondaryText)
                            .padding(.horizontal, 32)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.top)
                        }
                    }
                } else {
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
                                    equipment: equipment,
                                    startingWeight: weight,      // baseline — never changes
                                    startingBodyFat: bodyFat     // baseline — never changes
                                ))
                                Task {
                                    await generateWorkoutPlan()
                                }
                            }
                        )
                    default:
                        EmptyView()
                    }
                }

                Spacer()
            }
            .padding(.top)
        }
    }
    
    // MARK: - AI Generation
    private func generateWorkoutPlan() async {
        isLoadingTarget = true
        errorMessage = nil
        
        do {
            let plan: AIWorkoutResponse
            
            if AIWorkoutGeneratorService.shared.apiKey == nil || AIWorkoutGeneratorService.shared.apiKey!.isEmpty {
                plan = try await AIWorkoutGeneratorService.shared.mockWorkoutPlan()
            } else {
                plan = try await AIWorkoutGeneratorService.shared.generateWorkoutPlan(
                    age: Int(age) ?? 25,
                    gender: gender,
                    heightCm: Int(height) ?? 175,
                    weightKg: Int(weight) ?? 75,
                    bodyFat: bodyFat,
                    activityLevel: activityLevel,
                    goal: goal,
                    experience: fitnessLevel,
                    workoutDays: Int(sessionsPerWeek)
                )
            }
            
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(plan) {
                savedWorkoutPlanData = encodedData
            }
            
            await MainActor.run {
                hasCompletedOnboarding = true
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to generate plan. Please try again."
                isLoadingTarget = false
                print("Generation Error: \(error)")
            }
        }
    }
}
