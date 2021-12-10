//
//  CategoriesViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 09/12/21.
//

import Foundation
import Combine

class CategoriesViewModel: ObservableObject {
  @Published var indexOfSelectedCategory: Int? = nil
  private(set) var data = CategoryButtonModel.data
  
  lazy var selectedCategoryPublisher = $indexOfSelectedCategory
    .map { index -> CategoryButtonModel? in
      if let index = index {
        return CategoryButtonModel.data[index]
      }
      return nil
    }
    .eraseToAnyPublisher()
  
  func onTapCategory(at index: Int) {
    guard indexOfSelectedCategory != index else {
      indexOfSelectedCategory = nil
      return
    }
    indexOfSelectedCategory = index
  }
}
