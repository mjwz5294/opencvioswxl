//
//  RootViewController.m
//  opencvioswxl
//
//  Created by mac on 2018/11/15.
//  Copyright © 2018 mjwz5294. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)onClickCamara:(id)sender {
    UIViewController* vc = [sbRoot instantiateViewControllerWithIdentifier:@"CameraViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
