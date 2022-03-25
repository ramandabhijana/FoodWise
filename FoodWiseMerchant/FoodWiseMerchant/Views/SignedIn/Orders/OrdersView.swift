//
//  OrdersView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 11/03/22.
//

import SwiftUI

struct OrdersView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @StateObject private var viewModel: OrdersViewModel
  
  static private var confirmOrderViewModel: ConfirmOrderViewModel!
  
  init() {
    let segmentedAppearance = UISegmentedControl.appearance()
    segmentedAppearance.selectedSegmentTintColor = .darkGray
    segmentedAppearance.setTitleTextAttributes(
      [.foregroundColor: UIColor.white],
      for: .selected)
    _viewModel = StateObject(wrappedValue: OrdersViewModel())
  }
  
  var body: some View {
    VStack {
      Picker("", selection: $viewModel.selectedOrderkind) {
        ForEach(viewModel.orderKinds, id: \.rawValue) { kind in
          Text(kind.rawValue)
            .tag(kind)
        }
      }
      .pickerStyle(.segmented)
      .padding([.horizontal, .top])
      
      
      List {
        Group {
          switch viewModel.selectedOrderkind {
          case .new:
            ForEach(
              viewModel.newOrders,
              id: \.self,
              content: makeOrderCell)
          case .confirmed:
            ForEach(
              viewModel.confirmedOrders,
              id: \.self,
              content: makeOrderCell)
          }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
      }
      .listStyle(.plain)
      .padding(.vertical)
    }
    .background(Color.backgroundColor)
    .navigationTitle("All orders")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      viewModel.loadOrders(merchantId: mainViewModel.merchant.id)
    }
  }
  
  private func makeOrderCell(with order: Order?) -> some View {
    NavigationLink {
      LazyView(OrderConfirmationView(viewModel: ConfirmOrderViewModel(
        order: order!,
        repository: viewModel.repository)))
    } label: {
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.white)
          .shadow(radius: 2)
        VStack(alignment: .leading) {
          Text(OrdersViewModel.orderCellDateFormatter.string(from: order?.date.dateValue() ?? .now))
            .font(.caption)
            .bold()
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
          HStack {
            Image(systemName: "person.crop.circle")
              .font(.title2)
              .frame(width: 28, height: 28)
              .foregroundColor(.secondary.opacity(0.5))
            Text(order?.customerName ?? "Customer name")
              .font(.footnote)
            Spacer()
            Text(order?.status ?? "STATUS")
              .font(.caption)
              .padding(.horizontal)
              .background(Color.primaryColor)
              .padding(.top, -16)
          }
          
          HStack(spacing: 16) {
            VStack(alignment: .leading) {
              Text("Quantity")
                .font(.footnote)
                .fontWeight(.light)
              Text("\(order?.items.count ?? 0) Items")
                .font(.subheadline)
            }
            
            VStack(alignment: .leading) {
              Text("Payment")
                .font(.footnote)
                .fontWeight(.light)
              Text(order?.paymentMethod.firstUppercased ?? "Wallet")
                .font(.subheadline)
            }
            
            VStack(alignment: .leading) {
              Text("Pick up")
                .font(.footnote)
                .fontWeight(.light)
              Text(order?.pickupMethod.firstUppercased ?? "Delivery")
                .font(.subheadline)
            }
          }
          Divider()
          Text("Total \(viewModel.formatPrice(order?.total ?? 0.0))")
            .font(.subheadline)
            .bold()
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
      }
      .redacted(reason: order == nil ? .placeholder : [])
    }
    .disabled(order == nil)
  }
  
}

struct OrdersView_Previews: PreviewProvider {
  static var previews: some View {
    OrdersView()
  }
}
