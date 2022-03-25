//
//  CheckoutBagView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 08/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct CheckoutBagView: View {
  @EnvironmentObject private var rootViewModel: RootViewModel
  @EnvironmentObject private var overlayManager: OverlayViewManager
  
  @StateObject private var viewModel: CheckoutViewModel
  @StateObject private var selectLocationViewModel: SelectLocationViewModel
  
  @State private var tabBarHeight: CGFloat = 0.0
  @State private var tabBar: UITabBar? = nil
  
  static private var topUpViewModel: TopUpViewModel!
  
  init(viewModel: CheckoutViewModel,
       selectLocationViewModel: SelectLocationViewModel
  ) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _selectLocationViewModel = StateObject(wrappedValue: selectLocationViewModel)
  }
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      
      VStack(alignment: .leading, spacing: 22) {
        
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
          VStack(alignment: .leading) {
            Text("Your items")
              .bold()
              .font(.subheadline)
              .padding(.leading)
            
            
            VStack(spacing: 16) {
              ForEach(viewModel.firstThreeItems, content: buildItemCell)
            }
            .padding([.horizontal])
            
            if viewModel.orderItems.count > 3 {
              Button("Show more") {
                viewModel.showingAllOrderItems = true
              }
              .font(.subheadline.bold())
              .frame(maxWidth: .infinity, alignment: .center)
            }
          }
          .padding(.vertical)
        }
        
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
          VStack(alignment: .leading) {
            Text("Merchant")
              .font(.subheadline)
              .bold()
            HStack(spacing: 10) {
              WebImage(url: viewModel.merchant?.logoUrl)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
              VStack(alignment: .leading) {
                Text(viewModel.merchant?.name ?? "Merchant's name")
                  .font(.footnote)
                Text(viewModel.merchant?.location.geocodedLocation ?? "Merchant's store location" + " • \(viewModel.distanceFromMerchantString)")
                  .font(.caption)
              }
              .foregroundColor(.black)
            }
            .redacted(reason: viewModel.merchant == nil ? .placeholder : [])
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
        }
        
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
          VStack(alignment: .leading) {
            Text("Pick up Method")
              .font(.subheadline)
              .bold()
            HStack {
              MethodButton(
                selected: viewModel.selectedPickupMethod == .selfPickup,
                title: CheckoutViewModel.PickupMethod.selfPickup.rawValue) {
                  viewModel.setSelectedPickupMethod(.selfPickup)
                }
              MethodButton(
                selected: viewModel.selectedPickupMethod == .delivery,
                title: CheckoutViewModel.PickupMethod.delivery.rawValue) {
                  guard viewModel.selectedPickupMethod != .delivery else { return }
                  viewModel.showingLocationPicker = true
                  if selectLocationViewModel.coordinate == nil {
                    selectLocationViewModel.fetchUserLocation()
                  }
                }
            }
            
            // Conditionally show destination details
            if let address = viewModel.shippingAddress,
               viewModel.selectedPickupMethod == .delivery {
              HStack {
                VStack(alignment: .leading) {
                  Text("Deliver to:").bold()
                  Text(address.geocodedLocation)
                  Text("Note: \(address.details)")
                    .foregroundColor(.secondary)
                }
                .font(.caption)
                Spacer()
                Button {
                  viewModel.showingLocationPicker = true
                  if selectLocationViewModel.coordinate == nil {
                    selectLocationViewModel.fetchUserLocation()
                  }
                } label: {
                  Image(systemName: "square.and.pencil")
                    .font(.body.bold())
                }
              }
              .padding(.top)
            }
            
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
        }
        
        
        ZStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
          VStack(alignment: .leading) {
            Text("Payment Method")
              .font(.subheadline)
              .bold()
            HStack {
              MethodButton(
                selected: viewModel.selectedPaymentMethod == .cash,
                title: CheckoutViewModel.PaymentMethod.cash.rawValue) {
                  viewModel.setSelectedPaymentMethod(.cash)
                }
              MethodButton(
                selected: viewModel.selectedPaymentMethod == .wallet,
                title: CheckoutViewModel.PaymentMethod.wallet.rawValue) {
                  guard let userId = rootViewModel.customer?.id,
                        viewModel.selectedPaymentMethod != .wallet
                  else {
                    return
                  }
                  viewModel.verifyWalletBalance(userId: userId)
                }
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
        }
        
        
      }
      .padding()
      .padding(.bottom, 250)
    }
    .onAppear {
      NotificationCenter.default.post(name: .tabBarHiddenNotification, object: nil)
    }
    .onDisappear {
      tabBar?.isHidden = false
    }
    .background(Color.backgroundColor)
    .navigationTitle("Checkout")
    .navigationBarHidden(viewModel.isLoading)
    .onReceive(viewModel.$showingOrderSubmitted, perform: { shows in
      if shows {
        overlayManager.view = AnyView(
          ZStack {
           Color.black.opacity(0.5)
           VStack(spacing: 10) {
             Image(systemName: "checkmark.circle.fill")
               .font(.largeTitle)
               .foregroundColor(.accentColor)
             Text("Order Submitted")
               .bold()
           }
           .padding()
           .background(Color.white)
           .cornerRadius(8)
         }
         .edgesIgnoringSafeArea(.top)
        )
      } else {
        overlayManager.view = AnyView(EmptyView())
      }
    })
    .onReceive(viewModel.$isLoading, perform: { shows in
      if shows {
        overlayManager.view = AnyView(
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
        )
      } else {
        overlayManager.view = AnyView(EmptyView())
      }
    })
    .onReceive(viewModel.$showingTopUpBalance, perform: { shows in
      if shows {
        overlayManager.view = AnyView(TopUpView(viewModel: Self.topUpViewModel))
      } else {
        overlayManager.view = AnyView(EmptyView())
      }
    })
    .overlay(alignment: .bottom) {
      checkoutSheet
        .offset(y: tabBarHeight)
    }
    .sheet(isPresented: $viewModel.showingAllOrderItems) {
      NavigationView {
        allOrderItemsView
          .navigationTitle("Order Items")
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              Button("Close") { viewModel.showingAllOrderItems = false }
            }
          }
      }
    }
    .fullScreenCover(isPresented: $viewModel.showingLocationPicker) {
      if let coordinate = selectLocationViewModel.coordinate {
        viewModel.shippingAddress = Address(
          location: coordinate,
          geocodedLocation: selectLocationViewModel.geocodedLocation,
          details: selectLocationViewModel.addressDetails)
        viewModel.setSelectedPickupMethod(.delivery)
      } else {
        viewModel.shippingAddress = nil
      }
      viewModel.updateDistance()
    } content: {
      LazyView(SelectLocationView(viewModel: selectLocationViewModel))
        .onDisappear {
          NotificationCenter.default.post(name: .tabBarHiddenNotification, object: nil)
        }
    }
    .confirmationDialog(
      "Insufficient Balance",
      isPresented: $viewModel.showingNotSufficientBalanceAlert,
      titleVisibility: .visible,
      actions: {
        Button("Top up") {
          guard let walletId = viewModel.wallet?.id else { return }
          Self.topUpViewModel = TopUpViewModel(
            repository: viewModel.walletRepository,
            walletId: walletId)
          Self.topUpViewModel.showingView = true
          viewModel.listenTransactionPublisher(
            Self.topUpViewModel.$transaction
              .compactMap({ $0 })
              .eraseToAnyPublisher()
          )
          viewModel.showingTopUpBalance = true
        }
      },
      message: {
        Text("To proceed using the wallet as a payment method, you must top up sufficient balance")
      }
    )
    .introspectTabBarController { controller in
      tabBarHeight = controller.tabBar.frame.height
      tabBar = controller.tabBar
      tabBar?.isHidden = true
    }
  }
  
  @ViewBuilder
  private func topUpBalanceBuilder() -> some View  {
    if viewModel.showingTopUpBalance {
      TopUpView(viewModel: Self.topUpViewModel)
    }
  }
  
  private var checkoutSheet: some View {
    Rectangle()
      .fill(Color.secondaryColor)
      .frame(height: 230)
      .shadow(radius: 5)
      .overlay(alignment: .topLeading) {
        VStack(spacing: 15) {
          Group {
            HStack {
              Text("Subtotal")
              Spacer()
              Text(viewModel.subTotalString)
            }
            HStack {
              Text("Delivery Charge")
              Spacer()
              Text(viewModel.deliveryFeeString)
            }
          }
          .font(.callout)
          HStack {
            Text("Total")
              .bold()
            Spacer()
            Text(viewModel.totalCostString)
              .bold()
          }
          Spacer()
          Button(action: { viewModel.placeOrder(customer: rootViewModel.customer!) }) {
            RoundedRectangle(cornerRadius: 10)
              .frame(height: 44)
              .overlay {
                if viewModel.isPlacingOrder {
                  ProgressView()
                    .progressViewStyle(
                      CircularProgressViewStyle(tint: .white)
                    )
                } else {
                  Text("Place Order")
                    .foregroundColor(.white)
                }
              }
          }
          .disabled(viewModel.placeOrderButtonDisabled)
        }
        .padding()
        .padding(.bottom)
      }
  }
  
  @ViewBuilder
  private func buildItemCell(with item: LineItem) -> some View {
    if let food = item.food, let price = item.price {
      VStack(spacing: 8) {
        HStack(alignment: .top, spacing: 10) {
          WebImage(url: food.imagesUrl[0])
            .resizable()
            .frame(width: 40, height: 40)
            .cornerRadius(10)
          VStack(alignment: .leading, spacing: 5) {
            Text(food.name)
              .lineLimit(1)
              .font(Font.caption)
            HStack {
              Text(food.priceString)
              Text("\(food.discountRateString) OFF")
                .foregroundColor(.red)
              Text("\(food.retailPriceString)")
                .strikethrough()
                .foregroundColor(.secondary)
            }.font(.caption2)
            Text("×\(item.quantity)")
              .font(Font.caption)
              .bold()
          }
          Spacer()
          Text(viewModel.currencyString(from: price))
            .bold()
            .font(.caption)
        }
        Divider()
      }
    } else {
      EmptyView()
    }
  }
  
  private var allOrderItemsView: some View {
    List {
      ForEach(viewModel.orderItems, content: buildItemCell)
        .listRowSeparator(.hidden)
    }
  }
}

private extension CheckoutBagView {
  
  struct MethodButton: View {
    var selected: Bool
    var title: String
    var action: () -> ()
    
    var body: some View {
      Button(action: action) {
        RoundedRectangle(cornerRadius: 5)
          .strokeBorder(
            selected ? Color.primaryColor : .secondary.opacity(0.5),
            lineWidth: 1.5
          )
          .background(selected ? Color.primaryColor : .clear)
          .cornerRadius(5)
          .frame(height: 44)
          .overlay {
            Text(title)
              .foregroundColor(.black)
          }
          .overlay(alignment: .topTrailing) {
            if selected {
              Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.init(uiColor: .darkGray))
                .padding(-5)
            }
          }
          .animation(.easeIn, value: selected)
      }
    }
  }
  
}
