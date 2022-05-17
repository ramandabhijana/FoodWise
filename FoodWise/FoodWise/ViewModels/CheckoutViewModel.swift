//
//  CheckoutViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 08/03/22.
//

import Foundation
import Combine
import MapKit

class CheckoutViewModel: ObservableObject {
  @Published var showingAllOrderItems = false
  @Published var showingLocationPicker = false
  @Published var showingTopUpBalance = false
  @Published var showingNotSufficientBalanceAlert = false
  @Published var showingOrderSubmitted = false
  
  @Published private(set) var selectedPickupMethod: PickupMethod? = nil
  @Published private(set) var selectedPaymentMethod: PaymentMethod? = nil
  @Published private(set) var isLoading: Bool = false
  @Published private(set) var isPlacingOrder: Bool = false
  @Published private(set) var merchant: Merchant? = nil
  @Published private(set) var order: Order? = nil
  
  private let orderRepository: OrderRepository
  private let merchantRepository: MerchantRepository
  private var currentDistanceFromMerchant: Measurement<UnitLength>? = nil {
    didSet {
      guard let currentDistanceFromMerchant = currentDistanceFromMerchant else {
        deliveryFee = 0.0
        return
      }
      let firstRate = 1_500.00
      let secondRate = 2_500.00
      let thresholdDistance = Measurement(value: 5.0, unit: UnitLength.kilometers)
      if currentDistanceFromMerchant > thresholdDistance {
        let afterFirstRate = (currentDistanceFromMerchant.value.truncatingRemainder(dividingBy: thresholdDistance.value)) * secondRate
        deliveryFee = firstRate * currentDistanceFromMerchant.value + afterFirstRate
      } else {
        deliveryFee = max(firstRate * currentDistanceFromMerchant.value, firstRate)
      }
    }
  }
  private(set) var walletRepository: WalletRepository
  private(set) var orderItems: [LineItem]
  private(set) var wallet: Wallet? = nil
  
  private lazy var directionsCalculator: DirectionsCalculator = .init()
  private var subscriptions: Set<AnyCancellable> = []
  
  var shippingAddress: Address? = nil
  var firstThreeItems: [LineItem] { Array(orderItems.prefix(3)) }
  var placeOrderButtonDisabled: Bool { selectedPickupMethod == nil || selectedPaymentMethod == nil || isPlacingOrder || (selectedPickupMethod == .delivery && currentDistanceFromMerchant == nil) }
  var subTotalString: String {
    Self.rpCurrencyFormatter.string(from: .init(value: subTotal)) ?? "-"
  }
  var deliveryFeeString: String {
    Self.rpCurrencyFormatter.string(from: .init(value: deliveryFee)) ?? "-"
  }
  var totalCostString: String {
    Self.rpCurrencyFormatter.string(from: .init(value: totalCost)) ?? "-"
  }
  var distanceFromMerchantString: String {
    guard let distance = currentDistanceFromMerchant else { return "" }
    return String(format: "%.2f km", distance.value)
  }
  
  private var subTotal: Double {
    orderItems.map(\.price).compactMap { $0 }.reduce(0, +)
  }
  /*
   FIRST RATE: Rp1.500/km or part thereof for FIRST 5 KM
   SECOND RATE: Rp2.500/km or part thereof AFTER 5 KM
   */
  @Published private(set) var deliveryFee: Double = 0.0
  private var totalCost: Double { subTotal + deliveryFee }
  
