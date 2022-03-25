//
//  YourBagView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

class OverlayViewManager: ObservableObject {
  @Published var view: AnyView? = nil
}

struct YourBagView: View {
  @EnvironmentObject var rootViewModel: RootViewModel
  @StateObject private var viewModel: YourBagViewModel
  
  @StateObject private var overlayManager: OverlayViewManager = .init()
  
  static private var checkoutViewModel: CheckoutViewModel!
  
  init(viewModel: YourBagViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    ZStack {
      NavigationView {
        Group {
          ZStack {
            if !viewModel.allBagItems.isEmpty {
              List {
                Section(header: buildHeader()) {
                  ForEach(viewModel.bagItems.indices, id: \.self) { index in
                    BagItemCell(bagViewModel: viewModel,
                                bagItem: $viewModel.bagItems[index])
                  }
                  .listRowSeparator(.hidden)
                  .listRowBackground(Color.backgroundColor)
                }
              }
              .sheet(isPresented: $viewModel.showingNotInStockItems) {
                NavigationView {
                  List {
                    ForEach(
                      viewModel.outOfStockBagItems.map(\.food),
                      content: makeNotInStockItemCell)
                  }
                  .listStyle(.plain)
                  .navigationTitle("Not in stock")
                  .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                      Button("Close") { viewModel.showingNotInStockItems = false }
                    }
                  }
                }
              }
              .sheet(isPresented: $viewModel.showingOutOfStockConfirmation) {
                NavigationView {
                  List {
                    ForEach(
                      viewModel.outOfStockBagItems.map(\.food),
                      content: makeNotInStockItemCell)
                  }
                  .listStyle(.plain)
                  .navigationTitle("Not in stock")
                  .padding(.bottom, 140)
                  .overlay(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 30) {
                      Text("Some items in your bag cannot be checked out. Do you still want to continue?")
                      HStack {
                        Button(action: { viewModel.showingOutOfStockConfirmation = false }) {
                          Text("Cancel")
                        }
                        Spacer()
                        Button(action: {
                          viewModel.showingOutOfStockConfirmation = false
                          viewModel.isNavigationToCheckoutActive = true
                        }) {
                          Text("Continue")
                            .bold()
                        }
                      }
                    }
                    .padding()
                  }
                }
              }
              .onReceive(viewModel.$isNavigationToCheckoutActive) { active in
                if active {
                  Self.checkoutViewModel = .init(orderItems: viewModel.lineItemsToCheckout, merchantId: viewModel.merchantId!)
                  viewModel.listenOrderPublisher(
                    Self.checkoutViewModel.$order
                      .compactMap({ $0 })
                      .eraseToAnyPublisher()
                  )
                }
              }
            } else {
              VStack {
                Spacer()
                Image("shopping-bag")
                  .resizable()
                  .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.25)
                Text("No items in your bag")
                Spacer()
              }
              .frame(maxWidth: .infinity)
            }
          }
        }
        .onAppear {
          setNavigationBarColor(withStandardColor: .backgroundColor,
                                andScrollEdgeColor: .backgroundColor)
          NotificationCenter.default.post(name: .tabBarShownNotification, object: nil)
          NotificationCenter.default.post(name: .tabBarChangeBackgroundToSecondaryColorNotification, object: nil)
          if let customerId = rootViewModel.customer?.id {
            viewModel.fetchBagItems(userId: customerId)
          } else {
            NotificationCenter.default.post(name: .signInRequiredNotification, object: nil)
          }
        }
        .redacted(reason: viewModel.loadingBagItems ? .placeholder : [])
        .disabled(viewModel.loadingBagItems)
        .padding(.bottom, 60)
        .listStyle(.plain)
        .navigationTitle("Your Bag")
        .background(Color.backgroundColor)
        .overlay(alignment: .bottom) {
          Rectangle()
            .frame(height: 60)
            .shadow(
              color: .black.opacity(0.2),
              radius: 5,
              x: 0,
              y: -2
            )
            .overlay {
              HStack(alignment: .top) {
                VStack(alignment: .leading) {
                  Text("Total")
                    .font(.subheadline)
                  Text(viewModel.totalPriceString)
                    .fontWeight(.bold)
                }
                Spacer()
                Button(action: { viewModel.prepareBagCheckout(userId: rootViewModel.customer!.id) }) {
                  RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.main.bounds.width * 0.3)
                    .overlay {
                      Text("Checkout")
                        .foregroundColor(.white)
                    }
                }
                .disabled(viewModel.bagItems.isEmpty || rootViewModel.customer == nil)
                /*
                 When checkout button is tapped
                 Loading
                 1. Fetch bag items
                 2. Check if there's out of stock items
                 3. Y ? -> Show confirmation dialog
                            - options: Review items, checkout anyway
                            
                    N ? -> Navigate to checkout view
                 */
                .overlay {
                  NavigationLink(
                    isActive: $viewModel.isNavigationToCheckoutActive,
                    destination: {
                      LazyView(CheckoutBagView(
//                        viewModel: .init(orderItems: viewModel.lineItemsToCheckout, merchantId: viewModel.merchantId!),
                        viewModel: Self.checkoutViewModel,
                        selectLocationViewModel: SelectLocationViewModel())
                      )
                        .environmentObject(overlayManager)
                        .environmentObject(viewModel)
                    },
                    label: EmptyView.init)
                }
              }
              .padding(.horizontal)
              .padding(.vertical, 8)
              .background(Color.secondaryColor)
            }
        }
        
      }
      .overlay {
        if viewModel.loadingCheckout {
          ZStack {
            Color.black.opacity(0.5)
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
          .edgesIgnoringSafeArea(.top)
        }
      }
      
      if let overlayView = overlayManager.view {
        overlayView
      }
    }
    
  }
  
  @ViewBuilder
  private func buildHeader() -> some View {
    if viewModel.outOfStockBagItems.count > 0 {
      HStack {
        Text(viewModel.outOfStockAlertText)
          .bold()
          .foregroundColor(.black)
        Spacer()
        Button("Learn more") { viewModel.showingNotInStockItems = true }
      }
      .padding(.vertical, 10)
      .background(Color.backgroundColor)
    } else {
      EmptyView()
    }
  }
}

