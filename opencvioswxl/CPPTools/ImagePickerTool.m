//
//  ImagePickerTool.m
//  opencvioswxl
//
//  Created by longgege on 17/9/9.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "ImagePickerTool.h"

@interface ImagePickerTool()<UIImagePickerControllerDelegate,
UINavigationControllerDelegate>{
    void (^callback_)(UIImage*);
}

@end

@implementation ImagePickerTool

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static ImagePickerTool *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

+(void)showImagePickWithBlocks:(void (^)(UIImage* img))callblock OtherParms:(NSDictionary*)parms{
    [[ImagePickerTool shareInstance] showImagePickWithBlocks:callblock OtherParms:parms];
}

-(void)showImagePickWithBlocks:(void (^)(UIImage* img))callblock OtherParms:(NSDictionary*)parms{
    callback_ = callblock;
    
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary]){
        return;
    }
    
    UIImagePickerController* picker =
    [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    BaseViewController* vc = parms[@"vc"];
    [vc presentViewController:picker
                       animated:YES
                     completion:nil];
}


#pragma mark- UIImagePickerControllerDelegate
- (void)imagePickerController: (UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
    UIImage* temp = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    callback_(temp);
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
