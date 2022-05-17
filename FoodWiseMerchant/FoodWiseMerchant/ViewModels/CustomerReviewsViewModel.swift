//
//  CustomerReviewsViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import Foundation
import Combine

class CustomerReviewsViewModel: ObservableObject {
  @Published private(set) var allFoods: [Food] = []
  @Published private(set) var loading = false {
    willSet { if newValue { loadFoodsWithPlaceholder() } }
  }
  
  private let repository: FoodRepository
  private var foodsInitialized: Bool = false
  private var subscriptions: Set<AnyCancellable> = []
  
  init(repository: FoodRepository = FoodRepository()) {
    self.repository = repository
  }
  
  func fetchFoods(merchantId: String) {
    guard !foodsInitialized else { return }
    loading = true
    repository.getAllFoods(merchantId: merchantId)
      .sink { [weak self] completion in
        self?.loading = false
        if case .failure(let error) = completion {
          self?.allFoods = []
          print("Error fetching foods: \(error)")
        }
      } receiveValue: { [weak self] foods in
        self?.allFoods = foods.sorted(by: { ($0.reviewCount ?? 0) > ($1.reviewCount ?? 0) })
        self?.foodsInitialized = true
      }
      .store(in: &subscriptions)

  }
  
  private func loadFoodsWithPlaceholder() {
    allFoods = Array(repeating: .asPlaceholderInstance, count: 7)
  }
}
