//
//  NearbyViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 10/12/21.
//

import Foundation
import Combine
import CoreLocation

class NearbyViewModel: ObservableObject {
  enum ViewMode: Int {
    case list
    case map
  }
  
  @Published private var filteredMerchants: [NearbyMerchants] = []
  @Published private(set) var currentLocationString = "Loading Location"
  @Published var viewMode = ViewMode.list
  
  private let locationManager = LocationManager.shared
  private let merchantRepository = MerchantRepository()
  private var subscriptions = Set<AnyCancellable>()
  private var allNearbyMerchants: [NearbyMerchants] = []
  private let backgroundQueue = DispatchQueue(
    label: "NearbyViewModel",
    qos: .userInitiated
  )
  private var currentUserLocation: CLLocation? {
    willSet {
      if let location = currentUserLocation {
        Task { await geocodeLocation(location) }
      }
    }
    didSet {
      fetchMerchants()
    }
  }
  var filteredMerchantsPublisher: AnyPublisher<[NearbyMerchants], Never> {
    $filteredMerchants.dropFirst().share().eraseToAnyPublisher()
  }
  
  init() {
    locationManager.startMonitoring()
    locationManager.locationPublisher
      .sink { [weak self] _ in
        self?.locationManager.stopLocationService()
      } receiveValue: { [weak self] userLocation in
        self?.currentUserLocation = userLocation
      }
      .store(in: &subscriptions)
  }
  
  private func fetchMerchants() {
    merchantRepository.getAllMerchants()
      .map { [weak self] merchants -> [NearbyMerchants] in
        guard let self = self else { return [] }
        return self.getNearbyMerchants(merchants)
      }
      .subscribe(on: backgroundQueue)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        print(completion)
      } receiveValue: { [weak self] nearbyMerchants in
        self?.allNearbyMerchants = nearbyMerchants
        self?.filteredMerchants = nearbyMerchants.filter { $0.radius == .oneKm }
      }
      .store(in: &subscriptions)
  }
  
  func onRadiusChanged(radius: NearbyRadius) {
    if let index = allNearbyMerchants.indexOf(radius) {
      filteredMerchants = Array(allNearbyMerchants.prefix(through: index))
    }
  }
  
  private func getNearbyMerchants(_ merchants: [Merchant]) -> [NearbyMerchants] {
    guard let currentUserLocation = currentUserLocation else { return [] }
    var nearbyMerchants = NearbyRadius.allCases.map(NearbyMerchants.init(radius:))
    merchants.forEach { merchant in
      let distanceFromUser = merchant.location
        .asClLocation
        .distance(from: currentUserLocation)
      let distanceInKm = Measurement(
        value: distanceFromUser,
        unit: UnitLength.meters
      ).converted(to: .kilometers)
      if distanceInKm <= NearbyRadius.oneKm.asMeasurement {
        nearbyMerchants[.oneKm].append(merchant)
      } else if distanceInKm <= NearbyRadius.threeKm.asMeasurement {
        nearbyMerchants[.threeKm].append(merchant)
      } else if distanceInKm <= NearbyRadius.fiveKm.asMeasurement {
        nearbyMerchants[.fiveKm].append(merchant)
      } else if distanceInKm <= NearbyRadius.sevenKm.asMeasurement {
        nearbyMerchants[.sevenKm].append(merchant)
      }
    }
    return nearbyMerchants
  }
  
  @MainActor
  private func geocodeLocation(_ location: CLLocation) async {
    do {
      currentLocationString = try await Geocoder.shared.reverseGeocode(location: location)
    } catch let error as GeocodingError {
      currentLocationString = error.rawValue
    } catch {
      print(error)
    }
  }
}

struct NearbyMerchants {
  let radius: NearbyRadius
  var merchants: [Merchant] = []
  
  init(radius: NearbyRadius) {
    self.radius = radius
  }
}

enum NearbyRadius: Double, CaseIterable {
  case oneKm = 1.0
  case threeKm = 3.0
  case fiveKm = 5.0
  case sevenKm = 7.0
  
  var asMeasurement: Measurement<UnitLength> {
    Measurement(value: self.rawValue,
                unit: UnitLength.kilometers)
  }
  
  var asString: String {
    String(format: "%.0f Km", self.rawValue)
  }
}

extension Array where Element == NearbyMerchants {
  subscript(radius: NearbyRadius) -> [Merchant] {
    get {
      if let searchedMerchant = self.first(where: { $0.radius == radius }) {
        return searchedMerchant.merchants
      }
      fatalError("Cannot found merchants in radius: \(radius). Be sure to initialize before accessing")
    }
    set {
      if let index = indexOf(radius) {
        self[index].merchants = newValue
      } else {
        fatalError("Index not found for radius: \(radius)")
      }
    }
  }
  
  func indexOf(_ radius: NearbyRadius) -> Int? {
    firstIndex(where: { $0.radius == radius })
  }
}

extension MerchantLocation {
  var asClLocation: CLLocation { .init(latitude: lat, longitude: long) }
}
