//
//  neonVC.m
//  opencvioswxl
//
//  Created by longgege on 17/8/28.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "neonVC.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import "RetroFilter.hpp"
#import <mach/mach_time.h>

@interface neonVC ()<CvVideoCameraDelegate>
{
    CvVideoCamera* videoCamera;
    BOOL isCapturing;
    RetroFilter::Parameters params;
    cv::Ptr<RetroFilter> filter;
    uint64_t prevTime;
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

@implementation neonVC

@synthesize imageView;
@synthesize startCaptureButton;
@synthesize toolbar;
@synthesize videoCamera;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize camera
    self.videoCamera = [[CvVideoCamera alloc]
                        initWithParentView:imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    
    isCapturing = NO;
    
    // Load textures
    UIImage* resImage = [UIImage imageNamed:@"scratches.png"];
    UIImageToMat(resImage, params.scratches);
    
    resImage = [UIImage imageNamed:@"fuzzyBorder.png"];
    UIImageToMat(resImage, params.fuzzyBorder);
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
    
    params.frameSize = cv::Size(videoCamera.imageWidth,
                                videoCamera.imageHeight);
    
    filter = new RetroFilter(params);
}

-(IBAction)stopCaptureButtonPressed:(id)sender
{
    [videoCamera stop];
    isCapturing = NO;
}

static double machTimeToSecs(uint64_t time)
{
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return (double)time * (double)timebase.numer /
    (double)timebase.denom / 1e9;
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

- (void)processImage:(cv::Mat&)image
{
    cv::Mat inputFrame = image;
    
    bool isNeedRotation = image.size() != params.frameSize;
    if (isNeedRotation)
        inputFrame = image.t();
    
    // Apply filter
    cv::Mat finalFrame;
    TS(ApplyingFilter);
    filter->applyToVideo_optimized(inputFrame, finalFrame);
    TE(ApplyingFilter);
    
    if (isNeedRotation)
        finalFrame = finalFrame.t();
    
    // Add fps label to the frame
    uint64_t currTime = mach_absolute_time();
    double timeInSeconds = machTimeToSecs(currTime - prevTime);
    prevTime = currTime;
    double fps = 1.0 / timeInSeconds;
    NSString* fpsString =
    [NSString stringWithFormat:@"FPS = %3.2f", fps];
    cv::putText(finalFrame, [fpsString UTF8String],
                cv::Point(30, 30), cv::FONT_HERSHEY_COMPLEX_SMALL,
                0.8, cv::Scalar::all(255));
    
    finalFrame.copyTo(image);
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
