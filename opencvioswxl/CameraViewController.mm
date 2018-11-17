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

#import <AVFoundation/AVCaptureDevice.h>

#import "RetroFilter.hpp"

@interface CameraViewController ()<CvPhotoCameraDelegate>{
    RetroFilter::Parameters params;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) CvPhotoCamera* photoCamera;

@property (nonatomic,assign) AVCaptureDevicePosition deviceDirection;
@property (nonatomic,assign) AVCaptureSessionPreset sessionPreset;
@property (nonatomic,assign) AVCaptureVideoOrientation videoOrientation;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _deviceDirection = AVCaptureDevicePositionFront;
    _sessionPreset = AVCaptureSessionPresetPhoto;
    _videoOrientation = AVCaptureVideoOrientationPortrait;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self openCamera];
}
- (IBAction)onClickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickMode:(id)sender {
    if(_deviceDirection == AVCaptureDevicePositionFront){//自拍
        _deviceDirection = AVCaptureDevicePositionBack;
    }else{                                               //正拍
        _deviceDirection = AVCaptureDevicePositionFront;
    }
    [self openCamera];
}
- (IBAction)onClickPhoto:(id)sender {
    [_photoCamera takePicture];
}
- (IBAction)onClickOrientation:(id)sender {
    switch (_videoOrientation) {
        case AVCaptureVideoOrientationPortrait:
            _videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            _videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            _videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            _videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        default:
            _videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    [self openCamera];
}
- (IBAction)onClickStyle:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickButify:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 1、摄像头帧是方形的，如果_imageView是长方形的，会导致图片变形，设置ImageView的content mode就可以解决
 2、切换摄像头方向后，需要重启才能生效，直接使用switchCameras则会崩溃
 3、自拍实现镜像模式：就是把拍出来的图片作镜像处理，再赋值给_imageView。详见代理方法。
 */

-(void)openCamera{
    // Initialize camera
    if(_photoCamera && _photoCamera.running){
        [_photoCamera stop];
    }
    _photoCamera = [[CvPhotoCamera alloc] initWithParentView:_imageView];
    _photoCamera.delegate = self;
    _photoCamera.defaultAVCaptureDevicePosition = _deviceDirection;
    _photoCamera.defaultAVCaptureSessionPreset = _sessionPreset;
    _photoCamera.defaultAVCaptureVideoOrientation = _videoOrientation;
    [_photoCamera start];
}

#pragma mark- CvPhotoCameraDelegate
- (void)photoCamera:(CvPhotoCamera*)camera
      capturedImage:(UIImage *)image;
{
    [camera stop];
    if(_deviceDirection == AVCaptureDevicePositionFront){
        image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
    }
    [_imageView setImage:image];
}

- (void)photoCameraCancel:(CvPhotoCamera*)camera{
    Delog(@"photoCameraCancel");
}

@end
