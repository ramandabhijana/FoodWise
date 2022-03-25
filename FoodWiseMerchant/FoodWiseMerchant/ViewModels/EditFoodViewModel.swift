//
//  EditFoodViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/02/22.
//

import Foundation
import Combine

class EditFoodViewModel: ObservableObject {
  // MARK: - View State
  @Published var showingImagePicker = false
  @Published var showingCategoryPicker = false
  @Published var showingErrorSnackbar = false
  @Published var showingSubmitSnackbar = false
  @Published var name: String
  @Published var selectedCategories: [FoodCategory]
  @Published var keywords: String
  @Published var description: String
  @Published var discountRate: Float?
  @Published var foodImagesData: [(isNew: Bool, data: Data?)] = .init(
    repeating: (isNew: false, data: nil),
    count: 4)
  @Published var retailPrice: Double? {
    didSet { if retailPrice == nil { retailPrice = 0.00 } }
  }
  
  // This is used to hold image data when the user selected 1/more image
  @Published var newSelectedImageData: Data? = nil {
    willSet {
      guard let newValue = newValue else { return }
      // Look for available index, then set the newValue
      // because it's just appending, no need to set the isNew to true
      for index in foodImagesData.indices {
        if foodImagesData[index].data == nil {
          foodImagesData[index].data = newValue
          return
        }
      }
    }
  }
  
  @Published private(set) var loading: Bool = false
  @Published private(set) var imageValid: Bool = true
  @Published private(set) var nameValid: Bool = true
  @Published private(set) var categoriesValid: Bool = true
  @Published private(set) var keywordValid: Bool = true
  @Published private(set) var retailPriceValid: Bool = true
  @Published private(set) var discountRateValid: Bool = true
  @Published private(set) var errorMessage: String = ""
  @Published private(set) var updatedFood: Food = .asPlaceholderInstance
  
  private var initialFood: Food
  private var initialImageData: [Data?] = .init(repeating: nil, count: 4)
  private let repository: FoodRepository
  private var subscriptions = Set<AnyCancellable>()
  private var backgroundQueue = DispatchQueue(
    label: "NewFoodViewModelQueue",
    qos: .userInitiated
  )
  
  private var displayedPrice: Double? {
    guard let retailPrice = retailPrice,
          let discountRate = discountRate,
          discountRate >= 20.0 else {
      return nil
    }
    return retailPrice - (retailPrice * Double((discountRate * 0.01)))
  }
  private var shouldReuploadAllPhotos: Bool {
    return foodImagesData.filter(\.isNew).count > 0
  }
  private var madeChanges: Bool {
    shouldReuploadAllPhotos
    || (initialImageData != foodImagesData.map(\.data))
    || (initialFood.name != name)
    || (initialFood.categoriesName != selectedCategoriesName)
    || (initialFood.keywordsString != keywords)
    || (initialFood.retailPrice != retailPrice)
    || (initialFood.discountRate != discountRate)
    
  }
  
  // MARK: - Internal properties
  
