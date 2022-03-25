//
//  Coordinator+MessagesLayoutDelegate.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 02/03/22.
//

import MessageKit
import UIKit

extension ChatViewViewControllerRepresentation.Coordinator: MessagesLayoutDelegate {
  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    0
  }
  
  func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    16
  }
  
  func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    .init(width: 0, height: 0)
  }
}
