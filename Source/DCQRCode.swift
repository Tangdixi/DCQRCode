//
//  DCQRCode.swift
//  Example_DCPathButton
//
//  Created by tang dixi on 8/5/2016.
//  Copyright © 2016 Tangdixi. All rights reserved.
//

import Foundation
import CoreImage
import AVFoundation
import UIKit

final class DCQRCode {
  
  fileprivate lazy var version:Int = self.fetchQRCodeVersion()
  fileprivate var info:String
  fileprivate var size:CGSize
  
    var bottomColor = UIColor.white
    var topColor = UIColor.black
    
  /* Temporarily disable these two property */
  fileprivate var bottomImage:UIImage?
  fileprivate var quietZoneColor:UIColor = UIColor.white
  
  /**
    Remove the QRCode Quiet Zone, default is __false__
   */
  var removeQuietZone = false
  
  /**
    The QRCode's background color, default is __White__
   */
  var backgroundColor = UIColor.white
  
  /**
    The main color of QRCode, default is __Black__
   */
  // var color = UIColor.black
  
  /**
    Blend an image into the QRCode. The image will scale and fill the QRCode
   */
  var maskImage:UIImage?
  
  /**
    There are three position inner frame in QRCode, locate in __TopLeft__, __TopRight__ and __BottomLeft__.
    If you only want one frame's color changed, use __*positionInnerStyle*__ instead
   */
  var positionInnerColor:UIColor?
  
  /**
    There are three position frame in QRCode, locate in __TopLeft__, __TopRight__ and __BottomLeft__.
    If you only want one frame's color changed, use __*positionStyle*__ instead
   */
  var positionOuterColor:UIColor?
  
  /**
    Use serveral images to custom your QRCode's Position Inner Frame, the image will auto fill to fit the position frame.
   */
  var positionInnerStyle:[(UIImage, DCQRCodePosition)]?
  
  /**
    Use serveral images to custom your QRCode's Position Frame, the image will auto fill to fit the position frame.
   */
  var positionStyle:[(UIImage, DCQRCodePosition)]?
  
  /**
    Attach an image in the center of a QRCode
   */
  var centerImage:UIImage?
  
  /**
    Create a DCQRCode object with the specify __info__ and __size__. The size will auto scale in a Retina screen to avoid blurry. 
    @param info A String that you want to store in QRCode
    @param size The QRCode image's size
   */
  init(info:String, size:CGSize) {
    self.info = info
    self.size = size.scale(UIScreen.main.scale)
  }
  
  /**
    Output the QRCode image
    @return An UIImage object
   */
  func image() -> UIImage {
    
    /* Start from a white blank image */
    let originImage = CIImage.empty()
		var filter = generateQRCodeFilter(self.info) >>> resizeFilter(self.size) >>> falseColorFilter(topColor, color1: bottomColor)
    
    /* Processing through Core Image */
    if let maskImage = self.maskImage {
      
      guard let ciTopImage = CIImage(image: maskImage) else { fatalError() }
      let maskImageResizeFilter = resizeFilter(self.size)
      let resizeTopImage = maskImageResizeFilter(ciTopImage)
      let alphaQRCode = generateAlphaQRCode()
      
      filter = filter >>> blendWithAlphaMaskFilter(resizeTopImage, maskImage: alphaQRCode)
      
    }
    
    if let bottomImage = self.bottomImage {
      
      guard let ciBottimImage = CIImage(image: bottomImage) else { fatalError() }
      let bottomResizeFilter = resizeFilter(self.size)
      let resizeBottimImage = bottomResizeFilter(ciBottimImage)
      let reverseAlphaQRCode = generateReverseAlphaQRCode()
      
      filter = filter >>> blendWithAlphaMaskFilter(resizeBottimImage, maskImage: reverseAlphaQRCode)
      
    }
    
    let ciImage = filter(originImage)
    var image = UIImage(ciImage: ciImage)
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

    defer {
      
      UIGraphicsEndImageContext()
      
    }
    
    if let centerImage = self.centerImage {
      
      changePositionInnerColor(centerImage, position: .center)
      
      image = UIGraphicsGetImageFromCurrentImageContext()!
      
    }
    
    if let positionOuterColor = self.positionOuterColor, self.positionStyle == nil {
      
      changeOuterPositionColor(positionOuterColor, position: .bottomLeft)
      changeOuterPositionColor(positionOuterColor, position: .topLeft)
      changeOuterPositionColor(positionOuterColor, position: .topRight)
      
      image = UIGraphicsGetImageFromCurrentImageContext()!
      
    }
    
    if let positionInnerColor = self.positionInnerColor, self.positionInnerStyle == nil {
      
      let originColorImage = CIImage.empty()
      let color = CIColor(color: positionInnerColor)
      let filter = constantColorGenerateFilter(color) >>> cropFilter(CGRect(x: 0, y: 0, width: 2, height: 2))
      let ciColorImage = filter(originColorImage)
      let colorImage = UIImage(ciImage: ciColorImage)
      
      changePositionInnerColor(colorImage, position: .topLeft)
      changePositionInnerColor(colorImage, position: .topRight)
      changePositionInnerColor(colorImage, position: .bottomLeft)
      
      image = UIGraphicsGetImageFromCurrentImageContext()!
      
    }
    
    if let positionStyle = self.positionStyle {
      
      self.clearOuterPosition(positionStyle)
      
      positionStyle.forEach {
        changeOuterPositionStyle($0, position: $1)
      }
      image = UIGraphicsGetImageFromCurrentImageContext()!
      
    }
    
    if let positionInnerStyle = self.positionInnerStyle {
      
      self.clearInnerPosition(positionInnerStyle)
      
      positionInnerStyle.forEach {
        changePositionInnerColor($0, position: $1)
      }
      image = UIGraphicsGetImageFromCurrentImageContext()!
      
    }
    
    /* Make sure the QRCode's quiet zone clear */
    
    if self.backgroundColor != UIColor.white {
      
      changeOuterPositionColor(self.backgroundColor, position: .quietZone)
      
      image = UIGraphicsGetImageFromCurrentImageContext()!
      
    }
    
    if self.removeQuietZone == true {
      
      let quietZoneWidth = self.size.width / CGFloat((version - 1) * 4 + 23)
      var rect = CGRect(origin: CGPoint.zero, size: self.size)
      rect = rect.insetBy(dx: quietZoneWidth, dy: quietZoneWidth)
      
      image = image.cropByRect(rect)
      
    }
    
    return image
    
  }
}

