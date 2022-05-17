//
//  DonationRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/03/22.
//

import Foundation
import Combine
import FirebaseFirestore

class DonationRepository {
  private let db = Firestore.firestore()
  private let path = "donations"
  
  public init() { }
  
  func createDonation(pictureUrl: URL, kind: SharedFoodKind, foodName: String, pickupLocation: Address, notes: String, donorId: String) -> AnyPublisher<Donation, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let donation = Donation(date: .now, pictureUrl: pictureUrl, kind: kind, foodName: foodName, pickupLocation: pickupLocation, notes: notes, donorId: donorId)
      do {
        try self.db.collection(self.path)
          .document(donation.id)
          .setData(from: donation)
        return promise(.success(donation))
      } catch let error {
        return promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }
  
  func addAdoptionRequest(
    _ request: AdoptionRequest,
    toDonationWithId donationId: String) -> AnyPublisher<Void, Error> {
      Future { [weak self] promise in
        guard let self = self else { return }
        self.db.collection(self.path).document(donationId)
          .updateData([
            "adoptionRequests": FieldValue.arrayUnion([request.asObject])
          ]) { error in
            if let error = error {
              return promise(.failure(error))
            }
            return promise(.success(()))
          }
      }
      .eraseToAnyPublisher()
  }
  
  
  func getAllAvailableDonatedFoods() -> AnyPublisher<[Donation], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .whereField("status", isEqualTo: DonationStatus.available.rawValue)
        .getDocuments { snapshot, error in
          if let error = error {
            return promise(.failure(error))
          }
          let donations = snapshot?.documents.compactMap({ document in
            do {
              return try document.data(as: Donation.self)
            } catch let error {
              print("Couldn't create donation from document. \(error)")
              return nil
            }
          }) ?? [Donation]()
          return promise(.success(donations))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func getAvailableFoodsDonatedByUser(with userId: String) -> AnyPublisher<[Donation], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let query = self.db.collection(self.path)
        .whereField("donorId", isEqualTo: userId)
        .whereField("status", isEqualTo: DonationStatus.available.rawValue)
        .whereField("adoptionRequests", isNotEqualTo: [])
      query
        .getDocuments { snapshot, error in
          if let error = error {
            return promise(.failure(error))
          }
          let donations = snapshot?.documents.compactMap({ document in
            do {
              return try document.data(as: Donation.self)
            } catch let error {
              print("Couldn't create donation from document. \(error)")
              return nil
            }
          }) ?? [Donation]()
          return promise(.success(donations))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func getFoodsDonatedByUser(with userId: String) -> AnyPublisher<[Donation], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .whereField("donorId", isEqualTo: userId)
        .getDocuments { snapshot, error in
          if let error = error {
            return promise(.failure(error))
          }
          let donations = snapshot?.documents.compactMap({ document in
            do {
              return try document.data(as: Donation.self)
            } catch let error {
              print("Couldn't create donation from document. \(error)")
              return nil
            }
          }) ?? [Donation]()
          return promise(.success(donations))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func getFoodsAdoptedByUser(with userId: String) -> AnyPublisher<[Donation], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .whereField("receiverUserId", isEqualTo: userId)
        .getDocuments { snapshot, error in
          if let error = error {
            return promise(.failure(error))
          }
          let donations = snapshot?.documents.compactMap({ document in
            do {
              return try document.data(as: Donation.self)
            } catch let error {
              print("Couldn't create donation from document. \(error)")
              return nil
            }
          }) ?? [Donation]()
          return promise(.success(donations))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func acceptAdoptionRequest(_ request: AdoptionRequest, for donation: Donation) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let updatedData = [
        "receiverUserId": request.requesterCustomer.id,
        "status": DonationStatus.booked.rawValue,
        "adoptionRequests": [request.asObject]
      ] as [String : Any]
      self.db.collection(self.path).document(donation.id)
        .setData(updatedData, merge: true) { error in
          if let error = error { return promise(.failure(error)) }
          return promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func updateDonation(_ donation: Donation) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      do {
        try self.db.collection(self.path).document(donation.id)
          .setData(from: donation, merge: true) { error in
            if let error = error { return promise(.failure(error)) }
            return promise(.success(()))
          }
      } catch {
        return promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }
}
