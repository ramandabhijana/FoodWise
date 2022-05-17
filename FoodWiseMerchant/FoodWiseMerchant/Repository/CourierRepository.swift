//
//  CourierRepository.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 15/05/22.
//

import Foundation
import FirebaseFirestore
import Combine

final class CourierRepository {
  private let db = Firestore.firestore()
  private let path = "couriers"
  
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    
  }
}

extension CourierRepository: ProfileUrlNameFetchableRepository {
  func fetchNameAndProfilePictureUrl(ofUserWithId userId: String) -> AnyPublisher<(name: String, profilePictureUrl: URL?), Error> {
    Future {  promise in
      let docRef = self.db.collection(self.path).document(userId)
      docRef.getDocument { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        if let snapshot = snapshot, snapshot.exists {
          do {
            let courier = try snapshot.data(as: Courier.self)
            return promise(.success((courier.name, courier.profilePictureUrl)))
          } catch {
            return promise(.failure(error))
          }
        } else {
          let error = NSError(
            domain: "",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve courier information"]
          )
          return promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
