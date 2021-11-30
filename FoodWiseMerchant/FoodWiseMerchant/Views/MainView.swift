//
//  MainView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 29/11/21.
//

import SwiftUI

struct MainView: View {
  @State private var presentingSignInView = false
  @StateObject private var viewModel: MainViewModel
  
  init(viewModel: MainViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  private let signInRequiredPublisher = NotificationCenter.default
    .publisher(for: .signInRequiredNotification)
    .receive(on: RunLoop.main)
  
  var body: some View {
    Group {
      if let merchant = viewModel.merchant {
        MerchantHomeView()
      } else {
        SignInView(
          viewModel: .init(),
          onReceiveMerchant: viewModel.setMerchant
        )
      }
    }
    .onReceive(signInRequiredPublisher) { _ in
      presentingSignInView = true
    }
    .fullScreenCover(isPresented: $presentingSignInView) {
      LazyView(
        SignInView(viewModel: .init()) {
          viewModel.setMerchant($0)
          presentingSignInView = false
        }
      )
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(viewModel: .init())
  }
}

