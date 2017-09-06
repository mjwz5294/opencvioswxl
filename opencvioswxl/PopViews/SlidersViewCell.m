//
//  SlidersViewCell.m
//  opencvioswxl
//
//  Created by longgege on 17/9/6.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "SlidersViewCell.h"

@interface SlidersViewCell(){
    void (^callback_)(CGFloat);
}

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation SlidersViewCell

-(void)awakeFromNib{
    [super awakeFromNib];
    [_titleLab setText:@"haha"];
    [_slider setValue:0];
}

-(void)refresh:(NSDictionary*)dic{
    callback_ = dic[@"callback"];
    [_titleLab setText:dic[@"title"]];
    
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    _slider.continuous = NO;//当放开手, 值才确定下来
}

-(void)sliderValueChanged:(UISlider *)slider{
    if ([slider isEqual:_slider]) {
        callback_(slider.value);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
