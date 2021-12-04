//
//  CustomerRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 27/11/21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class CustomerRepository: ObservableObject {
  private let db = Firestore.firestore()
  private let path = "customers"
  private let authenticationService = AuthenticationService.shared
  private let storageService = StorageService.shared
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    
  }
  
  func createCustomer(
    userId: String,
    name: String,
    email: String,
    imageData: Data? = nil
  ) -> AnyPublisher<Customer, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      var newCustomer = Customer(
        id: userId,
        fullName: name,
        email: email
      )
      if let imageData = imageData {
        // Upload picture and get the url
        let filename = newCustomer.id
        self.storageService.uploadPictureData(
          imageData,
          path: .profilePictures(fileName: filename)
        )
        .flatMap { url -> AnyPublisher<Customer, Error> in
          newCustomer.profileImageUrl = url
          return self.upsertCustomer(newCustomer)
        }
        .sink { completion in
          if case .failure(let error) = completion {
            return promise(.failure(error))
          }
        } receiveValue: { _ in
          return promise(.success(newCustomer))
        }
        .store(in: &self.cancellables)
        
      } else {
        // No profile picture data
        self.upsertCustomer(newCustomer)
          .sink { completion in
            if case .failure(let error) = completion {
              return promise(.failure(error))
            }
          } receiveValue: { _ in
            return promise(.success(newCustomer))
          }
          .store(in: &self.cancellables)
      }
    }
    .eraseToAnyPublisher()
  }
  
  func getCustomer(withId id: String) -> AnyPublisher<Customer, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let docRef = self.db.collection(self.path).document(id)
      docRef.getDocument { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        if let snapshot = snapshot,
           snapshot.exists,
           let customer = snapshot.data().flatMap(Customer.init(object:))
        {
          return promise(.success(customer))
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
  
  func updateCustomer(_ customer: Customer) -> AnyPublisher<Customer, Error> {
    upsertCustomer(customer, merge: true)
  }
  
  private func upsertCustomer(_ customer: Customer, merge: Bool = false) -> AnyPublisher<Customer, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      do {
        try self.db.collection(self.path)
          .document(customer.id)
          .setData(from: customer)
        promise(.success(customer))
      } catch let error {
        promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }
}
