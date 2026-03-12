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
                        selectedTab = 1 // Start on Metrics
                    }
                })

            case .active:
                TabView(selection: $selectedTab) {
                    // Page 1: Exercises
                    exerciseListView
                        .tag(0)

                    // Page 2: Metrics (Main Glance)
                    mainMetricsView
                        .tag(1)

                    // Page 3: Controls
                    controlsView
                        .tag(2)
                }
                .tabViewStyle(.page)

            case .summary:
                SummaryView(onDismiss: {
                    withAnimation { phase = .today }
                })
            }
        }
    }

    // MARK: - Active Workout Subviews

    private var exerciseListView: some View {
        let exercises = sync.workoutPayload?.exercises ?? []
        return VStack(spacing: 0) {
            if !exercises.isEmpty && currentExerciseIndex < exercises.count {
                ExerciseProgressView(
                    exercise: exercises[currentExerciseIndex],
                    exerciseIndex: currentExerciseIndex,
                    totalExercises: exercises.count,
                    onCompleteExercise: {
                        withAnimation {
                            currentExerciseIndex += 1
                            if currentExerciseIndex >= exercises.count {
                                finishWorkout()
                            } else {
                                selectedTab = 1 // Snap back to metrics after completion
                            }
                        }
                    }
                )
            } else {
                Text("Loading...").foregroundColor(.secondary)
            }
        }
    }

    private var mainMetricsView: some View {
        VStack(spacing: 4) {
            Text("ACTIVE BURN")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.green.opacity(0.8))
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(health.activeEnergyBurned))")
                    .font(.system(size: 54, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("kcal")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
            }
            .padding(.vertical, -4)

            HStack(spacing: 16) {
                MetricWidget(icon: "heart.fill", color: .red, 
                             value: "\(Int(health.heartRate))", unit: "BPM")
                MetricWidget(icon: "clock.fill", color: .blue, 
                             value: formattedDuration(health.workoutDuration), unit: "")
            }
            .padding(.top, 4)
            
            if let payload = sync.workoutPayload {
                Text(payload.title)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .padding(.top, 8)
            }
        }
    }

    private var controlsView: some View {
        VStack(spacing: 12) {
            Text(health.isWorkoutPaused ? "PAUSED" : "WORKOUT")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(health.isWorkoutPaused ? .yellow : .green)

            HStack(spacing: 20) {
                // Pause/Resume
                Button(action: {
                    if health.isWorkoutActive { health.pauseWorkout() }
                    else { health.resumeWorkout(); selectedTab = 1 }
                }) {
                    ZStack {
                        Circle().fill(health.isWorkoutPaused ? Color.green : Color.yellow)
                        Image(systemName: health.isWorkoutPaused ? "play.fill" : "pause.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 60, height: 60)

                // Stop
                Button(action: finishWorkout) {
                    ZStack {
                        Circle().fill(Color.red)
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 60, height: 60)
            }
            
            Text("Hold to lock")
                .font(.system(size: 9))
                .foregroundColor(.secondary)
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

    private func formattedDuration(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Reusable UI Components

struct MetricWidget: View {
    let icon: String
    let color: Color
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
                .padding(.bottom, 2)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Screen 1: Today's Workout
struct TodayView: View {
    @EnvironmentObject var sync: WatchSyncService
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let payload = sync.workoutPayload {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(payload.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                            .lineLimit(2)

                        HStack(spacing: 8) {
                            StatBadge(icon: "list.bullet", value: "\(payload.exercises.count)", label: "EXERCISES")
                            StatBadge(icon: "flame.fill", value: "\(payload.totalExpectedCalories)", label: "EST. KCAL")
                        }

                        Button(action: onStart) {
                            HStack {
                                Text("GO")
                                Image(systemName: "play.fill")
                            }
                            .font(.system(size: 18, weight: .black))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .cornerRadius(12)
                            .foregroundColor(.black)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 8)
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView().tint(.green)
                    Text("Syncing Plan...").font(.caption2).foregroundColor(.secondary)
                    Button("Retry") { sync.requestWorkoutFromPhone() }
                        .controlSize(.mini)
                }
            }
        }
    }
}

private struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 10)).foregroundColor(.green)
                Text(label).font(.system(size: 8, weight: .bold)).foregroundColor(.secondary)
            }
            Text(value).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        VStack(spacing: 6) {
            HStack {
                Text("EXERCISE \(exerciseIndex + 1)/\(totalExercises)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(completedSets.count)/\(exercise.sets) SETS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 4)

            Text(exercise.name.uppercased())
                .font(.system(size: 15, weight: .black))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 40)

            HStack(spacing: 6) {
                ForEach(0..<exercise.sets, id: \.self) { setIdx in
                    let done = completedSets.contains(setIdx)
                    Button(action: { tapSet(setIdx) }) {
                        ZStack {
                            Circle()
                                .stroke(done ? Color.green : Color.white.opacity(0.2), lineWidth: 2)
                                .background(Circle().fill(done ? Color.green.opacity(0.2) : Color.clear))
                            
                            if done {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.green)
                            } else {
                                Text("\(setIdx + 1)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: 32, height: 32)
                }
            }
            .padding(.vertical, 4)

            Text(exercise.reps)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)

            Button(action: onCompleteExercise) {
                Text(exerciseIndex + 1 < totalExercises ? "NEXT" : "FINISH")
                    .font(.system(size: 14, weight: .black))
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(completedSets.count >= exercise.sets ? Color.green : Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(completedSets.count >= exercise.sets ? .black : .white)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.horizontal, 4)
        .onReceive(NotificationCenter.default.publisher(for: .watchCheckboxSync)) { note in
            handleSync(note: note)
        }
    }
    
    private func handleSync(note: Notification) {
        if let exerciseIdStr = note.userInfo?["exerciseId"] as? String,
           exerciseIdStr == exercise.id.uuidString,
           let isChecked = note.userInfo?["isChecked"] as? Bool {
            
            if let setIdx = note.userInfo?["setIndex"] as? Int {
                if isChecked { completedSets.insert(setIdx) }
                else { completedSets.remove(setIdx) }
            } else {
                if isChecked { for i in 0..<exercise.sets { completedSets.insert(i) } }
                else { completedSets.removeAll() }
            }
        }
    }

    private func tapSet(_ idx: Int) {
        WKInterfaceDevice.current().play(.click)
        withAnimation(.spring()) {
            if completedSets.contains(idx) {
                completedSets.remove(idx)
                sync.sendCheckboxUpdate(exerciseId: exercise.id, setIndex: idx, isChecked: false)
            } else {
                completedSets.insert(idx)
                sync.sendCheckboxUpdate(exerciseId: exercise.id, setIndex: idx, isChecked: true)
            }
        }
    }
}

// MARK: - Screen 3: Live Metrics (PAUSE/END)
// (Removed separate struct as it's now integrated as 'controlsView' and 'mainMetricsView' tabs)

// MARK: - Summary
struct SummaryView: View {
    @EnvironmentObject var health: HealthStoreManager
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.green.opacity(0.1)).frame(width: 60, height: 60)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                }

                Text("WORKOUT COMPLETE")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.green)

                VStack(spacing: 0) {
                    SummaryRow(icon: "flame.fill", color: .orange, label: "CALORIES",
                               value: "\(Int(health.activeEnergyBurned)) kcal")
                    Divider().background(Color.white.opacity(0.1)).padding(.vertical, 8)
                    SummaryRow(icon: "clock.fill", color: .blue, label: "DURATION",
                               value: formattedDuration(health.workoutDuration))
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(15)

                Button(action: onDismiss) {
                    Text("DONE")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.green)
                        .cornerRadius(12)
                        .foregroundColor(.black)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
    }

    private func formattedDuration(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        let s = Int(t) % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
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
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 9, weight: .bold)).foregroundColor(.secondary)
                Text(value).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
            }
            Spacer()
            Image(systemName: icon).font(.title3).foregroundColor(color)
        }
    }
}
