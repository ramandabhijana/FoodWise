//
//  FoodRatingReviewsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import Foundation
import Combine

class FoodRatingReviewsViewModel: ObservableObject {
  @Published var selectedRating: Int = -1
  @Published private var reviews: [Review] = []
  @Published private(set) var loading: Bool = false
  
  private let repository: ReviewRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  static let reviewCellDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM yyyy"
    return formatter
  }()

  
  var filteredReviews: [Review] {
    reviews.filter { review -> Bool in
      let selectedRatingFloat = Float(selectedRating)
      return selectedRatingFloat == -1.0 || selectedRatingFloat...(selectedRatingFloat + 0.5) ~= review.rating
    }
  }
  var isFilteringByRating: Bool {
    selectedRating != -1
  }
  
  init(foodId: String, repository: ReviewRepository) {
    self.repository = repository
    fetchReviewsForFood(withId: foodId)
  }
  
  func fetchReviewsForFood(withId foodId: String) {
    loading = true
    repository.getAllReviews(forFoodWithId: foodId)
      .sink { [weak self] completion in
        self?.loading = false
        if case .failure(let error) = completion {
          print("Error fetching all reviews: \(error)")
          self?.reviews = []
        }
      } receiveValue: { [weak self] reviews in
        self?.reviews = reviews.sorted(by: { $0.date > $1.date })
      }
      .store(in: &subscriptions)
  }
  
  func resetRatingFilter() {
    selectedRating = -1
  }
  
}
