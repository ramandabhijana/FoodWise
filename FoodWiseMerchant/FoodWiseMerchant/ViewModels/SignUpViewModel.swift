//
//  SignUpViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 29/11/21.
//

import Foundation
import Combine

class SignUpViewModel: ObservableObject {
  @Published var profileImageData: Data? = nil
  @Published var name = ""
  @Published var storeType = ""
  @Published var email = ""
  @Published var password = ""
  var address: (location: MerchantLocation, details: String)? = nil
  
  @Published private(set) var nameValid: Bool? = nil
  @Published private(set) var emailValid: Bool? = nil
  @Published private(set) var passwordValid: Bool? = nil
  @Published private(set) var storeTypeValid: Bool? = nil
  @Published private(set) var addressValid: Bool? = nil
  
  @Published private(set) var errorMessage = ""
  @Published private(set) var loadingUser = false
  @Published private(set) var signedInMerchant: Merchant? = nil
  
  private let merchantRepo = MerchantRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  public var signUpButtonDisabled: Bool {
    guard let nameValid = nameValid,
          let emailValid = emailValid,
          let passwordValid = passwordValid,
          let storeTypeValid = storeTypeValid,
          let addressValid = addressValid else {
      return true
    }
    return !(nameValid && emailValid && passwordValid && storeTypeValid && addressValid)
  }
  
  
  func signUp() {
    precondition(addressValid == true)
    loadingUser = true
    AuthenticationService.shared.registerUser(
      withEmail: email,
      password: password
    ) { [weak self] authResult, error in
      if let error = error {
        self?.loadingUser = false
        self?.errorMessage = error.localizedDescription
      } else if let self = self,
                let userInfo = authResult?.additionalUserInfo,
                userInfo.isNewUser {
        self.merchantRepo.createMerchant(
          userId: (authResult?.user.uid)!,
          name: self.name,
          storeType: self.storeType,
          email: self.email,
          password: self.password,
          location: self.address!.location,
          addressDetails: self.address!.details,
          imageData: self.profileImageData
        )
        .sink(receiveCompletion: { completion in
          if case .failure(let error) = completion {
            self.errorMessage = error.localizedDescription
            self.loadingUser = false
          }
        }, receiveValue: { merchant in
          self.signedInMerchant = merchant
          self.loadingUser = false
        })
        .store(in: &self.subscriptions)
      }
    }
  }
  
  func validateEmailIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    emailValid = email.isValidEmail
  }
  
  func validatePasswordIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    passwordValid = password.isStrongPassword
  }
  
  func validateNameIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    nameValid = !name.isEmpty
  }
  
  func validateStoreTypeIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    storeTypeValid = !storeType.isEmpty
  }
  
  func validateAddressIfFocusIsLost(focus: Bool) {
    guard focus == false else { return }
    addressValid = address != nil
  }
}
