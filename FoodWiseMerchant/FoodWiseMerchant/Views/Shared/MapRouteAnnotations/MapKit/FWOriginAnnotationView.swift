//
//  FWOriginAnnotationView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 07/04/22.
//

import MapKit
import SwiftUI

class FWOriginAnnotationView: MKAnnotationView {
  static let reuseIdentifier = String(describing: FWOriginAnnotationView.self)
  
  // the SwiftUI View
  private var rootView = OriginAnnotationView()
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    collisionMode = .circle
    frame = CGRect(x: 0, y: 0, width: 35, height: 35)
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

