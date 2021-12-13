//
//  MerchantsResultViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/12/21.
//

import Foundation
import Combine

class MerchantsResultViewModel: ObservableObject {
  @Published private(set) var loading = false 
  @Published private(set) var merchants: [Merchant?] = Array(repeating: nil, count: 10)
  
  private let merchantRepository: MerchantRepository
  private let searchQuery: String
  private var subscriptions = Set<AnyCancellable>()
  
  init(searchQuery: String,
       merchantRepository: MerchantRepository = .init()) {
    self.searchQuery = searchQuery
    self.merchantRepository = merchantRepository
  }
  
  func fetchMerchants() {
    print("Fetching Merchants")
    guard merchants.contains(where: { $0 == nil }) else { return }
    self.loading = true
    merchantRepository.getMerchants(withQuery: searchQuery)
      .sink { completion in
        print(completion)
      } receiveValue: { [weak self] merchants in
        self?.merchants = merchants
        self?.loading = false
      }
      .store(in: &subscriptions)
  }
}
