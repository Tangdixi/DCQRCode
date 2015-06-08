//
//  DCQRCodeGenerator.h
//  
//
//  Created by Paul on 6/7/15.
//
//

@import UIKit;
@import CoreImage;
@import Foundation;

@interface DCQRCodeGenerator : NSObject

+ (UIImage *)generateQRCodeWithInfo:(NSString *)info;

@end
