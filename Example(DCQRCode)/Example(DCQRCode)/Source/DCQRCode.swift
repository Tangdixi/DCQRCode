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
  
  private lazy var version:Int = self.fetchQRCodeVersion()
  private var info:String
  private var size:CGSize
  
  /* Temporarily disable these two property */
  private var bottomImage:UIImage?
  private var quietZoneColor:UIColor = UIColor.whiteColor()
  
  var bottomColor = UIColor.whiteColor()
  var topColor = UIColor.blackColor()
  var topImage:UIImage?
  
  var positionInnerColor:UIColor?
  var positionOuterColor:UIColor?
  var positionInnerStyle:[(UIImage, DCQRCodePosition)]?
  var positionStyle:[(UIImage, DCQRCodePosition)]?
  
  var centerImage:UIImage?
  
  init(info:String, size:CGSize) {
    self.info = info
    self.size = size.scale(UIScreen.mainScreen().scale)
  }
  
  /*
   
   */
  func image() -> UIImage {
    
    /* Start from a white blank image */
    let originImage = CIImage.emptyImage()
    var filter = generateQRCodeFilter(self.info) >>> resizeFilter(self.size) >>> falseColorFilter(topColor, color1: bottomColor)
    
    /* Processing through Core Image */
    if let topImage = self.topImage {
      
      guard let ciTopImage = CIImage(image: topImage) else { fatalError() }
      let topImageResizeFilter = resizeFilter(self.size)
      let resizeTopImage = topImageResizeFilter(ciTopImage)
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
    var image = UIImage(CIImage: ciImage)
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
    image.drawInRect(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

    defer {
      
      UIGraphicsEndImageContext()
      
    }
    
    if let positionOuterColor = self.positionOuterColor where self.positionStyle == nil {
      
      changeOuterPositionColor(positionOuterColor, position: .BottomLeft)
      changeOuterPositionColor(positionOuterColor, position: .TopLeft)
      changeOuterPositionColor(positionOuterColor, position: .TopRight)
      
      image = UIGraphicsGetImageFromCurrentImageContext()
      
    }
    
    if let positionInnerColor = self.positionInnerColor where self.positionInnerStyle == nil {
      
      let originColorImage = CIImage.emptyImage()
      let color = CIColor(color: positionInnerColor)
      let filter = constantColorGenerateFilter(color) >>> cropFilter(CGRectMake(0, 0, 2, 2))
      let ciColorImage = filter(originColorImage)
      let colorImage = UIImage(CIImage: ciColorImage)
      
      changePositionInnerColor(colorImage, position: .TopLeft)
      changePositionInnerColor(colorImage, position: .TopRight)
      changePositionInnerColor(colorImage, position: .BottomLeft)
      
      image = UIGraphicsGetImageFromCurrentImageContext()
      
    }
    
    if let positionStyle = self.positionStyle {
      
      self.clearOuterPosition(positionStyle)
      
      positionStyle.forEach {
        changeOuterPositionStyle($0, position: $1)
      }
      image = UIGraphicsGetImageFromCurrentImageContext()
      
    }
    
    if let positionInnerStyle = self.positionInnerStyle {
      
      self.clearInnerPosition(positionInnerStyle)
      
      positionInnerStyle.forEach {
        changePositionInnerColor($0, position: $1)
      }
      image = UIGraphicsGetImageFromCurrentImageContext()
      
    }
    
    if let centerImage = self.centerImage {
      
      changePositionInnerColor(centerImage, position: .Center)
      
      image = UIGraphicsGetImageFromCurrentImageContext()
      
    }
    
    /* Make sure the QRCode's quiet zone clear */
    
    if self.bottomColor != UIColor.whiteColor() {
      
      changeOuterPositionColor(self.bottomColor, position: .QuietZone)
      
      image = UIGraphicsGetImageFromCurrentImageContext()
      
    }
    
    return image
    
  }
}

//MARK: Private Method -

extension DCQRCode {
  
  private func fetchQRCodeVersion() -> Int {
    
    /* Fetch the qrcode version */
    let originImage = CIImage.emptyImage()
    let filter = generateQRCodeFilter(self.info)
    let width = Int(filter(originImage).extent.width)
    
    print("Version:\((width - 23)/4 + 1)")
    
    return (width - 23)/4 + 1
    
  }
  
  private func generateAlphaQRCode() -> CIImage {
    
    let originImage = CIImage.emptyImage()
    let filter = generateQRCodeFilter(self.info) >>> resizeFilter(self.size) >>> falseColorFilter(UIColor.blackColor(), color1: UIColor.whiteColor()) >>> maskToAlphaFilter()
    let image = filter(originImage)
    return image
    
  }
  
  private func generateReverseAlphaQRCode() -> CIImage {
    
    let originImage = CIImage.emptyImage()
    let filter = generateQRCodeFilter(self.info) >>> resizeFilter(self.size) >>> falseColorFilter(UIColor.whiteColor(), color1: UIColor.blackColor()) >>> maskToAlphaFilter()
    let image = filter(originImage)
    return image
    
  }
  
  private func changeOuterPositionColor(color:UIColor, position:DCQRCodePosition) {
    
    let path = position.outerPositionPath(self.size, version: self.version)
    color.setStroke()
    path.stroke()
    
  }
  
  private func changeOuterPositionStyle(image:UIImage, position:DCQRCodePosition) {
    
    let rect = position.outerPositionRect(self.size, version: self.version)
    
    image.drawInRect(rect)
    
  }
  
  private func changePositionInnerColor(image:UIImage, position:DCQRCodePosition) {
    
    let rect = position.innerPositionRect(self.size, version: self.version)
    image.drawInRect(rect)
    
  }
  
  private func clearOuterPosition(positionStyle:[(UIImage, DCQRCodePosition)]) {
    
    guard let context = UIGraphicsGetCurrentContext() else { fatalError() }
    
    positionStyle.forEach {
      
      let rect = $1.outerPositionRect(self.size, version: self.version)
      
      CGContextAddRect(context, rect)
      
    }
  
    CGContextClip(context)
    CGContextClearRect(context, CGRectMake(0, 0, self.size.width, self.size.height))

  }
  
  private func clearInnerPosition(positionInnerStyle:[(UIImage, DCQRCodePosition)]) {
    
    guard let context = UIGraphicsGetCurrentContext() else { fatalError() }
    
    positionInnerStyle.forEach {
      
      let rect = $1.innerPositionRect(self.size, version: self.version)
      
      CGContextAddRect(context, rect)
      
    }
    
    CGContextClip(context)
    CGContextClearRect(context, CGRectMake(0, 0, self.size.width, self.size.height))
    
  }
}

//MARK: Position Stuff -

enum DCQRCodePosition {
  
  static let innerPositionTileOriginWidth = CGFloat(3)
  static let outerPositionPathOriginLength = CGFloat(6)
  static let outerPositionTileOriginWidth = CGFloat(7)
  
  case TopLeft, TopRight, BottomLeft, Center, QuietZone
  
  func innerPositionRect(size:CGSize, version:Int) -> CGRect {
    
    let leftMargin = size.width * 3 / CGFloat((version - 1) * 4 + 23)
    let tileWidth = leftMargin
    let centerImageWith = size.width * 7 / CGFloat((version - 1) * 4 + 23)
    
    var rect = CGRect(origin: CGPoint(x: leftMargin, y: leftMargin), size: CGSize(width: leftMargin, height: leftMargin))
    rect = CGRectIntegral(rect)
    rect = CGRectInset(rect, -1, -1)
    
    switch self {
      
      case .TopLeft:
        
        return rect
      
      case .TopRight:
        
        let offset = size.width - tileWidth - leftMargin*2
        rect = CGRectOffset(rect, 0, offset)
        return rect
      
      case .BottomLeft:
        
        let offset = size.width - tileWidth - leftMargin*2
        rect = CGRectOffset(rect, offset, 0)
        return rect
      
      case .Center:
        
        rect = CGRect(origin: CGPointZero, size: CGSize(width: centerImageWith , height: centerImageWith))
        let offset = size.width/2 - centerImageWith/2
        rect = CGRectOffset(rect, offset, offset)
        return rect
      
      default:
        return CGRectZero
    }
    
  }
  
  func outerPositionRect(size:CGSize, version:Int) -> CGRect {
    
    let zonePathWidth = size.width / CGFloat((version - 1) * 4 + 23)
    
    let outerPositionWidth = zonePathWidth * DCQRCodePosition.outerPositionTileOriginWidth
    var rect = CGRect(origin: CGPointMake(zonePathWidth, zonePathWidth), size: CGSize(width: outerPositionWidth, height: outerPositionWidth))

    rect = CGRectIntegral(rect)
    rect = CGRectInset(rect, -1, -1)
    
    switch self {
    case .TopLeft:
      
      return rect
      
    case .TopRight:
      
      let offset = size.width - outerPositionWidth - zonePathWidth*2
      rect = CGRectOffset(rect, offset, 0)
      return rect
      
    case .BottomLeft:
      
      let offset = size.width - outerPositionWidth - zonePathWidth*2
      rect = CGRectOffset(rect, 0, offset)
      return rect

    default:
      
      return CGRectZero
      
    }
    
  }
  
  func outerPositionPath(size:CGSize, version:Int) -> UIBezierPath {
    
    let zonePathWidth = size.width / CGFloat((version - 1) * 4 + 23)
    let positionFrameWidth = zonePathWidth * DCQRCodePosition.outerPositionPathOriginLength
    
    let topLeftPoint = CGPoint(x: zonePathWidth * 1.5, y: zonePathWidth * 1.5)
    var rect = CGRect(origin: topLeftPoint, size: CGSize(width: positionFrameWidth, height: positionFrameWidth))
    
    /* Make sure the frame will  */
    rect = CGRectIntegral(rect)
    rect = CGRectInset(rect, 1, 1)
    
    switch self {
      case .TopLeft:
        
        let path = rect.rectPath()
        path.lineWidth = zonePathWidth + 3
        path.lineCapStyle = .Square
        
        return path
      
      case .TopRight:
        
        let offset = size.width - positionFrameWidth - topLeftPoint.x * 2
        rect = CGRectOffset(rect, offset, 0)
        let path = rect.rectPath()
        path.lineWidth = zonePathWidth + 3
        path.lineCapStyle = .Square
        
        return path
      case .BottomLeft:
        
        let offset = size.width - positionFrameWidth - topLeftPoint.x * 2
        rect = CGRectOffset(rect, 0, offset)
        let path = rect.rectPath()
        path.lineWidth = zonePathWidth + 3
        path.lineCapStyle = .Square
        
        return path
      case .QuietZone:
      
        let zoneRect = CGRect(origin: CGPoint(x: zonePathWidth*0.5, y: zonePathWidth*0.5) , size: CGSizeMake(size.width - zonePathWidth, size.width - zonePathWidth))
        let zonePath = zoneRect.rectPath()
        zonePath.lineWidth = zonePathWidth + UIScreen.mainScreen().scale
        zonePath.lineCapStyle = .Square
      
        return zonePath
      default:
        
        return UIBezierPath()
    }
    
    
  }
  
}

//MARK: Some Convenience Caculation Extension -

extension CGSize {
  
  func scale(ratio: CGFloat) -> CGSize {
    
    return CGSize(width: self.width * ratio, height: self.height * ratio)
    
  }
  
}

extension CGRect {
  
  func rectPath() -> UIBezierPath {
    
    let path = UIBezierPath()
    
    path.moveToPoint(self.origin)
    path.addLineToPoint(CGPoint(x: self.origin.x, y: self.origin.y + self.size.height))
    path.addLineToPoint(CGPoint(x: self.origin.x + self.size.width, y: self.origin.y + self.size.height))
    path.addLineToPoint(CGPoint(x: self.origin.x + self.size.width, y: self.origin.y))
    path.addLineToPoint(self.origin)
    
    return path
    
  }
  
}



