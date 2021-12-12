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
  @State private var tabBarController: UITabBarController?
  @StateObject private var viewModel: RootViewModel
  
  static private var tabBarFrame: CGRect = .zero
  
  private let tabBarHiddenPublisher = NotificationCenter.default
    .publisher(for: .tabBarHiddenNotification)
    .receive(on: RunLoop.main)
  private let tabBarShownPublisher = NotificationCenter.default
    .publisher(for: .tabBarShownNotification)
    .receive(on: RunLoop.main)
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
      
      Text("")
        .tabItem { Label("Your Bag", systemImage: "bag.fill") }
        .tag(1)
      
      Text("")
        .tabItem { Label("Community", systemImage: "person.3.fill") }
        .tag(2)
      
      MyProfileView()
        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        .tag(3)
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
    .introspectTabBarController {
      tabBarController = $0
      Self.tabBarFrame = $0.tabBar.frame
    }
    .onReceive(tabBarHiddenPublisher) { _ in
      tabBarController?.setTabBarHidden(true, animated: true)
    }
    .onReceive(tabBarShownPublisher) { _ in
      tabBarController?.setTabBarHidden(false, animated: true)
    }
    
  }
}

struct RootSignedInView_Previews: PreviewProvider {
  static var previews: some View {
    RootSignedInView()
  }
}

extension Notification.Name {
  static let tabBarHiddenNotification = Notification.Name("TabBarHiddenNotification")
  
  static let tabBarShownNotification = Notification.Name("TabBarShownNotification")
}

extension UITabBarController {
  /// Extends the size of the `UITabBarController` view frame, pushing the tab bar controller off screen.
  /// - Parameters:
  ///   - hidden: Hide or Show the `UITabBar`
  ///   - animated: Animate the change
  func setTabBarHidden(_ hidden: Bool, animated: Bool) {
    guard let vc = selectedViewController else { return }
    guard tabBarHidden != hidden else { return }
    
    let frame = self.tabBar.frame
    let height = frame.size.height
    let offsetY = hidden ? height : -height
    let safeAreaInset = hidden ? (height - vc.view.window!.safeAreaInsets.bottom) : -height

    UIViewPropertyAnimator(duration: animated ? 0.3 : 0, curve: .easeOut) {
      self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
      self.selectedViewController?.view.frame = CGRect(
        x: 0,
        y: 0,
        width: vc.view.frame.width,
        height: vc.view.frame.height + safeAreaInset
      )
      
      self.view.setNeedsDisplay()
      self.view.layoutIfNeeded()
    }
    .startAnimation()
  }
  
  /// Is the tab bar currently off the screen.
  private var tabBarHidden: Bool {
    tabBar.frame.origin.y >= UIScreen.main.bounds.height
  }
}
