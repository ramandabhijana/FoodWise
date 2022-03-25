//
//  IncomingRequestsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import Foundation
import Combine

class IncomingRequestsViewModel: ObservableObject {
  @Published private(set) var donations: [Donation] = []
  @Published private(set) var isLoading: Bool = false {
    willSet {
      if newValue { donations = listPlaceholder }
    }
  }
  
  lazy var listPlaceholder = (0..<10).map { _ in Donation.asPlaceholderInstance }
  
  private(set) var repository: DonationRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  init(repository: DonationRepository,
       userId: String) {
    self.repository = repository
    loadRequestedDonations(userId: userId)
  }
  
  static let cellDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM yyyy 'at' HH:mm"
    return formatter
  }()
  
  func loadRequestedDonations(userId: String) {
    isLoading = true
    repository.getAvailableFoodsDonatedByUser(with: userId)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          print("getFoodsDonatedByUser failed with error: \(error)")
          return
        }
        self?.isLoading = false
      } receiveValue: { [weak self] donations in
        self?.donations = donations
      }
      .store(in: &subscriptions)
  }
  
  func listenDonationPublisher(_ publisher: AnyPublisher<Donation, Never>) {
    publisher
      .sink { [weak self] donation in
        guard let self = self else { return }
        if let index = self.donations.firstIndex(where: { $0.id == donation.id }) {
          // Because request was accepted, we can remove it from requests list
          self.donations.remove(at: index)
        }
      }
      .store(in: &subscriptions)
  }
  
  
}
