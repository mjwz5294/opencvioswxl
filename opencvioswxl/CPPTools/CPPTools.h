//
//  CPPTools.h
//  opencvioswxl
//
//  Created by longgege on 17/9/9.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPPTools : NSObject

///输入UIImage，输出一个转化为postcard的UIImage
+(UIImage*)printPostcardWithImg:(UIImage*)image;

///输入UIImage，输出一个经过复古化处理的UIImage
+ (UIImage*)retroWithImg:(UIImage*)inputImage;

@end
