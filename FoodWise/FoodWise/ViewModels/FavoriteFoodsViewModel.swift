//
//  FavoriteFoodsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/12/21.
//

import Foundation
import Combine

class FavoriteFoodsViewModel: ObservableObject {
  @Published var searchText = ""
  
  @Published private(set) var errorMessage = ""
  @Published private(set) var foodsList: [Food] = []
  @Published private(set) var loading = false {
    willSet {
      if newValue {
        foodsList = [.asPlaceholderInstance, .asPlaceholderInstance, .asPlaceholderInstance, .asPlaceholderInstance, .asPlaceholderInstance]
      }
    }
  }
  
  private(set) var customerId: String?
  private var currentFavoriteList: FavoriteFoodList?
  
  private(set) var foodRepository: FoodRepository
  private lazy var favListRepository = FavoritesListRepository()
  
  private var subscriptions = Set<AnyCancellable>()
  
  var filteredFoods: [Food] {
    foodsList.filter { food in
      searchText.isEmpty
      || food.name.lowercased()
        .contains(searchText.lowercased())
    }
  }
  
  init(customerId: String? = nil, foodRepository: FoodRepository) {
    self.foodRepository = foodRepository
    self.customerId = customerId
    fetchFavoriteList()
  }
  
  func fetchFavoriteList() {
    guard let customerId = customerId else {
      return
    }
    loading = true
    favListRepository.getFavoriteList(forCustomerId: customerId)
      .handleEvents(receiveOutput: { [weak self] currentFavoriteList in
        self?.currentFavoriteList = currentFavoriteList
      })
      .map(\.foodIds)
      .flatMap { [weak self] foodIds -> AnyPublisher<Food, Error> in
        guard let self = self else {
          return Empty().eraseToAnyPublisher()
        }
        return self.foodRepository.mergedFoods(ids: foodIds)
      }
      .scan([], { foods, food -> [Food] in
        foods + [food]
      })
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
          if let foodRepoError = error as? FoodRepository.FoodRepositoryError {
            switch foodRepoError {
            case .emptyArgument: self?.foodsList = []
            }
          }
        }
        self?.loading = false
      } receiveValue: { [weak self] foods in
        self?.foodsList = foods
      }
      .store(in: &subscriptions)
  }
  
  func removeFromList(food: Food) {
    if let index = foodsList.firstIndex(where: { $0.id == food.id }) {
      foodsList.remove(at: index)
    }
  }
  
  func unfavoriteFood(_ food: Food) {
    guard let index = currentFavoriteList?.foodIds.firstIndex(of: food.id) else {
      return
    }
    currentFavoriteList?.foodIds.remove(at: index)
    favListRepository.updateFavoriteList(currentFavoriteList!)
      .sink { completion in
        if case .failure(let error) = completion {
          print("\n\(error.localizedDescription)\n")
        }
      } receiveValue: { [weak self] _ in
        self?.removeFromList(food: food)
      }
      .store(in: &subscriptions)
  }
  
  func clearSearchText() {
    searchText = ""
  }
  
  
  
}

