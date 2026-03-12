import Foundation
import Combine

/// A repository that manages the user's AI-generated workout plan.
/// It loads the plan from AppStorage/UserDefaults and provides access to it.
final class WorkoutRepository: ObservableObject {
    static let shared = WorkoutRepository()
    
    @Published var currentPlan: AIWorkoutResponse?
    
    private let storageKey = "savedWorkoutPlanData"
    
    init() {
        loadPlan()
    }
    
    func loadPlan() {
        guard let data = UserDefaults.standard.data(forKey: storageKey), !data.isEmpty else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            currentPlan = try decoder.decode(AIWorkoutResponse.self, from: data)
        } catch {
            print("Failed to decode AIWorkoutResponse: \(error)")
        }
    }
    
    func savePlan(_ plan: AIWorkoutResponse) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(plan)
            UserDefaults.standard.set(data, forKey: storageKey)
            currentPlan = plan
        } catch {
            print("Failed to encode AIWorkoutResponse: \(error)")
        }
    }
    
    func regeneratePlan(for profile: UserProfile) async throws {
        let plan: AIWorkoutResponse
        
        let generator = AIWorkoutGeneratorService.shared
        
        if generator.apiKey == nil || generator.apiKey!.isEmpty {
            plan = try await generator.mockWorkoutPlan()
        } else {
            plan = try await generator.generateWorkoutPlan(
                age: Int(profile.age) ?? 25,
                gender: profile.gender,
                heightCm: Int(profile.height) ?? 175,
                weightKg: Int(profile.weight) ?? 75,
                activityLevel: profile.activityLevel,
                goal: profile.goal,
                experience: profile.fitnessLevel,
                workoutDays: profile.sessionsPerWeek,
                equipment: profile.equipment
            )
        }
        
        await MainActor.run {
            savePlan(plan)
            // Push to watch after successful save
            PhoneWatchBridge.shared.pushTodaysWorkoutToWatch()
        }
    }
    
    /// Returns the DayWorkout model mapped from the AI plan for a specific day number (1...7)
    func workout(for dayNumber: Int) -> DayWorkout? {
        guard let plan = currentPlan else { return nil }
        
        let targetDayString = "Day \(dayNumber)"
        
        // Find the matching AI day
        guard let aiDay = plan.weeklyWorkoutPlan.first(where: {
            $0.day.lowercased() == targetDayString.lowercased() ||
            $0.day.lowercased().starts(with: "day \(dayNumber)")
        }) else {
            // Fallback: If AI didn't use "Day X" format exactly, try indexing directly if possible
            if dayNumber >= 1 && dayNumber <= plan.weeklyWorkoutPlan.count {
                let fallbackAiDay = plan.weeklyWorkoutPlan[dayNumber - 1]
                return mapToDayWorkout(day: dayNumber, aiDay: fallbackAiDay)
            }
            return nil
        }
        
        return mapToDayWorkout(day: dayNumber, aiDay: aiDay)
    }
    
    private func mapToDayWorkout(day: Int, aiDay: WorkoutDay) -> DayWorkout {
        let exercises = aiDay.exercises.map { aiEx -> Exercise in
            // Generate deterministic UUID based on day and exercise name to preserve streaks
            let seedString = "day\(day)_\(aiEx.name)"
            let uuid = uuidFromSeedString(seedString)
            
            // Parse reps from string safely (e.g. "8-12" or "10")
            // Apply maximum safety caps: Set <= 6, Reps <= 20
            let repsInt = min(20, parseInt(from: aiEx.reps))
            let safeSets = min(6, aiEx.sets)
            
            return Exercise(id: uuid, name: aiEx.name, sets: safeSets, reps: repsInt)
        }
        
        return DayWorkout(id: day, title: aiDay.focus, exercises: exercises)
    }
    
    private func parseInt(from string: String) -> Int {
        // Find the first integer safely instead of squishing all digits.
        // e.g. "8-12" -> "8"
        // e.g. "3 sets of 10" -> "3"
        
        let components = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let firstValidNumberString = components.first(where: { !$0.isEmpty }) ?? "0"
        return Int(firstValidNumberString) ?? 0
    }
    
    private func uuidFromSeedString(_ string: String) -> UUID {
        // Simple hash to create a stable UUID string representation
        let hash = abs(string.hashValue)
        let hashString = String(format: "%032llx", UInt64(hash))
        
        let uuidString = "\(hashString.prefix(8))-\(hashString.dropFirst(8).prefix(4))-\(hashString.dropFirst(12).prefix(4))-\(hashString.dropFirst(16).prefix(4))-\(hashString.dropFirst(20).prefix(12))"
        return UUID(uuidString: uuidString) ?? UUID()
    }
}
