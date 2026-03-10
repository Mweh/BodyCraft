import SwiftUI

struct HomeView: View {
    let userName = "Alex Fitman"
    let streakDays = [
        ("Mon", true), ("Tue", true), ("Wed", true), ("Thu", true),
        ("Fri", false), ("Sat", false), ("Sun", false)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // User Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Good Morning")
                                    .foregroundColor(AppTheme.secondaryText)
                                    .font(.subheadline)
                                Text(userName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Circle()
                                .fill(AppTheme.primary)
                                .frame(width: 50, height: 50)
                                .overlay(Text("AF").foregroundColor(.white).bold())
                        }
                        .padding(.horizontal)
                        
                        // AI Workout Quick Link
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(AppTheme.primary)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Workout Plan")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                Text("Create your personalized workout plan")
                                    .foregroundColor(AppTheme.secondaryText)
                                    .font(.caption)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // 4 Day Streak
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.yellow)
                                Text("4 Day Streak")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("This Week")
                                    .foregroundColor(AppTheme.secondaryText)
                                    .font(.caption)
                            }
                            
                            HStack(spacing: 12) {
                                ForEach(streakDays, id: \.0) { day in
                                    VStack(spacing: 8) {
                                        Circle()
                                            .fill(day.1 ? AppTheme.primary : AppTheme.surface)
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.white)
                                                    .font(.caption)
                                                    .opacity(day.1 ? 1 : 0)
                                            )
                                        Text(day.0)
                                            .font(.caption)
                                            .foregroundColor(day.1 ? .white : AppTheme.secondaryText)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Calories Burned
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                    .padding(8)
                                    .background(AppTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Calories burned today")
                                    .foregroundColor(AppTheme.secondaryText)
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("486")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("kcal")
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                            }
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Daily goal")
                                    Spacer()
                                    Text("486 / 600 kcal")
                                }
                                .font(.caption)
                                .foregroundColor(AppTheme.secondaryText)
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppTheme.background)
                                            .frame(height: 8)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.green)
                                            .frame(width: geo.size.width * (486.0 / 600.0), height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Body Goals
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "target")
                                    .foregroundColor(.green)
                                Text("Body Goals")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("68%")
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppTheme.background)
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.green)
                                        .frame(width: geo.size.width * 0.68, height: 8)
                                }
                            }
                            .frame(height: 8)
                            
                            HStack {
                                GoalMetricCard(title: "Weight", current: "72 kg", target: "-> 70 kg")
                                GoalMetricCard(title: "Body Fat", current: "18%", target: "-> 12%")
                                GoalMetricCard(title: "Muscle", current: "58 kg", target: "-> 62 kg")
                            }
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct GoalMetricCard: View {
    let title: String
    let current: String
    let target: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText)
            Text(current)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(target)
                .font(.caption2)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
