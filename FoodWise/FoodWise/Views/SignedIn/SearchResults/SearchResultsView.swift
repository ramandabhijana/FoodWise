//
//  SearchResultsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 12/12/21.
//

import SwiftUI

struct SearchResultsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.managedObjectContext) private var viewContext
  @StateObject private var viewModel: SearchResultViewModel
  @State private var navigationBarHidden = true
  @State private var scrollViewYValue: CGFloat = .zero
  @Namespace var animation
  private static var foodsViewModel: FoodsResultViewModel!
  private static var merchantsViewModel: MerchantsResultViewModel!
  
  init(viewModel: SearchResultViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    Self.foodsViewModel = .init(searchQuery: viewModel.getInitialSearchText)
    Self.merchantsViewModel = .init(searchQuery: viewModel.getInitialSearchText)
    
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = .init(named: "PrimaryColor")
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
  }
  
  var body: some View {
    VStack(spacing: 0) {
      NavigationLink(
        isActive: $viewModel.isSearchResultNavigationActive) {
          LazyView(
            SearchResultsView(viewModel: .init(searchText: viewModel.searchText))
          )
        } label: {
          EmptyView()
        }
      
      VStack(spacing: 8) {
        if !navigationBarHidden {
          HStack {
            Button(
              "\(Image(systemName: "chevron.left"))",
              action: dismiss.callAsFunction
            )
            .font(.title2)
            .tint(.init(uiColor: .darkGray))
            
            TextField("", text: .constant(viewModel.getInitialSearchText))
              .textFieldStyle(.roundedBorder)
              .onTapGesture(perform: viewModel.onBeginSearching)
          }
          .padding(.horizontal)
        }
        
        HStack(spacing: 0) {
          SegmentItemView(
            currentTitle: $viewModel.currentTitle,
            title: SearchResultTitle.foods.rawValue,
            animation: animation
          )
          
          SegmentItemView(
            currentTitle: $viewModel.currentTitle,
            title: SearchResultTitle.merchants.rawValue,
            animation: animation
          )
        }
      }
      .background(Color.primaryColor)
      
      ScrollView(showsIndicators: false) {
        VStack(spacing: 0) {
          GeometryReader { geoproxy -> AnyView in
            print("geoproxy \(geoproxy.frame(in: .global).midY)")
            let midY = geoproxy.frame(in: .global).midY
            if midY < scrollViewYValue && !navigationBarHidden {
              DispatchQueue.main.async {
                scrollViewYValue = midY
                navigationBarHidden = true
              }
            }
            if midY > scrollViewYValue && navigationBarHidden {
              DispatchQueue.main.async {
                scrollViewYValue = midY
                navigationBarHidden = false
              }
            }
            return AnyView(EmptyView())
          }
          .frame(width: 0, height: 0)
          
          switch viewModel.currentTitle {
          case SearchResultTitle.foods.rawValue:
            FoodsResultView(viewModel: Self.foodsViewModel)
          case SearchResultTitle.merchants.rawValue:
            MerchantsResultView(viewModel: Self.merchantsViewModel)
          default:
            EmptyView()
          }
        }
      }
      .background(Color.backgroundColor)
      
    }
    .animation(.easeInOut, value: navigationBarHidden)
    .navigationBarHidden(true)
    .overlay {
      if viewModel.isShowingSearchView {
        SearchView(
          searchText: $viewModel.searchText,
          showing: $viewModel.isShowingSearchView,
          onSubmit: viewModel.onSubmitSearchField
        ).environment(\.managedObjectContext, viewContext)
      }
    }
    .onAppear {
      NotificationCenter.default.post(name: .tabBarHiddenNotification, object: nil)
    }
    /*
    GeometryReader { proxy in
      NavigationView {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            SegmentItemView(
              currentTitle: $currentTitle,
              title: "Foods",
              animation: animation
            )
              
            SegmentItemView(
              currentTitle: $currentTitle,
              title: "Merchants",
              animation: animation
            )
          }
          .background(Color.primaryColor)
          ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
              GeometryReader { geoproxy -> AnyView in
                print("geoproxy \(geoproxy.frame(in: .global).midY)")
                let midY = geoproxy.frame(in: .global).midY
                if midY < scrollViewYValue && !navigationBarHidden {
                  DispatchQueue.main.async {
                    scrollViewYValue = midY
                    navigationBarHidden = true
                  }
                }
                
//                if midY < scrollViewYValue && !navigationBarHidden {
//                  DispatchQueue.main.async {
//                    scrollViewYValue = midY
//                    navigationBarHidden = true
//                  }
//                }
                
                if midY > scrollViewYValue && navigationBarHidden {
                  DispatchQueue.main.async {
                    scrollViewYValue = midY
                    navigationBarHidden = false
                  }
                }
                // print(midY) // scroll down (-), scroll up (+)
//                scrollViewYValue = midY
                return AnyView(EmptyView())
              }
              .frame(width: 0, height: 0)
              
              LazyVStack(spacing: 20) {
                ForEach(0..<10) { num in
                  NearbyMerchantCell(merchant: .init(id: "", name: "Merch name", email: "", storeType: "Resturant", location: .init(lat: 0.0, long: 0.0, geocodedLocation: "Jalan Sekar tunjung"), addressDetails: "", logoUrl: URL(string: "https://assets.grab.com/wp-content/uploads/sites/4/2018/09/17104052/order-grabfood-fast-food-delivery.jpg")))
//                    .onTapGesture {
//                      shownb.toggle()
//                      if shownb {
//                        navigationController?.setNavBarHidden(true, animated: true)
//                      } else {
//                        navigationController?.setNavBarHidden(false, animated: true)
//                      }
//                    }
                }
              }
              .padding(22)
            }
            
          }
          .background(Color.backgroundColor)
//          .simultaneousGesture(
//            DragGesture().onChanged { value in
//              if value.translation.height > 0 {
//                shownb = false
//              } else {
//                shownb = true
//              }
//            }
//          )
          
          
          
          /*
          ScrollView {
            LazyVGrid(
              columns: Array(repeating: .init(spacing: 22), count: 2),
              spacing: 22
            ) {
              ForEach(0..<10) { num in
                FoodCell1(food: .asPlaceholderInstance)
              }
            }.padding(22)
          }
          .background(Color.backgroundColor)
          */
          
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("\(Image(systemName: "chevron.left"))") {
              
            }
            .tint(.init(uiColor: .darkGray))
            .opacity(navigationBarHidden ? 0 : 1)
          }
          
          ToolbarItem(placement: .principal) {
            TextField("", text: .constant("Italian "))
              .textFieldStyle(.roundedBorder)
              .opacity(navigationBarHidden ? 0 : 1)
          }
        }
        
      }
      .frame(height: proxy.size.height + (navigationBarHidden ? 90 : 0))
      .position(
        x: proxy.size.width/2,
        y: proxy.size.height/2 - (navigationBarHidden ? 45 : 0)
      )
      .animation(.easeInOut, value: navigationBarHidden)
    }
    */
  }
}

//struct SearchResultsView_Previews: PreviewProvider {
//  static var previews: some View {
//    SearchResultsView()
//  }
//}

struct FoodsResultView: View {
  @StateObject private var viewModel: FoodsResultViewModel
  
  init(viewModel: FoodsResultViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    LazyVGrid(
      columns: Array(repeating: .init(spacing: 20), count: 2),
      spacing: 20
    ) {
      ForEach(
        viewModel.foods,
        content: FoodCell1.init
      )
      .redacted(reason: viewModel.loading ? .placeholder : [])
    }.padding()
  }
}

struct MerchantsResultView: View {
  @StateObject private var viewModel: MerchantsResultViewModel
  
  init(viewModel: MerchantsResultViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    LazyVStack(spacing: 20) {
      ForEach(
        viewModel.merchants,
        id: \.self,
        content: NearbyMerchantCell.init(merchant:)
      )
      .redacted(reason: viewModel.loading ? .placeholder : [])
    }
    .padding()
    .onAppear(perform: viewModel.fetchMerchants)
  }
}

extension UINavigationController: UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return viewControllers.count > 1
  }
}
