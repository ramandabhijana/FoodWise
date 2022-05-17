//
//  LegitimateRecipientView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

import SwiftUI

struct LegitimateRecipientView: View {
  private let viewModel: LegitimateRecipientViewModel
  private let onTapRetry: () -> ()
  private let onTapFinish: () -> ()
  @State private var showingFinishAlert = false
  @Environment(\.dismiss) var dismiss
  
  init(viewModel: LegitimateRecipientViewModel,
       onTapRetry: @escaping () -> (),
       onTapFinish: @escaping () -> ()) {
    self.viewModel = viewModel
    self.onTapRetry = onTapRetry
    self.onTapFinish = onTapFinish
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          VStack(spacing: 12) {
            Text("Legitimate Recipient.")
              .font(.title.bold())
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 35))
              .foregroundColor(.accentColor)
            Text("The provided QR Code is valid. You may now hand over the following items to the customer.")
              .font(.subheadline.bold())
              .multilineTextAlignment(.center)
              .foregroundColor(.secondary)
            Text(viewModel.paidInformation)
              .font(.footnote.bold())
              .foregroundColor(viewModel.isPaid ? .black : .red)
              .padding(.top)
          }
          Divider().padding(.vertical)
          VStack(spacing: 6) {
            ForEach(viewModel.lineItems) { item in
              HStack(alignment: .top, spacing: 16) {
                Text(item.name)
                  .lineLimit(2)
                  .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack {
                  Text("x\(item.qty)")
                  Spacer()
                  Text(item.price.asIndonesianCurrencyString())
                }
              }
              .font(.subheadline)
            }
          }
          Divider().padding(.vertical)
          VStack {
            HStack(spacing: 16) {
              Text("Subtotal")
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
              Text(viewModel.priceSection.subtotal.asIndonesianCurrencyString())
            }.frame(height: 18)
            
            HStack(spacing: 16) {
              Text("Delivery Charge")
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
              Text(viewModel.priceSection.deliveryCharge.asIndonesianCurrencyString())
            }.frame(height: 18)
            
            HStack(spacing: 16) {
              Text("Total")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
              Spacer()
              Text(viewModel.priceSection.total.asIndonesianCurrencyString()).bold()
            }
            .frame(height: 18)
          }
          .font(.subheadline)
        }
        .padding()
      }
      .background(Color.white)
      .navigationBarTitleDisplayMode(.inline)
      .alert("Are you sure to finish?", isPresented: $showingFinishAlert, actions: {
        Button("Cancel") { }
        Button("Yes") {
          dismiss()
          onTapFinish()
        }
      })
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Retry", action: onTapRetry)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Finish") {
            showingFinishAlert = true
          }
          .font(.body.bold())
        }
      }
    }
  }
}
