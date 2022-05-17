//
//  DeliveryTrackingViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/04/22.
//

import Foundation
import Combine

class DeliveryTrackingViewModel: ObservableObject {
  @Published var bottomSheetDisplayType: BottomSheetDisplayType = .minimized
  @Published var showingChatView = false
  @Published private(set) var courierAnnotation: CourierAnnotation?
  
  @Published private(set) var courier: Courier?
  @Published private(set) var deliveryTask: DeliveryTask?
  
//  private var sessionId: String?
  
  private var locationHandle: UInt?
  private let repository: SessionTrackingRepository
  private var courierRepository: CourierRepository? = nil
  private var deliveryTaskRepository: DeliveryTaskRepository? = nil
  private let regionToCourierSubject: PassthroughSubject<Void, Never> = .init()
  
  private var subscriptions: Set<AnyCancellable> = []
  
  var regionToCourierPublisher: AnyPublisher<Void, Never> {
    regionToCourierSubject.eraseToAnyPublisher()
  }
  
  init(
    sessionId: String?,
    courier: Courier?,
    deliveryTask: DeliveryTask?,
    repository: SessionTrackingRepository = SessionTrackingRepository()
  ) {
//    self.sessionId = sessionId
    self.courier = courier
    self.deliveryTask = deliveryTask
    self.repository = repository
    
    if let sessionId = sessionId {
      initializeListener(sessionId: sessionId)
    }
    
  }
  
  convenience init(
    deliveryTaskId: String,
    deliveryTaskRepository: DeliveryTaskRepository = DeliveryTaskRepository(),
    courierRepository: CourierRepository = CourierRepository()
  ) {
    self.init(sessionId: nil, courier: nil, deliveryTask: nil)
    self.deliveryTaskRepository = deliveryTaskRepository
    self.courierRepository = courierRepository
    self.fetchCourierSession(deliveryTaskId: deliveryTaskId)
  }
  
  deinit {
    removeListenerIfExists()
  }
  
  func onTapCourierFocusButton() {
    if bottomSheetDisplayType == .fullScreen {
      bottomSheetDisplayType = .minimized
    }
    regionToCourierSubject.send(())
  }
  
  private func initializeListener(sessionId: String) {
    self.locationHandle = self.repository.listenOnLocation(sesionId: sessionId) { [weak self] session in
      if (self?.courierAnnotation) != nil {
        self?.courierAnnotation?.coordinate = session.coordinate
        self?.courierAnnotation?.course = session.location.course
      } else {
        self?.courierAnnotation = CourierAnnotation(
          latitude: session.location.latitude,
          longitude: session.location.longitude,
          course: session.location.course)
      }
    }
  }
  
  private func removeListenerIfExists() {
    if let locationHandle = locationHandle {
      repository.removeLocationListener(handle: locationHandle)
    }
  }
  
  private func fetchCourierSession(deliveryTaskId: String) {
    deliveryTaskRepository?.getCourierSession(withDeliveryTaskId: deliveryTaskId)
      .flatMap { [weak self] session -> AnyPublisher<Courier, Error> in
        guard let self = self, let session = session else {
          return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
        self.deliveryTask = session.deliveryTask
        self.initializeListener(sessionId: session.courierId)
        return self.courierRepository!.getCourier(withId: session.courierId)
      }
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
          print("completed with error: \(error)")
        }
      }, receiveValue: { [weak self] courier in
        self?.courier = courier
      })
      .store(in: &subscriptions)
  }
  
  private func fetchCourier(courierId: String) {
    
  }
  
}
