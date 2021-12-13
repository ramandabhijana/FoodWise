//
//  HomeViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 06/12/21.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
  @Published var searchText = ""
  @Published var isShowingSearchView = false
  @Published var isSearchResultNavigationActive = false
  @Published private(set) var foodsList: [Food] = []
  
  private(set) var foodRepository = FoodRepository()
  private var foodCatRepo = CategoryRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  init() {
  }
  
  func addCategory(_ category: FoodCategory) {
    foodCatRepo.createCategory(category)
      .sink { completion in
        print(completion)
      } receiveValue: { _ in
        print("Successfully added: \(category)")
      }
      .store(in: &subscriptions)
  }
  
  func onSubmitSearchField() {
    guard !searchText.isEmpty else { return }
    isShowingSearchView = false
    isSearchResultNavigationActive = true
    
  }
  
  
}
