//
//  FoodDetailsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/12/21.
//

import Foundation
import Combine

class FoodDetailsViewModel: ObservableObject {
  @Published private(set) var food: Food
  @Published private(set) var loading = false
  @Published private(set) var favorited = false
  @Published private(set) var errorMessage = ""
  @Published private(set) var merchant: Merchant? = nil
  
  @Published var onUpdateFavoriteList: (message: String, shows: Bool) = ("", false)
  
  private var customerId: String?
  private var currentFavoriteList: FavoriteFoodList?
  
  private lazy var favListRepository = FavoritesListRepository()
  private var foodRepository: FoodRepository
  private var merchantRepository = MerchantRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  init(food: Food,
       customerId: String? = nil,
       currentFavoriteList: FavoriteFoodList? = nil,
       foodRepository: FoodRepository) {
    self.foodRepository = foodRepository
    self.food = food
    self.customerId = customerId
    fetchMerchant()
    fetchFavoriteList()
  }
  
  func fetchFood(completion: @escaping () -> ()) {
    loading = true
    foodRepository.getFood(withId: food.id)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.loading = false
      } receiveValue: { [weak self] food in
        self?.food = food
        completion()
      }
      .store(in: &subscriptions)
  }
  
  func fetchFavoriteList() {
    guard
      let customerId = customerId,
      currentFavoriteList == nil else {
      return
    }
    favListRepository.getFavoriteList(forCustomerId: customerId)
      .sink { completion in
        if case .failure(let error) = completion {
          print("\n\(error.localizedDescription)\n")
        }
      } receiveValue: { [weak self] favoriteFoodList in
        guard let self = self else { return }
        self.currentFavoriteList = favoriteFoodList
        self.favorited = favoriteFoodList.foodIds.contains(self.food.id)
      }
      .store(in: &subscriptions)
  }
  
  func addToFavorite() {
    loading = true
    guard var currentFavoriteList = currentFavoriteList else {
      NotificationCenter.default.post(name: .signInRequiredNotification,
                                      object: nil)
      return
    }
    currentFavoriteList.foodIds.append(food.id)
    favListRepository.updateFavoriteList(currentFavoriteList)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          print("\n\(error.localizedDescription)\n")
        }
        self?.loading = false
      } receiveValue: { [weak self] _ in
        self?.favorited = true
        self?.currentFavoriteList = currentFavoriteList
        self?.onUpdateFavoriteList = (message: "Food was added to favorite",
                                      shows: true)
      }
      .store(in: &subscriptions)
  }
  
  func removeFromFavorite() {
    precondition(customerId != nil)
    precondition(currentFavoriteList != nil)
    precondition(currentFavoriteList!.foodIds.contains(food.id))
    
    loading = true
    let index = currentFavoriteList!.foodIds.firstIndex(of: food.id)!
    currentFavoriteList?.foodIds.remove(at: index)
    favListRepository.updateFavoriteList(currentFavoriteList!)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          print("\n\(error.localizedDescription)\n")
        }
        self?.loading = false
      } receiveValue: { [weak self] _ in
        self?.favorited = false
        self?.onUpdateFavoriteList = (message: "Food was removed from favorite",
                                      shows: true)
      }
      .store(in: &subscriptions)
  }
  
  func fetchMerchant() {
    merchantRepository.getMerchant(withId: food.merchantId)
      .sink { completion in
        print("Completed getMerchant(withId:) completion: \(completion)")
      } receiveValue: { [weak self] merchant in
        self?.merchant = merchant
      }
      .store(in: &subscriptions)
  }
}
