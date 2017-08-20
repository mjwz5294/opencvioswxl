//
//  ViewController.m
//  opencvioswxl
//
//  Created by wxl on 2017/8/19.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "ViewController.h"
#import "opencviosinterface.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    cv::Mat cvimg = [[[opencviosinterface alloc] init] cvMatFromUIImage:[UIImage imageNamed:@"cat"]];
    cv::Mat cvGrayimg = [[[opencviosinterface alloc] init] cvMatGrayFromUIImage:[UIImage imageNamed:@"cat"]];
    
    cv::cvtColor(cvimg, cvGrayimg, CV_BGR2GRAY);
    
    UIImageView* imgview = [[UIImageView alloc] initWithImage:[[[opencviosinterface alloc] init] UIImageFromCVMat:cvimg]];
    imgview.frame.origin = CGPointMake(10, 100);
    
    UIImageView* imggrayview = [[UIImageView alloc] initWithImage:[[[opencviosinterface alloc] init] UIImageFromCVMat:cvGrayimg]];
    imggrayview.frame.origin = CGPointMake(10, 200);
    
    [self.view addSubview:imgview];
    [self.view addSubview:imggrayview];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
