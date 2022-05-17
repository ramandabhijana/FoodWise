//
//  NewFoodViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 04/12/21.
//

import Foundation
import Combine

class NewFoodViewModel: ObservableObject {
  @Published var name = ""
  @Published var selectedCategories = [FoodCategory]()
  @Published var stock = ""
  @Published var keywords = ""
  @Published var description = ""
  @Published var discountRate = "20"
  @Published var retailPrice: Double? = 0.0 {
    didSet { if retailPrice == nil { retailPrice = 0.00 } }
  }
  @Published var selectedFoodImageData: Data? = nil {
    willSet {
      if let newValue = newValue {
        for availableIndex in foodImagesData.indices {
          if foodImagesData[availableIndex] == nil {
            foodImagesData[availableIndex] = newValue
            return
          }
        }
      }
    }
  }
  
  @Published private(set) var foodImagesData: [Data?] = .init(repeating: nil, count: 4)
  @Published private(set) var imageValid: Bool? = nil
  @Published private(set) var nameValid: Bool? = nil
  @Published private(set) var categoriesValid: Bool? = nil
  @Published private(set) var stockValid: Bool? = nil
  @Published private(set) var keywordValid: Bool? = nil
  @Published private(set) var retailPriceValid: Bool? = nil
  @Published private(set) var discountRateValid: Bool? = true
  @Published private(set) var errorMessage = ""
  @Published private(set) var loading = false
  @Published private(set) var createdFood: Food? = nil
  
  private var backgroundQueue = DispatchQueue(
    label: "NewFoodViewModelQueue",
    qos: .userInitiated
  )
  private let merchantId: String
  private let foodRepo = FoodRepository()
  private var manageFoodViewModel: ManageFoodViewModel
  private var subscriptions = Set<AnyCancellable>()
  
  private var displayedPrice: Double? {
    guard let retailPrice = retailPrice,
          let discountRate = discountRateValue,
          discountRate >= 20.0 && discountRate <= 100.0 else {
      return nil
    }
    return retailPrice - (retailPrice * Double((discountRate * 0.01)))
  }
  
  var selectedCategoriesName: String {
    selectedCategories.map(\.name).joined(separator: ", ")
  }
  var stockValue: Int { Int(stock)! }
  var discountRateValue: Float? { Float(discountRate) }
  var photoLimit: Int {
    let notNilElementsCount = foodImagesData.compactMap { $0 }.count
    let spaceAvailable = 4 - notNilElementsCount
    return spaceAvailable
  }
  
  var buttonDisabled: Bool {
    guard let imageValid = imageValid,
          let nameValid = nameValid,
          let categoriesValid = categoriesValid,
          let stockValid = stockValid,
          let keywordValid = keywordValid,
          let retailPriceValid = retailPriceValid,
          let discountRateValid = discountRateValid
    else {
      return true
    }
    return !(imageValid && nameValid && categoriesValid && stockValid && keywordValid && retailPriceValid && discountRateValid)
  }
  
  var displayedPriceText: String {
    if let price = displayedPrice {
      return "The displayed price will be \(price.asIndonesianCurrencyString())"
    } else {
      return "Enter appropriate number to preview the final price"
    }
  }
  
  init(merchantId: String, manageFoodViewModel: ManageFoodViewModel) {
    self.merchantId = merchantId
    self.manageFoodViewModel = manageFoodViewModel
  }
  
  func saveFood() {
    precondition(buttonDisabled == false)
    loading = true
    let newFoodId = UUID().uuidString
    var imageUploadPublishers: [AnyPublisher<URL, Error>] = []
    for (index, datum) in foodImagesData.enumerated() {
      guard let datum = datum else { break }
      let uploadPublisher = StorageService.shared.uploadPictureData(
        datum,
        path: .foodPictures(fileName: "\(newFoodId)_\(index)")
      ).eraseToAnyPublisher()
      imageUploadPublishers.append(uploadPublisher)
    }
    
    Publishers.MergeMany(imageUploadPublishers)
      .collect()
      .subscribe(on: backgroundQueue)
      .receive(on: DispatchQueue.main)
      .flatMap { [unowned self] imageUrls in
        foodRepo.createFood(
          withId: newFoodId,
          name: name,
          imageUrls: imageUrls,
          categories: selectedCategories,
          stock: stockValue,
          keywords: {
            var keywords = keywords.lowercased().components(separatedBy: ", ")
            keywords.append(name.lowercased())
            return keywords
          }(),
          description: description,
          retailPrice: retailPrice!,
          discountRate: discountRateValue!,
          merchantId: merchantId)
      }
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.loading = false
      } receiveValue: { [weak self] food in
        print("\n\(food)\n")
        self?.manageFoodViewModel.addFood(food)
        self?.createdFood = food
      }
      .store(in: &subscriptions)
  }
  
  func validateNameIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    nameValid = !name.isEmpty
  }
  
  func validateCategoriesIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    categoriesValid = selectedCategories.count > 0
  }
  
  func validateImageIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
      imageValid = selectedFoodImageData != nil
    }
    
  }
  
  func validateStockIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    stockValid = Int(stock) != nil
  }
  
  func validateKeywordsIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    keywordValid = !keywords.isEmpty
  }
  
  func validateRetailPriceIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    retailPriceValid = retailPrice ?? -1.0 > 0.0
  }
  
  func validateDiscountRateIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    if let discountFloat = Float(discountRate) {
      discountRateValid = discountFloat >= 20.0 && discountFloat <= 100.0
    } else {
      discountRateValid = false
    }
    
  }
  
  
}
