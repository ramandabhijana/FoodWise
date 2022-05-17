//
//  WithdrawViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 14/05/22.
//

import Foundation
import Combine

class WithdrawViewModel: ObservableObject {
  @Published var enteredAmount: Double = 0.00
  @Published var bankName: String = ""
  @Published var accountNumber: String = ""
  @Published var accountHolder: String = ""
  @Published var showingErrorAlert = false
  @Published var showingSuccessAlert = false
  @Published private(set) var isLoading = false
  
  @Published private(set) var transaction: Transaction? = nil
  
  private(set) var isAmountValid: Bool?
  private(set) var isBankNameValid: Bool?
  private(set) var accountNumberValid: Bool?
  private(set) var accountHolderValid: Bool?
  
  private let maxAmount: Double
  private let userName: String
  private let userEmail: String
  private var walletId: String
  private let repository: WalletRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  var buttonDisabled: Bool {
    guard let isAmountValid = isAmountValid,
          let isBankNameValid = isBankNameValid,
          let accountNumberValid = accountNumberValid,
          let accountHolderValid = accountHolderValid
    else {
      return true
    }
    return !(isAmountValid && isBankNameValid && accountNumberValid && accountHolderValid)
  }
  
  init(maxAmount: Double, userName: String, userEmail: String, walletId: String, repository: WalletRepository) {
    self.maxAmount = maxAmount
    self.userName = userName
    self.userEmail = userEmail
    self.walletId = walletId
    self.repository = repository
    setupValidationListener()
  }
  
  private func setupValidationListener() {
    $enteredAmount
      .dropFirst(2)
      .map { [weak self] amount in
        guard let self = self else { return false }
        return amount > 0.00 && amount <= self.maxAmount
      }
      .assign(to: \.isAmountValid, on: self)
      .store(in: &subscriptions)
    $bankName
      .dropFirst()
      .map { !$0.isEmpty }
      .assign(to: \.isBankNameValid, on: self)
      .store(in: &subscriptions)
    $accountNumber
      .dropFirst()
      .map { $0.count >= 10 && Int($0) != nil }
      .assign(to: \.accountNumberValid, on: self)
      .store(in: &subscriptions)
    $accountHolder
      .dropFirst()
      .map { !$0.isEmpty }
      .assign(to: \.accountHolderValid, on: self)
      .store(in: &subscriptions)
  }
  
  func onTapSubmitButton() {
    guard buttonDisabled == false else { return }
    isLoading = true
    let withdrawData = WithdrawData(userEmail: userEmail, userName: userName, requestedAmount: WalletDetailsViewModel.currencyFormatter.string(from: NSNumber(value: enteredAmount))!, bankName: bankName, accountNo: accountNumber, accountHolder: accountHolder)
    let sendAdminPublisher = SMTPService.sendBalanceWithdrawalToAdmin(with: withdrawData)
    let sendUserPublisher = SMTPService.sendBalanceWithdrawalToUser(with: withdrawData)
    let (transaction, transactionPublisher) = makeTransactionPublisher()
    sendAdminPublisher
      .flatMap { _ in sendUserPublisher }
      .flatMap { _ in transactionPublisher }
      .sink(receiveCompletion: { [weak self] completion in
        self?.isLoading = false
        if case .failure(_) = completion {
          self?.showingErrorAlert = true
          return
        }
        self?.showingSuccessAlert = true
        self?.transaction = transaction
      }, receiveValue: { _ in }
      )
      .store(in: &subscriptions)
  }
  
  func makeTransactionPublisher() -> (Transaction, AnyPublisher<Void, Error>) {
    let transaction = Transaction(date: .now,
                                  amountSpent: -enteredAmount,
                                  info: "Withdraw Balance")
    return (transaction, repository.addNewTransaction(transaction, toWalletWithId: walletId))
  }
}
