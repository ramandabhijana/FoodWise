//
//  MainViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 30/11/21.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
  @Published private(set) var courier: Courier?
  
  private let courierRepo = CourierRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  init() {
    if let user = AuthenticationService.shared.signedInUser {
      courierRepo.getCourier(withId: user.uid)
        .sink { completion in
          if case .failure(let error) = completion {
            print("Error reading customer: \(error)")
          }
        } receiveValue: { [weak self] courier in
          self?.courier = courier
        }
        .store(in: &subscriptions)
    }
  }
  
  func setCourier(_ courier: Courier) {
    self.courier = courier
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
