//
//  CameraViewController.m
//  opencvioswxl
//
//  Created by mac on 2018/11/15.
//  Copyright © 2018 mjwz5294. All rights reserved.
//

#import "CameraViewController.h"

#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

#import "RetroFilter.hpp"

@interface CameraViewController ()<CvPhotoCameraDelegate>{
    RetroFilter::Parameters params;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) CvPhotoCamera* photoCamera;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self openCamera];
}
- (IBAction)onClickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickMode:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickRatio:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickSpark:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickStyle:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickButify:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 1、将imageView赋给_photoCamera后，我的imageView会向下拉长60个点，估计是opencv为相机底部的工具条预留的位置；
 2、我点击拍照后，照片的大小并不是imageView中展示的大小。不过这里尺寸，可以通过defaultAVCaptureSessionPreset参数设置。
 */

-(void)openCamera{
    // Initialize camera
    _photoCamera = [[CvPhotoCamera alloc]
                    initWithParentView:_imageView];
    _photoCamera.delegate = self;
    _photoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionFront;
    _photoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPresetPhoto;
    _photoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    
    [_photoCamera start];
}

#pragma mark- CvPhotoCameraDelegate
- (void)photoCamera:(CvPhotoCamera*)camera
      capturedImage:(UIImage *)image;
{
    [camera stop];
    [_imageView setImage:image];
}

- (void)photoCameraCancel:(CvPhotoCamera*)camera{
    Delog(@"photoCameraCancel");
}

@end
