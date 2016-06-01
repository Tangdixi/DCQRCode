//
//  PageViewController.swift
//  Example(DCQRCode)
//
//  Created by tang dixi on 2/6/2016.
//  Copyright © 2016 Tangdixi. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
  
  @IBOutlet weak var frameQRCodeImageView: UIImageView!
  @IBOutlet weak var toastQRCodeImageView: UIImageView!
  @IBOutlet weak var catQRCodeImageView: UIImageView!
  
  override func viewDidLoad() {
    
    let frameQRCode = DCQRCode(info: "https://github.com/Tangdixi/DCQRCode", size: CGSize(width: 180, height: 180))
    frameQRCode.positionInnerStyle = [
      (UIImage(named: "Red")!, DCQRCodePosition.TopRight),
      (UIImage(named: "Red")!, DCQRCodePosition.TopLeft),
      (UIImage(named: "Blue")!, DCQRCodePosition.BottomLeft)
    ]
    frameQRCodeImageView.image = frameQRCode.image()
   
    let toastQRCode = DCQRCode(info: "https://github.com/Tangdixi/DCQRCode", size: CGSize(width: 180, height: 180))
    toastQRCode.bottomColor = UIColor.clearColor()
    toastQRCode.topColor = UIColor.init(red: 219/255, green: 127/255, blue: 60/255, alpha: 0.8)
    toastQRCode.centerImage = UIImage(named: "Avatar")
    toastQRCodeImageView.image = toastQRCode.image()
    
    let catQRCode = DCQRCode(info: "https://github.com/Tangdixi/DCQRCode", size: CGSize(width: 180, height: 180))
    catQRCode.positionInnerStyle = [
      (UIImage(named: "CatLeft")!, DCQRCodePosition.TopLeft),
      (UIImage(named: "CatRight")!, DCQRCodePosition.TopRight),
    ]
    catQRCode.topColor = UIColor.init(red: 90/255, green: 35/255, blue: 7/255, alpha: 1.0)
    catQRCode.bottomColor = UIColor.clearColor()
    catQRCodeImageView.image = catQRCode.image()
    
  }
  
}
