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
@property (weak, nonatomic) IBOutlet UIView *imgSaveView;

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
    [_imageView setImage:nil];//切换镜头后拍照，有一瞬间是显示的上一张照片
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
    if(_deviceDirection == AVCaptureDevicePositionFront){
        image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
    }
    [_imageView setImage:image];
    /*
     对于常用的相机，我们希望拍完之后，立即保存，然后可以继续拍，因此相机不会关。
     但对于一个美图工具，一般拍完一张照片后，我们希望先看看满不满意再决定是否保存，做完这个决定之后，再开启相机继续拍。
     */
    [camera stop];
    [_imgSaveView setHidden:NO];
}

- (void)photoCameraCancel:(CvPhotoCamera*)camera{
    Delog(@"photoCameraCancel");
}
- (IBAction)saveImgCancle:(id)sender {
    [_imgSaveView setHidden:YES];
    [self openCamera];
}
- (IBAction)saveImgOK:(id)sender {
    [_imgSaveView setHidden:YES];
    UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        Delog(@"%@",error.localizedDescription);
    }else{
        [self openCamera];
    }
}

@end
