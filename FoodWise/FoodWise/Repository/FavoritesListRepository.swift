//
//  FavoritesListRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/12/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class FavoritesListRepository {
  private let db = Firestore.firestore()
  private let path = "favoriteFoodIds"
  
  public init() { }
  
  func getFavoriteList(forCustomerId customerId: String) -> AnyPublisher<FavoriteFoodList, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path).document(customerId)
        .getDocument { snapshot, error in
          guard error == nil else { return promise(.failure(error!)) }
          if let snapshot = snapshot {
            if !snapshot.exists {
              let newList = FavoriteFoodList(customerId: customerId,
                                             foodIds: [])
              return promise(.success(newList))
            }
            do {
              let favoriteList = try snapshot.data(as: FavoriteFoodList.self)
              promise(.success(favoriteList!))
            } catch let err {
              print(err)
              let error = NSError(
                domain: "",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve food details"]
              )
              return promise(.failure(error))
            }
          }
        }
    }.eraseToAnyPublisher()
  }
  
  func updateFavoriteList(_ favoriteList: FavoriteFoodList) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      do {
        try self.db.collection(self.path).document(favoriteList.id)
          .setData(from: favoriteList, merge: true) { error in
            if let error = error {
              promise(.failure(error))
              return
            }
            promise(.success(()))
          }
      } catch {
        promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }
}
