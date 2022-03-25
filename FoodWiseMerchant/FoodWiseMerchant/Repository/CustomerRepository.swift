//
//  CustomerRepository.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 06/03/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class CustomerRepository {
  private let db = Firestore.firestore()
  private let path = "customers"
  
  init() {
    
  }
}

extension CustomerRepository: ProfileUrlNameFetchableRepository {
  func fetchNameAndProfilePictureUrl(ofUserWithId userId: String) -> AnyPublisher<(name: String, profilePictureUrl: URL?), Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let docRef = self.db.collection(self.path).document(userId)
      docRef.getDocument { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        if let snapshot = snapshot,
           snapshot.exists,
           let customer = snapshot.data().flatMap(Customer.init(object:))
        {
          return promise(.success((customer.fullName, customer.profileImageUrl)))
        } else {
          let error = NSError(
            domain: "",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve customer information"]
          )
          return promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
