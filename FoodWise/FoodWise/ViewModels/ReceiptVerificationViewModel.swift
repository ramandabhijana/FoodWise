//
//  ReceiptVerificationViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/05/22.
//

import Foundation
import Combine

class ReceiptVerificationViewModel: ObservableObject {
//  @Published var showingErrorAlert = false
  
//  @Published private(set) var scanningSessionRunning = true
  @Published var showingReceiptVerified = false
  @Published var showingInvalidCodeAlert = false
  @Published private(set) var shouldDismissView = false
  
  private let itemIdentifier: String
  private let donatedFood: Donation
  private let qrCodeValidSubject: PassthroughSubject<Void, Never> = .init()
  
  public static let didFinishVerificationNotification: NSNotification.Name = .init(rawValue: "didFinishVerificationNotification")
  
  var qrCodeValidPublisher: AnyPublisher<Void, Never> {
    qrCodeValidSubject.eraseToAnyPublisher()
  }
  
  init(donatedFood: Donation) {
    self.donatedFood = donatedFood
    self.itemIdentifier = donatedFood.id
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
    showingReceiptVerified = false
  }
}

extension ReceiptVerificationViewModel: QRScanViewControllerDelegate {
  func errorDidOccur(_ error: QRScanViewControllerError, raisedError: Error?) {
    print("QRScan error: \(error)")
  }
  
  func didObtainQrCode(withPayloadValue payloadValue: String) {
    evaluateQrCode(payloadValue: payloadValue)
  }
}

extension ReceiptVerificationViewModel {
  func makeLineItems() -> [LegitimateRecipientViewModel.LineItem] {
    return [
      LegitimateRecipientViewModel.LineItem(
      id: donatedFood.id,
      name: donatedFood.foodName,
      qty: 1,
      price: 0.0)
    ]
  }
  
  func makePriceSection() -> LegitimateRecipientViewModel.PriceSection {
    return .init(subtotal: 0.0,
                 deliveryCharge: donatedFood.deliveryCharge ?? 0.0,
                 total: donatedFood.deliveryCharge ?? 0.0)
    
  }
}
