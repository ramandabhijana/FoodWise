//
//  Donation.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/03/22.
//

import Foundation
import FirebaseFirestore

struct Donation: Codable, Identifiable, Hashable {
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
  
  init(date: Date, pictureUrl: URL?, kind: SharedFoodKind, foodName: String, pickupLocation: Address, notes: String, donorId: String, receiverUserId: String? = nil, status: DonationStatus = .available, adoptionRequests: [AdoptionRequest] = []) {
    self.id = UUID().uuidString
    self.date = Timestamp(date: date)
    self.pictureUrl = pictureUrl
    self.kind = kind.appropriateFor
    self.foodName = foodName
    self.pickupLocation = pickupLocation
    self.notes = notes
    self.donorId = donorId
    self.receiverUserId = receiverUserId
    self.status = status.rawValue
    self.adoptionRequests = adoptionRequests
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: Donation, rhs: Donation) -> Bool {
    lhs.id == rhs.id
  }
  
  var kindValue: SharedFoodKind {
    switch kind {
    case SharedFoodKind.animalFeed.appropriateFor:
      return SharedFoodKind.animalFeed
    case SharedFoodKind.compostable.appropriateFor:
      return SharedFoodKind.compostable
    case SharedFoodKind.edible.appropriateFor:
      return SharedFoodKind.edible
    default:
      return SharedFoodKind.all
    }
  }
  
  static var asPlaceholderInstance: Donation {
    .init(date: .now, pictureUrl: nil, kind: .all, foodName: "Food name", pickupLocation: .init(location: .init(), geocodedLocation: "Location", details: ""), notes: "", donorId: "")
  }
}

enum DonationStatus: String {
  case available = "Available"
  case booked = "Booked"
  case received = "Received"
}
