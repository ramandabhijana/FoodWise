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
      if selectedTab != 0 && AuthenticationService.shared.user == nil {
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
            AuthenticationService.shared.signOut()
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
  @State private var navigationController: UINavigationController?
  @State var showsTabBar = true
  @StateObject private var viewModel: RootViewModel
  
  private let tabBarHiddenPublisher = NotificationCenter.default
    .publisher(for: .tabBarHiddenNotification)
    .receive(on: RunLoop.main)
  private let tabBarShownPublisher = NotificationCenter.default
    .publisher(for: .tabBarShownNotification)
    .receive(on: RunLoop.main)
  private let signInRequiredPublisher = NotificationCenter.default
    .publisher(for: .signInRequiredNotification)
    .receive(on: RunLoop.main)
  private let tabBarChangeBackgroundToBackgroundColorPublisher = NotificationCenter.default
    .publisher(for: .tabBarChangeBackgroundToBackgroundColorNotification)
    .receive(on: RunLoop.main)
  private let tabBarChangeBackgroundToSecondaryColorPublisher = NotificationCenter.default
    .publisher(for: .tabBarChangeBackgroundToSecondaryColorNotification)
    .receive(on: RunLoop.main)
  private let navBarChangeBackgroundToPrimaryBackgroundColorPublisher = NotificationCenter.default
    .publisher(for: .navBarChangeBackgroundToPrimaryBackgroundNotification)
    .receive(on: RunLoop.main)
  private let navBarChangeBackgroundToBackgroundColorPublisher = NotificationCenter.default
    .publisher(for: .navBarChangeBackgroundToBackgroundColorNotification)
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
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
  }
  
  var body: some View {
    TabView(selection: $viewModel.selectedTab) {
      HomeView(
        viewModel: .init(),
        categoriesViewModel: .init()
      )
      .tabItem { Label("Home", systemImage: "house") }
      .tag(0)
      
      YourBagView(viewModel: .init())
        .tabItem { Label("Your Bag", systemImage: "bag.fill") }
        .tag(1)
      
      SharedFoodsView(viewModel: .init())
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
    .overlay {
      if viewModel.customer == nil && AuthenticationService.shared.currentUserExist {
        ZStack {
          Color.backgroundColor
            .frame(
              width: UIScreen.main.bounds.width,
              height: UIScreen.main.bounds.height
            )
          ProgressView()
            .progressViewStyle(.circular)
        }
      }
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
    .introspectTabBarController { tabBarController = $0 }
    .introspectNavigationController { navigationController = $0 }
    .onReceive(tabBarHiddenPublisher) { _ in
      tabBarController?.setTabBarHidden(true)
    }
    .onReceive(tabBarShownPublisher) { _ in
      tabBarController?.setTabBarHidden(false)
    }
    .onReceive(tabBarChangeBackgroundToBackgroundColorPublisher) { _ in
      setupTabBarBackgroundColor(withColor: .init(named: "BackgroundColor"))
    }
    .onReceive(tabBarChangeBackgroundToSecondaryColorPublisher) { _ in
      setupTabBarBackgroundColor()
    }
    .onReceive(navBarChangeBackgroundToPrimaryBackgroundColorPublisher) { _ in
      setupNavBarBackgroundColor(withColor: .backgroundColor, scrollEdgeColor: .primaryColor)
    }
    .onReceive(navBarChangeBackgroundToBackgroundColorPublisher) { _ in
      setupNavBarBackgroundColor(withColor: .backgroundColor, scrollEdgeColor: .backgroundColor)
    }
      
      
  }
  
  private func setupTabBarBackgroundColor(withColor uiColor: UIColor? = UIColor(named: "SecondaryColor")) {
    let itemAppearance = UITabBarItemAppearance()
    itemAppearance.selected.iconColor = .darkGray
    itemAppearance.normal.iconColor = .lightGray.withAlphaComponent(0.5)
    
    let appearance = UITabBarAppearance()
    appearance.stackedLayoutAppearance = itemAppearance
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = uiColor
    tabBarController?.tabBar.standardAppearance = appearance
    tabBarController?.tabBar.scrollEdgeAppearance = appearance
  }
  
  private func setupNavBarBackgroundColor(withColor standardColor: UIColor, scrollEdgeColor: UIColor? = nil) {
    let standardAppearance = UINavigationBarAppearance()
    standardAppearance.configureWithTransparentBackground()
    standardAppearance.backgroundColor = standardColor
    
    let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
    buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
    
    standardAppearance.buttonAppearance = buttonAppearance
//    UINavigationBar.appearance().tintColor = .darkGray
//    UINavigationBar.appearance().standardAppearance = standardAppearance
    navigationController?.navigationBar.standardAppearance = standardAppearance
    
    if let scrollEdgeColor = scrollEdgeColor {
      /*
      UINavigationBar.appearance().scrollEdgeAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = scrollEdgeColor
        return appearance
      }()
       */
      navigationController?.navigationBar.scrollEdgeAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = scrollEdgeColor
        return appearance
      }()
    } else {
      UINavigationBar.appearance().scrollEdgeAppearance = nil
    }
    //          UINavigationBar.appearance().scrollEdgeAppearance = appearance
    //    UINavigationBar.appearance().standardAppearance = appearance
    //    UINavigationBar.appearance().tintColor = .black
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
  static let tabBarChangeBackgroundToBackgroundColorNotification = Notification.Name("TabBarChangeBackgroundToBackgroundColorNotification")
  static let tabBarChangeBackgroundToSecondaryColorNotification = Notification.Name("TabBarChangeBackgroundToSecondaryColorNotification")
  static let navBarChangeBackgroundToPrimaryBackgroundNotification = Notification.Name("NavBarChangeBackgroundToPrimaryBackgroundNotification")
  static let navBarChangeBackgroundToBackgroundColorNotification = Notification.Name("NavBarChangeBackgroundToBackgroundColorNotification")
  
}

extension View {
  func setNavigationBarColor(withStandardColor standardColor: Color, andScrollEdgeColor scrollEdgeColor: Color) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
      NotificationCenter.default.post(
        name: .updateNavigationBarNotification,
        object: nil,
        userInfo: ["standardColor": standardColor, "scrollEdgeColor": scrollEdgeColor])
    }
  }
  
  func resetNavigationBar() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
      NotificationCenter.default.post(
        name: .updateNavigationBarNotification,
        object: nil)
    }
  }
}

