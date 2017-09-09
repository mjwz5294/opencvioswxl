//
//  ImagePickerTool.h
//  opencvioswxl
//
//  Created by longgege on 17/9/9.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePickerTool : NSObject

+(void)showImagePickWithBlocks:(void (^)(UIImage* img))callblock OtherParms:(NSDictionary*)parms;

@end
