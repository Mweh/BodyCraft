import SwiftUI

struct AppTheme {
    static let background = Color(red: 18/255, green: 20/255, blue: 24/255)
    static let surface = Color(red: 28/255, green: 30/255, blue: 36/255)
    static let primary = Color(red: 40/255, green: 90/255, blue: 255/255) // Bright Blue
    static let secondaryText = Color(red: 140/255, green: 145/255, blue: 155/255)
    
    // Status Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [primary.opacity(0.8), primary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// Global UI Modifiers
extension View {
    func standardCardStyle() -> some View {
        self
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(16)
    }
}
