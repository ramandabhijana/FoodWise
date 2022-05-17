//
//  OrdersViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 11/03/22.
//

import Foundation
import Combine

class OrdersViewModel: ObservableObject {
  @Published var selectedOrderkind: OrderKind = .new
  @Published var showingConfirmationView: Bool = false
  @Published private(set) var newOrders: [Order?] = Array(repeating: nil, count: 10)
  @Published private(set) var confirmedOrders: [Order?] = Array(repeating: nil, count: 10)
  
  let orderKinds: [OrderKind] = OrderKind.allCases
  private(set) var repository: OrderRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  static let orderCellDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a 'on' MMMM dd, yyyy"
    return formatter
  }()
  static let rpCurrencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "id_ID")
    return formatter
  }()
  
  init(repository: OrderRepository = OrderRepository()) {
    self.repository = repository
    
    NotificationCenter.default.publisher(for: .orderConfirmedNotification)
      .sink { [weak self] notification in
        let unwrapNewOrders = self?.newOrders.compactMap({ $0 })
        if let self = self,
           let object = notification.object as? [String: Any],
           let orderId = object[kOrderIdKey] as? String,
           let isAccepted = object[kAcceptedKey] as? Bool,
           let orderIndex = unwrapNewOrders?.firstIndex(where: { $0.id == orderId})
        {
          var confirmedOrder = self.newOrders.remove(at: orderIndex)!
          let status = isAccepted ? OrderStatus.accepted : .rejected
          confirmedOrder.status = status.rawValue
          self.confirmedOrders.insert(confirmedOrder, at: 0)
          self.showingConfirmationView = false
        }
      }
      .store(in: &subscriptions)
  }
  
  func loadOrders(merchantId: String) {
    guard newOrders.contains(where: { $0 == nil }) else { return }
    repository.fetchAllOrdersForMerchant(with: merchantId)
      .sink { completion in
        print("fetchAllOrdersForMerchant completion: \(completion)")
      } receiveValue: { [weak self] orders in
        self?.newOrders = orders
          .filter { $0.status == OrderStatus.pending.rawValue }
          .sorted(by: { $0.date.dateValue() < $1.date.dateValue() })
        self?.confirmedOrders = orders
          .filter { $0.status == OrderStatus.accepted.rawValue || $0.status == OrderStatus.rejected.rawValue }
          .sorted(by: { $0.date.dateValue() > $1.date.dateValue() })
      }
      .store(in: &subscriptions)
  }
  
  func formatPrice(_ price: Double) -> String {
    Self.rpCurrencyFormatter.string(from: .init(value: price)) ?? "Rp0"
  }
  
}

extension OrdersViewModel {
  enum OrderKind: String, CaseIterable {
    case new = "New"
    case confirmed = "Confirmed"
  }
  
  
}
