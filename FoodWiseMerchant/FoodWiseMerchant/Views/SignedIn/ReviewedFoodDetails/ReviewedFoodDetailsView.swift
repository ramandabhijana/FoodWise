//
//  ReviewedFoodDetailsView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReviewedFoodDetailsView: View {
  @StateObject private var viewModel: ReviewedFoodDetailsViewModel
  
  init(viewModel: ReviewedFoodDetailsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 10) {
        WebImage(url: viewModel.reviewedFood.imagesUrl[0])
          .resizable()
          .frame(width: 35, height: 35)
          .cornerRadius(10)
        Text(viewModel.reviewedFood.name)
          .font(.subheadline)
      }
      .padding(.vertical, 10)
      .padding(.horizontal)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.primaryColor)
      
      ScrollView {
        VStack(spacing: 22) {
          HStack {
            makeRatingAttribute(
              key: "reviews",
              value: "\(viewModel.reviewedFood.reviewCount ?? 0)"
            )
            Spacer()
            makeRatingAttribute(
              key: "sentiment",
              value: viewModel.reviewedFood.sentimentScoreDescription
            )
            Spacer()
            makeRatingAttribute(
              key: "rating",
              value: String.init(format: "%.1f", viewModel.reviewedFood.rating ?? 0.0)
            )
          }
          .padding()
          
          LazyVStack(spacing: 20) {
            ForEach(viewModel.reviews, content: makeReviewCell)
          }
        }
        .padding()
      }
    }
    .background(Color.backgroundColor)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Review Details")
  }
  
  private func makeRatingAttribute(key: String, value: String) -> some View {
    VStack(spacing: 3) {
      Text(value).bold()
      Text(key.uppercased())
        .font(.caption)
    }
  }
  
  private func makeReviewCell(with review: Review) -> some View {
    VStack(alignment: .leading) {
      HStack {
        WebImage(url: review.customerProfilePicUrl)
          .resizable()
          .frame(width: 28, height: 28)
          .clipShape(Circle())
        Text(review.customerName)
          .font(.subheadline.bold())
        Spacer()
        Text(ReviewedFoodDetailsViewModel.reviewCellDateFormatter.string(from: review.date))
          .font(.caption.bold())
          .foregroundColor(.secondary)
      }
      HStack {
        makeRatingStars(forCount: review.rating)
        Text("•")
        Text(review.sentimentScoreDescription)
          .font(.footnote)
          .padding(2)
          .padding(.horizontal)
          .background(Color.secondaryColor)
      }
      Text(review.comments)
        .font(.footnote)
        .padding(.top, 8)
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(Color.white)
        .shadow(radius: 2)
    )
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
