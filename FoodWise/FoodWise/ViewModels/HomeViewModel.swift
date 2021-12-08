//
//  HomeViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 06/12/21.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
  @Published private(set) var foodsList: [Food] = []
  
  private(set) var foodRepository = FoodRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  init() {
    
  }
  
  
}
