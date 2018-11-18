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

@interface CameraViewController ()<CvPhotoCameraDelegate>{
    
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *imgSaveView;

@property (nonatomic,assign) AVCaptureDevicePosition deviceDirection;
@property (nonatomic,assign) AVCaptureVideoOrientation videoOrientation;

@property (nonatomic, strong) CvPhotoCamera* photoCamera;
@property (nonatomic, strong) CvVideoCamera* videoCamera;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _deviceDirection = AVCaptureDevicePositionFront;
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
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"拍摄方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // 创建action，这里action1只是方便编写，以后再编程的过程中还是以命名规范为主
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"表情包" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera];
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //把action添加到actionSheet里
    [actionSheet addAction:action1];
    [actionSheet addAction:action2];
    [actionSheet addAction:action3];
    [actionSheet addAction:action4];
    
    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];
    
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
    
    /*
     似乎可以同时开启两个，关闭一个后，另一个还会起作用，导致无法预览。所以开启前，先关掉
     每次开启，会有一瞬间的黑屏，应该是摄像头开启时候的反应，不知道怎么解决。
     参照天天P图，他们在拍完照之后，直接保存，只是多了一个预览的入口，这样也就没有了黑屏，这里先不折腾了
     */
    if(_photoCamera && _photoCamera.running){
        [_photoCamera stop];
    }
    [_imageView setImage:nil];//切换镜头后拍照，有一瞬间是显示的上一张照片
    _photoCamera = [[CvPhotoCamera alloc] initWithParentView:_imageView];
    _photoCamera.delegate = self;
    _photoCamera.defaultAVCaptureDevicePosition = _deviceDirection;
    _photoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetPhoto;
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
//保存照片的三种方式：https://www.jianshu.com/p/bf20733ba19b
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