//MARK: Private Method -

extension DCQRCode {
  
  fileprivate func fetchQRCodeVersion() -> Int {
    
    /* Fetch the qrcode version */
    let originImage = CIImage.empty()
    let filter = generateQRCodeFilter(self.info)
    let width = Int(filter(originImage).extent.width)
    
    return (width - 23)/4 + 1
    
  }
  
  fileprivate func generateAlphaQRCode() -> CIImage {
    
    let originImage = CIImage.empty()
    let filter = generateQRCodeFilter(self.info) >>> resizeFilter(self.size) >>> falseColorFilter(UIColor.black, color1: UIColor.white) >>> maskToAlphaFilter()
		let image = filter(originImage)
    return image
    
  }
  
  fileprivate func generateReverseAlphaQRCode() -> CIImage {
    
    let originImage = CIImage.empty()
    let filter = generateQRCodeFilter(self.info) >>> resizeFilter(self.size) >>> falseColorFilter(UIColor.white, color1: UIColor.black) >>> maskToAlphaFilter()
    let image = filter(originImage)
    return image
    
  }
  
  fileprivate func changeOuterPositionColor(_ color:UIColor, position:DCQRCodePosition) {
    
    let path = position.outerPositionPath(self.size, version: self.version)
    color.setStroke()
    path.stroke()
    
  }
  
  fileprivate func changeOuterPositionStyle(_ image:UIImage, position:DCQRCodePosition) {
    
    let rect = position.outerPositionRect(self.size, version: self.version)
    
    image.draw(in: rect)
    
  }
  
  fileprivate func changePositionInnerColor(_ image:UIImage, position:DCQRCodePosition) {
    
    let rect = position.innerPositionRect(self.size, version: self.version)
    image.draw(in: rect)
    
  }
  
  fileprivate func clearOuterPosition(_ positionStyle:[(UIImage, DCQRCodePosition)]) {
    
    guard let context = UIGraphicsGetCurrentContext() else { fatalError() }
    
    positionStyle.forEach {
      
      let rect = $1.outerPositionRect(self.size, version: self.version)
      
      context.addRect(rect)
      
    }
  
    context.clip()
    context.clear(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))

  }
  
  fileprivate func clearInnerPosition(_ positionInnerStyle:[(UIImage, DCQRCodePosition)]) {
    
    guard let context = UIGraphicsGetCurrentContext() else { fatalError() }
    
    positionInnerStyle.forEach {
      
      let rect = $1.innerPositionRect(self.size, version: self.version)
      
      context.addRect(rect)
      
    }
    
    context.clip()
    context.clear(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
    
  }
}

//MARK: Position Stuff -

enum DCQRCodePosition {
  
  static let innerPositionTileOriginWidth = CGFloat(3)
  static let outerPositionPathOriginLength = CGFloat(6)
  static let outerPositionTileOriginWidth = CGFloat(7)
  
  case topLeft, topRight, bottomLeft, center, quietZone
  
