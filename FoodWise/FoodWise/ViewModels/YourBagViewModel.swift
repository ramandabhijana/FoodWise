//
//  YourBagViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/03/22.
//

import Foundation
import Combine

class YourBagViewModel: ObservableObject {
  @Published var bagItems: [BagItemModel] = []
  @Published var showingError: Bool = false
  @Published var showingOutOfStockConfirmation: Bool = false
  @Published var showingNotInStockItems: Bool = false
  @Published var isNavigationToCheckoutActive: Bool = false
  @Published private(set) var errorMessage = ""
  @Published private(set) var loadingCheckout = false
  @Published private(set) var loadingBagItems = false {
    willSet {
      if newValue { loadListWithPlaceholderInstances() }
    }
  }
  
  private(set) var merchantId: String?
  private(set) var lineItemsToCheckout: [LineItem] = []
  private(set) var allBagItems: [BagItemModel] = [] {
    didSet {
      bagItems = allBagItems.filter({ $0.food.stock > 0})
    }
  }
  
  private var bagRepository: ShoppingBagRepository
  private var foodRepository: FoodRepository
  
  private var subscriptions = Set<AnyCancellable>()
  
  var outOfStockBagItems: [BagItemModel] {
    allBagItems.filter { $0.food.stock <= 0 }
  }
  var totalPriceString: String {
    let price = NSNumber.init(value: bagItems.map(\.price).reduce(0, +))
    return Self.rpCurrencyFormatter.string(from: price) ?? "-"
  }
  var outOfStockAlertText: String {
    let outOfStockItemsCount = outOfStockBagItems.count
    return "\(outOfStockItemsCount) item\(outOfStockItemsCount > 1 ? "s" : "") can't be checked out"
  }
  
