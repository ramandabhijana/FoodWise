//
//  UIImagePickerController.View.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/03/22.
//

import UIKit
import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
  @Binding var selectedImageData: Data?
  @Environment(\.presentationMode) var presentationMode
  var sourceType: UIImagePickerController.SourceType
  
  func makeUIViewController(context: Context) -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = self.sourceType
    imagePicker.delegate = context.coordinator
    return imagePicker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(picker: self)
  }
}

extension ImagePickerView {
  class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    
    init(picker: ImagePickerView) {
      self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      guard let selectedImage = info[.originalImage] as? UIImage else { return }
      self.picker.selectedImageData = selectedImage.pngData() ?? selectedImage.jpegData(compressionQuality: 0.5)
      self.picker.presentationMode.wrappedValue.dismiss()
    }
    
  }
}
