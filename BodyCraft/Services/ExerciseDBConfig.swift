import Foundation

enum ExerciseDBConfig {
    static let baseURL = "https://exercisedbv2.ascendapi.com/api/v1/exercises"
    
    static var headers: [String: String] {
        return [
            "accept": "application/json",
            "accept-language": "en-US,en;q=0.9,id;q=0.8,ms;q=0.7",
            "priority": "u=1, i",
            "referer": "https://exercisedbv2.ascendapi.com/docs",
            "sec-ch-ua": "\"Not:A-Brand\";v=\"99\", \"Google Chrome\";v=\"145\", \"Chromium\";v=\"145\"",
            "sec-ch-ua-mobile": "?0",
            "sec-ch-ua-platform": "\"macOS\"",
            "sec-fetch-dest": "empty",
            "sec-fetch-mode": "cors",
            "sec-fetch-site": "same-origin",
            "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
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
