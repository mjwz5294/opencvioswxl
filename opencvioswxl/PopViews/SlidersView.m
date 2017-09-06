//
//  SlidersView.m
//  opencvioswxl
//
//  Created by longgege on 17/9/6.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "SlidersView.h"

@implementation SlidersView

+(void)showSlidersViewWithBlocks:(NSArray*)blockArr OtherParms:(NSDictionary*)parms{
    void (^contrastBlock)(CGFloat) = blockArr[0][@"callback"];
    void (^brightBlock)(CGFloat) = blockArr[1][@"callback"];
    
    contrastBlock(0.5);
    brightBlock(0.5);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
