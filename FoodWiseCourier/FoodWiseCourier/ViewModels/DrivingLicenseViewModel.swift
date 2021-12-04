//
//  DrivingLicenseViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 29/11/21.
//

import Foundation
import Combine

class DrivingLicenseViewModel: ObservableObject {
  @Published var imageData: Data? = nil
  @Published var licenseNo = ""
  
  @Published private(set) var licenseNoValid: Bool? = nil
  private(set) var imageUrl: URL? = nil
  
  init(imageUrl: URL? = nil, licenseNo: String = "") {
    self.imageUrl = imageUrl
    self.licenseNo = licenseNo
  }
  
  public var signUpButtonDisabled: Bool {
    guard let licenseNoValid = licenseNoValid else {
      return true
    }
    return !(licenseNoValid && imageDataExists)
  }
  
  private var imageDataExists: Bool { imageData != nil }
  
  func validateLicenseNoIfFocusIsLost(focus: Bool) {
    guard focus == false else { return }
    licenseNoValid = (licenseNo.count == 12) && (Int(licenseNo) != nil)
  }
  
}
