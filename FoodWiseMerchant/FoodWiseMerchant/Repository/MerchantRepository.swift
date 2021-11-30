//
//  MerchantRepository.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 29/11/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class MerchantRepository {
  private let db = Firestore.firestore()
  private let path = "merchants"
  
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    
  }
  
  // name: String,
//email: String,
//storeType: String,
//coordinate: (lat: Double, long: Double),
//addressDetails: Strin
  
  func createMerchant(
    userId: String,
    name: String,
    storeType: String,
    email: String,
    password: String,
    coordinate: (lat: Double, long: Double),
    addressDetails: String,
    imageData: Data?
  ) -> AnyPublisher<Merchant, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      var newMerchant = Merchant(
        id: userId,
        name: name,
        email: email,
        storeType: storeType,
        coordinate: coordinate,
        addressDetails: addressDetails
      )
      if let imageData = imageData {
        let fileName = newMerchant.id
        StorageService.shared
          .uploadPictureData(imageData, path: .profilePictures(fileName: fileName))
          .flatMap { url -> AnyPublisher<Void, Error> in
            newMerchant.logoUrl = url
            return self.addMerchant(newMerchant)
          }
          .sink { completion in
            if case .failure(let error) = completion {
              return promise(.failure(error))
            }
          } receiveValue: { _ in
            return promise(.success(newMerchant))
          }
          .store(in: &self.cancellables)
      } else {
        self.addMerchant(newMerchant)
          .sink { completion in
            if case .failure(let error) = completion {
              return promise(.failure(error))
            }
          } receiveValue: { _ in
            return promise(.success(newMerchant))
          }
          .store(in: &self.cancellables)
      }
    }.eraseToAnyPublisher()
  }
  
  private func addMerchant(_ merchant: Merchant) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      do {
        try self.db.collection(self.path).document(merchant.id).setData(from: merchant)
        return promise(.success(Void()))
      } catch let error {
        return promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }
  
  func getMerchant(withId id: String) -> AnyPublisher<Merchant, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let docRef = self.db.collection(self.path).document(id)
      docRef.getDocument { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        if let snapshot = snapshot,
           snapshot.exists,
           let merchant = snapshot.data().flatMap(Merchant.init(object:))
        {
          return promise(.success(merchant))
        } else {
          let error = NSError(
            domain: "",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve merchant account"]
          )
          return promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
