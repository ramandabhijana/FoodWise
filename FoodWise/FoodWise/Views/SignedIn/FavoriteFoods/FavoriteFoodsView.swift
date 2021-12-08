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
  
  static private var foodToBeRemoved: Food?
  
  init(viewModel: FavoriteFoodsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
  }
  
  var body: some View {
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
            }
          ).padding(.horizontal)
        }
        .redacted(reason: viewModel.loading ? .placeholder : [])
      }.padding(.vertical, 20)
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
    
  }
}

//struct FavoriteFoodsView_Previews: PreviewProvider {
//  static var previews: some View {
//    FavoriteFoodsView(viewModel: .init(foodRepository: <#T##FoodRepository#>))
//  }
//}
