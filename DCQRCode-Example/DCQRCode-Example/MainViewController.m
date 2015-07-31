//
//  MainViewController.m
//  
//
//  Created by Paul on 8/1/15.
//
//

#import "MainViewController.h"
#import "LongPressQRCodeImageViewController.h"
#import "DCQRCodeScanController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)defaultUseButtonTouchUpInside:(id)sender {
    
    
    
}

- (IBAction)recognizeQRCodeImage:(id)sender {

    LongPressQRCodeImageViewController *longPressQRCodeImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"longPressQRCodeImageView"];
    
    [self.navigationController pushViewController:longPressQRCodeImageViewController animated:YES];
}

@end
