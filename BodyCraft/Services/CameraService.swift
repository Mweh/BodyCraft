import AVFoundation
import UIKit
import Combine

enum CameraPermission: String {
    case authorized
    case denied
    case notDetermined
}

final class CameraService: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var photo: UIImage?
    @Published var lastCaptureTime: Date?
    @Published var permissionStatus: CameraPermission = .notDetermined
    
    private let output = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionStatus = .authorized
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionStatus = granted ? .authorized : .denied
                }
            }
        case .denied, .restricted:
            permissionStatus = .denied
        @unknown default:
            permissionStatus = .denied
        }
    }
    
    func setup() {
        checkPermissions()
        
        #if targetEnvironment(simulator)
        print("Camera not available on simulator")
        return
        #endif
        
        // Don't re-setup if already configured or running
        guard !session.isRunning else { return }
        
        session.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No back camera found")
            session.commitConfiguration()
            return
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.sessionPreset = .photo
            session.commitConfiguration()
            
            // Start session in background to avoid blocking main thread
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        } catch {
            print("Camera setup error: \(error.localizedDescription)")
            session.commitConfiguration()
        }
    }
    
    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async {
            self.photo = image
            self.lastCaptureTime = Date()
        }
    }
}