private extension YourBagView {
  
  func makeNotInStockItemCell(_ food: Food) -> some View {
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
          Text(food.retailPriceString)
            .strikethrough()
            .foregroundColor(.secondary)
        }
        .font(.caption2)
      }
    }
    .padding(.vertical, 8)
  }
  
  struct BagItemCell: View {
    @EnvironmentObject var rootViewModel: RootViewModel
    @ObservedObject var bagViewModel: YourBagViewModel
    @Binding var bagItem: BagItemModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
      ZStack {
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.white)
        RoundedRectangle(cornerRadius: 10)
          .strokeBorder(Color.gray)
          .overlay(alignment: .topLeading) {
            VStack(alignment: .leading) {
              HStack(alignment: .top, spacing: 10) {
                WebImage(url: bagItem.food.imagesUrl[0])
                  .resizable()
                  .frame(width: 65, height: 65)
                  .cornerRadius(10)
                VStack(alignment: .leading, spacing: 5) {
                  Text(bagItem.food.name)
                    .font(Font.callout)
                  Text(bagItem.food.priceString)
                    .font(.caption)
                    .bold()
                  HStack {
                    Text("\(bagItem.food.discountRateString) OFF")
                      .foregroundColor(.errorColor)
                    Text(bagItem.food.retailPriceString)
                      .strikethrough()
                      .foregroundColor(.secondary)

                  }.font(.caption)
                }
              }
              Spacer()
              HStack(spacing: 22) {
                Text(
                  YourBagViewModel.rpCurrencyFormatter.string(from: .init(value: bagItem.price)) ?? "-"
                )
                  .font(Font.subheadline)
                  .fontWeight(Font.Weight.semibold)
                Spacer()
                Group {
                  Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash.fill")
                      .foregroundColor(.init(uiColor: .darkGray))
                  }

                  HStack {
                    Button(action: {
                      bagItem.lineItem.quantity -= 1
                      bagViewModel.updateBagItems(userId: rootViewModel.customer!.id)
                    }) {
                      Text("\(Image(systemName: "minus"))")
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .frame(width: 20, height: 20)
                    }
                    .disabled(bagItem.lineItem.quantity == 1)
                    
                    Divider()
                    Text("\(bagItem.lineItem.quantity)")
                      .bold()
                    Divider()
                    Button(action: {
                      bagItem.lineItem.quantity += 1
                      bagViewModel.updateBagItems(userId: rootViewModel.customer!.id)
                    }) {
                      Text("\(Image(systemName: "plus"))")
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .frame(width: 20, height: 20)
                    }
                    .disabled(
                      (bagItem.lineItem.quantity + 1) > bagItem.food.stock
                    )
                  }
                  .padding(3)
                  .padding(.horizontal, 5)
                  .overlay {
                    RoundedRectangle(cornerRadius: 5)
                      .strokeBorder(Color.accentColor)
                  }
                }
                .buttonStyle(.plain)
              }

            }

            .padding()
          }
      }
      .frame(height: 130)
      .padding(.vertical, 3)
      .alert(isPresented: $showingDeleteAlert) {
        Alert(
          title: Text("Remove item"),
          message: Text("Are you sure you want to remove “\(bagItem.food.name)” from your shopping bag?"),
          primaryButton: .default(Text("Yes"), action: {
            bagViewModel.removeItem(lineItem: bagItem.lineItem,
                                    userId: rootViewModel.customer!.id)
          }),
          secondaryButton: .cancel({
            showingDeleteAlert = false
          })
        )
      }
      
    }
  }
  
}
