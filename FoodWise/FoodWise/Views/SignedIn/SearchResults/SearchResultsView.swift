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
      VStack(spacing: 8) {
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
//    .onAppear {
      
//      NotificationCenter.default.post(name: .tabBarHiddenNotification, object: nil)
//    }
    .background {
      NavigationLink(isActive: $viewModel.isSearchResultNavigationActive) {
        LazyView(
          SearchResultsView(viewModel: .init(searchText: viewModel.searchText))
        )
      } label: {
        EmptyView()
      }
    }
  }
}

//struct SearchResultsView_Previews: PreviewProvider {
//  static var previews: some View {
//    SearchResultsView()
//  }
//}

struct FoodsResultView: View {
  @StateObject private var viewModel: FoodsResultViewModel
  @EnvironmentObject private var rootViewModel: RootViewModel
  
  init(viewModel: FoodsResultViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    if viewModel.foods.isEmpty {
      VStack {
        Image("empty_list")
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)
        Text("No results can be shown").font(.subheadline)
      }
      .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    } else {
      LazyVGrid(
        columns: Array(repeating: .init(spacing: 20), count: 2),
        spacing: 20
      ) {
        ForEach(
          viewModel.foods,
          content: makeListCell(food:)
        )
        .redacted(reason: viewModel.loading ? .placeholder : [])
      }.padding()
    }
  }
  
  func makeListCell(food: Food) -> some View {
    FoodCell1(
      food: food,
      isLoading: viewModel.loading,
      buildDestination: FoodDetailsView(
        viewModel: .init(
          food: food,
          customerId: rootViewModel.customer?.id,
          foodRepository: viewModel.foodRepository
        )
      )
    )
    /*
    NavigationLink {
      LazyView(FoodDetailsView(
        viewModel: .init(food: food,
                         customerId: rootViewModel.customer?.id,
                         foodRepository: viewModel.foodRepository))
      )
    } label: {
      FoodCell1(food: food)
    }
    */
  }
}

struct MerchantsResultView: View {
  @StateObject private var viewModel: MerchantsResultViewModel
  
  init(viewModel: MerchantsResultViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    if viewModel.merchants.isEmpty {
      VStack {
        Image("empty_list")
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)
        Text("No results can be shown").font(.subheadline)
      }
      .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    } else {
      LazyVStack(spacing: 20) {
        ForEach(
          viewModel.merchants,
          id: \.self,
          content: buildCell
        )
        .redacted(reason: viewModel.loading ? .placeholder : [])
      }
      .padding()
      .onAppear(perform: viewModel.fetchMerchants)
    }
  }
  
  private func buildCell(_ merchant: Merchant?) -> some View {
    NearbyMerchantCell(merchant: merchant, buildDestination: LazyView(MerchantDetailsView(viewModel: .init(merchant: merchant!))))
  }
}
