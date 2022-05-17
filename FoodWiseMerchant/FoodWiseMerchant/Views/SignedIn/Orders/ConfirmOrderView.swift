//
//  ConfirmOrderView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 11/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct OrderConfirmationView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @StateObject private var viewModel: ConfirmOrderViewModel
  
  static private var requestDeliveryViewModel: RequestDeliveryViewModel!
  
  @Environment(\.presentationMode) var presentationMode
  
  init(viewModel: ConfirmOrderViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 22) {
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
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
          }
          .padding()
        }
        
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
          VStack(alignment: .leading) {
            Text("Order items")
              .bold()
              .font(.subheadline)
            VStack(spacing: 16) {
              ForEach(viewModel.order.items, content: makeOrderItemCell)
              
              HStack {
                Text("Subtotal")
                  .font(.caption)
                Spacer()
                Text(viewModel.orderSubtotalFormatted)
                  .bold()
                  .font(.footnote)
              }
              
              HStack {
                Text("Delivery Charge")
                  .font(.caption)
                Spacer()
                Text(viewModel.orderDeliveryFormatted)
                  .bold()
                  .font(.footnote)
              }
              
              HStack {
                Text("Total")
                  .font(.caption)
                Spacer()
                Text(viewModel.orderTotalFormatted)
                  .bold()
                  .font(.footnote)
              }
              
            }
          }
          .padding()
        }
        
        if let shippingAddress = viewModel.order.shippingAddress {
          ZStack {
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.white)
              .shadow(radius: 2)
            VStack(alignment: .leading) {
              Text("Delivery Details")
                .bold()
                .font(.subheadline)
              
              PickupDestinationView(
                pickupAddress: mainViewModel.merchant.location.geocodedLocation,
                pickupDetails: mainViewModel.merchant.addressDetails,
                destinationAddress: shippingAddress.geocodedLocation,
                destinationDetails: shippingAddress.details
              ).padding(.top, 8)
              
              // Pending && Not requested
              if viewModel.order.status == OrderStatus.pending.rawValue {
                Button(action: {
                  viewModel.showingRequestDeliveryAndAccept = true
                }) {
                  RoundedRectangle(cornerRadius: 8)
                    .frame(height: 32)
                    .overlay {
                      Text("Request Delivery")
                        .font(.footnote)
                        .foregroundColor(.white)
                    }
                }
                .padding(.top)
              }
              
              
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
          VStack(alignment: .leading) {
            Text("Customer")
              .bold()
              .font(.subheadline)
            HStack {
              WebImage(url: URL(string: viewModel.order.customerProfilePicUrl))
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
              Text(viewModel.order.customerName)
                .font(.caption)
              Spacer()
              Button {
                viewModel.showingChatView = true
              } label: {
                Text("\(Image(systemName: "bubble.right")) Chat")
                  .bold()
                  .font(.subheadline)
              }
              .overlay {
                NavigationLink(
                  isActive: $viewModel.showingChatView,
                  destination: {
                    LazyView(ChatRoomView(
                      userId: mainViewModel.merchant.id,
                      otherUserType: kCustomerType,
                      otherUserProfilePictureUrl: URL(string: viewModel.order.customerProfilePicUrl),
                      otherUserName: viewModel.order.customerName,
                      otherUserId: viewModel.order.customerId))
                  },
                  label: EmptyView.init)
              }
            }
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        
      }
      .padding()
      .padding(.bottom, 70)
    }
    .background(Color.backgroundColor)
    .navigationTitle("Confirm Order")
    .navigationBarTitleDisplayMode(.inline)
    
    .onAppear {
      viewModel.merchantName = mainViewModel.merchant.name
    }
    .onReceive(viewModel.$shouldDismissView, perform: { dismissed in
      if dismissed {
        presentationMode.wrappedValue.dismiss()
      }
    })
    .sheet(isPresented: $viewModel.showingRejectSheet, content: {
      RejectOrderView(
        remarksText: $viewModel.remarksText,
        showingRejectSheet: $viewModel.showingRejectSheet,
        onSendButtonTapped: viewModel.rejectOrder
      )
    })
    .fullScreenCover(
      isPresented: $viewModel.showingRequestDeliveryView,
      onDismiss: {
        setNavigationBarColor(withStandardColor: .primaryColor, andScrollEdgeColor: .primaryColor)
      },
      content: {
        RequestDeliveryView(viewModel: Self.requestDeliveryViewModel)
      }
    )
    .overlay(alignment: .bottom) {
      ZStack {
        Rectangle()
          .fill(Color.backgroundColor)
          .shadow(radius: 5)
          .edgesIgnoringSafeArea(.bottom)
        HStack {
          Button {
            viewModel.showRejectSheet(true)
          } label: {
            ZStack {
              RoundedRectangle(cornerRadius: 8)
                .strokeBorder(lineWidth: 2)
              Text("Reject")
            }
          }
          Button {
            viewModel.showingAcceptAlert = true
          } label: {
            ZStack {
              RoundedRectangle(cornerRadius: 8)
              Text("Accept")
                .foregroundColor(.white)
            }
          }
        }
        .frame(height: 44)
        .padding()
        .padding(.bottom)
        .disabled(viewModel.order.status != OrderStatus.pending.rawValue)
      }
      .frame(height: 44)
    }
    .alert(
      "Accept Order?",
      isPresented: $viewModel.showingAcceptAlert
    ) {
      Group {
        Button("Cancel") { viewModel.showingAcceptAlert = false }
        Button("Accept") {
          viewModel.acceptOrder()
        }
      }
    }
    .alert(
      "Please request delivery first",
      isPresented: $viewModel.showingRequestDeliveryRequiredAlert
    ) {
      Button("OK", action: showRequestDeliveryView)
    }
    .alert(
      "Once you find a courier, the order will be automatically confirmed as accepted",
      isPresented: $viewModel.showingRequestDeliveryAndAccept
    ) {
      Button("Cancel") { }
      Button("Continue", action: showRequestDeliveryView)
    }
    .overlay {
      if viewModel.loading {
        ZStack {
         Color.black.opacity(0.5)
         HStack(spacing: 10) {
           ProgressView()
             .progressViewStyle(
               CircularProgressViewStyle(tint: .black)
             )
           Text("Loading...")
         }
         .padding()
         .background(.thinMaterial)
         .cornerRadius(8)
       }
       .edgesIgnoringSafeArea(.top)
      }
    }
    
  }
  
  private func makeOrderItemCell(_ item: LineItem) -> some View {
    VStack(spacing: 8) {
      HStack(alignment: .top, spacing: 10) {
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
        
        Spacer()
        Text("×\(item.quantity)")
          .font(Font.caption)
          .bold()
        Spacer()
        Text(NumberFormatter.rpCurrencyFormatter.string(from: .init(value: item.price ?? .zero)) ?? "")
          .bold()
          .font(.caption)
      }
      Divider()
      
    }
  }
  
  private func showRequestDeliveryView() {
    guard let shippingAddress = viewModel.order.shippingAddress else { return }
    Self.requestDeliveryViewModel = .init(
      pickupGeoCooordinate: mainViewModel.merchant.location.coordinate,
      destinationGeoCoordinate: shippingAddress.clLocation.coordinate,
      pickupAddress: mainViewModel.merchant.location.geocodedLocation,
      pickupDetails: mainViewModel.merchant.addressDetails,
      destinationAddress: shippingAddress.geocodedLocation,
      destinationDetails: shippingAddress.details,
      order: viewModel.order)
    viewModel.listenRequestDeliveryPublisher(Self.requestDeliveryViewModel.deliveryTaskAssignedPublisher)
    viewModel.showingRequestDeliveryView = true
  }
}

