import SwiftUI

// MARK: - Models

struct ExerciseModel: Identifiable {
    let id = UUID()
    let name: String
    let muscleGroup: String
    let sets: Int
    let reps: String
    let rest: Int
    var tip: String? = nil
}

struct WorkoutModel: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let calories: String
    let level: String
    let exercises: Int
    let tagColor: Color
    var imageURL: String? = nil
    var exerciseList: [ExerciseModel] = []
}

// MARK: - WorkoutListView

struct WorkoutListView: View {
    @State private var selectedFilter = "All"

    let filters = ["All", "Chest", "Back", "Shoulders", "Legs", "Arms"]

    @State private var workouts: [WorkoutModel] = [
        WorkoutModel(
            title: "Push Day - Chest & Triceps",
            duration: "50 min", calories: "380 kcal", level: "Intermediate", exercises: 6,
            tagColor: .cyan,
            imageURL: "https://images.unsplash.com/photo-1552848031-326ec03fe2ec?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxneW0lMjB3ZWlnaHQlMjB0cmFpbmluZyUyMHdvcmtvdXR8ZW58MXx8fHwxNzcyODU5MDIzfDA&ixlib=rb-4.1.0&q=80&w=1080",
            exerciseList: [
                ExerciseModel(name: "Barbell Bench Press", muscleGroup: "Chest", sets: 4, reps: "6-8", rest: 120, tip: "Keep your feet flat on the floor and arch slightly."),
                ExerciseModel(name: "Incline Dumbbell Press", muscleGroup: "Upper Chest", sets: 4, reps: "8-10", rest: 90, tip: "Control the descent, squeeze at the top."),
                ExerciseModel(name: "Cable Fly", muscleGroup: "Chest", sets: 3, reps: "12-15", rest: 60, tip: "Keep a slight bend in your elbows throughout."),
                ExerciseModel(name: "Overhead Tricep Extension", muscleGroup: "Triceps", sets: 3, reps: "10-12", rest: 60, tip: "Keep elbows pointing forward."),
                ExerciseModel(name: "Tricep Pushdown", muscleGroup: "Triceps", sets: 3, reps: "12-15", rest: 45, tip: "Lock your elbows at your sides."),
                ExerciseModel(name: "Chest Dips", muscleGroup: "Lower Chest", sets: 3, reps: "10-12", rest: 60, tip: "Lean forward to target chest more.")
            ]
        ),
        WorkoutModel(
            title: "Pull Day - Back & Biceps",
            duration: "55 min", calories: "400 kcal", level: "Intermediate", exercises: 6,
            tagColor: .blue,
            imageURL: "https://images.unsplash.com/photo-1759300642292-ffe3cb347548?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkdW1iYmVsbCUyMGJpY2VwJTIwY3VybCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc3Mjg1OTAyNHww&ixlib=rb-4.1.0&q=80&w=1080",
            exerciseList: [
                ExerciseModel(name: "Deadlift", muscleGroup: "Back", sets: 4, reps: "6-8", rest: 120, tip: "Keep your back straight, drive through your legs."),
                ExerciseModel(name: "Lat Pulldown", muscleGroup: "Lats", sets: 4, reps: "10-12", rest: 60, tip: "Pull to your chest, squeeze your lats."),
                ExerciseModel(name: "Seated Row", muscleGroup: "Mid Back", sets: 3, reps: "10-12", rest: 60, tip: "Pull to your stomach, squeeze your shoulder blades."),
                ExerciseModel(name: "Face Pull", muscleGroup: "Rear Delt", sets: 3, reps: "15-20", rest: 45, tip: "External rotation at the end of the movement."),
                ExerciseModel(name: "Barbell Curl", muscleGroup: "Biceps", sets: 3, reps: "10-12", rest: 60, tip: "Avoid swinging your body."),
                ExerciseModel(name: "Hammer Curl", muscleGroup: "Biceps", sets: 3, reps: "12-15", rest: 45, tip: "Control the lowering phase.")
            ]
        ),
        WorkoutModel(
            title: "Leg Day - Quads & Glutes",
            duration: "60 min", calories: "500 kcal", level: "Advanced", exercises: 6,
            tagColor: .red,
            imageURL: "https://images.unsplash.com/photo-1770026136877-8ddf98cd6500?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiYXJiZWxsJTIwc3F1YXQlMjBneW0lMjBleGVyY2lzZXxlbnwxfHx8fDE3NzI3NzI1OTd8MA&ixlib=rb-4.1.0&q=80&w=1080",
            exerciseList: [
                ExerciseModel(name: "Barbell Squat", muscleGroup: "Quads", sets: 4, reps: "5-6", rest: 180, tip: "Keep your chest up and knees over toes."),
                ExerciseModel(name: "Romanian Deadlift", muscleGroup: "Hamstrings", sets: 4, reps: "8-10", rest: 90, tip: "Hinge at the hips, keep bar close to legs."),
                ExerciseModel(name: "Leg Press", muscleGroup: "Quads", sets: 3, reps: "10-12", rest: 90, tip: "Don't lock knees at full extension."),
                ExerciseModel(name: "Hip Thrust", muscleGroup: "Glutes", sets: 4, reps: "10-12", rest: 60, tip: "Squeeze glutes hard at the top."),
                ExerciseModel(name: "Leg Extension", muscleGroup: "Quads", sets: 3, reps: "15-20", rest: 45, tip: "Slow and controlled movement."),
                ExerciseModel(name: "Calf Raise", muscleGroup: "Calves", sets: 4, reps: "15-20", rest: 45, tip: "Full range of motion, pause at top.")
            ]
        ),
        WorkoutModel(
            title: "Shoulder & Arms Sculptor",
            duration: "45 min", calories: "320 kcal", level: "Beginner", exercises: 6,
            tagColor: .orange,
            imageURL: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080",
            exerciseList: [
                ExerciseModel(name: "Dumbbell Shoulder Press", muscleGroup: "Shoulders", sets: 3, reps: "10-12", rest: 60, tip: "Press straight up, don't flare elbows too wide."),
                ExerciseModel(name: "Lateral Raise", muscleGroup: "Side Delt", sets: 3, reps: "12-15", rest: 45, tip: "Lead with your elbows, slight bend."),
                ExerciseModel(name: "Front Raise", muscleGroup: "Front Delt", sets: 3, reps: "12-15", rest: 45, tip: "Keep core tight throughout."),
                ExerciseModel(name: "Dumbbell Curl", muscleGroup: "Biceps", sets: 3, reps: "12-15", rest: 45, tip: "Supinate at the top for full contraction."),
                ExerciseModel(name: "Skull Crusher", muscleGroup: "Triceps", sets: 3, reps: "10-12", rest: 60, tip: "Keep upper arms perpendicular to floor."),
                ExerciseModel(name: "Arnold Press", muscleGroup: "Shoulders", sets: 3, reps: "10-12", rest: 60, tip: "Rotate palms as you press up.")
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Workouts")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Text("Training programs for your aesthetic body")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                FilterChip(
                                    title: filter,
                                    isSelected: selectedFilter == filter,
                                    action: { selectedFilter = filter }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)

                    List {
                        ForEach(workouts) { workout in
                            NavigationLink {
                                WorkoutDetailSheet(workout: workout)
                            } label: {
                                WorkoutCardView(workout: workout)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if workout.level == "Custom" {
                                    Button(role: .destructive) {
                                        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
                                            workouts.remove(at: index)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        
                        Color.clear.frame(height: 100)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: CreateWorkoutView(workouts: $workouts)) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(AppTheme.primary)
                                .clipShape(Circle())
                                .shadow(color: AppTheme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primary : AppTheme.surface)
                .foregroundColor(isSelected ? .white : AppTheme.secondaryText)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Workout Card

struct WorkoutCardView: View {
    let workout: WorkoutModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            if let urlString = workout.imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    } else if phase.error != nil {
                        Rectangle()
                            .fill(LinearGradient(colors: [workout.tagColor.opacity(0.3), AppTheme.surface], startPoint: .top, endPoint: .bottom))
                            .frame(height: 180)
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(AppTheme.surface)
                                .frame(height: 180)
                            ProgressView()
                        }
                    }
                }
            } else {
                Rectangle()
                    .fill(LinearGradient(colors: [workout.tagColor.opacity(0.3), AppTheme.surface], startPoint: .top, endPoint: .bottom))
                    .frame(height: 180)
            }

            // Level badge
            VStack {
                HStack {
                    Spacer()
                    Text(workout.level)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding()

            // Info overlay
            VStack(alignment: .leading, spacing: 8) {
                Text(workout.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                HStack(spacing: 16) {
                    Label(workout.duration, systemImage: "timer")
                    Label(workout.calories, systemImage: "flame")
                    Label("\(workout.exercises) exercises", systemImage: "dumbbell")
                }
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText)
            }
            .padding()
            .background(
                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
    }
}
