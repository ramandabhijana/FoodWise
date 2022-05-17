//
//  RecipientVerificationViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 14/05/22.
//

import Foundation
import Combine

class RecipientVerificationViewModel: ObservableObject {
  @Published var showingReceiptVerified = false
  @Published var showingInvalidCodeAlert = false
  @Published var showingErrorAlert = false
  @Published private(set) var pendingOrders: [Order]? = nil
  
  private let orderRepository: OrderRepository
  private let customerRepository: CustomerRepository
  private var subscriptions: Set<AnyCancellable> = []
  private let qrCodeValidForOrderSubject: PassthroughSubject<Order, Never> = .init()
  
  var qrCodeValidForOrderPublisher: AnyPublisher<Order, Never> {
    qrCodeValidForOrderSubject.eraseToAnyPublisher()
  }
  
  public static let didFinishVerificationNotification: NSNotification.Name = .init(rawValue: "didFinishVerificationNotification")
  
  init(
    orderRepository: OrderRepository = OrderRepository(),
    customerRepository: CustomerRepository = CustomerRepository()
  ) {
    self.orderRepository = orderRepository
    self.customerRepository = customerRepository
  }
  
  func rerunQrCaptureSession() {
    showingInvalidCodeAlert = false
    NotificationCenter.default.post(
      name: .qrScannerCaptureSessionShouldStartRunning,
      object: nil)
  }
  
  func dismissVerifiedView() {
    showingReceiptVerified = false
  }
  
  func loadPendingOrders(merchantId: String) {
    orderRepository.fetchPendingSelfPickupOrdersForMerchant(withId: merchantId)
      .replaceError(with: [])
      .sink { [weak self] orders in
        self?.pendingOrders = orders
      }
      .store(in: &subscriptions)
  }
  
  private func evaluateQRCodePayloadValue(_ value: String) {
    guard let pendingOrders = pendingOrders else { return }
    NotificationCenter.default.post(
      name: .qrScannerCaptureSessionShouldEndRunning,
      object: nil)
    if let order = pendingOrders.first(where: { $0.id == value }) {
      qrCodeValidForOrderSubject.send(order)
    } else {
      showingInvalidCodeAlert = true
    }
  }
  
  func finishOrder(order: Order) {
    pendingOrders = nil
    let totalQuantity = order.items.reduce(0) { partialResult, lineItem in
      partialResult + lineItem.quantity
    }
    let rescuedCountPublisher = customerRepository.incrementFoodRescuedCount(
      by: Int64(totalQuantity),
      forCustomerId: order.customerId)
    let finishedPublisher = orderRepository.finishOrder(orderWithId: order.id)
    finishedPublisher
      .flatMap { _ in rescuedCountPublisher }
      .sink(receiveCompletion: { [weak self] completion in
        if case .failure(let error) = completion {
          print("\nError: \(error)\n")
        }
        self?.showingErrorAlert = true
      }, receiveValue: { _ in
        NotificationCenter.default.post(
          name: Self.didFinishVerificationNotification,
          object: nil)
      })
      .store(in: &subscriptions)
  }
  
}

extension RecipientVerificationViewModel: QRScanViewControllerDelegate {
  func errorDidOccur(_ error: QRScanViewControllerError, raisedError: Error?) {
    print("QRScan error: \(error)")
  }
  
  func didObtainQrCode(withPayloadValue payloadValue: String) {
    evaluateQRCodePayloadValue(payloadValue)
  }
}

extension RecipientVerificationViewModel {
  func makeLineItems(fromOrderLineItems lineItems: [LineItem]) -> [LegitimateRecipientViewModel.LineItem] {
    lineItems.map {
      LegitimateRecipientViewModel.LineItem(
        id: $0.id,
        name: $0.food?.name ?? "",
        qty: $0.quantity,
        price: $0.price ?? 0.0)
    }
  }
  
  func makePriceSection(subtotal: Double, deliveryCharge: Double, total: Double) -> LegitimateRecipientViewModel.PriceSection {
    .init(subtotal: subtotal,
          deliveryCharge: deliveryCharge,
          total: total)
  }
}
