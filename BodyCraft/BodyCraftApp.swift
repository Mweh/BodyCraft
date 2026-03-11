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
    @StateObject private var profileStore = UserProfileStore()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(profileStore)
                .preferredColorScheme(.dark)
        }
    }
}

