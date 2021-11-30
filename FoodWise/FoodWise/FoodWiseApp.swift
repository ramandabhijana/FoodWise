//
//  FoodWiseApp.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 30/10/21.
//

import SwiftUI
import Firebase

@main
struct FoodWiseApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
//      SignInViewTest()
      
      RootSignedInView()
      
//      SignUpView(viewModel: .init())
//      NearbyView()
//      SignInView()
//      WelcomeView()
//      NearbyMapView()
//      RootSignedInView()
//      HomeView()
//      MerchantHomeView()
//      FoodDetailsView(food: .sampleData.first!)
//      SelectLocationView(viewModel: .init(), onSave: { _, _ in })
//      SelectLocationViewTest()
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
