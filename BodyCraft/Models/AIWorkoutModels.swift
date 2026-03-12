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
    var id: UUID = UUID()
    let day: String
    let focus: String
    let exercises: [ExerciseAI]
    
    enum CodingKeys: String, CodingKey {
        case id, day, focus, exercises
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.day = try container.decode(String.self, forKey: .day)
        self.focus = try container.decode(String.self, forKey: .focus)
        self.exercises = try container.decode([ExerciseAI].self, forKey: .exercises)
        // If no ID in JSON, generate stable one from day and focus
        if let decodedId = try? container.decode(UUID.self, forKey: .id) {
            self.id = decodedId
        } else {
            let seed = "\(day)\(focus)"
            self.id = UUID(uuidString: seed.md5DataID) ?? UUID()
        }
    }
}

struct ExerciseAI: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let sets: Int
    let reps: String
    let restSeconds: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, sets, reps
        case restSeconds = "rest_seconds"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.sets = try container.decode(Int.self, forKey: .sets)
        self.reps = try container.decode(String.self, forKey: .reps)
        self.restSeconds = try container.decode(Int.self, forKey: .restSeconds)
        // If no ID in JSON, generate stable one from name, sets, reps
        if let decodedId = try? container.decode(UUID.self, forKey: .id) {
            self.id = decodedId
        } else {
            let seed = "\(name)\(sets)\(reps)"
            self.id = UUID(uuidString: seed.md5DataID) ?? UUID()
        }
    }
}

// MARK: - Stable ID helper
private extension String {
    var md5DataID: String {
        let data = Data(self.utf8)
        let hash = data.reduce(0) { ($0 << 5) &- $0 &+ Int($1) }
        let hex = String(format: "%08x%08x%08x%08x", hash, hash, hash, hash)
        var result = hex
        result.insert("-", at: result.index(result.startIndex, offsetBy: 8))
        result.insert("-", at: result.index(result.startIndex, offsetBy: 13))
        result.insert("-", at: result.index(result.startIndex, offsetBy: 18))
        result.insert("-", at: result.index(result.startIndex, offsetBy: 23))
        return result
    }
}
