//
//  ChatViewController+CoordinatorCellDelegate.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 03/03/22.
//

import UIKit
import MessageKit
import CoreLocation
import MapKit

extension ChatViewController: CoordinatorCellDelegate {
  func didTapAccessoryView(in cell: MessageCollectionViewCell, messageData: [MessageType]) {
    
  }
  
  func didTapMessage(in cell: MessageCollectionViewCell, messageData: [MessageType]) {
    guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
    let message = messageData[indexPath.section]
    guard case .location(let loc) = message.kind else { return }
    let regionDistance: CLLocationDistance = 0.1
    let regionSpan = MKCoordinateRegion(center: loc.location.coordinate,
                                        latitudinalMeters: regionDistance,
                                        longitudinalMeters: regionDistance)
    let options = [
        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
    ]
    let placemark = MKPlacemark(coordinate: loc.location.coordinate, addressDictionary: nil)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.openInMaps(launchOptions: options)
  }
  
  func didTapImage(in cell: MessageCollectionViewCell, messageData: [MessageType]) {
    guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
    let message = messageData[indexPath.section]
    if case .photo(let mediaItem) = message.kind {
      guard let imageURL = mediaItem.url else { return }
      let vc = PhotoViewerViewController(with: imageURL)
      rootViewController?.present(vc, animated: true, completion: nil)
    }
  }
  
  var rootViewController: UIViewController? {
    let keyWindow = (UIApplication.shared.connectedScenes.first as! UIWindowScene).keyWindow
    return keyWindow?.rootViewController
  }
}
