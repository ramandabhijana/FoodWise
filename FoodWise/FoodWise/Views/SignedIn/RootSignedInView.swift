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
  
  enum TabItems: Int, CaseIterable {
    case home, bag, community, more
    
    var itemName: String {
      switch self {
      case .home: return "Home"
      case .bag: return "Your Bag"
      case .community: return "Community"
      case .more: return "More"
      }
    }
    
    var imageSystemName: String {
      switch self {
      case .home: return "house.fill"
      case .bag: return "bag.fill"
      case .community: return "person.3.fill"
      case .more: return "ellipsis.circle.fill"
      }
    }
  }
  
  @Published private(set) var customer: Customer?
  @Published private(set) var showingTabBar: Bool = true
  @Published var selectedTab: TabItems = .home {
    didSet {
      if selectedTab != .home && AuthenticationService.shared.user == nil {
        NotificationCenter.default.post(
          name: .signInRequiredNotification,
          object: nil
        )
      }
    }
  }
  
  private let customerRepo = CustomerRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  private let tabBarHiddenPublisher = NotificationCenter.default
    .publisher(for: .tabBarHiddenNotification)
    .receive(on: RunLoop.main)
  private let tabBarShownPublisher = NotificationCenter.default
    .publisher(for: .tabBarShownNotification)
    .receive(on: RunLoop.main)
  
  init() {
    AuthenticationService.shared.$user
      .dropFirst()
      .drop { $0 != nil }
      .sink { [weak self] _ in
        self?.customer = nil
      }
      .store(in: &subscriptions)
    
    fetchCustomerIfUserExist()
    setupTabBarHiddenPublisher()
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
  
  func incrementFoodSharedCount() {
    guard let customer = customer else { return }
    self.customer?.foodSharedCount! += 1
    customerRepo.incrementFoodSharedCount(forCustomerId: customer.id)
      .replaceError(with: ())
      .sink(receiveValue: { _ in })
      .store(in: &subscriptions)
  }
  
  func incrementFoodRescuedCount() {
    customer?.foodRescuedCount! += 1
  }
  
  func fetchCustomerIfUserExist() {
    if let user = AuthenticationService.shared.signedInUser {
      
      customerRepo.getCustomer(withId: user.uid)
        .sink { [weak self] completion in
          if case .failure(let error) = completion {
            print("Error reading customer: \(error)")
            AuthenticationService.shared.signOut()
            self?.postSignInRequiredIfUserNil()
          }
        } receiveValue: { [weak self] customer in
          self?.customer = customer
        }
        .store(in: &subscriptions)
    }
  }
  
  private func setupTabBarHiddenPublisher() {
    tabBarShownPublisher
      .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
      .sink { [weak self] _ in
        guard self?.showingTabBar != true else { return }
        self?.showingTabBar = true
      }
      .store(in: &subscriptions)
    tabBarHiddenPublisher
      .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
      .sink { [weak self] _ in
        guard self?.showingTabBar != false else { return }
        self?.showingTabBar = false
      }
      .store(in: &subscriptions)
  }
}

struct RootSignedInView: View {
  @State private var presentingOnboardingView = false
  @State private var tabBarController: UITabBarController?
  @State private var navigationController: UINavigationController?
  @State private var tabBarBackgroundColor: Color = .secondaryColor
  @StateObject private var viewModel: RootViewModel
  
  private let tabBarHeight: CGFloat = UITabBarController().tabBar.bounds.height
  
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
  
  private lazy var allMainViews: [RootViewModel.TabItems: AnyView] = {
    [
      .home: AnyView(
        HomeView(
          viewModel: .init(),
          categoriesViewModel: .init())),
      .bag: AnyView(YourBagView(viewModel: .init())),
      .community: AnyView(SharedFoodsView(viewModel: .init())),
      .more: AnyView(MyProfileView())
    ]
  }()
  
  init() {
    _viewModel = StateObject(wrappedValue: RootViewModel())
    
    let segmentedAppearance = UISegmentedControl.appearance()
    segmentedAppearance.selectedSegmentTintColor = .darkGray
    segmentedAppearance.setTitleTextAttributes(
      [.foregroundColor: UIColor.white],
      for: .selected)
    
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
  }
  
