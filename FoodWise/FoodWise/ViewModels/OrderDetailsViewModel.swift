//
//  OrderDetailsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/04/22.
//

import Foundation
import Combine

class OrderDetailsViewModel: ObservableObject {
  private(set) var order: Order
  @Published var showingReceipt = false
  @Published private(set) var deliveryTask: DeliveryTask? = nil
  @Published private(set) var merchantNameAndProfilePicUrl: (name: String, picUrl: URL?) = ("Loading...", nil)
  @Published private(set) var courierIdNameAndProfilePicUrl: (id: String, name: String, picUrl: URL?)? = nil
  @Published private(set) var courier: Courier? = nil
  
  private var subscriptions: Set<AnyCancellable> = []
  private(set) var sessionId: String? = nil
  private(set) var deliveryTaskRepository: DeliveryTaskRepository
  private(set) var merchantRepository: MerchantRepository
  private(set) var courierRepository: CourierRepository
  
  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, dd MMMM yyyy"
    return formatter
  }()
  private static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    return formatter
  }()
  
  var orderDateFormatted: String {
    Self.dateFormatter.string(from: order.date.dateValue())
  }
  var orderTimeFormatted: String {
    Self.timeFormatter.string(from: order.date.dateValue())
  }
  var trackLocationButtonDisabled: Bool {
    courier == nil || deliveryTask == nil || sessionId == nil
  }
  var loadingMerchant: Bool {
    merchantNameAndProfilePicUrl.name == "Loading..."
  }
  
  init(
    order: Order,
    deliveryTaskRepository: DeliveryTaskRepository = DeliveryTaskRepository(),
    merchantRepository: MerchantRepository = MerchantRepository(),
    courierRepository: CourierRepository = CourierRepository()
  ) {
    // order to be displayed that was passed in from list of orders
    self.order = order
    self.deliveryTaskRepository = deliveryTaskRepository
    self.merchantRepository = merchantRepository
    self.courierRepository = courierRepository
    fetchMerchant()
    fetchDeliveryTask()
  }
  
  //
  
  
  //
  
  private func fetchDeliveryTask() {
    guard order.pickupMethod == OrderPickupMethod.delivery.rawValue,
          let deliveryTaskId = order.deliveryTaskId
    else { return }
    
    var fetchingPublisher: AnyPublisher<Courier, Error> = Empty().eraseToAnyPublisher()
    
    if order.status == OrderStatus.finished.rawValue {
      let historyRepo = TaskHistoryRepository()
      fetchingPublisher = historyRepo.getDeliveryTask(withTaskId: deliveryTaskId)
        .flatMap { [weak self] history -> AnyPublisher<Courier, Error> in
          guard let self = self,
                let history = history else {
            return Empty(completeImmediately: true).eraseToAnyPublisher()
          }
          self.deliveryTask = history.task
          return self.fetchCourier(courierId: history.courierId)
        }
        .eraseToAnyPublisher()
    } else {
      fetchingPublisher = deliveryTaskRepository.getCourierSession(withDeliveryTaskId: deliveryTaskId)
        .flatMap { [weak self] session -> AnyPublisher<Courier, Error> in
          guard let self = self, let session = session else {
            return Empty(completeImmediately: true).eraseToAnyPublisher()
          }
          self.sessionId = session.courierId
          self.deliveryTask = session.deliveryTask
          return self.fetchCourier(courierId: session.courierId)
        }
        .eraseToAnyPublisher()
    }
    
    fetchingPublisher
      .sink { completion in
        if case .failure(let error) = completion {
          print("completed with error: \(error)")
        }
      } receiveValue: { [weak self] courier in
        self?.courier = courier
      }
      .store(in: &subscriptions)
  }
  
  private func fetchMerchant() {
    merchantRepository.fetchNameAndProfilePictureUrl(ofUserWithId: order.merchantShopFromId)
      .sink { completion in
        if case .failure(let error) = completion {
          print(".getDeliveryTask(withId:) completed with error: \(error)")
        }
      } receiveValue: { [weak self] nameAndUrl in
        self?.merchantNameAndProfilePicUrl.name = nameAndUrl.name
        self?.merchantNameAndProfilePicUrl.picUrl = nameAndUrl.profilePictureUrl
      }
      .store(in: &subscriptions)
  }
  
  private func fetchCourier(courierId: String) -> AnyPublisher<Courier, Error> {
    courierRepository.getCourier(withId: courierId)
  }
  
}
