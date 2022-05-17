//
//  WaitingReviewsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WaitingReviewsView: View {
  @StateObject private var viewModel: WaitingReviewsViewModel
  
  init(viewModel: WaitingReviewsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  static func makeItemLabel(with item: LineItem) -> some View {
    HStack(alignment: .top, spacing: 8) {
      WebImage(url: item.food?.imagesUrl[0])
        .resizable()
        .frame(width: 60, height: 60)
        .cornerRadius(10)
      VStack(alignment: .leading, spacing: 5) {
        Text(item.food?.name ?? "Item name")
          .lineLimit(2)
          .font(.subheadline)
          .foregroundColor(.black)
        HStack {
          Text(item.food?.priceString ?? "Rp0")
            .foregroundColor(.black)
          Text(item.food?.discountRateString ?? "0%")
            .foregroundColor(.red)
          Text(item.food?.retailPriceString ?? "Rp0")
            .strikethrough()
            .foregroundColor(.secondary)
        }
        .font(.caption2)
        Text("Bought \(item.quantity) • \((item.price ?? 0.0).asIndonesianCurrencyString())")
          .font(.footnote)
          .foregroundColor(.black)
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
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
        ForEach(
          Array(viewModel.completedOrders.enumerated()),
          id: \.element
        ) { index, order in
          Section {
            ForEach(order.items) { item in
              buildItemCell(
                item: item,
                order: order,
                atIndex: index)
            }
            .padding(.horizontal)
          } header: {
            makeHeader(WaitingReviewsViewModel.sectionDateFormatter.string(from: order.date.dateValue()))
          }
        }
      }
    }
    .background(Color.backgroundColor)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Waiting for review")
    .onAppear {
      setNavigationBarColor(withStandardColor: .primaryColor, andScrollEdgeColor: .primaryColor)
      NotificationCenter.default.post(name: .tabBarHiddenNotification, object: nil)
    }
    .overlay {
      emptyList
    }
  }
  
  @ViewBuilder
  private var emptyList: some View {
    if viewModel.completedOrders.isEmpty {
      VStack {
        Image("empty_list")
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)
        Text("No results").font(.subheadline)
      }
      .frame(width: UIScreen.main.bounds.width,
             height: UIScreen.main.bounds.height)
    } else {
      EmptyView()
    }
  }
  
  private func makeHeader(_ textString: String) -> some View {
    HStack {
      Text(textString)
        .font(.subheadline)
        .padding(.leading)
        .padding(.vertical, 8)
      Spacer()
    }
    .background(.ultraThickMaterial)
    .frame(maxWidth: .infinity)
  }
  
  private func buildItemCell(item: LineItem,
                             order: Order,
                             atIndex orderIndex: Int) -> some View {
    NavigationLink(
      destination: LazyView(WriteReviewView(viewModel: {
        let viewModel = WriteReviewViewModel(reviewedItem: item,
                                             order: order,
                                             orderIndex: orderIndex)
        self.viewModel.listenItemReviewed(
          publisher: viewModel.itemReviewSubmittedForOrderAtIndexPublisher)
        return viewModel
      }()))
    ) {
      Self.makeItemLabel(with: item)
      .redacted(reason: viewModel.loading ? .placeholder : [])
    }
    .disabled(viewModel.loading)
  }
  
  
}
