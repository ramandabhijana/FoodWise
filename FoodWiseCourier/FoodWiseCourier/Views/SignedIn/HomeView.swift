//
//  HomeView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 30/11/21.
//

import SwiftUI

struct HomeView: View {
  var body: some View {
    VStack {
      Button("Sign Out") {
        AuthenticationService.shared.signOut()
        NotificationCenter.default.post(name: .signInRequiredNotification,
                                        object: nil)
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
