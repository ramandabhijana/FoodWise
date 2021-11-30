//
//  CourierRepository.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 30/11/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class CourierRepository {
  private let db = Firestore.firestore()
  private let path = "couriers"
  
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    
  }
  
  func createCourier(
    userId: String,
    name: String,
    bikeBrand: String,
    bikePlate: String,
    email: String,
    password: String,
    licenseImageData: Data,
    licenseNo: String,
    profileImageData: Data?
  ) -> AnyPublisher<Courier, Error> {
    let storage = StorageService.shared
    let licenseUploadPublisher = storage.uploadPictureData(
      licenseImageData,
      path: .licensePictures(fileName: userId)
    )
    if let profileImageData = profileImageData {
      let profileUploadPublisher = storage.uploadPictureData(
        profileImageData,
        path: .profilePictures(fileName: userId)
      )
      return licenseUploadPublisher
        .zip(profileUploadPublisher)
        .flatMap { [weak self] licenseUrlProfileUrl -> AnyPublisher<Courier, Error> in
          guard let self = self else {
            let error = NSError(
              domain: "",
              code: 0,
              userInfo: [NSLocalizedDescriptionKey: "Unable to perform task. Try again."]
            )
            return Fail(error: error).eraseToAnyPublisher()
          }
          let (licenseUrl, profileUrl) = licenseUrlProfileUrl
          let newLicense = DrivingLicense(
            imageUrl: licenseUrl,
            licenseNo: licenseNo,
            licenseHolderId: userId
          )
          let newCourier = Courier(
            id: userId,
            name: name,
            bikeBrand: bikeBrand,
            bikePlate: bikePlate,
            email: email,
            license: newLicense,
            profilePictureUrl: profileUrl
          )
          return self.addCourier(newCourier)
        }.eraseToAnyPublisher()
    } else {
      return licenseUploadPublisher
        .flatMap { licenseUrl -> AnyPublisher<Courier, Error>  in
          let newLicense = DrivingLicense(
            imageUrl: licenseUrl,
            licenseNo: licenseNo,
            licenseHolderId: userId
          )
          let newCourier = Courier(
            id: userId,
            name: name,
            bikeBrand: bikeBrand,
            bikePlate: bikePlate,
            email: email,
            license: newLicense
          )
          return self.addCourier(newCourier)
        }.eraseToAnyPublisher()
    }
  }
  
  private func addCourier(_ courier: Courier) -> AnyPublisher<Courier, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      do {
        try self.db.collection(self.path).document(courier.id).setData(from: courier)
        return promise(.success(courier))
      } catch let error {
        return promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }
  
  func getCourier(withId id: String) -> AnyPublisher<Courier, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let docRef = self.db.collection(self.path).document(id)
      docRef.getDocument { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        if let snapshot = snapshot,
           snapshot.exists,
           let courier = snapshot.data().flatMap(Courier.init(object:))
        {
          return promise(.success(courier))
        } else {
          let error = NSError(
            domain: "",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve courier account"]
          )
          return promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
