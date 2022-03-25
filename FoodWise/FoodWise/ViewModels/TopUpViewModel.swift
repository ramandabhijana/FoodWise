//
//  TopUpViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 24/02/22.
//

import Foundation
import Combine

enum TopUpViewState {
  case inputAmount, confirmation
}

class TopUpViewModel: ObservableObject {
  @Published var showingView = false {
    willSet {
      if !newValue { viewState = .inputAmount }
    }
  }
  @Published var enteredAmount: Double = 15_000.00
  @Published var isAmountValid = true
  @Published var showingCardEntryView = false
  @Published var isLoadingReceipt = false
  @Published var showingReceiptView = false
  @Published var receipt: TopUpReceipt? = nil {
    didSet { isLoadingReceipt = false }
  }
  
  @Published private(set) var transaction: Transaction? = nil
  @Published private(set) var viewState: TopUpViewState = .inputAmount
  
  private let idr1kToUsd = 0.000070
  private var transactionSubject: PassthroughSubject<Transaction, Error> = .init()
  private var subscriptions: Set<AnyCancellable> = []
  
  private(set) var walletId: String = "" {
    didSet { print("wallet id: \(walletId)") }
  }
  private(set) var repository: WalletRepository
  
  var transactionPublisher: AnyPublisher<Transaction, Error> {
    transactionSubject.eraseToAnyPublisher()
  }
  var enteredAmountString: String {
    Self.rpCurrencyFormatter.string(from: NSNumber(value: enteredAmount)) ?? "-"
  }
  var usdConversion: String {
    let converted = NSNumber(value: enteredAmount * idr1kToUsd)
    return Self.usdCurrencyFormatter.string(from: converted) ?? ""
  }
  var usdAmount: Int {
    let toUsd = NSNumber(value: enteredAmount * idr1kToUsd)
    let formattedUsd = Self.decimalFormatter.string(from: toUsd) ?? ""
    let doubleConversion = (formattedUsd as NSString).doubleValue
    return Int(doubleConversion * 100.00)
  }
  
  static let rpCurrencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "id_ID")
    return formatter
  }()
  static let usdCurrencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    return formatter
  }()
  static let decimalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "en_US")
    return formatter
  }()
  static let recommendedAmount: [Double] = [25_000.00, 50_000.00, 100_000.00, 200_000.00]
  
  
//  convenience init(repository: WalletRepository) {
//    self.repository = repository
//    $enteredAmount
//      .map { $0 >= 15_000.00 }
//      .assign(to: \.isAmountValid, on: self)
//      .store(in: &subscriptions)
//  }
  
  init(repository: WalletRepository,
       walletIdPublisher: AnyPublisher<String, Never>? = nil) {
    self.repository = repository
    $enteredAmount
      .map { $0 >= 15_000.00 }
      .assign(to: \.isAmountValid, on: self)
      .store(in: &subscriptions)
    if let walletIdPublisher = walletIdPublisher {
      walletIdPublisher
        .handleEvents(receiveCompletion: { completion in
          print(completion)
        })
        .assign(to: \.walletId, on: self)
        .store(in: &subscriptions)
    }
  }
  
  convenience init(repository: WalletRepository, walletId: String) {
    self.init(repository: repository)
    self.walletId = walletId
  }
  
//  convenience init(repository: WalletRepository, userId: String) {
//    self.init(repository: repository)
//    repository.getWalletForUser(withId: userId)
//      .sink { completion in
//        if case .failure(let error) = completion {
//          print("Failed getWalletForUser, error: \(error)")
//        }
//      } receiveValue: { [weak self] wallet in
//        self?.walletId = wallet.id
//      }
//      .store(in: &subscriptions)
//  }
  
  func showConfirmation() {
    viewState = .confirmation
  }
  
  func onTapConfirmationButton(cardEntryViewModelBuilder: (Int) -> CardEntryViewModel) {
    self.showingView = false
    self.showingCardEntryView = true
  }
  
  func listenPaymentPublisher(_ publisher: AnyPublisher<Payment, Never>) {
    publisher
      .sink { [weak self] payment in
        print("Payment success: \(payment)")
        self?.showingCardEntryView = false
        self?.isLoadingReceipt = true
        guard let self = self, self.walletId.isEmpty == false else { return }
        let transaction = Transaction(
          date: payment.updatedAtDate,
          amountSpent: self.enteredAmount,
          info: "Top Up Wallet")
        self.repository.addNewTransaction(transaction,
                                          toWalletWithId: self.walletId)
          .sink { [weak self] completion in
            if case .failure(let error) = completion {
              
            }
            // show error snackbar
          } receiveValue: { [weak self] _ in
            guard let self = self else { return }
            self.receipt = TopUpReceipt(
              date: payment.dateString,
              time: payment.timeString,
              cardBrand: payment.cardDetails.card.cardBrand,
              cardLast4: payment.cardDetails.card.last4,
              topUpAmount: {
                let rpAmount = NSNumber(value: self.enteredAmount)
                return Self.rpCurrencyFormatter.string(from: rpAmount) ?? ""
              }(),
              paidAmount: self.usdConversion
            )
            self.transaction = transaction
            self.showingReceiptView = true
          }
          .store(in: &self.subscriptions)
      }
      .store(in: &subscriptions)
  }
}

