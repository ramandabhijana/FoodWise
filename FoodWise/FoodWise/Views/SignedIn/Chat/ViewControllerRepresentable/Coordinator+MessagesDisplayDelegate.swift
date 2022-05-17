//
//  Coordinator+MessagesDisplayDelegate.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 02/03/22.
//

import MessageKit
import UIKit
import MapKit


extension ChatViewViewControllerRepresentation.Coordinator: MessagesDisplayDelegate {
  func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    .black
  }
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message)
    ? UIColor(.primaryColor)
    : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
  }
  
  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
    let corner: MessageStyle.TailCorner =
          isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
  
  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    avatarView.isHidden = true
  }
}

// MARK: - Media Message
extension ChatViewViewControllerRepresentation.Coordinator {
  func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    guard let message = message as? MessageTypeImpl else { return }
    switch message.kind {
    case .photo(let media):
      guard let imageURL = media.url else { return }
      imageView.sd_setImage(with: imageURL, completed: nil)
    default:
      break
    }
  }
}

// MARK: - Location Messages
extension ChatViewViewControllerRepresentation.Coordinator {
  func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
    let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
    let pinImage = UIImage(named: "map_pin_primary")!
    annotationView.image = pinImage
    annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
    return annotationView
  }
  
  func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
    return { view in
      view.layer.transform = CATransform3DMakeScale(2, 2, 2)
      UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
        view.layer.transform = CATransform3DIdentity
      }, completion: nil)
    }
  }
  
  func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
    return LocationMessageSnapshotOptions(
      showsBuildings: true,
      showsPointsOfInterest: true,
      span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
  }
}
