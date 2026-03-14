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
        guard let url = ExerciseDBConfig.searchURL(for: query) else {
            throw ExerciseDBServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ExerciseDBConfig.headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
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
}
