//
//  CourierSession.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import Foundation
import FirebaseFirestore

struct CourierSession: Codable {
  let courierId: String
  var location: GeoPoint
  
}
