//
//  ViewController.m
//  DCQRCode-Example
//
//  Created by Paul on 7/22/15.
//  Copyright (c) 2015 DC. All rights reserved.
//

#import "DefaultUseController.h"
#import "DCQRCodeScanController.h"

@interface DefaultUseController ()<DCQRCodeScanControllerDelegate>

@end

@implementation DefaultUseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    
}

- (IBAction)presentButtonTouchUpInside:(id)sender {
    
    DCQRCodeScanController *qrcodeScanController = [[DCQRCodeScanController alloc]init];
    
    qrcodeScanController.delegate = self;
    qrcodeScanController.availableCodeTypes = @[
                                                
                                                AVMetadataObjectTypeQRCode,
                                                AVMetadataObjectTypeUPCECode,
                                                AVMetadataObjectTypeEAN8Code,
                                                AVMetadataObjectTypeEAN13Code,
                                                AVMetadataObjectTypeAztecCode,
                                                AVMetadataObjectTypeCode39Code,
                                                AVMetadataObjectTypeCode93Code,
                                                AVMetadataObjectTypePDF417Code,
                                                AVMetadataObjectTypeCode128Code,
                                                AVMetadataObjectTypeCode39Mod43Code,
                                                
                                                ];
    
    [self presentViewController:qrcodeScanController animated:YES completion:nil];
    
}

#pragma mark - DCQRCodeScanControllerDelegate Methods

- (void)dcQRCodeScanController:(DCQRCodeScanController *)dcQRCodeScanController didFinishScanningCodeWithInfo:(NSString *)info {
    
    NSLog(@"Code Info: %@", info);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)dcQRCodeScanControllerDidCancel:(DCQRCodeScanController *)dcQRCodeScanController {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
