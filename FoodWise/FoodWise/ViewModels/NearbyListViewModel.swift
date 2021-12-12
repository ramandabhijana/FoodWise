//
//  NearbyListViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 11/12/21.
//

import Foundation
import Combine

class NearbyListViewModel: ObservableObject {
  @Published private(set) var merchants: [NearbyMerchants] = []
  @Published private(set) var radius: NearbyRadius = .oneKm
  
  private var radiusChangedSubject: PassthroughSubject<NearbyRadius, Never>
  private var subscriptions = Set<AnyCancellable>()
  
  var merchantsCount: Int {
    merchants.reduce([]) { $0 + $1.merchants }.count
  }
  var radiusString: String {
    radius.asString
  }
  var headerInfoText: String {
    let count = merchantsCount
    let merchantForm = count > 1 ? "Merchants" : "Merchant"
    return "\(count) \(merchantForm) found • \(radiusString)"
  }
  
  init(
    radiusChangedSubject: PassthroughSubject<NearbyRadius, Never>,
    filteredMerchantsPublisher: AnyPublisher<[NearbyMerchants], Never>
  ) {
    self.radiusChangedSubject = radiusChangedSubject
    filteredMerchantsPublisher
      .sink { [weak self] merchants in
        print("NearbyListViewModel receive filteredMerchants \(merchants)")
        self?.radius = merchants.last!.radius
        let filteredMerchants = merchants.filter { !$0.merchants.isEmpty }
        self?.merchants = filteredMerchants
      }
      .store(in: &subscriptions)
  }
  
  deinit {
    print("NearbyListViewModel deinitialized")
  }
  
  func onTapRadius(_ radius: NearbyRadius) {
    radiusChangedSubject.send(radius)
  }
  
  
  
}
