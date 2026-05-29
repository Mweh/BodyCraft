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
    
    /// When the Watch sends real HealthKit calorie data, this override takes
    /// priority over the locally-estimated burnedCalories. It is persisted so
    /// it survives app restarts and is cleared at the start of a new workout day.
    @Published private(set) var watchBurnOverride: Int? = nil
    private let watchBurnKey = "watchBurnOverride"
    private let watchBurnDayKey = "watchBurnOverrideDay"
    
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
        restoreWatchBurnOverride()
    }
    
    // MARK: - Watch Calorie Override
    
    /// Called by PhoneWatchBridge when real HealthKit calorie data arrives from Watch.
    /// Sets a persistent override so calculateTargets() doesn't revert the value.
    func applyWatchBurn(_ calories: Double) {
        let kcal = Int(calories)
        let today = streakStore.currentDayNumber
        watchBurnOverride = kcal
        burnedCalories = kcal
        UserDefaults.standard.set(kcal, forKey: watchBurnKey)
        UserDefaults.standard.set(today, forKey: watchBurnDayKey)
        print("[Dashboard] Watch burn override applied: \(kcal) kcal")
    }
    
    /// Clear the override (e.g. when a new day starts).
    func clearWatchBurnOverride() {
        watchBurnOverride = nil
        UserDefaults.standard.removeObject(forKey: watchBurnKey)
        UserDefaults.standard.removeObject(forKey: watchBurnDayKey)
    }
    
    private func restoreWatchBurnOverride() {
        let today = streakStore.currentDayNumber
        let savedDay = UserDefaults.standard.integer(forKey: watchBurnDayKey)
        // Only restore if the override is from today
        if savedDay == today, let saved = UserDefaults.standard.object(forKey: watchBurnKey) as? Int {
            watchBurnOverride = saved
        } else if savedDay != today {
            // Stale override from a previous day — clear it
            clearWatchBurnOverride()
        }
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
        
        let burns = estimateBurns(for: today, weight: weight > 0 ? weight : 70.0)
        self.totalWorkoutCalories = burns.total
        
        // Bug #2 Fix: Only update burnedCalories from local estimate if the Watch
        // hasn't provided real HealthKit data. The override takes priority.
        if let override = watchBurnOverride {
            // Keep the real Watch value; only recalculate if Watch gave us more
            self.burnedCalories = max(override, burns.completed)
        } else {
            self.burnedCalories = burns.completed
        }
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