  static let rpCurrencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "id_ID")
    return formatter
  }()
  
  init(orderItems: [LineItem],
       merchantId: String,
       walletRepository: WalletRepository = WalletRepository(),
       merchantRepository: MerchantRepository = MerchantRepository(),
       orderRepository: OrderRepository = OrderRepository()
  ) {
    self.orderItems = orderItems
    self.walletRepository = walletRepository
    self.merchantRepository = merchantRepository
    self.orderRepository = orderRepository
    self.merchantRepository.getMerchant(withId: merchantId)
      .sink { completion in
      } receiveValue: { [weak self] merchant in
        self?.merchant = merchant
      }
      .store(in: &subscriptions)
  }
  
  func setSelectedPickupMethod(_ method: PickupMethod) {
    selectedPickupMethod = method
  }
  
  func setSelectedPaymentMethod(_ method: PaymentMethod) {
    selectedPaymentMethod = method
  }
  
  func currencyString(from price: Double) -> String {
    Self.rpCurrencyFormatter.string(from: .init(value: price)) ?? "Rp0"
  }
  
  func updateDistance() {
    guard let shippingAddress = shippingAddress,
          let merchant = merchant else {
            currentDistanceFromMerchant = nil
            return
    }
    /*
    let distanceFromSelectedAddress = merchant.location
      .asClLocation
      .distance(from: shippingAddress.clLocation)
    let distanceInKm = Measurement(
      value: distanceFromSelectedAddress,
      unit: UnitLength.meters
    ).converted(to: .kilometers)
    */
    let pickupLocation = MKMapItem(placemark: .init(coordinate: merchant.location.asClLocation.coordinate))
    let dropOffLocation = MKMapItem(placemark: .init(coordinate: shippingAddress.clLocation.coordinate))
    directionsCalculator.calculateRoute(from: pickupLocation, to: dropOffLocation)
      .sink { completion in
        if case .failure(let error) = completion {
          print("unable to get route with error: \(error)")
        }
      } receiveValue: { [weak self] route in
        self?.currentDistanceFromMerchant = Measurement(
          value: route.distance,
          unit: UnitLength.meters).converted(to: .kilometers)
      }
      .store(in: &subscriptions)
  }
  
  func verifyWalletBalance(userId: String) {
    isLoading = true
    walletRepository.fetchOrCreateWallet(userId: userId)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
//          self?.errorMessage = error.localizedDescription
        }
        self?.isLoading = false
      } receiveValue: { [weak self] wallet in
        guard let self = self else { return }
        self.wallet = wallet
        if wallet.balance < self.totalCost {
          self.showingNotSufficientBalanceAlert = true
        } else {
          self.setSelectedPaymentMethod(.wallet)
        }
      }
      .store(in: &subscriptions)
  }
  
  func listenTransactionPublisher(_ publisher: AnyPublisher<Transaction, Never>) {
    publisher
      .map(\.amountSpent)
      .sink(receiveValue: { [weak self] amount in
        guard let self = self else { return }
        self.wallet?.balance += amount
        self.showingTopUpBalance = false
        if (self.wallet?.balance ?? .zero) >= self.totalCost {
          self.setSelectedPaymentMethod(.wallet)
        }
      })
      .store(in: &subscriptions)
  }
  
  func placeOrder(customer: Customer) {
    guard let selectedPickupMethod = selectedPickupMethod,
          let selectedPaymentMethod = selectedPaymentMethod,
          let merchant = merchant
    else {
      return
    }

    isPlacingOrder = true
    
    let paymentMethod: OrderPaymentMethod = {
      switch selectedPaymentMethod {
      case .cash: return .cash
      case .wallet: return .wallet
      }
    }()
    let pickupMethod: OrderPickupMethod = {
      switch selectedPickupMethod {
      case .delivery: return .delivery
      case .selfPickup: return .selfPickup
      }
    }()
    
    let transactionPublisher = selectedPaymentMethod == .wallet
    ? walletRepository.addNewTransaction(
      Transaction(
        date: .now,
        amountSpent: -(totalCost),
        info: "Pay Order"
      ),
      toWalletWithId: wallet!.id)
    : Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    
    let createOrderPublisher = orderRepository.createOrder(paymentMethod: paymentMethod, pickupMethod: pickupMethod, total: totalCost, deliveryCharge: deliveryFee, subtotal: subTotal, items: orderItems, merchantShopFromId: merchant.id, customerId: customer.id, customerProfilePicUrl: customer.profileImageUrl?.absoluteString ?? "", customerName: customer.fullName, customerEmail: customer.email, walletId: wallet?.id, shippingAddress: shippingAddress)
    
    transactionPublisher
      .flatMap { _ in createOrderPublisher }
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          print("Failed to createOrder with error: \(error)")
        }
      } receiveValue: { [weak self] order in
        self?.showingOrderSubmitted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self?.showingOrderSubmitted = false
          self?.isPlacingOrder = false
          self?.order = order
        }
      }
      .store(in: &subscriptions)
  }
  
  
}

extension CheckoutViewModel {
  enum PickupMethod: String {
    case selfPickup = "Self-pickup"
    case delivery = "Delivery"
  }
  
  enum PaymentMethod: String {
    case cash = "Cash"
    case wallet = "Wallet"
  }
}

