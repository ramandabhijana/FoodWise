//
//  SignInVM.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 30/11/21.
//

import Foundation
import Combine

class SignInViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""
  
  @Published private(set) var emailValid: Bool? = nil
  @Published private(set) var passwordValid: Bool? = nil
  @Published private(set) var signedInMerchant: Merchant? = nil
  @Published private(set) var errorMessage = ""
  @Published private(set) var loadingUser = false
  
  private var cancellables = Set<AnyCancellable>()
  private let authenticationService = AuthenticationService.shared
  private let merchantRepo = MerchantRepository()
  
  init() {
    
  }
  
  public var signInButtonDisabled: Bool {
    guard let emailValid = emailValid,
          let passwordValid = passwordValid else {
      return true
    }
    return !(emailValid && passwordValid)
  }
  
  func signIn() {
    loadingUser = true
    authenticationService.signIn(
      email: email,
      password: password
    ) { [weak self] authResult, error in
      if let error = error {
        self?.loadingUser = false
        self?.errorMessage = error.localizedDescription
      } else if let self = self,
                let user = authResult?.user
      {
        self.getMerchant(withId: user.uid)
          .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
              self.errorMessage = error.localizedDescription
              self.loadingUser = false
              self.authenticationService.signOut()
            }
          }, receiveValue: { merchant in
            self.signedInMerchant = merchant
            self.loadingUser = false
          })
          .store(in: &self.cancellables)
      }
    }
  }
  
  private func getMerchant(withId userId: String) -> AnyPublisher<Merchant, Error> {
    merchantRepo.getMerchant(withId: userId)
  }
  
  func validateEmailIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    emailValid = email.isValidEmail
  }
  
  func validatePasswordIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    passwordValid = password.isStrongPassword
  }
}
