//
//  OrderVerificationViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

import Foundation
import Combine

enum DeliveredItemKind {
  case order, donation
}

class OrderVerificationViewModel: ObservableObject {
//  @Published var showingErrorAlert = false
  
//  @Published private(set) var scanningSessionRunning = true
  @Published var showingOrderVerified = false
  @Published var showingInvalidCodeAlert = false
  @Published private(set) var shouldDismissView = false
  
  private let deliveryTask: DeliveryTask
  private let itemIdentifier: String
  private let qrCodeValidSubject: PassthroughSubject<Void, Never> = .init()
  private(set) var itemKind: DeliveredItemKind
  private(set) var isPaid: Bool
  
  public static let didFinishVerificationNotification: NSNotification.Name = .init(rawValue: "didFinishVerificationNotification")
  
  var qrCodeValidPublisher: AnyPublisher<Void, Never> {
    qrCodeValidSubject.eraseToAnyPublisher()
  }
  
  init(deliveryTask: DeliveryTask) {
    self.deliveryTask = deliveryTask
    if let order = deliveryTask.order {
      itemKind = .order
      itemIdentifier = order.id
      isPaid = order.paymentMethod == OrderPaymentMethod.wallet.rawValue
    } else if let donation = deliveryTask.donation {
      itemKind = .donation
      itemIdentifier = donation.id
      isPaid = false
    } else {
      fatalError("Delivery task is not delivering order/donation")
    }
  }
  
  func evaluateQrCode(payloadValue: String) {
    NotificationCenter.default.post(
      name: .qrScannerCaptureSessionShouldEndRunning,
      object: nil)
    if payloadValue == itemIdentifier {
      qrCodeValidSubject.send(())
    } else {
      showingInvalidCodeAlert = true
    }
  }
  
  func rerunQrCaptureSession() {
    showingInvalidCodeAlert = false
    NotificationCenter.default.post(
      name: .qrScannerCaptureSessionShouldStartRunning,
      object: nil)
  }
  
  func dismissVerifiedView() {
    showingOrderVerified = false
    
  }
}

extension OrderVerificationViewModel: QRScanViewControllerDelegate {
  func errorDidOccur(_ error: QRScanViewControllerError, raisedError: Error?) {
    print("QRScan error: \(error)")
//    showingErrorAlert = true
  }
  
  func didObtainQrCode(withPayloadValue payloadValue: String) {
    evaluateQrCode(payloadValue: payloadValue)
  }
}

extension OrderVerificationViewModel {
  func makeLineItems() -> [LegitimateRecipientViewModel.LineItem] {
    switch itemKind {
    case .order:
      return deliveryTask.order!.items.map {
        LegitimateRecipientViewModel.LineItem(
          id: $0.id,
          name: $0.food!.name,
          qty: $0.quantity,
          price: $0.price!)
      }
    case .donation:
      let donation = deliveryTask.donation!
      return [
        LegitimateRecipientViewModel.LineItem(
        id: donation.id,
        name: donation.foodName,
        qty: 1,
        price: 0.0)
      ]
    }
  }
  
  func makePriceSection() -> LegitimateRecipientViewModel.PriceSection {
    switch itemKind {
    case .order:
      return .init(subtotal: deliveryTask.order!.subtotal,
                   deliveryCharge: deliveryTask.order!.deliveryCharge,
                   total: deliveryTask.order!.total)
    case .donation:
      let donation = deliveryTask.donation!
      return .init(subtotal: 0.0,
                   deliveryCharge: donation.deliveryCharge,
                   total: donation.deliveryCharge)
    }
    
  }
}
