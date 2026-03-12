import SwiftUI
import WatchKit

// MARK: - Root Entry
struct ContentView: View {
    @StateObject private var sync   = WatchSyncService.shared
    @StateObject private var health = HealthStoreManager.shared

    var body: some View {
        WorkoutRootView()
            .environmentObject(sync)
            .environmentObject(health)
    }
}

// MARK: - Workout Root (3-screen architecture)
struct WorkoutRootView: View {
    @EnvironmentObject var sync:   WatchSyncService
    @EnvironmentObject var health: HealthStoreManager

    @State private var phase: WorkoutPhase = .today
    @State private var currentExerciseIndex = 0
    @State private var selectedTab: Int = 0 // 0 = Exercise, 1 = Controls

    enum WorkoutPhase {
        case today, active, summary
    }

    var body: some View {
        Group {
            switch phase {
            case .today:
                TodayView(onStart: {
                    currentExerciseIndex = 0
                    health.startWorkout()
                    withAnimation {
                        phase = .active
                        selectedTab = 0
                    }
                })

            case .active:
                TabView(selection: $selectedTab) {
                    // Screen 2: Current Exercise
                    let exercises = sync.workoutPayload?.exercises ?? []
                    if !exercises.isEmpty && currentExerciseIndex < exercises.count {
                        ExerciseProgressView(
                            exercise: exercises[currentExerciseIndex],
                            exerciseIndex: currentExerciseIndex,
                            totalExercises: exercises.count,
                            onCompleteExercise: {
                                currentExerciseIndex += 1
                                if currentExerciseIndex >= exercises.count {
                                    finishWorkout()
                                }
                            }
                        )
                        .tag(0)
                    } else {
                        // Fallback fallback
                        VStack {
                            Text("Free Workout")
                            Button("End") { finishWorkout() }
                        }
                        .tag(0)
                    }

                    // Screen 3: Workout Controls
                    LiveMetricsView(
                        onResume: { selectedTab = 0 },
                        onEnd: { finishWorkout() }
                    )
                    .tag(1)
                }

            case .summary:
                SummaryView(onDismiss: {
                    withAnimation { phase = .today }
                })
            }
        }
    }

    private func finishWorkout() {
        health.endWorkout { duration, calories in
            let ids = sync.workoutPayload?.exercises.map(\.id.uuidString) ?? []
            sync.sendWorkoutSummary(WatchSummaryPayload(
                caloriesBurned: calories,
                durationSeconds: duration,
                completedExerciseIds: ids
            ))
            phase = .summary
        }
    }
}

// MARK: - Screen 1: Today's Workout
struct TodayView: View {
    @EnvironmentObject var sync: WatchSyncService
    let onStart: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let payload = sync.workoutPayload {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text(payload.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }

                    HStack(spacing: 8) {
                        StatBadge(icon: "list.bullet",
                                  value: "\(payload.exercises.count)",
                                  label: "Ex.")
                        StatBadge(icon: "flame.fill",
                                  value: "\(payload.totalExpectedCalories)",
                                  label: "kcal")
                    }

                    Button(action: onStart) {
                        Text("Start Workout")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.top, 4)

                } else {
                    // Problem 4: Non-blocking fetching UI
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.green)
                        Text("Fetching Plan...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Button("Sync") { sync.requestWorkoutFromPhone() }
                            .buttonStyle(.bordered)
                            .tint(.secondary)
                            .controlSize(.mini)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
            }
            .padding(.horizontal, 4)
        }
        .onAppear {
            if sync.workoutPayload == nil {
                sync.requestWorkoutFromPhone()
            }
        }
    }
}

private struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon).font(.caption).foregroundColor(.green)
            Text(value).font(.headline).foregroundColor(.white)
            Text(label).font(.system(size: 9)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.white.opacity(0.08))
        .cornerRadius(10)
    }
}

// MARK: - Screen 2: Exercise Progress
struct ExerciseProgressView: View {
    @EnvironmentObject var sync: WatchSyncService
    let exercise: WatchExercise
    let exerciseIndex: Int
    let totalExercises: Int
    let onCompleteExercise: () -> Void

    @State private var completedSets: Set<Int> = []

