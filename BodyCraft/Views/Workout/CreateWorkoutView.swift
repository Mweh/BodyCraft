import SwiftUI

struct CreateWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var workouts: [WorkoutModel]
    @State private var programName = ""
    @State private var selectedExercises: Set<UUID> = []
    
    @State private var customExerciseName = ""
    @State private var customExerciseMuscle = ""
    
    @State private var readyExercises: [ExerciseModel] = [
        ExerciseModel(name: "Barbell Bench Press", muscleGroup: "Chest", sets: 4, reps: "8-10", rest: 90),
        ExerciseModel(name: "Incline Dumbbell Press", muscleGroup: "Chest", sets: 3, reps: "10-12", rest: 60),
        ExerciseModel(name: "Cable Crossover", muscleGroup: "Chest", sets: 3, reps: "12-15", rest: 60),
        ExerciseModel(name: "Lat Pulldown", muscleGroup: "Back", sets: 4, reps: "10-12", rest: 60),
        ExerciseModel(name: "Barbell Row", muscleGroup: "Back", sets: 4, reps: "8-10", rest: 90),
        ExerciseModel(name: "Deadlift", muscleGroup: "Back", sets: 4, reps: "5-8", rest: 120),
        ExerciseModel(name: "Barbell Squat", muscleGroup: "Legs", sets: 4, reps: "6-8", rest: 120),
        ExerciseModel(name: "Leg Press", muscleGroup: "Legs", sets: 3, reps: "10-12", rest: 90),
        ExerciseModel(name: "Overhead Press", muscleGroup: "Shoulders", sets: 4, reps: "8-10", rest: 90),
        ExerciseModel(name: "Lateral Raise", muscleGroup: "Shoulders", sets: 3, reps: "12-15", rest: 45)
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(AppTheme.surface))
                    }
                    
                    Spacer()
                    Text("New Program")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    
                    // Invisible button for symmetry
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.clear)
                            .padding(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                List {
                    // Form Section
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Custom Program")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PROGRAM NAME")
                                .font(.caption)
                                .foregroundColor(AppTheme.secondaryText)
                                .fontWeight(.semibold)
                            
                            TextField("e.g. Full Body Destruction", text: $programName)
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .accentColor(AppTheme.primary)
                        }
                        
                        // Custom Exercise Form
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ADD CUSTOM EXERCISE")
                                .font(.caption)
                                .foregroundColor(AppTheme.secondaryText)
                                .fontWeight(.semibold)
                            
                            HStack {
                                TextField("Exercise Name", text: $customExerciseName)
                                    .padding()
                                    .background(AppTheme.surface)
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .accentColor(AppTheme.primary)
                                
                                TextField("Muscle", text: $customExerciseMuscle)
                                    .padding()
                                    .frame(width: 100)
                                    .background(AppTheme.surface)
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .accentColor(AppTheme.primary)
                                
                                Button(action: {
                                    if !customExerciseName.isEmpty && !customExerciseMuscle.isEmpty {
                                        let newEx = ExerciseModel(
                                            name: customExerciseName,
                                            muscleGroup: customExerciseMuscle,
                                            sets: 4, reps: "10-12", rest: 60
                                        )
                                        readyExercises.insert(newEx, at: 0)
                                        selectedExercises.insert(newEx.id)
                                        customExerciseName = ""
                                        customExerciseMuscle = ""
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background((customExerciseName.isEmpty || customExerciseMuscle.isEmpty) ? AppTheme.surface : AppTheme.primary)
                                        .cornerRadius(12)
                                }
                                .disabled(customExerciseName.isEmpty || customExerciseMuscle.isEmpty)
                            }
                        }
                        
                        HStack {
                            Text("SELECT EXERCISES/TEMPLATES")
                                .font(.caption)
                                .foregroundColor(AppTheme.secondaryText)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(selectedExercises.count) Selected")
                                .font(.caption)
                                .foregroundColor(AppTheme.primary)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 8)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.bottom, 16)
                    
                    // Exercises Section
                    ForEach(readyExercises) { exercise in
                        Button(action: {
                            toggleSelection(for: exercise)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(exercise.muscleGroup)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                                Spacer()
                                
                                if selectedExercises.contains(exercise.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.primary)
                                } else {
                                    Image(systemName: "circle")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(12)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.bottom, 12)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if let index = readyExercises.firstIndex(where: { $0.id == exercise.id }) {
                                    readyExercises.remove(at: index)
                                    selectedExercises.remove(exercise.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    
                    // Bottom Button Section
                    VStack {
                        Button(action: {
                            let chosenExercises = readyExercises.filter { selectedExercises.contains($0.id) }
                            let newWorkout = WorkoutModel(
                                title: programName,
                                duration: "\(chosenExercises.count * 10) min", // Approximation
                                calories: "\(chosenExercises.count * 60) kcal", // Approximation
                                level: "Custom",
                                exercises: chosenExercises.count,
                                tagColor: .green,
                                imageURL: nil,
                                exerciseList: chosenExercises
                            )
                            workouts.insert(newWorkout, at: 0) // Insert at beginning of list
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Create Program")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background((programName.isEmpty || selectedExercises.isEmpty) ? AppTheme.surface : AppTheme.primary)
                                .cornerRadius(16)
                        }
                        .disabled(programName.isEmpty || selectedExercises.isEmpty)
                        .padding(.top, 10)
                        
                        Spacer().frame(height: 80) // Add extra padding at bottom to clear safe area
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .padding(.horizontal)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func toggleSelection(for exercise: ExerciseModel) {
        if selectedExercises.contains(exercise.id) {
            selectedExercises.remove(exercise.id)
        } else {
            selectedExercises.insert(exercise.id)
        }
    }
}

struct CreateWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        CreateWorkoutView(workouts: .constant([]))
    }
}
