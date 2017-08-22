//
//  ViewController.m
//  opencvioswxl
//
//  Created by wxl on 2017/8/19.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "ViewController.h"
#import "opencviosinterface.h"
#import <opencv2/imgcodecs/ios.h>

@interface ViewController (){
    cv::Mat cvImage;
    UIImage* testImg;
    UIImageView* testImgView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    testImg = [UIImage imageNamed:@"cat"];
    testImgView = [[UIImageView alloc] initWithImage:testImg];
    [self.view addSubview:testImgView];
    
    // Convert UIImage* to cv::Mat
    /*
     下面有三种转换的方式，第一种不太明白，后面两种基本都是先转为NSData，然后转成cv::mat
     */
    cvImage = [[[opencviosinterface alloc] init] cvMatFromUIImage:[UIImage imageNamed:@"cat"]];
    
    if (0){
        NSString* filePath = [[NSBundle mainBundle]
                              pathForResource:@"cat" ofType:@"jpeg"];
        NSLog(@"filePath:%@",filePath);
        // Create file handle
        NSFileHandle* handle =
        [NSFileHandle fileHandleForReadingAtPath:filePath];
        // Read content of the file
        NSData* data = [handle readDataToEndOfFile];
        // Decode image from the data buffer
        cvImage = cv::imdecode(cv::Mat(1, [data length], CV_8UC1,
                                       (void*)data.bytes),
                               CV_LOAD_IMAGE_UNCHANGED);
    }
    
    if (0){
        //        NSData* data = UIImagePNGRepresentation(image);
        NSData* data = UIImageJPEGRepresentation(testImg, 1);
        // Decode image from the data buffer
        cvImage = cv::imdecode(cv::Mat(1, [data length], CV_8UC1,
                                       (void*)data.bytes),
                               CV_LOAD_IMAGE_UNCHANGED);
    }
    
    
    
    //实验
    if (!cvImage.empty())
    {
        [self cannyTest];
    }
    
}

-(void)cannyTest{
    
    NSLog(@"33333");
    cv::Mat gray;
    // Convert the image to grayscale
    cv::cvtColor(cvImage, gray, CV_RGBA2GRAY);
    // Apply Gaussian filter to remove small edges
    cv::GaussianBlur(gray, gray,
                     cv::Size(5, 5), 1.2, 1.2);
    // Calculate edges with Canny
    cv::Mat edges;
    cv::Canny(gray, edges, 0, 50);
    // Fill image with white color
    cvImage.setTo(cv::Scalar::all(255));
    // Change color on edges
    cvImage.setTo(cv::Scalar(0, 128, 255, 255), edges);
    // Convert cv::Mat to UIImage* and show the resulting image
    //        imageView.image = MatToUIImage(cvImage);
    testImgView.image = [[[opencviosinterface alloc] init] UIImageFromCVMat:cvImage];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
