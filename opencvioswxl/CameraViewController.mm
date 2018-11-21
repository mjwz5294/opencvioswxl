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


typedef NS_ENUM(NSInteger, CamType) {
    CamTypePhoto = 1,
    CamTypeVideo = 2,
    CamTypeEmoji = 3,
};

@interface CameraViewController ()<CvPhotoCameraDelegate,CvVideoCameraDelegate>{
    
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *imgSaveView;
@property (weak, nonatomic) IBOutlet UIButton *btnTake;

@property (nonatomic,assign) AVCaptureDevicePosition deviceDirection;
@property (nonatomic,assign) AVCaptureVideoOrientation videoOrientation;
@property (nonatomic,assign) CamType camType;

@property (nonatomic, strong) CvPhotoCamera* photoCamera;
@property (nonatomic, strong) CvVideoCamera* videoCamera;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initCommonSetting];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self openCamera];
}
- (IBAction)onClickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)initCommonSetting{
    _deviceDirection = AVCaptureDevicePositionFront;
    _videoOrientation = AVCaptureVideoOrientationPortrait;
    _camType = CamTypePhoto;
}
-(void)initEmojiSetting{
//    _camType = CamTypeEmoji;
    [self initPhotoSetting];
}

#pragma mark- 设置选项
- (IBAction)onClickMode:(id)sender {
    if(_deviceDirection == AVCaptureDevicePositionFront){//自拍
        _deviceDirection = AVCaptureDevicePositionBack;
    }else{                                               //正拍
        _deviceDirection = AVCaptureDevicePositionFront;
    }
    [self refreshSetting];
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
    [self refreshSetting];
}
-(void)refreshSetting{
    switch (_camType) {
        case CamTypePhoto:
            [self openCamera];
            break;
        case CamTypeVideo:
            [self openVideoCamera];
            break;
        case CamTypeEmoji:
            [self openCamera];
            break;
        default:
            [self openCamera];
            break;
    }
}
- (IBAction)onClickStyle:(id)sender {
    
    if(_videoCamera && _videoCamera.running){
        [self stopVideo];
    }
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"拍摄方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // 创建action，这里action1只是方便编写，以后再编程的过程中还是以命名规范为主
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self initPhotoSetting];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self initVideoSetting];
    }];
//    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"表情包" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self initEmojiSetting];
//    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //把action添加到actionSheet里
    [actionSheet addAction:action1];
    [actionSheet addAction:action2];
//    [actionSheet addAction:action3];
    [actionSheet addAction:action4];
    
    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}
- (IBAction)onClickButify:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- 拍照片
-(void)initPhotoSetting{
    //关闭其它的
    if (_videoCamera && _videoCamera.running) {
        [self stopVideo];
    }
    
    _camType = CamTypePhoto;
    [_btnTake setTitle:@"拍摄" forState:UIControlStateNormal];
    [self openCamera];
}
/*
 1、摄像头帧是方形的，如果_imageView是长方形的，会导致图片变形，设置ImageView的content mode就可以解决
 2、切换摄像头方向后，需要重启才能生效，直接使用switchCameras则会崩溃
 3、自拍实现镜像模式：就是把拍出来的图片作镜像处理，再赋值给_imageView。详见代理方法。
 */
-(void)openCamera{
    if (_camType != CamTypePhoto) {
        return;
    }
    Delog(@"openCamera-----------");
    /*
     似乎可以同时开启两个，关闭一个后，另一个还会起作用，导致无法预览。所以开启前，先关掉
     每次开启，会有一瞬间的黑屏，应该是摄像头开启时候的反应，不知道怎么解决。
     参照天天P图，他们在拍完照之后，直接保存，只是多了一个预览的入口，这样也就没有了黑屏，这里先不折腾了
     */
    if(_photoCamera && _photoCamera.running){
        [_photoCamera stop];
    }
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    [_imageView setImage:nil];//切换镜头后拍照，有一瞬间是显示的上一张照片
    _photoCamera = [[CvPhotoCamera alloc] initWithParentView:_imageView];
    _photoCamera.delegate = self;
    _photoCamera.defaultAVCaptureDevicePosition = _deviceDirection;
    _photoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetPhoto;
    _photoCamera.defaultAVCaptureVideoOrientation = _videoOrientation;
    [_photoCamera start];
}
- (IBAction)onClickPhoto:(id)sender {
    if (_camType != CamTypePhoto) {
        return;
    }
    [_photoCamera takePicture];
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

#pragma mark- 拍视频
-(void)initVideoSetting{
    //这里不能关闭_photoCamera，否则图片没有内容，而且录制过程中，_photoCamera就应该跑着
//        if (_photoCamera && _photoCamera.running) {
//            [_photoCamera stop];
//        }
    
    _camType = CamTypeVideo;
    [_btnTake setTitle:@"录制" forState:UIControlStateNormal];
}
-(void)openVideoCamera{
    if (_camType != CamTypeVideo) {
        return;
    }
    Delog(@"openVideoCamera-----------");
    if(_videoCamera && _videoCamera.running){
        [_videoCamera stop];
    }
    [_imageView setContentMode:UIViewContentModeCenter];
    //_imageView无论怎么配置，都只是影响拍摄时自己看到的样子，与拍摄结果无关
//    [_imageView setFrame:CGRectMake(0, 0, 480, 480)];
//    [_imageView setCenter:self.view.center];
    _videoCamera = [[CvVideoCamera alloc] initWithParentView:_imageView];
    _videoCamera.delegate = self;
    //真正影响拍摄结果的，还是_videoCamera的参数配置
    _videoCamera.defaultAVCaptureDevicePosition = _deviceDirection;
    _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    //必需是左或者右，否则视频帧变形，不知是个什么bug，看来opencv只能拿来处理图片，它提供的拍照/视频工具不行
    _videoCamera.defaultFPS = 30;
    _videoCamera.recordVideo = YES;//没这句就没法保存
    [_videoCamera start];
    
    [_btnTake.titleLabel setText:@"录制中"];
    [_btnTake setTitle:@"录制中" forState:UIControlStateNormal];
    
}
- (IBAction)takeVideo:(id)sender {
    if (_camType != CamTypeVideo) {
        return;
    }
    if(_videoCamera.running){
        [self saveVideo];
    }else{
        [self openVideoCamera];
    }
}
-(void)stopVideo{
    if(_videoCamera && _videoCamera.running){
        [_videoCamera stop];
    }
    [_btnTake.titleLabel setText:@"录制"];
    [_btnTake setTitle:@"录制" forState:UIControlStateNormal];
}
-(void)saveVideo{
    Delog(@"saveVideo-----------");
    [self stopVideo];
    NSString* relativePath = [_videoCamera.videoFileURL relativePath];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(relativePath)) {
        //保存视频到相簿
        Delog(@"保存视频成功：%@",relativePath);
        UISaveVideoAtPathToSavedPhotosAlbum(relativePath, self,nil, nil);
    }else{
        Delog(@"保存视频失败：%@",relativePath);
    }
}

#pragma mark- CvVideoCameraDelegate
- (void)processImage:(cv::Mat&)image
{
    // Do some OpenCV processing with the image
    
//    UIImage *img = MatToUIImage(image);
//    if (!img) {
//        return;
//    }
//    Delog(@"%f-----------%f",img.size.width,img.size.height);
//    Delog(@"%d-----------%d",image.size[0],image.size[1]);
//    cv::resize(image, image, cv::Size(100,100));
//    cv::flip(image, image, -1);//对成
//    cv::transpose(image, image);//旋转90度
}

@end
