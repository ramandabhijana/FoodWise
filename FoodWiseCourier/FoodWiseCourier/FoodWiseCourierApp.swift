//
//  FoodWiseCourierApp.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 27/11/21.
//

import SwiftUI
import Firebase

@main
struct FoodWiseCourierApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
      MainView(viewModel: .init())
    }
  }
  
//  var rootView: some View {
//    let mainViewModel = MainViewModel()
//    let homeViewModel = HomeViewModel(courierPublisher: mainViewModel.courierPublisher)
//    return MainView(viewModel: .init(), homeViewModel: homeViewModel)
//  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    return true
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    
  }
}

