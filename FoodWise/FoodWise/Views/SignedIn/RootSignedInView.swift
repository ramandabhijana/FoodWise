//
//  RootSignedInView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 04/11/21.
//

import SwiftUI
import Combine

extension Notification.Name {
  static let signInRequiredNotification = Notification.Name("SignInRequiredNotification")
}

class RootViewModel: ObservableObject {
  @Published private(set) var customer: Customer?
  @Published var selectedTab = 0 {
    didSet {
      if selectedTab == 3 && AuthenticationService.shared.user == nil {
        NotificationCenter.default.post(
          name: .signInRequiredNotification,
          object: nil
        )
      }
    }
  }
  
  private let customerRepo = CustomerRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  init() {
    AuthenticationService.shared.$user
      .dropFirst()
      .drop { $0 != nil }
      .sink { [weak self] _ in
        self?.customer = nil
      }
      .store(in: &subscriptions)
    
    fetchCustomerIfUserExist()
  }
  
  func postSignInRequiredIfUserNil() {
    let exist = AuthenticationService.shared.currentUserExist
    if !exist {
      NotificationCenter.default.post(name: .signInRequiredNotification,
                                      object: nil)
    }
  }
  
  func setCustomer(_ customer: Customer) {
    self.customer = customer
  }
  
  func fetchCustomerIfUserExist() {
    if let user = AuthenticationService.shared.signedInUser {
      customerRepo.getCustomer(withId: user.uid)
        .sink { completion in
          if case .failure(let error) = completion {
            print("Error reading customer: \(error)")
          }
        } receiveValue: { [weak self] customer in
          self?.customer = customer
        }
        .store(in: &subscriptions)
    }
  }
}

struct RootSignedInView: View {
  @State private var presentingOnboardingView = false
  @StateObject private var viewModel: RootViewModel
  
  private let signInRequiredPublisher = NotificationCenter.default
    .publisher(for: .signInRequiredNotification)
    .receive(on: RunLoop.main)
  
  init() {
    _viewModel = StateObject(wrappedValue: RootViewModel())
    
    let itemAppearance = UITabBarItemAppearance()
    itemAppearance.selected.iconColor = .darkGray
    itemAppearance.normal.iconColor = .lightGray.withAlphaComponent(0.5)
    
    let appearance = UITabBarAppearance()
    appearance.stackedLayoutAppearance = itemAppearance
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = UIColor(named: "SecondaryColor")
    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
  }
  
  var body: some View {
    TabView(selection: $viewModel.selectedTab) {
      HomeView(
        viewModel: .init(),
        categoriesViewModel: .init()
      )
      .tabItem { Label("Home", systemImage: "house") }
      .tag(0)
//      .introspectTabBarController { tbController in
//        let itemAppearance = UITabBarItemAppearance()
//        itemAppearance.selected.iconColor = .darkGray
//        itemAppearance.normal.iconColor = .lightGray.withAlphaComponent(0.5)
//        let appearance = UITabBarAppearance()
//        appearance.stackedLayoutAppearance = itemAppearance
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(named: "SecondaryColor")
//        tbController.tabBar.standardAppearance = appearance
//        tbController.tabBar.scrollEdgeAppearance = appearance
//      }
      
      Text("")
        .tabItem { Label("Your Bag", systemImage: "bag.fill") }
        .tag(1)
      
      Text("")
        .tabItem { Label("Community", systemImage: "person.3.fill") }
        .tag(2)
      
      MyProfileView()
        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        .tag(3)
//        .introspectTabBarController { tbController in
//          let itemAppearance = UITabBarItemAppearance()
//          itemAppearance.selected.iconColor = .darkGray
//          itemAppearance.normal.iconColor = .lightGray.withAlphaComponent(0.5)
//          let appearance = UITabBarAppearance()
//          appearance.stackedLayoutAppearance = itemAppearance
//          appearance.configureWithTransparentBackground()
//          appearance.backgroundColor = UIColor(named: "BackgroundColor")
//          tbController.tabBar.standardAppearance = appearance
//          tbController.tabBar.scrollEdgeAppearance = appearance
//        }
    }
    .onAppear(perform: viewModel.postSignInRequiredIfUserNil)
    .onReceive(signInRequiredPublisher) { _ in
      print("receive sign in req")
      presentingOnboardingView.toggle()
    }
    .fullScreenCover(isPresented: $presentingOnboardingView) {
      LazyView(
        WelcomeView {
          viewModel.setCustomer($0)
          presentingOnboardingView = false
        }
        
      )
    }
    .environmentObject(viewModel)
  }
}

struct RootSignedInView_Previews: PreviewProvider {
  static var previews: some View {
    RootSignedInView()
  }
}
