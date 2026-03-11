import SwiftUI

struct ContentView: View {
    @State private var showingWorkout = false
    
    // Quick Start Categories
    let workoutTypes = [
        ("Strength Training", "dumbbell.fill", Color.blue),
        ("High Intensity Interval", "flame.fill", Color.orange),
        ("Core Training", "figure.core.cylinder", Color.green),
        ("Cardio Run", "figure.run", Color.red)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // Today's Progress Summary (Glanceable)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            Text("Calories")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.gray)
                            Text("1,420")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Mini rings placeholder
                        ZStack {
                            Circle().stroke(Color.white.opacity(0.2), lineWidth: 4)
                            Circle()
                                .trim(from: 0, to: 0.65)
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                        }
                        .frame(width: 32, height: 32)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.bottom, 8)
                    
                    // Quick Start Workouts
                    ForEach(workoutTypes, id: \.0) { workout in
                        Button(action: { showingWorkout = true }) {
                            HStack {
                                Image(systemName: workout.1)
                                    .foregroundColor(workout.2)
                                    .font(.title3)
                                    .frame(width: 30)
                                Text(workout.0)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding()
                        }
                        .buttonStyle(.plain)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .navigationTitle("BodyCraft")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showingWorkout) {
                WorkoutPagerView()
            }
        }
    }
}

// A Paging view managing the active workout session
struct WorkoutPagerView: View {
    @State private var selection = 1
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        TabView(selection: $selection) {
            WorkoutControlsView(onEndWorkout: { dismiss() })
                .tag(0)
            
            WorkoutSessionView()
                .tag(1)
            
            // Placeholder Media Controls (Page 2)
            VStack {
                Image(systemName: "music.note")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Text("Now Playing")
            }
            .tag(2)
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    ContentView()
}
