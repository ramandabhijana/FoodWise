//
//  PhotoZoom+View.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/12/21.
//

import SwiftUI

extension PhotoZoomViewController {
  struct View: UIViewControllerRepresentable {
    let url: URL?
    
    func makeUIViewController(context: Context) -> PhotoZoomViewController {
      return PhotoZoomViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
      
    }
  }
}


