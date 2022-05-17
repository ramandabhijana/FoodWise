//
//  FavoriteFoodCell.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/12/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavoriteFoodCell<Destination: View>: View {
  var food: Food
  var goToDetailScreen: () -> Destination
  var onTapRemoveFromFavoriteButton: () -> ()
  var onTapAddToBagButton: () -> ()
  
  var body: some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.white)
      .frame(height: 170)
      .shadow(radius: 1.5)
      .overlay(alignment: .leading) {
        VStack(alignment: .leading, spacing: 16) {
          NavigationLink(destination: goToDetailScreen) {
            HStack {
              WebImage(url: food.imagesUrl[0])
                .resizable()
                .frame(width: 90, height: 90)
                .scaledToFit()
                .cornerRadius(10)
              
              VStack(alignment: .leading, spacing: 8) {
                Text(food.name)
                  .foregroundColor(.black)
                HStack {
                  Text(food.priceString)
                    .bold()
                    .foregroundColor(.black)
                  Group {
                    Text("\(food.discountRateString) OFF")
                      .foregroundColor(.errorColor)
                    Text(food.retailPriceString)
                      .strikethrough()
                      .foregroundColor(.secondary.opacity(0.6))
                  }
                  .font(.subheadline)
                }
                Spacer()
              }.padding(.top, 5)
            }
          }
          
          HStack {
            Button(action: onTapRemoveFromFavoriteButton) {
              RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.secondary, lineWidth: 2)
                .frame(width: 30, height: 30)
                .overlay {
                  Image(systemName: "trash.fill")
                    .foregroundColor(.init(uiColor: .darkGray))
                }
            }
            
            Button(action: onTapAddToBagButton) {
              RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.accentColor, lineWidth: 2)
                .frame(height: 30)
                .overlay {
                  Text("Add to Bag")
                    .foregroundColor(.accentColor)
                }
            }

          }
        }
        
        .padding()
      }
  }
}

//struct FavoriteFoodCell_Previews: PreviewProvider {
//  static var previews: some View {
//    FavoriteFoodCell(food: .sampleData[0], onTapRemoveFromFavoriteButton: {_ in })
//  }
//}
