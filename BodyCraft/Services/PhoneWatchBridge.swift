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

        // Use current profile for weight-adjusted calorie estimation
        let profile = UserProfileStore.shared.profile
        let weightKg = Double(profile.weight) ?? 75.0

        // Map exercises
        var watchExercises: [WatchExercise] = []
        var totalKcal = 0
        
        for ex in day.exercises {
            // Estimate kcal based on METs (roughly 5 for strength) and weight
            // Formula: kcal = MET * weight_kg * duration_hours
            // Estimating 3 minutes (0.05 hr) per set inclusive of rest
            let exerciseDurationHrs = Double(ex.sets) * 0.05
            let kcal = Int(5.0 * weightKg * exerciseDurationHrs)
            
            totalKcal += kcal
            watchExercises.append(WatchExercise(id: ex.id, name: ex.name, sets: ex.sets, reps: ex.reps, category: day.focus))
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
        
        // Reliability: Always update application context so it's available even if app isn't reachable
        updateContext(dict)
        
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(dict, replyHandler: nil, errorHandler: nil)
        }
    }

    private func updateContext(_ dict: [String: Any]) {
        try? WCSession.default.updateApplicationContext(dict)
    }

    // iPhone → Watch checkbox: real-time with transferUserInfo fallback
    func sendCheckboxUpdate(exerciseId: UUID, isChecked: Bool) {
        let dict: [String: Any] = [
            "type": "checkboxSync",
            "exerciseId": exerciseId.uuidString,
            "isChecked": isChecked
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(dict, replyHandler: nil, errorHandler: { err in
                print("[PhoneBridge] checkbox sendMessage failed, queuing: \(err)")
                try? session.updateApplicationContext(dict)
            })
        } else {
            // Persist in application context so Watch picks it up on next activation
            try? session.updateApplicationContext(dict)
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
                // Bug #2 Fix: use applyWatchBurn so the value is protected
                // from being reverted by calculateTargets()
                DashboardViewModel.shared.applyWatchBurn(summary.caloriesBurned)
                
                // Update StreakStore to persist exercise completion
                let day = WorkoutStreakStore.shared.currentDayNumber
                for idStr in summary.completedExerciseIds {
                    if let id = UUID(uuidString: idStr) {
                        WorkoutStreakStore.shared.toggle(day: day, exerciseId: id)
                    }
                }
                
                print("[PhoneBridge] Watch workout synced — burned \(summary.caloriesBurned) kcal")
            }
            return
        }

        // Live calorie/duration streaming
        if let type = dict["type"] as? String, type == "calorieUpdate" {
            let calories = dict["calories"] as? Double ?? 0
            DispatchQueue.main.async {
                // Bug #2 Fix: use applyWatchBurn so the value is not reverted
                DashboardViewModel.shared.applyWatchBurn(calories)
                print("[PhoneBridge] Live calorie update: \(Int(calories)) kcal")
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
