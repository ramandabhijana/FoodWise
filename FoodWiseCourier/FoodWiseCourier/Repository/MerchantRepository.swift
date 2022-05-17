//
//  MerchantRepository.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 15/05/22.
//

import Foundation
import Combine
import FirebaseFirestore

struct MerchantRepository {
  private let db = Firestore.firestore()
  private let path = "merchants"

  init() { }
  
  
}

extension MerchantRepository: ProfileUrlNameFetchableRepository {
  func fetchNameAndProfilePictureUrl(ofUserWithId userId: String) -> AnyPublisher<(name: String, profilePictureUrl: URL?), Error> {
    Future {  promise in
      let docRef = self.db.collection(self.path).document(userId)
      docRef.getDocument { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        if let snapshot = snapshot, snapshot.exists {
          do {
            let merchant = try snapshot.data(as: Merchant.self)
            return promise(.success((merchant.name, merchant.logoUrl)))
          } catch {
            return promise(.failure(error))
          }
        } else {
          let error = NSError(
            domain: "",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve merchant information"]
          )
          return promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
