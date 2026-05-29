import SwiftUI

struct ScanningHUDView: View {
    @State private var scanLineOffset: CGFloat = -120
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Dimmed background with cutout using HolePunchMask
            HolePunchMask(cutoutRect: CGRect(x: 0, y: 0, width: 270, height: 270))
                .fill(Color.black.opacity(0.65), style: FillStyle(eoFill: true, antialiased: true))
                .ignoresSafeArea()
            
            // Corner Brackets - Centered exactly with the cutout
            ScannerCorners()
                .stroke(Color.white, lineWidth: 4)
                .frame(width: 270, height: 270)
                .scaleEffect(pulseScale)
            
            // Guide text
            VStack {
                Spacer()
                Text("Align food within the frame")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.bottom, 160)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.03
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
