//
//  DeliveryTask.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 14/04/22.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct DeliveryTask: Codable {
  let taskId: String
  let pickupAddress: Address
  let dropOffAddress: Address
  let totalDistance: Double
  let totalTravelTime: Double
  let serviceWage: Double
  let order: Order?
  let donation: Donation?
  let requesterId: String
  let requesterProfilePicUrl: String
  let requesterName: String
  let requesterType: String
  let requestedDate: Timestamp
  var deadlineCourierConfirmation: Timestamp?
  var status: [DeliveryStatus]?
  
  init(pickupAddress: Address, dropOffAddress: Address, totalDistance: Double, totalTravelTime: Double, donation: Donation, serviceWage: Double, requesterId: String, requesterProfilePicUrl: String, requesterName: String) {
    self.taskId = UUID().uuidString
    self.pickupAddress = pickupAddress
    self.dropOffAddress = dropOffAddress
    self.totalDistance = totalDistance
    self.totalTravelTime = totalTravelTime
    self.serviceWage = serviceWage
    self.order = nil
    self.donation = donation
    self.requesterId = requesterId
    self.requesterProfilePicUrl = requesterProfilePicUrl
    self.requesterName = requesterName
    self.requesterType = kCustomerType
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
     "donation": donation?.asObject as Any,
     "requesterId": requesterId,
     "requesterProfilePicUrl": requesterProfilePicUrl,
     "requesterName": requesterName,
     "requesterType": requesterType,
     "requestedDate": requestedDate,
     "deadlineCourierConfirmation": deadlineCourierConfirmation as Any,
     "status": status?.map(\.asObject) as Any
    ]
  }
  
  var deadlineConfirmationDate: Date? {
    deadlineCourierConfirmation?.dateValue()
  }
}

struct DeliveryStatus: Codable {
  var status: String
  var date: Timestamp?
  
  var formattedDate: String {
    guard let date = date else {
      return "-"
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
    return formatter.string(from: date.dateValue())
  }
  
  init(status: Status, date: Date? = nil) {
    self.status = status.rawValue
    if let date = date {
      self.date = Timestamp(date: date)
    } else {
      self.date = nil
    }
  }
  
  var asObject: [String: Any] {
    ["status": status,
     "date": date as Any
    ]
  }
  
  var statusValue: Status? { Status(rawValue: status) }
  
  enum Status: String {
    case requestAccepted = "Request Accepted"
    case itemsPickedUp = "Items Picked up"
    case received = "Received by Customer"
    
    var index: Int {
      switch self {
      case .requestAccepted: return 0
      case .itemsPickedUp: return 1
      case .received: return 2
      }
    }
  }
}
