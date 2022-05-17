//
//  OrderReceiptView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 17/04/22.
//

import SwiftUI

struct OrderReceiptView: View {
  @Environment(\.dismiss) private var dismiss
  private let qrCodeGenerator = QRCodeGenerator()
  private let viewModel: OrderReceiptViewModel
  
  init(viewModel: OrderReceiptViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          Text("Order Receipt")
            .font(.title.bold())
          Divider()
          VStack {
            makeFirstSectionItem(key: "Date", value: viewModel.formattedDate)
            makeFirstSectionItem(key: "Time", value: viewModel.formattedTime)
            makeFirstSectionItem(key: "Merchant", value: viewModel.merchantName)
          }
          .padding(.vertical)
          Divider()
          VStack {
            GeometryReader { proxy in
              HStack(spacing: 16) {
                Text("Items")
                  .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack {
                  Text("Qty")
                  Spacer()
                  Text("Price")
                }
                .frame(width: proxy.size.width * 0.45, alignment: .leading)
              }
            }
            .frame(height: 18)
            .font(.subheadline.bold())
            .padding(.bottom, 5)
            
            ForEach(viewModel.order.items) { item in
              GeometryReader { proxy in
                HStack(spacing: 16) {
                  Text(item.food?.name ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                  Spacer()
                  HStack {
                    Text("×\(item.quantity)")
                    Spacer()
                    Text("\((item.price ?? 0.0).asIndonesianCurrencyString())")
                  }
                  .frame(width: proxy.size.width * 0.45, alignment: .leading)
                }
              }
              .frame(height: 18)
              .font(.subheadline)
            }
          }
          .padding(.vertical)
          Divider()
          VStack {
            HStack(spacing: 16) {
              Text("Subtotal")
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
              Text("\(viewModel.order.formattedSubtotal)")
            }
            .frame(height: 18)
            HStack(spacing: 16) {
              Text("Delivery fee")
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
              Text("\(viewModel.order.formattedDeliveryCharge)")
            }
            .frame(height: 18)
            HStack(spacing: 16) {
              Text("Total")
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
              Text("\(viewModel.order.formattedTotal)")
            }
            .frame(height: 18)
            .font(.body.bold())
          }
          .padding(.vertical)
          .font(.subheadline)
          Divider()
          VStack {
            Image(uiImage: qrCodeGenerator.generate(from: viewModel.order.id) ?? .init())
              .resizable()
              .interpolation(.none)
              .scaledToFit()
              .frame(
                width: UIScreen.main.bounds.width * 0.3,
                height: UIScreen.main.bounds.width * 0.3
              )
            Text("Thank you for odering!\nShow the QR Code above to the \(viewModel.giver) to have your order in hand.")
              .font(.subheadline)
              .multilineTextAlignment(.center)
          }
          .padding(.vertical)
        }
        .padding()
      }
      .background(Color.white)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Close", action: dismiss.callAsFunction)
        }
      }
    }
  }
  
  private func makeFirstSectionItem(key: String, value: String) -> some View {
    GeometryReader { proxy in
      HStack {
        Text(key)
          .frame(width: proxy.size.width * 0.4, alignment: .leading)
        Spacer()
        Text(value)
      }
    }
    .frame(height: 18)
    .font(.subheadline)
  }
  
}
