//
//  Customer.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 15/04/22.
//

import Foundation

struct Customer: Codable {
  let id: String
  var fullName: String
  let email: String
  var profileImageUrl: URL? = nil
  
  var asObject: [String: Any] {
    ["id": id,
     "fullName": fullName,
     "email": email,
     "profileImageUrl": profileImageUrl?.absoluteString as Any]
  }
}
