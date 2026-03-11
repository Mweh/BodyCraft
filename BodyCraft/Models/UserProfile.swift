import Foundation

struct UserProfile: Codable {
    var name: String = ""
    var age: String = ""
    var gender: String = ""
    var height: String = ""

    /// Current weight (updated by the Edit modal in Home)
    var weight: String = ""       // kg (current — updated by Edit modal)

    var goal: String = ""
    var activityLevel: String = ""
    var fitnessLevel: String = ""
    var bodyFat: Double = 20.0    // % (current — updated by Edit modal)
    var sessionsPerWeek: Int = 3
    var durationPerSession: String = ""
    var equipment: String = ""

    // ── Baseline (set once at onboarding, never touched afterwards) ────────
    var startingWeight: String = ""
    var startingBodyFat: Double = 0.0

    // ── Computed: current readings ─────────────────────────────────────────
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
    var targetBodyFat: Double {
        gender.lowercased() == "female" ? 18.0 : 10.0
    }

    var targetBMI: Double { 22.0 }

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

    // ── Computed: real progress (0.0 – 1.0) ───────────────────────────────
    // Formula: how much of the gap (starting → target) has been closed.
    // Direction-aware: works for both loss and gain goals.

    var bodyFatProgress: Double {
        // If no separate baseline recorded yet, use current as start → 0%
        let start  = startingBodyFat > 0 ? startingBodyFat : bodyFat
        let target = targetBodyFat
        guard abs(start - target) > 0.01 else { return 1.0 }
        let p = (start - bodyFat) / (start - target)
        return min(max(p, 0.0), 1.0)
    }

    var weightProgress: Double {
        let startStr = startingWeight.isEmpty ? weight : startingWeight
        guard let startW   = Double(startStr),
              let currentW = Double(weight),
              targetWeight > 0,
              abs(startW - targetWeight) > 0.01
        else { return 0.0 }
        let p = (startW - currentW) / (startW - targetWeight)
        return min(max(p, 0.0), 1.0)
    }

    var bmiProgress: Double {
        let startStr = startingWeight.isEmpty ? weight : startingWeight
        guard let startW   = Double(startStr),
              let currentW = Double(weight),
              let h        = Double(height), h > 0,
              abs(startW - targetWeight) > 0.01
        else { return 0.0 }
        let hm  = h / 100
        let startBMI   = startW   / (hm * hm)
        let currentBMI = currentW / (hm * hm)
        guard abs(startBMI - targetBMI) > 0.01 else { return 1.0 }
        let p = (startBMI - currentBMI) / (startBMI - targetBMI)
        return min(max(p, 0.0), 1.0)
    }

    var overallGoalProgress: Double {
        (bodyFatProgress + weightProgress + bmiProgress) / 3.0
    }
}
