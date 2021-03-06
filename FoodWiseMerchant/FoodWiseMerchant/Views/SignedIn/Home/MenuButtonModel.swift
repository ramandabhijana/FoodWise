//
//  MenuButtonModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 04/11/21.
//

import SwiftUI

enum MenuDestination {
  case manageFoodStock
  case editFoodDetails
  case chats
  case viewOrders
  case requestDelivery
  case scanBarcode
  case customerReviews
  case wallet
  case settings
  
  @ViewBuilder
  var view: some View {
    switch self {
    case .manageFoodStock:
      ManageFoodStockView()
    case .editFoodDetails:
      RootEditFoodDetailsView()
    case .chats:
      ConversationsView()
    case .viewOrders:
      OrdersView()
    case .requestDelivery:
      ZStack {
        Color.backgroundColor
        Text("Access this menu through ") + Text("View All Orders").bold()
      }
    case .scanBarcode:
      RecipientVerificationView()
    case .customerReviews:
      CustomerReviewsView()
    case .wallet:
      WalletDetailsView()
    case .settings:
      SettingsView()
    }
  }
}

struct MenuButtonModel<Destination: View>: Identifiable {
  let id = UUID()
  let imageSystemName: String
  let title: String
  let destination: MenuDestination
}

extension MenuButtonModel {
  static var allMenus: [MenuButtonModel] {
    [.init(imageSystemName: "rectangle.stack.badge.plus", title: "Manage Food Stock", destination: .manageFoodStock),
     .init(imageSystemName: "rectangle.and.pencil.and.ellipsis", title: "Edit Food Details", destination: .editFoodDetails),
     .init(imageSystemName: "bubble.left.and.bubble.right", title: "Chats", destination: .chats),
     .init(imageSystemName: "list.bullet.rectangle.portrait", title: "View Orders", destination: .viewOrders),
     .init(imageSystemName: "location.circle", title: "Request Delivery", destination: .requestDelivery),
     .init(imageSystemName: "barcode.viewfinder", title: "Scan Barcode", destination: .scanBarcode),
     .init(imageSystemName: "star.bubble", title: "Customer Reviews", destination: .customerReviews),
     .init(imageSystemName: "dollarsign.square", title: "Wallet", destination: .wallet),
     .init(imageSystemName: "gearshape.circle", title: "Settings", destination: .settings)
    ]
  }
  
  
}
