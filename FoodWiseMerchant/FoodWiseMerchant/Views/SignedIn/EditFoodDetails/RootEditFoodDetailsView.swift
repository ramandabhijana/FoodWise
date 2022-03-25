//
//  RootEditFoodDetailsView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/02/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct RootEditFoodDetailsView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @StateObject private var viewModel: RootEditFoodDetailsViewModel
  @StateObject private var removeFoodViewModel: RemoveFoodViewModel
  
  static private var editFoodViewModel: EditFoodViewModel!
  
  init() {
    let rootViewModel = RootEditFoodDetailsViewModel()
    let removeViewModel = RemoveFoodViewModel(repository: rootViewModel.repository)
    rootViewModel.listenToDeletionPublisher(removeViewModel.foodDeletionPublisher)
    _viewModel = StateObject(wrappedValue: rootViewModel)
    _removeFoodViewModel = StateObject(wrappedValue: removeViewModel)
    setupFoodWiseNavigationBarAppearance()
  }
  
  var body: some View {
    ZStack {
      Color.backgroundColor.ignoresSafeArea()
      VStack {
        HStack {
          TextField(
            "Search Recorded Food",
            text: $viewModel.searchFieldText
          )
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
              RemoveEditCell(
                food: food,
                loading: viewModel.loading,
                onTapRemoveButton: { selectedFood in
                  removeFoodViewModel.currentSelectedFood = selectedFood
                  removeFoodViewModel.showingDeletionConfirmationAlert = true
                },
                navigateToEditDetails: { selectedFood in
                  LazyView(goToEditView(withFood: selectedFood))
                }
              )
              .padding(.horizontal)
            }
            .redacted(reason: viewModel.loading ? .placeholder : [])
          }
          .padding(.vertical)
        }
      }
    }
    .navigationTitle("Edit Food Details")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      viewModel.fetchRecordedFoods(merchantId: mainViewModel.merchant.id)
    }
    .confirmationDialog(
      removeFoodViewModel.deleteConfirmationAlertTitle,
      isPresented: $removeFoodViewModel.showingDeletionConfirmationAlert,
      titleVisibility: .visible,
      actions: {
        Button("Remove", role: .destructive) {
          if let food = removeFoodViewModel.currentSelectedFood {
            removeFoodViewModel.removeFood(food)
          }
        }
        Button("Cancel", role: .cancel) {
          removeFoodViewModel.currentSelectedFood = nil
          removeFoodViewModel.showingDeletionConfirmationAlert = false
        }
      },
      message: {
        Text(removeFoodViewModel.deletionConfirmationMessage)
      }
    )
    .snackBar(
      isShowing: $removeFoodViewModel.showingDeletionSuccessAlert,
      text: Text(removeFoodViewModel.deletionSuccessMessage),
      shouldNotifyNotificationFeedbackOccurred: true
    )
    .snackBar(
      isShowing: $removeFoodViewModel.deletionError.shows,
      text: Text(removeFoodViewModel.deletionError.errorMessage),
      isError: true
    )
  }
  
  private func goToEditView(withFood food: Food) -> some View {
    let editViewModel = EditFoodViewModel(
      food: food,
      repository: viewModel.repository)
    viewModel.listenToFoodPublisher(editViewModel.updatedFoodPublisher)
    let view = EditFoodDetailsView(viewModel: editViewModel)
    return view
  }
  
  
}

private extension RootEditFoodDetailsView {
  struct RemoveEditCell<EditDetailsView: View>: View {
    var food: Food
    var loading: Bool
    var onTapRemoveButton: (Food) -> Void
    var navigateToEditDetails: (Food) -> EditDetailsView

    var body: some View {
      RoundedRectangle(cornerRadius: 10)
        .fill(Color.white)
        .frame(height: 200)
        .shadow(radius: 1.5)
        .overlay(alignment: .leading) {
          VStack {
            HStack(spacing: 15) {
              WebImage(url: food.imagesUrl[0])
                .resizable()
                .frame(width: 90, height: 120)
                .scaledToFit()
                .cornerRadius(10)
              
              VStack(alignment: .leading) {
                Text(food.name)
                  .bold()
                  .lineLimit(1)
                  .padding(.bottom, 5)
                Group {
                  HStack {
                    Text("Price:")
                    Spacer()
                    Text("\(food.priceString)").bold()
                  }
                  HStack {
                    Text("Retail Price:")
                    Spacer()
                    Text("\(food.retailPriceString)").bold()
                  }
                  HStack(alignment: .top) {
                    Text("Category:")
                    Spacer()
                    Text("\(food.categoriesName)").bold()
                  }
                  HStack(alignment: .top) {
                    Text("Keywords:")
                    Spacer()
                    Text("\(food.keywordsString)").bold()
                  }
                }
                .font(.subheadline)
                
              }
            }
            HStack {
              Button(action: { onTapRemoveButton(food) }) {
                RoundedRectangle(cornerRadius: 8)
                  .strokeBorder(lineWidth: 3)
                  .overlay { Text("Remove") }
              }
              NavigationLink(destination: {
                return navigateToEditDetails(food)
              }) {
                RoundedRectangle(cornerRadius: 8)
                  .overlay {
                    Text("Edit Details").foregroundColor(.white)
                  }
              }
            }
          }
          .padding()
          .redacted(reason: loading ? .placeholder : [])
          .disabled(loading)
        }
    }
  }
}

//struct RootEditFoodDetailsView_Previews: PreviewProvider {
//  static var previews: some View {
//    RootEditFoodDetailsView(food: .init(id: "id", name: "Chocolate Ice Cream without topping", imagesUrl: [.init(string: "https://images.herzindagi.info/image/2020/Jun/chocolate-parle-g-ice-cream.jpg")], categories: [.categoriesData[1], .categoriesData[2], .categoriesData[4]], stock: 3, keywords: ["Desert", "sweet", "cold"], description: "Ice cream", retailPrice: 15_000, discountRate: 50, merchantId: "mID"))
//  }
//}
