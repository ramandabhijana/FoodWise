//
//  FWDestinationAnnotationView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 07/04/22.
//

import MapKit
import SwiftUI

class FWDestinationAnnotationView: MKAnnotationView {
  static let reuseIdentifier = String(describing: FWDestinationAnnotationView.self)
  
  // the SwiftUI View
  private var rootView = DestinationAnnotationView()
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    collisionMode = .circle
    frame = CGRect(x: 0, y: 0, width: 30, height: 60)
    centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
    addToSubview()
  }
  
  private func addToSubview() {
    let view = UIHostingController(rootView: rootView).view!
    view.backgroundColor = .clear
    self.addSubview(view)
    view.frame = bounds
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
