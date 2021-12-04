//
//  SignUpViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 27/11/21.
//

import Foundation
import Combine

class SignUpViewModel: ObservableObject {
  @Published var profileImageData: Data? = nil
  @Published var fullName = ""
  @Published var email = ""
  @Published var password = ""
  
  @Published private(set) var fullNameValid: Bool? = nil
  @Published private(set) var emailValid: Bool? = nil
  @Published private(set) var passwordValid: Bool? = nil
  @Published private(set) var errorMessage = ""
  @Published private(set) var loadingUser = false
  @Published private(set) var signedInCustomer: Customer? = nil
  
  private let customerRepo = CustomerRepository()
  private let authenticationService = AuthenticationService.shared
  private var subscriptions = Set<AnyCancellable>()
  
  public var signUpButtonDisabled: Bool {
    guard let fullNameValid = fullNameValid,
          let emailValid = emailValid,
          let passwordValid = passwordValid else {
      return true
    }
    return !(fullNameValid && emailValid && passwordValid)
  }
  
  init() {
    
  }
  
  func signUp() {
    loadingUser = true
    authenticationService.registerUser(
      withEmail: email,
      password: password
    ) { [weak self] authResult, error in
      if let error = error {
        self?.loadingUser = false
        self?.errorMessage = error.localizedDescription
      } else if let self = self,
                let userInfo = authResult?.additionalUserInfo,
                userInfo.isNewUser {
        self.customerRepo.createCustomer(
          userId: (authResult?.user.uid)!,
          name: self.fullName,
          email: self.email,
          imageData: self.profileImageData
        )
        .sink(receiveCompletion: { completion in
          if case .failure(let error) = completion {
            self.errorMessage = error.localizedDescription
            self.loadingUser = false
          }
        }, receiveValue: { customer in
          self.signedInCustomer = customer
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
  
  func validateFullNameIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    fullNameValid = !fullName.isEmpty
  }
}
