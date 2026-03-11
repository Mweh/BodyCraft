import SwiftUI

struct WorkoutSessionView: View {
    // Mock duration and metrics
    @State private var timeElapsed: TimeInterval = 1452 // ~24 minutes
    @State private var currentHR = 142
    @State private var caloriesBurned = 284
    
    // Rest Timer state
    @State private var isResting = false
    @State private var restTimeRemaining = 60
    
    var timeString: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Heart Rate
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(currentHR)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("BPM")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.red)
            }
            
            // Duration
            Text(timeString)
                .font(.system(size: 38, weight: .medium, design: .rounded))
                .foregroundColor(.yellow)
                .padding(.vertical, 4)
            
            // Calories
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(caloriesBurned)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("CAL")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            // Smart Rest Timer
            Button(action: {
                // Toggle rest (In a real app, this would start a timer & trigger haptics)
                isResting.toggle()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isResting ? "timer" : "stopwatch")
                    Text(isResting ? "Rest: 00:\(restTimeRemaining)" : "Start Rest")
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(isResting ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isResting ? Color.yellow : Color.white.opacity(0.15))
                .cornerRadius(20)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    WorkoutSessionView()
}
