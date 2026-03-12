//
//  BodyCraft_Watch_AppApp.swift
//  BodyCraft Watch App Watch App
//
//  Created by Muhammad Fahmi on 11/03/26.
//

import SwiftUI

@main
struct BodyCraft_Watch_App_Watch_AppApp: App {
    @StateObject private var sync = WatchSyncService.shared
    @StateObject private var health = HealthStoreManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sync)
                .environmentObject(health)
        }
    }
}
