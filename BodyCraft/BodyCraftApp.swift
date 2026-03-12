//
//  BodyCraftApp.swift
//  BodyCraft
//
//  Created by Muhammad Fahmi on 10/03/26.
//
//

import SwiftUI

#if DEBUG
import FLEX
#endif

// MARK: - AppDelegate for Debug Tools
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            FLEXManager.shared.showExplorer()
            DebugMenuManager.registerResetOnboardingAction()
        }
        #endif

        return true
    }
}

// MARK: - Custom Debug Utilities
#if DEBUG
class DebugMenuManager {
    static func registerResetOnboardingAction() {
        FLEXManager.shared.registerGlobalEntry(
            withName: "🔥 Reset Onboarding State",
            viewControllerFutureBlock: {
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                UserDefaults.standard.removeObject(forKey: "savedWorkoutPlanData")

                let alert = UIAlertController(
                    title: "Onboarding Reset",
                    message: "Restart the app to view the onboarding flow.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                return alert
            }
        )

        FLEXManager.shared.registerGlobalEntry(
            withName: "🔥 Toggle Onboarding Skip Button",
            viewControllerFutureBlock: {
                let current = UserDefaults.standard.bool(forKey: "showOnboardingSkipButton")
                UserDefaults.standard.set(!current, forKey: "showOnboardingSkipButton")
                
                let alert = UIAlertController(
                    title: "Skip Button",
                    message: "The onboarding skip button is now \(!current ? "Visible" : "Hidden").",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                return alert
            }
        )
    }
}
#endif

@main
struct BodyCraftApp: App {
    @StateObject private var profileStore   = UserProfileStore.shared
    @StateObject private var streakStore    = WorkoutStreakStore.shared
    @StateObject private var nutritionStore = NutritionStore()
    @StateObject private var dashboardVM    = DashboardViewModel.shared

    // Activates WCSession and pushes workout plan to Watch on launch
    private let watchBridge = PhoneWatchBridge.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(profileStore)
                .environmentObject(streakStore)
                .environmentObject(dashboardVM)
                .environmentObject(nutritionStore)
                .preferredColorScheme(.dark)
        }
    }
}
