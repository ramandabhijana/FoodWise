//
//  Coordinator+MessageCellDelegate.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 02/03/22.
//

import MessageKit

public protocol CoordinatorCellDelegate: AnyObject {
  func didTapAccessoryView(in cell: MessageCollectionViewCell, messageData: [MessageType])
  func didTapMessage(in cell: MessageCollectionViewCell, messageData: [MessageType])
  func didTapImage(in cell: MessageCollectionViewCell, messageData: [MessageType])
}

extension ChatViewViewControllerRepresentation.Coordinator: MessageCellDelegate {
  func didTapAccessoryView(in cell: MessageCollectionViewCell) {
    cellDelegate?.didTapAccessoryView(in: cell, messageData: messages)
    print("Accessory view tapped")
  }
  
  func didTapMessage(in cell: MessageCollectionViewCell) {
    cellDelegate?.didTapMessage(in: cell, messageData: messages)
    
  }
  
  func didTapImage(in cell: MessageCollectionViewCell) {
    cellDelegate?.didTapImage(in: cell, messageData: messages)
  }
  
  
}
