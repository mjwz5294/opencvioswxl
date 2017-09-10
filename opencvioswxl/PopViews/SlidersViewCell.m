//
//  SlidersViewCell.m
//  opencvioswxl
//
//  Created by longgege on 17/9/6.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "SlidersViewCell.h"

@interface SlidersViewCell(){
    void (^callback_)(CGFloat,NSString*,BOOL);
    //
    /*
     1、之前一直想通过判断block结构来实现对不同结构的block调用，没成功，只能通过‘对其它参数定义协议’来实现了。
     2、后来根据http://www.jianshu.com/p/7b7bb050c643提供的方法来实现block可变参数适配，即将callback_定义为void (^callback_)()，发现传回去的参数乱了，没办法用；
     3、偶然尝试了一个暴力的做法，就是直接定义void (^callback_)(CGFloat,NSString*)，为之前的callback_添加一个NSString类型的回调参数，发现参数居然都能识别，只要顺序能对上就没问题。
     4、总结：对于一个void (^callback_)(CGFloat,NSString*,NSInteger)的block
     （1）我可以给它赋值为参数为（CGFloat），（CGFloat，,NSString*）或(CGFloat,NSString*,NSInteger)的block
     （2）但不能赋值为参数为(CGFloat,NSInteger)或(CGFloat，NSString*,NSInteger,NSString*)的block
     （3）说明参数可以少，不能多，不能顺序对不上
     5、这里的方案：没必要再定义什么callbackType_了，只需要在callback_添加参数，然后全部传回去，外面要用哪些参数，按顺序取就行了。以后要扩展也一样，只管添加返回的参数
     */
}

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic,assign) BOOL isSwitch;
@property (nonatomic,assign) BOOL isSwitchOn;

@end

@implementation SlidersViewCell

-(void)awakeFromNib{
    [super awakeFromNib];
    [_titleLab setText:@"haha"];
    [_slider setValue:0];
    _isSwitch = NO;
    _isSwitchOn = NO;
}

-(void)refresh:(NSDictionary*)dic{
    callback_ = dic[@"callback"];
    [_titleLab setText:dic[@"title"]];
    
    if (dic[@"isSwitch"]) {
        _isSwitch = YES;
        _isSwitchOn = [dic[@"isSwitch"] boolValue];
        [self refreshSwitchState];
    }
    
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    _slider.continuous = NO;//当放开手, 值才确定下来
}

-(void)sliderValueChanged:(UISlider *)slider{
    
    if ([slider isEqual:_slider]) {
        if (_isSwitch) {
            _isSwitchOn = !_isSwitchOn;
            [self refreshSwitchState];
        }
        callback_(slider.value,_titleLab.text,_isSwitchOn);
    }
}

-(void)refreshSwitchState{
    if (_isSwitchOn) {
        [_titleLab setTextColor:[UIColor redColor]];
    }else{
        [_titleLab setTextColor:[UIColor blackColor]];
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
