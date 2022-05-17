//
//  FavoriteFoodsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/12/21.
//

import SwiftUI

struct FavoriteFoodsView: View {
  @EnvironmentObject private var rootViewModel: RootViewModel
  @StateObject private var viewModel: FavoriteFoodsViewModel
  @State private var showsUnfavoriteAlert = false
//  @State private var viewIsShown = false
  
  static private var foodToBeRemoved: Food?
  
  init(viewModel: FavoriteFoodsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
  }
  
  var body: some View {
    Group {
      if viewModel.customerId == nil {
        VStack {
          Spacer()
          Button("Sign in to manage your favorite foods") {
            NotificationCenter.default.post(name: .signInRequiredNotification, object: nil)
          }
          Spacer()
        }
        .frame(width: UIScreen.main.bounds.width)
        .background(Color.backgroundColor)
        
      } else {
        ScrollView(showsIndicators: false) {
          LazyVStack(spacing: 20) {
            ForEach(viewModel.filteredFoods) { food in
              FavoriteFoodCell(
                food: food,
                goToDetailScreen: {
                  LazyView(FoodDetailsView(
                    viewModel: .init(food: food,
                                     customerId: rootViewModel.customer?.id,
                                     foodRepository: viewModel.foodRepository),
                    onDismiss: viewModel.removeFromList(food:))
                  )
                },
                onTapRemoveFromFavoriteButton: {
                  Self.foodToBeRemoved = food
                  showsUnfavoriteAlert.toggle()
                },
                onTapAddToBagButton: {
                  viewModel.addFoodToBag(food)
                }
              ).padding(.horizontal)
            }
            .redacted(reason: viewModel.loading ? .placeholder : [])
          }
          .padding(.vertical, 20)
        }
        .background(Color.backgroundColor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            TextField("Search favorited", text: $viewModel.searchText)
              .disableAutocorrection(true)
              .padding(8)
              .background(Color.secondary.opacity(0.2))
              .cornerRadius(8)
              .overlay(alignment: .trailing) {
                if !viewModel.searchText.isEmpty {
                  Button(action: viewModel.clearSearchText) {
                    Image(systemName: "xmark.circle.fill")
                      .font(.caption)
                      .padding(.trailing, 8)
                      .foregroundColor(.secondary)
                  }
                }
              }
          }
        }
        .alert(
          "Remove food from favorite list?",
          isPresented: $showsUnfavoriteAlert
        ) {
          Group {
            Button("Cancel", role: .cancel) { }
            Button("Remove") {
              if let food = Self.foodToBeRemoved {
                viewModel.unfavoriteFood(food)
              }
            }
          }
        }
        .confirmationDialog(
          "You can only shop from one merchant at a time!",
          isPresented: $viewModel.showingDifferentMerchantAlert,
          titleVisibility: .visible,
          actions: {
            Button("Add anyway") {
              viewModel.replaceBagItems()
            }
          },
          message: {
            Text("If you still want to put this food in your bag, all the items in your bag at the moment will be removed. You may review your bag first.")
          }
        )
        .snackBar(
          isShowing: $viewModel.showingAddedToBag,
          text: Text("Food was added to bag! \(Image(systemName: "bag.fill"))"))
      }
    }
    .onAppear {
      setNavigationBarColor(withStandardColor: .backgroundColor, andScrollEdgeColor: .backgroundColor)
      NotificationCenter.default.post(
        name: .tabBarHiddenNotification,
        object: nil)
    }
    
  }
}

//struct FavoriteFoodsView_Previews: PreviewProvider {
//  static var previews: some View {
//    FavoriteFoodsView(viewModel: .init(foodRepository: <#T##FoodRepository#>))
//  }
//}
