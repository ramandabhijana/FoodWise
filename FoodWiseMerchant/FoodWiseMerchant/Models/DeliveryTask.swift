//
//  DeliveryTask.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 06/04/22.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct DeliveryTask: Codable {
  let taskId: String
  let pickupAddress: ShippingAddress
  let dropOffAddress: ShippingAddress
  let totalDistance: Double
  let totalTravelTime: Double
  let serviceWage: Double
  let order: Order?
  let requesterId: String
  let requesterProfilePicUrl: String
  let requesterName: String
  let requesterType: String
  let requestedDate: Timestamp
  var deadlineCourierConfirmation: Timestamp?
  
  init(pickupAddress: ShippingAddress, dropOffAddress: ShippingAddress, totalDistance: Double, totalTravelTime: Double, order: Order, requesterId: String, requesterProfilePicUrl: String, requesterName: String) {
    self.taskId = UUID().uuidString
    self.pickupAddress = pickupAddress
    self.dropOffAddress = dropOffAddress
    self.totalDistance = totalDistance
    self.totalTravelTime = totalTravelTime
    self.serviceWage = order.deliveryCharge
    self.order = order
    self.requesterId = requesterId
    self.requesterProfilePicUrl = requesterProfilePicUrl
    self.requesterName = requesterName
    self.requesterType = kMerchantType
    self.requestedDate = Timestamp(date: .now)
    let deadline = Date.now + 32
    self.deadlineCourierConfirmation = Timestamp(date: deadline)
  }
  
  var asObject: [String: Any] {
    ["taskId": taskId,
     "pickupAddress": pickupAddress.asObject,
     "dropOffAddress": dropOffAddress.asObject,
     "totalDistance": totalDistance,
     "totalTravelTime": totalTravelTime,
     "serviceWage": serviceWage,
     "order": order?.asObject as Any,
     "requesterId": requesterId,
     "requesterProfilePicUrl": requesterProfilePicUrl,
     "requesterName": requesterName,
     "requesterType": requesterType,
     "requestedDate": requestedDate,
     "deadlineCourierConfirmation": deadlineCourierConfirmation as Any
    ]
  }
  
  var deadlineConfirmationDate: Date? {
    deadlineCourierConfirmation?.dateValue()
  }
}
