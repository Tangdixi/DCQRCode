//
//  ViewController.swift
//  Example(DCQRCode)
//
//  Created by tang dixi on 30/5/2016.
//  Copyright © 2016 Tangdixi. All rights reserved.
//

import UIKit

let dataSource = ["Default", "Outer Position Color", "Inner Position Color", "Outer Position Image", "Inner Position Color", "Center Image", "Bottom Color", "Top Color", "Top Image"]

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

extension ViewController {
  
  func qrcodeConfiguration(indexPath:NSIndexPath) -> DCQRCode {
    
    let qrcode = DCQRCode(info: "https://github.com/Tangdixi/DCQRCode", size: CGSize(width: 300, height: 300))
    
    switch indexPath.row {
    case 0:
      return qrcode
    case 1:
      qrcode.positionOuterColor = UIColor.brownColor()
      return qrcode
    case 2:
      qrcode.positionInnerColor = UIColor.redColor()
      return qrcode
    case 3:
      qrcode.positionStyle = [
        (UIImage(named: "OuterPosition")!, DCQRCodePosition.TopRight),
        (UIImage(named: "OuterPosition")!, DCQRCodePosition.TopLeft),
        (UIImage(named: "OuterPosition")!, DCQRCodePosition.BottomLeft)
      ]
      return qrcode
    case 4:
      
      qrcode.positionOuterColor = UIColor.brownColor()
      qrcode.positionInnerStyle = [
        (UIImage(named: "Polygon")!, DCQRCodePosition.TopLeft),
        (UIImage(named: "Polygon")!, DCQRCodePosition.TopRight),
        (UIImage(named: "Polygon")!, DCQRCodePosition.BottomLeft)
      ]
      
      return qrcode
    case 5:
      qrcode.centerImage = UIImage(named: "Avatar")
      return qrcode
    case 6:
      qrcode.bottomColor = UIColor.yellowColor()
      return qrcode
    case 7:
      qrcode.topColor = UIColor.brownColor()
      return qrcode
    case 8:
      qrcode.topImage = UIImage(named: "Top")
      return qrcode
    default:
      return qrcode
    }
    
  }
  
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return dataSource.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
    cell.textLabel?.text = dataSource[indexPath.row]
    
    return cell
    
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    guard let controller = self.storyboard?.instantiateViewControllerWithIdentifier("qrcodeViewController") as? QRCodeViewController else { fatalError() }
    
    controller.qrcode = self.qrcodeConfiguration(indexPath)
    
    self.navigationController?.pushViewController(controller, animated: true)
    
  }
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    
    return UIView(frame: CGRectZero)
    
  }
  
  
  
}