  func innerPositionRect(_ size:CGSize, version:Int) -> CGRect {
    
    let leftMargin = size.width * 3 / CGFloat((version - 1) * 4 + 23)
    let tileWidth = leftMargin
    let centerImageWith = size.width * 7 / CGFloat((version - 1) * 4 + 23)
    
    var rect = CGRect(origin: CGPoint(x: leftMargin, y: leftMargin), size: CGSize(width: leftMargin, height: leftMargin))
    rect = rect.integral
    rect = rect.insetBy(dx: -1, dy: -1)
    
    switch self {
      
      case .topLeft:
        
        return rect
      
      case .topRight:
        
        let offset = size.width - tileWidth - leftMargin*2
        rect = rect.offsetBy(dx: offset, dy: 0)
        return rect
      
      case .bottomLeft:
        
        let offset = size.width - tileWidth - leftMargin*2
        rect = rect.offsetBy(dx: 0, dy: offset)
        return rect
      
      case .center:
        
        rect = CGRect(origin: CGPoint.zero, size: CGSize(width: centerImageWith , height: centerImageWith))
        let offset = size.width/2 - centerImageWith/2
        rect = rect.offsetBy(dx: offset, dy: offset)
        return rect
      
      default:
        return CGRect.zero
    }
    
  }
  
  func outerPositionRect(_ size:CGSize, version:Int) -> CGRect {
    
    let zonePathWidth = size.width / CGFloat((version - 1) * 4 + 23)
    
    let outerPositionWidth = zonePathWidth * DCQRCodePosition.outerPositionTileOriginWidth
    var rect = CGRect(origin: CGPoint(x: zonePathWidth, y: zonePathWidth), size: CGSize(width: outerPositionWidth, height: outerPositionWidth))

    rect = rect.integral
    rect = rect.insetBy(dx: -1, dy: -1)
    
    switch self {
    case .topLeft:
      
      return rect
      
    case .topRight:
      
      let offset = size.width - outerPositionWidth - zonePathWidth*2
      rect = rect.offsetBy(dx: offset, dy: 0)
      return rect
      
    case .bottomLeft:
      
      let offset = size.width - outerPositionWidth - zonePathWidth*2
      rect = rect.offsetBy(dx: 0, dy: offset)
      return rect

    default:
      
      return CGRect.zero
      
    }
    
  }
  
  func outerPositionPath(_ size:CGSize, version:Int) -> UIBezierPath {
    
    let zonePathWidth = size.width / CGFloat((version - 1) * 4 + 23)
    let positionFrameWidth = zonePathWidth * DCQRCodePosition.outerPositionPathOriginLength
    
    let topLeftPoint = CGPoint(x: zonePathWidth * 1.5, y: zonePathWidth * 1.5)
    var rect = CGRect(origin: topLeftPoint, size: CGSize(width: positionFrameWidth, height: positionFrameWidth))
    
    /* Make sure the frame will  */
    rect = rect.integral
    rect = rect.insetBy(dx: 1, dy: 1)
    
    switch self {
      case .topLeft:
        
        let path = rect.rectPath()
        path.lineWidth = zonePathWidth + 3
        path.lineCapStyle = .square
        
        return path
      
      case .topRight:
        
        let offset = size.width - positionFrameWidth - topLeftPoint.x * 2
        rect = rect.offsetBy(dx: offset, dy: 0)
        let path = rect.rectPath()
        path.lineWidth = zonePathWidth + 3
        path.lineCapStyle = .square
        
        return path
      case .bottomLeft:
        
        let offset = size.width - positionFrameWidth - topLeftPoint.x * 2
        rect = rect.offsetBy(dx: 0, dy: offset)
        let path = rect.rectPath()
        path.lineWidth = zonePathWidth + 3
        path.lineCapStyle = .square
        
        return path
      case .quietZone:
      
        let zoneRect = CGRect(origin: CGPoint(x: zonePathWidth*0.5, y: zonePathWidth*0.5) , size: CGSize(width: size.width - zonePathWidth, height: size.width - zonePathWidth))
        let zonePath = zoneRect.rectPath()
        zonePath.lineWidth = zonePathWidth + UIScreen.main.scale
        zonePath.lineCapStyle = .square
      
        return zonePath
      default:
        
        return UIBezierPath()
    }
    
    
  }
  
}

//MARK: Some Convenience Caculation Extension -

extension CGSize {
  
  func scale(_ ratio: CGFloat) -> CGSize {
    
    return CGSize(width: self.width * ratio, height: self.height * ratio)
    
  }
  
}

extension CGRect {
  
  func rectPath() -> UIBezierPath {
    
    let path = UIBezierPath()
    
    path.move(to: self.origin)
    path.addLine(to: CGPoint(x: self.origin.x, y: self.origin.y + self.size.height))
    path.addLine(to: CGPoint(x: self.origin.x + self.size.width, y: self.origin.y + self.size.height))
    path.addLine(to: CGPoint(x: self.origin.x + self.size.width, y: self.origin.y))
    path.addLine(to: self.origin)
    
    return path
    
  }
  
}

extension UIImage {
  
  func cropByRect(_ rect:CGRect) -> UIImage {
    
    let scaleRect = CGRect(x: rect.origin.x * self.scale, y: rect.origin.x * self.scale, width: rect.size.width * self.scale, height: rect.size.height * self.scale)
    guard let imageRef = self.cgImage?.cropping(to: scaleRect) else { fatalError() }
    let image = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
    
    return image
  }
  
}


