//
//  WalletRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 23/02/22.
//

import Foundation
import FirebaseFirestore
import Combine

final class WalletRepository {
  private let db = Firestore.firestore()
  private let path = "wallets"
  
  public init() { }
  
  // This method will create and return a new wallet for user if
  // there is no wallet data associated to the user
  // or simply return the existing wallet
  func fetchOrCreateWallet(userId: String) -> AnyPublisher<Wallet, Error> {
    checkExistsWalletForUser(with: userId)
      .flatMap { [weak self] exists -> AnyPublisher<Wallet, Error> in
        guard let self = self else {
          return Fail(error: NSError()).eraseToAnyPublisher()
        }
        return exists
          ? self.getWalletForUser(withId: userId)
          : self.createWallet(userId: userId)
      }
      .eraseToAnyPublisher()
  }
  
  func checkExistsWalletForUser(with userId: String) -> AnyPublisher<Bool, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
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
    Future { [weak self] promise in
      guard let self = self else { return }
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
    Future { [weak self] promise in
      guard let self = self else { return }
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
    Future { [weak self] promise in
      guard let self = self else { return }
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
