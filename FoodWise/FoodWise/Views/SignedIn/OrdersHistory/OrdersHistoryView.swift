//
//  OrdersHistoryView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/04/22.
//

import SwiftUI

struct OrdersHistoryView: View {
  @StateObject private var viewModel: OrdersHistoryViewModel
  @Namespace var animation
  
  init(viewModel: OrdersHistoryViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    VStack {
      // Switch between ongoing and past
      HStack(spacing: 0) {
        SegmentItemView(
          currentTitle: $viewModel.selectedHistoryStatus,
          title: OrdersHistoryViewModel.HistoryStatus.ongoing.rawValue,
          animation: animation
        )
        SegmentItemView(
          currentTitle: $viewModel.selectedHistoryStatus,
          title: OrdersHistoryViewModel.HistoryStatus.past.rawValue,
          animation: animation
        )
      }
      .background(Color.primaryColor)
      
      // List
      List {
        Group {
          switch viewModel.selectedHistoryStatus {
          case OrdersHistoryViewModel.HistoryStatus.ongoing.rawValue:
            ongoingOrders
          case OrdersHistoryViewModel.HistoryStatus.past.rawValue:
            pastOrders
          default:
            EmptyView()
          }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        
      }
      .listStyle(.plain)
      .refreshable {
        viewModel.refreshList()
      }
      .overlay {
        emptyList
      }
    }
    .background(Color.backgroundColor)
    .navigationTitle("Order History")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      NotificationCenter.default.post(name: .tabBarHiddenNotification, object: nil)
      setNavigationBarColor(withStandardColor: .primaryColor, andScrollEdgeColor: .primaryColor)
    }
    .snackBar(
      isShowing: $viewModel.showingError,
      text: Text("Unknown error occurred"),
      isError: true
    )
  }
  
  @ViewBuilder
  private var emptyList: some View {
    switch viewModel.selectedHistoryStatus {
    case OrdersHistoryViewModel.HistoryStatus.ongoing.rawValue:
      if viewModel.ongoingOrders.isEmpty {
        VStack {
          Image("empty_list")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
          Text("No results").font(.subheadline)
        }
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height)
      }
    case OrdersHistoryViewModel.HistoryStatus.past.rawValue:
      if let pastOrders = viewModel.pastOrders {
        if pastOrders.isEmpty {
          VStack {
            Image("empty_list")
              .resizable()
              .scaledToFit()
              .frame(width: 100, height: 100)
            Text("No results").font(.subheadline)
          }
          .frame(width: UIScreen.main.bounds.width,
                 height: UIScreen.main.bounds.height)
        }
      }
    default:
      EmptyView()
    }
  }
  
  @ViewBuilder
  private var ongoingOrders: some View {
    ForEach(viewModel.ongoingOrders, id: \.self) { order in
      OrderCell(
        order: order,
        loading: viewModel.loadingOngoingOrders,
        buildDestination: OrderDetailsView(viewModel: .init(order: order))
      )
      .padding(.vertical, 4)
    }
  }
  
  @ViewBuilder
  private var pastOrders: some View {
    ForEach(viewModel.pastOrders ?? []) { order in
      OrderCell(
        order: order,
        loading: viewModel.loadingPastOrders,
        buildDestination: OrderDetailsView(viewModel: .init(order: order))
      )
      .padding(.vertical, 4)
    }
  }
  
}

private extension OrdersHistoryView {
  struct OrderCell<Destination: View>: View {
    var order: Order
    var loading: Bool
    let buildDestination: () -> Destination
    
    init(
      order: Order,
      loading: Bool,
      buildDestination: @autoclosure @escaping () -> Destination
    ) {
      self.order = order
      self.loading = loading
      self.buildDestination = buildDestination
    }
    
    var body: some View {
      ZStack {
        NavigationLink(
          destination: LazyView(buildDestination()),
          label: { EmptyView() }
        ).frame(width: 0).opacity(0.0).disabled(loading)
        label
      }
      .redacted(reason: loading ? .placeholder : [])
    }
    
    private var label: some View {
      VStack(alignment: .leading) {
        Text(OrdersHistoryViewModel.orderCellDateFormatter.string(from: order.date.dateValue()))
          .font(.caption)
        HStack {
          Text(order.status)
            .font(.footnote)
            .padding(1)
            .background(Color.primaryColor)
          Spacer()
          Text("\(order.pickupMethod.firstUppercased) • Paid with \(order.paymentMethod.lowercased())")
            .font(.footnote)
        }
        Divider()
        ForEach(order.items.prefix(3)) { item in
          HStack(spacing: 16) {
            Text(item.food?.name ?? "Item name")
              .font(.footnote)
              .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
              Text("×\(item.quantity)")
              Spacer()
              Text(item.price?.asIndonesianCurrencyString() ?? "Rp0.000")
            }
            .font(Font.caption)
            .frame(width: UIScreen.main.bounds.width * 0.3, alignment: .leading)
          }
          .lineLimit(1)
        }
        if order.items.count > 3 {
          Text("+\(order.items.count-3) items more...")
            .font(.caption2.bold())
            .foregroundColor(.secondary)
        }
        Divider()
        HStack {
          Text("Total").font(.footnote.bold())
          Spacer()
          Text(order.formattedTotal).font(.footnote.bold())
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.white)
          .shadow(radius: 2)
      )
    }
  }
}
