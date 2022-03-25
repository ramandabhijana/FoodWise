//
//  CardEntryView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 25/02/22.
//

import SwiftUI
import Combine
import SquareInAppPaymentsSDK

struct CardEntryView {
  @ObservedObject var viewModel: CardEntryViewModel
  
  var theme: SQIPTheme = {
    let theme = SQIPTheme()
    theme.tintColor = UIColor(named: "AccentColor")!
    return theme
  }()
}

extension CardEntryView: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> SQIPCardEntryViewController {
    let controller = SQIPCardEntryViewController(theme: theme)
    controller.delegate = viewModel
    return controller
  }
  
  func updateUIViewController(_ uiViewController: SQIPCardEntryViewController, context: Context) {
    
  }
  
  
}

final class CardEntryViewModel: ObservableObject {
  private let currency = "AUD"
  private let userEmail: String
  private let amount: Int
  
  private var subscriptions: Set<AnyCancellable> = []
  
  @Published private(set) var payment: Payment? = nil
  
  var paymentPublisher: AnyPublisher<Payment, Never> {
    $payment.compactMap { $0 }.eraseToAnyPublisher()
  }
  
  init(userEmail: String, amount: Int) {
    self.userEmail = userEmail
    self.amount = amount
  }
}

extension CardEntryViewModel: SQIPCardEntryViewControllerDelegate {
  func cardEntryViewController(
    _ cardEntryViewController: SQIPCardEntryViewController,
    didObtain cardDetails: SQIPCardDetails,
    completionHandler: @escaping (Error?) -> Void
  ) {
    let body = WalletTopUpBody(nonce: cardDetails.nonce,
                               amount: amount,
                               currency: currency,
                               userEmail: userEmail)
    ChargePaymentService.processWalletTopUp(body)
      .sink { completion in
        if case .failure(let error) = completion {
          completionHandler(error)
        }
      } receiveValue: { [weak self] payment in
        self?.payment = payment
      }
      .store(in: &subscriptions)
  }
  
  func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didCompleteWith status: SQIPCardEntryCompletionStatus) {
  }
}
