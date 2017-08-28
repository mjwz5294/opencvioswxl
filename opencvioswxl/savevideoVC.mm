//
//  savevideoVC.m
//  opencvioswxl
//
//  Created by longgege on 17/8/28.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "savevideoVC.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import "RetroFilter.hpp"

@interface savevideoVC ()<CvVideoCameraDelegate>
{
    CvVideoCamera* videoCamera;
    BOOL isCapturing;
    RetroFilter::Parameters params;
    cv::Ptr<RetroFilter> filter;
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

@implementation savevideoVC

@synthesize imageView;
@synthesize startCaptureButton;
@synthesize toolbar;
@synthesize videoCamera;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize camera
    videoCamera = [[CvVideoCamera alloc]
                   initWithParentView:imageView];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionFront;
    videoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPreset352x288;
    videoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    videoCamera.defaultFPS = 30;
    videoCamera.recordVideo = YES;
    
    isCapturing = NO;
    
    // Load textures
    UIImage* resImage = [UIImage imageNamed:@"scratches.png"];
    UIImageToMat(resImage, params.scratches);
    
    resImage = [UIImage imageNamed:@"fuzzyBorder.png"];
    UIImageToMat(resImage, params.fuzzyBorder);
    
    params.frameSize = cv::Size(352, 288);
    filter = new RetroFilter(params);
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
}

-(IBAction)stopCaptureButtonPressed:(id)sender
{
    [videoCamera stop];
    
    NSString* relativePath = [videoCamera.videoFileURL relativePath];
    UISaveVideoAtPathToSavedPhotosAlbum(relativePath, nil, NULL, NULL);
    
    //Alert window
    UIAlertView *alert = [UIAlertView alloc];
    alert = [alert initWithTitle:@"Status"
                         message:@"Saved to the Gallery!"
                        delegate:nil
               cancelButtonTitle:@"Continue"
               otherButtonTitles:nil];
    [alert show];
    
    isCapturing = NO;
}

- (void)processImage:(cv::Mat&)image
{
    cv::Mat inputFrame = image, finalFrame;
    bool isNeedRotation = image.size() != params.frameSize;
    
    if (isNeedRotation)
        inputFrame = image.t();
    
    filter->applyToVideo(inputFrame, finalFrame);
    
    if (isNeedRotation)
        finalFrame = finalFrame.t();
    
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
