import Foundation
import Combine
import SwiftUI

final class DashboardViewModel: ObservableObject {
    static let shared = DashboardViewModel(
        profileStore: UserProfileStore.shared,
        streakStore: WorkoutStreakStore.shared,
        workoutRepo: WorkoutRepository.shared
    )

    @Published var totalWorkoutCalories: Int = 0
    @Published var burnedCalories: Int = 0
    
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
        let weight = Double(profile.weight) ?? 0.0
        
        // Calculate actual burn purely from today's exercises
        let burns = estimateBurns(for: today, weight: weight > 0 ? weight : 70.0)
        self.totalWorkoutCalories = burns.total
        self.burnedCalories = burns.completed
    }
    
    private func estimateBurns(for day: Int, weight: Double) -> (total: Int, completed: Int) {
        guard let todayWorkout = workout(for: day) else { return (0, 0) }
        
        var totalBurn = 0.0
        var completedBurn = 0.0
        
        for exercise in todayWorkout.exercises {
            let repsDuration = Double(exercise.reps * 4) // seconds
            let restDuration = 60.0 // seconds rest after a set
            
            let totalSecondsPerSet = repsDuration + restDuration
            let totalDurationMinutes = (Double(exercise.sets) * totalSecondsPerSet) / 60.0
            
            let durationHours = totalDurationMinutes / 60.0
            let metValue = 6.0
            let calories = metValue * weight * durationHours
            
            totalBurn += calories
            
            if streakStore.isExerciseCompleted(day: day, exerciseId: exercise.id) {
                completedBurn += calories
            }
        }
        
        return (Int(totalBurn), Int(completedBurn))
    }
}
