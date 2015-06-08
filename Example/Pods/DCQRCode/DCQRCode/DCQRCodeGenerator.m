//
//  DCQRCodeGenerator.m
//  
//
//  Created by Paul on 6/7/15.
//
//

#import "DCQRCodeGenerator.h"

@implementation DCQRCodeGenerator

+ (UIImage *)generateQRCodeWithInfo:(NSString *)info {
    
    NSData *qrCodeInfoData = [info dataUsingEncoding:NSUTF8StringEncoding];
    
    // Configure filter
    //
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setValue:qrCodeInfoData forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *generateImage = [filter.outputImage imageByApplyingTransform:CGAffineTransformMakeScale(5.0f, 5.0f)];
    
    return [UIImage imageWithCIImage:generateImage];
    
}

@end
