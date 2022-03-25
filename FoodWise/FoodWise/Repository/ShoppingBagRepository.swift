//
//  ShoppingBagRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/03/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class ShoppingBagRepository {
  private let db = Firestore.firestore()
  private let path = "shoppingBags"
  
  public init() { }
  
  func createBag(withItem item: LineItem?, ownerId: String, merchantShopAtId: String?) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let lineItems = item == nil ? [] : [item!]
      let shoppingBag = ShoppingBag(ownerId: ownerId, lineItems: lineItems, merchantShopAtId: merchantShopAtId)
      do {
        try self.db.collection(self.path)
          .document(ownerId)
          .setData(from: shoppingBag)
        promise(.success(()))
      } catch let error {
        promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }
  
  func updateBagItems(newLineItems: [LineItem], bagOwnerId: String) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path).document(bagOwnerId)
        .setData(["lineItems": newLineItems.map(\.asObject)], merge: true, completion: { error in
          if let error = error {
            promise(.failure(error))
            return
          }
          return promise(.success(()))
        })
    }
    .eraseToAnyPublisher()
  }
  
  /*
  func updateItemQuantity(_ qty: Int, lineItemId: String, lineItemFoodId: String, bagOwnerId: String) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
//      let lineItem =
      var ref = self.db.collection(self.path)
        .document(bagOwnerId)
        
//        .updateData([
//
//        ], completion: <#T##((Error?) -> Void)?#>)
    }
    .eraseToAnyPublisher()
  }
   */
  
  func removeItemFromBag(lineItem: LineItem, bagOwnerId: String) -> AnyPublisher<Void, Error> {
    var lineItemToBeDeleted = lineItem
    lineItemToBeDeleted.food = nil
    lineItemToBeDeleted.price = nil
    return Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path).document(bagOwnerId)
        .updateData([
          "lineItems": FieldValue.arrayRemove([lineItemToBeDeleted.asObject])
        ]) { error in
          if let error = error {
            promise(.failure(error))
          }
          promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func getShoppingBag(bagOwnerId: String) -> AnyPublisher<ShoppingBag?, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path).document(bagOwnerId)
        .getDocument { snapshot, error in
          guard error == nil, let snapshot = snapshot else {
            return promise(.failure(error ?? NSError()))
          }
          guard snapshot.exists else { return promise(.success(nil)) }
          do {
            let bag = try snapshot.data(as: ShoppingBag.self)
            return promise(.success(bag))
          } catch {
            return promise(.failure(error))
          }
        }
    }
    .eraseToAnyPublisher()
  }
  
  //
  
  //
  
  
}
