import SwiftUI
import Combine

struct WorkoutDetailSheet: View {
    let workout: WorkoutModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedExercise: LocalExerciseSearchItem?
    @State private var selectedExerciseId: String? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
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
                                        .frame(height: 350) // Increased height for better immersion
                                        .clipped()
                                } else {
                                    Rectangle()
                                        .fill(LinearGradient(
                                            colors: [workout.tagColor.opacity(0.4), AppTheme.background],
                                            startPoint: .top, endPoint: .bottom
                                        ))
                                        .frame(height: 350)
                                }
                            }
                        } else {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [workout.tagColor.opacity(0.4), AppTheme.background],
                                    startPoint: .top, endPoint: .bottom
                                ))
                                .frame(height: 350)
                        }

                        // Immersive Gradient Overlay
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.95)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 350)

                        // Title + meta
                        VStack(alignment: .leading, spacing: 8) {
                            Text(workout.title)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)

                            HStack(spacing: 16) {
                                Label(workout.duration, systemImage: "clock.fill")
                                Label(workout.calories, systemImage: "flame.fill")
                                Text(workout.level)
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(workout.tagColor)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(24)
                    }
                    .frame(height: 350)
                    .ignoresSafeArea(edges: .top)

                    // ── Exercise List ─────────────────────────────────────
                    if workout.title == "Push Day - Chest & Triceps" {
                        // Offline data from bundled JSON (no API calls)
                        ChestExerciseListView(vm: ChestExerciseListViewModel()) { exercise in
                            selectedExercise = exercise
                        }
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    } else if workout.title == "Shoulder & Arms Sculptor" {
                        // Offline data from bundled JSON for Shoulder
                        ShoulderExerciseListView(vm: ShoulderExerciseListViewModel()) { exercise in
                            selectedExercise = exercise
                        }
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(workout.exerciseList) { exercise in
                                Button {
                                    if let id = exercise.exerciseId {
                                        selectedExerciseId = id
                                    }
                                } label: {
                                    ExerciseRow(exercise: exercise)
                                }
                                .buttonStyle(.plain)
                                .disabled(exercise.exerciseId == nil)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

            // Back Button Overlay
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(.black.opacity(0.3))
                        .frame(width: 40, height: 40)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.leading, 20)
                .padding(.top, 56) // Account for notch/dynamic island
            }
        }
        .navigationDestination(item: $selectedExercise) { exercise in
            ExerciseDetailView(exerciseId: exercise.exerciseId)
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedExerciseId != nil },
            set: { if !$0 { selectedExerciseId = nil } }
        )) {
            if let id = selectedExerciseId {
                ExerciseDetailView(exerciseId: id)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: – Exercise Row Card
struct ExerciseRow: View {
    let exercise: ExerciseModel

    var body: some View {
        HStack(spacing: 16) {
            // Exercise Image Thumbnail
            ZStack {
                Color.white.opacity(0.04)
                
                if let urlString = exercise.imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "dumbbell.fill")
                                .foregroundColor(AppTheme.secondaryText.opacity(0.3))
                        }
                    }
                } else {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(AppTheme.secondaryText.opacity(0.3))
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.name)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Label("\(exercise.sets) s", systemImage: "repeat")
                    Label("\(exercise.reps) r", systemImage: "bolt.fill")
                    
                    Spacer()
                    
                    Text(exercise.muscleGroup.capitalized)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.primary.opacity(0.2))
                        .foregroundColor(AppTheme.primary)
                        .clipShape(Capsule())
                }
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.surface.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}
