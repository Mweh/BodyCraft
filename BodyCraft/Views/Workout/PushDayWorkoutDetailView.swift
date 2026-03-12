import SwiftUI
import Combine

struct PushDayWorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)? = nil
    @StateObject private var vm = ChestExerciseListViewModel()
    @State private var selectedExercise: ExerciseSearchItem?
    
    // Using the same image URL as the banner
    let imageURL = "https://images.unsplash.com/photo-1552848031-326ec03fe2ec?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxneW0lMjB3ZWlnaHQlMjB0cmFpbmluZyUyMHdvcmtvdXR8ZW58MXx8fHwxNzcyODU5MDIzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppTheme.background

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 220)
                                    .clipped()
                            } else {
                                Rectangle()
                                    .fill(AppTheme.surface)
                                    .frame(height: 220)
                            }
                        }

                        LinearGradient(
                            colors: [Color.black.opacity(0.05), Color.black.opacity(0.75), AppTheme.background],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 220)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Push Day - Chest & Triceps")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            HStack(spacing: 14) {
                                Label("50 min", systemImage: "timer")
                                Label("380 kcal", systemImage: "flame")
                                Text("Intermediate")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 220)
                    }

                    ChestExerciseListView(vm: vm) { exercise in
                        selectedExercise = exercise
                    }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                }
            }

            Button(action: {
                if let onDismiss {
                    onDismiss()
                } else {
                    dismiss()
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Circle())
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .navigationDestination(item: $selectedExercise) { exercise in
            ExerciseDetailView(exerciseId: exercise.exerciseId)
        }
    }
}

// Reusable Component for maintainability
struct ExerciseRowView: View {
    let title: String
    let target: String
    let sets: String
    let reps: String
    let rest: String
    let instruction: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(target)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.05)) // Subtle background for tags
                    .foregroundColor(AppTheme.secondaryText)
                    .clipShape(Capsule())
            }
            
            HStack(spacing: 16) {
                Text(sets)
                Text(reps)
                Text(rest)
            }
            .font(.subheadline)
            .foregroundColor(AppTheme.secondaryText)
            
            Text(instruction)
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText.opacity(0.8))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

// MARK: - Local JSON-backed Chest Exercise List

@MainActor
final class ChestExerciseListViewModel: ObservableObject {
    @Published var items: [ExerciseSearchItem] = []

    init() {
        loadFromBundle()
    }

    private func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "chest_exercises", withExtension: "json") else {
            items = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(ExerciseSearchResponse.self, from: data)
            items = decoded.data
        } catch {
            items = []
        }
    }
}

struct ChestExerciseListView: View {
    @ObservedObject var vm: ChestExerciseListViewModel
    let onSelect: (ExerciseSearchItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Exercises")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("Chest (Offline Data)")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())
            }

            if vm.items.isEmpty {
                Text("No exercises available.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
            } else {
                LazyVStack(spacing: 12) { 
                    ForEach(vm.items) { item in
                        Button {
                            onSelect(item)
                        } label: {
                            ChestExerciseRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct ChestExerciseRow: View {
    let item: ExerciseSearchItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.06))

                if let url = item.imageUrl {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "dumbbell")
                                .foregroundColor(AppTheme.secondaryText.opacity(0.7))
                        }
                    }
                    .clipped()
                } else {
                    Image(systemName: "dumbbell")
                        .foregroundColor(AppTheme.secondaryText.opacity(0.7))
                }
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text("Chest")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
            }

            Spacer()
        }
        .padding(14)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct PushDayWorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PushDayWorkoutDetailView()
    }
}

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
