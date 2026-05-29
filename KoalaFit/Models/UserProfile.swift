import Foundation

// MARK: - Daily Nutrition Goals

struct DailyNutritionGoals {
    let calories: Double
    let protein:  Double   // grams
    let carbs:    Double   // grams
    let fat:      Double   // grams
}

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
    var photoData: Data? = nil

    // ── Baseline (set once at onboarding, never touched afterwards) ────────
    var startingWeight: String = ""
    var startingBodyFat: Double = 0.0

    // ── Goal preset ────────────────────────────────────────────────────────
    /// "Current" | "Cutting" | "Bulking" | "Manual"
    var goalPreset: String = "Current"
    /// Only used when goalPreset == "Manual"
    var customTargetWeight: String = ""
    var customTargetBodyFat: Double = 0.0

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

    // ── Computed: targets (depend on chosen preset) ───────────────────────
    var targetBodyFat: Double {
        switch goalPreset {
        case "Cutting":  return gender.lowercased() == "female" ? 15.0 : 8.0
        case "Bulking":  return gender.lowercased() == "female" ? 22.0 : 15.0
        case "Manual":   return customTargetBodyFat > 0 ? customTargetBodyFat : (gender.lowercased() == "female" ? 18.0 : 10.0)
        default:         return gender.lowercased() == "female" ? 18.0 : 10.0   // "Current"
        }
    }

    var targetBMI: Double {
        switch goalPreset {
        case "Cutting": return 20.5
        case "Bulking": return 24.0
        default:        return 22.0
        }
    }

    var targetWeight: Double {
        if goalPreset == "Manual", let w = Double(customTargetWeight), w > 0 { return w }
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

    // ── Computed: daily nutrition targets ─────────────────────────────────
    // Uses Mifflin-St Jeor BMR → TDEE via activity multiplier → goal-adjusted calories
    // and distributes into protein/carbs/fat based on the user's goal.
    var dailyNutritionGoals: DailyNutritionGoals {
        guard let w = Double(weight), let h = Double(height), let a = Double(age), w > 0, h > 0, a > 0
        else { return DailyNutritionGoals(calories: 2000, protein: 150, carbs: 220, fat: 65) }

        let isFemale = gender.lowercased() == "female"

        // Mifflin-St Jeor BMR
        let bmr: Double
        if isFemale {
            bmr = 10 * w + 6.25 * h - 5 * a - 161
        } else {
            bmr = 10 * w + 6.25 * h - 5 * a + 5
        }

        // Activity multiplier
        let activityMultiplier: Double
        switch activityLevel {
        case "Lightly Active":    activityMultiplier = 1.375
        case "Moderately Active": activityMultiplier = 1.55
        case "Very Active":       activityMultiplier = 1.725
        case "Extremely Active":  activityMultiplier = 1.9
        default:                  activityMultiplier = 1.2  // Sedentary
        }

        var tdee = bmr * activityMultiplier

        // Goal-based calorie adjustment
        switch goal {
        case "Lose Weight", "Cutting":
            tdee -= 400
        case "Build Muscle", "Bulking":
            tdee += 300
        default:
            break  // Maintain
        }

        let calories = max(tdee, 1200)

        // Macro split
        let proteinG: Double
        let fatG:     Double
        let carbsG:   Double

        switch goal {
        case "Lose Weight", "Cutting":
            // Higher protein to preserve muscle
            proteinG = w * 2.0
            fatG     = calories * 0.25 / 9
            carbsG   = (calories - proteinG * 4 - fatG * 9) / 4
        case "Build Muscle", "Bulking":
            proteinG = w * 2.2
            fatG     = calories * 0.30 / 9
            carbsG   = (calories - proteinG * 4 - fatG * 9) / 4
        default:
            proteinG = w * 1.8
            fatG     = calories * 0.28 / 9
            carbsG   = (calories - proteinG * 4 - fatG * 9) / 4
        }

        return DailyNutritionGoals(
            calories: calories.rounded(),
            protein:  max(proteinG, 50).rounded(),
            carbs:    max(carbsG,   50).rounded(),
            fat:      max(fatG,     20).rounded()
        )
    }
}
