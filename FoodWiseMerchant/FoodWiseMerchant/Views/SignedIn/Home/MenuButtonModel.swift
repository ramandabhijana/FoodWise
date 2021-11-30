//
//  MenuButtonModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 04/11/21.
//

import SwiftUI

struct MenuButtonModel<Destination: View>: Identifiable {
  let id = UUID()
  let imageSystemName: String
  let title: String
  let destination: (() -> Destination)? = nil
}

extension MenuButtonModel {
  static var allMenus: [MenuButtonModel] {
    [.init(imageSystemName: "rectangle.stack.badge.plus", title: "Manage Food Stock"),
     .init(imageSystemName: "rectangle.and.pencil.and.ellipsis", title: "Edit Food Details"),
     .init(imageSystemName: "bubble.left.and.bubble.right", title: "Chats"),
     .init(imageSystemName: "list.bullet.rectangle.portrait", title: "View Orders"),
     .init(imageSystemName: "location.circle", title: "Request Delivery"),
     .init(imageSystemName: "barcode.viewfinder", title: "Scan Barcode"),
     .init(imageSystemName: "star.bubble", title: "Customer Reviews"),
     .init(imageSystemName: "dollarsign.square", title: "Wallet"),
     .init(imageSystemName: "gearshape.circle", title: "Settings")
    ]
  }
}