  // to hold the state of index and data of selected image when the view is about to show image picker to change the image
  var previousIndexAndSelectedImageData: (index: Int, data: Data)? = nil
  let priceFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "id_ID")
    return formatter
  }()
  let decimalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
  }()
  
  var updatedFoodPublisher: AnyPublisher<Food, Never> {
    return $updatedFood.eraseToAnyPublisher()
  }
  var selectedCategoriesName: String {
    return selectedCategories.map(\.name).joined(separator: ", ")
  }
  var photoLimit: Int {
    let notNilElementsCount = foodImagesData.compactMap(\.data).count
    let spaceAvailable = 4 - notNilElementsCount
    return spaceAvailable
  }
  var displayedPriceText: String {
    if let price = displayedPrice {
      return "The displayed price will be \(price.asIndonesianCurrencyString())"
    } else {
      return "Enter appropriate number to preview the final price"
    }
  }
  var buttonDisabled: Bool {
    !(madeChanges && imageValid && nameValid && categoriesValid && keywordValid && retailPriceValid && discountRateValid)
  }
  
  
  init(food: Food, repository: FoodRepository) {
    self.initialFood = food
    self.repository = repository
    self.name = food.name
    self.selectedCategories = food.categories
    self.keywords = food.keywordsString
    self.description = food.description
    self.discountRate = food.discountRate
    self.retailPrice = food.retailPrice
    loadFoodImagesData(with: initialFood.imagesUrl)
  }
  
  private func loadFoodImagesData(with imagesUrl: [URL?]) {
    for (index, imageUrl) in imagesUrl.enumerated() {
      guard let url = imageUrl else { continue }
      URLSession.shared.dataTaskPublisher(for: url)
        .receive(on: DispatchQueue.main)
        .map(\.data)
        .sink { completion in
          
        } receiveValue: { [weak self] imageData in
          self?.initialImageData[index] = imageData
          self?.foodImagesData[index] = (isNew: false, data: imageData)
        }
        .store(in: &subscriptions)
    }
  }
  
  func removeImageData(at index: Int) {
    foodImagesData.remove(at: index)
    // mark the next element's isNew = true to trigger reupload of all data
    foodImagesData.append((isNew: true, data: nil))
  }
  // for document
  
  //
  
  func saveChanges() {
    validateAllInput()
    guard buttonDisabled == false else { return }
    loading = true
    let foodId = initialFood.id
    var imageUploadPublishers: [AnyPublisher<URL, Error>] = []
    if shouldReuploadAllPhotos {
      Publishers.MergeMany(getPictureDataDeletionPublisher())
        .collect()
        .subscribe(on: backgroundQueue)
        .flatMap { [weak self] _ -> AnyPublisher<Food, Error> in
          guard let self = self else {
            return Fail(error: NSError()).eraseToAnyPublisher()
          }
          let allImagesData = self.foodImagesData.map(\.data).compactMap { $0 }
          for (index, datum) in allImagesData.enumerated() {
            let uploadPublisher = StorageService.shared.uploadPictureData(
              datum,
              path: .foodPictures(fileName: "\(foodId)_\(index)")
            ).eraseToAnyPublisher()
            imageUploadPublishers.append(uploadPublisher)
          }
          return self.getUpdateFoodPublisher(imageUploadPublishers: imageUploadPublishers)
        }
        .sink { [weak self] completion in
          self?.handleCompletion(completion)
        } receiveValue: { [weak self] food in
          self?.handleReceiveValue(food)
        }
        .store(in: &subscriptions)
    } else {
      let startIndexOfNewImageData = initialFood.imagesUrl.count
      let newImageDataIndicesRange = (startIndexOfNewImageData..<foodImagesData.count)
      for index in newImageDataIndicesRange {
        guard let datum = foodImagesData[index].data else { continue }
        let uploadPublisher = StorageService.shared.uploadPictureData(
          datum,
          path: .foodPictures(fileName: "\(foodId)_\(index)")
        )
        .eraseToAnyPublisher()
        imageUploadPublishers.append(uploadPublisher)
      }
      getUpdateFoodPublisher(imageUploadPublishers: imageUploadPublishers,
                             appendingImageUrlsToInitialValue: true)
        .sink { [weak self] completion in
          self?.handleCompletion(completion)
        } receiveValue: { [weak self] food in
          self?.handleReceiveValue(food)
        }
        .store(in: &subscriptions)
    }
  }
  
  private func getUpdateFoodPublisher(
    imageUploadPublishers: [AnyPublisher<URL, Error>],
    appendingImageUrlsToInitialValue: Bool = false
  ) -> AnyPublisher<Food, Error> {
    Publishers.MergeMany(imageUploadPublishers)
      .collect()
      .subscribe(on: backgroundQueue)
      .receive(on: DispatchQueue.main)
      .flatMap { [unowned self] imageUrls in
        repository.updateFood(
          withId: initialFood.id,
          name: name,
          imageUrls: {
            if appendingImageUrlsToInitialValue {
              initialFood.imagesUrl.append(contentsOf: imageUrls)
              return initialFood.imagesUrl.compactMap { $0 }
            } else {
              return imageUrls
            }
//            appendingImageUrlsToInitialValue ? initialFood.imagesUrl + imageUrls : imageUrls
            
          }(),
          categories: selectedCategories,
          stock: initialFood.stock,
          keywords: {
            var kywords = keywords.lowercased().components(separatedBy: ", ")
            if !kywords.contains(name.lowercased()) {
              kywords.append(name.lowercased())
            }
            return kywords
          }(),
          description: description,
          retailPrice: retailPrice!,
          discountRate: discountRate!,
          merchantId: initialFood.merchantId)
      }.eraseToAnyPublisher()
  }
  
  private func handleCompletion(_ completion: Subscribers.Completion<Error>) {
    if case .failure(let error) = completion {
      errorMessage = error.localizedDescription
    }
    loading = false
  }
  
  private func handleReceiveValue(_ food: Food) {
    updatedFood = food
  }
  
  private func uploadImageAndUpdateFood(imageUploadPublishers: [AnyPublisher<URL, Error>]) {
    Publishers.MergeMany(imageUploadPublishers)
      .collect()
      .subscribe(on: backgroundQueue)
      .receive(on: DispatchQueue.main)
      .flatMap { [unowned self] imageUrls in
        repository.updateFood(
          withId: initialFood.id,
          name: name,
          imageUrls: imageUrls,
          categories: selectedCategories,
          stock: initialFood.stock,
          keywords: {
            var kywords = keywords.lowercased().components(separatedBy: ", ")
            if !kywords.contains(name.lowercased()) {
              kywords.append(name.lowercased())
            }
            return kywords
          }(),
          description: description,
          retailPrice: retailPrice!,
          discountRate: discountRate!,
          merchantId: initialFood.merchantId)
      }
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.loading = false
      } receiveValue: { [weak self] food in
        self?.updatedFood = food
      }
      .store(in: &subscriptions)
  }
  
  private func getPictureDataDeletionPublisher() -> [AnyPublisher<Void, Error>] {
    let fileNames = initialFood.imagesUrl.indices.map { "\(initialFood.id)_\($0)" }
    var deletionPublishers: [AnyPublisher<Void, Error>] = []
    for fileName in fileNames {
      let publisher = StorageService.shared.deletePictureData(at: .foodPictures(fileName: fileName))
      deletionPublishers.append(publisher)
    }
    return deletionPublishers
  }
  
  
}

// MARK: - Validation
extension EditFoodViewModel {
  private func validateAllInput() {
    nameValid = !name.isEmpty
    categoriesValid = selectedCategories.count > 0
    imageValid = photoLimit < 4
    keywordValid = !keywords.isEmpty
    retailPriceValid = retailPrice ?? -1.0 > 0.0
    discountRateValid = discountRate ?? -1.0 >= 20.0
  }
  
  func validateNameIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    nameValid = !name.isEmpty
  }
  
  func validateCategoriesIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    categoriesValid = selectedCategories.count > 0
  }
  
  func validateImage() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
      // when photoLimit equal to 4 = foodImagesData doesnt contain value
      imageValid = photoLimit < 4
    }
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
    discountRateValid = discountRate ?? -1.0 >= 20.0
  }
}
