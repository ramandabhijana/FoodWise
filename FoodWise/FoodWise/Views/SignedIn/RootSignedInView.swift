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
  private let appDidBecomeActivePublisher = NotificationCenter.Publisher(
    center: .default,
    name: UIApplication.didBecomeActiveNotification)
  
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
    .introspectTabBarController { tabBarController = $0 }
    .onReceive(tabBarHiddenPublisher) { _ in
//      tabBarController?.setTabBarHidden(true, animated: true)
//      showsTabBar = false
//      tabBarController?.setTabBar(hidden: true, animated: true, along: nil)
//      tabBarController?.tabBar.isHidden = true
//      tabBarController?.tabBar.layer.zPosition = -1
//      tabBarController?.tabBar.isUserInteractionEnabled = false
      tabBarController?.setTabBarHidden(true)
    }
    .onReceive(tabBarShownPublisher) { _ in
//      tabBarController?.setTabBarHidden(false, animated: true)
//      showsTabBar = true
//      tabBarController?.setTabBar(hidden: false, animated: true, along: nil)
//      tabBarController?.tabBar.isHidden = false
//      tabBarController?.tabBar.layer.zPosition = 0
//      tabBarController?.tabBar.isUserInteractionEnabled = true
//      tabBarController?.tabBar.items
      tabBarController?.setTabBarHidden(false)
      
    }
    .onReceive(tabBarChangeBackgroundToBackgroundColorPublisher) { _ in
      setupTabBarBackgroundColor(withColor: .init(named: "BackgroundColor"))
    }
    .onReceive(tabBarChangeBackgroundToSecondaryColorPublisher) { _ in
      setupTabBarBackgroundColor()
    }
    .onReceive(appDidBecomeActivePublisher) { _ in
//      print("\ntabBar.ishidden: \(tabBarController?.tabBar.isHidden)\nTabbarhidden: \(tabBarController?.tabBarHidden)")
//      tabBarController?.updateTabBarFrame()
//      tabBarController?.setTabBar(hidden: true, animated: false, along: nil)
      
//      tabBarController?.setTabBar(hidden: !showsTabBar, animated: true, along: nil)
      
      
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
}

extension UITabBarController {
  func setTabBarHidden(_ hidden: Bool) {
    tabBar.layer.zPosition = hidden ? -1 : 0
    let enabled = hidden ? false : true
    tabBar.isUserInteractionEnabled = enabled
    tabBar.items?.forEach { $0.isEnabled = enabled }
  }
  
  func setTabBar(
    hidden: Bool,
    animated: Bool = true,
    along transitionCoordinator: UIViewControllerTransitionCoordinator? = nil
  ) {
    
    guard tabBarHidden != hidden else { return }
    
    let offsetY = hidden ? tabBar.frame.height : -tabBar.frame.height
    let endFrame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
    let vc: UIViewController? = viewControllers?[selectedIndex]
    var newInsets: UIEdgeInsets? = vc?.additionalSafeAreaInsets
    let originalInsets = newInsets
    newInsets?.bottom -= offsetY
    
    /// Helper method for updating child view controller's safe area insets.
    func set(childViewController cvc: UIViewController?, additionalSafeArea: UIEdgeInsets) {
      cvc?.additionalSafeAreaInsets = additionalSafeArea
      cvc?.view.setNeedsLayout()
    }
    
    // Update safe area insets for the current view controller before the animation takes place when hiding the bar.
    if hidden, let insets = newInsets {
      set(childViewController: vc, additionalSafeArea: insets)
    }
    
    guard animated else {
      tabBar.frame = endFrame
      return
    }
    
    // Perform animation with coordinato if one is given. Update safe area insets _after_ the animation is complete,
    // if we're showing the tab bar.
    weak var tabBarRef = self.tabBar
    UIView.animate(
      withDuration: 0.3,
      animations: {
        tabBarRef?.frame = endFrame
//        tabBarRef?.isHidden = hidden
      },
      completion: { completed in
      if !hidden,
         completed,
         let insets = newInsets {
        set(childViewController: vc, additionalSafeArea: insets)
      }
    })
  }
  
  /// `true` if the tab bar is currently hidden.
  var isTabBarHidden: Bool {
    return !tabBar.frame.intersects(view.frame)
  }
  
