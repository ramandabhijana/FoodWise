//
//  ManageFoodViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/12/21.
//

import Foundation
import Combine

class ManageFoodViewModel: ObservableObject {
  
  @Published private var recordedFoods: [Food]? = nil
  @Published var searchFieldText = ""
  @Published var loading = false
  @Published var errorMessage = ""
  
  private var foodRepository = FoodRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  var foodsList: [Food] {
    recordedFoods?.filter { food in
      searchFieldText.isEmpty
      || food.name.lowercased()
        .contains(searchFieldText.lowercased())
    } ?? []
  }
  
  init() {
    
  }
  
  func fetchFoodsIfListEmpty(merchantId: String) {
    guard recordedFoods == nil else { return }
    loading = true
    foodRepository.getAllFoods(merchantId: merchantId)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.loading = false
      } receiveValue: { [weak self] foods in
        self?.recordedFoods = foods
      }
      .store(in: &subscriptions)
  }
  
  func addFood(_ food: Food) {
    recordedFoods?.append(food)
  }
  
  func updateFood(_ food: Food) {
    let indexOfFood = recordedFoods?.firstIndex { $0.id == food.id }
    if let indexOfFood = indexOfFood {
      recordedFoods?[indexOfFood].stock = food.stock
    }
  }
  
  func clearSearchText() {
    searchFieldText = ""
  }
}
