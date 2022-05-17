//
//  OrderDetailsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct OrderDetailsView: View {
  @StateObject private var viewModel: OrderDetailsViewModel
  private static var receiptViewModel: OrderReceiptViewModel!
  
  init(viewModel: OrderDetailsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 22) {
        // Buttons (Track location & View Receipt)
        HStack {
          if viewModel.order.pickupMethod == OrderPickupMethod.delivery.rawValue {
            NavigationLink {
              LazyView(DeliveryTrackingView(viewModel: DeliveryTrackingViewModel(
                sessionId: viewModel.sessionId!,
                courier: viewModel.courier!,
                deliveryTask: viewModel.deliveryTask!)))
            } label: {
              RoundedRectangle(cornerRadius: 8)
                .strokeBorder(lineWidth: 2)
                .overlay {
                  Text("Track Location").bold()
                }
            }
            .disabled(viewModel.trackLocationButtonDisabled)
          }
          
          Button(action: {
            Self.receiptViewModel = OrderReceiptViewModel(
              order: viewModel.order,
              merchantName: viewModel.merchantNameAndProfilePicUrl.name)
            viewModel.showingReceipt = true
          }) {
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(lineWidth: 2)
              .overlay {
                Text("View Receipt").bold()
              }
          }
          .disabled(viewModel.loadingMerchant)
        }
        .frame(height: 44)
        
        // Details
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Text("Order Date:")
            Spacer()
            Text(viewModel.orderDateFormatted)
              .bold()
          }
          .font(.footnote)
          HStack {
            Text("Time:")
            Spacer()
            Text(viewModel.orderTimeFormatted)
              .bold()
          }
          .font(.footnote)
          
          HStack {
            Text("Pick up:")
            Spacer()
            Text(viewModel.order.pickupMethod)
              .bold()
          }
          .font(.footnote)
          
          HStack {
            Text("Payment:")
            Spacer()
            Text(viewModel.order.paymentMethod)
              .bold()
          }
          .font(.footnote)
          
          HStack {
            Text("Status:")
            Spacer()
            Text(viewModel.order.status)
              .bold()
          }
          .font(.footnote)
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
        )
        
        // Order Items
        VStack(alignment: .leading, spacing: 8) {
          Text("Order items")
            .bold()
            .font(.subheadline)
          VStack(spacing: 16) {
            ForEach(viewModel.order.items, content: makeOrderItemCell)
            HStack {
              Text("Subtotal")
                .font(.caption)
              Spacer()
              Text(viewModel.order.formattedSubtotal)
                .bold()
                .font(.footnote)
            }
            HStack {
              Text("Delivery Charge")
                .font(.caption)
              Spacer()
              Text(viewModel.order.formattedDeliveryCharge)
                .bold()
                .font(.footnote)
            }
            HStack {
              Text("Total")
                .font(.caption)
              Spacer()
              Text(viewModel.order.formattedTotal)
                .bold()
                .font(.footnote)
            }
          }
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
        )
        
        // Route
        if let shippingAddress = viewModel.order.shippingAddress {
          VStack(alignment: .leading, spacing: 0) {
            Text("Route")
              .bold()
              .font(.subheadline)
            PickupDestinationView(
              pickupAddress: viewModel.deliveryTask?.pickupAddress.geocodedLocation ?? "To be confirmed...",
              pickupDetails: viewModel.deliveryTask?.pickupAddress.details ?? "-",
              destinationAddress: shippingAddress.geocodedLocation,
              destinationDetails: shippingAddress.details
            ).padding(.top, 8)
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.white)
              .shadow(radius: 2)
          )
        }
        
        
        // Merchant & Courier
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            WebImage(url: viewModel.merchantNameAndProfilePicUrl.picUrl)
              .resizable()
              .placeholder {
                Image(systemName: "person.circle.fill")
                  .resizable()
                  .foregroundColor(.secondary)
                  .frame(width: 28, height: 28)
                  .clipShape(Circle())
              }
              .frame(width: 28, height: 28)
              .clipShape(Circle())
            VStack(alignment: .leading) {
              Text("MERCHANT")
                .font(.caption)
                .foregroundColor(.secondary)
              Text(viewModel.merchantNameAndProfilePicUrl.name)
                .font(.footnote.bold())
            }
            Spacer()
            Button {
              
            } label: {
              Text("Chat")
                .font(.footnote.bold())
                .padding(5)
                .padding(.horizontal)
                .background(
                  RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(lineWidth: 1.5)
                )
            }
          }
          if viewModel.order.pickupMethod == OrderPickupMethod.delivery.rawValue {
            Divider()
            HStack {
              WebImage(url: viewModel.courier?.profilePictureUrl)
                .resizable()
                .placeholder {
                  Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.secondary)
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())
              VStack(alignment: .leading) {
                Text("COURIER")
                  .font(.caption)
                  .foregroundColor(.secondary)
                Text(viewModel.courier?.name ?? "To be confirmed...")
                  .font(.footnote.bold())
              }
              Spacer()
              if let courier = viewModel.courier {
                Button {
                  
                } label: {
                  Text("Chat")
                    .font(.footnote.bold())
                    .padding(5)
                    .padding(.horizontal)
                    .background(
                      RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(lineWidth: 1.5)
                    )
                }
              }
            }
          }
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
        )
      }
      .padding()
    }
    .background(Color.backgroundColor)
    .navigationTitle("Order Details")
    .navigationBarTitleDisplayMode(.inline)
    .fullScreenCover(isPresented: $viewModel.showingReceipt) {
      OrderReceiptView(viewModel: Self.receiptViewModel)
    }
  }
  
  private func makeOrderItemCell(_ item: LineItem) -> some View {
    VStack(spacing: 8) {
      HStack(alignment: .top, spacing: 16) {
        WebImage(url: item.food?.imagesUrl[0])
          .resizable()
          .frame(width: 40, height: 40)
          .cornerRadius(10)
        VStack(alignment: .leading, spacing: 5) {
          Text(item.food?.name ?? "")
            .font(Font.caption)
          HStack {
            Text(item.food?.priceString ?? "")
            Text(item.food?.retailPriceString ?? "")
              .strikethrough()
              .foregroundColor(.secondary)
          }
          .font(.caption2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        HStack {
          Text("×\(item.quantity)")
          Spacer()
          Text(item.price?.asIndonesianCurrencyString() ?? "-")
        }
        .font(.caption.bold())
        .frame(width: UIScreen.main.bounds.width * 0.25, alignment: .leading)
      }
      .lineLimit(1)
      Divider()
      
    }
  }
}
