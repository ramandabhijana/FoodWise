//
//  FoodWiseApp.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 30/10/21.
//

import SwiftUI

@main
struct FoodWiseApp: App {
  var body: some Scene {
    WindowGroup {
//      SignUpView()
//      NearbyView()
//      SignInView()
//      WelcomeView()
//      NearbyMapView()
//      RootSignedInView()
//      HomeView()
//      MerchantHomeView()
//      FoodDetailsView(food: .sampleData.first!)
      SelectLocationView(viewModel: .init(), onSave: { _, _ in })
//      SelectLocationViewTest()
    }
  }
}
