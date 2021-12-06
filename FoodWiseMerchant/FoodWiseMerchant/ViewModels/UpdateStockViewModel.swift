//
//  UpdateStockViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/12/21.
//

import Foundation
import Combine

class UpdateStockViewModel: ObservableObject {
  
  @Published private(set) var buttonDisabled = true
  @Published private(set) var errorMessage = ""
  @Published private(set) var loading = false
  @Published var stock = "" {
    didSet {
      buttonDisabled = stock.isEmpty && Int(stock) == nil
    }
  }
  
  private(set) var food: Food
  private var manageFoodViewModel: ManageFoodViewModel
  private var foodRepo = FoodRepository()
  private var subscriptions = Set<AnyCancellable>()
  private var backgroundQueue = DispatchQueue(
    label: "UpdateStockViewModel",
    qos: .userInitiated
  )
  
  init(food: Food, manageFoodViewModel: ManageFoodViewModel) {
    self.food = food
    self.manageFoodViewModel = manageFoodViewModel
  }
  
  func updateFoodStock() {
    guard !buttonDisabled, let stock = Int(stock) else { return }
    loading = true
    foodRepo.updateFoodStock(stock, for: food)
      .subscribe(on: backgroundQueue)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.loading = false
      } receiveValue: { [weak self] _ in
        guard let self = self else { return }
        self.food.stock = stock
        self.manageFoodViewModel.updateFood(self.food)
        NotificationCenter.default.post(
          name: .viewModeldidFinishUpdateStock,
          object: nil)
      }
      .store(in: &subscriptions)
  }
  
}

extension Notification.Name {
  static let viewModeldidFinishUpdateStock = Notification.Name("viewModeldidFinishUpdateStock")
}
