//
//  Address.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 08/03/22.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct Address: Codable {
  var geopoint: GeoPoint
  var geocodedLocation: String
  var details: String
  
  init(location: CLLocationCoordinate2D, geocodedLocation: String, details: String) {
    self.geopoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
    self.geocodedLocation = geocodedLocation
    self.details = details.isEmpty ? "-" : details
  }
  
  var clLocation: CLLocation {
    CLLocation(latitude: geopoint.latitude, longitude: geopoint.longitude)
  }
  
  var asObject: [String: Any] {
    ["geopoint": geopoint,
     "geocodedLocation": geocodedLocation,
     "details": details
    ]
  }
}
