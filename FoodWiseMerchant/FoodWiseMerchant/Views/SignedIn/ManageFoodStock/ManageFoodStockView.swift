//
//  ManageFoodStockView.swift
//  FPExercise
//
//  Created by Abhijana Agung Ramanda on 10/10/21.
//

import SwiftUI

struct ManageFoodStockView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @StateObject private var viewModel: ManageFoodViewModel
  static private var updateStockViewModel: UpdateStockViewModel!
  @State private var showsUpdateStockView = false
  
  init() {
    _viewModel = StateObject(wrappedValue: ManageFoodViewModel())
    setupFoodWiseNavigationBarAppearance()
  }
  
  var body: some View {
    ZStack {
      Color.backgroundColor.ignoresSafeArea()
      
      VStack(spacing: 0) {
        HStack {
          TextField("Search Recorded Food", text: $viewModel.searchFieldText)
            .padding(8)
            .disableAutocorrection(true)
            .background(Color.gray.opacity(0.2))
            .overlay(alignment: .trailing) {
              if !viewModel.searchFieldText.isEmpty {
                Button("\(Image(systemName: "xmark.circle.fill"))",
                       action: viewModel.clearSearchText)
                  .padding(.trailing, 8)
                  .foregroundColor(.secondary)
              }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color.primaryColor)
        
        
        ScrollView(showsIndicators: false) {
          LazyVStack(spacing: 24) {
            ForEach(viewModel.foodsList) { food in
              FoodStockCellView(food: food) { tappedFood in
                Self.updateStockViewModel = UpdateStockViewModel(
                  food: tappedFood,
                  manageFoodViewModel: viewModel)
                showsUpdateStockView = true
              }
              .padding(.horizontal)
            }
            .redacted(reason: viewModel.loading ? .placeholder : [])
            
            
          }.padding(.vertical, 24)
        }
      }
        
    }
    .navigationTitle("Manage Food Stock")
    .navigationBarTitleDisplayMode(.inline)
//    .onReceive(viewModel.$recordedFoods.drop(while: { $0.isEmpty }), perform: { _ in
//      showingAddFoodView = false
//    })
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink("\(Image(systemName: "plus"))") {
          LazyView(
            NewFoodView(viewModel: .init(
              merchantId: mainViewModel.merchant.id,
              manageFoodViewModel: viewModel))
          )
        }
//        Button("\(Image(systemName: "plus"))") {
//
//        }
//          Menu("\(Image(systemName: "plus"))") {
//            Button("New Food") { }
//            Button("New Stock") { }
//          }
      }
      
//      ToolbarItem(placement: .navigationBarLeading) {
//        Button(
//          action: { },
//          label: {
//            Text("Cancel")
//              .foregroundColor(.black)
//          })
//      }
      
    }
    .onAppear {
      viewModel.fetchFoodsIfListEmpty(merchantId: mainViewModel.merchant.id)
    }
//    .fullScreenCover(isPresented: $showsUpdateStockView) {
//      UpdateStockView(showing: $showsUpdateStockView,
//                      viewModel: Self.updateStockViewModel)
//    }
    .sheet(isPresented: $showsUpdateStockView) {
      LazyView(
        UpdateStockView(showing: $showsUpdateStockView,
                        viewModel: Self.updateStockViewModel)
      )

    }
    
  }
  
  private func setupNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = UIColor(named: "PrimaryColor")
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().tintColor = .black
    
  }
}

@available(iOS 15.0, *)
struct ManageFoodStock_Previews: PreviewProvider {
  static var previews: some View {
    ManageFoodStockView()
  }
}
