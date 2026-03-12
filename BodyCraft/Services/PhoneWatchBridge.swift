import Foundation
import Combine
import WatchConnectivity

/// iPhone-side WatchConnectivity bridge — activated at app launch.
/// Pushes today's AI workout plan to the Watch and receives results back.
final class PhoneWatchBridge: NSObject, WCSessionDelegate, ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    static let shared = PhoneWatchBridge()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Push Workout to Watch

    func pushTodaysWorkoutToWatch() {
        guard let planData = UserDefaults.standard.data(forKey: "savedWorkoutPlanData"),
              let plan = try? JSONDecoder().decode(AIWorkoutResponse.self, from: planData) else { return }

        let todayNumber = WorkoutStreakStore.shared.currentDayNumber
        let idx = max(0, min(todayNumber - 1, plan.weeklyWorkoutPlan.count - 1))
        let day = plan.weeklyWorkoutPlan[idx]

        // Map exercises — break apart to help the type-checker
        var watchExercises: [WatchExercise] = []
        for ex in day.exercises {
            let repsInt = Int(ex.reps.components(separatedBy: CharacterSet.decimalDigits.inverted).first ?? "10") ?? 10
            let durationMin = Double(ex.sets * repsInt) * 0.03
            let _ = Int(durationMin * 5.0 * 75.0 / 200.0 * 60)   // estimated kcal per exercise (unused here)
            watchExercises.append(WatchExercise(id: ex.id, name: ex.name, sets: ex.sets, reps: ex.reps, category: day.focus))
        }

        // Estimate total calories separately
        var totalKcal = 0
        for ex in day.exercises {
            let repsInt = Int(ex.reps.components(separatedBy: CharacterSet.decimalDigits.inverted).first ?? "10") ?? 10
            let durationMin = Double(ex.sets * repsInt) * 0.03
            totalKcal += Int(durationMin * 5.0 * 75.0 / 200.0 * 60)
        }

        let payload = WatchWorkoutPayload(
            dayNumber: todayNumber,
            title: "\(day.day): \(day.focus)",
            totalExpectedCalories: totalKcal,
            exercises: watchExercises
        )

        sendPayloadToWatch(payload)
    }

    private func sendPayloadToWatch(_ payload: WatchWorkoutPayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        let dict: [String: Any] = ["workoutPayload": data]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(dict, replyHandler: nil) { [weak self] _ in
                self?.updateContext(dict)
            }
        } else {
            updateContext(dict)
        }
    }

    private func updateContext(_ dict: [String: Any]) {
        try? WCSession.default.updateApplicationContext(dict)
    }

    // Problem 3: Push iPhone toggle to Watch
    func sendCheckboxUpdate(exerciseId: UUID, isChecked: Bool) {
        let dict: [String: Any] = [
            "type": "checkboxSync",
            "exerciseId": exerciseId.uuidString,
            "isChecked": isChecked
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(dict, replyHandler: nil, errorHandler: nil)
        }
    }

    // MARK: - Receive from Watch

    private func handleIncoming(_ dict: [String: Any]) {
        // Watch requests a fresh push of the workout plan
        if let type = dict["type"] as? String, type == "requestWorkout" {
            DispatchQueue.main.async { self.pushTodaysWorkoutToWatch() }
            return
        }

        // Workout summary received from Watch → update DashboardViewModel
        if let data = dict["workoutSummary"] as? Data,
           let summary = try? JSONDecoder().decode(WatchSummaryPayload.self, from: data) {
            DispatchQueue.main.async {
                // Update Dashboard for immediate visual feedback
                DashboardViewModel.shared.burnedCalories = Int(summary.caloriesBurned)
                
                // Update StreakStore to persist the progress
                let day = WorkoutStreakStore.shared.currentDayNumber
                for idStr in summary.completedExerciseIds {
                    if let id = UUID(uuidString: idStr) {
                        WorkoutStreakStore.shared.toggle(day: day, exerciseId: id)
                    }
                }
                
                print("Watch workout synced — burned \(summary.caloriesBurned) kcal")
            }
            return
        }

        // Live calorie/duration streaming (Problem 1)
        if let type = dict["type"] as? String, type == "calorieUpdate" {
            let calories = dict["calories"] as? Double ?? 0
            DispatchQueue.main.async {
                // Real-time update to the shared dashboard singleton
                DashboardViewModel.shared.burnedCalories = Int(calories)
                print("Live metric received: \(Int(calories)) kcal")
            }
            return
        }

        // Checkbox sync from Watch → relay via NotificationCenter (Problem 3)
        if let type = dict["type"] as? String, type == "checkboxSync" {
            NotificationCenter.default.post(
                name: .watchCheckboxSync,
                object: nil,
                userInfo: dict
            )
        }
        if let type = dict["type"] as? String, type == "checkboxSync" {
            NotificationCenter.default.post(
                name: .watchCheckboxSync,
                object: nil,
                userInfo: dict
            )
        }
    }

    // MARK: - WCSessionDelegate (iOS)

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        guard state == .activated else { return }
        DispatchQueue.main.async { self.pushTodaysWorkoutToWatch() }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleIncoming(message)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handleIncoming(userInfo)
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
