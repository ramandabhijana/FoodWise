//
//  HomeView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 01/11/21.
//

import SwiftUI
import Introspect

struct HomeView: View {
  
  @State private var selectedCategory: CategoryButtonModel? = nil
  @State private var categorySelected = false
  @State private var showSearchView = false
//  @FocusState private var searchFieldFocused = true
  @State private var navigationBar: UINavigationBar? = nil
  
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
            
            
            CategoriesView()
            
            ForEach(Food.sampleSection, id: \.self) { sectionName in
              VStack(alignment: .leading) {
                Text(sectionName)
                  .font(.headline)
                  .padding(.leading)
                ScrollView(.horizontal, showsIndicators: false) {
                  LazyHStack(spacing: 16) {
                    ForEach(Food.sampleData) { food in
                      FoodCell1(food: food)
                    }
                  }
                  .padding(.horizontal)
                  .frame(height: 260)
                }
              }
              .padding(.vertical)
            }
            .animation(nil, value: showSearchView)
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
          .onTapGesture { showSearchView.toggle() }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack {
            Button("\(Image(systemName: "envelope.fill"))") {

            }

            Button("\(Image(systemName: "heart.fill"))") {

            }
          }
          .foregroundColor(.init(uiColor: .darkGray))
//          .opacity(searchFieldFocused ? 0 : 1)
//          .overlay {
//            if searchFieldFocused {
//              Button("Cancel") {
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
//                searchFieldFocused = false
//              }
//            }
//          }
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
      if showSearchView {
        SearchingView(
          searchText: .constant(""),
          showing: $showSearchView,
          onSubmit: .constant({ })
        )
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}

struct CategoriesView: View {
  let data = CategoryButtonModel.data
  @State private var indexOfSelectedCategory: Int? = nil
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(spacing: 16) {
        ForEach(data.indices, id: \.self) { index in
          CategoryButton(
            model: data[index],
            index: index,
            currentSelectedIndex: $indexOfSelectedCategory
          )
          .onTapGesture {
            guard indexOfSelectedCategory != index else {
              indexOfSelectedCategory = nil
              return
            }
            indexOfSelectedCategory = index
          }
          
        }
      }
      .padding(.horizontal)
    }
  }
}


struct PageView: View {
  
  @State var currentIndex = 0
  
  private let timer = Timer
    .publish(every: 4, on: .main, in: .common)
    .autoconnect()
    .eraseToAnyPublisher()
  
  private let bannerImageNames = [ "Frame 9-3", "Frame 10"]
  
  var body: some View {
    TabView(selection: $currentIndex) {
      ForEach(bannerImageNames.indices, id: \.self) { index in
        Image(bannerImageNames[index])
          .resizable()
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 10.0))
          .tag(index)
      }
            .padding(.horizontal)
//      .padding(.all)
      .onReceive(timer) { _ in
        guard currentIndex != bannerImageNames.count-1 else {
          currentIndex = 0
          return
        }
        currentIndex += 1
      }
    }
//    .frame(width: UIScreen.main.bounds.width)
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    .animation(.easeInOut, value: currentIndex)
    .transition(.slide)
  }
}

struct SearchingView: View {
  @Binding var searchText: String
  @Binding var showing: Bool
  @Binding var onSubmit: () -> Void
  
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
      .introspectNavigationController { controller in
        let a2 = UINavigationBarAppearance()
        a2.configureWithOpaqueBackground()
        a2.backgroundColor = .white
        controller.navigationBar.standardAppearance = a2
      }
      
      //          ZStack {
      //            Button("Dismiss") {
      //              UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
      //              searchFieldFocused = false
      //            }
      //          }
      //          .frame(width: UIScreen.main.bounds.width, height: 400)
      //          .background(.white)
      //          .onAppear {
      //            let a2 = UINavigationBarAppearance()
      //            a2.configureWithOpaqueBackground()
      //            a2.backgroundColor = .white
      //            navigationBar?.standardAppearance = a2
      //          }
    }
  }
  
  private func dismiss() {
    withAnimation(.easeIn) { showing.toggle() }
  }
}
