import Foundation
import Combine
import SwiftUI

final class DashboardViewModel: ObservableObject {
    static let shared = DashboardViewModel(
        profileStore: UserProfileStore.shared,
        streakStore: WorkoutStreakStore.shared,
        workoutRepo: WorkoutRepository.shared
    )

    @Published var dailyCalorieTarget: Int = 0
    @Published var workoutBurn: Int = 0
    @Published var netTarget: Int = 0
    
    // Dependencies
    private var profileStore: UserProfileStore
    private var streakStore: WorkoutStreakStore
    private var workoutRepo: WorkoutRepository
    
    private var cancellables = Set<AnyCancellable>()
    
    init(profileStore: UserProfileStore, streakStore: WorkoutStreakStore, workoutRepo: WorkoutRepository) {
        self.profileStore = profileStore
        self.streakStore = streakStore
        self.workoutRepo = workoutRepo
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Recalculate anytime dependencies change
        Publishers.CombineLatest3(
            profileStore.$profile,
            streakStore.$completedExercises,
            workoutRepo.$currentPlan
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in
            self?.calculateTargets()
        }
        .store(in: &cancellables)
        
        // Initial calculation
        calculateTargets()
    }
    
    // MARK: - Core Logic
    
    func workout(for day: Int) -> DayWorkout? {
        workoutRepo.workout(for: day)
    }
    
    func calculateTargets() {
        let profile = profileStore.profile
        let today = streakStore.currentDayNumber
        
        // 1. Calculate BMR
        // Mifflin-St Jeor Equation
        let weight = Double(profile.weight) ?? 0
        let height = Double(profile.height) ?? 0
        let age = Double(profile.age) ?? 25
        let isMale = profile.gender.lowercased() == "male"
        
        // Needs weight and height to be meaningful
        guard weight > 0, height > 0 else {
            // Fallback to AI's simple target if profile is missing metrics
            self.dailyCalorieTarget = workoutRepo.currentPlan?.dailyCalories ?? 600
            self.workoutBurn = estimateBurn(for: today, weight: 70) // Fallback default weight
            self.netTarget = self.dailyCalorieTarget - self.workoutBurn
            return
        }
        
        var bmr = (10.0 * weight) + (6.25 * height) - (5.0 * age)
        bmr += isMale ? 5.0 : -161.0
        
        // 2. Activity Multiplier
        let activityLevels: [String: Double] = [
            "sedentary": 1.2,
            "lightly active": 1.375,
            "moderately active": 1.55,
            "very active": 1.725,
            "extra active": 1.9
        ]
        let multiplier = activityLevels[profile.activityLevel.lowercased()] ?? 1.55
        let tdee = bmr * multiplier
        
        // 3. Goal Adjustment
        var targetCals = tdee
        let goal = profile.goal.lowercased()
        if goal.contains("lose") {
            targetCals -= 500
        } else if goal.contains("muscle") || goal.contains("gain") {
            targetCals += 300
        }
        
        // 4. Calculate actual burn from today's completed exercises
        self.workoutBurn = estimateBurn(for: today, weight: weight)
        
        // 5. Final assignments
        self.dailyCalorieTarget = Int(round(targetCals))
        self.netTarget = self.dailyCalorieTarget - self.workoutBurn
    }
    
    private func estimateBurn(for day: Int, weight: Double) -> Int {
        guard let todayWorkout = workout(for: day) else { return 0 }
        
        var totalBurn = 0.0
        for exercise in todayWorkout.exercises {
            // Only count if completed
            if streakStore.isExerciseCompleted(day: day, exerciseId: exercise.id) {
                // Approximate: 1 MET = 1 kcal / kg / hour
                // Let's assume average strength training is 6.0 METs
                // Let's assume 1 set = ~1 minute (including rest)
                let durationMinutes = Double(exercise.sets)
                let durationHours = durationMinutes / 60.0
                let metValue = 6.0
                
                let calories = metValue * weight * durationHours
                totalBurn += calories
            }
        }
        return Int(totalBurn)
    }
}
