//
//  IncomingDeliveryViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 09/04/22.
//

import Foundation
import Combine

class IncomingDeliveryViewModel: ObservableObject {
  @Published var showingRouteSheet = false
  @Published var showingTimeIsUp = false
  @Published var shouldDismissView = false
  @Published private(set) var secondsLeft: Int = 30
  
  private(set) var deliveryTask: DeliveryTask
  private(set) var deadlineDate: Date
  private(set) var timer: Timer?
  private let acceptedTaskSubject: PassthroughSubject<DeliveryTask, Never> = .init()
  private let repository: CourierSessionRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  var passingDeadline: Bool { Date.now > deadlineDate }
  var wageFormatted: String {
    NumberFormatter.rpCurrencyFormatter.string(from: .init(value: deliveryTask.serviceWage)) ?? "-"
  }
  var timeFormatted: String {
    let formatter: DateComponentsFormatter = {
      let fmt = DateComponentsFormatter()
      fmt.unitsStyle = .brief
      fmt.allowedUnits = [.hour, .minute]
      return fmt
    }()
    return formatter.string(from: deliveryTask.totalTravelTime) ?? "-"
  }
  var distanceFormatted: String {
    String(format: "%.2f km", deliveryTask.totalDistance)
  }
  var timeElapsedText: String { "\(secondsLeft) seconds left" }
  var progressWidthScaleFactor: Double {
    Double(secondsLeft) / 30.0
  }
  var acceptedTaskPublisher: AnyPublisher<DeliveryTask, Never> {
    acceptedTaskSubject.eraseToAnyPublisher()
  }
  
  init(deadlineDate: Date, deliveryTask: DeliveryTask, repository: CourierSessionRepository = CourierSessionRepository()) {
    self.deliveryTask = deliveryTask
    self.deadlineDate = deadlineDate
    self.repository = repository
    setTimer()
  }
  
  private func setTimer() {
    timer = Timer.scheduledTimer(
      timeInterval: 1,
      target: self,
      selector: #selector(updateTime),
      userInfo: nil,
      repeats: true)
  }
  
  func getCountdownDateComponents() -> DateComponents {
    return Calendar.current.dateComponents([.second], from: .now, to: deadlineDate)
  }
  
  @objc func updateTime() {
    guard !passingDeadline else {
      showingTimeIsUp = true
      return
    }
    let countdown = getCountdownDateComponents()
    secondsLeft = countdown.second!
  }
  
  func invalidateTimer() {
    timer?.invalidate()
  }
  
  func resetTimerIfNotPassingDeadline() {
    if !passingDeadline {
      setTimer()
    } else {
      showingTimeIsUp = true
    }
  }
  
  func rejectTask(courierId: String) {
    repository.rejectTask(courierId: courierId)
      .sink { completion in
        if case .failure(let error) = completion {
          print("rejectTask(courierId:) complete with error: \(error)")
        }
      } receiveValue: { [weak self] _ in
        self?.shouldDismissView = true
      }
      .store(in: &subscriptions)
  }
  
  func acceptTask(courierId: String) {
    repository.acceptTask(deliveryTask, courierId: courierId)
      .sink { completion in
        if case .failure(let error) = completion {
          print("acceptTask(courierId:) complete with error: \(error)")
        }
      } receiveValue: { [weak self] updatedTask in
        self?.shouldDismissView = true
        self?.acceptedTaskSubject.send(updatedTask)
        self?.acceptedTaskSubject.send(completion: .finished)
      }
      .store(in: &subscriptions)
  }
  
}

extension NumberFormatter {
  static var rpCurrencyFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "id_ID")
    return formatter
  }
}
