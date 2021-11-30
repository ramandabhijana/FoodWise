//
//  Merchant.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 29/11/21.
//

import Foundation

struct Merchant: Codable {
  let id: String
  let name: String
  let email: String
  let storeType: String
  let coordinate: [String: Double]
  let addressDetails: String
  var logoUrl: URL? = nil
  
  init(id: String,
       name: String,
       email: String,
       storeType: String,
       coordinate: (lat: Double, long: Double),
       addressDetails: String,
       logoUrl: URL? = nil
  ) {
    self.id = id
    self.name = name
    self.email = email
    self.storeType = storeType
    self.coordinate = ["lat": coordinate.lat, "long": coordinate.long]
    self.addressDetails = addressDetails
    self.logoUrl = logoUrl
  }
  
  init(id: String,
       name: String,
       email: String,
       storeType: String,
       coordinate: [String: Double],
       addressDetails: String,
       logoUrl: URL? = nil
  ) {
    self.id = id
    self.name = name
    self.email = email
    self.storeType = storeType
    self.coordinate = coordinate
    self.addressDetails = addressDetails
    self.logoUrl = logoUrl
  }
}

extension Merchant {
  init?(object: [String: Any]) {
    if let id = object["id"] as? String,
       let name = object["name"] as? String,
       let email = object["email"] as? String,
       let type = object["storeType"] as? String,
       let coordinate = object["coordinate"] as? [String: Double],
       let addressDetails = object["addressDetails"] as? String
    {
      self.init(
        id: id,
        name: name,
        email: email,
        storeType: type,
        coordinate: coordinate,
        addressDetails: addressDetails
      )
      guard let logoUrl = object["logoUrl"] as? String else {
        return
      }
      self.logoUrl = URL(string: logoUrl)
    } else {
      print("\n🚨Fail to init mandatory field with object: \(object)\n")
      return nil
    }
  }
}



