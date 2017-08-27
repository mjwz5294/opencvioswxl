//
//  videoFromCamVC.m
//  opencvioswxl
//
//  Created by wxl on 2017/8/26.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "videoFromCamVC.h"
#import <opencv2/imgcodecs/ios.h>
#import "opencviosinterface.h"
#import <opencv2/videoio/cap_ios.h>

@interface videoFromCamVC ()<CvVideoCameraDelegate>
{
    BOOL isCapturing;
}

@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, weak) IBOutlet
UIBarButtonItem* startCaptureButton;
@property (nonatomic, weak) IBOutlet
UIBarButtonItem* stopCaptureButton;

-(IBAction)startCaptureButtonPressed:(id)sender;
-(IBAction)stopCaptureButtonPressed:(id)sender;

@end

@implementation videoFromCamVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    CvVideoCamera* testCam = [[CvVideoCamera alloc] init];
    
    self.videoCamera = [[CvVideoCamera alloc]
                        initWithParentView:_imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    
    isCapturing = NO;
}

- (NSInteger)supportedInterfaceOrientations
{
    // Only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction)startCaptureButtonPressed:(id)sender
{
    [_videoCamera start];
    isCapturing = YES;
}

-(IBAction)stopCaptureButtonPressed:(id)sender
{
    [_videoCamera stop];
    isCapturing = NO;
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
        [_videoCamera stop];
    }
}

- (void)dealloc
{
    _videoCamera.delegate = nil;
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
