//
//  DCQRCodeImageView.h
//  
//
//  Created by Paul on 7/30/15.
//
//

@import UIKit;

@class DCQRCodeImageView;

@protocol DCQRCodeImageViewDelegate <NSObject>

- (void)dcQRCodeImageView:(DCQRCodeImageView *)dcQRCodeImageView didFinishLongPressWithCodeInfo:(NSString *)codeInfo;

@end

@interface DCQRCodeImageView : UIImageView

@property (weak, nonatomic) id<DCQRCodeImageViewDelegate> delegate;

@end
