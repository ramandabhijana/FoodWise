//
//  HomeHorizontalListViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 06/12/21.
//

import Foundation
import Combine

class HomeHorizontalListViewModel: ObservableObject {
  @Published private(set) var loading = false
  @Published private(set) var foodsList: [Food] = [
    .init(), .init(), .init(), .init()
  ]
  
  private(set) var foodRepository: FoodRepository
  private var subscriptions = Set<AnyCancellable>()
  
  init(foodRepository: FoodRepository) {
    self.foodRepository = foodRepository
    
    // Applying category filter, limit, etc
    self.loading = true
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
//      self?.foodsList = Food.sampleData
//      self?.loading = false
//    }
    
    self.foodRepository.getAllFoods()
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          print("HomeHorizontalListViewModel: Error occur consider retry. Error: \(error)")
        }
        
      } receiveValue: { [weak self] foods in
        self?.foodsList = foods
        self?.loading = false
        print("\n\(foods)\n")
      }
      .store(in: &subscriptions)
     
  }
}
