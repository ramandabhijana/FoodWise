//
//  RootEditFoodDetailsViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/02/22.
//

import Foundation
import Combine

class RootEditFoodDetailsViewModel: ObservableObject {
  @Published var searchFieldText = ""
  @Published var errorMessage = ""
  @Published var loading = false {
    willSet {
      if newValue {
        loadListWithPlaceholder()
      }
    }
  }
  
  @Published private var recordedFoods: [Food]? = nil
  
  var foodsList: [Food] {
    return recordedFoods?.filter { food in
      searchFieldText.isEmpty
      || food.name.lowercased()
        .contains(searchFieldText.lowercased())
    } ?? []
  }
  
  private(set) var repository: FoodRepository
  private var subscriptions = Set<AnyCancellable>()
  
  init(repository: FoodRepository = .init()) {
    self.repository = repository
  }
  
  func fetchRecordedFoods(merchantId: String) {
    guard recordedFoods == nil else { return }
    loading = true
    repository.getAllFoods(merchantId: merchantId)
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
  
  func clearSearchText() {
    searchFieldText = ""
  }
  
  func listenToFoodPublisher(_ publisher: AnyPublisher<Food, Never>) {
    publisher
      .sink { [weak self] food in
        if let indexOfFood = self?.recordedFoods?.firstIndex(of: food) {
          self?.recordedFoods?[indexOfFood] = food
        }
      }
      .store(in: &subscriptions)
  }
  
  func listenToDeletionPublisher(_ publisher: AnyPublisher<Food, Never>) {
    publisher
      .sink { [weak self] food in
        if let indexOfFood = self?.recordedFoods?.firstIndex(of: food) {
          self?.recordedFoods?.remove(at: indexOfFood)
        }
      }
      .store(in: &subscriptions)
  }
  
  private func loadListWithPlaceholder() {
    recordedFoods = (0..<7).map { _ in Food.asPlaceholderInstance }
  }
}
