import Foundation

struct ExerciseSearchResponse: Decodable {
    let success: Bool
    let data: [ExerciseSearchItem]
}

struct ExerciseDBError: LocalizedError, Equatable {
    let statusCode: Int
    let message: String

    var errorDescription: String? { message }
}

struct ExerciseSearchItem: Identifiable, Decodable, Hashable {
    let exerciseId: String
    let name: String
    let imageUrl: URL?

    var id: String { exerciseId }
}

enum ExerciseDBClient {
    static func searchExercises(query: String) async throws -> [ExerciseSearchItem] {
        var components = URLComponents(string: "https://exercisedbv2.ascendapi.com/api/v1/exercises/search")!
        components.queryItems = [
            URLQueryItem(name: "search", value: query)
        ]
        let url = components.url!

        return try await send(request: URLRequest(url: url)) { data in
            let decoded = try JSONDecoder().decode(ExerciseSearchResponse.self, from: data)
            return decoded.data
        }
    }

    private static func send<T>(
        request: URLRequest,
        decode: (Data) throws -> T
    ) async throws -> T {
        var req = request
        req.httpMethod = req.httpMethod ?? "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("BodyCraft/1.0 (iOS)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // Retry once on rate limit
        if http.statusCode == 429 {
            let retryAfterSeconds = Int(http.value(forHTTPHeaderField: "Retry-After") ?? "") ?? 2
            try await Task.sleep(nanoseconds: UInt64(max(1, retryAfterSeconds)) * 1_000_000_000)

            let (data2, response2) = try await URLSession.shared.data(for: req)
            guard let http2 = response2 as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            if (200...299).contains(http2.statusCode) {
                return try decode(data2)
            }

            throw ExerciseDBError(
                statusCode: http2.statusCode,
                message: errorMessage(statusCode: http2.statusCode, data: data2) ?? "Request failed (\(http2.statusCode))."
            )
        }

        guard (200...299).contains(http.statusCode) else {
            throw ExerciseDBError(
                statusCode: http.statusCode,
                message: errorMessage(statusCode: http.statusCode, data: data) ?? "Request failed (\(http.statusCode))."
            )
        }

        return try decode(data)
    }

    private static func errorMessage(statusCode: Int, data: Data) -> String? {
        // Try JSON { message: "..."} shape if present, otherwise fallback to raw text.
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let message = json["message"] as? String, !message.isEmpty {
                return message
            }
            if let error = json["error"] as? String, !error.isEmpty {
                return error
            }
        }

        let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let text, !text.isEmpty {
            return text
        }
        return nil
    }
}
