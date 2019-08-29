//
//  ScannerViewController.swift
//  heartwitch-ios-app
//
//  Created by Leo Dion on 8/28/19.
//

import UIKit
import AVFoundation
import SwiftUI

struct InvalidValueError : Error {
  
}

protocol ScanningListener {
  func controller(_ controller: ScannerViewController, scanned result: Result<SocketConfiguration, Error>)
}

struct ScannerView : UIViewControllerRepresentable {
  
  typealias UIViewControllerType = ScannerViewController
  
  var scanningDelegate : ScanningListener?
  
  init (delegate : ScanningListener? = nil) {
    self.scanningDelegate = delegate
  }
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ScannerView>) -> ScannerViewController {
    let viewController = ScannerViewController()
       viewController.scanningDelegate = scanningDelegate
       return viewController
  }
  
  func updateUIViewController(_ uiViewController: ScannerViewController, context: UIViewControllerRepresentableContext<ScannerView>) {
    
  }
  
  public func onScan( _ delegate: ScanningListener ) -> some View {
    return ScannerView(delegate: delegate)
  }
}
final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
  
  var captureSession: AVCaptureSession!
  var previewLayer: AVCaptureVideoPreviewLayer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.black
    captureSession = AVCaptureSession()
    
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
    let videoInput: AVCaptureDeviceInput
    
    do {
      videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      return
    }
    
    if (captureSession.canAddInput(videoInput)) {
      captureSession.addInput(videoInput)
    } else {
      failed()
      return
    }
    
    let metadataOutput = AVCaptureMetadataOutput()
    
    if (captureSession.canAddOutput(metadataOutput)) {
      captureSession.addOutput(metadataOutput)
      
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = [.qr]
    } else {
      failed()
      return
    }
    
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.layer.bounds
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer)
    
    captureSession.startRunning()
  }
  
  func failed() {
    let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
    captureSession = nil
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if (captureSession?.isRunning == false) {
      captureSession.startRunning()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if (captureSession?.isRunning == true) {
      captureSession.stopRunning()
    }
  }
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    
    
    if let metadataObject = metadataObjects.first {
      guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
      guard let stringValue = readableObject.stringValue else { return }
      AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
      if found(code: stringValue) {
        captureSession.stopRunning()
      }
    }
    
    //dismiss(animated: true)
  }
  
  func found(code: String) -> Bool {
    guard let delegate = self.scanningDelegate else {
      return false
    }
    
    let components = code.components(separatedBy: ",")
    
    guard components.count == 2 else {
      delegate.controller(self, scanned: .failure(InvalidValueError()))
      return true
    }
    
    guard let hostName = components.first, let uuidString = components.last else {
      delegate.controller(self, scanned: .failure(InvalidValueError()))
      return true
    }
    
    guard let identifier = UUID(uuidString: uuidString) else {
      delegate.controller(self, scanned: .failure(InvalidValueError()))
      return true
    }
    
    
    delegate.controller(self, scanned: .success(SocketConfiguration(identifier: identifier, hostName: hostName)))
    return true
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  

  
  var scanningDelegate : ScanningListener?
  
}
