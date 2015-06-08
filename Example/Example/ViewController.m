//
//  ViewController.m
//  Example
//
//  Created by Paul on 6/6/15.
//  Copyright (c) 2015 DC. All rights reserved.
//

#import "ViewController.h"

#import "DCQRCodeGenerator.h"
#import "DCQRCodeScanner.h"

@interface ViewController ()<DCQRCodeScannerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) DCQRCodeScanner *dcQRCodeScanner;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configureQRCodeScanner];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureQRCodeScanner {
    
    _dcQRCodeScanner = [[DCQRCodeScanner alloc]init];
    _dcQRCodeScanner.availableCodeTypes = @[
                                           AVMetadataObjectTypeUPCECode,
                                           AVMetadataObjectTypeCode39Code,
                                           AVMetadataObjectTypeCode39Mod43Code,
                                           AVMetadataObjectTypeEAN13Code,
                                           AVMetadataObjectTypeEAN8Code,
                                           AVMetadataObjectTypeCode93Code,
                                           AVMetadataObjectTypeCode128Code,
                                           AVMetadataObjectTypePDF417Code,
                                           AVMetadataObjectTypeQRCode,
                                           AVMetadataObjectTypeAztecCode];
    _dcQRCodeScanner.delegate = self;
    
}

#pragma mark - DCQRCodeSanner Delegate

- (void)dcQRCodeScanner:(DCQRCodeScanner *)scanner didFinishDetetiveQRCodeInfo:(NSString *)codeInfo {
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"QRCode Scan!" message:[NSString stringWithFormat:@" Info: %@", codeInfo] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alertView show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)dcQRCodeScannerDidCancel:(DCQRCodeScanner *)scanner {
    
    [self dismissViewControllerAnimated:YES completion:nil];    
    
}

#pragma IBActions

- (IBAction)showQRCodeScanner:(id)sender {
    
    [self presentViewController:self.dcQRCodeScanner animated:YES completion:nil];
    
}

- (IBAction)generateQRCode:(id)sender {
    
    _imageView.image = [DCQRCodeGenerator generateQRCodeWithInfo:self.textField.text];
    
    [_textField resignFirstResponder];
    
}


@end
