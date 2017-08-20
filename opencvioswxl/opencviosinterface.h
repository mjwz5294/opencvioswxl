//
//  opencviosinterface.h
//  opencvioswxl
//
//  Created by wxl on 2017/8/20.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface opencviosinterface : NSObject

- (cv::Mat)cvMatFromUIImage:(UIImage *)image;

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end
