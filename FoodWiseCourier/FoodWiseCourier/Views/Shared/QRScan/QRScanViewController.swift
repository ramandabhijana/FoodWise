//
//  QRScanViewController.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

import UIKit
import Vision
import AVFoundation
import Combine

class QRScanViewController: UIViewController {
  private var captureSession = AVCaptureSession()
  private var subscriptions = Set<AnyCancellable>()
  
  private lazy var barcodeRequest = VNDetectBarcodesRequest { [weak self] request, error in
    guard let self = self else { return }
    if let error = error {
      self.showAlert(withTitle: "Barcode Error", message: error.localizedDescription) { _ in
        self.delegate?.errorDidOccur(.barcodeError, raisedError: error)
      }
      return
    }
    self.processRequest(request)
  }
  
  public weak var delegate: QRScanViewControllerDelegate?
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    checkPermissions()
    setupCameraLiveView()
    setupStartEndRunningPublisher()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    captureSession.stopRunning()
  }
  
  private func checkPermissions() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .denied, .restricted:
      showPermissionsAlert { [weak self] _ in
        self?.delegate?.errorDidOccur(.cameraUsageNotAuthorized, raisedError: nil)
      }
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
        if !granted {
          self?.showPermissionsAlert { _ in
            self?.delegate?.errorDidOccur(.cameraUsageNotAuthorized, raisedError: nil)
          }
        }
      }
    default:
      return
    }
  }
  
  private func setupCameraLiveView() {
    captureSession.sessionPreset = .hd1280x720
    
    // Configure and add input
    guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                      for: .video,
                                                      position: .back),
          let captureInput = try? AVCaptureDeviceInput(device: captureDevice),
          captureSession.canAddInput(captureInput)
    else {
      showAlert(
        withTitle: "Cannot Find Camera",
        message: "There seems to be a problem with the camera on your device."
      ) { [weak self] _ in
          self?.delegate?.errorDidOccur(.cameraNotFound, raisedError: nil)
      }
      return
    }
    captureSession.addInput(captureInput)
    
    // Configure and add output
    let captureOutput = AVCaptureVideoDataOutput()
    captureOutput.videoSettings = [
      kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
    ]
    captureOutput.setSampleBufferDelegate(self, queue: .global(qos: .default))
    captureSession.addOutput(captureOutput)
    
    // configure the view
    configurePreviewLayer()
    
    captureSession.startRunning()
  }
  
  // Called by detectBarcodeRequest to process the request
  private func processRequest(_ request: VNRequest) {
    guard let barcodes = request.results else { return }
    DispatchQueue.main.async { [weak self] in
      guard let self = self, self.captureSession.isRunning else { return }
      self.view.layer.sublayers?.removeSubrange(1...)
      for barcode in barcodes {
        guard let potentialQrCode = barcode as? VNBarcodeObservation,
              potentialQrCode.symbology == .qr,
              potentialQrCode.confidence > 0.9,
              let payload = potentialQrCode.payloadStringValue else {
                return
              }
        self.delegate?.didObtainQrCode(withPayloadValue: payload)
      }
    }
  }
  
  private func setupStartEndRunningPublisher() {
    NotificationCenter.default.publisher(for: .qrScannerCaptureSessionShouldStartRunning)
      .sink { [weak self] _ in
        self?.captureSession.startRunning()
      }
      .store(in: &subscriptions)
    NotificationCenter.default.publisher(for: .qrScannerCaptureSessionShouldEndRunning)
      .sink { [weak self] _ in
        self?.captureSession.stopRunning()
      }
      .store(in: &subscriptions)
  }
}

extension QRScanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput,
                     didOutput sampleBuffer: CMSampleBuffer,
                     from connection: AVCaptureConnection) {
    // Get an image out of buffer
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      return
    }
    // make new handler using that image
    let imageRequestHandler = VNImageRequestHandler(
      cvPixelBuffer: pixelBuffer,
      orientation: .right)
    // perform the request using the handler
    do {
      try imageRequestHandler.perform([barcodeRequest])
    } catch {
      print(error)
    }
  }
}

extension NSNotification.Name {
  static var qrScannerCaptureSessionShouldEndRunning: NSNotification.Name {
    .init(rawValue: "qrScannerCaptureSessionShouldEndRunning")
  }
  static var qrScannerCaptureSessionShouldStartRunning: NSNotification.Name {
    .init(rawValue: "qrScannerCaptureSessionShouldStartRunning")
  }
}

private extension QRScanViewController {
  private func configurePreviewLayer() {
    let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    cameraPreviewLayer.videoGravity = .resizeAspectFill
    cameraPreviewLayer.connection?.videoOrientation = .portrait
    cameraPreviewLayer.frame = view.frame
    view.layer.insertSublayer(cameraPreviewLayer, at: 0)
  }

  private func showAlert(withTitle title: String,
                         message: String,
                         handler: ((UIAlertAction) -> Void)? = nil) {
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
      self.present(alertController, animated: true)
    }
  }

  private func showPermissionsAlert(handler: ((UIAlertAction) -> Void)? = nil) {
    showAlert(
      withTitle: "Camera Permissions",
      message: "Please open Settings and grant permission for this app to use your camera.",
      handler: handler
    )
  }
}

enum QRScanViewControllerError: Error, LocalizedError {
  case barcodeError, cameraNotFound, cameraUsageNotAuthorized
  
}

protocol QRScanViewControllerDelegate: AnyObject {
  func errorDidOccur(_ error: QRScanViewControllerError, raisedError: Error?)
  func didObtainQrCode(withPayloadValue payloadValue: String)
}
