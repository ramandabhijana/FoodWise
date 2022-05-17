//
//  Courier.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 15/05/22.
//

import Foundation

struct Courier: Codable {
  let id: String
  var name: String
  var bikeBrand: String
  var bikePlate: String
  let email: String
  var profilePictureUrl: URL? = nil
}
