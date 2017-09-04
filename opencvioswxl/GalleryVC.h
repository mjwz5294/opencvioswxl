//
//  GalleryVC.h
//  opencvioswxl
//
//  Created by wxl on 2017/8/24.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryVC : BaseViewController<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIPopoverControllerDelegate>
{
    UIPopoverController* popoverController;
    UIImageView* imageView;
    UIImage* postcardImage;
    cv::CascadeClassifier faceDetector;
}

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, strong) UIPopoverController* popoverController;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* loadButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* saveButton;

-(IBAction)loadButtonPressed:(id)sender;
-(IBAction)saveButtonPressed:(id)sender;

- (UIImage*)printPostcard:(UIImage*)image;

@end
