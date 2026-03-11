import SwiftUI
import Combine

struct WorkoutDetailSheet: View {
    let workout: WorkoutModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Hero Image ────────────────────────────────────────
                    ZStack(alignment: .bottomLeading) {
                        if let urlString = workout.imageURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 260)
                                        .clipped()
                                } else {
                                    Rectangle()
                                        .fill(LinearGradient(
                                            colors: [workout.tagColor.opacity(0.4), AppTheme.surface],
                                            startPoint: .top, endPoint: .bottom
                                        ))
                                        .frame(height: 260)
                                }
                            }
                        } else {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [workout.tagColor.opacity(0.4), AppTheme.surface],
                                    startPoint: .top, endPoint: .bottom
                                ))
                                .frame(height: 260)
                        }

                        // Gradient overlay
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.85)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 260)

                        // Title + meta
                        VStack(alignment: .leading, spacing: 6) {
                            Text(workout.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            HStack(spacing: 16) {
                                Label(workout.duration, systemImage: "timer")
                                Label(workout.calories, systemImage: "flame")
                                Text(workout.level)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(workout.tagColor.opacity(0.85))
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                        }
                        .padding()
                    }
                    .frame(height: 260)

                    // ── Exercise List ─────────────────────────────────────
                    if workout.title == "Push Day - Chest & Triceps" {
                        RemoteExerciseList(query: "Chest Tricep")
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(workout.exerciseList) { exercise in
                                ExerciseRow(exercise: exercise)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }

            // ── Close Button ──────────────────────────────────────────────
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
    }
}

// MARK: - Remote Exercise List (API)
@MainActor
final class RemoteExerciseListViewModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published var items: [ExerciseSearchItem] = []
    @Published var state: LoadState = .idle

    func load(query: String) async {
        state = .loading
        do {
            let results = try await ExerciseDBClient.searchExercises(query: query)
            items = results
            state = .loaded
        } catch let apiError as ExerciseDBError {
            items = []
            if apiError.statusCode == 429 {
                state = .failed("Rate limit exceeded. Please wait a moment and try again.")
            } else {
                state = .failed(apiError.message)
            }
        } catch {
            items = []
            state = .failed(error.localizedDescription)
        }
    }
}

struct RemoteExerciseList: View {
    let query: String
    @StateObject private var vm = RemoteExerciseListViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Exercises")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(query)
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)

            Group {
                switch vm.state {
                case .idle, .loading:
                    VStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { _ in
                            RemoteExerciseRowPlaceholder()
                        }
                    }
                    .padding(.horizontal, 16)

                case .failed(let message):
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Failed to load exercises")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(message)
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)

                        Button {
                            Task { await vm.load(query: query) }
                        } label: {
                            Text("Retry")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppTheme.primary)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    .padding(16)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal, 16)

                case .loaded:
                    LazyVStack(spacing: 12) {
                        ForEach(vm.items) { item in
                            RemoteExerciseRow(item: item)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .task {
            guard vm.state == .idle else { return }
            await vm.load(query: query)
        }
    }
}

struct RemoteExerciseRow: View {
    let item: ExerciseSearchItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.06))

                AsyncImage(url: item.imageUrl) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .foregroundColor(AppTheme.secondaryText.opacity(0.7))
                    }
                }
                .clipped()
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text("Chest / Triceps")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText.opacity(0.7))
        }
        .padding(14)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct RemoteExerciseRowPlaceholder: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 14)
                    .frame(maxWidth: 220, alignment: .leading)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .frame(height: 12)
                    .frame(maxWidth: 140, alignment: .leading)
            }

            Spacer()
        }
        .padding(14)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .redacted(reason: .placeholder)
    }
}

// MARK: – Exercise Row Card
struct ExerciseRow: View {
    let exercise: ExerciseModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(exercise.muscleGroup)
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
            }

            HStack(spacing: 16) {
                Label("\(exercise.sets) sets", systemImage: "square.stack.3d.up")
                Label("\(exercise.reps) reps", systemImage: "arrow.counterclockwise")
                Label("Rest \(exercise.rest)s", systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(AppTheme.secondaryText)

            if let tip = exercise.tip {
                Text(tip)
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText.opacity(0.7))
                    .padding(.top, 2)
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
