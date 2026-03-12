import Foundation
import WatchConnectivity
import Combine

// MARK: - Shared Models (Mirroring iPhone target)
struct WatchWorkoutPayload: Codable {
    let title: String
    let totalExpectedCalories: Int
    let exercises: [WatchExercise]
}

struct WatchExercise: Codable, Identifiable {
    let id: UUID
    let name: String
    let sets: Int
    let reps: String
}

struct WatchSummaryPayload: Codable {
    let caloriesBurned: Double
    let durationSeconds: TimeInterval
    let completedExerciseIds: [String]
}

final class WatchSyncService: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSyncService()

    @Published var workoutPayload: WatchWorkoutPayload?
    
    // Persistent cache keys
    private let kWorkoutCacheKey = "cached_workout_payload"
    private var wcSession: WCSession?

    override private init() {
        super.init()
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
        
        // Problem 4: Load cached plan immediately for non-blocking UI
        loadCachedPayload()
    }

    // MARK: - Cache Management
    private func loadCachedPayload() {
        if let data = UserDefaults.standard.data(forKey: kWorkoutCacheKey),
           let decoded = try? JSONDecoder().decode(WatchWorkoutPayload.self, from: data) {
            DispatchQueue.main.async {
                self.workoutPayload = decoded
            }
        }
    }

    private func saveToCache(_ payload: WatchWorkoutPayload) {
        if let encoded = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(encoded, forKey: kWorkoutCacheKey)
        }
    }

    // MARK: - Messaging
    
    // Problem 2: Pull request from Watch
    func requestWorkoutFromPhone() {
        if wcSession?.isReachable == true {
            wcSession?.sendMessage(["type": "requestWorkout"], replyHandler: nil, errorHandler: nil)
        }
    }

    // Problem 1: Calorie Streaming
    func sendLiveMetrics(calories: Double, duration: TimeInterval) {
        let msg: [String: Any] = [
            "type": "calorieUpdate",
            "calories": calories,
            "duration": Int(duration)
        ]
        if wcSession?.isReachable == true {
            wcSession?.sendMessage(msg, replyHandler: nil, errorHandler: nil)
        }
    }

    // Problem 3: Checkbox Sync
    func sendCheckboxUpdate(exerciseId: UUID, setIndex: Int, isChecked: Bool) {
        let msg: [String: Any] = [
            "type": "checkboxSync",
            "exerciseId": exerciseId.uuidString,
            "setIndex": setIndex,
            "isChecked": isChecked
        ]
        if wcSession?.isReachable == true {
            wcSession?.sendMessage(msg, replyHandler: nil, errorHandler: nil)
        }
    }

    // Post-Workout Summary
    func sendWorkoutSummary(_ summary: WatchSummaryPayload) {
        do {
            let data = try JSONEncoder().encode(summary)
            try wcSession?.updateApplicationContext(["workoutSummary": data])
        } catch {
            print("Failed to encode summary: \(error)")
        }
    }

    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            // Problem 2: Auto-request on activation if no payload
            if workoutPayload == nil {
                requestWorkoutFromPhone()
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleIncoming(applicationContext)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleIncoming(message)
    }

    private func handleIncoming(_ dict: [String: Any]) {
        // Workout Plan Sync
        if let data = dict["workoutPayload"] as? Data {
            if let decoded = try? JSONDecoder().decode(WatchWorkoutPayload.self, from: data) {
                DispatchQueue.main.async {
                    self.workoutPayload = decoded
                    self.saveToCache(decoded)
                }
            }
        }
        
        // Remote Checkbox Sync (iPhone -> Watch)
        if let type = dict["type"] as? String, type == "checkboxSync" {
            NotificationCenter.default.post(name: .watchCheckboxSync, object: nil, userInfo: dict)
        }
    }
}

extension NSNotification.Name {
    static let watchCheckboxSync = NSNotification.Name("watchCheckboxSync")
}
