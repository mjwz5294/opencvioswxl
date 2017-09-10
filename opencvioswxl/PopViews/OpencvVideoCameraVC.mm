//
//  OpencvVideoCameraVC.m
//  opencvioswxl
//
//  Created by longgege on 17/9/10.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "OpencvVideoCameraVC.h"

#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

@interface OpencvVideoCameraVC ()<CvVideoCameraDelegate>{
    void (^callback_)(UIImage*);
    UIImage* img_;
    
}

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UIButton* showToolBtn;


@property (nonatomic, strong) CvVideoCamera* videoCamera;

@end

@implementation OpencvVideoCameraVC

+(void)showOpencvVideoCameraWithParms:(NSDictionary*)parms{
    [[[self alloc] initFromXib] showOpencvVideoCameraWithParms:parms];
}

-(void)showOpencvVideoCameraWithParms:(NSDictionary*)parms{
    Delog(@"showOpencvVideoCameraWithParms");
    callback_ = parms[@"callback"];
    BaseViewController* vc = parms[@"vc"];
    [vc presentViewController:self animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self startOpencvVideoCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startOpencvVideoCamera{
    _videoCamera = [[CvVideoCamera alloc]
                    initWithParentView:_imageView];
    _videoCamera.delegate = self;
    _videoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionFront;
    _videoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPreset640x480;
    _videoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    _videoCamera.defaultFPS = 30;
    
    [_videoCamera start];
}

- (IBAction)showTools:(id)sender {
    [_videoCamera stop];
    if(img_){
        callback_(img_);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- CvVideoCameraDelegate
- (void)processImage:(cv::Mat&)image
{
    // Do some OpenCV processing with the image
//    Delog(@"processImage---%@",MatToUIImage(image));
    img_ = MatToUIImage(image);
    
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
