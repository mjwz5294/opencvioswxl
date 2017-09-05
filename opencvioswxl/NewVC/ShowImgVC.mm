//
//  ShowImgVC.m
//  opencvioswxl
//
//  Created by longgege on 17/9/5.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "ShowImgVC.h"
#import <opencv2/imgcodecs/ios.h>

@interface ShowImgVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray* editArr_;
    NSString* sourceImgName_;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImg;
@property (weak, nonatomic) IBOutlet UIImageView *resultImg;

@end

@implementation ShowImgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    editArr_ = [NSArray arrayWithObjects:
                @{@"editName":@"showSourceImg",@"editBrief":@"显示原图片"},
                @{@"editName":@"showGrayImg",@"editBrief":@"显示灰色图片"},
                @{@"editName":@"roiTest",@"editBrief":@"设置感兴趣区域"},
                nil];
    
    sourceImgName_ = @"lena.png";
    [_sourceImg setImage:[UIImage imageNamed:sourceImgName_]];
    [self showSourceImg];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showSourceImg{
    [_resultImg setImage:[UIImage imageNamed:sourceImgName_]];
}

-(void)showGrayImg{
    cv::Mat matImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],matImg);
    cv::cvtColor(matImg,matImg,CV_BGR2GRAY);
    [_resultImg setImage:MatToUIImage(matImg)];
    
    //TODO: 尝试写入图片，不成功
    cv::imwrite("resultimg.png", matImg);
    
    //TODO: 尝试这种写法，不成功
//    cv::Mat matImg = cv::imread([sourceImgName_ UTF8String],0);
//    [_resultImg setImage:MatToUIImage(matImg)];
    
    
}

-(void)roiTest{
    
    cv::Mat matImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],matImg);
    
    cv::Mat catImg;
    UIImageToMat([UIImage imageNamed:@"cat.jpeg"],catImg);
    
    cv::Rect rect = cv::Rect(0, 0, 150, 150);
    cv::Rect rect1 = cv::Rect(150, 150, 150, 150);
    
    cv::Mat srcImg = catImg(rect);
    cv::Mat desImg = matImg(rect1);
    /*
     copyTo方法要成功，必须两图片的通道数一致。之前犯过一个错误就是:
     1、先执行CV_BGR2GRAY，通道数由4变为1，即由bgra变味gray
     2、然后执行CV_GRAY2BGR，通道数由1变成了3，即由gray变为bgr
     3、结果copyTo就一只没效果
     */
    cv::cvtColor(srcImg,srcImg,CV_BGR2GRAY);
    cv::cvtColor(srcImg,srcImg,CV_GRAY2BGRA);
    srcImg.copyTo(desImg);
    [_resultImg setImage:MatToUIImage(matImg)];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return editArr_.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSDictionary* tmpdic = editArr_[indexPath.row];
    NSString* tmpBrief = tmpdic[@"editBrief"];
    if (!tmpBrief.length) {
        tmpBrief = tmpdic[@"editName"];
    }
    cell.textLabel.text = tmpBrief;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSelector:NSSelectorFromString(editArr_[indexPath.row][@"editName"])];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
