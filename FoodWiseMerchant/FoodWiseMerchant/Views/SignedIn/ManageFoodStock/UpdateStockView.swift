//
//  UpdateStockView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/12/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct UpdateStockView: View {
  @StateObject private var viewModel: UpdateStockViewModel
  @FocusState private var stockFieldFocused: Bool
  @Binding var showing: Bool
  
  private let finishedUpdatePublisher = NotificationCenter.default
    .publisher(for: .viewModeldidFinishUpdateStock)
    .receive(on: RunLoop.main)
  
  init(showing: Binding<Bool>, viewModel: UpdateStockViewModel) {
    _showing = showing
    _viewModel = StateObject(wrappedValue: viewModel)
    setupFoodWiseNavigationBarAppearance()
  }
  
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 25) {
          InputFieldContainer(
            isError: false,
            label: "Stock"
          ) {
            TextField(
              "The stock to update the current one",
              text: $viewModel.stock
            )
              .keyboardType(.numberPad)
              .focused($stockFieldFocused)
          }
          
          VStack(alignment: .leading, spacing: 16) {
            WebImage(url: viewModel.food.imagesUrl[0])
              .resizable()
              .frame(height: 200)
              .aspectRatio(contentMode: .fill)
              .clipped()
              .cornerRadius(10)
            makeFoodDetailsItem(key: "ID", value: viewModel.food.id)
            makeFoodDetailsItem(key: "Name", value: viewModel.food.name)
            makeFoodDetailsItem(key: "Category", value: viewModel.food.categoriesName)
            makeFoodDetailsItem(key: "Stock", value: "\(viewModel.food.stock)")
            makeFoodDetailsItem(key: "Price", value: viewModel.food.priceString)
            makeFoodDetailsItem(key: "Retail Price", value: viewModel.food.retailPriceString)
            makeFoodDetailsItem(key: "Discount", value: viewModel.food.discountRateString)
          }
          .padding(.top, 30)
        }
        .padding()
      }
      .frame(maxWidth: .infinity)
      .background(Color.backgroundColor)
      .navigationBarTitleDisplayMode(.inline)
      .onReceive(finishedUpdatePublisher) { _ in
        showing = false
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            showing = false
          }.disabled(viewModel.loading)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: viewModel.updateFoodStock) {
            if viewModel.loading {
              ProgressView()
            } else {
              Text("Update").bold()
            }
          }.disabled(viewModel.buttonDisabled)
        }

        ToolbarItemGroup(placement: .keyboard) {
          HStack {
            Spacer()
            Button("Done") { stockFieldFocused = false }
          }
        }
      }
    }
    
    
    
  }
}

private extension UpdateStockView {
  func makeFoodDetailsItem(key: String, value: String) -> some View {
    HStack(alignment: .top) {
      Text(key)
        .frame(
          width: UIScreen.main.bounds.width * 0.25,
          alignment: .leading
        )
      Text(value).lineLimit(2)
    }
  }
}

//struct UpdateStockView_Previews: PreviewProvider {
//  static var previews: some View {
//    UpdateStockView()
//  }
//}
