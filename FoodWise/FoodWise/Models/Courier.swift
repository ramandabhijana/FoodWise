//
//  Courier.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 14/04/22.
//

import Foundation

struct Courier: Codable {
  let id: String
  var name: String
  var bikeBrand: String
  var bikePlate: String
  let email: String
  var license: DrivingLicense
  var profilePictureUrl: URL? = nil
}
