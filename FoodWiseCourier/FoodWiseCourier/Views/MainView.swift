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
  @StateObject private var drawerStateManager = DrawerStateManager()
  private static var signInViewModel = SignInViewModel()
  
  private let signInRequiredPublisher = NotificationCenter.default
    .publisher(for: .signInRequiredNotification)
    .receive(on: RunLoop.main)
  
  init(viewModel: MainViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
  }
  
  var body: some View {
    Group {
      if viewModel.courier != nil {
        HStack(spacing: 0) {
          DrawerView(manager: drawerStateManager)
          ZStack {
            /*
            switch drawerStateManager.selectedMenu {
            case .home:
              HomeView(viewModel: .init())
                .frame(width: UIScreen.main.bounds.width)
            case .chat:
              EmptyView()
            case .tasks:
              EmptyView()
            case .wallet:
              EmptyView()
            }
             */
            HomeView(viewModel: .init())
          }
          .frame(width: UIScreen.main.bounds.width)
          .environmentObject(drawerStateManager)
          
          .overlay {
            Group {
              drawerStateManager.showingView
              ? Color.black.opacity(0.5)
              : .clear
            }
            .ignoresSafeArea()
            .onTapGesture {
              if drawerStateManager.showingView {
                drawerStateManager.hideView()
              }
            }
          }
        }
        .frame(width: UIScreen.main.bounds.width)
        .offset(x: drawerStateManager.showingView ? 125 : -125)
        .animation(.easeInOut, value: drawerStateManager.showingView)
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
//    .onAppear(perform: viewModel.postSignInNotificationIfNeeded)
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

/*
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
*/
