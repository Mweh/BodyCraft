import Foundation

enum AIError: Error {
    case invalidURL
    case missingAPIKey
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case apiError(String)
}

class AIWorkoutGeneratorService {
    static let shared = AIWorkoutGeneratorService()
    
    // In a real app, securely inject this via a backend or secure vault.
    var apiKey: String? = "AIzaSyDKi_sE1L1s0Resix5X8ri8rIFNYb7l7oc"
    
    // Using Gemini 1.5 Flash as it's fast and supports JSON response formats.
    private let endpoint = "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent"

    func generateWorkoutPlan(
        age: Int,
        gender: String,
        heightCm: Int,
        weightKg: Int,
        activityLevel: String,
        goal: String,
        experience: String,
        workoutDays: Int,
        equipment: String
    ) async throws -> AIWorkoutResponse {
        
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }
        
        guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else {
            throw AIError.invalidURL
        }
        
        // 1. Construct the Unified Prompt
        let unifiedPrompt = """
        You are a world-class certified personal trainer and sports nutritionist. Your task is to design a highly personalized, safe, and effective weekly workout program and daily nutrition target (calories) based on the user's profile.
        
        Generate a workout program for the following user:
        - Age: \(age)
        - Gender: \(gender)
        - Height: \(heightCm) cm
        - Weight: \(weightKg) kg
        - Activity Level: \(activityLevel)
        - Fitness Goal: \(goal)
        - Experience: \(experience)
        - Available workout days: \(workoutDays) days per week
        - Available Equipment: \(equipment)
        
        CONSTRAINTS:
        1. You MUST return ONLY valid JSON matching the exact schema provided below. Do not include markdown formatting like ```json.
        2. Workouts must be realistic. STRENGTH limits: 3-5 sets, 6-15 reps. ENDURANCE limits: 3-5 sets, 12-20 reps. CARDIO limits: specify in duration matching the reps string format.
        3. STRICT LIMIT: Never generate `sets` exceeding 6. Never generate `reps` exceeding 20 inside any string.
        4. Caloric targets must be healthy (minimum 1,200 kcal for women, 1,500 kcal for men). If a user's goal requires unsafe targets, adjust to the nearest safe limit.
        5. Rest periods must be specified in seconds.
        6. Match the number of workout days to the user's available days.
        
        REQUIRED JSON SCHEMA:
        {
          "daily_calories": number,
          "goal": "string",
          "safety_flag": boolean,
          "rationale": "string",
          "weekly_workout_plan": [
            {
              "day": "string",
              "focus": "string",
              "exercises": [
                {
                  "name": "string",
                  "sets": number,
                  "reps": "string",
                  "rest_seconds": number
                }
              ]
            }
          ]
        }
        """
        
        // 2. Build the REST API request body
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": unifiedPrompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.4
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown API Error"
            print("Gemini API Error (\(httpResponse.statusCode)): \(errorString)")
            throw AIError.apiError("HTTP status \(httpResponse.statusCode)")
        }
        
        // 3. Decode Gemini API response envelope
        struct GeminiResponse: Decodable {
            let candidates: [Candidate]
            
            struct Candidate: Decodable {
                let content: Content
            }
            struct Content: Decodable {
                let parts: [Part]
            }
            struct Part: Decodable {
                let text: String
            }
        }
        
        let geminiDecoder = JSONDecoder()
        let geminiResponse = try geminiDecoder.decode(GeminiResponse.self, from: data)
        
        guard var jsonString = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw AIError.invalidResponse
        }
        
        // Sanitize the response string to strip markdown backticks if Gemini includes them
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        if jsonString.hasPrefix("```json") {
            jsonString = String(jsonString.dropFirst(7))
        } else if jsonString.hasPrefix("```") {
            jsonString = String(jsonString.dropFirst(3))
        }
        
        if jsonString.hasSuffix("```") {
            jsonString = String(jsonString.dropLast(3))
        }
        
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 4. Decode the structured JSON into our Swift Models
        guard let payloadData = jsonString.data(using: .utf8) else {
            throw AIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let aiWorkout = try decoder.decode(AIWorkoutResponse.self, from: payloadData)
            return aiWorkout
        } catch {
            print("Failed to decode inner JSON: \(error)")
            throw AIError.decodingError(error)
        }
    }
    
    // Fallback/Mock Data function for testing UI without API calls
    func mockWorkoutPlan() async throws -> AIWorkoutResponse {
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 sec delay
        
        let mockJSON = """
        {
          "daily_calories": 2150,
          "goal": "lose fat",
          "safety_flag": false,
          "rationale": "At 80kg with moderate activity, your maintenance calories are around 2,650. A 500-calorie deficit puts you at 2,150 kcal/day for sustainable fat loss. The 4-day upper/lower split is optimal for an intermediate lifter to preserve muscle mass while burning fat.",
          "weekly_workout_plan": [
            {
              "day": "Day 1",
              "focus": "Upper Body - Strength",
              "exercises": [
                {
                  "name": "Barbell Bench Press",
                  "sets": 4,
                  "reps": "6-8",
                  "rest_seconds": 120
                },
                {
                  "name": "Pull-ups",
                  "sets": 3,
                  "reps": "8-10",
                  "rest_seconds": 90
                }
              ]
            },
            {
              "day": "Day 2",
              "focus": "Lower Body - Strength",
              "exercises": [
                {
                  "name": "Barbell Squats",
                  "sets": 4,
                  "reps": "6-8",
                  "rest_seconds": 120
                }
              ]
            }
          ]
        }
        """
        
        let decoder = JSONDecoder()
        return try decoder.decode(AIWorkoutResponse.self, from: mockJSON.data(using: .utf8)!)
    }
}
