//
//  FoodDetailsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 17/11/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct FoodDetailsView: View {
  @State private var navigationBarBackgroundColor = Color.clear
  @State private var showTitle = false
  
  private var contentWidth: CGFloat = UIScreen.main.bounds.width - 30
  
  let food: Food
  
  init(food: Food) {
    self.food = food
  }
  
  var body: some View {
    ZStack(alignment: .top) {
      Color.backgroundColor
      
      ScrollView {
        LazyVStack(spacing: 18) {
          GeometryReader { proxy -> AnyView in
            let minY = proxy.frame(in: .global).minY
            let scrollViewScrolled = minY > 0
            return AnyView(
              WebImage(url: food.imageUrl)
                .resizable()
                .offset(y: scrollViewScrolled ? -minY : .zero)
                .onChange(of: minY) { value in
                  if abs(value) > (.headerImageHeight * 0.76) {
                    withAnimation {
                      navigationBarBackgroundColor = Color.primaryColor
                    }
                  } else {
                    withAnimation {
                      navigationBarBackgroundColor = .clear
                    }
                  }
                }
            )
          }.frame(height: .headerImageHeight)
          
          VStack(spacing: 30) {
            GeometryReader { proxy -> AnyView in
              let minY = proxy.frame(in: .global).minY
              return AnyView(
                HStack(alignment: .top,spacing: 15) {
                  Text(food.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                  Spacer()
                  VStack(alignment: .trailing) {
                    Text(food.priceString)
                      .font(.title2)
                      .fontWeight(.bold)
                    Text("\(food.discountRateString) OFF")
                      .font(.callout)
                      .foregroundColor(.red)
                    Text("was " + food.retailPriceString)
                      .font(.callout)
                      .foregroundColor(.secondary)
                  }
                }
                .onChange(of: minY, perform: { value in
                  let viewNotCoveredByNavigationBar = value > (.headerImageHeight * 0.17)
                  if viewNotCoveredByNavigationBar {
                    if showTitle {
                      withAnimation { showTitle = false }
                    }
                  } else {
                    if !showTitle {
                      withAnimation(.easeOut) { showTitle = true }
                    }
                  }
                })
              )
            }
            .frame(
              width: contentWidth,
              height: 65
            )
            
            
            Rectangle()
              .fill(Color(.systemFill))
              .frame(height: 10)
              
            
            VStack(spacing: 10) {
              HStack(alignment: .top) {
                Text("Stock Left")
                  .fontWeight(.light)
                Spacer()
                Text("3")
                  .frame(width: contentWidth * 0.58, alignment: .leading)
              }
              
              HStack(alignment: .top) {
                Text("Category")
                  .fontWeight(.light)
                Spacer()
                Text("Rice, Main Dish")
                  .frame(width: contentWidth * 0.58, alignment: .leading)
              }
              
              Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco")
                .font(.callout)
                .padding(.top, 5)
            }
            .frame(width: contentWidth)
            
            Rectangle()
              .fill(Color(.systemFill))
              .frame(height: 10)
            
            VStack(alignment: .leading, spacing: 10) {
              Text("Rating and Reviews")
                .font(.title3)
                .fontWeight(.semibold)
              
              VStack(alignment: .leading, spacing: 0) {
                Text("4.5 ★★★★★").font(.title3)
                Text("(16 Reviews)").fontWeight(.light)
              }
              .padding(.vertical, 10)
              
              VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                  HStack {
                    Text("★★★★★")
                    Spacer()
                    Text("13 Sep 2021")
                  }
                  Text("by Mathijs").foregroundColor(.secondary)
                }
                .font(.callout)
                Text("Delicious, Nice")
                Divider()
                
                VStack(alignment: .leading, spacing: 0) {
                  HStack {
                    Text("★★★★★")
                    Spacer()
                    Text("13 Sep 2021")
                  }
                  Text("by Mathijs").foregroundColor(.secondary)
                }
                .font(.callout)
                Text("Delicious, Nice")
              }
              .padding(.vertical, 5)
              .padding(.bottom, 10)
              
              Button(
                action: {},
                label: {
                  Text("See all")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                })
            }
            .frame(width: contentWidth)
            
            Rectangle()
              .fill(Color(.systemFill))
              .frame(height: 10)
            
//            SimilarFoods()
//              .padding(.horizontal)
          }
//          .frame(width: contentWidth)
        }
        .padding(.bottom, 140)
      }
      
      VStack {
        NavigationBarView(
          width: UIScreen.main.bounds.width - 30,
          showTitle: showTitle,
          backgroundColor: navigationBarBackgroundColor
        )
        .clipped()
        Spacer()
        
        ZStack {
          Rectangle()
            .fill(Color.secondaryColor)
            .frame(height: 50)
            .shadow(
              color: .black,
              radius: 15,
              y: -5)
          GeometryReader { proxy in
            HStack(alignment: .center) {
              Button(
                action: {},
                label: {
                  RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.accentColor, lineWidth: 3)
                    .overlay(
                      Image(systemName: "text.bubble.fill")
                        .foregroundColor(.accentColor)
                        .font(.title2)
                    )
                    .background(
                      RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                    )
                })
              Button(
                action: {},
                label: {
                  RoundedRectangle(cornerRadius: 10)
                    .frame(width: proxy.size.width * 0.78)
                    .overlay {
                      HStack {
                        Image(systemName: "bag.fill.badge.plus")
                        Text("Add to Bag")
                          .bold()
                      }
                      .foregroundColor(.white)
                    }
                })
            }
            .frame(
              width: UIScreen.main.bounds.width - 30,
              height: 44
            )
          }
          .frame(height: 35)
          .padding()
          .padding(.bottom, 34)
  //        .padding(.bottom, .safeAreaInsetsBottom)
          .background(Color.secondaryColor)
        }
      }
    }
    .ignoresSafeArea()
  }
}

struct FoodDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    FoodDetailsView(food: .sampleData.first!)
  }
}

private extension CGFloat {
  static let headerImageHeight = UIScreen.main.bounds.height / 2.2
}
