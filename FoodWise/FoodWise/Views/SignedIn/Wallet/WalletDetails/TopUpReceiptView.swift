//
//  TopUpReceiptView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 26/02/22.
//

import SwiftUI

struct TopUpReceiptView: View {
  @Binding var loading: Bool
  @Binding var showingReceipt: Bool
  @Binding var receipt: TopUpReceipt?
  
  var body: some View {
    Group {
      if loading {
        ZStack {
          Color.black.opacity(0.5)
            .frame(height: UIScreen.main.bounds.height * 1.5)
          HStack(spacing: 10) {
            ProgressView()
              .progressViewStyle(
                CircularProgressViewStyle(tint: .black)
              )
            Text("Please wait...")
          }
          .padding()
          .background(.thinMaterial)
          .cornerRadius(8)
        }
      } else {
        EmptyView()
      }
    }
    .sheet(isPresented: $showingReceipt) {
      receiptView
    }
  }
}

private extension TopUpReceiptView {
  var receiptView: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        if let receipt = receipt {
          VStack(alignment: .center) {
            VStack(spacing: 5) {
              Group {
                Image(systemName: "checkmark.circle.fill")
                  .font(.title3)
                Text("Top Up Success")
                  .font(.subheadline)
              }
              .foregroundColor(.accentColor)
              Text(receipt.topUpAmount)
                .fontWeight(.bold)
                .font(.title2)
                .padding(.top, 10)
            }
            
            Divider()
            VStack(alignment: .leading) {
              Text("Date: ") + Text(receipt.date).bold()
              Text("Time: ") + Text(receipt.time).bold()
              Text("Payment Method: ") + Text("\(receipt.cardBrand) ****\(receipt.cardLast4)").bold()
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            
            HStack {
              Text(verbatim: "Top Up Wallet (\(receipt.topUpAmount))").bold()
              Spacer()
              Text("\(receipt.paidAmount)").bold()
            }
            .font(.caption)
            .padding(.vertical)
            
            Divider()
            
            VStack(spacing: 8) {
              HStack {
                Text("Subtotal ")
                Spacer()
                Text("\(receipt.paidAmount)")
              }
              HStack {
                Text("Tax ")
                Spacer()
                Text("$0.00")
              }
              HStack {
                Text("Total ").bold()
                Spacer()
                Text("\(receipt.paidAmount)").bold()
              }
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
          }
          .padding()
          .frame(maxWidth: .infinity)
          .background(
            RoundedRectangle(cornerRadius: 5)
              .fill(Color.white)
              .shadow(radius: 3)
          )
          .padding()
        }
      }
      .frame(maxWidth: .infinity)
      .background(Color.backgroundColor)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done", action: dismissReceiptView)
        }
      }
    }
  }
  
  func dismissReceiptView() {
    showingReceipt = false
  }
}

struct TopUpReceipt {
  let date: String
  let time: String
  let cardBrand: String
  let cardLast4: String
  let topUpAmount: String
  let paidAmount: String
}
