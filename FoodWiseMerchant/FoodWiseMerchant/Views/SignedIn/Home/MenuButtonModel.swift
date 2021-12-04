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
      EmptyView()
    case .editFoodDetails:
      EmptyView()
    case .chats:
      EmptyView()
    case .viewOrders:
      EmptyView()
    case .requestDelivery:
      EmptyView()
    case .scanBarcode:
      EmptyView()
    case .customerReviews:
      EmptyView()
    case .wallet:
      EmptyView()
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
