//
//  Merchant.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 15/05/22.
//

import Foundation
import CoreLocation

struct Merchant: Codable {
  let id: String
  let name: String
  let email: String
  let storeType: String
  var logoUrl: URL? = nil
}
