//
//  BodyCraftApp.swift
//  BodyCraft
//
//  Created by Muhammad Fahmi on 10/03/26.
//
//

import SwiftUI

@main
struct BodyCraftApp: App {
    @StateObject private var profileStore    = UserProfileStore()
    @StateObject private var streakStore     = WorkoutStreakStore()
    @StateObject private var nutritionStore  = NutritionStore()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(profileStore)
                .environmentObject(streakStore)
                .environmentObject(nutritionStore)
                .preferredColorScheme(.dark)
        }
    }
}

