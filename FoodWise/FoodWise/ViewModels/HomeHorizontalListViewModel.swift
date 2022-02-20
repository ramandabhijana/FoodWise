//
//  HomeHorizontalListViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 06/12/21.
//

import Foundation
import Combine

class HomeHorizontalListViewModel: ObservableObject {
  @Published private(set) var loading = false {
    willSet { if newValue { foodsList = loadingList } }
  }
  @Published private(set) var foodsList: [Food] = []
  
  private(set) var defaultFoodsList: [Food] = []
  private(set) var foodRepository: FoodRepository
  private let loadingList: [Food] = (0..<6).map { _ in Food.asPlaceholderInstance }
  private let criteria: FeaturedCriteria
  private var subscriptions = Set<AnyCancellable>()
  
  init(foodRepository: FoodRepository,
       criteria: FeaturedCriteria,
       onChangeOfSelectedCategory: AnyPublisher<CategoryButtonModel?, Never>
  ) {
    self.foodRepository = foodRepository
    self.criteria = criteria
    self.loading = true
    self.fetchInitialFoods()
    onChangeOfSelectedCategory.dropFirst()
      .sink { [weak self] category in
        guard let self = self else { return }
        if let category = category {
          self.fetchFoods(matchingCategory: category.categories.category)
        } else {
          self.foodsList = self.defaultFoodsList
        }
      }
      .store(in: &subscriptions)
  }
  
  private func fetchInitialFoods() {
    self.loading = true
    correspondingPublisher()
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          print("Failed fetching initial foods. Error: \(error)")
        } else {
          self?.loading = false
        }
      } receiveValue: { [weak self] foods in
        self?.defaultFoodsList = foods
        self?.foodsList = foods
      }
      .store(in: &subscriptions)
  }
  
  private func fetchFoods(matchingCategory category: FoodCategory) {
    self.loading = true
    correspondingPublisher(for: category)
      .sink { [weak self] completion in
        print(completion)
        self?.loading = false
      } receiveValue: { [weak self] foods in
        guard let self = self else { return }
        self.foodsList = foods
      }
      .store(in: &subscriptions)
  }
  
  private func correspondingPublisher(for category: FoodCategory? = nil) -> AnyPublisher<[Food], Error> {
    switch criteria {
    case .bestDeals:
      return foodRepository.getBestDealsFoods(category: category)
    case .under10k:
      return foodRepository.getFoodsUnder10K(category: category)
    case .mostLoved:
      return foodRepository.getMostLovedFoods(category: category)
    }
  }
}
