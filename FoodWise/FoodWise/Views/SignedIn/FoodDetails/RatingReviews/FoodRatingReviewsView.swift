//
//  FoodRatingReviewsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import SwiftUI

struct FoodRatingReviewsView: View {
  @StateObject private var viewModel: FoodRatingReviewsViewModel
  @Environment(\.dismiss) private var dismiss
  
  init(viewModel: FoodRatingReviewsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        HStack {
          Picker(
            "Filter by rating",
            selection: $viewModel.selectedRating
          ) {
            Text("★ 1").tag(1)
            Text("★ 2").tag(2)
            Text("★ 3").tag(3)
            Text("★ 4").tag(4)
            Text("★ 5").tag(5)
          }
          .pickerStyle(.segmented)
          
          if viewModel.isFilteringByRating {
            Button("Reset", action: viewModel.resetRatingFilter)
            .font(.subheadline.bold())
          }
        }
        .animation(.default, value: viewModel.selectedRating)
        .padding()
        .background(Color.primaryColor)
        
        ScrollView(showsIndicators: false) {
          LazyVStack {
            ForEach(viewModel.filteredReviews) { review in
              Self.makeReviewCell(with: review)
              Divider()
                .padding(.vertical, 8)
            }
          }
          .padding()
        }
      }
//      .navigationBarHidden(true)
      .background(Color.backgroundColor)
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Rating and Reviews")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "chevron.left")
          }
          .foregroundColor(.init(uiColor: .darkGray))
        }
      }
    }
    
  }
  
  private static func makeRatingStars(forCount ratingCount: Float) -> some View {
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
  
  static func makeReviewCell(with review: Review) -> some View {
    VStack(alignment: .leading) {
      HStack {
        makeRatingStars(forCount: review.rating)
        Spacer()
        Text(FoodRatingReviewsViewModel.reviewCellDateFormatter.string(from: review.date))
          .font(.footnote)
      }
      Text("by \(review.customerName)")
        .font(.subheadline)
        .foregroundColor(.secondary)
      Text(review.comments)
        .font(.subheadline)
        .padding(.top, 2)
    }
  }
}
