//
//  FoodCell1.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/11/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct FoodCell1: View {
  let food: Food
  
  var body: some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.white)
      .frame(width: 140, height: 250)
      .shadow(
        radius: 1.5
      )
      .overlay {
        GeometryReader { proxy in
          VStack(alignment: .leading, spacing: 8) {
            WebImage(url: food.imageUrl)
              .resizable()
              .scaledToFill()
              .frame(
                width: proxy.size.width,
                height: proxy.size.height * 0.5
              )
              .clipped()
              .cornerRadius(10)
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
            
            Text(food.name)
              .lineLimit(2)
              .padding(.top, 8)
            Text(food.priceString)
              .fontWeight(.bold)
            
            HStack {
              Text(food.discountRateString)
                .fontWeight(.semibold)
                .padding(5)
                .foregroundColor(.yellow)
                .colorMultiply(.yellow)
                .background(Color.primaryColor.opacity(0.2))
                .font(.caption)
              
              Text(food.retailPriceString)
                .strikethrough()
                .lineLimit(1)
                .foregroundColor(.secondary)
                .font(.caption2)
            }
          }
          
        }
        .padding(5)
      }
  }
}

struct FoodCell1_Previews: PreviewProvider {
  static var previews: some View {
    FoodCell1(food: .sampleData[0])
  }
}
