//
//  OpencvCameraViewVC.m
//  opencvioswxl
//
//  Created by longgege on 17/9/10.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "OpencvCameraViewVC.h"

#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

#import "RetroFilter.hpp"

@interface OpencvCameraViewVC ()<CvPhotoCameraDelegate>{
    void (^callback_)(UIImage*);
    RetroFilter::Parameters params;
    
}

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UIButton* showToolBtn;


@property (nonatomic, strong) CvPhotoCamera* photoCamera;

@end

@implementation OpencvCameraViewVC

/*
 1、将imageView赋给_photoCamera后，我的imageView会向下拉长60个点，估计是opencv为相机底部的工具条预留的位置；
 2、我点击拍照后，照片的大小并不是imageView中展示的大小。不过这里尺寸，可以通过defaultAVCaptureSessionPreset参数设置。
 */

-(void)openCamera{
    // Initialize camera
    _photoCamera = [[CvPhotoCamera alloc]
                   initWithParentView:_imageView];
    _photoCamera.delegate = self;
    _photoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionFront;
    _photoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPresetPhoto;
    _photoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    
    // Load images
    UIImage* resImage = [UIImage imageNamed:@"scratches.png"];
    UIImageToMat(resImage, params.scratches);
    
    resImage = [UIImage imageNamed:@"fuzzy_border.png"];
    UIImageToMat(resImage, params.fuzzyBorder);
    
    [_photoCamera start];
}

- (IBAction)showTools:(id)sender {
    [_photoCamera takePicture];
}

#pragma mark- CvPhotoCameraDelegate
- (void)photoCamera:(CvPhotoCamera*)camera
      capturedImage:(UIImage *)image;
{
    [camera stop];
    [_imageView setImage:image];
    callback_(image);
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)photoCameraCancel:(CvPhotoCamera*)camera{
    Delog(@"photoCameraCancel");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    Delog(@"viewDidLoad");
    
    [self openCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(void)showOpencvCameraWithParms:(NSDictionary*)parms{
    [[[self alloc] initFromXib] showOpencvCameraWithParms:parms];
}

-(void)showOpencvCameraWithParms:(NSDictionary*)parms{
    Delog(@"showOpencvCameraWithBlock");
    callback_ = parms[@"callback"];
    BaseViewController* vc = parms[@"vc"];
    [vc presentViewController:self animated:YES completion:nil];
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
