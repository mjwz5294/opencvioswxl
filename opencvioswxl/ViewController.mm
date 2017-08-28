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
    cv::CascadeClassifier faceDetector;
}

@end

@implementation ViewController

- (IBAction)centerBtnTapped:(id)sender {
    [self pushToGallery];
    
}

-(void)pushToGallery{
    
//    NSString* vcId = @"GalleryVC";
//    NSString* vcId = @"retroVC";
//    NSString* vcId = @"photoFromCamVC";
//    NSString* vcId = @"videoFromCamVC";
//    NSString* vcId = @"advanceCamControlVC";
//    NSString* vcId = @"processionVideoVC";
    NSString* vcId = @"savevideoVC";
    
    UIViewController* tmpVC = [self.storyboard instantiateViewControllerWithIdentifier:vcId];
    [self.navigationController pushViewController:tmpVC animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    testImg = [UIImage imageNamed:@"lena.png"];
//    testImg = [UIImage imageNamed:@"cat"];
    testImg = [UIImage imageNamed:@"meinv.jpg"];
    testImgView = [[UIImageView alloc] initWithImage:testImg];
    [self.view addSubview:testImgView];
    
    // Convert UIImage* to cv::Mat
    /*
     下面有三种转换的方式，第一种不太明白，后面两种基本都是先转为NSData，然后转成cv::mat
     */
    cvImage = [[[opencviosinterface alloc] init] cvMatFromUIImage:testImg];
    
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
        [self faceDetectTest];
    }
    
    
    
    
    
    
}

-(void)faceDetectTest{
    // Load cascade classifier from the XML file
    NSString* cascadePath = [[NSBundle mainBundle]
                             pathForResource:@"haarcascade_frontalface_alt"
                             ofType:@"xml"];
    faceDetector.load([cascadePath UTF8String]);
    
    //Load image with face
    cv::Mat faceImage = [[[opencviosinterface alloc] init] cvMatFromUIImage:testImg];
    
    // Convert to grayscale
    cv::Mat gray;
    cvtColor(faceImage, gray, CV_BGR2GRAY);
    
    // Detect faces
    std::vector<cv::Rect> faces;
    faceDetector.detectMultiScale(gray, faces, 1.1,
                                  2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
    
    // Draw all detected faces
    for(unsigned int i = 0; i < faces.size(); i++)
    {
        const cv::Rect& face = faces[i];
        // Get top-left and bottom-right corner points
        cv::Point tl(face.x, face.y);
        cv::Point br = tl + cv::Point(face.width, face.height);
        
        // Draw rectangle around the face
        cv::Scalar magenta = cv::Scalar(255, 0, 255);
        cv::rectangle(faceImage, tl, br, magenta, 4, 8, 0);
    }
    
    // Show resulting image
//    testImgView.image = MatToUIImage(faceImage);
    testImgView.image = [[[opencviosinterface alloc] init] UIImageFromCVMat:faceImage];
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
