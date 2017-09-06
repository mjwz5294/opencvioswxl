//
//  SlidersView.m
//  opencvioswxl
//
//  Created by longgege on 17/9/6.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "SlidersView.h"
#import "SlidersViewCell.h"

@interface SlidersView()<UITableViewDelegate,UITableViewDataSource>{
    NSArray* editArr_;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@end

@implementation SlidersView

+(void)showSlidersViewWithBlocks:(NSArray*)blockArr OtherParms:(NSDictionary*)parms{
    [[SlidersView viewFromNib] showSlidersViewWithBlocks:blockArr OtherParms:parms];
}

-(void)showSlidersViewWithBlocks:(NSArray*)blockArr OtherParms:(NSDictionary*)parms{
    
    [_titleLab setText:@"操作对比度和亮度"];
    editArr_ = blockArr;
    
    [self setFrame:CGRectMake(0, 0,screenWidth, screenHeight)];
    UIView* parentview = parms[@"parentView"];
    if (parentview) {
        [parentview addSubview:self];
    }else{
        [[self topViewController].view addSubview:self];
    }
    
    [_tableView registerNib:[UINib nibWithNibName:@"SlidersViewCell" bundle:nil] forCellReuseIdentifier:@"SlidersViewCell"];
    [_tableView setTableFooterView:[UIView new]];
    [_tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return editArr_.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SlidersViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SlidersViewCell" forIndexPath:indexPath];
    
    [cell refresh:editArr_[indexPath.row]];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self removeFromSuperview];
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
