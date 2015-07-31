//
//  DCQRCodeScanConteoller.m
//  
//
//  Created by Paul on 7/22/15.
//
//

#import "DCQRCodeScanController.h"
#import "UIImage+DCQRCodeExtension.h"

@interface DCQRCodeScanController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (strong, nonatomic) CAShapeLayer *scanAreaMask;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (copy, nonatomic) NSString *codeInfo;
@property (strong, nonatomic) CAShapeLayer *scanLine;

@end

@implementation DCQRCodeScanController

#pragma mark - Controller's Life Circle

- (instancetype)init {
    
    if (self = [super init]) {
    
        NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
        
        [self configureBasicStuff];
        
    }
    return self;
    
}

- (void)viewDidLoad {
    
    NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self configureCaptureSessionWithScanAreaView:self.scanAreaView];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self removeCaptureSession];

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)awakeFromNib {
    
    NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    
    [self configureBasicStuff];
    
}

#pragma mark - 

- (void)configureScanMaskWithScanRect:(CGRect)scanRect {
    
    if (!CGRectGetWidth(scanRect) || !CGRectGetHeight(scanRect)) {
        
        NSLog(@"DCQRCode Error: A scan rect must be a rect");
        
        return ;
    }

    /*
     // Define some points for drawing a mask rect
     //
     //
     //          topLeft                       topRight
     //              _____________________________
     //             |                             |
     //             |                             |
     //             |                             |
     //             |                             |
     //             |                             |
     //             |scanRectTopLeft              |
     //             |     ________________________|  specialCorner
     //             |    |                   |    |
     //             |    |   scanRectTopRight|    |
     //             |    |                   |    |
     //             |    |                   |    |
     //             |    |                   |    |
     //             |    |                   |    |
     //             |    |                   |    |
     //             |    |                   |    |
     //             |    |                   |    |
     //             |    |                   |    |
     //             |     -------------------     |
     //             |scanRectBottomLeft           |
     //             |                             |
     //             |                             |
     //             |                             |
     //             |                             |
     //             |                             |
     //             |                             |
     //              -----------------------------
     //
     //          bottomLeft                     bottomRight
     //
     //
     */
    CGPoint topLeft = {0.0f, 0.0f};
    CGPoint topRight = {self.view.frame.size.width, 0.0f};
    CGPoint bottomRight = {topRight.x, self.view.frame.size.height};
    CGPoint bottomLeft = {topLeft.x, bottomRight.y};
    
    CGPoint specialCorner = {topRight.x, scanRect.origin.y};
    
    CGPoint scanRectTopLeft = {scanRect.origin.x, scanRect.origin.y};
    CGPoint scanRectBottomLeft = {scanRect.origin.x, scanRect.origin.y + scanRect.size.height};
    CGPoint scanRectBottomRight = {scanRect.origin.x + scanRect.size.width, scanRectBottomLeft.y};
    CGPoint scanRectTopRight = {scanRectBottomRight.x , scanRectTopLeft.y};
    
    // Use a shape layer and it will add into the current view's layer, once the user use their customScanMask
    // It will be removed
    //
    _scanAreaMask = ({
        
        UIBezierPath *scanMaskPath = [[UIBezierPath alloc]init];
        
        [scanMaskPath moveToPoint:topLeft];
        [scanMaskPath addLineToPoint:topRight];
        [scanMaskPath addLineToPoint:specialCorner];
        [scanMaskPath addLineToPoint:scanRectTopLeft];
        [scanMaskPath addLineToPoint:scanRectBottomLeft];
        [scanMaskPath addLineToPoint:scanRectBottomRight];
        [scanMaskPath addLineToPoint:scanRectTopRight];
        [scanMaskPath addLineToPoint:specialCorner];
        [scanMaskPath addLineToPoint:bottomRight];
        [scanMaskPath addLineToPoint:bottomLeft];
        [scanMaskPath closePath];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = scanMaskPath.CGPath;
        shapeLayer.fillColor = [[UIColor blackColor]colorWithAlphaComponent:0.618f].CGColor;
        
        shapeLayer.zPosition = -1;
        shapeLayer;
        
    });
    
    [self.view.layer addSublayer:self.scanAreaMask];
    
}

