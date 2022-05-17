//
//  WriteReviewViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import Foundation
import Combine

class WriteReviewViewModel: ObservableObject {
  @Published var reviewComments: String = ""
  @Published var showingError: Bool = false
  @Published private(set) var rating: Float = 1.0
  @Published private(set) var loading: Bool = false
  
  private(set) var reviewedItem: LineItem
  private let order: Order
  private let orderIndex: Int
  
  private let reviewSentimentClassifier: CustomerReviewsSentimentClassifier
  private let reviewRepository: ReviewRepository
  private let foodRepository: FoodRepository
  private let orderRepository: OrderRepository
  
  private let itemReviewSubmittedForOrderAtIndexSubject: PassthroughSubject<(LineItem, Int), Never> = .init()
  private var subscriptions: Set<AnyCancellable> = []
  
  var itemReviewSubmittedForOrderAtIndexPublisher: AnyPublisher<(LineItem, Int), Never> {
    itemReviewSubmittedForOrderAtIndexSubject.eraseToAnyPublisher()
  }
  var buttonDisabled: Bool { loading || reviewComments.isEmpty }
  
  init(
    reviewedItem: LineItem,
    order: Order,
    orderIndex: Int,
    reviewSentimentClassifier: CustomerReviewsSentimentClassifier = CustomerReviewsSentimentClassifier(),
    reviewRepository: ReviewRepository = ReviewRepository(),
    foodRepository: FoodRepository = FoodRepository(),
    orderRepository: OrderRepository = OrderRepository()
  ) {
    self.reviewedItem = reviewedItem
    self.order = order
    self.orderIndex = orderIndex
    self.reviewSentimentClassifier = reviewSentimentClassifier
    self.reviewRepository = reviewRepository
    self.foodRepository = foodRepository
    self.orderRepository = orderRepository
  }
  
  deinit {
    itemReviewSubmittedForOrderAtIndexSubject.send(completion: .finished)
  }
  
  func incrementRating() {
    guard rating + 0.5 <= 5.0 else { return }
    rating += 0.5
  }
  
  func decrementRating() {
    guard rating - 0.5 >= 1.0 else { return }
    rating -= 0.5
  }
  
  func submitReview(customer: Customer) {
    loading = true
    
    let sentimentScore: Float = {
      guard let prediction = reviewSentimentClassifier.makePredictionFor(aReview: reviewComments) else {
        return CustomerReviewsSentimentClassifier.NeutralSentimentScore
      }
      return prediction.labelValue
    }()
    
    let reviewAdditionPublisher = reviewRepository.addReview(rating: rating, sentimentScore: sentimentScore, comments: reviewComments, foodId: reviewedItem.foodId, customerId: customer.id, customerName: customer.fullName, customerProfilePicUrl: customer.profileImageUrl)
    let allFoodReviewsPublisher = reviewRepository.getAllReviews(forFoodWithId: reviewedItem.foodId)
    
    reviewAdditionPublisher
      .flatMap { _ in allFoodReviewsPublisher }
      .flatMap { [unowned self] reviews in
        updateFoodReviewAttribute(reviewRecords: reviews)
      }
      .flatMap { [unowned self] _ in updateOrderItems() }
      .sink { [weak self] completion in
        self?.loading = false
        if case .failure(let error) = completion {
          self?.showingError = true
          print("\(String(describing: Self.self)) submit review error: \(error)")
        }
      } receiveValue: { [unowned self] _ in
        itemReviewSubmittedForOrderAtIndexSubject.send((reviewedItem, orderIndex))
      }
      .store(in: &subscriptions)
  }
  
  private func updateFoodReviewAttribute(reviewRecords: [Review]) -> AnyPublisher<Void, Error> {
    let allRatings = reviewRecords.map(\.rating)
    let allSentimentScores = reviewRecords.map(\.sentimentScore)
    let reviewCount = Float(reviewRecords.count)
    
    let overallRating = allRatings.reduce(0.0, +) / reviewCount
    let overallSentimentScore = allSentimentScores.reduce(0.0, +) / reviewCount
    
    return foodRepository.setReviewProperty(forFoodWithId: reviewedItem.foodId, rating: overallRating, reviewCount: reviewRecords.count, sentimentScore: overallSentimentScore)
  }
  
  private func updateOrderItems() -> AnyPublisher<Void, Error> {
    var updatedLineItems = order.items
    let reviewedItemIndex = order.items.firstIndex(where: { $0.id == reviewedItem.id })!
    updatedLineItems[reviewedItemIndex].isReviewed = true
    return orderRepository.updateLineItems(with: updatedLineItems,
                                           forOrderWithOrderId: order.id)
  }
}
