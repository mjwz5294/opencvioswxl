//
//  GalleryVC.m
//  opencvioswxl
//
//  Created by wxl on 2017/8/24.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "GalleryVC.h"
#import "PostcardPrinter.hpp"
#import <opencv2/imgcodecs/ios.h>

@interface GalleryVC ()

@end

@implementation GalleryVC

@synthesize imageView;
@synthesize loadButton;
@synthesize saveButton;
@synthesize popoverController;
@synthesize toolbar;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Load face detector
    NSString* filename = [[NSBundle mainBundle]
                          pathForResource:@"haarcascade_frontalface_alt2"
                          ofType:@"xml"];
    faceDetector.load([filename UTF8String]);
    
    [saveButton setEnabled:NO];
}

- (NSInteger)supportedInterfaceOrientations
{
    // Only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
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

- (UIImage*)printPostcard:(UIImage*)image;
{
    // Convert input image to cv::Mat
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    //FIXME: workaround for stretch error
    if (cvImage.rows > cvImage.cols)
    {
        cvImage = cvImage.t();
        flip(cvImage, cvImage, 1);
        resize(cvImage, cvImage,
               cv::Size(cvImage.cols, cvImage.rows*2));
    }
    
    // Convert the image to grayscale and stretch contrast
    cv::Mat gray;
    cvtColor(cvImage, gray, CV_RGBA2GRAY);
    equalizeHist(gray, gray);
    
    // Find faces in the image
    std::vector<cv::Rect> faces;
    TS(FaceDetection);
    faceDetector.detectMultiScale(gray, faces, 1.1, 2,
                                  CV_HAAR_FIND_BIGGEST_OBJECT,
                                  cv::Size(100,100));
    TE(FaceDetection);
    
    PostcardPrinter::Parameters parameters;
    
    // Initialize face image
    UIImage* resImage;
    if (faces.size())
    {
        cv::Rect faceRect = faces[0];
        
        // Extend the rectangle
        faceRect.x -= faceRect.width/4;
        faceRect.y -= faceRect.width/4;
        faceRect.width *= 1.5;
        faceRect.height = faceRect.width;
        
        cv::Rect imageRect(0, 0, cvImage.cols, cvImage.rows);
        faceRect = faceRect & imageRect;
        
        parameters.face = cvImage(faceRect);
    }
    else
    {
        resImage = [UIImage imageNamed:@"lena.png"];
        UIImageToMat(image, parameters.face);
    }
    
    // Load other images from resources
    resImage = [UIImage imageNamed:@"texture.jpg"];
    UIImageToMat(image, parameters.texture);
    cvtColor(parameters.texture, parameters.texture, CV_RGBA2RGB);
    
    resImage = [UIImage imageNamed:@"text.png"];
    UIImageToMat(resImage, parameters.text, true);
    
    // Create PostcardPrinter class
    PostcardPrinter postcardPrinter(parameters);
    
    // Add vintage effect
    TS(Preprocessing);
    postcardPrinter.preprocessFace();
    TE(Preprocessing);
    
    // Print postcard
    cv::Mat postcard;
    TS(PostcardPrinting);
    postcardPrinter.print(postcard);
    TE(PostcardPrinting);
    
    return MatToUIImage(postcard);
}

- (void)imagePickerController: (UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==
        UIUserInterfaceIdiomPad)
    {
        [popoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES
                                   completion:nil];
    }
    
    UIImage* temp =
    [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    postcardImage = [self printPostcard:temp];
    imageView.image = postcardImage;
    
    [saveButton setEnabled:YES];
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==
        UIUserInterfaceIdiomPad)
    {
        [popoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)loadButtonPressed:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary])
        return;
    
    UIImagePickerController* picker =
    [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==
        UIUserInterfaceIdiomPad)
    {
        if ([self.popoverController isPopoverVisible])
        {
            [self.popoverController dismissPopoverAnimated:YES];
        }
        else
        {
            self.popoverController =
            [[UIPopoverController alloc]
             initWithContentViewController:picker];
            
            popoverController.delegate = self;
            
            [self.popoverController
             presentPopoverFromBarButtonItem:sender
             permittedArrowDirections:UIPopoverArrowDirectionDown
             animated:YES];
        }
    }
    else
    {
        [self presentViewController:picker
                           animated:YES
                         completion:nil];
    }
}

- (IBAction)saveButtonPressed:(id)sender
{
    if (postcardImage != nil)
    {
        UIImageWriteToSavedPhotosAlbum(postcardImage, self,
                                       nil, NULL);
        
        // Alert window
        UIAlertView *alert = [UIAlertView alloc];
        alert = [alert initWithTitle:@"Status"
                             message:@"Saved to the Gallery!"
                            delegate:nil
                   cancelButtonTitle:@"Continue"
                   otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
