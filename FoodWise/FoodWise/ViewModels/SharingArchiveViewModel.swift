//
//  SharingArchiveViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 04/05/22.
//

import Foundation
import Combine

class SharingArchiveViewModel: ObservableObject {
  @Published private var sharedFoods: [SharedFoodModel] = []
  @Published private var receivedFoods: [DonationModel]? = nil
  @Published private(set) var loadingSharedList: Bool = false {
    willSet {
      if newValue { loadSharedListWithPlaceholder() }
    }
  }
  @Published private(set) var loadingReceivedList: Bool = false {
    willSet {
      if newValue { loadReceivedListWithPlaceholder() }
    }
  }
  
  @Published var sharedListSearchText: String = ""
  @Published var receivedListSearchText: String = ""
  @Published var showingDropoffLocationPickerForReceivedDonation: (Bool, Donation?) = (false, nil)
  @Published var showingRequestDeliveryView: Bool = false
  @Published var showingError: Bool = false
  @Published var showingVerificationView: Bool = false
  @Published var displayedList: DisplayedList = .shared {
    didSet {
      guard displayedList == .received, receivedFoods == nil else { return }
      loadReceivedFoods()
    }
  }
  
  static let receivedCellDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "'Request accepted on' dd MMMM yyyy 'at' HH:mm"
    return formatter
  }()
  static let sharedCellDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "'You shared this on' dd MMMM yyyy 'at' HH:mm"
    return formatter
  }()
  static let cellConfirmedDateDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM yyyy HH:mm"
    return formatter
  }()
  
  private let customerId: String
  private let repository: DonationRepository
  private let customerRepository: CustomerRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  var donatedFoodToBeVerified: Donation? = nil
  
  var filteredSharedList: [SharedFoodModel] {
    sharedFoods.filter { food in
      sharedListSearchText.isEmpty
      || food.donation.foodName.lowercased().contains(sharedListSearchText.lowercased())
      || (food.recipientCustomer?.fullName.lowercased() ?? "").contains(sharedListSearchText.lowercased())
    }
  }
  
  var filteredReceivedList: [DonationModel] {
    receivedFoods?.filter { donation in
      receivedListSearchText.isEmpty
      || donation.donation.foodName.lowercased().contains(receivedListSearchText.lowercased())
      || donation.donorUser.fullName.lowercased().contains(receivedListSearchText.lowercased())
    } ?? []
  }
  
  init(customerId: String,
       repository: DonationRepository = DonationRepository(),
       customerRepository: CustomerRepository = CustomerRepository()) {
    self.customerId = customerId
    self.repository = repository
    self.customerRepository = customerRepository
    loadSharedFoods()
    
    NotificationCenter.default
      .publisher(for: ReceiptVerificationViewModel.didFinishVerificationNotification)
      .flatMap { [unowned self] _ -> AnyPublisher<[Void], Never> in
        if var verifiedDonatedFood = self.donatedFoodToBeVerified {
          verifiedDonatedFood.status = DonationStatus.received.rawValue
          let donationUpdatePublisher = repository.updateDonation(verifiedDonatedFood)
            .replaceError(with: ())
            .eraseToAnyPublisher()
          let rescuedCountPublisher = customerRepository.incrementFoodRescuedCount(
            forCustomerId: verifiedDonatedFood.receiverUserId!)
            .replaceError(with: ())
            .eraseToAnyPublisher()
          
          return Publishers.Merge(donationUpdatePublisher, rescuedCountPublisher)
            .collect()
            .eraseToAnyPublisher()
        }
        return Empty(completeImmediately: true).eraseToAnyPublisher()
      }
      .sink(receiveValue: { [weak self] _ in
        self?.showingVerificationView = false
      })
      .store(in: &subscriptions)
  }
  
  func refreshList() {
    switch displayedList {
    case .shared: loadSharedFoods()
    case .received: loadReceivedFoods()
    }
  }
  
  func clearSharedListSearchText() {
    sharedListSearchText = ""
  }
  
  func clearReceivedListSearchText() {
    receivedListSearchText = ""
  }
  
  func listenDeliveryTaskAssignedPublisher(
    _ publisher: AnyPublisher<DeliveryTask, Never>,
    forReceivedDonation donation: Donation
  ) {
    publisher
      .sink { [weak self] assignedTask in
        self?.showingRequestDeliveryView = false
        // update model in array
        if let receivedDonationIndex = self?.receivedFoods?.firstIndex(where: { $0.donation == donation }) {
          var updatedDonation = donation
          updatedDonation.deliveryTaskId = assignedTask.taskId
          updatedDonation.deliveryCharge = assignedTask.serviceWage
          updatedDonation.shippingAddress = assignedTask.dropOffAddress
          self?.receivedFoods?[receivedDonationIndex].donation = updatedDonation
          
          // update in db
          self?.updateDonationInDB(updatedDonation)
        }
      }
      .store(in: &subscriptions)
  }
  
  private func updateDonationInDB(_ donation: Donation) {
    repository.updateDonation(donation)
      .replaceError(with: ())
      .sink { _ in
        print("Donation updated successfully")
      }
      .store(in: &subscriptions)
  }
  
  private func loadSharedFoods() {
    loadingSharedList = true
    repository.getFoodsDonatedByUser(with: customerId)
      .flatMap { [weak self] donations -> AnyPublisher<SharedFoodModel, Error> in
        guard let self = self else {
          return Fail(error: NSError.somethingWentWrong).eraseToAnyPublisher()
        }
        return self.mergedSharedFoodModels(donations: donations)
      }
      .scan([], { $0 + [$1] })
      .handleEvents(receiveCompletion: { [weak self] completion in
        if case .failure = completion {
          self?.showingError = true
        }
        self?.loadingSharedList = false
      })
      .replaceError(with: [])
      .replaceEmpty(with: [])
      .sink { [weak self] sharedFoods in
        self?.sharedFoods = sharedFoods.sorted(by: { $0.donation.date.dateValue() > $1.donation.date.dateValue() })
      }
      .store(in: &subscriptions)
  }
  
  private func loadReceivedFoods() {
    loadingReceivedList = true
    repository.getFoodsAdoptedByUser(with: customerId)
      .flatMap { [weak self] donations -> AnyPublisher<DonationModel, Error> in
        guard let self = self else {
          return Fail(error: NSError.somethingWentWrong).eraseToAnyPublisher()
        }
        return self.mergedReceivedFoodModels(donations: donations)
      }
      .scan([], { $0 + [$1] })
      .handleEvents(receiveCompletion: { [weak self] completion in
        if case .failure = completion {
          self?.showingError = true
        }
        self?.loadingReceivedList = false
      })
      .replaceError(with: [])
      .replaceEmpty(with: [])
      .sink { [weak self] receivedFoods in
        self?.receivedFoods = receivedFoods.sorted(by: { $0.donation.date.dateValue() > $1.donation.date.dateValue() })
      }
      .store(in: &subscriptions)
  }
  
  private func mergedSharedFoodModels(donations: [Donation]) -> AnyPublisher<SharedFoodModel, Error> {
    guard !donations.isEmpty else { return Empty().eraseToAnyPublisher() }
    
    let initialPublisher = makeSharedFoodPublisher(donation: donations[0])
    let remainingDonations = Array(donations.dropFirst())
    return remainingDonations.reduce(initialPublisher) { partialResult, donation in
      partialResult
        .merge(with: makeSharedFoodPublisher(donation: donation))
        .eraseToAnyPublisher()
    }
  }
  
  private func makeSharedFoodPublisher(donation: Donation) -> AnyPublisher<SharedFoodModel, Error> {
    guard let recipientId = donation.receiverUserId else {
      let food = SharedFoodModel(donation: donation, recipientCustomer: nil)
      return Just(food).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    return customerRepository.getCustomer(withId: recipientId)
      .map { customer in
        SharedFoodModel(donation: donation, recipientCustomer: customer)
      }
      .eraseToAnyPublisher()
  }
  
  private func mergedReceivedFoodModels(donations: [Donation]) -> AnyPublisher<DonationModel, Error> {
    guard !donations.isEmpty else { return Empty().eraseToAnyPublisher() }
    
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
  
  private func loadSharedListWithPlaceholder() {
    sharedFoods = Array(repeating: .asPlaceholderInstance, count: 7)
  }
  
  private func loadReceivedListWithPlaceholder() {
    receivedFoods = Array(repeating: .asPlaceholderInstance, count: 7)
  }
}

extension SharingArchiveViewModel {
  enum DisplayedList: String, CaseIterable {
    case shared = "Shared"
    case received = "Received"
  }
  
  struct SharedFoodModel: Identifiable, Hashable {
    var id: String { donation.id }
    var donation: Donation
    let recipientCustomer: Customer?
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
    
    static func == (lhs: SharedFoodModel, rhs: SharedFoodModel) -> Bool {
      lhs.id == rhs.id
    }
    
    static var asPlaceholderInstance: SharedFoodModel {
      .init(donation: .asPlaceholderInstance,
            recipientCustomer: .init(id: "", fullName: "Customer name", email: "", foodRescuedCount: 0, foodSharedCount: 0))
    }
  }
}
