//
//  PhotoZoomViewController.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/12/21.
//

import UIKit
import SDWebImage

class PhotoZoomViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var imageView: UIImageView!
  
  private var imageUrl: URL?
  
  convenience init(url: URL?) {
    self.init(nibName: nil, bundle: nil)
    self.imageUrl = url
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.sd_setImage(with: imageUrl, completed: { _,_,_,_ in })
    imageView.frame.size = imageView.image!.size
    scrollView.delegate = self
    setZoomParameters(scrollView.bounds.size)
    centerImage()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    setZoomParameters(scrollView.bounds.size)
    centerImage()
  }
  
  private func setZoomParameters(_ scrollViewSize: CGSize) {
    let imageSize = imageView.bounds.size
    
    // need to set the scale differently depending on how the image size compares to the scrollView size
    let widthScale = scrollViewSize.width / imageSize.width
    let heightScale = scrollViewSize.height / imageSize.height
    
    // find the smaller of those two results using min func
    let minScale = min(widthScale, heightScale)
    
    scrollView.minimumZoomScale = minScale
    scrollView.maximumZoomScale = 3.0
    scrollView.zoomScale = minScale
  }
  
  private func centerImage() {
    // to determine where the center is and how to place the image there
    // need both size of scroll view and size of image frame
    let scrollViewSize = scrollView.bounds.size
    let imageSize = imageView.frame.size
    
    // calculate space that should be surrounding the image
    // check to see if imagesize is less than scroll view size
    // then substract the images width from scroll view's width
    // and divide by two to get padding for one side
    // if not give zero space
    let horizontalSpace = imageSize.width < scrollViewSize.width
      ? (scrollViewSize.width - imageSize.width) / 2
      : .zero
    
    let verticalSpace = imageSize.height < scrollViewSize.height
      ? (scrollViewSize.height - imageSize.height) / 2
      : .zero
    
    scrollView.contentInset = UIEdgeInsets(
      top: verticalSpace,
      left: horizontalSpace,
      bottom: verticalSpace,
      right: horizontalSpace)
  }
  
}

extension PhotoZoomViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
  
  
}
