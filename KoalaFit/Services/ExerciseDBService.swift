import Foundation

enum ExerciseDBServiceError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case apiError(String)
}

struct ExerciseSearchResponse: Codable {
    let success: Bool
    let data: [ExerciseSummary]
}

struct ExerciseSummary: Codable {
    let exerciseId: String
    let name: String
    let imageUrl: String?
}

struct ExerciseDetailResponse: Codable {
    let success: Bool
    let data: ExerciseDetail
}

struct ExerciseDetail: Codable {
    let exerciseId: String
    let name: String
    let imageUrl: String?
    let videoUrl: String?
    let instructions: [String]?
    let bodyParts: [String]?
    let targetMuscles: [String]?
    let equipments: [String]?
}

class ExerciseDBService {
    static let shared = ExerciseDBService()
    
    private init() {}
    
    func searchExercise(query: String) async throws -> ExerciseSummary? {
        // First try the full query
        if let match = try? await performSearch(query: query) {
            return match
        }
        
        // If it failed, try a simplified fuzzy query (e.g., "Barbell Bench Press" -> "Bench Press")
        let fuzzyKeywords = ["bench", "squat", "press", "row", "curl", "extension", "dip", "lunge", "deadlift", "push-up", "pull-up"]
        let words = query.lowercased().split(separator: " ")
        for keyword in fuzzyKeywords {
            if words.contains(where: { $0 == keyword }) {
                if let match = try? await performSearch(query: keyword) {
                    return match
                }
            }
        }
        
        return nil
    }
    
    private func performSearch(query: String) async throws -> ExerciseSummary? {
        guard let url = ExerciseDBConfig.searchURL(for: query) else {
            throw ExerciseDBServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ExerciseDBConfig.headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ExerciseDBServiceError.invalidResponse
        }
        
        if httpResponse.statusCode == 429 {
            print("ExerciseDB API (429): Rate limited / Security check triggered for '\(query)'.")
            return nil // Let the caller know we can't get data right now
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ExerciseDBServiceError.invalidResponse
        }
        
        do {
            let searchResponse = try JSONDecoder().decode(ExerciseSearchResponse.self, from: data)
            return searchResponse.data.first 
        } catch {
            throw ExerciseDBServiceError.decodingError(error)
        }
    }
    
    func getExerciseDetail(id: String) async throws -> ExerciseDetail {
        guard let url = ExerciseDBConfig.detailURL(for: id) else {
            throw ExerciseDBServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ExerciseDBConfig.headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ExerciseDBServiceError.invalidResponse
        }
        
        do {
            // Try wrapping first (matches Search style)
            if let detailResponse = try? JSONDecoder().decode(ExerciseDetailResponse.self, from: data) {
                return detailResponse.data
            }
            // Fallback: Try decoding directly
            let directDetail = try JSONDecoder().decode(ExerciseDetail.self, from: data)
            return directDetail
        } catch {
            print("Decoding failed for exercise detail \(id): \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw Response: \(jsonString)")
            }
            throw ExerciseDBServiceError.decodingError(error)
        }
    }
    
    func findLocalMatch(for name: String, focus: String) -> (exerciseId: String, imageUrl: String)? {
        let nameLower = name.lowercased()
        let focusLower = focus.lowercased()
        
        // Simple heuristic matching based on key exercises we have in MockData
        if focusLower.contains("chest") || nameLower.contains("bench") || nameLower.contains("push-up") || nameLower.contains("chest") {
            return ("exr_41n2hGUso7JFmuYR", "https://cdn.exercisedb.dev/media/w/images/Fw2auG2NBK.jpg")
        } else if focusLower.contains("back") || nameLower.contains("pull") || nameLower.contains("row") || nameLower.contains("back") {
            return ("exr_41n2hadPLLFRGvFk", "https://cdn.exercisedb.dev/media/w/images/E62m1yYRE8.jpg")
        } else if focusLower.contains("leg") || nameLower.contains("squat") || nameLower.contains("lunge") || nameLower.contains("calf") {
            return ("exr_41n2hmPq7h39Y7K4", "https://cdn.exercisedb.dev/media/w/images/BvE8XGv7P0.jpg")
        } else if focusLower.contains("shoulder") || nameLower.contains("press") || nameLower.contains("raise") || nameLower.contains("delt") {
            return ("exr_41n2hmvGdVRvvnNY", "https://cdn.exercisedb.dev/media/w/images/h6Yv3EwXp9.jpg")
        } else if focusLower.contains("arm") || focusLower.contains("bicep") || nameLower.contains("curl") {
            return ("exr_41n2hxqpSU5p6DZv", "https://cdn.exercisedb.dev/media/w/images/uGKkXKxdYy.jpg")
        } else if focusLower.contains("tricep") || nameLower.contains("dip") || nameLower.contains("extension") {
            return ("exr_41n2hGUso7JFmuYR", "https://cdn.exercisedb.dev/media/w/images/Fw2auG2NBK.jpg")
        }
        return nil
    }
}
