//
//  Merchant.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 29/11/21.
//

import Foundation
import CoreLocation

struct Merchant: Codable {
  let id: String
  let name: String
  let email: String
  let storeType: String
  let location: MerchantLocation
  let addressDetails: String
  var logoUrl: URL? = nil
  
  init(id: String,
       name: String,
       email: String,
       storeType: String,
       location: MerchantLocation,
       addressDetails: String,
       logoUrl: URL? = nil
  ) {
    self.id = id
    self.name = name
    self.email = email
    self.storeType = storeType
    self.location = location
    self.addressDetails = addressDetails
    self.logoUrl = logoUrl
  }
  
  init(id: String,
       name: String,
       email: String,
       storeType: String,
       location: [String: Any],
       addressDetails: String,
       logoUrl: URL? = nil
  ) {
    self.id = id
    self.name = name
    self.email = email
    self.storeType = storeType
    self.location = MerchantLocation(object: location)!
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
       let location = object["location"] as? [String: Any],
       let addressDetails = object["addressDetails"] as? String
    {
      self.init(
        id: id,
        name: name,
        email: email,
        storeType: type,
        location: location,
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

struct MerchantLocation: Codable, Equatable {
  var lat: Double
  var long: Double
  var geocodedLocation: String
  
  internal init(lat: Double, long: Double, geocodedLocation: String) {
    self.lat = lat
    self.long = long
    self.geocodedLocation = geocodedLocation
  }
  
  init?(object: [String: Any]) {
    if let lat = object["lat"] as? Double,
       let long = object["long"] as? Double,
       let geocoded = object["geocodedLocation"] as? String
    {
      self.init(lat: lat, long: long, geocodedLocation: geocoded)
    } else {
      print("\n🚨Fail to init mandatory field with object: \(object)\n")
      return nil
    }
  }
  
  var coordinate: CLLocationCoordinate2D { .init(latitude: lat, longitude: long) }
  
  var asObject: [String: Any] {
    ["lat": lat,
     "long": long,
     "geocodedLocation": geocodedLocation]
  }
  
  static func ==(lhs: MerchantLocation, rhs: MerchantLocation) -> Bool {
    lhs.long == rhs.long
    && lhs.lat == rhs.lat
    && lhs.geocodedLocation == rhs.geocodedLocation
  }
}

