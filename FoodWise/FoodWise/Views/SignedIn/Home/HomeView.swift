//
//  HomeView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 01/11/21.
//

import SwiftUI
import Introspect
import Combine

struct HomeView: View {
  @EnvironmentObject private var rootViewModel: RootViewModel
  @StateObject private var viewModel: HomeViewModel
  @StateObject private var categoriesViewModel: CategoriesViewModel
  // categoriesvm
  @State private var selectedCategory: CategoryButtonModel? = nil
  @State private var categorySelected = false
  @State private var showsSearchView = false
  @State private var navigationBar: UINavigationBar? = nil
  
  init(viewModel: HomeViewModel, categoriesViewModel: CategoriesViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _categoriesViewModel = StateObject(wrappedValue: categoriesViewModel)
  }
  
  var body: some View {
    NavigationView {
      ZStack {
        ScrollView(showsIndicators: false) {
          
          LazyVStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20)
              .fill(Color.primaryColor)
              .padding(.top, -50)
              .frame(
                width: UIScreen.main.bounds.width,
                height: 60)
            
            PageView()
              .frame(
                height: UIScreen.main.bounds.width * 0.5
              )
              .padding(.top, -60)
            
            
            CategoriesView(viewModel: categoriesViewModel)
            
            ForEach(Food.homeSection, id: \.self) { section in
              HorizontalListView(
                sectionName: section.name,
                viewModel: .init(
                  foodRepository: viewModel.foodRepository,
                  criteria: section.criteria,
                  onChangeOfSelectedCategory: categoriesViewModel.selectedCategoryPublisher
                ))
            }
            .animation(nil, value: showsSearchView)
          }
          .background(Color.backgroundColor)
          
        }
        .background(Color.primaryColor)
//        .edgesIgnoringSafeArea(.bottom)
//        .onAppear {
//          let a2 = UINavigationBarAppearance()
//          a2.configureWithDefaultBackground()
//          a2.backgroundColor = .init(named: "BackgroundColor")
//          navigationBar?.standardAppearance = a2
//        }
        
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          TextField(
            "Search for foods or eateries",
            text: .constant("")
          )
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .onTapGesture { showsSearchView.toggle() }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack {
            
            Button("\(Image(systemName: "envelope.fill"))") {

            }
            NavigationLink("\(Image(systemName: "heart.fill"))") {
              LazyView(
                FavoriteFoodsView(viewModel: .init(
                  customerId: rootViewModel.customer?.id,
                  foodRepository: viewModel.foodRepository))
              )
            }
          }
          .foregroundColor(.init(uiColor: .darkGray))
        }
        
      }
      .introspectNavigationController { controller in
        navigationBar = controller.navigationBar
        let a2 = UINavigationBarAppearance()
        a2.configureWithDefaultBackground()
        a2.backgroundColor = .init(named: "BackgroundColor")
        navigationBar?.standardAppearance = a2
      }
    }
    .overlay {
      if showsSearchView {
        SearchingView(
          searchText: .constant(""),
          showing: $showsSearchView,
          onSubmit: .constant({ })
        )
      }
    }
  }
}

//struct HomeView_Previews: PreviewProvider {
//  static var previews: some View {
//    HomeView(viewModel: .init())
//  }
//}

struct CategoriesView: View {
  @ObservedObject private var viewModel: CategoriesViewModel
  @State private var indexOfSelectedCategory: Int? = nil
  
  init(viewModel: CategoriesViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(spacing: 16) {
        ForEach(viewModel.data.indices, id: \.self) { index in
          CategoryButton(
            model: viewModel.data[index],
            index: index,
            currentSelectedIndex: $viewModel.indexOfSelectedCategory
          )
          .onTapGesture { viewModel.onTapCategory(at: index) }
        }
      }
      .padding(.horizontal)
    }
  }
}

struct FeaturedMenuModel: Identifiable {
  var id = UUID()
  let imageName: String
  let destination: AnyView
  
  init(imageName: String, destination: AnyView) {
    self.imageName = imageName
    self.destination = destination
  }
  
  static var data: [FeaturedMenuModel] {
    return [
      .init(imageName: "Frame 9-3",
            destination: AnyView(LazyView(NearbyView(viewModel: .init())))),
      .init(imageName: "Frame 10",
            destination: AnyView(EmptyView()))
    ]
  }
//    .init(imageName: "Frame 9-3") { NearbyView(viewModel: .init()) }
//    .init(imageName: "Frame 10") {
//      EmptyView() as! Destination
//    }
  
}

struct PageView: View {
  @State var currentIndex = 0
  
  private let timer = Timer
    .publish(every: 4, on: .main, in: .common)
    .autoconnect()
    .eraseToAnyPublisher()
  
  private let data = FeaturedMenuModel.data
  private let bannerImageNames = [ "Frame 9-3", "Frame 10"]
  
  var body: some View {
    TabView(selection: $currentIndex) {
      ForEach(data.indices) { index in
        NavigationLink {
          LazyView(data[index].destination)
        } label: {
          Image(data[index].imageName)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
        }
        .tag(index)
      }
      .padding(.horizontal)
//      .onReceive(timer) { _ in
//        guard currentIndex != bannerImageNames.count-1 else {
//          currentIndex = 0
//          return
//        }
//        currentIndex += 1
//      }
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    .animation(.easeInOut, value: currentIndex)
    .transition(.slide)
  }
}

struct SearchingView: View {
  @Binding var searchText: String
  @Binding var showing: Bool
  @Binding var onSubmit: () -> Void
  @State private var tabBarFrame = CGRect.zero
  @State private var tabBarController: UITabBarController? = nil
  
  var body: some View {
    NavigationView {
      List {
        Text("Search History")
          .font(.headline)
          .bold()
          .listRowSeparator(.hidden)
        ForEach(0..<5) { num in
          Text("Text number \(num)")
        }
        .listRowSeparator(.hidden)
      }
      .listStyle(.plain)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("\(Image(systemName: "chevron.backward"))", action: dismiss)
        }
        
        ToolbarItem(placement: .principal) {
          TextField(
            "Search for foods or eateries",
            text: $searchText
          )
          .onSubmit(onSubmit)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .introspectTextField { textField in
            textField.becomeFirstResponder()
          }
        }
      }
      .onAppear {
        DispatchQueue.main.async { tabBarHidden(true) }
      }
      .onDisappear { tabBarHidden(false) }
      .introspectTabBarController(customize: setTabBarController)
      .introspectNavigationController { controller in
        let a2 = UINavigationBarAppearance()
        a2.configureWithOpaqueBackground()
        a2.backgroundColor = .white
        controller.navigationBar.standardAppearance = a2
      }
    }
  }
  
  private func setTabBarController(_ controller: UITabBarController) {
    tabBarController = controller
  }
  
  private func tabBarHidden(_ hidden: Bool) {
    tabBarController?.tabBar.isHidden = hidden
    UIView.transition(with: (tabBarController?.view)!, duration: 0.15, options: .transitionCrossDissolve, animations: nil, completion: nil)
  }
  
  private func dismiss() {
    withAnimation(.easeIn) { showing.toggle() }
  }
}
