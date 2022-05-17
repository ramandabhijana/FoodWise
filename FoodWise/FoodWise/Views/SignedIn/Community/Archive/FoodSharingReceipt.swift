//
//  FoodSharingReceiptView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 04/05/22.
//

import SwiftUI

struct FoodSharingReceiptView: View {
  @Environment(\.dismiss) private var dismiss
  private let qrCodeGenerator = QRCodeGenerator()
  private let viewModel: FoodSharingReceiptModel
  
  init(viewModel: FoodSharingReceiptModel) {
    self.viewModel = viewModel
    
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          Text("Food Sharing Receipt")
            .font(.title.bold())
          
          Divider()
          
          VStack {
            makeFirstSectionItem(key: "Date", value: viewModel.formattedDate)
            makeFirstSectionItem(key: "Time", value: viewModel.formattedTime)
            makeFirstSectionItem(key: "Sharer", value: viewModel.sharerName)
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
            
            GeometryReader { proxy in
              HStack(spacing: 16) {
                Text(viewModel.donation.foodName)
                  .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack {
                  Text("×1")
                  Spacer()
                  Text("Rp0")
                }
                .frame(width: proxy.size.width * 0.45, alignment: .leading)
              }
            }
            .frame(height: 18)
            .font(.subheadline)
          }
          .padding(.vertical)
          
          Divider()
          
          VStack {
            HStack(spacing: 16) {
              Text("Subtotal")
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
              Text("Rp0")
            }
            .frame(height: 18)
            HStack(spacing: 16) {
              Text("Delivery fee")
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
              Text("\((viewModel.donation.deliveryCharge ?? 0.0).asIndonesianCurrencyString())")
            }
            .frame(height: 18)
            HStack(spacing: 16) {
              Text("Total")
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
              Text("\((viewModel.donation.deliveryCharge ?? 0.0).asIndonesianCurrencyString())")
            }
            .frame(height: 18)
            .font(.body.bold())
          }
          .padding(.vertical)
          .font(.subheadline)
          
          Divider()
          
          VStack {
            Image(uiImage: qrCodeGenerator.generate(from: viewModel.donation.id) ?? .init())
              .resizable()
              .interpolation(.none)
              .scaledToFit()
              .frame(
                width: UIScreen.main.bounds.width * 0.3,
                height: UIScreen.main.bounds.width * 0.3
              )
            Text("Thank you for your contribution!\nShow the QR Code above to the \(viewModel.giver) to have your order in hand.")
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

struct FoodSharingReceiptModel {
  private(set) var donation: Donation
  private(set) var sharerName: String
  
  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy"
    return formatter.string(from: donation.date.dateValue())
  }
  var formattedTime: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm"
    return formatter.string(from: donation.date.dateValue())
  }
  var giver: String {
    return donation.deliveryTaskId != nil ? "courier" : "sharer"
  }
  
  init(donation: Donation, sharerName: String) {
    self.donation = donation
    self.sharerName = sharerName
  }
}
