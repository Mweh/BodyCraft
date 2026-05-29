import Foundation
import HealthKit
import Combine

final class HealthStoreManager: NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    static let shared = HealthStoreManager()

    let healthStore = HKHealthStore()

    // Session is nullable — we nil it out after ending
    private(set) var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    @Published var workoutState: WorkoutState = .notStarted
    @Published var activeEnergyBurned: Double = 0.0
    @Published var heartRate: Double = 0.0
    @Published var workoutDuration: TimeInterval = 0.0
    @Published var isHealthKitAvailable: Bool = false

    var isWorkoutActive: Bool { workoutState == .running }
    var isWorkoutPaused: Bool { workoutState == .paused }

    private var timer: Timer?
    private var startDate: Date?

    enum WorkoutState {
        case notStarted, running, paused, ended
    }

    override private init() {
        super.init()
        // Request authorization eagerly at singleton creation.
        // This is a safety net — the primary call happens in the app entry point.
        // Both calls are needed because the singleton is created before onAppear fires.
        if HKHealthStore.isHealthDataAvailable() {
            requestAuthorization()
        }
    }

    // MARK: - Authorization
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isHealthKitAvailable = success
            }
        }
    }

    // MARK: - Workout Lifecycle
    func startWorkout() {
        guard workoutState == .notStarted || workoutState == .ended else { return }

        activeEnergyBurned = 0
        heartRate = 0
        workoutDuration = 0
        startDate = Date()

        // Always attempt a real HK session if the hardware supports HealthKit.
        // Do NOT gate on isHealthKitAvailable — the flag may not have resolved
        // yet when the user taps Start. The session itself will fail gracefully
        // if permission was denied, and we fall back only in that case.
        if HKHealthStore.isHealthDataAvailable() {
            startHKSession()
        } else {
            // Hardware doesn't support HealthKit (e.g. simulator without entitlement)
            DispatchQueue.main.async {
                self.workoutState = .running
                self.startTimer()
            }
        }
    }

    private func startHKSession() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor

        do {
            let newSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let newBuilder = newSession.associatedWorkoutBuilder()

            newSession.delegate = self
            newBuilder.delegate = self
            newBuilder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

            self.session = newSession
            self.builder = newBuilder

            newSession.startActivity(with: startDate)
            newBuilder.beginCollection(withStart: startDate!) { [weak self] success, error in
                DispatchQueue.main.async {
                    self?.workoutState = .running
                    self?.startTimer()
                }
            }
        } catch {
            // Fallback
            DispatchQueue.main.async {
                self.workoutState = .running
                self.startTimer()
            }
        }
    }

    func pauseWorkout() {
        guard workoutState == .running else { return }
        
        // Safety: Check if HK session is actually in a state that can be paused (Problem 5)
        if let session = session, session.state == .running {
            session.pause()
        }
        
        DispatchQueue.main.async {
            self.workoutState = .paused
            self.stopTimer()
        }
    }

    func resumeWorkout() {
        guard workoutState == .paused else { return }
        
        // Safety: Check if HK session is actually in a state that can be resumed (Problem 5)
        if let session = session, session.state == .paused {
            session.resume()
        }
        
        DispatchQueue.main.async {
            self.workoutState = .running
            self.startTimer()
        }
    }

    func endWorkout(completion: ((TimeInterval, Double) -> Void)? = nil) {
        guard workoutState == .running || workoutState == .paused else { return }

        let finalDuration = workoutDuration
        let finalCalories = activeEnergyBurned

        workoutState = .ended
        stopTimer()

        if let session = session, session.state != .ended {
            session.end()
            builder?.endCollection(withEnd: Date()) { [weak self] _, _ in
                self?.builder?.finishWorkout { _, _ in
                    DispatchQueue.main.async {
                        self?.cleanupSession()
                        completion?(finalDuration, finalCalories)
                    }
                }
            }
        } else {
            cleanupSession()
            completion?(finalDuration, finalCalories)
        }
    }

    private func cleanupSession() {
        session = nil
        builder = nil
        workoutState = .ended
    }

    // MARK: - Timer
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startDate, self.workoutState == .running else { return }
            self.workoutDuration = Date().timeIntervalSince(start)
            
            // Problem 1: Stream metrics to phone every 4 seconds
            if Int(self.workoutDuration) % 4 == 0 {
                WatchSyncService.shared.sendLiveMetrics(calories: self.activeEnergyBurned, duration: self.workoutDuration)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - HKWorkoutSessionDelegate
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            switch toState {
            case .running: self.workoutState = .running
            case .paused:  self.workoutState = .paused
            case .ended:   self.workoutState = .ended
            default: break
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}

    // MARK: - HKLiveWorkoutBuilderDelegate
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    func workoutBuilderHasEventsAdded(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType,
                  let stats = workoutBuilder.statistics(for: quantityType) else { continue }
            updateForStatistics(stats)
        }
    }

    private func updateForStatistics(_ statistics: HKStatistics) {
        switch statistics.quantityType.identifier {
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
            if let value = statistics.mostRecentQuantity()?.doubleValue(for: unit) {
                DispatchQueue.main.async { self.heartRate = value }
            }
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            let unit = HKUnit.kilocalorie()
            if let value = statistics.sumQuantity()?.doubleValue(for: unit) {
                DispatchQueue.main.async { 
                    self.activeEnergyBurned = value 
                    // Immediate push for calorie update (Problem 1)
                    WatchSyncService.shared.sendLiveMetrics(calories: value, duration: self.workoutDuration)
                }
            }
        default: break
        }
    }
}
