//
//  String+.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 27/11/21.
//

import Foundation

public extension String {
  var isValidEmail: Bool {
    let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluate(with: self)
  }
  
  var isStrongPassword: Bool {
    let strongFormat = "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$"
    let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", strongFormat)
    return passwordPredicate.evaluate(with: self)
  }
}

extension StringProtocol {
  var firstUppercased: String { return prefix(1).uppercased() + dropFirst().lowercased() }
  var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}

public let kCustomerType = "CUSTOMER"
public let kCourierType = "COURIER"
public let kMerchantType = "MERCHANT"
