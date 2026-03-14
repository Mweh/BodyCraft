import SwiftUI

// MARK: - Models

struct ExerciseModel: Identifiable {
    let id: UUID
    let name: String
    let muscleGroup: String
    let sets: Int
    let reps: String
    let rest: Int
    var tip: String? = nil

    init(id: UUID = UUID(), name: String, muscleGroup: String, sets: Int, reps: String, rest: Int, tip: String? = nil) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.sets = sets
        self.reps = reps
        self.rest = rest
        self.tip = tip
    }
    var imageURL: String? = nil
    var exerciseId: String? = nil
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
    var category: String = "All"
}

// MARK: - WorkoutListView

struct WorkoutListView: View {
    @State private var selectedFilter = "All"
    @State private var selectedWorkout: WorkoutModel? = nil
    
    @AppStorage("savedWorkoutPlanData") private var savedWorkoutPlanData: Data = Data()

    let filters = ["All", "Chest", "Back", "Shoulders", "Legs", "Arms", "Custom"]

    var defaultWorkouts: [WorkoutModel] = []
    
    @State private var workouts: [WorkoutModel] = []
    
    var filteredWorkouts: [WorkoutModel] {
        if selectedFilter == "All" {
            return workouts
        }
        return workouts.filter { $0.category == selectedFilter }
    }
    
    /// Infer a filter category from a list of exercises.
    /// - If all exercises share the same top-level category → return that category.
    /// - Mixed / unrecognised → return "Custom".
    static func inferCategory(from exercises: [ExerciseModel]) -> String {
        let muscleToCategory: [String: String] = [
            "Chest": "Chest", "Upper Chest": "Chest", "Lower Chest": "Chest",
            "Back": "Back", "Lats": "Back", "Mid Back": "Back",
            "Legs": "Legs", "Quads": "Legs", "Hamstrings": "Legs",
            "Glutes": "Legs", "Calves": "Legs",
            "Shoulders": "Shoulders", "Side Delt": "Shoulders",
            "Front Delt": "Shoulders", "Rear Delt": "Shoulders",
            "Biceps": "Arms", "Triceps": "Arms"
        ]
        let categories = Set(exercises.compactMap { muscleToCategory[$0.muscleGroup] })
        if categories.count == 1, let single = categories.first {
            return single
        }
        return "Custom"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {


                    VStack(alignment: .leading, spacing: 6) {
                        Text("Workouts")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Training programs powered by AI")
                            .font(.system(.subheadline, design: .rounded))
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
                        ForEach(filteredWorkouts) { workout in
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
        .onAppear {
            loadWorkouts()
        }
        .onChange(of: savedWorkoutPlanData) { _ in
            loadWorkouts()
        }
    }
    
    // Compute workouts based on AI or fallback to default
    private func loadWorkouts() {
        if !savedWorkoutPlanData.isEmpty,
           let aiWorkoutPlan = try? JSONDecoder().decode(AIWorkoutResponse.self, from: savedWorkoutPlanData) {
            
            workouts = aiWorkoutPlan.weeklyWorkoutPlan.map { aiDay in
                let uiExercises = aiDay.exercises.map { aiEx in
                    ExerciseModel(
                        id: aiEx.id,
                        name: aiEx.name,
                        muscleGroup: aiDay.focus,
                        sets: aiEx.sets,
                        reps: aiEx.reps,
                        rest: aiEx.restSeconds,
                        tip: "Technique verified by ExerciseDB",
                        imageURL: aiEx.imageUrl,
                        exerciseId: aiEx.exerciseId
                    )
                }
                
                // Use the first exercise's image as the workout thumbnail if available
                let thumbnailURL = aiDay.exercises.first(where: { $0.imageUrl != nil })?.imageUrl
                
                return WorkoutModel(
                    title: "\(aiDay.day): \(aiDay.focus)",
                    duration: "\(uiExercises.count * 8) min",
                    calories: "AI Target",
                    level: "Personalized",
                    exercises: uiExercises.count,
                    tagColor: .purple,
                    imageURL: thumbnailURL,
                    exerciseList: uiExercises
                )
            }
        } else {
            workouts = defaultWorkouts
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
                            .frame(height: 200)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(AppTheme.surface)
                            .frame(height: 200)
                    }
                }
            } else {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [workout.tagColor.opacity(0.3), AppTheme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(height: 200)
            }

            // Info overlay with deep gradient
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                
                HStack {
                    Text(workout.level)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(workout.tagColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.title)
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                    HStack(spacing: 16) {
                        Label(workout.duration, systemImage: "clock.fill")
                        Label(workout.calories, systemImage: "flame.fill")
                        Label("\(workout.exercises) exercises", systemImage: "dumbbell.fill")
                    }
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Preview

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
    }
}
