import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingCoordinatorView(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", image: selectedTab == 0 ? "house-fill" : "house")
                    }
                    .tag(0)
                
                WorkoutListView()
                    .tabItem {
                        Label("Workout", image: selectedTab == 1 ? "barbell-fill" : "workout")
                    }
                    .tag(1)
                
                NutritionSummaryView()
                    .tabItem {
                        Label("Nutrition", image: selectedTab == 3 ? "orange-fill" : "orange")
                    }
                    .tag(3)
                
                ProfileView()
                    .tabItem {
                        Label("Setting", image: selectedTab == 4 ? "gear-fill" : "gear")
                    }
                    .tag(4)
            }
            .tint(AppTheme.primary)
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
