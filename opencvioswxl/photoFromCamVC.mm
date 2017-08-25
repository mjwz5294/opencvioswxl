//
//  photoFromCamVC.m
//  opencvioswxl
//
//  Created by wxl on 2017/8/25.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "photoFromCamVC.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import "opencviosinterface.h"

@interface photoFromCamVC ()<CvPhotoCameraDelegate>
{
    CvPhotoCamera* photoCamera;
    UIImageView* resultView;
    RetroFilter::Parameters params;
}

@property (nonatomic, strong) CvPhotoCamera* photoCamera;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, weak) IBOutlet
UIBarButtonItem* takePhotoButton;
@property (nonatomic, weak) IBOutlet
UIBarButtonItem* startCaptureButton;

-(IBAction)takePhotoButtonPressed:(id)sender;
-(IBAction)startCaptureButtonPressed:(id)sender;

- (UIImage*)applyEffect:(UIImage*)image;

@end

@implementation photoFromCamVC
@synthesize imageView;
@synthesize toolbar;
@synthesize photoCamera;
@synthesize takePhotoButton;
@synthesize startCaptureButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize camera
//    photoCamera = [[CvPhotoCamera alloc] initWithParentView:imageView];
//    photoCamera.delegate = self;
//    photoCamera.defaultAVCaptureDevicePosition =
//    AVCaptureDevicePositionFront;
//    photoCamera.defaultAVCaptureSessionPreset =
//    AVCaptureSessionPresetPhoto;
//    photoCamera.defaultAVCaptureVideoOrientation =
//    AVCaptureVideoOrientationPortrait;
    
    // Load images
    UIImage* resImage = [UIImage imageNamed:@"scratches.png"];
//    UIImageToMat(resImage, params.scratches);
    params.scratches = [[[opencviosinterface alloc] init] cvMatFromUIImage:resImage];
    
    resImage = [UIImage imageNamed:@"fuzzy_border.png"];
//    UIImageToMat(resImage, params.fuzzyBorder);
    params.fuzzyBorder = [[[opencviosinterface alloc] init] cvMatFromUIImage:resImage];
    
    [takePhotoButton setEnabled:NO];
}

- (NSInteger)supportedInterfaceOrientations
{
    // Only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction)takePhotoButtonPressed:(id)sender;
{
    [photoCamera takePicture];
}

-(IBAction)startCaptureButtonPressed:(id)sender;
{
    [photoCamera start];
    [self.view addSubview:imageView];
    [takePhotoButton setEnabled:YES];
    [startCaptureButton setEnabled:NO];
}

- (UIImage*)applyEffect:(UIImage*)image;
{
    cv::Mat frame;
//    UIImageToMat(image, frame);
    frame = [[[opencviosinterface alloc] init] cvMatFromUIImage:image];
    
    params.frameSize = frame.size();
    RetroFilter retroFilter(params);
    
    cv::Mat finalFrame;
    retroFilter.applyToPhoto(frame, finalFrame);
    
//    UIImage* result = MatToUIImage(finalFrame);
    UIImage* result = [[[opencviosinterface alloc] init] UIImageFromCVMat:finalFrame];
    return [UIImage imageWithCGImage:[result CGImage]
                               scale:1.0
                         orientation:UIImageOrientationLeftMirrored];
}

- (void)photoCamera:(CvPhotoCamera*)camera
      capturedImage:(UIImage *)image;
{
    [camera stop];
    resultView = [[UIImageView alloc]
                  initWithFrame:imageView.bounds];
    
    UIImage* result = [self applyEffect:image];
    
    [resultView setImage:result];
    [self.view addSubview:resultView];
    
    [takePhotoButton setEnabled:NO];
    [startCaptureButton setEnabled:YES];
}

- (void)photoCameraCancel:(CvPhotoCamera*)camera;
{
}

- (void)viewDidDisappear:(BOOL)animated
{
    [photoCamera stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    photoCamera.delegate = nil;
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
