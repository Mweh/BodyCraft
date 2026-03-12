import Foundation

// MARK: - Watch Sync Models (iPhone side mirror)
// These mirror the structs in the Watch target. They must stay in sync.

struct WatchWorkoutPayload: Codable {
    let dayNumber: Int
    let title: String
    let totalExpectedCalories: Int
    let exercises: [WatchExercise]
}

struct WatchExercise: Codable, Identifiable {
    let id: UUID
    let name: String
    let sets: Int
    let reps: String
    let category: String
}

struct WatchSummaryPayload: Codable {
    let caloriesBurned: Double
    let durationSeconds: TimeInterval
    let completedExerciseIds: [String]
}

// MARK: - Notification Names

extension Notification.Name {
    static let watchCheckboxSync = Notification.Name("WatchSyncCheckboxUpdated")
}
