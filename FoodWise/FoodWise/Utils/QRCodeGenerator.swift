//
//  QRCodeGenerator.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

import UIKit
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
  private let context: CIContext = .init()
  private let filter: CIFilter & CIQRCodeGenerator = CIFilter.qrCodeGenerator()
  
  func generate(from string: String) -> UIImage? {
    filter.message = Data(string.utf8)
    if let outputImage = filter.outputImage,
       let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
      return UIImage(cgImage: cgImage)
    }
    return nil
  }
  

}


