import SwiftUI

struct WorkoutListView: View {
    @State private var selectedFilter = "All"
    let filters = ["All", "Chest", "Back", "Shoulders", "Legs"]
    
    let workouts = [
        WorkoutModel(
            title: "Push Day - Chest & Triceps",
            duration: "50 min", calories: "380 kcal", level: "Intermediate", exercises: 6, tagColor: .cyan,
            imageURL: "https://images.unsplash.com/photo-1552848031-326ec03fe2ec?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxneW0lMjB3ZWlnaHQlMjB0cmFpbmluZyUyMHdvcmtvdXR8ZW58MXx8fHwxNzcyODU5MDIzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
        ),
        WorkoutModel(
            title: "Pull Day - Back & Biceps", 
            duration: "55 min", calories: "400 kcal", level: "Intermediate", exercises: 6, tagColor: .blue,
            imageURL: "https://images.unsplash.com/photo-1759300642292-ffe3cb347548?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkdW1iYmVsbCUyMGJpY2VwJTIwY3VybCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc3Mjg1OTAyNHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
            
            ),
        WorkoutModel(title: "Leg Day - Quads & Glutes", 
        duration: "60 min", calories: "500 kcal", level: "Advanced", exercises: 6, tagColor: .red,
        imageURL: "https://images.unsplash.com/photo-1770026136877-8ddf98cd6500?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiYXJiZWxsJTIwc3F1YXQlMjBneW0lMjBleGVyY2lzZXxlbnwxfHx8fDE3NzI3NzI1OTd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
        )
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
    var imageURL: String? = nil
}

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
                        // Error placeholder
                        Rectangle()
                            .fill(LinearGradient(colors: [workout.tagColor.opacity(0.3), AppTheme.surface], startPoint: .top, endPoint: .bottom))
                            .frame(height: 180)
                    } else {
                        // Loading state
                        ZStack {
                            Rectangle()
                                .fill(AppTheme.surface)
                                .frame(height: 180)
                            ProgressView()
                        }
                    }
                }
            } else {
                // Placeholder Image Background
                Rectangle()
                    .fill(LinearGradient(colors: [workout.tagColor.opacity(0.3), AppTheme.surface], startPoint: .top, endPoint: .bottom))
                    .frame(height: 180)
            }
            
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
