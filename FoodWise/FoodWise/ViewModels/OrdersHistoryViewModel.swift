//
//  OrdersHistoryViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/04/22.
//

import Foundation
import Combine

class OrdersHistoryViewModel: ObservableObject {
  @Published var showingError: Bool = false
  @Published var selectedHistoryStatus: String = HistoryStatus.ongoing.rawValue{
    didSet {
      if selectedHistoryStatus == OrdersHistoryViewModel.HistoryStatus.past.rawValue,
         pastOrders == nil {
        loadPastOrders()
      }
    }
  }
  @Published private(set) var ongoingOrders: [Order] = []
  @Published private(set) var pastOrders: [Order]? = nil
  @Published private(set) var loadingOngoingOrders: Bool = false {
    willSet {
      if newValue { ongoingOrders = Array(repeating: .asPlaceholder, count: 7) }
    }
  }
  @Published private(set) var loadingPastOrders: Bool = false {
    willSet {
      if newValue { pastOrders = Array(repeating: .asPlaceholder, count: 7) }
    }
  }
  
  static let orderCellDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "'Placed on' MMMM dd, yyyy 'at' hh:mm a"
    return formatter
  }()
  
  private let customerId: String
  private(set) var repository: OrderRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  init(customerId: String,
       repository: OrderRepository = OrderRepository()) {
    self.customerId = customerId
    self.repository = repository
    loadOngoingOrders(forCustomerWithId: customerId)
  }
  
  func loadOngoingOrders(forCustomerWithId customerId: String) {
    loadingOngoingOrders = true
    repository.getOrders(
      orderedByCustomerWithId: customerId,
      withStatusIn: [.pending, .accepted]
    )
      .sink { [weak self] completion in
        self?.loadingOngoingOrders = false
        if case .failure(let error) = completion {
          print("Error: \(error)")
          self?.showingError = true
        }
      } receiveValue: { [weak self] orders in
        self?.setOngoingOrders(orders)
      }
      .store(in: &subscriptions)
  }
  
  func loadPastOrders() {
    loadingPastOrders = true
    repository.getOrders(
      orderedByCustomerWithId: customerId,
      withStatusIn: [.rejected, .finished]
    )
      .sink { [weak self] completion in
        self?.loadingPastOrders = false
        if case .failure(let error) = completion {
          print("loadPastOrders error: \(error)")
          self?.showingError = true
        }
      } receiveValue: { [weak self] orders in
        self?.setPastOrders(orders)
      }
      .store(in: &subscriptions)
  }
  
  func refreshList() {
    switch selectedHistoryStatus {
    case OrdersHistoryViewModel.HistoryStatus.ongoing.rawValue:
      loadOngoingOrders(forCustomerWithId: customerId)
    case OrdersHistoryViewModel.HistoryStatus.past.rawValue:
      loadPastOrders()
    default:
      return
    }
  }
  
  private func setOngoingOrders(_ orders: [Order]) {
//    print("\norders:\(orders)\n")
    ongoingOrders = orders.sorted(by: { $0.date.dateValue() < $1.date.dateValue() })
  }
  
  private func setPastOrders(_ orders: [Order]) {
    pastOrders = orders.sorted(by: { $0.date.dateValue() > $1.date.dateValue() })
  }
  
}

extension OrdersHistoryViewModel {
  enum HistoryStatus: String, CaseIterable {
    case ongoing = "Ongoing"
    case past = "Past"
  }
}
