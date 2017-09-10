//
//  OpencvVideoCameraVC.m
//  opencvioswxl
//
//  Created by longgege on 17/9/10.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "OpencvVideoCameraVC.h"
#import "SlidersView.h"

#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

#import "RetroFilter.hpp"
#import <mach/mach_time.h>

@interface OpencvVideoCameraVC ()<CvVideoCameraDelegate>{
    void (^callback_)(UIImage*);
    
}

@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UIButton* showToolBtn;
@property (nonatomic, assign) BOOL isFocusLocked, isExposureLocked, isBalanceLocked, isUsingRetroFilter;


@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) UIImage* img;
@property (nonatomic, assign) RetroFilter::Parameters params;
@property (nonatomic, assign) cv::Ptr<RetroFilter> filter;
@property (nonatomic, assign) uint64_t prevTime;

@end

/*
 1、videoCamera的高级功能（如聚焦等），只有后置摄像头才行，这点可以通过defaultAVCaptureDevicePosition参数来设置。
 */

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
    _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    _videoCamera.defaultFPS = 30;
    _videoCamera.recordVideo = YES;//没这句就没法保存
    
    _isFocusLocked = NO;
    _isExposureLocked = NO;
    _isBalanceLocked = NO;
    _isUsingRetroFilter = NO;
    
    // Load textures
    UIImage* resImage = [UIImage imageNamed:@"scratches.png"];
    UIImageToMat(resImage, _params.scratches);
    
    resImage = [UIImage imageNamed:@"fuzzyBorder.png"];
    UIImageToMat(resImage, _params.fuzzyBorder);
    
    _prevTime = mach_absolute_time();
    
    [_videoCamera start];
    
    _params.frameSize = cv::Size(352, 288);
    
    if (!_filter)
        _filter = new RetroFilter(_params);
    
}

- (IBAction)showTools:(id)sender {
    
    WeakSelf;
    
    void (^lockFocusBlock)(CGFloat,NSString*,BOOL) = ^(CGFloat progress,NSString* titleStr,BOOL isSwitchOn){
        weakSelf.isFocusLocked = isSwitchOn;
        if (!isSwitchOn) {
            [weakSelf.videoCamera unlockFocus];
        }else{
            [weakSelf.videoCamera lockFocus];
        }
    };
    void (^lockExposureBlock)(CGFloat,NSString*,BOOL) = ^(CGFloat progress,NSString* titleStr,BOOL isSwitchOn){
        weakSelf.isExposureLocked = isSwitchOn;
        if (!isSwitchOn) {
            [weakSelf.videoCamera unlockExposure];
        }else{
            [weakSelf.videoCamera lockExposure];
        }
    };
    void (^lockBalanceBlock)(CGFloat,NSString*,BOOL) = ^(CGFloat progress,NSString* titleStr,BOOL isSwitchOn){
        weakSelf.isBalanceLocked = isSwitchOn;
        if (!isSwitchOn) {
            [weakSelf.videoCamera unlockBalance];
        }else{
            [weakSelf.videoCamera lockBalance];
        }
    };
    void (^rotationBlock)(CGFloat,NSString*,BOOL) = ^(CGFloat progress,NSString* titleStr,BOOL isSwitchOn){
        weakSelf.videoCamera.rotateVideo = isSwitchOn;
    };
    void (^usingRetroFilterBlock)(CGFloat,NSString*,BOOL) = ^(CGFloat progress,NSString* titleStr,BOOL isSwitchOn){
        weakSelf.isUsingRetroFilter = isSwitchOn;
    };
    void (^saveVideoBlock)(CGFloat,NSString*,BOOL) = ^(CGFloat progress,NSString* titleStr,BOOL isSwitchOn){
        [weakSelf saveVideo];
    };
    void (^stopBlock)() = ^(){
        [weakSelf stopVideo];
    };
    
    [SlidersView showSlidersViewWithBlocks:@[
                                             @{@"callback":lockFocusBlock,@"title":@"聚焦开关",@"isSwitch":@(_isFocusLocked)},
                                             @{@"callback":lockExposureBlock,@"title":@"曝光开关",@"isSwitch":@(_isExposureLocked)},
                                             @{@"callback":lockBalanceBlock,@"title":@"平衡开关",@"isSwitch":@(_isBalanceLocked)},
                                             @{@"callback":rotationBlock,@"title":@"旋转开关",@"isSwitch":@(_videoCamera.rotateVideo)},
                                             @{@"callback":usingRetroFilterBlock,@"title":@"复古效果",@"isSwitch":@(_isUsingRetroFilter)},
                                             @{@"callback":saveVideoBlock,@"title":@"保存"},
                                             @{@"callback":stopBlock,@"title":@"关闭"}
                                             ] OtherParms:@{@"parentView":self.view}];
}

-(void)saveVideo{
    [_videoCamera stop];
    NSString* relativePath = [_videoCamera.videoFileURL relativePath];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(relativePath)) {
        //保存视频到相簿
        Delog(@"保存成功：%@",relativePath);
        UISaveVideoAtPathToSavedPhotosAlbum(relativePath, self,nil, nil);
        
        //Alert window
        UIAlertView *alert = [UIAlertView alloc];
        alert = [alert initWithTitle:@"Status"
                             message:@"Saved to the Gallery!"
                            delegate:nil
                   cancelButtonTitle:@"Continue"
                   otherButtonTitles:nil];
        [alert show];
    }else{
        Delog(@"保存失败：%@",relativePath);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)stopVideo{
    [_videoCamera stop];
    if(_img){
        callback_(_img);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Macros for time measurements
#if 1
#define TS(name) int64 t_##name = cv::getTickCount()
#define TE(name) printf("TIMER_" #name ": %.2fms\n", \
1000.*((cv::getTickCount() - t_##name) / cv::getTickFrequency()))
#else
#define TS(name)
#define TE(name)
#endif

//TODO: may be remove this code
static double machTimeToSecs(uint64_t time)
{
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return (double)time * (double)timebase.numer /
    (double)timebase.denom / 1e9;
}

#pragma mark- CvVideoCameraDelegate
- (void)processImage:(cv::Mat&)image
{
    // Do some OpenCV processing with the image
    
    
    if (_isUsingRetroFilter) {
        cv::Mat inputFrame = image;
        BOOL isNeedRotation = image.size() != _params.frameSize;
        if (isNeedRotation)
            inputFrame = image.t();
        
        // Apply filter
        cv::Mat finalFrame;
        TS(ApplyingFilter);
        _filter->applyToVideo(inputFrame, finalFrame);
        TE(ApplyingFilter);
        
        if (isNeedRotation)
            finalFrame = finalFrame.t();
        
        // Add fps label to the frame
        uint64_t currTime = mach_absolute_time();
        double timeInSeconds = machTimeToSecs(currTime - _prevTime);
        _prevTime = currTime;
        double fps = 1.0 / timeInSeconds;
        NSString* fpsString = [NSString stringWithFormat:@"FPS = %3.2f", fps];
        cv::putText(finalFrame,[fpsString UTF8String],cv::Point(30, 30),cv::FONT_HERSHEY_COMPLEX_SMALL,0.8,cv::Scalar::all(255));
        
        finalFrame.copyTo(image);
    }
    
    
    _img = MatToUIImage(image);
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
