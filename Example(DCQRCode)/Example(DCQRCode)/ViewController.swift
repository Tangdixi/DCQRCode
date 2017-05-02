//
//  ViewController.swift
//  Example(DCQRCode)
//
//  Created by tang dixi on 30/5/2016.
//  Copyright © 2016 Tangdixi. All rights reserved.
//

import UIKit

let dataSource = ["Default", "Outer Position Color", "Inner Position Color", "Outer Position Image", "Inner Position Color", "Center Image", "Bottom Color", "Top Color", "Top Image", "Examples"]

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
  
  func qrcodeConfiguration(_ indexPath:IndexPath) -> DCQRCode {
    
    let qrcode = DCQRCode(info: "https://github.com/Tangdixi/DCQRCode", size: CGSize(width: 300, height: 300))
    
    switch indexPath.row {
    case 0:
      return qrcode
    case 1:
      qrcode.positionOuterColor = UIColor.brown
      return qrcode
    case 2:
      qrcode.positionInnerColor = UIColor.red
      return qrcode
    case 3:
      qrcode.positionStyle = [
        (UIImage(named: "OuterPosition")!, DCQRCodePosition.topRight),
        (UIImage(named: "OuterPosition")!, DCQRCodePosition.topLeft),
        (UIImage(named: "OuterPosition")!, DCQRCodePosition.bottomLeft)
      ]
      qrcode.color = UIColor.init(red: 100/255, green: 145/255, blue: 193/255, alpha: 1)
      return qrcode
    case 4:
      
      qrcode.positionOuterColor = UIColor.brown
      qrcode.positionInnerStyle = [
        (UIImage(named: "Polygon")!, DCQRCodePosition.topLeft),
        (UIImage(named: "Polygon")!, DCQRCodePosition.topRight),
        (UIImage(named: "Polygon")!, DCQRCodePosition.bottomLeft)
      ]
      
      return qrcode
    case 5:
      qrcode.centerImage = UIImage(named: "Avatar")
      return qrcode
    case 6:
      qrcode.backgroundColor = UIColor.yellow
      return qrcode
    case 7:
      qrcode.color = UIColor.brown
      return qrcode
    case 8:
      qrcode.maskImage = UIImage(named: "Top")
      return qrcode
    default:
      return qrcode
    }
    
  }
  
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    cell.textLabel?.text = dataSource[indexPath.row]
    
    return cell
    
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    /* Enter Example */
    if indexPath.row == dataSource.count - 1 {
      
      guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "pageViewController") else { fatalError() }
      self.navigationController?.pushViewController(controller, animated: true)
      
      return
    }
    
    guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "qrcodeViewController") as? QRCodeViewController else { fatalError() }
    
    controller.qrcode = self.qrcodeConfiguration(indexPath)
    
    self.navigationController?.pushViewController(controller, animated: true)
    
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    
    return UIView(frame: CGRect.zero)
    
  }
  
}
