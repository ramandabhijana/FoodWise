//
//  OnDutyModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 10/04/22.
//

import Foundation
import Combine

class OnDutyModel: ObservableObject {
  @Published var showingFinishedPickingUpItemsAlert = false
  @Published var showingVerificationView = false
  @Published var loading = false
  @Published var showingError = false
  @Published var showingChatRoomWithRequesterView = false
  @Published var showingChatRoomWithUserAtDestinationView = false
  
  // MARK: - Stored Properties
  @Published private(set) var deliveryTask: DeliveryTask
  private(set) var deliveryItems: [DeliveryItem]
  private let mapVisibleRectToInitialSubject: PassthroughSubject<Void, Never> = .init()
  private let dutyFinishedSubject: PassthroughSubject<Void, Never> = .init()
  
  // get set when the delivery items status changed to picked up by courier
  private let courierId: String
  private let customerRepository: CustomerRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  // MARK: - Computed Properties
  var mapVisibleRectToInitialPublisher: AnyPublisher<Void, Never> {
    mapVisibleRectToInitialSubject.eraseToAnyPublisher()
  }
  var dutyFinishedPublisher: AnyPublisher<Void, Never> {
    dutyFinishedSubject.eraseToAnyPublisher()
  }
  @Published private(set) var userAtLocation: (id: String, name: String, profilePicUrl: String, type: String)?
  /*
  var userAtLocation: (id: String, name: String, profilePicUrl: String, type: String) {
    let status = DeliveryStatus.Status(rawValue: deliveryTask.status!.last!.status)
    switch status {
    case .requestAccepted: return deliveryTask.userAtPickupLocation
    case .itemsPickedUp, .received: return deliveryTask.userAtDropOffLocation
    case .none: fatalError()
    }
  }
  */
  
  var currentDestination: (title: String, address: Address) {
    let status = DeliveryStatus.Status(rawValue: deliveryTask.status!.last!.status)
    switch status {
    case .requestAccepted: return ("Pickup Location", deliveryTask.pickupAddress)
    case .itemsPickedUp, .received: return ("Drop-off Location", deliveryTask.dropOffAddress)
    case .none: fatalError()
    }
  }
  
  var mainViewTitle: String {
    let status = DeliveryStatus.Status(rawValue: deliveryTask.status!.last!.status)
    switch status {
    case .requestAccepted: return "Picking up Items"
    case .itemsPickedUp, .received: return "Delivering Items"
    case .none: return ""
    }
  }
  
  var isDeliveringItems: Bool {
    if let currentStatus = deliveryTask.status!.last {
      return currentStatus.status == DeliveryStatus.Status.itemsPickedUp.rawValue
    }
    return false
  }
  
  init(courierId: String,
       initialDeliveryTask: DeliveryTask,
       deliveryTaskPublisher: AnyPublisher<DeliveryTask, Never>,
       customerRepository: CustomerRepository = CustomerRepository()
  ) {
    self.courierId = courierId
    self.deliveryTask = initialDeliveryTask
    self.customerRepository = customerRepository
    self.deliveryItems = {
      if let order = initialDeliveryTask.order {
        return order.items.map { item in
          DeliveryItem(id: item.id,
                       imageUrl: item.food?.imagesUrl.first!,
                       name: item.food!.name,
                       quantity: item.quantity,
                       price: item.price!)
        }
      } else if let donation = initialDeliveryTask.donation {
        return [DeliveryItem(id: donation.id, imageUrl: donation.pictureUrl, name: donation.foodName, quantity: 1, price: 0)]
      } else {
        return []
      }
    }()
    
    // Fetching user at location
    let status = DeliveryStatus.Status(rawValue: deliveryTask.status!.last!.status)
    switch status {
    case .requestAccepted:
      if let userAtPickupLocation = deliveryTask.userAtPickupLocation {
        self.userAtLocation = userAtPickupLocation
      } else if let donorId = deliveryTask.donation?.donorId {
        customerRepository.fetchNameAndProfilePictureUrl(ofUserWithId: donorId)
          .sink { _ in
          } receiveValue: { [weak self] nameAndUrl in
            self?.userAtLocation = (
              id: donorId,
              name: nameAndUrl.name,
              profilePicUrl: nameAndUrl.profilePictureUrl?.absoluteString ?? "",
              type: kCustomerType)
          }
          .store(in: &subscriptions)
      }
    case .itemsPickedUp, .received:
      self.userAtLocation = deliveryTask.userAtDropOffLocation
    case .none: fatalError()
    }
    
    deliveryTaskPublisher
      .assign(to: \.deliveryTask, on: self)
      .store(in: &subscriptions)
    
    NotificationCenter.default
      .publisher(for: OrderVerificationViewModel.didFinishVerificationNotification)
      .sink { [weak self] _ in
        self?.showingVerificationView = false
        self?.loading = true
        self?.finishDuty()
      }
      .store(in: &subscriptions)
  }
  
