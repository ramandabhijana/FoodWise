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
  @Published var showingAddedToBag = false
  @Published var showingDifferentMerchantAlert = false
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
  private var foodToBeAddedToBag: Food? = nil
  private var currentFavoriteList: FavoriteFoodList?
  
  private(set) var foodRepository: FoodRepository
  private let shoppingBagRepository: ShoppingBagRepository
  private lazy var favListRepository = FavoritesListRepository()
  
  private var subscriptions = Set<AnyCancellable>()
  
  var filteredFoods: [Food] {
    foodsList.filter { food in
      searchText.isEmpty
      || food.name.lowercased()
        .contains(searchText.lowercased())
    }
  }
  
  init(
    customerId: String? = nil,
    foodRepository: FoodRepository,
    shoppingBagRepository: ShoppingBagRepository = ShoppingBagRepository()
  ) {
    self.foodRepository = foodRepository
    self.customerId = customerId
    self.shoppingBagRepository = shoppingBagRepository
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
  
  func replaceBagItems() {
    guard let foodToBeAddedToBag = foodToBeAddedToBag else { return }
    addFoodToBag(foodToBeAddedToBag,
                 overwriteIfFromDifferentMerchant: true)
  }
  
  func addFoodToBag(_ food: Food,
                    overwriteIfFromDifferentMerchant: Bool = false) {
    foodToBeAddedToBag = food
    guard let customerId = customerId else { return }
    let lineItem = LineItem(id: UUID().uuidString,
                            foodId: food.id,
                            quantity: 1)
    shoppingBagRepository.getShoppingBag(bagOwnerId: customerId)
      .flatMap { [weak self] shoppingBagOrNil -> AnyPublisher<Void, Error> in
        guard let self = self else {
          return Fail(error: NSError.createWith("Something went wrong")).eraseToAnyPublisher()
        }
        guard let shoppingBag = shoppingBagOrNil else {
          return self.shoppingBagRepository.createBag(
            withItem: lineItem,
            ownerId: customerId,
            merchantShopAtId: food.merchantId)
        }
        let bagLineItems = shoppingBag.lineItems
        guard !bagLineItems.isEmpty else {
          return self.shoppingBagRepository.createBag(
            withItem: lineItem,
            ownerId: customerId,
            merchantShopAtId: food.merchantId)
        }
        if bagLineItems.first(where: { $0.foodId == lineItem.foodId }) == nil {
          // validate if from the same merchant
          guard let currentMerchantId = shoppingBag.merchantShopAtId else {
            return self.shoppingBagRepository.createBag(
              withItem: lineItem,
              ownerId: customerId,
              merchantShopAtId: food.merchantId)
          }
          let isShoppingSameMerchant = currentMerchantId == food.merchantId
          if isShoppingSameMerchant {
            let newLineItems = bagLineItems + [lineItem]
            return self.shoppingBagRepository.updateBagItems(
              newLineItems: newLineItems,
              bagOwnerId: customerId)
          } else {
            if overwriteIfFromDifferentMerchant {
              return self.shoppingBagRepository.createBag(
                withItem: lineItem,
                ownerId: customerId,
                merchantShopAtId: food.merchantId)
            } else {
              return Fail(error: FoodDetailsViewModelError.differentMerchantError).eraseToAnyPublisher()
            }
          }
        } else {
          // Simply return publisher, no need to talk to db layer as the lineItem is already saved
          return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
      }
      .subscribe(on: DispatchQueue.global(qos: .userInteractive))
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        guard case .failure(let error) = completion else {
          return
        }
        if let viewModelError = error as? FoodDetailsViewModelError,
           viewModelError == .differentMerchantError {
          self?.showingDifferentMerchantAlert = true
          return
        }
        self?.errorMessage = error.localizedDescription
      } receiveValue: { [weak self] _ in
        self?.showingAddedToBag = true
      }
      .store(in: &subscriptions)
  }
  
  
}

