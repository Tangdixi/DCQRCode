//
//  DCQRCodeScanner.m
//  
//
//  Created by Paul on 6/7/15.
//
//

#import "DCQRCodeScanner.h"

@interface DCQRCodeScanner ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureMetadataOutput *captureMetadataOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (copy, nonatomic) NSString *decodeString;

@end

@implementation DCQRCodeScanner

#pragma mark - Controller's Life Circle

- (void)viewDidLoad {
    
    [super viewDidLoad];

    
    [self configureControlsLayout];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self configureCaptureSession];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self removeCaptureSession];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Configure UI Stuff

- (void)configureControlsLayout {
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, 100, 50);
    
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_cancelButton addTarget:self action:@selector(dcQRCodeScannerCancelButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_cancelButton];
    
}

#pragma mark - Configure AVCapture Session

- (void)configureCaptureSession {
    
    // Initialization for capture session
    //
    _captureSession = [[AVCaptureSession alloc]init];
    _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    
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
        _captureMetadataOutput = [[AVCaptureMetadataOutput alloc]init];
        
        [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        if ([self.captureSession canAddOutput:_captureMetadataOutput]) {
            [_captureSession addOutput:_captureMetadataOutput];
        }
        
        // Only if we add the output device into the capture session
        //
        _captureMetadataOutput.metadataObjectTypes = self.availableCodeTypes;

        // 5. Configure the capture preview layer
        //
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _captureVideoPreviewLayer.bounds = self.view.bounds;
        _captureVideoPreviewLayer.position = self.view.center;
        
        [self.view.layer addSublayer:_captureVideoPreviewLayer];
        
        // 6. Start the capture session
        //
        [_captureSession startRunning];
        
        [self.view bringSubviewToFront:self.cancelButton];
        
    });
    
}

- (void)removeCaptureSession {
    
    [_captureSession stopRunning];
    
    _captureSession = nil;
    _decodeString = nil;
    
}

- (BOOL)hasAvailableCodeType:(NSString *)codeType {
    
    for (NSString *availableType in self.availableCodeTypes) {
        
        if ([codeType isEqualToString:availableType]) {
            
            return YES;
            
        }
        
    }
    
    return NO;
}

#pragma mark - Output Metedata Delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    for (AVMetadataObject *metadataObject in metadataObjects) {
        
        if ([self hasAvailableCodeType:metadataObject.type]) {
            
            AVMetadataMachineReadableCodeObject *decodeObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
            
            if (decodeObject.stringValue && !self.decodeString) {
                
                _decodeString = decodeObject.stringValue;
                
                // Configure the DCQRCodeScanner Delegate
                //
                if ([_delegate respondsToSelector:@selector(dcQRCodeScanner:didFinishDetetiveQRCodeInfo:)]) {
                    
                    [_delegate dcQRCodeScanner:self didFinishDetetiveQRCodeInfo:self.decodeString];
                    
                }
                
            }
            
        }
        
    }
    
}

#pragma mark - Control's Action

- (void)dcQRCodeScannerCancelButtonTouchUpInside:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(dcQRCodeScannerDidCancel:)]) {
        
        [_delegate dcQRCodeScannerDidCancel:self];
        
    }
    
}

@end
