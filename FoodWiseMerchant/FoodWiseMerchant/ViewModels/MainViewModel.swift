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
          self?.merchant = merchant
        }
        .store(in: &subscriptions)
    } 
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
