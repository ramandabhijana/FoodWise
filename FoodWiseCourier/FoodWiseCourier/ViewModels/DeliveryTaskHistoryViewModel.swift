//
//  DeliveryTaskHistoryViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 15/05/22.
//

import Foundation
import Combine

class DeliveryTaskHistoryViewModel: ObservableObject {
  @Published var showingError = false
  @Published private(set) var taskHistory: [DeliveryTask] = []
  @Published private(set) var loadingTaskHistory: Bool = false {
    willSet {
      if newValue { loadListWithPlaceholder() }
    }
  }
  
  static let cellAssignedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "'Assigned on' d MMM yyyy"
    return formatter
  }()
  
//  private let courierId: String
  private let repository: TaskHistoryRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  init(courierId: String, repository: TaskHistoryRepository = TaskHistoryRepository()) {
    self.repository = repository
    loadHistory(courierId: courierId)
  }
  
  private func loadHistory(courierId: String) {
    loadingTaskHistory = true
    repository.getCompletedDeliveryTasks(forCourierId: courierId)
      .handleEvents(receiveCompletion: { [weak self] completion in
        if case .failure(let error) = completion {
          print("Failed loading history with error: \(error)")
          self?.showingError = true
        }
        self?.loadingTaskHistory = false
      })
      .replaceError(with: [])
      .assign(to: \.taskHistory, on: self)
      .store(in: &subscriptions)
  }
  
  private func loadListWithPlaceholder() {
    taskHistory = Array(repeating: .asPlaceholder, count: 8)
  }
  
  
  
}
