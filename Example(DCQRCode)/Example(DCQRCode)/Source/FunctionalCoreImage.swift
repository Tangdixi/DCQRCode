//
//  CoreImageWrapper.swift
//  Example_DCPathButton
//
//  Created by tang dixi on 9/5/2016.
//  Copyright © 2016 Tangdixi. All rights reserved.
//

import Foundation
import CoreImage
import UIKit

typealias Filter = ((CIImage) -> CIImage)

infix operator >>> : DCQRCodePrecedence
precedencegroup DCQRCodePrecedence {
	associativity: left
	higherThan: AdditionPrecedence
	lowerThan: MultiplicationPrecedence
}

func >>>(firstFilter: @escaping Filter, secondFilter: @escaping Filter) -> Filter {
  return { image in
    secondFilter(firstFilter(image))
  }
}

func generateQRCodeFilter(_ info:String) -> Filter {
  return { _ in
    // Guard no illegal characters
    guard let data = info.data(using: String.Encoding.isoLatin1) else { fatalError() }
    let parameters = ["inputMessage": data, "inputCorrectionLevel": "H"] as [String : Any]
    guard let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: parameters) else { fatalError() }
    guard let outputImage = filter.outputImage else { fatalError() }
    return outputImage
  }
}

func cropFilter(_ cropRect:CGRect) -> Filter {
  return { image in
    
    let croppedImage = image.cropping(to: cropRect)
    return croppedImage
    
  }
}

func bitmapResizeFilter(_ desireSize:CGSize) -> Filter {
  return { image in
	
     let extent = image.extent.integral
     let scale = min(desireSize.width/extent.width, desireSize.height/extent.height)
     
     let width = Int(extent.width*scale)
     let height = Int(extent.height*scale)
     let colorSpace = CGColorSpaceCreateDeviceRGB()
     let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
     let bitmapRef = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
     
     let context = CIContext()
     let bitmapImage = context.createCGImage(image, from: extent)
     bitmapRef?.interpolationQuality = .none
     bitmapRef?.scaleBy(x: scale, y: scale)
     bitmapRef?.draw(bitmapImage!, in: extent)
     guard let scaledImageRef = bitmapRef?.makeImage() else { fatalError() }
     let scaledImage = CIImage(cgImage: scaledImageRef)
     
     return scaledImage

  }
}

func resizeFilter(_ desireSize:CGSize) -> Filter {
  return { image in
    
    let scaleRatio = desireSize.width/image.extent.width
    let scaledImage = image.applying(CGAffineTransform(scaleX: scaleRatio, y: scaleRatio))
    
    return scaledImage
  }
}

func falseColorFilter(_ color0:UIColor, color1:UIColor) -> Filter {
  return { image in
    let ciColor0 = CIColor(color:color0)
    let ciColor1 = CIColor(color:color1)
    let parameters = ["inputImage": image, "inputColor0": ciColor0, "inputColor1": ciColor1]
    guard let filter = CIFilter(name: "CIFalseColor", withInputParameters: parameters) else { fatalError() }
    guard let outputImage = filter.outputImage else { fatalError() }
    return outputImage
  }
}

func maskToAlphaFilter() -> Filter {
  return { image in
    let parameters = ["inputImage": image]
    guard let filter = CIFilter(name: "CIMaskToAlpha", withInputParameters: parameters) else { fatalError() }
    guard let outputImage = filter.outputImage else { fatalError() }
    return outputImage
  }
}

func blendWithAlphaMaskFilter(_ backgroundImage:CIImage, maskImage:CIImage) -> Filter {
  return { image in
    let parameters = ["inputImage": image, "inputBackgroundImage": backgroundImage, "inputMaskImage": maskImage]
    guard let filter = CIFilter(name: "CIBlendWithAlphaMask", withInputParameters: parameters) else { fatalError() }
    guard let outputImage = filter.outputImage else { fatalError() }
    return outputImage
  }
}

func affineTileFilter(_ transform:NSValue, corpRect:CGRect) -> Filter {
  return { image in
    let parameters = ["inputImage": image, "inputTransform": transform]
    guard let filter = CIFilter(name: "CIAffineTile", withInputParameters: parameters) else { fatalError() }
    guard var outputImage = filter.outputImage else { fatalError() }
    outputImage = outputImage.cropping(to: corpRect)
    return outputImage
  }
}

func colorBlendModeFilter(_ backgroundImage:CIImage) -> Filter {
  return { image in
    let parameters = ["inputImage": image, "inputBackgroundImage": backgroundImage]
    guard let filter = CIFilter(name: "CIColorBlendMode", withInputParameters: parameters) else { fatalError() }
    guard let outputImage = filter.outputImage else { fatalError() }
    return outputImage
  }
}

func constantColorGenerateFilter(_ color:CIColor) -> Filter {
  return { _ in
    let parameters = ["inputColor": color]
    guard let filter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: parameters) else { fatalError() }
    guard let outputImage = filter.outputImage else { fatalError() }
    return outputImage
  }
}
