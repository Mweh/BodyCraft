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
        // Delay initializing FLEX slightly to allow the root UIWindow to finish rendering
        // in the SwiftUI Lifecycle. This prevents hierarchy crashes (like the network inspector bug).
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            FLEXManager.shared.showExplorer()
            
            // Register our custom debug action
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
        // Registering a global entry in FLEX for our specific use case
        FLEXManager.shared.registerGlobalEntry(
            withName: "🔥 Reset Onboarding State",
            viewControllerFutureBlock: {
                
                // 1. Wipe UserDefaults flags
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                
                // 2. Clear out AI payload cache
                UserDefaults.standard.removeObject(forKey: "savedWorkoutPlanData")
                
                // You could also clear standard onboarding inputs if saved explicitly in UserDefaults...
                
                // 3. Optional: Bring up an alert confirming the reset
                let alert = UIAlertController(title: "Onboarding Reset", message: "Restart the app to view the onboarding flow.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                return alert
            }
        )
    }
}
#endif

@main
struct BodyCraftApp: App {
    @StateObject private var profileStore  = UserProfileStore()
    @StateObject private var streakStore   = WorkoutStreakStore()
    
    // Inject the traditional UIKit AppDelegate into the SwiftUI app lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(profileStore)
                .environmentObject(streakStore)
                .preferredColorScheme(.dark)
        }
    }
}
