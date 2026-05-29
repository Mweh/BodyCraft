import Foundation

// MARK: - WorkoutPlanData
// UUIDs are hardcoded so persistence (UserDefaults) survives app restarts.

enum WorkoutPlanData {

    static let weeklyPlan: [DayWorkout] = [

        // ── Day 1 : Upper Body Push ──────────────────────────────────────
        DayWorkout(id: 1, title: "Upper Body Push", exercises: [
            Exercise(id: UUID(uuidString: "11000001-0000-0000-0000-000000000001")!, name: "Push Up",        sets: 3, reps: 15),
            Exercise(id: UUID(uuidString: "11000001-0000-0000-0000-000000000002")!, name: "Pull Up",        sets: 3, reps: 8),
            Exercise(id: UUID(uuidString: "11000001-0000-0000-0000-000000000003")!, name: "Sit Up",         sets: 3, reps: 20)
        ]),

        // ── Day 2 : Lower Body ───────────────────────────────────────────
        DayWorkout(id: 2, title: "Lower Body", exercises: [
            Exercise(id: UUID(uuidString: "22000002-0000-0000-0000-000000000001")!, name: "Squat",          sets: 4, reps: 12),
            Exercise(id: UUID(uuidString: "22000002-0000-0000-0000-000000000002")!, name: "Lunges",         sets: 3, reps: 10),
            Exercise(id: UUID(uuidString: "22000002-0000-0000-0000-000000000003")!, name: "Calf Raise",     sets: 3, reps: 20)
        ]),

        // ── Day 3 : Active Rest ──────────────────────────────────────────
        DayWorkout(id: 3, title: "Active Rest", exercises: [
            Exercise(id: UUID(uuidString: "33000003-0000-0000-0000-000000000001")!, name: "Full Body Stretch", sets: 1, reps: 10)
        ]),

        // ── Day 4 : Shoulders & Arms ─────────────────────────────────────
        DayWorkout(id: 4, title: "Shoulders & Arms", exercises: [
            Exercise(id: UUID(uuidString: "44000004-0000-0000-0000-000000000001")!, name: "Dumbbell Shoulder Press", sets: 3, reps: 12),
            Exercise(id: UUID(uuidString: "44000004-0000-0000-0000-000000000002")!, name: "Lateral Raise",           sets: 3, reps: 15),
            Exercise(id: UUID(uuidString: "44000004-0000-0000-0000-000000000003")!, name: "Tricep Dip",              sets: 3, reps: 12)
        ]),

        // ── Day 5 : Posterior Chain ──────────────────────────────────────
        DayWorkout(id: 5, title: "Posterior Chain", exercises: [
            Exercise(id: UUID(uuidString: "55000005-0000-0000-0000-000000000001")!, name: "Deadlift",              sets: 3, reps: 8),
            Exercise(id: UUID(uuidString: "55000005-0000-0000-0000-000000000002")!, name: "Romanian Deadlift",     sets: 3, reps: 10),
            Exercise(id: UUID(uuidString: "55000005-0000-0000-0000-000000000003")!, name: "Hip Thrust",            sets: 3, reps: 12)
        ]),

        // ── Day 6 : HIIT Cardio ──────────────────────────────────────────
        DayWorkout(id: 6, title: "HIIT Cardio", exercises: [
            Exercise(id: UUID(uuidString: "66000006-0000-0000-0000-000000000001")!, name: "Burpee",               sets: 3, reps: 15),
            Exercise(id: UUID(uuidString: "66000006-0000-0000-0000-000000000002")!, name: "Mountain Climber",     sets: 3, reps: 20),
            Exercise(id: UUID(uuidString: "66000006-0000-0000-0000-000000000003")!, name: "Jump Rope (sec)",      sets: 3, reps: 60)
        ]),

        // ── Day 7 : Full Rest / Yoga ─────────────────────────────────────
        DayWorkout(id: 7, title: "Full Rest / Yoga", exercises: [
            Exercise(id: UUID(uuidString: "77000007-0000-0000-0000-000000000001")!, name: "Yoga Flow",            sets: 1, reps: 15)
        ])
    ]


    /// Returns the DayWorkout for a given day number (1…7).
    static func workout(for day: Int) -> DayWorkout? {
        weeklyPlan.first { $0.id == day }
    }
}



