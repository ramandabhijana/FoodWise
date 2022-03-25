//
//  MerchantDetailsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 02/03/22.
//

import Foundation
import Combine

enum MerchantDetailsSortOptions: String, CaseIterable {
  case original = "Default"
  case price = "Price"
  case discound = "Discount"
}

class MerchantDetailsViewModel: ObservableObject {
  @Published var showingChatView: Bool = false
  @Published private(set) var merchant: Merchant? = nil
  @Published private(set) var allFoods: [Food] = []
  @Published private(set) var errorMessage = ""
  @Published private(set) var loading = false
  {
    willSet { if newValue { loadFoodsListWithPlaceholder() } }
  }
  @Published var currentSortOption: MerchantDetailsSortOptions = .original
  
  private(set) var foodRepository: FoodRepository
  private(set) var merchantRepository: MerchantRepository
  private var subscriptions = Set<AnyCancellable>()
  
  private var fetchMerchantPublisher: AnyPublisher<Merchant, Error>? {
    guard let merchantId = merchant?.id else { return nil }
    return merchantRepository.getMerchant(withId: merchantId)
  }
  private var fetchFoodsPublisher: AnyPublisher<[Food], Error>? {
    guard let merchantId = merchant?.id else { return nil }
    return foodRepository.getAllFoodsForMerchant(withId: merchantId)
  }
  
  init(
    merchant: Merchant,
    merchantRepository: MerchantRepository = MerchantRepository(),
    foodRepository: FoodRepository = FoodRepository()
  ) {
    self.merchant = merchant
    self.merchantRepository = merchantRepository
    self.foodRepository = foodRepository
    fetchAllFoodsForMerchant()
  }
  
  func refetchMerchantAndFoods(completion: @escaping () -> ()) {
    guard let merchantPublisher = fetchMerchantPublisher,
          let foodsPublisher = fetchFoodsPublisher else {
            completion()
            return
          }
    loading = true
    merchantPublisher
      .flatMap { [weak self] merchant -> AnyPublisher<[Food], Error> in
        self?.merchant = merchant
        return foodsPublisher
      }
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.loading = false
      } receiveValue: { [weak self] foods in
        self?.allFoods = foods
        completion()
      }
      .store(in: &subscriptions)
  }
  
//  private func fetchMerchantPublisher() -> AnyPublisher<Merchant, Error>? {
//    guard let merchantId = merchant?.id else { return nil }
//    return merchantRepository.getMerchant(withId: merchantId)
//      .sink { [weak self] completion in
//        if case .failure(let error) = completion {
//          self?.errorMessage = error.localizedDescription
//        }
//      } receiveValue: { [weak self] merchant in
//        self?.merchant = merchant
//      }
//      .store(in: &subscriptions)
//  }
  
  func fetchAllFoodsForMerchant() {
    guard let allFoodsPublisher = fetchFoodsPublisher else { return }
    loading = true
    allFoodsPublisher
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.loading = false
      } receiveValue: { [weak self] foods in
        self?.allFoods = foods
      }
      .store(in: &subscriptions)
  }
  
  func goToChatView(currentUserId: String?) {
    guard currentUserId != nil else {
      NotificationCenter.default.post(name: .signInRequiredNotification, object: nil)
      return
    }
    guard merchant != nil else {
      errorMessage = "Something went wrong"
      return
    }
    showingChatView = true
  }
  
  private func loadFoodsListWithPlaceholder() {
    allFoods = (0..<20).map { _ in Food.asPlaceholderInstance }
  }
}
