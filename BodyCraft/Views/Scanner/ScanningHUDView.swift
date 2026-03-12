import SwiftUI

struct ScanningHUDView: View {
    @State private var scanLineOffset: CGFloat = -120
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Dimmed background with cutout using HolePunchMask
            HolePunchMask(cutoutRect: CGRect(x: 0, y: 0, width: 250, height: 250))
                .fill(Color.black.opacity(0.6), style: FillStyle(eoFill: true, antialiased: true))
                .ignoresSafeArea()
                .offset(y: -50) // Match the frame's bottom padding logic if needed, or center properly
            
            // Frame and Brackets
            VStack {
                ZStack {
                    // Central scanning square
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(width: 250, height: 250)
                    
                    // Corner Brackets
                    ScannerCorners()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 250, height: 250)
                        .scaleEffect(pulseScale)
                    
                    // Animated Scanning Line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .green.opacity(0.5), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 230, height: 40)
                        .offset(y: scanLineOffset)
                }
                .padding(.bottom, 50)
            }
            
            // Guide text
            VStack {
                Spacer()
                Text("Align food within the frame")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.bottom, 150)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                scanLineOffset = 120
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
}

struct HolePunchMask: Shape {
    var cutoutRect: CGRect
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        
        // Center the cutout
        let cutoutOrigin = CGPoint(
            x: rect.midX - cutoutRect.width / 2,
            y: rect.midY - cutoutRect.height / 2
        )
        let cutoutFrame = CGRect(origin: cutoutOrigin, size: cutoutRect.size)
        
        path.addRoundedRect(in: cutoutFrame, cornerSize: CGSize(width: 30, height: 30))
        return path
    }
}

struct ScannerCorners: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 40
        let radius: CGFloat = 30
        
        // Top Left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))
        
        // Top Right
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))
        
        // Bottom Right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))
        
        // Bottom Left
        path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))
        
        return path
    }
}

extension View {
    func inverted() -> some View {
        self.colorInvert().drawingGroup().luminanceToAlpha().colorInvert()
    }
}
