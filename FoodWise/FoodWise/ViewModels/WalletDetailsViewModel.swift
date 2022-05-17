//
//  WalletDetailsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 23/02/22.
//

import Foundation
import Combine

class WalletDetailsViewModel: ObservableObject {
  @Published var showingTopUpSheet = false
  @Published var showingWithdrawSheet = false
  @Published var showingHistoryView = false
  
  @Published private(set) var wallet: Wallet? = nil
  @Published private(set) var transactionHistory: [TransactionHistoryGroupedByDate] = []
  @Published private(set) var errorMessage: String = ""
  @Published private(set) var isLoading: Bool = false
  
  var transactionHistoryIsEmpty: Bool {
    (wallet?.transactionHistory ?? []).isEmpty
  }
  var walletBalanceFormatted: String {
    let number = NSNumber.init(floatLiteral: wallet?.balance ?? 0.0)
    return Self.currencyFormatter.string(from: number) ?? ""
  }
  var walletIdPublisher: AnyPublisher<String, Never> {
    walletIdSubject.eraseToAnyPublisher()
  }
  func transactionAmountSpentFormated(amount: Double) -> String {
    let amountNumber = NSNumber.init(floatLiteral: amount)
    let amountString = Self.currencyFormatter.string(from: amountNumber) ?? ""
    return amount > 0.0 ? "+\(amountString)" : amountString
  }
  
  private(set) var repository: WalletRepository
  
  private let walletIdSubject: PassthroughSubject<String, Never> = .init()
  private var subscriptions: Set<AnyCancellable> = []
  
  static let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "IDR"
    return formatter
  }()
  
  static let historySectionDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
  }()
  
  init(repository: WalletRepository = WalletRepository(),
       userId: String) {
    self.repository = repository
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//      self.walletIdSubject.send("59DFE4BA-6E93-4D92-9DF6-8067848980B0")
//      self.walletIdSubject.send(completion: .finished)
//    }
    loadWallet(userId: userId)
  }
  
  func loadWallet(userId: String) {
    isLoading = true
    repository.fetchOrCreateWallet(userId: userId)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.isLoading = false
      } receiveValue: { [weak self] wallet in
        self?.wallet = wallet
        self?.walletIdSubject.send(wallet.id)
        self?.walletIdSubject.send(completion: .finished)
//        print(wallet)
//        let sortedHistoryArray = wallet.transactionHistory
//          .sorted {
//            $0.date > $1.date
//          }
        let historyDictionary = Dictionary(
          grouping: wallet.transactionHistory,
          by: { $0.calendarDate })
        self?.transactionHistory = historyDictionary.keys.sorted(by: >)
          .map { date in
            TransactionHistoryGroupedByDate(
              date: date,
              transactions: historyDictionary[date]!.sorted { $0.date > $1.date })
          }
      }
      .store(in: &subscriptions)
  }
  
  func listenTransactionPublisher(_ publisher: AnyPublisher<Transaction, Never>) {
    publisher
      .sink { [weak self] transaction in
        self?.wallet?.balance += transaction.amountSpent
        self?.wallet?.transactionHistory.insert(transaction, at: 0)
        if let indexOfTransactionDate = self?.transactionHistory.indexOf(transaction.calendarDate) {
          self?.transactionHistory[indexOfTransactionDate].transactions.insert(transaction, at: 0)
        } else {
          let newHistory = TransactionHistoryGroupedByDate(date: transaction.calendarDate, transactions: [transaction])
          self?.transactionHistory.insert(newHistory, at: 0)
        }
      }
      .store(in: &subscriptions)
  }
}

extension WalletDetailsViewModel {
  struct TransactionHistoryGroupedByDate: Identifiable {
    let date: Date
    var transactions: [Transaction]
    var id: Date { date }
  }
}

extension Array where Element == WalletDetailsViewModel.TransactionHistoryGroupedByDate {
  func indexOf(_ date: Date) -> Int? {
    firstIndex(where: { $0.date == date })
  }
}