private extension OrderConfirmationView {
  struct RejectOrderView: View {
    @Binding var remarksText: String
    @Binding var showingRejectSheet: Bool
    @FocusState private var textEditorFocused: Bool
    @State var showLoading = false
    
    var onSendButtonTapped: () -> ()
    
    var body: some View {
      NavigationView {
        ScrollView {
          VStack(alignment: .leading) {
            Text("Tell the customer why you have to reject the order:")
            TextEditor(text: $remarksText)
              .disableAutocorrection(true)
              .frame(minWidth: 0, maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.5)
              .border(Color.secondary)
              .focused($textEditorFocused)
          }
          .navigationTitle("Reject Order")
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              Button("Close") { showingRejectSheet = false }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
              Button(action: {
                showLoading = true
                onSendButtonTapped()
              }) {
                if !showLoading {
                  Text("Send").font(.headline.bold())
                } else {
                  ProgressView()
                    .progressViewStyle(
                      CircularProgressViewStyle(tint: .black)
                    )
                }
              }
              .disabled(remarksText.isEmpty)
            }
            ToolbarItem(placement: .keyboard) {
              HStack {
                Spacer()
                Button("Done") { textEditorFocused = false }
              }
            }
          }
          .padding()
        }
        .background(Color.backgroundColor)
      }
    }
  }
}
