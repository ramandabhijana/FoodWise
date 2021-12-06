//
//  FoodStockCellView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/12/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct FoodStockCellView: View {
  var food: Food
  var onTapUpdateButton: (Food) -> Void
  
  var body: some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.white)
      .frame(height: 125)
      .shadow(radius: 1.5)
      .overlay(alignment: .leading) {
        HStack(spacing: 15) {
          WebImage(url: food.imagesUrl[0])
            .resizable()
            .frame(width: 100, height: 100)
            .scaledToFit()
            .cornerRadius(10)
          
          VStack(alignment: .leading) {
            Text(food.name)
              .bold()
              .lineLimit(1)
            HStack {
              Text(food.priceString)
              Text(food.retailPriceString)
                .strikethrough()
                .foregroundColor(.secondary.opacity(0.6))
            }
            .font(.subheadline)
            
            Spacer()
            HStack(spacing: 25) {
              Text("Stock: \(food.stock)")
                .fontWeight(.bold)
              Rectangle()
                .fill(Color.secondary)
                .frame(width: 1, height: 20)
              Button("Update Stock") {
                onTapUpdateButton(food)
              }
            }
            
          }
        }
        .padding()
      }
  }
}

/*
struct FoodStockCellView_Previews: PreviewProvider {
  static var previews: some View {
    FoodStockCellView(food: .init(id: <#T##String#>, name: <#T##String#>, imagesUrl: <#T##[URL?]#>, categories: <#T##[FoodCategory]#>, stock: <#T##Int#>, keywords: <#T##[String]#>, description: <#T##String#>, retailPrice: <#T##Double#>, discountRate: <#T##Float#>, merchantId: <#T##String#>))
  }
}
*/
