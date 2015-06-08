//
//  DCQRCodeScanner.h
//  
//
//  Created by Paul on 6/7/15.
//
//

@import UIKit;
@import AVFoundation;

@class DCQRCodeScanner;

@protocol DCQRCodeScannerDelegate <NSObject>

- (void)dcQRCodeScanner:(DCQRCodeScanner *)scanner didFinishDetetiveQRCodeInfo:(NSString *)codeInfo;

- (void)dcQRCodeScannerDidCancel:(DCQRCodeScanner *)scanner;

@end

@interface DCQRCodeScanner : UIViewController

@property (weak, nonatomic) id<DCQRCodeScannerDelegate> delegate;

@property (copy, nonatomic) NSArray *availableCodeTypes;

@property (strong, nonatomic) UIView *customMaskView;

@property (strong, nonatomic) UIButton *cancelButton;

@end
