#DCQRCode

![ColorFrame](https://raw.githubusercontent.com/Tangdixi/DCQRCode/2.0/Assets/ColorFrame.png)
![Cat](https://raw.githubusercontent.com/Tangdixi/DCQRCode/2.0/Assets/Cat.png)
![ColorFrame](https://raw.githubusercontent.com/Tangdixi/DCQRCode/2.0/Assets/Frame.png)

**DCQRCode** is a QRCode generate library implement by [*CoreImage*](https://developer.apple.com/library/ios/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html) and [*CoreGraphics*](https://developer.apple.com/library/ios/documentation/CoreGraphics/Reference/CoreGraphics_Framework/). **DCQRCode** allow you to change the QRCode's *color* or *Position Style*, etc. The inspirarion come from the QRCode feature in [WeChat](http://www.wechat.com/en/).  

## How To Get Started  
- Download [**DCQRCode**](https://codeload.github.com/Tangdixi/DCPathButton/zip/master)
- Clone **DCQRCode**
```bash
git clone git@github.com:Tangdixi/DCPathButton.git
``` 

##Installation

Drag the **Source** into your project.  
Well, it is strongly recommended that you install via [**CocoaPods**](https://cocoapods.org) or [**Carthage**](https://github.com/Carthage/Carthage).

##Usage
1. Create a DCQRCode  
```swift
let qrcode = DCQRCode(info: "https://github.com/Tangdixi/DCQRCode", size: CGSize(width: 300, height: 300))
```
2. Configure the qrcode
```swift
qrcode.backgroundColor = UIColor.yellowColor()
qrcode.color = UIColor.brownColor()
```
3. Output the qrcode image 
```Swift
let qrcodeImage = qrcode.image()
```  

More detail just head to the **Example Project**

##Documentation
**Documentation** is added into the source file.  
You can use `option` and click the keyword in **Xcode**   

##Bug, Suggestions

All you need is open an [issue](https://github.com/Tangdixi/DCQRCode/issues), I'll answer it ASAP !

##TODO
*  Allow reverse position color
*  Generate pattern images as the QRCode mask
*  Change QRCode style, like round rect

##License

**DCQRCode** is available under the MIT license. See the LICENSE file for more info.

