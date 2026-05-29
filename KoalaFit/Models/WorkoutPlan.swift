import Foundation

// MARK: - Exercise

struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let sets: Int
    let reps: Int

    /// Convenient initialiser — generates a new UUID automatically.
    init(name: String, sets: Int, reps: Int) {
        self.id   = UUID()
        self.name = name
        self.sets = sets
        self.reps = reps
    }

    /// Initialiser with explicit stable UUID (used in WorkoutPlanData for persistence).
    init(id: UUID, name: String, sets: Int, reps: Int) {
        self.id   = id
        self.name = name
        self.sets = sets
        self.reps = reps
    }

    /// Human‑readable detail string, e.g. "3 sets × 15 reps"
    var detail: String { "\(sets) sets × \(reps) reps" }
}

// MARK: - DayWorkout

struct DayWorkout: Identifiable {
    let id: Int           // 1 – 7
    let title: String     // e.g. "Upper Body Push"
    let exercises: [Exercise]

    var isRestDay: Bool { exercises.isEmpty }
}
