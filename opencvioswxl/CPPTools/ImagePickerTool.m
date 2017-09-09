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
    NSDictionary* editDic_;
    void (^callback_)(UIImage*,NSString*);
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

+(void)showImagePickWithBlocks:(NSDictionary*)editDic OtherParms:(NSDictionary*)parms{
    [[ImagePickerTool shareInstance] showImagePickWithBlocks:editDic OtherParms:parms];
}

-(void)showImagePickWithBlocks:(NSDictionary*)editDic OtherParms:(NSDictionary*)parms{
    editDic_ = editDic;
    callback_ = editDic[@"callback"];
    
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary]){
        return;
    }
    
    UIImagePickerController* picker =
    [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    BaseViewController* vc = editDic[@"vc"];
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
    callback_(temp,editDic_[@"title"]);
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