  var body: some View {
//    TabView(selection: $viewModel.selectedTab) {
//      HomeView(
//        viewModel: .init(),
//        categoriesViewModel: .init()
//      )
//      .tabItem { Label("Home", systemImage: "house") }
//      .tag(0)
//
//      YourBagView(viewModel: .init())
//        .tabItem { Label("Your Bag", systemImage: "bag.fill") }
//        .tag(1)
//
//      SharedFoodsView(viewModel: .init())
//        .tabItem { Label("Community", systemImage: "person.3.fill") }
//        .tag(2)
//
//      MyProfileView()
//        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
//        .tag(3)
//    }
    makeTabView(with: [
      .home: AnyView(
        HomeView(
          viewModel: .init(),
          categoriesViewModel: .init())),
      .bag: AnyView(LazyView(YourBagView(viewModel: .init()))),
      .community: AnyView(SharedFoodsView(viewModel: .init())),
      .more: AnyView(MyProfileView())
    ])
    .onAppear(perform: viewModel.postSignInRequiredIfUserNil)
    .onReceive(signInRequiredPublisher) { _ in
      print("receive sign in req")
      presentingOnboardingView.toggle()
    }
    .overlay {
      if viewModel.customer == nil && AuthenticationService.shared.currentUserExist {
        VStack {
          Spacer()
          ProgressView()
            .progressViewStyle(.circular)
          Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.backgroundColor)
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
//    .introspectTabBarController { tabBarController = $0 }
    .introspectNavigationController { navigationController = $0 }
//    .onReceive(tabBarHiddenPublisher) { _ in
//      tabBarController?.setTabBarHidden(true)
//      viewModel.showingTabBar = false
//    }
//    .onReceive(tabBarShownPublisher) { _ in
//      print("tabBarShownNotifiation")
//      tabBarController?.setTabBarHidden(false)
//    }
    .onReceive(tabBarChangeBackgroundToBackgroundColorPublisher) { _ in
//      setupTabBarBackgroundColor(withColor: .init(named: "BackgroundColor"))
      tabBarBackgroundColor = .backgroundColor
    }
    .onReceive(tabBarChangeBackgroundToSecondaryColorPublisher) { _ in
      tabBarBackgroundColor = .secondaryColor
//      setupTabBarBackgroundColor()
    }
    .onReceive(navBarChangeBackgroundToPrimaryBackgroundColorPublisher) { _ in
      setupNavBarBackgroundColor(withColor: .backgroundColor, scrollEdgeColor: .primaryColor)
    }
    .onReceive(navBarChangeBackgroundToBackgroundColorPublisher) { _ in
      setupNavBarBackgroundColor(withColor: .backgroundColor, scrollEdgeColor: .backgroundColor)
    }
  }
  
  private func makeTabView(with viewsDictionary: [RootViewModel.TabItems: AnyView]) -> some View {
    return ZStack(alignment: .bottom) {
      Group {
        switch viewModel.selectedTab {
        case .home: viewsDictionary[.home]
        case .bag: LazyView(viewsDictionary[.bag])
        case .community: LazyView(viewsDictionary[.community])
        case .more: LazyView(viewsDictionary[.more])
        }
      }
      .padding(.bottom, viewModel.showingTabBar ? tabBarHeight : 0)
      .animation(.easeIn, value: viewModel.showingTabBar)
      
      VStack(spacing: 0) {
        Divider()
        HStack {
          ForEach(RootViewModel.TabItems.allCases, id: \.self.rawValue) { item in
            Spacer()
            Button(action: { viewModel.selectedTab = item }) {
              VStack {
                Image(systemName: item.imageSystemName)
                  .font(.title2)
                  .foregroundColor(
                    item == viewModel.selectedTab
                      ? Color(uiColor: .darkGray)
                      : Color(uiColor: .lightGray.withAlphaComponent(0.5)))
                Text(item.itemName)
                  .font(.caption2)
                  .foregroundColor(
                    item == viewModel.selectedTab
                      ? .accentColor
                      : Color(uiColor: .lightGray.withAlphaComponent(0.5)))
              }
            }
            Spacer()
          }
        }
        .frame(height: tabBarHeight)
        .background(tabBarBackgroundColor)
        
      }
      .offset(y: viewModel.showingTabBar ? 0 : tabBarHeight*2)
      .animation(.easeIn, value: viewModel.showingTabBar)
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
