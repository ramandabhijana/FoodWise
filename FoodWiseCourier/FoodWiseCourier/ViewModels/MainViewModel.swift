//
//  MainViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 30/11/21.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
  @Published private(set) var courier: Courier!
  
  private let courierRepo = CourierRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  var courierPublisher: AnyPublisher<Courier, Never> {
    $courier.compactMap({ $0 }).eraseToAnyPublisher()
  }
  
  init() {
    if let user = AuthenticationService.shared.signedInUser {
      courierRepo.getCourier(withId: user.uid)
        .sink { [weak self] completion in
          if case .failure(let error) = completion {
            print("Error reading customer: \(error)")
            AuthenticationService.shared.signOut()
            self?.postSignInNotificationIfNeeded()
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
