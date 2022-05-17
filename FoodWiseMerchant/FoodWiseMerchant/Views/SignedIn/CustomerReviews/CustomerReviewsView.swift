//
//  CustomerReviewsView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct CustomerReviewsView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @StateObject private var viewModel: CustomerReviewsViewModel
  
  init() {
    _viewModel = StateObject(wrappedValue: CustomerReviewsViewModel())
  }
  
  var body: some View {
    List {
      ForEach(viewModel.allFoods, content: makeReviewedFoodCell)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .padding(.vertical)
    .background(Color.backgroundColor)
    .navigationTitle("Customer Reviews")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      viewModel.fetchFoods(merchantId: mainViewModel.merchant.id)
    }
  }
  
  private func makeReviewedFoodCell(with food: Food) -> some View {
    NavigationLink {
      LazyView(ReviewedFoodDetailsView(viewModel: ReviewedFoodDetailsViewModel(reviewedFood: food)))
    } label: {
      HStack(alignment: .top, spacing: 10) {
        WebImage(url: food.imagesUrl[0])
          .resizable()
          .frame(width: 60, height: 60)
          .cornerRadius(10)
        VStack(alignment: .leading, spacing: 5) {
          Text(food.name)
            .lineLimit(2)
            .font(.subheadline)
          HStack {
            makeRatingStars(forCount: food.rating ?? 0.0)
            if food.sentimentScore != nil {
              Text("•")
              Text(food.sentimentScoreDescription)
                .padding(2)
                .background(Color.primaryColor)
                .font(.caption)
            }
          }
          Group {
            if let reviewCount = food.reviewCount, reviewCount > 0 {
              Text("\(reviewCount) Customer reviews")
            } else {
              Text("No review")
            }
          }
          .font(.caption)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.white)
          .shadow(radius: 2)
      )
    }
    .disabled(food.reviewCount ?? 0 < 1)
    .redacted(reason: viewModel.loading ? .placeholder : [])
  }
  
  private func makeRatingStars(forCount ratingCount: Float) -> some View {
    HStack(spacing: 1) {
      ForEach(1..<6) { num in
        RatingStar(
          size: 18,
          fill: {
            if Float(num) - 0.5 == ratingCount {
              return .half
            } else if Float(num) <= ratingCount {
              return .full
            } else {
              return .none
            }
          }()
        )
      }
    }
  }
  
}

struct CustomerReviewsView_Previews: PreviewProvider {
  static var previews: some View {
    CustomerReviewsView()
  }
}
