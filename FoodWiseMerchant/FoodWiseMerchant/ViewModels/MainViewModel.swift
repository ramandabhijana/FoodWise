//
//  MainViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 29/11/21.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
  @Published private(set) var merchant: Merchant!
  
  /*
   Merchant(id: "nwcRFSc67Oga5hBmA5WOyLjOQOk1", name: "Merchant 30 nov 0053", email: "merchant30nov0053@gmail.com", storeType: "Restaurant", location: FoodWiseMerchant.MerchantLocation(lat: -8.636118170509661, long: 115.23453811594203, geocodedLocation: "Jalan Dukuh Denpasar, Bali"), addressDetails: "second floor", logoUrl: Optional(https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/profile_pictures%2FnwcRFSc67Oga5hBmA5WOyLjOQOk1?alt=media&token=2ed31122-0b76-4f66-b525-0101911a87b5))
   */
  
  private let merchantRepo = MerchantRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  init() {
    if let user = AuthenticationService.shared.signedInUser {
      merchantRepo.getMerchant(withId: user.uid)
        .sink { completion in
          if case .failure(let error) = completion {
            print("Error reading customer: \(error)")
          }
        } receiveValue: { [weak self] merchant in
          print("\n\(merchant)\n")
          self?.merchant = merchant
        }
        .store(in: &subscriptions)
    }
    
    // Test Data
//    merchant = Merchant(id: "nwcRFSc67Oga5hBmA5WOyLjOQOk1", name: "Merchant 30 nov 0053", email: "merchant30nov0053@gmail.com", storeType: "Restaurant", location: ["lat": -8.636118170509661, "long": 115.23453811594203, "geocodedLocation": "Jalan Dukuh Denpasar, Bali"], addressDetails: "second floor", logoUrl: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/profile_pictures%2FnwcRFSc67Oga5hBmA5WOyLjOQOk1?alt=media&token=2ed31122-0b76-4f66-b525-0101911a87b5"))
  }
  
  func setMerchant(_ merchant: Merchant) {
    self.merchant = merchant
  }
  
  func postSignInNotificationIfNeeded() {
    if AuthenticationService.shared.currentUserExist == false {
      NotificationCenter.default.post(name: .signInRequiredNotification,
                                      object: nil)
    }
  }
}

extension Notification.Name {
  static let signInRequiredNotification = Notification.Name("SignInRequiredNotification")
}
