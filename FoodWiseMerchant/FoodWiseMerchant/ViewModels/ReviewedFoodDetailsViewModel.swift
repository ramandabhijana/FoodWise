//
//  ReviewedFoodDetailsViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import Foundation
import Combine

class ReviewedFoodDetailsViewModel: ObservableObject {
  @Published private(set) var reviews: [Review] = []
  @Published private(set) var loading: Bool = false {
    willSet { if newValue { loadReviewsWithPlaceholder() } }
  }
  
  private(set) var reviewedFood: Food
  private let repository: ReviewRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  static let reviewCellDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM yyyy"
    return formatter
  }()
  
  init(reviewedFood: Food,
       repository: ReviewRepository = ReviewRepository()
  ) {
    self.reviewedFood = reviewedFood
    self.repository = repository
    fetchAllReviews()
  }
  
  func fetchAllReviews() {
    loading = true
    repository.getAllReviews(forFoodWithId: reviewedFood.id)
      .sink { [weak self] completion in
        self?.loading = false
        if case .failure(let error) = completion {
          self?.reviews = []
          print("Error: \(error)")
        }
      } receiveValue: { [weak self] reviews in
        self?.reviews = reviews
      }
      .store(in: &subscriptions)
  }
  
  private func loadReviewsWithPlaceholder() {
    reviews = Array(repeating: .asPlaceholder, count: 8)
  }
}
