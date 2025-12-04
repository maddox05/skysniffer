//
//  CustomCameraView.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/2/25.
//

import SwiftUI
import AVFoundation
internal import Combine

struct CustomCameraView: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    @StateObject private var camera = CameraModel()
    @State private var instructionOpacity: Double = 1.0
    @State private var showingPermissionAlert = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreview(camera: camera)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top branding bar - respects safe area
                    HStack {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }

                        Spacer()

                        HStack(spacing: 8) {
                            Image("App Icon White")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("SkySniffer")
                                .font(.custom("EBGaramond-SemiBold", size: 18))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)

                        Spacer()

                        Button {
                            camera.flipCamera()
                        } label: {
                            Image(systemName: "camera.rotate")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .padding(.top, geometry.safeAreaInsets.top > 20 ? 8 : 0)

                    Spacer(minLength: 0)

                    // Instructions
                    Text("Frame the plane and contrail")
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(10)
                        .opacity(instructionOpacity)

                    Spacer(minLength: 20)

                    // Capture button
                    Button {
                        camera.capturePhoto()
                    } label: {
                        ZStack {
                            // Dark shadow circle for visibility
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 90, height: 90)
                                .blur(radius: 8)

                            Circle()
                                .stroke(Color.white, lineWidth: 5)
                                .frame(width: 80, height: 80)

                            Circle()
                                .fill(Color.white)
                                .frame(width: 65, height: 65)
                        }
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom + 20 : 40)
                }
            }
        }
        .onAppear {
            camera.checkPermissions()

            // Fade out instruction after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 1.0)) {
                    instructionOpacity = 0
                }
            }
        }
        .onChange(of: camera.capturedImage) { oldValue, newValue in
            if let capturedImage = newValue {
                Task { @MainActor in
                    image = capturedImage
                    isPresented = false
                }
            }
        }
        .onChange(of: camera.permissionDenied) { oldValue, newValue in
            if newValue {
                showingPermissionAlert = true
            }
        }
        .alert("Camera Access Required", isPresented: $showingPermissionAlert) {
            Button("Cancel", role: .cancel) {
                isPresented = false
            }
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
                isPresented = false
            }
        } message: {
            Text("SkySniffer needs camera access to photograph the sky. Please enable camera access in Settings.")
        }
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var capturedImage: UIImage?
    @Published var isCameraAuthorized = false
    @Published var permissionDenied = false
    @Published var session = AVCaptureSession()
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var output = AVCapturePhotoOutput()

    private var currentCameraPosition: AVCaptureDevice.Position = .back

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("✅ Camera authorized")
            setUp()
        case .notDetermined:
            print("❓ Camera permission not determined, requesting...")
            AVCaptureDevice.requestAccess(for: .video) { status in
                print("📹 Camera permission response: \(status)")
                if status {
                    DispatchQueue.main.async {
                        self.setUp()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.permissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            print("❌ Camera permission denied or restricted")
            DispatchQueue.main.async {
                self.permissionDenied = true
            }
        @unknown default:
            break
        }
    }

    func setUp() {
        do {
            print("🎥 Setting up camera...")
            session.beginConfiguration()

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
                print("❌ No camera device found")
                return
            }

            print("📷 Camera device found: \(device.localizedName)")

            let input = try AVCaptureDeviceInput(device: device)

            if session.canAddInput(input) {
                session.addInput(input)
                print("✅ Camera input added")
            }

            if session.canAddOutput(output) {
                session.addOutput(output)
                print("✅ Camera output added")
            }

            session.commitConfiguration()

            DispatchQueue.global(qos: .background).async {
                print("▶️ Starting camera session...")
                self.session.startRunning()
                print("✅ Camera session running: \(self.session.isRunning)")
            }
        } catch {
            print("❌ Error setting up camera: \(error.localizedDescription)")
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func flipCamera() {
        session.beginConfiguration()

        // Remove current input
        session.inputs.forEach { input in
            session.removeInput(input)
        }

        // Toggle camera position
        currentCameraPosition = currentCameraPosition == .back ? .front : .back

        // Add new input
        do {
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
                return
            }

            let input = try AVCaptureDeviceInput(device: device)

            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("Error flipping camera: \(error.localizedDescription)")
        }

        session.commitConfiguration()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }

        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        camera.preview = previewLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview layer frame if needed
        if let previewLayer = camera.preview {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}
