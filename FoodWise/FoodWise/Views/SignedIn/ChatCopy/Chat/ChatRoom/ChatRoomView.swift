//
//  ChatRoomView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatRoomView: View {
  @Environment(\.dismiss) private var dismiss
  
  var userId: String
  var otherUserType: String
  var otherUserProfilePictureUrl: URL?
  var otherUserName: String?
  var otherUserId: String
  var chatRoomId: String?
  
  
  
  var body: some View {
    ChatViewViewControllerRepresentation(
      userId: userId,
      otherUserId: otherUserId,
      otherUserType: otherUserType,
      chatRoomId: chatRoomId
    )
      .padding(.vertical)
      .padding(.horizontal, 5)
      .background(Color.backgroundColor)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        
        ToolbarItem(placement: .navigationBarLeading) {
          HStack {
            Button(action: dismiss.callAsFunction) {
              Image(systemName: "chevron.left")
                .font(.body.weight(.bold))
                .foregroundColor(.init(uiColor: .darkGray))
            }
            .padding(.trailing)
            WebImage(url: otherUserProfilePictureUrl)
              .resizable()
              .frame(width: 30, height: 30)
              .clipShape(Circle())
            Text(otherUserName ?? "Chat User")
          }
        }
      }
  }
}
