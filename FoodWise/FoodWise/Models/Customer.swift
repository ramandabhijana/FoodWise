//
//  Customer.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 27/11/21.
//

import Foundation

struct Customer: Codable {
  let id: String
  var fullName: String
  let email: String
  var profileImageUrl: URL? = nil
  var foodRescuedCount: Int?
  var foodSharedCount: Int?
}

extension Customer {
  init?(object: [String: Any]) {
    if let id = object["id"] as? String,
       let fullName = object["fullName"] as? String,
       let email = object["email"] as? String,
       let foodRescuedCount = object["foodRescuedCount"] as? Int,
       let foodSharedCount = object["foodSharedCount"] as? Int
    {
      self.init(id: id,
                fullName: fullName,
                email: email,
                foodRescuedCount: foodRescuedCount,
                foodSharedCount: foodSharedCount)
      guard let profileImageUrl = object["profileImageUrl"] as? String else {
        return
      }
      self.profileImageUrl = URL(string: profileImageUrl)
    } else {
      print("\n🚨Fail to init mandatory field with object: \(object)\n")
      return nil
    }
  }
}

extension Customer {
  var asObject: [String: Any] {
    ["id": id,
     "fullName": fullName,
     "email": email,
     "profileImageUrl": profileImageUrl?.absoluteString as Any,
     "foodRescuedCount": foodRescuedCount,
     "foodSharedCount": foodSharedCount]
  }
}
