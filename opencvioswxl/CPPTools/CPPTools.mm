//
//  CPPTools.m
//  opencvioswxl
//
//  Created by longgege on 17/9/9.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "CPPTools.h"
#import <opencv2/imgcodecs/ios.h>
#import "PostcardPrinter.hpp"//制作邮票

@implementation CPPTools



+(UIImage*)printPostcardWithImg:(UIImage*)image{
    PostcardPrinter::Parameters params;
    UIImage* tmpImg = image;
    UIImageToMat(tmpImg, params.face);
    
    // Load image with texture
    tmpImg = [UIImage imageNamed:@"texture.jpg"];
    UIImageToMat(tmpImg, params.texture);
    cvtColor(params.texture, params.texture, CV_RGBA2RGB);
    
    // Load image with text
    tmpImg = [UIImage imageNamed:@"text.png"];
    UIImageToMat(tmpImg, params.text, true);
    
    // Create PostcardPrinter class
    PostcardPrinter postcardPrinter(params);
    
    // Print postcard, and measure printing time
    cv::Mat postcard;
    int64 timeStart = cv::getTickCount();
    postcardPrinter.print(postcard);
    int64 timeEnd = cv::getTickCount();
    float durationMs =
    1000.f * float(timeEnd - timeStart) / cv::getTickFrequency();
    NSLog(@"Printing time = %.3fms", durationMs);
    
    if (postcard.empty()){
        cv::Mat tmpMat;
        UIImageToMat(image, tmpMat);
        NSLog(@"printPostcardWithImg失败--------");
        return MatToUIImage(tmpMat);
    }
    return MatToUIImage(postcard);
}

@end
