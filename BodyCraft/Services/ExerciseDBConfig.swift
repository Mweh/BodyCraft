import Foundation

enum ExerciseDBConfig {
    static let baseURL = "https://exercisedbv2.ascendapi.com/api/v1/exercises"
    
    static var headers: [String: String] {
        return [
            "accept": "*/*",
            "accept-language": "en-US,en;q=0.9",
            "sec-ch-ua": "\"Google Chrome\";v=\"123\", \"Not:A-Brand\";v=\"8\", \"Chromium\";v=\"123\"",
            "sec-ch-ua-mobile": "?0",
            "sec-ch-ua-platform": "\"macOS\"",
            "sec-fetch-dest": "empty",
            "sec-fetch-mode": "cors",
            "sec-fetch-site": "same-site",
            "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
        ]
    }
    
    static func searchURL(for query: String) -> URL? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: "\(baseURL)/search?search=\(encodedQuery)")
    }
    
    static func detailURL(for exerciseId: String) -> URL? {
        return URL(string: "\(baseURL)/\(exerciseId)")
    }
}
