//
//  QRScanViewController+SwiftUI.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

import SwiftUI
import Combine

extension QRScanViewController {
  struct View<ViewModel: QRScanViewControllerDelegate & ObservableObject>: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ViewModel
    
    func makeUIViewController(context: Context) -> QRScanViewController {
      let viewController = QRScanViewController()
      viewController.delegate = viewModel
      return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
      
    }
  }
}

