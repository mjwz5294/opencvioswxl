//
//  retroVC.h
//  opencvioswxl
//
//  Created by wxl on 2017/8/25.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RetroFilter.hpp"

@interface retroVC : UIViewController<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIPopoverControllerDelegate>
{
    UIPopoverController* popoverController;
    UIImageView* imageView;
    UIImage* image;
    RetroFilter::Parameters params;
}

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, strong) UIPopoverController* popoverController;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* loadButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* saveButton;

-(IBAction)loadButtonPressed:(id)sender;
-(IBAction)saveButtonPressed:(id)sender;

- (UIImage*)applyFilter:(UIImage*)image;

@end
