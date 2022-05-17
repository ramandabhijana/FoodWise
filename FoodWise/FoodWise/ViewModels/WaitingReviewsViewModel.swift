//
//  WaitingReviewsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/04/22.
//

import Foundation
import Combine

class WaitingReviewsViewModel: ObservableObject {
  @Published private(set) var completedOrders = [Order]()
  @Published private(set) var loading = false {
    willSet {
      if newValue { loadOrdersWithPlaceholder() }
    }
  }
  private var subscriptions: Set<AnyCancellable> = []
  private let orderRepository: OrderRepository
  private let customerId: String
  static let sectionDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy '•' hh:mm a"
    return formatter
  }()
  
  init(customerId: String, orderRepository: OrderRepository = OrderRepository()) {
    self.customerId = customerId
    self.orderRepository = orderRepository
    fetchCompletedOrders()
  }
  
  func fetchCompletedOrders() {
    loading = true
    orderRepository.getOrders(orderedByCustomerWithId: customerId, withStatusIn: [.finished])
      .sink { [weak self] completion in
        self?.loading = false
        if case .failure(let error) = completion {
          print("Error fetching completed orders: \(error)")
          self?.completedOrders = []
        }
      } receiveValue: { [weak self] orders in
        var completedOrders = orders
        for orderIndex in completedOrders.indices {
          completedOrders[orderIndex].items = completedOrders[orderIndex].items.filter { item in
            if let isReviewed = item.isReviewed { return !isReviewed }
            return true
          }
        }
        self?.completedOrders = completedOrders.filter({ order in
          !order.items.isEmpty
        })
      }
      .store(in: &subscriptions)
  }
  
  func listenItemReviewed(publisher: AnyPublisher<(LineItem, Int), Never>) {
    publisher
      .sink { [weak self] itemAndOrderIndex in
        let (item, orderIndex) = itemAndOrderIndex
        self?.remove(item: item, fromOrderAtIndex: orderIndex)
      }
      .store(in: &subscriptions)
  }
  
  private func remove(item: LineItem, fromOrderAtIndex orderIndex: Int) {
    completedOrders[orderIndex].items.removeAll { $0.id == item.id }
  }
  
  private func loadOrdersWithPlaceholder() {
    completedOrders = Array(repeating: .asPlaceholder, count:8)
  }
  
  
}
