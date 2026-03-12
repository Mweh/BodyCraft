import SwiftUI
import CoreImage
import Combine
import AVFoundation

struct FoodScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FoodScannerViewModel()
    @StateObject private var cameraService = CameraService()
    
    @State private var showingPhotoPicker = false
    @State private var isFlashActive = false
    @State private var captureAnimation = false
    
    var body: some View {
        ZStack {
            // Camera Background
            if cameraService.permissionStatus == .authorized {
                CameraPreview(session: cameraService.session)
                    .ignoresSafeArea()
            } else if cameraService.permissionStatus == .denied {
                Color.black.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "camera.slash.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Camera access denied")
                        .font(.headline)
                        .foregroundColor(.white)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Color.black.ignoresSafeArea()
                ProgressView()
                    .tint(.white)
            }
            
            // UI Overlay
            switch viewModel.state {
            case .idle:
                scanningOverlay
            case .processingImage, .fetchingNutrition:
                processingOverlay
            case .analysisComplete:
                // This state is now bypassed by the ViewModel's auto-confirm logic
                ProgressView().tint(.white)
            case .resultCalculated(let nutritionInfo):
                NutritionResultView(
                    nutritionInfo: nutritionInfo,
                    capturedImage: viewModel.selectedImage,
                    onReset: {
                        viewModel.reset()
                        cameraService.setup() // Restart camera
                    },
                    onDismiss: { dismiss() }
                )
            case .error(let message):
                errorOverlay(message)
            }
            
            // Capture Animation Flash
            if captureAnimation {
                Color.white.ignoresSafeArea()
                    .opacity(0.8)
                    .transition(.opacity)
            }
        }
        .onAppear {
            cameraService.setup()
        }
        .onDisappear {
            cameraService.stop()
        }
        .onChange(of: cameraService.lastCaptureTime) { _ in
            if let photo = cameraService.photo {
                viewModel.processImage(photo)
            }
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker(isPresented: $showingPhotoPicker, selectedImage: $viewModel.selectedImage) { image in
                viewModel.processImage(image)
            }
        }
    }
    
    // MARK: - Scanning Overlay
    
    private var scanningOverlay: some View {
        ZStack {
            ScanningHUDView()
            
            VStack {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: { /* Toggle Flash logic */ }) {
                        Image(systemName: isFlashActive ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Bottom Controls
                HStack(spacing: 60) {
                    // Gallery Button
                    Button(action: { showingPhotoPicker = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 50, height: 50)
                            Image(systemName: "photo.on.rectangle")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                    }
                    
                    // Capture Button
                    Button(action: captureAction) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 65, height: 65)
                        }
                    }
                    
                    // Placeholder or additional tool
                    Spacer().frame(width: 50)
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Analyzing Food...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
    
    private func errorOverlay(_ message: String) -> some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 50))
                Text("Identification Error")
                    .font(.title2).bold().foregroundColor(.white)
                Text(message)
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
                Button("Try Again") { viewModel.reset() }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private func captureAction() {
        // Trigger haptic
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Show flash animation
        withAnimation { captureAnimation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation { captureAnimation = false }
        }
        
        // Perform capture
        cameraService.capturePhoto()
        
        // Freeze camera to create the "captured" vibe
        cameraService.stop()
    }
}
