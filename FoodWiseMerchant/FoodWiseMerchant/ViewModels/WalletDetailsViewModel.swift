//
//  WalletDetailsViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 14/05/22.
//

import Foundation
import Combine

class WalletDetailsViewModel: ObservableObject {
  @Published var showingWithdrawSheet = false
  @Published var showingHistoryView = false
  
  @Published private(set) var wallet: Wallet? = nil
  @Published private(set) var transactionHistory: [TransactionHistoryGroupedByDate] = []
  @Published private(set) var errorMessage: String = ""
  @Published private(set) var isLoading: Bool = false
  
  private(set) var repository: WalletRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  var transactionHistoryIsEmpty: Bool {
    (wallet?.transactionHistory ?? []).isEmpty
  }
  var walletBalanceFormatted: String {
    let number = NSNumber.init(floatLiteral: wallet?.balance ?? 0.0)
    return Self.currencyFormatter.string(from: number) ?? ""
  }
  
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
  
  init(repository: WalletRepository = WalletRepository()) {
    self.repository = repository
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
  
  func transactionAmountSpentFormated(amount: Double) -> String {
    let amountNumber = NSNumber.init(floatLiteral: amount)
    let amountString = Self.currencyFormatter.string(from: amountNumber) ?? ""
    return amount > 0.0 ? "+\(amountString)" : amountString
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