  /// Extends the size of the `UITabBarController` view frame, pushing the tab bar controller off screen.
  /// - Parameters:
  ///   - hidden: Hide or Show the `UITabBar`
  ///   - animated: Animate the change
  func setTabBarHidden(_ hidden: Bool, animated: Bool) {
    guard let vc = selectedViewController,
//          tabBar.isHidden != tabBarHidden else { return }
          tabBarHidden != hidden else { return }
    
    let frame = self.tabBar.frame
    let height = frame.size.height
    let offsetY = hidden ? height : -height
    print("\nvc height + offsetY: \(vc.view.frame.height + offsetY)\n") // 896 & 979
    // 847 & 930
    UIViewPropertyAnimator(duration: animated ? 0.3 : 0, curve: .easeOut) {
//      self.selectedViewController
      self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
//      self.selectedViewController?.view.frame = CGRect(
//        x: 0,
//        y: 0,
//        width: vc.view.frame.width,
//        height: vc.view.frame.height + offsetY
//      )
      self.selectedViewController?.additionalSafeAreaInsets.bottom = .zero
      self.view.setNeedsDisplay()
      self.view.layoutIfNeeded()
      self.tabBar.isHidden = hidden
    }
    .startAnimation()
    
//
    
  }
  
  /*
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
//    guard isTabBarHidden != hidden else { return }
    
    let offsetY = tabBar.frame.height
    let endFrame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
    let vc: UIViewController? = viewControllers?[selectedIndex]
    var newInsets: UIEdgeInsets? = vc?.additionalSafeAreaInsets
    let originalInsets = newInsets
    newInsets?.bottom -= offsetY
    
    /// Helper method for updating child view controller's safe area insets.
    func set(childViewController cvc: UIViewController?, additionalSafeArea: UIEdgeInsets) {
      cvc?.additionalSafeAreaInsets = additionalSafeArea
      cvc?.view.setNeedsLayout()
    }
    
    // Update safe area insets for the current view controller before the animation takes place when hiding the bar.
//    if hidden, let insets = newInsets {
//      set(childViewController: vc, additionalSafeArea: insets)
//    }
    
    // Perform animation with coordinato if one is given. Update safe area insets _after_ the animation is complete,
    // if we're showing the tab bar.
    weak var tabBarRef = self.tabBar
    UIView.animate(
      withDuration: 0.3,
      animations: {
        tabBarRef?.frame = endFrame
      },
      completion: { completed in
//      if !hidden,
//         completed,
//         let insets = newInsets {
//        set(childViewController: vc, additionalSafeArea: insets)
//      }
    })
    
    
//    if tabBar.isHidden && !isTabBarHidden {
//      setTabBar(hidden: true, animated: true, along: nil)
//    }
  }
   */
  
//  open override func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//    if tabBar.isHidden && !tabBarHidden {
//      guard let vc = selectedViewController else { return }
//      print("\nvc height didlayout\(vc.view.frame.height)\n")
//      let frame = self.tabBar.frame
//      let height = frame.size.height
//      UIViewPropertyAnimator(duration: 0, curve: .easeOut) {
//        self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: height)
//        self.selectedViewController?.view.frame = CGRect(
//          x: 0,
//          y: 0,
//          width: vc.view.frame.width,
//          height: vc.view.frame.height + height)
//        self.selectedViewController?.additionalSafeAreaInsets.bottom =  self.view.safeAreaInsets.bottom
//        self.view.setNeedsDisplay()
//        self.view.layoutIfNeeded()
//      }
//      .startAnimation()
//    }
//  }
  
  func updateTabBarFrame() {
//    if tabBar.isHidden && !tabBarHidden {
//      setTabBarHidden(true, animated: false)
//    }
    /*
    if tabBar.isHidden && !tabBarHidden {
      // (CGRect) $R0 = (origin = (x = 0, y = 813), size = (width = 414, height = 83))
      DispatchQueue.main.async {
        var tabBarFrame = self.tabBar.frame
        tabBarFrame.origin.y += tabBarFrame.size.height
        self.tabBar.frame = tabBarFrame
        self.tabBar.setNeedsDisplay()
        self.tabBar.layoutIfNeeded()
      }
      
//      tabBar.frame.origin.y = tabBarFrame.origin.y
//      self.view.setNeedsDisplay()
//      self.view.layoutIfNeeded()
      
//      let vc = selectedViewController
//      vc?.additionalSafeAreaInsets.bottom = -(tabBarFrame.height - view.safeAreaInsets.bottom)
      
      
//      view.setNeedsDisplay()
//      view.layoutIfNeeded()
    }
     */
  }
  
  /// Is the tab bar currently off the screen.
  var tabBarHidden: Bool {
    return tabBar.frame.origin.y >= UIScreen.main.bounds.height
  }
}
