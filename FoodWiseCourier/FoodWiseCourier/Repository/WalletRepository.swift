//
//  WalletRepository.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

import Foundation
import FirebaseFirestore
import Combine

struct WalletRepository {
  private let db = Firestore.firestore()
  private let path = "wallets"
  
  public init() { }
  
  func fetchOrCreateWallet(userId: String) -> AnyPublisher<Wallet, Error> {
    checkExistsWalletForUser(with: userId)
      .flatMap { exists -> AnyPublisher<Wallet, Error> in
        return exists
          ? getWalletForUser(withId: userId)
          : createWallet(userId: userId)
      }
      .eraseToAnyPublisher()
  }
  
  func checkExistsWalletForUser(with userId: String) -> AnyPublisher<Bool, Error> {
    Future { promise in
      self.db.collection(self.path)
        .whereField("userId", isEqualTo: userId)
        .getDocuments { snapshot, error in
          guard error == nil, let snapshot = snapshot else {
            return promise(.failure(error ?? NSError()))
          }
          let walletExists = !snapshot.isEmpty
          return promise(.success(walletExists))
        }
    }.eraseToAnyPublisher()
  }
  
  func getWalletForUser(withId userId: String) -> AnyPublisher<Wallet, Error> {
    Future { promise in
      self.db.collection(self.path)
        .whereField("userId", isEqualTo: userId)
        .getDocuments { snapshot, error in
          guard error == nil else {
            return promise(.failure(error ?? NSError()))
          }
          let walletDocuments = (snapshot?.documents.compactMap { document in
            do {
              return try document.data(as: Wallet.self)
            } catch let error {
              print("Couldn't create Wallet from document. \(error)")
              return nil
            }
          } ?? [Wallet]())
          if walletDocuments.count == 1,
             let wallet = walletDocuments.first {
            return promise(.success(wallet))
          }
        }
    }.eraseToAnyPublisher()
  }
  
  func createWallet(userId: String) -> AnyPublisher<Wallet, Error> {
    Future { promise in
      let wallet = Wallet.init(
        id: UUID().uuidString,
        balance: 0.0,
        transactionHistory: [],
        userId: userId)
      do {
        try self.db.collection(self.path).document(wallet.id)
          .setData(from: wallet, merge: true) { error in
            if let error = error {
              promise(.failure(error))
              return
            }
            promise(.success(wallet))
          }
      } catch {
        promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }
  
  func addNewTransaction(
    _ transaction: Transaction,
    toWalletWithId walletId: String
  ) -> AnyPublisher<Void, Error> {
    Future { promise in
      let walletRef = self.db.collection(self.path).document(walletId)
      walletRef.updateData([
        "balance": FieldValue.increment(transaction.amountSpent),
        "transactionHistory": FieldValue.arrayUnion([transaction.asObject])
      ]) { error in
        if let error = error {
          promise(.failure(error))
        }
        promise(.success(()))
      }
    }.eraseToAnyPublisher()
  }
}
