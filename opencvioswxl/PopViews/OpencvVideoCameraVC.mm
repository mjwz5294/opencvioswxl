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

@interface OpencvVideoCameraVC ()<CvVideoCameraDelegate>{
    void (^callback_)(UIImage*);
}

@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UIButton* showToolBtn;
@property (nonatomic, assign) BOOL isFocusLocked, isExposureLocked, isBalanceLocked;


@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) UIImage* img;

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
    _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    _videoCamera.defaultFPS = 30;
    
    _isFocusLocked = NO;
    _isExposureLocked = NO;
    _isBalanceLocked = NO;
    
    [_videoCamera start];
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
    void (^stopBlock)() = ^(){
        [weakSelf.videoCamera stop];
        if(weakSelf.img){
            callback_(weakSelf.img);
        }
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    [SlidersView showSlidersViewWithBlocks:@[
                                             @{@"callback":lockFocusBlock,@"title":@"聚焦开关",@"isSwitch":@(_isFocusLocked)},
                                             @{@"callback":lockExposureBlock,@"title":@"曝光开关",@"isSwitch":@(_isExposureLocked)},
                                             @{@"callback":lockBalanceBlock,@"title":@"平衡开关",@"isSwitch":@(_isBalanceLocked)},
                                             @{@"callback":rotationBlock,@"title":@"旋转开关",@"isSwitch":@(_videoCamera.rotateVideo)},
                                             @{@"callback":stopBlock,@"title":@"关闭"}
                                             ] OtherParms:@{@"parentView":self.view}];
}

#pragma mark- CvVideoCameraDelegate
- (void)processImage:(cv::Mat&)image
{
    // Do some OpenCV processing with the image
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
