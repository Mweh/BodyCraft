import SwiftUI
import Combine
import Lottie

struct AILoadingView: View {
    var errorMessage: String? = nil
    
    let messages = [
        "Analyzing your body profile",
        "Calculating your optimal calorie burn",
        "Designing your weekly workout split",
        "Balancing strength and recovery",
        "Optimizing exercises for your goal"
    ]
    
    @State private var currentIndex = 0
    @State private var showCheckmark = false
    @State private var breathingScale = 1.0
    
    let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    
    private let activeGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.7, green: 0.4, blue: 1.0)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Top: Lottie Animation with Breathing Effect
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.12))
                    .frame(width: 140, height: 140)
                    .blur(radius: 35)
                
                LottieView(name: "AI twinkle loading", loopMode: .loop)
                    .frame(width: 200, height: 200)
                    .scaleEffect(breathingScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            breathingScale = 1.08
                        }
                    }
            }
            .padding(.bottom, 30)
            
            // Middle: Headline
            Text("Designing Your Program")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 60)
            
            // Bottom: Premium Discrete Carousel
            VStack(spacing: 25) {
                ForEach(-1...1, id: \.self) { offset in
                    let index = getIndex(for: offset)
                    let isCenter = offset == 0
                    
                    HStack(spacing: 8) {
                        if isCenter && showCheckmark {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        Text(messages[index])
                            .font(.system(size: isCenter ? 22 : 16, weight: isCenter ? .semibold : .medium, design: .rounded))
                            .foregroundStyle(isCenter ? AnyShapeStyle(activeGradient) : AnyShapeStyle(Color.white.opacity(0.4)))
                            .scaleEffect(isCenter ? 1.0 : 0.9)
                    }
                    .id("\(currentIndex)_\(offset)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
            }
            .frame(height: 180)
            .clipped()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.top, 24)
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.ignoresSafeArea())
        .onReceive(timer) { _ in
            // Step 1: Show completion checkmark
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showCheckmark = true
            }
            
            // Step 2: Transition to next message after 0.5s pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    showCheckmark = false
                    currentIndex = (currentIndex + 1) % messages.count
                }
            }
        }
    }
    
    private func getIndex(for offset: Int) -> Int {
        let index = (currentIndex + offset + messages.count) % messages.count
        return index
    }
}

private struct MessageLine: View {
    let text: String
    let isCenter: Bool
    
    var body: some View {
        Text(text)
            .font(.system(size: isCenter ? 18 : 14, weight: isCenter ? .bold : .medium, design: .rounded))
            .foregroundColor(isCenter ? .white : .white.opacity(0.3))
            .scaleEffect(isCenter ? 1.1 : 0.9)
            .frame(height: 30)
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
    }
}

struct AILoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AILoadingView()
    }
}
