//
//  AdoptionRequest.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/03/22.
//

import Foundation
import FirebaseFirestore

struct AdoptionRequest: Codable, Identifiable, Equatable {
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
  
  static func == (lhs: AdoptionRequest, rhs: AdoptionRequest) -> Bool {
    lhs.id == rhs.id
  }
}

protocol ObjectRepresentable {
  var asObject: [String: Any] { get }
}

extension ObjectRepresentable {
  var asObject: [String: Any] {
    let mirror = Mirror(reflecting: self)
    let dict = Dictionary<String, Any>(
      uniqueKeysWithValues: mirror.children.lazy
        .map { label, value in
          guard let label = label else { return nil }
          return (label, value)
        }
        .compactMap { $0 }
    )
    return dict
  }
}