    var body: some View {
        VStack(spacing: 8) {
            Text("\(exerciseIndex + 1) / \(totalExercises)")
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(exercise.name)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text("\(exercise.sets) sets × \(exercise.reps)")
                .font(.caption)
                .foregroundColor(.green)

            HStack(spacing: 8) {
                ForEach(0..<exercise.sets, id: \.self) { setIdx in
                    let done = completedSets.contains(setIdx)
                    Button(action: { tapSet(setIdx) }) {
                        ZStack {
                            Circle()
                                .fill(done ? Color.green : Color.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                            Text("\(setIdx + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(done ? .white : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)

            Button(action: onCompleteExercise) {
                Text(exerciseIndex + 1 < totalExercises ? "Next Exercise" : "Finish")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(completedSets.count >= exercise.sets ? .green : .blue)
            .padding(.top, 4)
        }
        .padding(.horizontal, 4)
        .onReceive(NotificationCenter.default.publisher(for: .watchCheckboxSync)) { note in
            // Handle remote sync from iPhone
            if let exerciseIdStr = note.userInfo?["exerciseId"] as? String,
               exerciseIdStr == exercise.id.uuidString,
               let isChecked = note.userInfo?["isChecked"] as? Bool {
                
                // If the iPhone message includes a specific setIndex, use it
                if let setIdx = note.userInfo?["setIndex"] as? Int {
                    if isChecked { completedSets.insert(setIdx) }
                    else { completedSets.remove(setIdx) }
                } else {
                    // Fallback: If no set index (e.g. legacy sync), toggle first available or all
                    if isChecked { 
                        for i in 0..<exercise.sets { completedSets.insert(i) }
                    } else {
                        completedSets.removeAll()
                    }
                }
            }
        }
    }

    private func tapSet(_ idx: Int) {
        WKInterfaceDevice.current().play(.click)
        if completedSets.contains(idx) {
            completedSets.remove(idx)
            sync.sendCheckboxUpdate(exerciseId: exercise.id, setIndex: idx, isChecked: false)
        } else {
            completedSets.insert(idx)
            sync.sendCheckboxUpdate(exerciseId: exercise.id, setIndex: idx, isChecked: true)
        }
    }
}

// MARK: - Screen 3: Live Metrics (Pause / End)
struct LiveMetricsView: View {
    @EnvironmentObject var health: HealthStoreManager
    let onResume: () -> Void
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(formattedDuration(health.workoutDuration))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            HStack(spacing: 20) {
                VStack {
                    Image(systemName: "flame.fill").foregroundColor(.orange)
                    Text(String(format: "%.0f", health.activeEnergyBurned))
                        .font(.headline)
                }
                VStack {
                    Image(systemName: "heart.fill").foregroundColor(.red)
                    Text(String(format: "%.0f", health.heartRate))
                        .font(.headline)
                }
            }

            HStack(spacing: 14) {
                Button(action: {
                    if health.isWorkoutActive { health.pauseWorkout() }
                    else if health.isWorkoutPaused { health.resumeWorkout(); onResume() }
                }) {
                    Image(systemName: health.isWorkoutActive ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(Color.yellow)
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
                .buttonStyle(.plain)

                Button(action: onEnd) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(Color.red)
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
            
            Text(health.isWorkoutPaused ? "Paused" : "Active")
                .font(.caption2)
                .foregroundColor(health.isWorkoutPaused ? .yellow : .green)
        }
    }

    private func formattedDuration(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Summary
struct SummaryView: View {
    @EnvironmentObject var health: HealthStoreManager
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)

                Text("Done!")
                    .font(.headline)

                SummaryRow(icon: "flame.fill", color: .orange, label: "Burned",
                           value: String(format: "%.0f kcal", health.activeEnergyBurned))
                SummaryRow(icon: "clock.fill", color: .blue, label: "Duration",
                           value: formattedDuration(health.workoutDuration))

                Button("Dismiss", action: onDismiss)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.top, 6)
            }
        }
    }

    private func formattedDuration(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

private struct SummaryRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(color)
            Text(label).foregroundColor(.secondary).font(.caption)
            Spacer()
            Text(value).fontWeight(.semibold).font(.caption)
        }
    }
}
