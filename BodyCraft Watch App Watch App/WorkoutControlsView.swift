import SwiftUI

struct WorkoutControlsView: View {
    @State private var isPaused = false
    @State private var isWaterLocked = false
    var onEndWorkout: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack(spacing: 16) {
                // End Button
                ControlBox(
                    title: "End",
                    iconName: "xmark.circle.fill",
                    color: .red,
                    isLocked: isWaterLocked,
                    action: {
                        if !isWaterLocked {
                            onEndWorkout()
                        }
                    }
                )
                
                // Pause/Resume Button
                ControlBox(
                    title: isPaused ? "Resume" : "Pause",
                    iconName: isPaused ? "play.circle.fill" : "pause.circle.fill",
                    color: isPaused ? .green : .yellow,
                    isLocked: isWaterLocked,
                    action: {
                        if !isWaterLocked {
                            isPaused.toggle()
                        }
                    }
                )
            }
            
            // Water Lock Button
            ControlBox(
                title: isWaterLocked ? "Unlock" : "Lock",
                iconName: "drop.fill",
                color: .cyan,
                isLocked: false,
                action: {
                    // Apple Watch water lock typically requires crown turn to unlock
                    isWaterLocked.toggle()
                }
            )
            .padding(.horizontal, 40)
        }
    }
}

struct ControlBox: View {
    let title: String
    let iconName: String
    let color: Color
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: iconName)
                    .font(.system(size: 32))
                    .foregroundColor(isLocked ? .gray : color)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isLocked ? .gray : .white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .opacity(isLocked ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WorkoutControlsView(onEndWorkout: {})
}
