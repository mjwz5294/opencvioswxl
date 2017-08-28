//
//  advanceCamControlVC.m
//  opencvioswxl
//
//  Created by longgege on 17/8/28.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "advanceCamControlVC.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

@interface advanceCamControlVC ()<CvVideoCameraDelegate>
{
    CvVideoCamera* videoCamera;
    BOOL isCapturing;
    
    BOOL isFocusLocked, isExposureLocked, isBalanceLocked;
}

@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, weak) IBOutlet
UIBarButtonItem* startCaptureButton;
@property (nonatomic, weak) IBOutlet
UIBarButtonItem* stopCaptureButton;

@property (nonatomic, weak) IBOutlet
UIBarButtonItem* lockFocusButton;
@property (nonatomic, weak) IBOutlet
UIBarButtonItem* lockExposureButton;
@property (nonatomic, weak) IBOutlet
UIBarButtonItem* lockBalanceButton;
@property (nonatomic, weak) IBOutlet
UIBarButtonItem* rotationButton;

-(IBAction)startCaptureButtonPressed:(id)sender;
-(IBAction)stopCaptureButtonPressed:(id)sender;

- (IBAction)actionLockFocus:(id)sender;
- (IBAction)actionLockExposure:(id)sender;
- (IBAction)actionLockBalance:(id)sender;

- (IBAction)rotationButtonPressed:(id)sender;

@end

@implementation advanceCamControlVC

@synthesize imageView;
@synthesize startCaptureButton;
@synthesize toolbar;
@synthesize videoCamera;
@synthesize lockFocusButton;
@synthesize lockExposureButton;
@synthesize lockBalanceButton;
@synthesize rotationButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    videoCamera = [[CvVideoCamera alloc]
                   initWithParentView:imageView];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionBack;
    videoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPreset640x480;
    videoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    videoCamera.defaultFPS = 30;
    
    isCapturing = NO;
    
    [lockFocusButton setEnabled:NO];
    [lockExposureButton setEnabled:NO];
    [lockBalanceButton setEnabled:NO];
    
    isFocusLocked = NO;
    isExposureLocked = NO;
    isBalanceLocked = NO;
}

- (NSInteger)supportedInterfaceOrientations
{
    // Only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction)startCaptureButtonPressed:(id)sender
{
    [videoCamera start];
    isCapturing = YES;
    
    [lockFocusButton setEnabled:YES];
    [lockExposureButton setEnabled:YES];
    [lockBalanceButton setEnabled:YES];
}

-(IBAction)stopCaptureButtonPressed:(id)sender
{
    [videoCamera stop];
    isCapturing = NO;
    
    [lockFocusButton setEnabled:NO];
    [lockExposureButton setEnabled:NO];
    [lockBalanceButton setEnabled:NO];
}

- (IBAction)actionLockFocus:(id)sender
{
    if (isFocusLocked)
    {
        [self.videoCamera unlockFocus];
        [lockFocusButton setTitle:@"Lock focus"];
        isFocusLocked = NO;
    }
    else
    {
        [self.videoCamera lockFocus];
        [lockFocusButton setTitle:@"Unlock focus"];
        isFocusLocked = YES;
    }
}

- (IBAction)actionLockExposure:(id)sender
{
    if (isExposureLocked)
    {
        [self.videoCamera unlockExposure];
        [lockExposureButton setTitle:@"Lock exposure"];
        isExposureLocked = NO;
    }
    else
    {
        [self.videoCamera lockExposure];
        [lockExposureButton setTitle:@"Unlock exposure"];
        isExposureLocked = YES;
    }
}

- (IBAction)actionLockBalance:(id)sender
{
    if (isBalanceLocked)
    {
        [self.videoCamera unlockBalance];
        [lockBalanceButton setTitle:@"Lock balance"];
        isBalanceLocked = NO;
    }
    else
    {
        [self.videoCamera lockBalance];
        [lockBalanceButton setTitle:@"Unlock balance"];
        isBalanceLocked = YES;
    }
}


- (IBAction)rotationButtonPressed:(id)sender
{
    videoCamera.rotateVideo = !videoCamera.rotateVideo;
}


- (void)processImage:(cv::Mat&)image
{
    // Do some OpenCV processing with the image
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (isCapturing)
    {
        [videoCamera stop];
    }
}

- (void)dealloc
{
    videoCamera.delegate = nil;
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
