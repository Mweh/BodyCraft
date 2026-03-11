import SwiftUI

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
