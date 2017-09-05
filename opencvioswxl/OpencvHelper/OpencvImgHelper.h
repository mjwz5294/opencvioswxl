//
//  OpencvImgHelper.h
//  opencvioswxl
//
//  Created by longgege on 17/9/5.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpencvImgHelper : NSObject

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image readType:(NSInteger)type;

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end
