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
  
  var background:(UIImage, CGRect)?
  var bottomColor = UIColor.whiteColor()
  var topColor = UIColor.blackColor()
  var bottomImage:UIImage?
  var topImage:UIImage?
  var quietZoneColor:UIColor = UIColor.whiteColor()
  
  var positionInnerColor:UIColor?
  var positionOuterColor:UIColor?
  var positionInnerStyle:UIImage?
  var positionOuterStyle:UIImage?
  
  var centerImage:UIImage?
  
  init(info:String, size:CGSize) {
    self.info = info
    self.size = size.scale(UIScreen.mainScreen().scale)
  }
  
  func generateQRCode() -> UIImage {
    
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
    
    /* Use Core Graphics to attach stuffs */
    if let positionOuterColor = self.positionOuterColor {
      
      UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
      image.drawInRect(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      
      changePositionOuterColor(positionOuterColor, position: .BottomLeft)
      changePositionOuterColor(positionOuterColor, position: .TopLeft)
      changePositionOuterColor(positionOuterColor, position: .TopRight)
      
      image = UIGraphicsGetImageFromCurrentImageContext()
      
      UIGraphicsEndImageContext()
      
    }
    
    if let positionInnerColor = self.positionInnerColor {
      
      let originColorImage = CIImage.emptyImage()
      let color = CIColor(color: positionInnerColor)
      let filter = constantColorGenerateFilter(color) >>> cropFilter(CGRectMake(0, 0, 2, 2))
      let ciColorImage = filter(originColorImage)
      let colorImage = UIImage(CIImage: ciColorImage)
      
      UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
      image.drawInRect(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      
      changePositionInnerColor(colorImage, position: .TopLeft)
      changePositionInnerColor(colorImage, position: .TopRight)
      changePositionInnerColor(colorImage, position: .BottomLeft)
      
      image = UIGraphicsGetImageFromCurrentImageContext()
      
      UIGraphicsEndImageContext()
      
    }
  
    if let centerImage = self.centerImage {
      
      UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
      
      image.drawInRect(CGRect(origin: CGPointZero, size: CGSize(width: image.size.width, height: image.size.height)))
      
      changePositionInnerColor(centerImage, position: .Center)
      
      image = UIGraphicsGetImageFromCurrentImageContext()
      
      UIGraphicsEndImageContext()
      
    }
    
    /* Make sure the QRCode's quiet zone clear */
    
    if self.bottomImage != nil || self.bottomColor != UIColor.whiteColor() {
      
      UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
      image.drawInRect(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      
      changePositionOuterColor(self.quietZoneColor, position: .QuietZone)
      
      image = UIGraphicsGetImageFromCurrentImageContext()
      
      UIGraphicsEndImageContext()
      
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
  
  private func changePositionOuterColor(color:UIColor, position:DCQRCodePosition) {
    
    let path = position.outerPositionPath(self.size, version: self.version)
    color.setStroke()
    path.stroke()
    
  }
  
  private func changePositionInnerColor(image:UIImage, position:DCQRCodePosition) {
    
    let rect = position.innerPositionRect(self.size, version: self.version)
    image.drawInRect(rect)
    
  }
  
}

//MARK: Position Stuff

enum DCQRCodePosition {
  
  static let innerPositionTileOriginWidth = CGFloat(3)
  static let outerPositionTileOriginWidth = CGFloat(6)
  
  case TopLeft, TopRight, BottomLeft, Center, QuietZone
  
  func innerPositionRect(size:CGSize, version:Int) -> CGRect {
    
    /* Caculate the size at first */
    let originTileCount = CGFloat((version - 1) * 4 + 23)
    var tileWidth = size.width * DCQRCodePosition.innerPositionTileOriginWidth / originTileCount
    
    let scaleRatio = size.width / originTileCount
    let originToEdge = 6.0 * scaleRatio
    let centerImageLength = 0.2 * size.width
    
    tileWidth += UIScreen.mainScreen().scale
    
    switch self {
      
      case .TopLeft:
        let point = CGPoint(x: floor(DCQRCodePosition.innerPositionTileOriginWidth * scaleRatio), y: DCQRCodePosition.innerPositionTileOriginWidth * scaleRatio).toFloor()
        let rect = CGRect(origin: point, size: CGSize(width: tileWidth, height: tileWidth).toCeil())
        return rect
      case .TopRight:
        let point = CGPoint(x: size.width - originToEdge, y: DCQRCodePosition.innerPositionTileOriginWidth * scaleRatio).toFloor()
        let rect = CGRect(origin: point, size: CGSize(width: tileWidth, height: tileWidth).toCeil())
        return rect
      case .BottomLeft:
        let point = CGPoint(x: DCQRCodePosition.innerPositionTileOriginWidth * scaleRatio, y: size.width - originToEdge).toFloor()
        let rect = CGRect(origin: point, size: CGSize(width: tileWidth, height: tileWidth).toCeil())
        return rect
      case .Center:
        let point = CGPoint(x: size.width/2.0 - centerImageLength/2.0, y: size.width/2.0 - centerImageLength/2.0)
        let rect = CGRect(origin: point, size: CGSize(width: centerImageLength, height: centerImageLength))
        return rect
      default:
        return CGRectZero
    }
    
  }
  
  func outerPositionPath(size:CGSize, version:Int) -> UIBezierPath {
    
    let zonePathWidth = size.width / CGFloat((version - 1) * 4 + 23)
    let positionFrameWidth = zonePathWidth * DCQRCodePosition.outerPositionTileOriginWidth
    
    let topLeftPoint = CGPoint(x: zonePathWidth * 1.5, y: zonePathWidth * 1.5)
    var rect = CGRect(origin: topLeftPoint, size: CGSize(width: positionFrameWidth, height: positionFrameWidth))
    
    switch self {
      case .TopLeft:
        
        let path = rect.rectPath()
        path.lineWidth = zonePathWidth + UIScreen.mainScreen().scale
        path.lineCapStyle = .Square
        
        return path
      
      case .TopRight:
        
        let offset = size.width - positionFrameWidth - topLeftPoint.x * 2
        rect = CGRectOffset(rect, offset, 0)
        let path = rect.rectPath()
        path.lineWidth = zonePathWidth + UIScreen.mainScreen().scale
        path.lineCapStyle = .Square
        
        return path
      case .BottomLeft:
        
        let offset = size.width - positionFrameWidth - topLeftPoint.x * 2
        rect = CGRectOffset(rect, 0, offset)
        let path = rect.rectPath()
        path.lineWidth = zonePathWidth + UIScreen.mainScreen().scale
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

//MARK: Some Convenience Caculation Extension

extension CGPoint {
  
  func toFloor() -> CGPoint {
    
    return CGPoint(x: floor(self.x), y: floor(self.y))
    
  }
  func toCeil() -> CGPoint {
    
    return CGPoint(x: ceil(self.x), y: ceil(self.y))
    
  }
  
}

extension CGSize {
  
  func scale(ratio: CGFloat) -> CGSize {
    
    return CGSize(width: self.width * ratio, height: self.height * ratio)
    
  }
  
  func toFloor() -> CGSize {
    
    return CGSize(width: floor(self.width), height: floor(self.height))
    
  }
  func toCeil() -> CGSize {
    
    return CGSize(width: ceil(self.width), height: ceil(self.height))
    
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



