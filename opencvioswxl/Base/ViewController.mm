//
//  ViewController.m
//  opencvioswxl
//
//  Created by wxl on 2017/8/19.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "ViewController.h"
#import <opencv2/imgcodecs/ios.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray* vcArr_;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"OPENCV STUDY";
    
    vcArr_ = [NSArray arrayWithObjects:
              @{@"vcName":@"ShowImgVC",@"vcBrief":@"对图片进行基本处理，并展示"},
              @{@"vcName":@"GalleryVC",@"vcBrief":@""},
              @{@"vcName":@"retroVC",@"vcBrief":@""},
              @{@"vcName":@"photoFromCamVC",@"vcBrief":@""},
              @{@"vcName":@"videoFromCamVC",@"vcBrief":@""},
              @{@"vcName":@"advanceCamControlVC",@"vcBrief":@""},
              @{@"vcName":@"processionVideoVC",@"vcBrief":@""},
              @{@"vcName":@"savevideoVC",@"vcBrief":@""},
              @{@"vcName":@"neonVC",@"vcBrief":@""},
              @{@"vcName":@"detectFacialFeatureVC",@"vcBrief":@""},
              nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return vcArr_.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSDictionary* tmpdic = vcArr_[indexPath.row];
    NSString* tmpBrief = tmpdic[@"vcBrief"];
    if (!tmpBrief.length) {
        tmpBrief = tmpdic[@"vcName"];
    }
    cell.textLabel.text = tmpBrief;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BaseViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:vcArr_[indexPath.row][@"vcName"]];
    [self.navigationController pushViewController:vc animated:YES];
}






@end
