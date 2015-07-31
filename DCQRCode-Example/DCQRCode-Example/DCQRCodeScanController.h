//
//  DCQRCodeScanConteoller.h
//  
//
//  Created by Paul on 7/22/15.
//
//

@import UIKit;
@import AVFoundation;
@import CoreImage;
@import Foundation;
@import QuartzCore;

typedef NS_ENUM(NSUInteger, kDCQRCodeScanAnimtion) {
    
    kDCQRCodeScanAnimtionBlink = 0,
    kDCQRCodeScanAnimtionUpAndDown = 1,
    kDCQRCodeScanAnimtionLeftAndRight = 2,
    kDCQRCodeScanAnimtionNone = 3,
};

@class DCQRCodeScanController;

@protocol DCQRCodeScanControllerDelegate <NSObject>

- (void)dcQRCodeScanController:(DCQRCodeScanController *)dcQRCodeScanController didFinishScanningCodeWithInfo:(NSString *)info;
- (void)dcQRCodeScanControllerDidCancel:(DCQRCodeScanController *)dcQRCodeScanController;

@end

@interface DCQRCodeScanController : UIViewController

@property (weak, nonatomic) id<DCQRCodeScanControllerDelegate> delegate;

@property (assign, nonatomic) kDCQRCodeScanAnimtion scanAnimationType;
@property (assign, nonatomic, getter = isAllowScanAreaMask) BOOL allowScanAreaMask;

@property (copy, nonatomic) NSArray *availableCodeTypes;

@property (strong, nonatomic) UIImageView *scanAreaView;
@property (strong, nonatomic) UIButton *defaultCancelButton;
@property (strong, nonatomic) UIButton *defaultAlbumButton;

@end
