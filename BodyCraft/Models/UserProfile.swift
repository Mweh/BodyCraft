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
    var bodyFat: Double = 20.0    // %
    var sessionsPerWeek: Int = 3
    var durationPerSession: String = ""
    var equipment: String = ""

    // ── Computed: current values ───────────────────────────────────────────
    var bmiValue: Double {
        guard let h = Double(height), let w = Double(weight), h > 0 else { return 0 }
        return w / ((h / 100) * (h / 100))
    }

    var bmi: String {
        bmiValue == 0 ? "—" : String(format: "%.1f", bmiValue)
    }

    var initials: String {
        let words = name.split(separator: " ")
        let letters = words.prefix(2).compactMap { $0.first.map { String($0) } }
        return letters.isEmpty ? "?" : letters.joined()
    }

    // ── Computed: targets ──────────────────────────────────────────────────
    /// Target body fat %: 10% for men, 18% for women (fitness category floor)
    var targetBodyFat: Double {
        gender.lowercased() == "female" ? 18.0 : 10.0
    }

    /// Target BMI: 22.0 (centre of the healthy 18.5–24.9 range)
    var targetBMI: Double { 22.0 }

    /// Target weight derived from target BMI and current height
    var targetWeight: Double {
        guard let h = Double(height), h > 0 else { return 0 }
        let hm = h / 100
        return targetBMI * hm * hm
    }

    var targetWeightString: String {
        targetWeight == 0 ? "—" : String(format: "%.1f kg", targetWeight)
    }

    var targetBodyFatString: String { String(format: "%.0f%%", targetBodyFat) }
    var targetBMIString: String     { String(format: "%.1f", targetBMI) }

    // ── Computed: progress (0.0 – 1.0) ────────────────────────────────────
    /// How far body fat has moved from start toward target (clamped 0–1)
    var bodyFatProgress: Double {
        // We store the onboarding value as starting point.
        // Progress = how much of the gap we've closed. At start → 0.0.
        // Since we don't track history yet, this stays 0 until the user
        // logs updates. For now, return 0 so we start fresh.
        return 0.0
    }

    var weightProgress: Double { 0.0 }
    var bmiProgress:    Double { 0.0 }

    /// Overall average progress across the three goals
    var overallGoalProgress: Double {
        (bodyFatProgress + weightProgress + bmiProgress) / 3.0
    }
}

