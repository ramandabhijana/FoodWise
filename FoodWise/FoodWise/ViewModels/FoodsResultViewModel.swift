//
//  FoodsResultViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/12/21.
//

import Foundation
import Combine

class FoodsResultViewModel: ObservableObject {
  @Published private(set) var loading = false {
    willSet {
      if newValue {
        foods = (0..<10).map { _ in Food.asPlaceholderInstance }
      }
    }
  }
  @Published private(set) var foods: [Food] = []
  
  private(set) var foodRepository: FoodRepository
  private var subscriptions = Set<AnyCancellable>()
  
  init(searchQuery: String,
       foodRepository: FoodRepository = .init()) {
    self.foodRepository = foodRepository
    
    loading = true
    foodRepository.getFoods(withQuery: searchQuery)
      .sink { completion in
        print(completion)
      } receiveValue: { [weak self] foods in
        self?.foods = foods
        self?.loading = false
      }
      .store(in: &subscriptions)
  }
}
