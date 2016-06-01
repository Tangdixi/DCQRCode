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

typealias Filter = (CIImage -> CIImage)

infix operator >>> { associativity left }

func >>>(firstFilter:Filter, secondFilter:Filter) -> Filter {
  return { image in
    secondFilter(firstFilter(image))
  }
}

func generateQRCodeFilter(info:String) -> Filter {
  return { _ in
    // Guard no illegal characters
    guard let data = info.dataUsingEncoding(NSISOLatin1StringEncoding) else { fatalError() }
    let parameters = ["inputMessage": data, "inputCorrectionLevel": "H"]
    guard let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: parameters) else { fatalError() }
    guard let outputImage = filter.outputImage else { fatalError() }
    return outputImage
  }
}

func cropFilter(cropRect:CGRect) -> Filter {
  return { image in
    
    let croppedImage = image.imageByCroppingToRect(cropRect)
    return croppedImage
    
  }
}

func bitmapResizeFilter(desireSize:CGSize) -> Filter {
  return { image in
    
     let extent = CGRectIntegral(image.extent)
     let scale = min(desireSize.width/CGRectGetWidth(extent), desireSize.height/CGRectGetHeight(extent))
     
     let width = Int(CGRectGetWidth(extent)*scale)
     let height = Int(CGRectGetHeight(extent)*scale)
     let colorSpace = CGColorSpaceCreateDeviceRGB()
     let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
     let bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, bitmapInfo.rawValue)
     
     let context = CIContext()
     let bitmapImage = context.createCGImage(image, fromRect: extent)
     CGContextSetInterpolationQuality(bitmapRef, .None)
     CGContextScaleCTM(bitmapRef, scale, scale)
     CGContextDrawImage(bitmapRef, extent, bitmapImage)
     guard let scaledImageRef = CGBitmapContextCreateImage(bitmapRef) else { fatalError() }
     let scaledImage = CIImage(CGImage: scaledImageRef)
     
     return scaledImage

  }
}

func resizeFilter(desireSize:CGSize) -> Filter {
  return { image in
    
    let scaleRatio = desireSize.width/image.extent.width
    let scaledImage = image.imageByApplyingTransform(CGAffineTransformMakeScale(scaleRatio, scaleRatio))
    
    return scaledImage
  }
}

func falseColorFilter(color0:UIColor, color1:UIColor) -> Filter {
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

func blendWithAlphaMaskFilter(backgroundImage:CIImage, maskImage:CIImage) -> Filter {
  return { image in
    let parameters = ["inputImage": image, "inputBackgroundImage": backgroundImage, "inputMaskImage": maskImage]
    guard let filter = CIFilter(name: "CIBlendWithAlphaMask", withInputParameters: parameters) else { fatalError() }
    guard let outputImage = filter.outputImage else { fatalError() }
    return outputImage
  }
}

func affineTileFilter(transform:NSValue, corpRect:CGRect) -> Filter {
  return { image in
    let parameters = ["inputImage": image, "inputTransform": transform]
    guard let filter = CIFilter(name: "CIAffineTile", withInputParameters: parameters) else { fatalError() }
    guard var outputImage = filter.outputImage else { fatalError() }
    outputImage = outputImage.imageByCroppingToRect(corpRect)
    return outputImage
  }
}

func colorBlendModeFilter(backgroundImage:CIImage) -> Filter {
  return { image in
    let parameters = ["inputImage": image, "inputBackgroundImage": backgroundImage]
    guard let filter = CIFilter(name: "CIColorBlendMode", withInputParameters: parameters) else { fatalError() }
    guard let outputImage = filter.outputImage else { fatalError() }
    return outputImage
  }
}

func constantColorGenerateFilter(color:CIColor) -> Filter {
  return { _ in
    let parameters = ["inputColor": color]
    guard let filter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: parameters) else { fatalError() }
    guard let outputImage = filter.outputImage else { fatalError() }
    return outputImage
  }
}
