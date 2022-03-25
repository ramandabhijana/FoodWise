//
//  Coordinator+MessagesDataSource.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 02/03/22.
//

import MessageKit
import UIKit


extension ChatViewViewControllerRepresentation.Coordinator: MessagesDataSource {
  func currentSender() -> SenderType {
    // TODO: Replace with real data
    return Sender(senderId: userId, displayName: "", photoURL: "")
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
  
  func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    let dateString = messageBottomDateFormatter.string(from: message.sentDate)
    return NSAttributedString(
      string: dateString,
      attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
  }
  
  func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    let dateString = messageTimestampDateFormatter.string(from: message.sentDate)
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.boldSystemFont(ofSize: 10),
      .foregroundColor: UIColor.systemGray]
    return NSAttributedString(string: dateString, attributes: attributes)
  }
  
}
