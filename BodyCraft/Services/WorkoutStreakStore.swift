import Foundation
import Combine

// MARK: - WorkoutStreakStore

/// Persists which exercises have been completed per day (1–7).
/// A day is considered "complete" when every exercise in that day is ticked.
final class WorkoutStreakStore: ObservableObject {

    // completedExercises[dayNumber] = Set of completed exercise UUIDs
    @Published private(set) var completedExercises: [Int: Set<String>] = [:]
    
    // The date the user started the plan. Used to compute what Day 1-7 it is today.
    @Published private(set) var startDate: Date

    private let key = "workout_streak_completed"
    private let startDateKey = "workout_streak_start_date"

    init() {
        // Load completed exercises
        var loadedDict: [Int: Set<String>] = [:]
        if let data = UserDefaults.standard.data(forKey: "workout_streak_completed"),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            loadedDict = decoded.reduce(into: [:]) { result, pair in
                if let day = Int(pair.key) { result[day] = Set(pair.value) }
            }
        }
        self.completedExercises = loadedDict
        
        // Load start date; if none, set to now
        if let timeInterval = UserDefaults.standard.object(forKey: "workout_streak_start_date") as? TimeInterval {
            self.startDate = Date(timeIntervalSince1970: timeInterval)
        } else {
            let now = Date()
            self.startDate = now
            UserDefaults.standard.set(now.timeIntervalSince1970, forKey: "workout_streak_start_date")
        }
    }

    // MARK: - Public API

    /// The current program day (1...7), computed based on elapsed days since startDate.
    var currentDayNumber: Int {
        let calendar = Calendar.current
        let startOfDayStart = calendar.startOfDay(for: startDate)
        let startOfDayToday = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: startOfDayStart, to: startOfDayToday)
        let daysElapsed = max(0, components.day ?? 0)
        // Day 1 corresponds to daysElapsed = 0.
        // E.g. 0 elapsed -> Day 1, 1 -> Day 2 ... 6 -> Day 7. 
        // Note: 7 elapsed wraps back to Day 1 (if it's a looping 7-day program).
        return (daysElapsed % 7) + 1
    }

    func isExerciseCompleted(day: Int, exerciseId: UUID) -> Bool {
        completedExercises[day]?.contains(exerciseId.uuidString) ?? false
    }

    func isDayCompleted(day: Int) -> Bool {
        guard let workout = WorkoutPlanData.workout(for: day) else { return false }
        guard !workout.exercises.isEmpty else { return false }
        let checked = completedExercises[day] ?? []
        return workout.exercises.allSatisfy { checked.contains($0.id.uuidString) }
    }

    func toggle(day: Int, exercise: Exercise) {
        // Cannot check exercises for future days
        guard day <= currentDayNumber else { return }
        
        var set = completedExercises[day] ?? []
        if set.contains(exercise.id.uuidString) {
            set.remove(exercise.id.uuidString)
        } else {
            set.insert(exercise.id.uuidString)
        }
        // Force UI update
        self.completedExercises[day] = set
        save()
    }

    /// Number of consecutive days completed starting from Day 1.
    var streakCount: Int {
        var count = 0
        for day in 1...7 {
            if isDayCompleted(day: day) { count += 1 } else { break }
        }
        return count
    }

    // MARK: - Persistence

    private func save() {
        let encoded = completedExercises.mapKeys { String($0) }
            .mapValues { Array($0) }
        if let data = try? JSONEncoder().encode(encoded) {
            UserDefaults.standard.set(data, forKey: key)
        }
        UserDefaults.standard.set(startDate.timeIntervalSince1970, forKey: startDateKey)
    }
}

// MARK: - Dictionary helper

private extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        reduce(into: [:]) { result, pair in
            result[transform(pair.key)] = pair.value
        }
    }
}
