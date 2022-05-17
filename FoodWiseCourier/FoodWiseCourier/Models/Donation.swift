//
//  Donation.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 11/04/22.
//

import Foundation
import FirebaseFirestore

struct Donation: Codable, Identifiable {
  let id: String
  let date: Timestamp
  let pictureUrl: URL?
  let kind: String
  let foodName: String
  let pickupLocation: Address
  let notes: String
  let donorId: String
  var receiverUserId: String?
  var status: String
  var adoptionRequests: [AdoptionRequest]
  var shippingAddress: Address
  var deliveryCharge: Double
//  var deliveryTaskId: String
  
  var asObject: [String: Any] {
    ["id": id,
     "date": date,
     "pictureUrl": pictureUrl?.absoluteString as Any,
     "kind": kind,
     "foodName": foodName,
     "pickupLocation": pickupLocation.asObject,
     "notes": notes,
     "donorId": donorId,
     "receiverUserId": receiverUserId as Any,
     "status": status,
     "adoptionRequests": adoptionRequests.map(\.asObject),
     "shippingAddress": shippingAddress.asObject,
     "deliveryCharge": deliveryCharge
//     "deliveryTaskId": deliveryTaskId
    ]
  }
  
}

struct AdoptionRequest: Codable {
  let id: String
  let date: Timestamp
  let messageForDonor: String
  let requesterCustomer: Customer
  
  init(messageForDonor: String, requesterCustomer: Customer) {
    self.id = UUID().uuidString
    self.date = Timestamp(date: .now)
    self.messageForDonor = messageForDonor
    self.requesterCustomer = requesterCustomer
  }
  
  var asObject: [String: Any] {
    ["id": id,
     "date": date,
     "messageForDonor": messageForDonor,
     "requesterCustomer": requesterCustomer.asObject]
  }
}
