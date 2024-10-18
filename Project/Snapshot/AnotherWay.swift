//
//  ContentView.swift
//  Snapshot
//
//  Created by Gustavo Araujo Santos on 10/16/24.
//

import SwiftUI
import AVFoundation
import UIKit
import Photos
import CoreLocation
import MobileCoreServices
import OSLog

struct AnotherWay: View {
    @State private var cameraViewController: CameraViewController?

    var body: some View {
        VStack {
            CameraView(cameraViewController: $cameraViewController)
                .edgesIgnoringSafeArea(.all)
            HStack {
                Button(action: {
                    cameraViewController?.capturePhoto()
                }) {
                    Text("Capture Photo")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Button(action: {
                    cameraViewController?.switchCamera()
                }) {
                    Text("Switch Camera")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: AVCapturePhotoCaptureDelegate?
    let locationManager = LocationManager()
    var currentCameraPosition: AVCaptureDevice.Position = .back

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
    }

    func setupSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let videoCaptureDevice = getCamera(for: currentCameraPosition) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            // Handle error
            return
        }

        photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        if (captureSession.canAddOutput(photoOutput)) {
            captureSession.addOutput(photoOutput)
        } else {
            // Handle error
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            return device
        }
        return nil
    }

    func switchCamera() {
        captureSession.beginConfiguration()
        let currentInput = captureSession.inputs.first as! AVCaptureDeviceInput
        captureSession.removeInput(currentInput)

        currentCameraPosition = currentCameraPosition == .back ? .front : .back

        guard let newCamera = getCamera(for: currentCameraPosition) else { return }
        let newVideoInput: AVCaptureDeviceInput

        do {
            newVideoInput = try AVCaptureDeviceInput(device: newCamera)
        } catch {
            return
        }

        if captureSession.canAddInput(newVideoInput) {
            captureSession.addInput(newVideoInput)
        } else {
            captureSession.addInput(currentInput) // Revert to old Input if new input fails
        }

        captureSession.commitConfiguration()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        settings.isHighResolutionPhotoEnabled = true
        settings.isAutoStillImageStabilizationEnabled = true
        settings.flashMode = .auto

        photoOutput.capturePhoto(with: settings, delegate: delegate!)
    }

    func savePhotoToLibrary(_ imageData: Data, metadata: [String: Any], location: CLLocation?) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    options.uniformTypeIdentifier = UTType.heic.identifier

                    creationRequest.addResource(with: .photo, data: imageData, options: options)
                    
                    if let location = location {
                        creationRequest.location = location
                    }
                }, completionHandler: { success, error in
                    if let error = error {
                        print("Error saving photo: \(error.localizedDescription)")
                    } else {
                        print("Photo saved successfully")
                    }
                })
            } else {
                print("Photo library access denied")
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let photoData = photo.fileDataRepresentation(),
                  let image = UIImage(data: photoData),
                  let metadata = photo.metadata as? [String: Any] else { return }
            
            let location = parent.cameraViewController?.locationManager.getCurrentLocation()
            parent.cameraViewController?.savePhotoToLibrary(photoData, metadata: metadata, location: location)
        }
    }

    @Binding var cameraViewController: CameraViewController?

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.delegate = context.coordinator
        DispatchQueue.main.async {
            self.cameraViewController = viewController
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

// MARK: - NEW NEW NEW

struct NEWANOTHERWAY: View {
    let model = NewCamera()
    
    var body: some View {
        VStack {
            CameraPreview(captureSession: model.captureSession)
                .edgesIgnoringSafeArea(.all)
            HStack {
                Button(action: {
                    model.capturePhoto()
                }) {
                    Text("Capture Photo")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Button(action: {
                    model.switchCamera()
                }) {
                    Text("Switch Camera")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    var captureSession: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Here you can update the view if needed
    }
}

class NewCamera: NSObject {
    
    // MARK: - Private Properties
    
    public let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let locationManager = LocationManager()
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // MARK: - Public Properties
    
    var addToPreviewStream: ((AVCaptureVideoPreviewLayer) -> Void)?
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        setupSession()
    }
    
    // MARK: - Public Methods
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        settings.isHighResolutionPhotoEnabled = true
        settings.isAutoStillImageStabilizationEnabled = true
        settings.flashMode = .off

        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func switchCamera() {
        captureSession.beginConfiguration()
        let currentInput = captureSession.inputs.first as! AVCaptureDeviceInput
        captureSession.removeInput(currentInput)

        currentCameraPosition = currentCameraPosition == .back ? .front : .back

        guard let newCamera = getCamera(for: currentCameraPosition) else { return }
        let newVideoInput: AVCaptureDeviceInput

        do {
            newVideoInput = try AVCaptureDeviceInput(device: newCamera)
        } catch {
            return
        }

        if captureSession.canAddInput(newVideoInput) {
            captureSession.addInput(newVideoInput)
        } else {
            captureSession.addInput(currentInput)
        }

        captureSession.commitConfiguration()
    }
    
    // MARK: - Private Methods
    
    private func setupSession() {
        captureSession.sessionPreset = .photo

        guard let videoCaptureDevice = getCamera(for: currentCameraPosition) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            // Handle error
            return
        }

        photoOutput.isHighResolutionCaptureEnabled = true
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            // Handle error
            return
        }
        
        addToPreviewStream?(AVCaptureVideoPreviewLayer(session: captureSession))
        captureSession.startRunning()
    }

    private func savePhotoToLibrary(_ imageData: Data, metadata: [String: Any], location: CLLocation?) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    options.uniformTypeIdentifier = UTType.heic.identifier
                    
                    creationRequest.addResource(with: .photo, data: imageData, options: options)
                    
                    if let location = location {
                        creationRequest.location = location
                    }
                }, completionHandler: { success, error in
                    if let error = error {
                        logger.error("Error saving photo: \(error.localizedDescription)")
                    } else {
                        logger.debug("Photo saved successfully")
                    }
                })
            } else {
                logger.debug("Photo library access denied")
            }
        }
    }
    
    private func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            return device
        }
        return nil
    }
}

// MARK: - Extensions

extension NewCamera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            logger.error("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let photoData = photo.fileDataRepresentation() else {
            logger.error("Error getting photo")
            return
        }
        
        let location = locationManager.getCurrentLocation()
        savePhotoToLibrary(photoData, metadata: photo.metadata, location: location)
    }
}

// MARK: - Fileprivates

fileprivate let logger = Logger(subsystem: "com.gustavo.Snapshot", category: "Camera")
