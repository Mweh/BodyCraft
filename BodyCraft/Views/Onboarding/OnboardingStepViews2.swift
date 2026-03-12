import SwiftUI

// MARK: - Step 2: Activity Level
struct ActivityStepView: View {
    @Binding var selectedActivity: String
    var nextAction: () -> Void
    
    let levels = [
        ("Sedentary", "Mostly sitting, little or no exercise", "sofa"),
        ("Lightly Active", "Light exercise or activity 1-2 days per week", "figure.walk"),
        ("Moderately Active", "Exercise 3-4 days per week", "bicycle"),
        ("Active", "Exercise 5-6 days per week", "heart.fill"),
        ("Very Active", "Intense training or physically demanding job", "bolt.fill")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What's your activity level?")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("Tell us how active your daily lifestyle is.")
                .foregroundColor(AppTheme.secondaryText)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(levels, id: \.0) { level in
                        SelectionCard(
                            title: level.0,
                            subtitle: level.1,
                            icon: level.2,
                            isSelected: selectedActivity == level.0,
                            action: { selectedActivity = level.0 }
                        )
                    }
                }
            }
            
            PrimaryButton(title: "Continue", action: nextAction)
        }
        .padding()
    }
}

// MARK: - Step 3: Fitness Level
struct FitnessLevelStepView: View {
    @Binding var selectedFitness: String
    var nextAction: () -> Void
    
    let levels = [
        ("Beginner", "New to exercise or returning after a long break", "leaf"),
        ("Intermediate", "Consistent training for several months", "figure.run"),
        ("Advanced", "Experienced and committed lifter", "flame.fill")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Fitness level?")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("How experienced are you with exercise?")
                .foregroundColor(AppTheme.secondaryText)
            
            ForEach(levels, id: \.0) { level in
                SelectionCard(
                    title: level.0,
                    subtitle: level.1,
                    icon: level.2,
                    isSelected: selectedFitness == level.0,
                    action: { selectedFitness = level.0 }
                )
            }
            
            Spacer()
            
            PrimaryButton(title: "Continue", action: nextAction)
        }
        .padding()
    }
}

// MARK: - Step 4: About You (Age/Gender)
struct AboutYouStepView: View {
    @Binding var age: String
    @Binding var gender: String
    var nextAction: () -> Void
    
    let genders = ["Male", "Female"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("About you")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("Basic info for personalization.")
                .foregroundColor(AppTheme.secondaryText)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Age", systemImage: "person")
                    .foregroundColor(.white)
                
                HStack {
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    Text("years")
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            .padding(.top)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Gender", systemImage: "person.fill")
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    ForEach(genders, id: \.self) { g in
                        Button(action: { gender = g }) {
                            Text(g)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(gender == g ? AppTheme.primary : AppTheme.surface)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(.top)
            
            Spacer()
            PrimaryButton(title: "Continue", action: nextAction)
        }
        .padding()
    }
}
