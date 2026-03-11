import SwiftUI

struct CompletionSummaryView: View {
    // Post-workout mock summary data
    let workoutName = "Push Day"
    let totalTime = "00:45:12"
    let activeCalories = 420
    let totalCalories = 486
    let avgHeartRate = 128
    
    var onDone: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Workout Complete")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.green)
                    Text(workoutName)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 8)
                
                Divider()
                
                // Core Metrics
                VStack(spacing: 12) {
                    SummaryRow(title: "Time", value: totalTime, color: .yellow)
                    SummaryRow(title: "Active Kilocalories", value: "\(activeCalories)CAL", color: .orange)
                    SummaryRow(title: "Total Kilocalories", value: "\(totalCalories)CAL", color: .red)
                    SummaryRow(title: "Average Heart Rate", value: "\(avgHeartRate)BPM", color: .pink)
                }
                
                Divider()
                
                // Done Button
                Button(action: onDone) {
                    Text("Done")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .lineLimit(1)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

#Preview {
    CompletionSummaryView(onDone: {})
}
