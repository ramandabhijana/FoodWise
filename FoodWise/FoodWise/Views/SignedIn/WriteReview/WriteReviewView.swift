//
//  WriteReviewView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WriteReviewView: View {
  @StateObject private var viewModel: WriteReviewViewModel
  @EnvironmentObject var rootViewModel: RootViewModel
  @FocusState private var commentsTextEditFocused: Bool
  @Environment(\.dismiss) private var dismiss
  
  init(viewModel: WriteReviewViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    VStack {
      HStack(alignment: .top, spacing: 8) {
        WebImage(url: viewModel.reviewedItem.food?.imagesUrl[0])
          .resizable()
          .frame(width: 40, height: 40)
          .cornerRadius(10)
          .shadow(radius: 2)
        VStack(alignment: .leading, spacing: 5) {
          Text(viewModel.reviewedItem.food?.name ?? "Item name")
            .lineLimit(2)
            .font(.subheadline.bold())
            .foregroundColor(.black)
//          HStack {
//            Text(viewModel.reviewedItem.food?.priceString ?? "Rp0")
//              .foregroundColor(.black)
//            Text(viewModel.reviewedItem.food?.retailPriceString ?? "Rp0")
//              .strikethrough()
//              .foregroundColor(.secondary)
//          }
//          .font(.caption2)
          Text("Bought \(viewModel.reviewedItem.quantity) • \((viewModel.reviewedItem.price ?? 0.0).asIndonesianCurrencyString())")
            .font(.footnote)
            .foregroundColor(.black)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.primaryColor)
      )
      
      ScrollView {
        VStack(spacing: 22) {
          VStack(alignment: .leading, spacing: 5) {
            Text("Rating").bold()
            HStack {
              Button(action: viewModel.decrementRating) {
                Circle()
                  .strokeBorder(lineWidth: 2)
                  .frame(width: 25, height: 25)
                  .overlay {
                    Image(systemName: "minus")
                  }
              }
              Spacer()
              ForEach(1..<6) { starValue in
                RatingStar(
                  size: 40,
                  fill: {
                    if Float(starValue) - 0.5 == viewModel.rating {
                      return .half
                    } else if Float(starValue) <= viewModel.rating {
                      return .full
                    } else {
                      return .none
                    }
                  }()
                )
              }
              Spacer()
              Button(action: viewModel.incrementRating) {
                Circle()
                  .strokeBorder(lineWidth: 2)
                  .frame(width: 25, height: 25)
                  .overlay {
                    Image(systemName: "plus")
                  }
              }
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          VStack(alignment: .leading, spacing: 10) {
            HStack {
              Text("Review").bold()
              Text("(Write in English if possible)").font(.caption)
            }
            TextEditor(text: $viewModel.reviewComments)
              .disableAutocorrection(true)
              .focused($commentsTextEditFocused)
              .frame(height: 250)
              .padding(1)
              .background(
                Rectangle()
              )
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
        }
        .padding()
      }
      Spacer()
      
      if !commentsTextEditFocused {
        Button(action: { viewModel.submitReview(customer: rootViewModel.customer!) }) {
          RoundedRectangle(cornerRadius: 10)
            .frame(height: 44)
            .overlay {
              if !viewModel.loading {
                Text("Submit")
                  .bold()
                  .foregroundColor(.white)
              } else {
                ProgressView()
                  .progressViewStyle(.circular)
                  .tint(.white)
              }
            }
        }
        .padding()
        .disabled(viewModel.buttonDisabled)
      }
    }
    .background(Color.backgroundColor)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Rate and Review")
    .onReceive(viewModel.itemReviewSubmittedForOrderAtIndexPublisher) { _ in
      dismiss()
    }
    .toolbar {
      ToolbarItem(placement: .keyboard) {
        HStack {
          Spacer()
          Button("Done") { commentsTextEditFocused = false }
        }
      }
    }
  }
}
