//
//  DonationRepository.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

import Foundation
import Combine
import FirebaseFirestore

enum DonationStatus: String {
  case available = "Available"
  case booked = "Booked"
  case received = "Received"
}

struct DonationRepository {
  private let db = Firestore.firestore()
  private let path = "donations"
  
  func setDonationStatusToReceived(forDonationWithId donationId: String) -> AnyPublisher<Void, Error> {
    Future { promise in
      let data: [String: Any] = ["status": DonationStatus.received.rawValue]
      db.collection(path).document(donationId)
        .setData(data, merge: true) { error in
          if let error = error { return promise(.failure(error)) }
          return promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
}
