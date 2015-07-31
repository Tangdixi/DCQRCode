//
//  DCQRCodeImageView.m
//  
//
//  Created by Paul on 7/30/15.
//
//

#import "DCQRCodeImageView.h"

@interface DCQRCodeImageView ()

@property (copy, nonatomic) NSString *codeInfo;

@end

@implementation DCQRCodeImageView

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self performSelector:@selector(detectQRCodeWithImage:)
               withObject:self.image
               afterDelay:0.618f];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(detectQRCodeWithImage:)
                                               object:self.image];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(detectQRCodeWithImage:)
                                               object:self.image];
    
}

#pragma mark - Scan Image Method

- (void)detectQRCodeWithImage:(UIImage *)image {
    
    // Configure the detector
    //
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{
                                                        CIDetectorAccuracy: @"CIDetectorAccuracyHigh",
                                                        }
                            ];
    
    // Convert the image to CIImage
    //
    CIImage *stillImage = [CIImage imageWithCGImage:image.CGImage];
    
    // Fetch the features in the CIImage
    //
    NSArray *imageFeatures = [detector featuresInImage:stillImage];
    
    for (CIQRCodeFeature *feature in imageFeatures) {
        
        if (feature.messageString && !self.codeInfo) {
            
            _codeInfo = feature.messageString;
            
            if (_delegate && [_delegate respondsToSelector:@selector(dcQRCodeImageView:didFinishLongPressWithCodeInfo:)]) {
                
                [_delegate dcQRCodeImageView:self didFinishLongPressWithCodeInfo:self.codeInfo];
                
                _codeInfo = nil;
                
            }
            
        }
        
    }
    
}

@end
