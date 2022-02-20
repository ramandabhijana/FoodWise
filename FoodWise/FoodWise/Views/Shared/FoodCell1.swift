//
//  FoodCell1.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/11/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct FoodCell1<Destination: View>: View {
  let food: Food
  var isLoading: Bool
  let buildDestination: (() -> Destination)?
  
  init(
    food: Food,
    isLoading: Bool = false,
    buildDestination: @autoclosure @escaping () -> Destination
  ) {
    self.food = food
    self.isLoading = isLoading
    self.buildDestination = buildDestination
  }
  
  init(
    food: Food,
    isLoading: Bool = false
  ) {
    self.food = food
    self.isLoading = isLoading
    self.buildDestination = nil
  }
  
  var body: some View {
    if let buildDestination = buildDestination {
      NavigationLink(
        destination: LazyView(buildDestination()),
        label: buildView
      )
      .disabled(isLoading)
    } else {
      buildView()
    }
  }
  
  private func buildView() -> some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.white)
      .frame(height: 250)
      .shadow(
        radius: 1.5
      )
      .overlay {
        GeometryReader { proxy in
          VStack(alignment: .leading, spacing: 8) {
            WebImage(url: food.imagesUrl[0])
              .resizable()
              .scaledToFill()
              .frame(
                width: proxy.size.width,
                height: proxy.size.height * 0.5
              )
              .clipped()
              .cornerRadius(10)
            /*
              .overlay(alignment: .topTrailing) {
                HStack(spacing: 2) {
                  Star(smoothness: 0.4)
                    .fill(Color.accentColor)
                    .frame(width: 18, height: 18)
                    .overlay {
                      Star(smoothness: 0.4)
                        .fill(Color.primaryColor)
                        .frame(width: 12, height: 12)
                    }
                  Text(food.overallRatingString)
                    .foregroundColor(.white)
                    .font(.caption)
                    .bold()
                }
                .padding(.horizontal, 3)
                .padding(.vertical, 1)
                .background(
                  UIBlurEffect.View(blurStyle: .systemThinMaterialDark)
                )
                .padding(5)
              }
            */
            
            Group {
              Text(food.name)
                .lineLimit(2)
                .padding(.top, 8)
              Text(food.priceString)
                .fontWeight(.bold)
            }
            .foregroundColor(.black)
            
            HStack {
              Text(food.discountRateString + " OFF")
                .foregroundColor(.errorColor)
              
              Text(food.retailPriceString)
                .strikethrough()
                .lineLimit(1)
                .foregroundColor(.secondary)
            }
            .font(.caption)
          }
          
        }
        .padding(5)
      }
      .frame(minWidth: 140)
      .redacted(reason: isLoading ? .placeholder : [])
  }
}

/*
struct FoodCell1_Previews: PreviewProvider {
  static var previews: some View {
    FoodCell1(food: .sampleData[0])
  }
}
*/
