//
//  CourierAnnotationView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/04/22.
//

import UIKit
import MapKit
import Combine

class CourierAnnotationView: MKAnnotationView {
  private let imageSize = CGSize(width: 40, height: 40)
  private let imageName = "courier"
  private var courseSubscription: AnyCancellable?
  
  static let reuseIdentifier = String(describing: CourierAnnotationView.self)
  
  override var annotation: MKAnnotation? {
    willSet {
      courseSubscription?.cancel()
    }
    didSet {
      
      guard let courierAnnotation = annotation as? CourierAnnotation else { return }
      let courierImage = UIImage(named: imageName)
      self.image = courierImage
      courseSubscription = courierAnnotation.publisher(for: \.course)
        .sink { [weak self] course in
          guard let self = self else { return }
          let courseRadians = course * Double.pi / 180
          self.transform = CGAffineTransform(rotationAngle: CGFloat(courseRadians))
        }
    }
  }
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
