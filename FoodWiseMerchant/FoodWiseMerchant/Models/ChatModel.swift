//
//  ChatModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 06/03/22.
//

import UIKit
import MessageKit
import CoreLocation
import FirebaseFirestore

public let kCustomerType = "CUSTOMER"
public let kCourierType = "COURIER"
public let kMerchantType = "MERCHANT"

struct Conversations: Codable {
  let userId: String
  var all: [Conversation]
  
  var asObject: [String: Any] {
    ["userId": userId, "all": all.map(\.asObject)]
  }
}

struct Conversation: Codable {
  let id: String
  let chatRoomId: String
  let otherUserId: String
  let otherUserType: String
  var latestMessage: LatestMessage
  
  var asObject: [String: Any] {
    ["id": id,
     "chatRoomId": chatRoomId,
     "otherUserId": otherUserId,
     "otherUserType": otherUserType,
     "latestMessage": latestMessage.asObject]
  }
}

struct LatestMessage: Codable {
  let date: Timestamp
  let text: String
  let isRead: Bool
  
  var asObject: [String: Any] {
    ["date": date,
     "text": text,
     "isRead": isRead]
  }
}

struct ChatRoom: Identifiable, Codable {
  var id: String { "chatroom_\(userId)_\(otherUserId)" }
  let userId: String
  let otherUserId: String
  var messages: [Message]
  
  var asObject: [String: Any] {
    ["id": id,
     "userId": userId,
     "otherUserId": otherUserId,
     "messages": messages.map(\.asObject)]
  }
}

// Db model
struct Message: Identifiable, Codable {
  let id: String
  let type: String
  let content: String
  let dateTimestamp: Timestamp
  let senderId: String
  let isRead: Bool
  
  var asObject: [String: Any] {
    ["id": id,
     "type": type,
     "content": content,
     "dateTimestamp": dateTimestamp,
     "senderId": senderId,
     "isRead": isRead]
  }
}

// view model
struct MessageTypeImpl: MessageType {
  var messageId: String
  var sentDate: Date
  var kind: MessageKind
  var sender: SenderType
}
/*
 public protocol MessageType {

     /// The sender of the message.
     var sender: SenderType { get }

     /// The unique identifier for the message.
     var messageId: String { get }

     /// The date the message was sent.
     var sentDate: Date { get }

     /// The kind of message and its underlying kind.
     var kind: MessageKind { get }

 }
 */

struct Sender: SenderType {
  var senderId: String
  var displayName: String
  
  var photoURL: String
}

struct Media: MediaItem {
  var url: URL?
  var image: UIImage?
  var placeholderImage: UIImage
  var size: CGSize
}

struct Location: LocationItem {
  var location: CLLocation
  var size: CGSize
}

extension MessageKind: CustomStringConvertible {
  public var description: String {
    switch self {
    case .text(_):
      return "text"
    case .attributedText(_):
      return "attributed_text"
    case .photo(_):
      return "photo"
    case .video(_):
      return "video"
    case .location(_):
      return "location"
    case .emoji(_):
      return "emoji"
    case .audio(_):
      return "audio"
    case .contact(_):
      return "contact"
    case .custom(_):
      return "custom"
    case .linkPreview(_):
      return "linkPreview"
    }
  }
}
