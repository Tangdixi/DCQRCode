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
  @IBOutlet weak var leafQRCodeImageView: UIImageView!
  
  override func viewDidLoad() {
    
    let frameQRCode = DCQRCode(info: "https://github.com/Tangdixi/DCQRCode", size: CGSize(width: 180, height: 180))
    frameQRCode.positionInnerStyle = [
      (UIImage(named: "Red")!, DCQRCodePosition.topRight),
      (UIImage(named: "Red")!, DCQRCodePosition.topLeft),
      (UIImage(named: "Blue")!, DCQRCodePosition.bottomLeft)
    ]
    frameQRCodeImageView.image = frameQRCode.image()
   
    let toastQRCode = DCQRCode(info: "https://github.com/Tangdixi/DCQRCode", size: CGSize(width: 180, height: 180))
    toastQRCode.backgroundColor = UIColor.clear
    toastQRCode.color = UIColor.init(red: 219/255, green: 127/255, blue: 60/255, alpha: 0.8)
    toastQRCode.centerImage = UIImage(named: "Avatar")
    toastQRCodeImageView.image = toastQRCode.image()
    
    let catQRCode = DCQRCode(info: "https://github.com/Tangdixi/DCQRCode", size: CGSize(width: 180, height: 180))
    catQRCode.positionInnerStyle = [
      (UIImage(named: "CatLeft")!, DCQRCodePosition.topLeft),
      (UIImage(named: "CatRight")!, DCQRCodePosition.topRight),
    ]
    catQRCode.color = UIColor.init(red: 90/255, green: 35/255, blue: 7/255, alpha: 1.0)
    catQRCode.backgroundColor = UIColor.clear
    catQRCode.centerImage = UIImage(named: "Avatar")
    catQRCode.removeQuietZone = true
    catQRCodeImageView.image = catQRCode.image()
    
    let leafQRCode = DCQRCode(info: "https://github.com/Tangdixi/DCQRCode", size: CGSize(width: 180, height: 180))
    leafQRCode.backgroundColor = UIColor.clear
    leafQRCode.removeQuietZone = true
    leafQRCode.color = UIColor.init(white: 0, alpha: 0.6)
    leafQRCode.centerImage = UIImage(named: "Avatar")
    leafQRCodeImageView.image = leafQRCode.image()
    
  }
  
}
