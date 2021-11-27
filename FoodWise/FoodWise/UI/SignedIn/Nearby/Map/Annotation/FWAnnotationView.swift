//
//  FWAnnotationView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import SwiftUI
import MapKit

class FWAnnotationView: MKAnnotationView {
  static let reuseIdentifier = String(describing: FWAnnotationView.self)
  static let clusteringIdentifier = "FWAnnotationViewClusteringIdentifier"
  
  // the SwiftUI View
  private var rootView = FoodWiseAnnotationView()
  
  private let rootViewTagNumber = 10
  
  override var annotation: MKAnnotation? {
    willSet {
      clusteringIdentifier = FWAnnotationView.clusteringIdentifier
    }
    didSet {
      guard annotation !== oldValue else { return }
      if let annotation = annotation as? FWAnnotation,
         let previousView = self.viewWithTag(rootViewTagNumber) {
        previousView.removeFromSuperview()
        rootView = FoodWiseAnnotationView(
          imageUrl: annotation.imageUrl
        )
        addToSubview()
      }
    }
  }
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    collisionMode = .circle
    frame = CGRect(x: 0, y: 0, width: 50, height: 70)
    centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
    addToSubview()
  }
  
  private func addToSubview() {
    let view = UIHostingController(rootView: rootView).view!
    view.backgroundColor = .clear
    view.tag = rootViewTagNumber
    self.addSubview(view)
    view.frame = bounds
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
