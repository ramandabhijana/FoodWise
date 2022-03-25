//
//  PhotoViewerViewController.swift
//  Messanger
//
//  Created by Abhijana Agung Ramanda on 21/08/20.
//  Copyright © 2020 Abhijana Agung Ramanda. All rights reserved.
//

import UIKit

class PhotoViewerViewController: UIViewController {
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let url: URL
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Photo"
    navigationItem.largeTitleDisplayMode = .never
    view.backgroundColor = .black
    view.addSubview(imageView)
    imageView.sd_setImage(with: url, completed: nil)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    imageView.frame = view.bounds
  }
  
  init(with url: URL) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
