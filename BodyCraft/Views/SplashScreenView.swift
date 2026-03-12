import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5
    
    // Warna sesuai dengan tema aplikasi (Dark Theme)
    let backgroundColor = Color(red: 17/255, green: 20/255, blue: 24/255)
    let primaryBlue = Color(red: 37/255, green: 99/255, blue: 235/255)
    
    var body: some View {
        if isActive {
            MainTabView() // Lanjut ke halaman utama struktur baru
                .transition(.opacity)
        } else {
            ZStack {
                // Background gelap
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    // Ikon Logo
                    Image("KoalaFit")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    // Nama Aplikasi
                    Text("KoalaFit")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    // Animasi muncul perlahan
                    withAnimation(.easeOut(duration: 1.2)) {
                        self.scale = 1.0
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                // Pindah ke MainTabView setelah 2.5 detik
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
