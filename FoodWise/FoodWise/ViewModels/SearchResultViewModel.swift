//
//  SearchResultViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/12/21.
//

import Foundation

enum SearchResultTitle: String {
  case foods = "Foods"
  case merchants = "Merchants"
}

class SearchResultViewModel: ObservableObject {
  @Published var searchText: String
  @Published var isShowingSearchView = false
  @Published var isSearchResultNavigationActive = false {
    didSet {
      print("\nisSearchResultNavigationActive: \(isSearchResultNavigationActive)\n")
    }
  }
  @Published var currentTitle = SearchResultTitle.foods.rawValue
  private let initialSearchText: String
  
  var getInitialSearchText: String { initialSearchText }
  
  init(searchText: String) {
    self.searchText = searchText
    self.initialSearchText = searchText
  }
  
  func onSubmitSearchField() {
    guard !searchText.isEmpty else { return }
    isShowingSearchView = false
    isSearchResultNavigationActive = true
  }
  
  func onBeginSearching() {
    searchText = initialSearchText
    isShowingSearchView = true
  }
}
