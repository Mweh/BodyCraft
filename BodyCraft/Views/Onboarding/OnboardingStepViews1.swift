import SwiftUI

// MARK: - Step 0: Welcome
struct WelcomeStepView: View {
    var nextAction: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(32)
                .background(AppTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Text("Your Personalized Workout Plan")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            Text("Tell us about yourself so we can build the perfect training program for your goals.")
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: nextAction) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            
            HStack(spacing: 20) {
                Label("AI-Powered", systemImage: "bolt.fill").foregroundColor(.yellow)
                Label("Personalized", systemImage: "person.fill").foregroundColor(.cyan)
                Label("Free", systemImage: "shield.fill").foregroundColor(.green)
            }
            .font(.caption)
            .padding(.top, 16)
        }
    }
}

// MARK: - Step 1: Goals
struct GoalStepView: View {
    @Binding var selectedGoal: String
    var nextAction: () -> Void
    
    let goals = [
        ("Lose Fat", "Burn calories and reduce body fat.", "flame"),
        ("Weight Gain", "Increase body weight with healthy nutrition.", "arrow.up.right"),
        ("Build Muscle", "Grow strength and muscle mass.", "dumbbell")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What's your goal?")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("Choose your main fitness objective.")
                .foregroundColor(AppTheme.secondaryText)
            
            ForEach(goals, id: \.0) { goalItem in
                SelectionCard(
                    title: goalItem.0,
                    subtitle: goalItem.1,
                    icon: goalItem.2,
                    isSelected: selectedGoal == goalItem.0,
                    action: { selectedGoal = goalItem.0 }
                )
            }
            
            Spacer()
            
            PrimaryButton(title: "Continue", action: nextAction)
        }
        .padding()
    }
}

// MARK: - Shared Views
struct SelectionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? AppTheme.primary : AppTheme.secondaryText)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.primary)
                }
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppTheme.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}