  static let rpCurrencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "id_ID")
    return formatter
  }()
  
  init(
    bagRepository: ShoppingBagRepository = ShoppingBagRepository(),
    foodRepository: FoodRepository = FoodRepository()
  ) {
    self.bagRepository = bagRepository
    self.foodRepository = foodRepository
  }
  
  func fetchBagItems(userId: String) {
    loadingBagItems = true
    getBagItemsPublisher(userId: userId)
      .sink(receiveCompletion: { [weak self] completion in
        self?.loadingBagItems = false
        if case .failure(let error) = completion {
          if let viewModelError = error as? YourBagViewModelError,
             viewModelError == .lineItemsEmpty {
            self?.allBagItems = []
            return
          }
          self?.errorMessage = error.localizedDescription
        }
      }, receiveValue: { [weak self] bagItems in
        self?.allBagItems = bagItems
      })
      .store(in: &subscriptions)
  }
  
  
  func prepareBagCheckout(userId: String) {
    loadingCheckout = true
    getBagItemsPublisher(userId: userId)
      .sink(receiveCompletion: { [weak self] completion in
        if case .failure(let error) = completion {
          if let viewModelError = error as? YourBagViewModelError,
             viewModelError == .lineItemsEmpty {
            self?.allBagItems = []
            return
          }
          self?.errorMessage = error.localizedDescription
        }
        self?.loadingCheckout = false
      }, receiveValue: { [weak self] bagItems in
        
        // Make sure there are at least an item in bag
        guard let self = self,
              self.merchantId != nil,
              !bagItems.isEmpty else { return }
        
        self.allBagItems = bagItems
        
        // Load the items to be carried over to checkout page
        self.lineItemsToCheckout = self.bagItems.map({ bagItem in
          LineItem(id: bagItem.id,
                   foodId: bagItem.food.id,
                   quantity: bagItem.lineItem.quantity,
                   price: bagItem.price,
                   food: bagItem.food)
        })
        
        if self.outOfStockBagItems.isEmpty {
          // we can navigate to checkout page
          self.isNavigationToCheckoutActive = true
        } else {
          self.showingOutOfStockConfirmation = true
        }
      })
      .store(in: &subscriptions)
  }
  
  private func getBagItemsPublisher(userId: String) -> AnyPublisher<[BagItemModel], Error> {
    return bagRepository.getShoppingBag(bagOwnerId: userId)
      .handleEvents(receiveOutput: { [weak self] shoppingBag in
        self?.merchantId = shoppingBag?.merchantShopAtId
      })
      .map(\.?.lineItems)
      .compactMap { $0 }
      .flatMap { [weak self] lineItems -> AnyPublisher<BagItemModel, Error> in
        guard let self = self else {
          return Fail(error: NSError.somethingWentWrong).eraseToAnyPublisher()
        }
        return self.mergedBagItemModels(lineItems: lineItems)
      }
      .reduce([], { $0 + [$1] })
      .eraseToAnyPublisher()
  }
  
  //
  
  //
  
  func updateBagItems(userId: String) {
    bagRepository.updateBagItems(
      newLineItems: bagItems.map(\.lineItem),
      bagOwnerId: userId
    )
    .subscribe(on: DispatchQueue.global(qos: .background))
    .sink { completion in
      if case .failure(let error) = completion {
        print("Bag items were not updated. Error: \(error)")
      }
    } receiveValue: { _ in }
    .store(in: &subscriptions)
  }
  
  func removeItem(lineItem: LineItem, userId: String) {
    bagRepository.removeItemFromBag(lineItem: lineItem, bagOwnerId: userId)
      .sink { completion in
        if case .failure(let error) = completion {
          print("Bag item was not removed. Error: \(error)")
        }
      } receiveValue: { [weak self] _ in
        guard let index = self?.bagItems.firstIndex(where: { $0.id == lineItem.id }) else { return }
        self?.bagItems.remove(at: index)
      }
      .store(in: &subscriptions)
  }
  
  private func mergedBagItemModels(lineItems: [LineItem]) -> AnyPublisher<BagItemModel, Error> {
    guard !lineItems.isEmpty else {
      return Fail(error: YourBagViewModelError.lineItemsEmpty).eraseToAnyPublisher()
    }
    let initialPublisher = bagItemModelPublisher(lineItem: lineItems.first!)
    let remainingItems = Array(lineItems.dropFirst())
    return remainingItems.reduce(initialPublisher) { partialResult, lineItem in
      partialResult
        .merge(with: bagItemModelPublisher(lineItem: lineItem))
        .eraseToAnyPublisher()
    }
  }
  
  private func bagItemModelPublisher(lineItem: LineItem) -> AnyPublisher<BagItemModel, Error> {
    foodRepository.getFood(withId: lineItem.foodId)
      .map { food in
        var updatedQtyLineItem = lineItem
        updatedQtyLineItem.quantity = min(lineItem.quantity, food.stock)
        return BagItemModel(lineItem: updatedQtyLineItem, food: food)
      }
      .eraseToAnyPublisher()
  }
  
  private func loadListWithPlaceholderInstances() {
    bagItems = [.asPlaceholderInstance, .asPlaceholderInstance, .asPlaceholderInstance, .asPlaceholderInstance, .asPlaceholderInstance]
  }
  
  func listenOrderPublisher(_ publisher: AnyPublisher<Order, Never>) {
    bagItems = []
    publisher
      .setFailureType(to: Error.self)
      .flatMap { [weak self] order -> AnyPublisher<Void, Error> in
        guard let self = self else {
          return Fail(error: NSError.somethingWentWrong)
            .eraseToAnyPublisher()
        }
        return self.bagRepository.createBag(withItem: nil,
                                     ownerId: order.customerId,
                                     merchantShopAtId: nil)
      }
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
          
        }
      }, receiveValue: { [weak self] _ in
        self?.isNavigationToCheckoutActive = false
      })
      .store(in: &subscriptions)
  }
  
  private enum YourBagViewModelError: Error {
    case lineItemsEmpty
  }
}

struct BagItemModel: Identifiable {
  var lineItem: LineItem
  var food: Food
  var price: Double { Double(lineItem.quantity) * food.price }
  var id: String { lineItem.id }
  
}

extension BagItemModel {
  static var asPlaceholderInstance: BagItemModel {
    .init(lineItem: .init(id: UUID().uuidString, foodId: "", quantity: 0), food: .asPlaceholderInstance)
  }
}
