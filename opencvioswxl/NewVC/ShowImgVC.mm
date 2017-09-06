//
//  ShowImgVC.m
//  opencvioswxl
//
//  Created by longgege on 17/9/5.
//  Copyright © 2017年 mjwz5294. All rights reserved.
//

#import "ShowImgVC.h"
#import <opencv2/imgcodecs/ios.h>
#import "SlidersView.h"

@interface ShowImgVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray* editArr_;
    NSString* sourceImgName_;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImg;
@property (weak, nonatomic) IBOutlet UIImageView *resultImg;
@property (weak, nonatomic) IBOutlet UILabel *testLab;

@end

@implementation ShowImgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    editArr_ = [NSArray arrayWithObjects:
                @{@"editName":@"showSourceImg",@"editBrief":@"显示原图片"},
                @{@"editName":@"showGrayImg",@"editBrief":@"显示灰色图片"},
                @{@"editName":@"roiTest",@"editBrief":@"设置感兴趣区域"},
                @{@"editName":@"weightTest",@"editBrief":@"图像混合加权"},
                @{@"editName":@"splitAndMerge",@"editBrief":@"分离颜色通道与多通道图像混合"},
                @{@"editName":@"contrastAndBright",@"editBrief":@"图像对比度、亮度调整"},
                nil];
    
    sourceImgName_ = @"lena.png";
    [_sourceImg setImage:[UIImage imageNamed:sourceImgName_]];
    [self showSourceImg];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)contrastAndBright{
    WeakSelf;
    
    __block CGFloat tmpcon = 0;
    __block CGFloat tmpbri = 0;
    void (^contrastBlock)(CGFloat) = ^(CGFloat progress){
        tmpcon = progress;
        [weakSelf contrastAndBrightWithContrast:tmpcon withBright:tmpbri];
    };
    void (^brightBlock)(CGFloat) = ^(CGFloat progress){
        tmpbri = progress;
        [weakSelf contrastAndBrightWithContrast:tmpcon withBright:tmpbri];
    };
    
    [SlidersView showSlidersViewWithBlocks:@[
  @{@"callback":contrastBlock,@"title":@"对比度"},
  @{@"callback":brightBlock,@"title":@"亮度"}
  ] OtherParms:@{@"parentView":self.view}];
    
}

-(void)contrastAndBrightWithContrast:(CGFloat)contrast withBright:(CGFloat)bright{
    DebugLog(@"contrast:%f",contrast);
    DebugLog(@"bright:%f",bright);
    
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    dstImg= cv::Mat::zeros( sourceImg.size(), sourceImg.type());
    //三个for循环，执行运算 dstImg(i,j) =a*sourceImg(i,j) + b
    for(int y = 0; y < sourceImg.rows; y++ )
    {
        for(int x = 0; x < sourceImg.cols; x++ )
        {
            for(int c = 0; c < 3; c++ )
            {
                dstImg.at<cv::Vec3b>(y,x)[c]= cv::saturate_cast<uchar>( (contrast)*(sourceImg.at<cv::Vec3b>(y,x)[c] ) + bright);
            }
        }
    }
    
    [_resultImg setImage:MatToUIImage(dstImg)];
    
}

//为了更好的观察一些图像材料的特征，有时需要对RGB三个颜色通道的分量进行分别显示和调整。通过opencv的split和merge方法可以很方便的达到目的
-(void)splitAndMerge{
    //【0】定义相关变量
    cv::Mat matImg,catImg,imageBlueChannel,imageBlueChannel1;
    std::vector<cv::Mat> channels,channels1;
    
    //【1】读入图片
    UIImageToMat([UIImage imageNamed:sourceImgName_],catImg);
    UIImageToMat([UIImage imageNamed:@"cat.jpeg"],matImg);
    
    //【2】把一个3通道图像转换成3个单通道图像
    cv::split(catImg,channels);//分离色彩通道
    cv::split(matImg,channels1);//分离色彩通道
    
    //【3】将原图的蓝色通道引用返回给imageBlueChannel，注意是引用，相当于两者等价，修改其中一个另一个跟着变
    imageBlueChannel=channels.at(0);
    imageBlueChannel1=channels1.at(2);
    
    cv::Rect rect = cv::Rect(0, 0, matImg.cols, matImg.rows);
    
    //【4】将原图的蓝色通道的（500,250）坐标处右下方的一块区域和logo图进行加权操作，将得到的混合结果存到imageBlueChannel中
    //需要注意：这里三张图的通道数必须一样，但具体哪个通道没要求。至于美术原理的设计，这里就先不研究了
    addWeighted(imageBlueChannel(rect),1.0,imageBlueChannel1,1.0,0,imageBlueChannel(rect));
    
    //【5】将三个单通道重新合并成一个三通道,注意，这里必须是三个单通道
    cv::merge(channels,catImg);
    
    [_resultImg setImage:MatToUIImage(catImg)];
    
}

-(void)weightTest{
    //【0】定义一些局部变量
    float alphaValue = 1;
    float betaValue = 1;
    cv::Rect rect = cv::Rect(0, 0, 250, 150);
    
    //【1】读取图像 ( 两幅图片需为同样的类型和尺寸 )
    cv::Mat srcImage2,srcImage3,dstImage;
    UIImageToMat([UIImage imageNamed:sourceImgName_],srcImage2);
    UIImageToMat([UIImage imageNamed:@"cat.jpeg"],srcImage3);
    srcImage2 = srcImage2(rect);
    srcImage3 = srcImage3(rect);
    
    //【2】做图像混合加权操作
    addWeighted(srcImage2, alphaValue, srcImage3, betaValue, 0.9, dstImage);
    [_resultImg setImage:MatToUIImage(dstImage)];
    /*TODO: 这里参数的设置原理不太明白，先放几个解释在这里吧
     void addWeighted(InputArray src1, double alpha, InputArray src2, double beta, double gamma, OutputArray dst, int dtype=-1);
     第一个参数，InputArray类型的src1，表示需要加权的第一个数组，常常填一个Mat。
     第二个参数，alpha，表示第一个数组的权重
     第三个参数，src2，表示第二个数组，它需要和第一个数组拥有相同的尺寸和通道数。
     第四个参数，beta，表示第二个数组的权重值。
     第五个参数，dst，输出的数组，它和输入的两个数组拥有相同的尺寸和通道数。
     第六个参数，gamma，一个加到权重总和上的标量值。看下面的式子自然会理解。
     第七个参数，dtype，输出阵列的可选深度，有默认值-1。;当两个输入数组具有相同的深度时，这个参数设置为-1（默认值），即等同于src1.depth（）
     */
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
