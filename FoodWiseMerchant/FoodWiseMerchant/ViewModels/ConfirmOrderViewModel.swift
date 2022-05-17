//
//  ConfirmOrderViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 11/03/22.
//

import Foundation
import Combine

class ConfirmOrderViewModel: ObservableObject {
  @Published var showingRejectSheet: Bool = false
  @Published var showingAcceptAlert: Bool = false
  @Published var showingErrorSnackbar = false
  @Published var shouldDismissView: Bool = false
  @Published var loading = false
  @Published var showingRequestDeliveryRequiredAlert = false
  @Published var showingRequestDeliveryAndAccept = false
  @Published var showingRequestDeliveryView = false
  @Published var showingChatView = false
  @Published var remarksText: String = ""
  
  private(set) var order: Order
  private(set) var repository: OrderRepository
  private let foodRepository: FoodRepository
  private let walletRepository: WalletRepository
  private var subscriptions: Set<AnyCancellable> = []
  private var courierFound = false
  
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, dd MMMM yyyy"
    return formatter
  }()
  static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    return formatter
  }()
  
  var orderDateFormatted: String {
    Self.dateFormatter.string(from: order.date.dateValue())
  }
  var orderTimeFormatted: String {
    Self.timeFormatter.string(from: order.date.dateValue())
  }
  var orderSubtotalFormatted: String {
    NumberFormatter.rpCurrencyFormatter.string(from: .init(value: order.subtotal)) ?? "-"
  }
  var orderDeliveryFormatted: String {
    NumberFormatter.rpCurrencyFormatter.string(from: .init(value: order.deliveryCharge)) ?? "-"
  }
  var orderTotalFormatted: String {
    NumberFormatter.rpCurrencyFormatter.string(from: .init(value: order.total)) ?? "-"
  }
  var errorMessage: String { "Something went wrong" }
  
  var merchantName: String!
  
  
  init(order: Order,
       repository: OrderRepository,
       foodRepository: FoodRepository = FoodRepository(),
       walletRepository: WalletRepository = WalletRepository()) {
    self.order = order
    self.repository = repository
    self.foodRepository = foodRepository
    self.walletRepository = walletRepository
  }
  
  func showRejectSheet(_ shows: Bool) {
    showingRejectSheet = shows
  }
  
  func rejectOrder() {
    let order = self.order
    loading = true
    let remarkData = OrderRemarkData(userEmail: order.customerEmail, userName: order.customerName, date: orderDateFormatted, time: orderTimeFormatted, merchantName: merchantName, remarks: remarksText)
    let mailPublisher = SMTPService.sendOrderRemark(
      with: remarkData,
      accepted: false)
    let transactionPublisher = order.walletId != nil
    ? walletRepository.addNewTransaction(
      Transaction(
        date: order.date.dateValue(),
        amountSpent: order.total,
        info: "Refund (Order rejected)"
      ),
      toWalletWithId: order.walletId!)
    : Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    
    repository.confirmOrder(orderWithId: order.id, status: .rejected)
      .flatMap { _ in mailPublisher }
      .flatMap { _ in transactionPublisher }
      .sink { _ in
      } receiveValue: { [weak self] _ in
        self?.showingRejectSheet = false
        self?.loading = false
        self?.remarksText = ""
        self?.postConfirmedNotificationAndDismiss(accepted: false)
      }
      .store(in: &subscriptions)
  }
  
  func acceptOrder(withDeliveryTaskId taskId: String? = nil) {
    if order.pickupMethod == OrderPickupMethod.delivery.rawValue,
       courierFound == false {
      showingRequestDeliveryRequiredAlert = true
      return
    }
    
    loading = true
    
    let foodRepository = self.foodRepository
    let orderRepository = self.repository
    let order = self.order
    
    let foodStockPublishers = order.items
      .map { item in
        foodRepository.incrementFoodStock(-(item.quantity), for: item.food!)
      }
    
    let remarkData = OrderRemarkData(userEmail: order.customerEmail, userName: order.customerName, date: orderDateFormatted, time: orderTimeFormatted, merchantName: merchantName, remarks: "")
    let mailPublisher = SMTPService.sendOrderRemark(
      with: remarkData,
      accepted: true)
    
    let transactionPublisher = walletRepository.fetchOrCreateWallet(userId: order.merchantShopFromId)
      .flatMap { [walletRepository] wallet in
        order.walletId != nil
        ? walletRepository.addNewTransaction(
          Transaction(
            date: order.date.dateValue(),
            amountSpent: order.subtotal,
            info: "Order"
          ),
          toWalletWithId: wallet.id)
        : Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
      }
    
    Publishers.MergeMany(foodStockPublishers)
      .collect()
      .flatMap { _ in
        orderRepository.confirmOrder(orderWithId: order.id,
                                     status: .accepted,
                                     deliveryTaskId: taskId)
      }
      .flatMap { _ in transactionPublisher }
      .flatMap { _ in mailPublisher }
      .sink { [weak self] completion in
        if case .failure(_) = completion {
          self?.showingErrorSnackbar = true
        }
      } receiveValue: { [weak self] _ in
        self?.loading = false
        self?.postConfirmedNotificationAndDismiss(accepted: true)
      }
      .store(in: &subscriptions)
  }
  
  func listenRequestDeliveryPublisher(_ publisher: AnyPublisher<DeliveryTask, Never>) {
    publisher
      .sink { [weak self] task in
        self?.showingRequestDeliveryView = false
        self?.courierFound = true
        self?.acceptOrder(withDeliveryTaskId: task.taskId)
      }
      .store(in: &subscriptions)
  }
  
  private func postConfirmedNotificationAndDismiss(accepted: Bool) {
    NotificationCenter.default.post(
      name: .orderConfirmedNotification,
      object: [kOrderIdKey: order.id, kAcceptedKey: accepted])
    shouldDismissView = true
  }
}

extension NumberFormatter {
  static var rpCurrencyFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "id_ID")
    return formatter
  }
}

extension Notification.Name {
  static var orderConfirmedNotification: NSNotification.Name {
    .init(rawValue: "orderConfirmedNotification")
  }
}

let kOrderIdKey = "orderId"
let kAcceptedKey = "accepted"
