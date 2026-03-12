import Foundation

struct AIWorkoutResponse: Codable {
    let dailyCalories: Int
    let goal: String
    let weeklyWorkoutPlan: [WorkoutDay]
    let safetyFlag: Bool
    let rationale: String
    
    enum CodingKeys: String, CodingKey {
        case dailyCalories = "daily_calories"
        case goal
        case weeklyWorkoutPlan = "weekly_workout_plan"
        case safetyFlag = "safety_flag"
        case rationale
    }
}

struct WorkoutDay: Codable, Identifiable {
    var id: UUID { UUID() }
    let day: String
    let focus: String
    let exercises: [Exercise]
    
    enum CodingKeys: String, CodingKey {
        case day, focus, exercises
    }
}

struct Exercise: Codable, Identifiable {
    var id: UUID { UUID() }
    let name: String
    let sets: Int
    let reps: String
    let restSeconds: Int
    
    enum CodingKeys: String, CodingKey {
        case name, sets, reps
        case restSeconds = "rest_seconds"
    }
}
