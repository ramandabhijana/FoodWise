//
//  SharedFoodsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/03/22.
//

import Foundation
import Combine

class SharedFoodsViewModel: ObservableObject {
  @Published var currentSelectedKind: SharedFoodKind = .all
  @Published var showingDonateView: Bool = false
  @Published private(set) var allDonatedFoods: [DonationModel]? = nil
  
  lazy var listPlaceholder = (0..<10).map { _ in DonationModel.asPlaceholderInstance }
  
  @Published private(set) var loading: Bool = false {
    willSet {
      if newValue { allDonatedFoods = listPlaceholder }
    }
  }
  private(set) var repository: DonationRepository
  private(set) var customerRepository: CustomerRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  var donatedFoods: [DonationModel] {
    return allDonatedFoods?.filter { currentSelectedKind == .all || $0.donation.kind == currentSelectedKind.appropriateFor
    } ?? []
  }
  
  init(repository: DonationRepository = DonationRepository(),
       customerRepository: CustomerRepository = CustomerRepository()
  ) {
    self.repository = repository
    self.customerRepository = customerRepository
  }
  
  func loadDonatedFoods() {
    loading = true
    repository.getAllAvailableDonatedFoods()
      .flatMap { [weak self] donations -> AnyPublisher<DonationModel, Error> in
        guard let self = self else {
          return Fail(error: NSError.somethingWentWrong).eraseToAnyPublisher()
        }
        return self.mergedDonationModels(donations: donations)
      }
      .scan([], { $0 + [$1] })
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          if let viewModelError = error as? ViewModelError,
             viewModelError == .emptyArgument {
            self?.allDonatedFoods = []
            return
          }
          print("Failed to getAllAvailableDonatedFoods with error: \(error)")
          return
        }
        self?.loading = false
      } receiveValue: { [weak self] donationModels in
        self?.allDonatedFoods = donationModels
      }
      .store(in: &subscriptions)
  }
  
  func listenNewDonationPublisher(_ publisher: AnyPublisher<DonationModel, Never>) {
    publisher
      .sink { [unowned self] donation in
        allDonatedFoods?.append(donation)
        showingDonateView = false
      }
      .store(in: &subscriptions)
  }
  
  private func mergedDonationModels(donations: [Donation]) -> AnyPublisher<DonationModel, Error> {
    guard !donations.isEmpty else {
      return Fail(error: ViewModelError.emptyArgument).eraseToAnyPublisher()
    }
    let initialPublisher = makeDonationModelPublisher(donation: donations[0])
    let remainingDonations = Array(donations.dropFirst())
    return remainingDonations.reduce(initialPublisher) { partialResult, donation in
      partialResult
        .merge(with: makeDonationModelPublisher(donation: donation))
        .eraseToAnyPublisher()
    }
  }
  
  private func makeDonationModelPublisher(donation: Donation) -> AnyPublisher<DonationModel, Error> {
    customerRepository.getCustomer(withId: donation.donorId)
      .map { customer in
        DonationModel(donation: donation, donorUser: customer)
      }
      .eraseToAnyPublisher()
  }
}

private extension SharedFoodsViewModel {
  enum ViewModelError: Error {
    case emptyArgument
  }
}

struct DonationModel: Identifiable, Hashable {
  var id: String { donation.id }
  var donation: Donation
  let donorUser: Customer
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: DonationModel, rhs: DonationModel) -> Bool {
    lhs.id == rhs.id
  }
  
  static var asPlaceholderInstance: DonationModel {
    .init(donation: .asPlaceholderInstance,
          donorUser: .init(id: "", fullName: "Customer name", email: "", foodRescuedCount: 0, foodSharedCount: 0))
  }
}


enum SharedFoodKind: String, CaseIterable {
  case all = "All"
  case edible = "Edible"
  case compostable = "Compostable"
  case animalFeed = "Animal Feed"
  
  var appropriateFor: String {
    switch self {
    case .all: return ""
    case .edible: return "Human consumption"
    case .compostable: return "Composting"
    case .animalFeed: return "Animal feed"
    }
  }
}
