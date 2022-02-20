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
  private static var signInViewModel = SignInViewModel()
  
  init(viewModel: MainViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    setupNavigationBarAppearance()
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
  }
  
  private let signInRequiredPublisher = NotificationCenter.default
    .publisher(for: .signInRequiredNotification)
    .receive(on: RunLoop.main)
  
  var body: some View {
    Group {
      if viewModel.merchant != nil {
        MerchantHomeView()
          .environmentObject(viewModel)
      } else {
        Color.primaryColor
          .ignoresSafeArea()
          .overlay {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle())
          }
      }
    }
    .onAppear(perform: viewModel.postSignInNotificationIfNeeded)
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
  
  private func setupNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = UIColor(named: "PrimaryColor")
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(viewModel: .init())
  }
}

