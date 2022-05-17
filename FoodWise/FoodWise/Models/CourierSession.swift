//
//  CourierSession.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 14/04/22.
//

import Foundation
import FirebaseFirestore
import GeoFireUtils

struct CourierSession: Codable {
  let courierId: String
  var isBusy: Bool
  var location: GeoPoint {
    didSet {
      GFUtils.geoHash(forLocation: CLLocationCoordinate2D(
        latitude: location.latitude,
        longitude: location.longitude))
    }
  }
  private(set) var geohash: String
  var deliveryTask: DeliveryTask? {
    willSet { self.deliveryTaskId = newValue?.taskId }
  }
  var deliveryTaskId: String?
  
  init(courierId: String,
       isBusy: Bool = false,
       location: CLLocationCoordinate2D,
       deliveryTask: DeliveryTask? = nil) {
    self.courierId = courierId
    self.isBusy = isBusy
    self.location = GeoPoint(latitude: location.latitude,
                             longitude: location.longitude)
    self.geohash = GFUtils.geoHash(forLocation: location)
    self.deliveryTask = deliveryTask
  }
}