extension UITabBarController {
  func setTabBarHidden(_ hidden: Bool) {
    tabBar.layer.zPosition = hidden ? -1 : 0
    let enabled = hidden ? false : true
    tabBar.isUserInteractionEnabled = enabled
    tabBar.items?.forEach { $0.isEnabled = enabled }
  }
}

extension UINavigationController: UIGestureRecognizerDelegate {
  open override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationBar.tintColor = UIColor.black
    interactivePopGestureRecognizer?.delegate = self
    NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationBar(_:)), name: .updateNavigationBarNotification, object: nil)
  }
  
  
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return viewControllers.count > 1
  }
  
  @objc func updateNavigationBar(_ notification: NSNotification) {
    if let info = notification.userInfo {
      let standardColor = info["standardColor"] as! Color
      let scrollEdgeColor = info["scrollEdgeColor"] as! Color
      
      let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
      buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
      UINavigationBar.appearance().tintColor = UIColor.black
      
      let standardAppearance = UINavigationBarAppearance()
      standardAppearance.configureWithTransparentBackground()
      standardAppearance.backgroundColor = UIColor(standardColor)
      standardAppearance.buttonAppearance = buttonAppearance
      
      let scrollEdgeAppearance = UINavigationBarAppearance()
      scrollEdgeAppearance.configureWithTransparentBackground()
      scrollEdgeAppearance.backgroundColor = UIColor(scrollEdgeColor)
      scrollEdgeAppearance.buttonAppearance = buttonAppearance
      
      navigationBar.standardAppearance = standardAppearance
      navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
      navigationBar.compactAppearance = standardAppearance
    } else {
      let appearance = UINavigationBarAppearance()
      let transparentAppearance = UINavigationBarAppearance()
      transparentAppearance.configureWithTransparentBackground()
      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = transparentAppearance
      navigationBar.compactAppearance = appearance
    }
  }
}

extension NSNotification.Name {
  static var updateNavigationBarNotification: NSNotification.Name { .init(rawValue: "updateNavigationBarNotification") }
}
