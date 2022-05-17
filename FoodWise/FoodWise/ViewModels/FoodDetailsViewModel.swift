//
//  FoodDetailsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/12/21.
//

import Foundation
import Combine

class FoodDetailsViewModel: ObservableObject {
  @Published var showingChatView: Bool = false
  @Published var showingError = false
  @Published var showingDifferentMerchantAlert = false
  @Published private(set) var food: Food
  @Published private(set) var loading = false
  @Published private(set) var favorited = false
  @Published private(set) var reviews: [Review] = []
  
  @Published private(set) var errorMessage = "" {
    didSet { showingError = true }
  }
  @Published private(set) var merchant: Merchant? = nil
  
  @Published var showingAddedToBag: Bool = false
  @Published var onUpdateFavoriteList: (message: String, shows: Bool) = ("", false)
  
  private(set) var customerId: String?
  private var currentFavoriteList: FavoriteFoodList?
  
  private var favListRepository: FavoritesListRepository
  private(set) var foodRepository: FoodRepository
  private(set) var merchantRepository: MerchantRepository
  private let shoppingBagRepository: ShoppingBagRepository
  private(set) var reviewRepository: ReviewRepository
  private var subscriptions = Set<AnyCancellable>()
  
  var foodOutOfStock: Bool { food.stock <= 0 }
  
  init(food: Food,
       customerId: String? = nil,
       currentFavoriteList: FavoriteFoodList? = nil,
       foodRepository: FoodRepository,
       shoppingBagRepository: ShoppingBagRepository = ShoppingBagRepository(),
       favListRepository: FavoritesListRepository = FavoritesListRepository(),
       merchantRepository: MerchantRepository = MerchantRepository(),
       reviewRepository: ReviewRepository = ReviewRepository()
  ) {
    self.foodRepository = foodRepository
    self.shoppingBagRepository = shoppingBagRepository
    self.favListRepository = favListRepository
    self.merchantRepository = merchantRepository
    self.reviewRepository = reviewRepository
    self.food = food
    self.customerId = customerId
    fetchMerchant()
    fetchFavoriteList()
    fetchReviews()
  }
  
  func fetchReviews() {
    guard let reviewCount = food.reviewCount,
          reviewCount > 0
    else { return }
    loading = true
    reviewRepository.getAllReviews(forFoodWithId: food.id, limit: 3)
      .sink { [weak self] completion in
        self?.loading = false
      } receiveValue: { [weak self] reviews in
        self?.reviews = reviews
      }
      .store(in: &subscriptions)
    
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
        self?.onUpdateFavoriteList = (message: "Food was added to favorite 💛",
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
  
  func goToChatView() {
    guard customerId != nil else {
      NotificationCenter.default.post(name: .signInRequiredNotification, object: nil)
      return
    }
    guard merchant != nil else {
      errorMessage = "Something went wrong"
      return
    }
    showingChatView = true
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
  
  func replaceBagItems() {
    addToBag(overwriteIfFromDifferentMerchant: true)
  }
  
  // TODO: Separate to individual viewmodel
  func addToBag(overwriteIfFromDifferentMerchant: Bool = false) {
    guard let customerId = customerId else {
      postSignInRequiredNotification()
      return
    }
    guard let merchant = merchant else {
      errorMessage = "Something went wrong"
      return
    }
    
    let lineItem = LineItem(id: UUID().uuidString, foodId: food.id, quantity: 1)
    shoppingBagRepository.getShoppingBag(bagOwnerId: customerId)
      .flatMap { [weak self] shoppingBagOrNil -> AnyPublisher<Void, Error> in
        guard let self = self else {
          return Fail(error: NSError.createWith("Something went wrong")).eraseToAnyPublisher()
        }
        guard let shoppingBag = shoppingBagOrNil else {
          return self.shoppingBagRepository.createBag(withItem: lineItem, ownerId: customerId, merchantShopAtId: merchant.id)
        }
        let bagLineItems = shoppingBag.lineItems
        guard !bagLineItems.isEmpty else {
          return self.shoppingBagRepository.createBag(withItem: lineItem, ownerId: customerId, merchantShopAtId: merchant.id)
        }
        if bagLineItems.first(where: { $0.foodId == lineItem.foodId }) == nil {
          // validate if from the same merchant
          guard let currentMerchantId = shoppingBag.merchantShopAtId else {
            return self.shoppingBagRepository.createBag(withItem: lineItem, ownerId: customerId, merchantShopAtId: merchant.id)
          }
          let isShoppingSameMerchant = currentMerchantId == merchant.id
          if isShoppingSameMerchant {
            let newLineItems = bagLineItems + [lineItem]
            return self.shoppingBagRepository.updateBagItems(
              newLineItems: newLineItems,
              bagOwnerId: customerId)
          } else {
            if overwriteIfFromDifferentMerchant {
              return self.shoppingBagRepository.createBag(withItem: lineItem, ownerId: customerId, merchantShopAtId: merchant.id)
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
  
  private func postSignInRequiredNotification() {
    NotificationCenter.default.post(name: .signInRequiredNotification, object: nil)
  }
  
  
  
}

extension NSError {
  static func createWith(_ localizedDescription: String) -> NSError {
    NSError(
      domain: "",
      code: 0,
      userInfo: [NSLocalizedDescriptionKey: localizedDescription]
    )
  }
  
  static var somethingWentWrong: NSError {
    createWith("Something went wrong")
  }
}

enum FoodDetailsViewModelError: Error {
  case differentMerchantError
}
