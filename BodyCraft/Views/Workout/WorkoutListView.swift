import SwiftUI

struct WorkoutListView: View {
    @State private var selectedFilter = "All"
    let filters = ["All", "Chest", "Back", "Shoulders", "Legs"]
    
    let workouts = [
        WorkoutModel(title: "Push Day - Chest & Triceps", duration: "50 min", calories: "380 kcal", level: "Intermediate", exercises: 6, tagColor: .cyan),
        WorkoutModel(title: "Pull Day - Back & Biceps", duration: "55 min", calories: "400 kcal", level: "Intermediate", exercises: 6, tagColor: .blue),
        WorkoutModel(title: "Leg Day - Quads & Glutes", duration: "60 min", calories: "500 kcal", level: "Advanced", exercises: 6, tagColor: .red)
    ]
    
    var body: some View {
        NavigationView {
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
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(workouts) { workout in
                                WorkoutCardView(workout: workout)
                            }
                            Spacer().frame(height: 100)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

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

struct WorkoutModel: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let calories: String
    let level: String
    let exercises: Int
    let tagColor: Color
}

struct WorkoutCardView: View {
    let workout: WorkoutModel
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Placeholder Image Background
            Rectangle()
                .fill(LinearGradient(colors: [workout.tagColor.opacity(0.3), AppTheme.surface], startPoint: .top, endPoint: .bottom))
                .frame(height: 180)
            
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

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
    }
}
