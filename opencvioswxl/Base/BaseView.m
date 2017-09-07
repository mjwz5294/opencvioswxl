//
//  BaseView.m
//  opencvioswxl
//
//  Created by longgege on 17/9/6.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

-(void)awakeFromNib{
    [super awakeFromNib];
    
}

-(void)dealloc{
    DebugLog(@"dealloc:%@",[self class]);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
