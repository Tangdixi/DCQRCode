//
//  LongPressQRCodeImageViewController.m
//  
//
//  Created by Paul on 8/1/15.
//
//

#import "LongPressQRCodeImageViewController.h"
#import "DCQRCodeImageView.h"

@interface LongPressQRCodeImageViewController ()<DCQRCodeImageViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet DCQRCodeImageView *dcQRCodeImageView;
@end

@implementation LongPressQRCodeImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _dcQRCodeImageView.delegate = self;
    
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

- (void)dcQRCodeImageView:(DCQRCodeImageView *)dcQRCodeImageView didFinishLongPressWithCodeInfo:(NSString *)codeInfo {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:codeInfo
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:@"QRCode"
                                                   otherButtonTitles:nil];
    
    [actionSheet showInView:self.view];
    
}

@end
