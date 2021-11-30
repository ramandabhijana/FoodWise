//
//  SignUpViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 29/11/21.
//

import Foundation
import Combine

class SignUpViewModel: ObservableObject {
  @Published var profileImageData: Data? = nil
  @Published var fullName = ""
  @Published var bikeBrand = ""
  @Published var bikePlate = ""
  @Published var email = ""
  @Published var password = ""
  
  var license: (imageData: Data, licenseNo: String)? = nil
  
  @Published private(set) var nameValid: Bool? = nil
  @Published private(set) var bikeBrandValid: Bool? = nil
  @Published private(set) var bikePlateValid: Bool? = nil
  @Published private(set) var licenseValid: Bool? = nil
  @Published private(set) var emailValid: Bool? = nil
  @Published private(set) var passwordValid: Bool? = nil
  
  @Published private(set) var errorMessage = ""
  @Published private(set) var loadingUser = false
  @Published private(set) var signedInCourier: Courier?
  
  private let courierRepo = CourierRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  public var signUpButtonDisabled: Bool {
    guard let nameValid = nameValid,
          let emailValid = emailValid,
          let passwordValid = passwordValid,
          let bikeBrandValid = bikeBrandValid,
          let bikePlateValid = bikePlateValid,
          let licenseValid = licenseValid else {
      return true
    }
    return !(nameValid && emailValid && passwordValid && bikeBrandValid && bikePlateValid && licenseValid)
  }
  
  func signUp() {
    precondition(licenseValid == true)
    loadingUser = true
    AuthenticationService.shared.registerUser(
      withEmail: email,
      password: password
    ) { [weak self] authResult, error in
      guard error == nil else {
        self?.loadingUser = false
        self?.errorMessage = error!.localizedDescription
        return
      }
      guard let self = self,
            let userInfo = authResult?.additionalUserInfo,
            userInfo.isNewUser
      else { return }
      self.courierRepo.createCourier(
        userId: (authResult?.user.uid)!,
        name: self.fullName,
        bikeBrand: self.bikeBrand,
        bikePlate: self.bikePlate,
        email: self.email,
        password: self.password,
        licenseImageData: self.license!.imageData,
        licenseNo: self.license!.licenseNo,
        profileImageData: self.profileImageData
      )
      .sink { completion in
        if case .failure(let error) = completion {
          self.errorMessage = error.localizedDescription
          self.loadingUser = false
        }
      } receiveValue: { courier in
        self.signedInCourier = courier
        self.loadingUser = false
      }
      .store(in: &self.subscriptions)
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
    nameValid = !fullName.isEmpty
  }
  
  func validateBikeBrandIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    bikeBrandValid = !bikeBrand.isEmpty
  }
  
  func validateBikePlateIfFocusIsLost(focus: Bool) {
    guard focus == false else { return }
    bikePlateValid = !bikePlate.isEmpty
  }
  
  func validateLicenseIfFocusIsLost(focus: Bool) {
    guard focus == false else { return }
    licenseValid = license != nil
  }
}

