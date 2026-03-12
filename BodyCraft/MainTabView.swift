import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingCoordinatorView(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else {
            TabView(selection: $selectedTab) {
                // We'll replace these placeholders as we build them.
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
                
                WorkoutListView()
                    .tabItem {
                        Image(systemName: "figure.walk")
                        Text("Workout")
                    }
                    .tag(1)
                
//                ProgressDashboardView()
//                    .tabItem {
//                        Image(systemName: "chart.line.uptrend.xyaxis")
//                        Text("Progress")
//                    }
//                    .tag(2)
                
                NutritionSummaryView()
                    .tabItem {
                        Image(systemName: "fork.knife")
                        Text("Nutrition")
                    }
                    .tag(3)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(4)
            }
            .accentColor(AppTheme.primary)
            .preferredColorScheme(.dark)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(UserProfileStore())
            .environmentObject(WorkoutStreakStore())
            .environmentObject(NutritionStore())
    }
}
