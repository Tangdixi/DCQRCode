//
//  QRCodeViewController.swift
//  Example(DCQRCode)
//
//  Created by tang dixi on 31/5/2016.
//  Copyright © 2016 Tangdixi. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  
  var qrcode:DCQRCode?
  
  override func viewDidLoad() {
    
    guard let qrcode = self.qrcode else { fatalError() }
    
    let image = qrcode.image()
    
    imageView.image = image
    
  }
  
}