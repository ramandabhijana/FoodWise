//
//  FoodWiseMerchantApp.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 27/11/21.
//

import SwiftUI
import Firebase

@main
struct FoodWiseMerchantApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
      MainView(viewModel: .init())
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
