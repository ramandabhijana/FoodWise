//
//  VNDocumentCameraVC+.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 29/11/21.
//

import SwiftUI
import VisionKit

extension VNDocumentCameraViewController {
  struct View {
    @Binding var imageData: Data?
  }
}

// MARK: - UIViewControllerRepresentable
extension VNDocumentCameraViewController.View: UIViewControllerRepresentable {
  func makeCoordinator() -> some VNDocumentCameraViewControllerDelegate {
    VNDocumentCameraViewController.Delegate(imageData: $imageData)
  }
  
  func makeUIViewController(context: Context) -> some UIViewController {
    let controller = VNDocumentCameraViewController()
    controller.delegate = context.coordinator
    return controller
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

extension VNDocumentCameraViewController.Delegate: VNDocumentCameraViewControllerDelegate {
  func documentCameraViewController(
    _ controller: VNDocumentCameraViewController,
    didFinishWith scan: VNDocumentCameraScan
  ) {
    let lastPage = scan.pageCount - 1
    let data = scan.imageOfPage(at: lastPage).jpegData(compressionQuality: 0.5)
    DispatchQueue.main.async { [weak self] in
      self?.imageData = data
    }
    controller.dismiss(animated: true)
  }
}

private extension VNDocumentCameraViewController {
  final class Delegate: NSObject {
    @Binding var imageData: Data?
    
    init(imageData: Binding<Data?>) {
      self._imageData = imageData
    }
  }
}
