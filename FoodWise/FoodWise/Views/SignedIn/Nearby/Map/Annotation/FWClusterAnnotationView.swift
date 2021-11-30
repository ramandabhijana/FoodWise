//
//  FWClusterAnnotationView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import MapKit

class FWClusterAnnotationView: MKAnnotationView {
  static let reuseIdentifier = String(describing: FWClusterAnnotationView.self)
  static let clusteringIdentifier = "FWClusterAnnotationViewClusteringIdentifier"
  
  override var annotation: MKAnnotation? {
    didSet { setImage() }
  }
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    collisionMode = .circle
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setImage() {
    if let clusterAnnotation = annotation as? MKClusterAnnotation {
      self.image = getImage(count: clusterAnnotation.memberAnnotations.count)
    } else {
      self.image = getImage()
    }
  }
  
  private func getImage(count: Int? = nil) -> UIImage {
    let bounds = CGRect(
      origin: .zero,
      size: CGSize(width: 45, height: 45)
    )
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { context in
      UIColor(named: "AccentColor")?.setFill()
      UIBezierPath(ovalIn: bounds).fill()
      
      // draw the count text if the passed in value is not nil
      if let count = count {
        let text = count >= 100 ? "99+" : "\(count)"
        let attrs: [NSAttributedString.Key: Any] = [
          .foregroundColor: UIColor.white,
          .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        let size = text.size(withAttributes: attrs)
        let origin = CGPoint(
          x: bounds.midX - size.width / 2,
          y: bounds.midY - size.height / 2
        )
        let rect = CGRect(origin: origin, size: size)
        text.draw(in: rect, withAttributes: attrs)
      }
    }
  }
  
  
}