  func finishPickingUpItems(
    courierId: String,
    repository: CourierSessionRepository,
    completion: @escaping (DeliveryTask) -> Void
  ) {
    // update user at location
    userAtLocation = deliveryTask.userAtDropOffLocation
    repository.setItemPickedUp(for: deliveryTask, courierId: courierId)
      .sink { completion in
        if case .failure(let error) = completion {
          print("setItemPickedUp complete with error \(error)")
        }
      } receiveValue: { task in
        completion(task)
      }
      .store(in: &subscriptions)
  }
  
  func centerVisibleMapRect() {
    mapVisibleRectToInitialSubject.send(())
  }
  
  func finishDuty() {
    let transactionPublisher: AnyPublisher<Void, Error> = {
      if let order = deliveryTask.order,
         order.paymentMethod == OrderPaymentMethod.wallet.rawValue {
        let walletRepository = WalletRepository()
        let transaction = Transaction(date: .now,
                                      amountSpent: deliveryTask.serviceWage,
                                      info: "Delivery wage")
        return walletRepository
          .fetchOrCreateWallet(userId: courierId)
          .flatMap { wallet in
            walletRepository.addNewTransaction(transaction, toWalletWithId: wallet.id)
          }
          .eraseToAnyPublisher()
      }
      return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }()
    
    var finishStatusPublisher: AnyPublisher<Void, Error> = Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    var sharedCountPublisher: AnyPublisher<Void, Error> = Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    var rescuedCountPublisher: AnyPublisher<Void, Error> = Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    
    if let order = deliveryTask.order {
      let repo = OrderRepository()
      finishStatusPublisher = repo.finishOrder(orderWithId: order.id)
      let totalQuantity: Int64 = order.items.reduce(0) { partialResult, lineItem in
        partialResult + Int64(lineItem.quantity)
      }
      rescuedCountPublisher = customerRepository.incrementFoodRescuedCount(
        by: totalQuantity,
        forCustomerId: order.customerId)
    } else if let donation = deliveryTask.donation {
      let repo = DonationRepository()
      finishStatusPublisher = repo.setDonationStatusToReceived(forDonationWithId: donation.id)
      rescuedCountPublisher = customerRepository.incrementFoodRescuedCount(forCustomerId: donation.receiverUserId!)
      sharedCountPublisher = customerRepository.incrementFoodSharedCount(forCustomerId: donation.donorId)
    }
    
    let finishedTaskPublisher = CourierSessionRepository().finishTaskAndRemove(deliveryTask, fromSessionWithId: courierId)
    
    let mergedPublishers = Publishers.MergeMany(
      finishStatusPublisher,
      sharedCountPublisher,
      rescuedCountPublisher
    ).collect()
    
    mergedPublishers
      .flatMap { _ in finishedTaskPublisher }
      .flatMap { [courierId] task in
        TaskHistoryRepository().addCompletedDeliveryTask(
          task,
          forCourierWithId: courierId)
      }
      .flatMap { _ in transactionPublisher }
      .sink { [weak self] completion in
        self?.loading = false
        if case .failure(let error) = completion {
          self?.showingError = true
          print("Error: \(error)")
        }
      } receiveValue: { [weak self] _ in
        self?.dutyFinishedSubject.send(())
      }
      .store(in: &subscriptions)
    
    /*
    TaskHistoryRepository().addCompletedDeliveryTask(
      deliveryTask,
      toHistoryListOfCourierWithId: courierId)
    .sink { [weak self] completion in
      self?.loading = false
      if case .failure(let error) = completion {
        fatalError(error.localizedDescription)
        self?.showingError = true
        print("Error: \(error)")
      }
    } receiveValue: { [weak self] _ in
      self?.dutyFinishedSubject.send(())
    }
    .store(in: &subscriptions)
    */
    
    // add amount if wallet
    // set order status to finish
    // add to task history
    // set deliverytask status
  }
}

extension OnDutyModel {
  struct DeliveryItem: Identifiable {
    let id: String
    let imageUrl: URL?
    let name: String
    let quantity: Int
    let price: Double
  }
}
