import Foundation

struct UserProfile: Codable {
    var name: String = ""
    var age: String = ""
    var gender: String = ""
    var height: String = ""       // cm
    var weight: String = ""       // kg
    var goal: String = ""
    var activityLevel: String = ""
    var fitnessLevel: String = ""
    var sessionsPerWeek: Int = 3
    var durationPerSession: String = ""
    var equipment: String = ""

    // Computed: BMI
    var bmi: String {
        guard let h = Double(height), let w = Double(weight), h > 0 else { return "—" }
        let bmiValue = w / ((h / 100) * (h / 100))
        return String(format: "%.1f", bmiValue)
    }

    // Computed: initials for avatar
    var initials: String {
        let words = name.split(separator: " ")
        let letters = words.prefix(2).compactMap { $0.first.map { String($0) } }
        return letters.isEmpty ? "?" : letters.joined()
    }
}