- (void)configureBasicStuff {
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // We restrict the scan area 200 x 200 in the center of the view in default
    //
    _scanAreaView = ({
        
        UIImageView *scanRectView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
        
        scanRectView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"qrcodeArea" ofType:@"png"]];
        scanRectView.contentMode = UIViewContentModeScaleToFill;
        scanRectView.center = self.view.center;
        
        scanRectView;
        
    });
    
    // The cancel button will place on bottom left in the view
    //
    _defaultCancelButton = ({
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, 100, 50);
        
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        cancelButton;
        
    });
    
    // The album button will place on bottom right in the view
    //
    _defaultAlbumButton = ({
        
        UIButton *albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        albumButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 100, [UIScreen mainScreen].bounds.size.height - 50, 100, 50);
        
        [albumButton setTitle:@"Album" forState:UIControlStateNormal];
        [albumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [albumButton addTarget:self action:@selector(albumButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        albumButton;
        
    });
    
    [self.view addSubview:self.scanAreaView];
    [self.view addSubview:self.defaultCancelButton];
    [self.view addSubview:self.defaultAlbumButton];
 
    // Initial the image picker for album
    //
    _imagePickerController = ({
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePickerController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        imagePickerController;
        
    });
    
    // Configure the scan area mask, aka, we limit the scan area inside this rect
    //
    self.allowScanAreaMask = YES;
    self.scanAnimationType = kDCQRCodeScanAnimtionNone;
    
}

#pragma mark - Custom Accessors

- (void)setAllowScanAreaMask:(BOOL)allowScanAreaMask {
    
    if (allowScanAreaMask) {
        
        [self configureScanMaskWithScanRect:self.scanAreaView.frame];
        
        
    }
    else {
        
        [_scanAreaMask removeFromSuperlayer];
        
    }
    
    _allowScanAreaMask = allowScanAreaMask;
}

- (void)setDefaultCancelButton:(UIButton *)cancelButton {
    
    // If the user set the default cancel button to nil, we just simply remove it
    //
    if (! cancelButton) {
        
        [_defaultCancelButton removeFromSuperview];
        
    }
    else {
     
        // 1. Because the default cancel button is always exist after the controller initial, so we remove the default button first
        //
        [_defaultCancelButton removeFromSuperview];
        
        // 2. If the user donn't build his own cancel button from storyboard, we add it into self.view
        //
        if (! cancelButton.superview) {
            
            [self.view addSubview:_defaultCancelButton];
            
        }
        
        // 3. Add the target action to the cancel button
        //
        [cancelButton addTarget:self action:@selector(cancelButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    _defaultCancelButton = cancelButton;
    
}

- (void)setDefaultAlbumButton:(UIButton *)albumButton {
    
    if (! albumButton) {
        
        [_defaultAlbumButton removeFromSuperview];
        
    }
    else {
        
        // 1. Because the default album button is always exist after the controller initial, so we remove the default button first
        //
        [_defaultCancelButton removeFromSuperview];
        
        // 2. If the user donn't build his own album button from storyboard, we add it into self.view
        //
        if (! albumButton.superview) {
            
            [self.view addSubview:_defaultAlbumButton];
            
        }
        
        // 3. Add the target action to the album button
        //
        [albumButton addTarget:self action:@selector(albumButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    _defaultAlbumButton = albumButton;
    
}

- (void)setScanAreaView:(UIImageView *)scanRectView {
    
    if (! scanRectView) {
        
        [_scanAreaView removeFromSuperview];
        [_scanAreaMask removeFromSuperlayer];
        
    }
    else {
     
        // 1. Because the default album button is always exist after the controller initial, so we remove the default button first
        //
        [_scanAreaView removeFromSuperview];
        
        // 2. If the user donn't build his own album button from storyboard, we add it into self.view
        //
        if (! scanRectView.superview) {
            
            [self.view addSubview:_scanAreaView];
            
        }
        
    }
    
    _scanAreaView = scanRectView;
    
}

- (void)setScanAnimationType:(kDCQRCodeScanAnimtion)scanAnimationType {
    
}

#pragma mark - Scan Animation Mathod

- (void)configureScanLineWithScanAnimationType:(kDCQRCodeScanAnimtion)scanAnimationType {
    
    if (!self.scanLine) {
        
        _scanLine = ({
            
            CAShapeLayer *scanLine = [CAShapeLayer layer];
            scanLine;
            
        });
        
    }
    
    switch (scanAnimationType) {
            
        case kDCQRCodeScanAnimtionBlink:
            
            _scanLine.frame = CGRectMake(self.scanAreaView.center.x - self.scanAreaView.frame.size.width * 0.8f,
                                         self.scanAreaView.center.y - 2,
                                         self.scanAreaView.frame.size.width * 0.8f,
                                         4);
            
            break;
        case kDCQRCodeScanAnimtionLeftAndRight:
            
            _scanLine.frame = CGRectMake(self.scanAreaView.center.x - self.scanAreaView.frame.size.width * 0.8f,
                                         self.scanAreaView.center.y - 2,
                                         4,
                                         self.scanAreaView.frame.size.height * 0.8f);
            
            break;
            
        case kDCQRCodeScanAnimtionUpAndDown:
            
            _scanLine.frame = CGRectMake(self.scanAreaView.center.x - self.scanAreaView.frame.size.width * 0.8f,
                                         self.scanAreaView.center.y - 2,
                                         self.scanAreaView.frame.size.width * 0.8f,
                                         4);
            
            break;
            
        default:
            break;
            
    }
    
}

#pragma mark - Scan Image Method

- (void)detectQRCodeWithImage:(UIImage *)image {
    
    // Configure the detector
    //
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{
                                                        CIDetectorAccuracy: @"CIDetectorAccuracyLow",
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
            
            if (_delegate && [_delegate respondsToSelector:@selector(dcQRCodeScanController:didFinishScanningCodeWithInfo:)]) {
                
                [_delegate dcQRCodeScanController:self didFinishScanningCodeWithInfo:self.codeInfo];
                
                return ;
            }
            
        }
        
    }
    
}

#pragma mark - Orientation Methods

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
    
}

- (BOOL)shouldAutorotate {
    
    return NO;
    
}

#pragma mark - IBActions

- (void)cancelButtonTouchUpInside:(UIButton *)button {
    
    if (_delegate && [_delegate respondsToSelector:@selector(dcQRCodeScanControllerDidCancel:)]) {
        
        [_delegate dcQRCodeScanControllerDidCancel:self];
        
    }
    
}

- (void)albumButtonTouchUpInside:(UIButton *)button {
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
    
}

#pragma mark - Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *originImage = info[UIImagePickerControllerOriginalImage];
    UIImage *scaleImage = [originImage fixOrientaionWithMaxiumResolution:640];
    
    [self detectQRCodeWithImage:scaleImage];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Output Metedata Delegate

- (BOOL)hasAvailableCodeType:(NSString *)codeType {
    
    for (NSString *availableType in self.availableCodeTypes) {
        
        if ([codeType isEqualToString:availableType]) {
            
            return YES;
            
        }
        
    }
    
    return NO;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    for (AVMetadataObject *metadataObject in metadataObjects) {
        
        if ([self hasAvailableCodeType:metadataObject.type]) {
            
            AVMetadataMachineReadableCodeObject *decodeObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
            
            if (decodeObject.stringValue && !self.codeInfo) {
                
                _codeInfo = decodeObject.stringValue;
                
                NSLog(@"DCQRCode: Code info detect: %@", self.codeInfo);
                
                // Configure the DCQRCodeScanner Delegate
                //
                if (_delegate && [_delegate respondsToSelector:@selector(dcQRCodeScanController:didFinishScanningCodeWithInfo:)]) {
                    
                    [_delegate dcQRCodeScanController:self didFinishScanningCodeWithInfo:self.codeInfo];
                    
                }
                
            }
            
        }
        
    }
    
}

#pragma mark - Configure AVCapture Session

- (void)configureCaptureSessionWithScanAreaView:(UIView *)scanArea {
    
    if (!self.captureSession) {
        
        // Initialization for capture session
        //
        _captureSession = [[AVCaptureSession alloc]init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        // Configure the capture session
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 1. Fetch a device
            //
            AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            
            // 2. Make it as an input device
            //
            NSError *captureDeviceInputError = nil;
            
            AVCaptureDeviceInput *captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&captureDeviceInputError];
            
            // 3. Add the input device to the capture session
            //
            if ([self.captureSession canAddInput:captureDeviceInput]) {
                
                [_captureSession addInput:captureDeviceInput];
                
            }
            
            // 4. Configure the output data
            //
            AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc]init];
            
            [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            
            if ([self.captureSession canAddOutput:captureMetadataOutput]) {
                [_captureSession addOutput:captureMetadataOutput];
            }
            
            // Only if we add the output device into the capture session
            //
            captureMetadataOutput.metadataObjectTypes = self.availableCodeTypes;
            
            // 5. Configure the capture preview layer
            //
            _captureVideoPreviewLayer = ({
            
                AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
                captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                captureVideoPreviewLayer.bounds = self.view.frame;
                captureVideoPreviewLayer.position = self.view.center;
                captureVideoPreviewLayer.zPosition = -2;
                captureVideoPreviewLayer;
            
            });
            [self.view.layer addSublayer:_captureVideoPreviewLayer];
            
            // 6. Start the capture session
            //
            if (!self.captureSession.running) {
                
                [_captureSession startRunning];
                
            }
            
            if (self.scanAreaView) {
                
                captureMetadataOutput.rectOfInterest = [self.captureVideoPreviewLayer metadataOutputRectOfInterestForRect:self.scanAreaView.frame];
                
            }
            
        });
        
    }
    
}

- (void)removeCaptureSession {
    
    if (self.captureSession.running) {

        [_captureSession stopRunning];
        
        [_captureVideoPreviewLayer removeFromSuperlayer];
        _captureSession = nil;
        _codeInfo = nil;
        
    }
    
}

@end
