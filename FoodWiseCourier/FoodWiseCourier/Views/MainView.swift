//
//  MainView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 30/11/21.
//

import SwiftUI

struct MainView: View {
  @State private var presentingSignInView = false
  @StateObject private var viewModel: MainViewModel
  private static var signInViewModel = SignInViewModel()
  
  private let signInRequiredPublisher = NotificationCenter.default
    .publisher(for: .signInRequiredNotification)
    .receive(on: RunLoop.main)
  
  init(viewModel: MainViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    Group {
      if viewModel.courier != nil {
        HomeView()
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
          viewModel.setCourier($0)
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
