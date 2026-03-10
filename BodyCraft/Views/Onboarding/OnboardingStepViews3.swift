import SwiftUI

// MARK: - Step 5: Body Measurements
struct BodyMeasurementsStepView: View {
    @Binding var height: String
    @Binding var weight: String
    var nextAction: () -> Void
    
    var calculatedBMI: Double {
        guard let h = Double(height), let w = Double(weight), h > 0 else { return 0 }
        let heightMeters = h / 100
        return w / (heightMeters * heightMeters)
    }
    
    var bmiCategory: String {
        let bmi = calculatedBMI
        if bmi < 18.5 { return "Underweight" }
        if bmi < 25 { return "Normal" }
        if bmi < 30 { return "Overweight" }
        return "Obese"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Body measurements")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("Body data for accurate calculations.")
                .foregroundColor(AppTheme.secondaryText)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Height", systemImage: "ruler")
                    .foregroundColor(.white)
                HStack {
                    TextField("180", text: $height)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    Text("cm")
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Weight", systemImage: "scalemass")
                    .foregroundColor(.white)
                HStack {
                    TextField("85", text: $weight)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    Text("kg")
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            
            if calculatedBMI > 0 {
                VStack(spacing: 8) {
                    Text("Your BMI")
                        .foregroundColor(AppTheme.secondaryText)
                    Text(String(format: "%.1f", calculatedBMI))
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    Text(bmiCategory)
                        .foregroundColor(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(16)
                .padding(.top)
            }
            
            Spacer()
            PrimaryButton(title: "Continue", action: nextAction)
        }
        .padding()
    }
}

// MARK: - Step 6: Workout Preferences
struct WorkoutPreferencesStepView: View {
    @Binding var sessions: Double
    @Binding var duration: String
    var nextAction: () -> Void
    
    let durations = ["15 min", "30 min", "45 min", "60 min"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Workout preferences")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("Customize your training schedule.")
                .foregroundColor(AppTheme.secondaryText)
            
            VStack(alignment: .leading, spacing: 16) {
                Label("Sessions per Week", systemImage: "calendar")
                    .foregroundColor(.white)
                
                HStack {
                    Text("2 days")
                    Spacer()
                    Text("\(Int(sessions))x").font(.title).bold()
                    Spacer()
                    Text("6 days")
                }
                .foregroundColor(AppTheme.secondaryText)
                
                Slider(value: $sessions, in: 2...6, step: 1)
                    .accentColor(AppTheme.primary)
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 16) {
                Label("Duration per Session", systemImage: "timer")
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    ForEach(durations, id: \.self) { d in
                        Button(action: { duration = d }) {
                            Text(d)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(duration == d ? AppTheme.primary : AppTheme.surface)
                                .foregroundColor(duration == d ? .white : AppTheme.secondaryText)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(16)
            
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(AppTheme.primary)
                Text("AI will adjust volume & intensity based on your preferences.")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding(.top)
            
            Spacer()
            PrimaryButton(title: "Continue", action: nextAction)
        }
        .padding()
    }
}

// MARK: - Step 7 & 8: Equipment & Summary
struct EquipmentStepView: View {
    @Binding var selectedEquipment: String
    var nextAction: () -> Void
    
    let equipmentList = [
        ("Full Gym", "Full access to gym machines & free weights", "building"),
        ("Home Equipment", "Dumbbells, resistance bands, etc.", "house"),
        ("No Equipment", "Bodyweight exercises only", "hand.raised")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your equipment")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("Select the equipment you have access to.")
                .foregroundColor(AppTheme.secondaryText)
            
            ForEach(equipmentList, id: \.0) { item in
                SelectionCard(
                    title: item.0,
                    subtitle: item.1,
                    icon: item.2,
                    isSelected: selectedEquipment == item.0,
                    action: { selectedEquipment = item.0 }
                )
            }
            
            Spacer()
            
            PrimaryButton(title: "Continue", action: nextAction)
        }
        .padding()
    }
}

struct SummaryStepView: View {
    let goal: String
    let activity: String
    let fitness: String
    let age: String
    let gender: String
    let height: String
    let weight: String
    let frequency: Int
    let duration: String
    let equipment: String
    var finishAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(32)
                .background(AppTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Text("You're all set!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("Review your details before we generate your plan.")
                .foregroundColor(AppTheme.secondaryText)
            
            ScrollView {
                VStack(spacing: 0) {
                    SummaryRow(title: "Goal", value: goal)
                    SummaryRow(title: "Activity Level", value: activity)
                    SummaryRow(title: "Fitness Level", value: fitness)
                    SummaryRow(title: "Age", value: "\(age) years")
                    SummaryRow(title: "Gender", value: gender)
                    SummaryRow(title: "Height", value: "\(height) cm")
                    SummaryRow(title: "Weight", value: "\(weight) kg")
                    SummaryRow(title: "Frequency", value: "\(frequency)x per week")
                    SummaryRow(title: "Duration", value: duration)
                    SummaryRow(title: "Equipment", value: equipment)
                }
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(16)
            }
            
            Button(action: finishAction) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate Workout Plan")
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(AppTheme.secondaryText)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.vertical, 12)
        Divider().background(AppTheme.secondaryText.opacity(0.3))
    }
}
