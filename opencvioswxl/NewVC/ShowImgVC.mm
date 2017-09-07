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
                @{@"editName":@"nolinearBlurTest",@"editBrief":@"非线性滤波"},
                @{@"editName":@"linearBlurTest",@"editBrief":@"线性滤波"},
                @{@"editName":@"dilateAndErode",@"editBrief":@"膨胀腐蚀等基本形态学处理"},
                @{@"editName":@"morphologyExTest",@"editBrief":@"形态学高级处理"},
                @{@"editName":@"contrastAndBright",@"editBrief":@"图像对比度、亮度调整"},
                @{@"editName":@"splitAndMerge",@"editBrief":@"分离颜色通道与多通道图像混合"},
                @{@"editName":@"weightTest",@"editBrief":@"图像混合加权"},
                @{@"editName":@"roiTest",@"editBrief":@"设置感兴趣区域"},
                @{@"editName":@"showSourceImg",@"editBrief":@"显示原图片"},
                @{@"editName":@"showGrayImg",@"editBrief":@"显示灰色图片"},
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

/*形态学高级处理
 1、开运算（Opening Operation），其实就是先腐蚀后膨胀的过程。开运算可以用来消除小物体、在纤细点处分离物体、平滑较大物体的边界的同时并不明显改变其面积
 2、先膨胀后腐蚀的过程称为闭运算(Closing Operation)，闭运算能够排除小型黑洞(黑色区域)
 3、形态学梯度（Morphological Gradient）为膨胀图与腐蚀图之差，对二值图像进行这一操作可以将团块（blob）的边缘突出出来。我们可以用形态学梯度来保留物体的边缘轮廓
 4、顶帽运算（Top Hat）又常常被译为”礼帽“运算。为原图像与上文刚刚介绍的“开运算“的结果图之差，顶帽运算往往用来分离比邻近点亮一些的斑块。当一幅图像具有大幅的背景的时候，而微小物品比较有规律的情况下，可以使用顶帽运算进行背景提取。
 5、黑帽（Black Hat）运算为”闭运算“的结果图与原图像之差，黑帽运算用来分离比邻近点暗一些的斑块
 */

-(void)morphologyExTest{
    //这里是用了block的多参数适配方案，精简了代码，查看SlidersViewCell中的代码，即可理解
    
    void (^morphologyExBlock)(CGFloat,NSString*) = ^(CGFloat progress,NSString* titleStr){
//        DebugLog(@"progress%f---testStr:%@",progress, titleStr);
        
        cv::Mat sourceImg,dstImg;
        UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
        
        int dealType = cv::MORPH_ERODE;
        if ([titleStr isEqualToString:@"腐蚀"]) {
            dealType = cv::MORPH_ERODE;
        }else if ([titleStr isEqualToString:@"膨胀"]) {
            dealType = cv::MORPH_DILATE;
        }else if ([titleStr isEqualToString:@"开运算"]) {
            dealType = cv::MORPH_OPEN;
        }else if ([titleStr isEqualToString:@"闭运算"]) {
            dealType = cv::MORPH_CLOSE;
        }else if ([titleStr isEqualToString:@"形态学梯度"]) {
            dealType = cv::MORPH_GRADIENT;
        }else if ([titleStr isEqualToString:@"顶帽运算"]) {
            dealType = cv::MORPH_TOPHAT;
        }else if ([titleStr isEqualToString:@"黑帽运算"]) {
            dealType = cv::MORPH_BLACKHAT;
        }else if ([titleStr isEqualToString:@"击中击不中运算"]) {//只支持CV_8UC1类型的二值图像，即灰度图
            cv::cvtColor(sourceImg, sourceImg, CV_BGR2GRAY);
            dealType = cv::MORPH_HITMISS;
        }else{
            dealType = cv::MORPH_ERODE;
        }
        
        cv::Mat element = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(1+floor(progress*10)*2,1+floor(progress*10)*2));//自定义核，关于核的设置，需要了解原理
        cv::morphologyEx(sourceImg,dstImg, dealType, element);
        [_resultImg setImage:MatToUIImage(dstImg)];
    };
    
    [SlidersView showSlidersViewWithBlocks:@[
                                             @{@"callback":morphologyExBlock,@"title":@"腐蚀"},
                                             @{@"callback":morphologyExBlock,@"title":@"膨胀"},
                                             @{@"callback":morphologyExBlock,@"title":@"开运算"},
                                             @{@"callback":morphologyExBlock,@"title":@"闭运算"},
                                             @{@"callback":morphologyExBlock,@"title":@"击中击不中运算"},
                                             @{@"callback":morphologyExBlock,@"title":@"形态学梯度"},//后面三个显示不出来图片，不知为啥
                                             @{@"callback":morphologyExBlock,@"title":@"顶帽运算"},
                                             @{@"callback":morphologyExBlock,@"title":@"黑帽运算"}
                                             ] OtherParms:@{@"parentView":self.view}];
}



//膨胀腐蚀是基本形态学处理，形态学的高级形态，往往都是建立在腐蚀和膨胀这两个基本操作之上的
-(void)dilateAndErode{
    WeakSelf;
    
    void (^dilateBlock)(CGFloat) = ^(CGFloat progress){
        [weakSelf dilate:1+floor(progress*10)*2];//size必须大于1
    };
    void (^erodeBlock)(CGFloat) = ^(CGFloat progress){
        [weakSelf erode:1+floor(progress*10)*2];//size必须大于1
    };
    [SlidersView showSlidersViewWithBlocks:@[
                                             @{@"callback":dilateBlock,@"title":@"膨胀"},
                                             @{@"callback":erodeBlock,@"title":@"腐蚀"}
                                             ] OtherParms:@{@"parentView":self.view}];
}

-(void)dilate:(CGFloat)size{
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    cv::Mat element = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(size,size));//自定义核，关于核的设置，需要了解原理
    cv::dilate(sourceImg, dstImg, element);
    [_resultImg setImage:MatToUIImage(dstImg)];
}

-(void)erode:(CGFloat)size{
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    cv::Mat element = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(size,size));//自定义核，关于核的设置，需要了解原理
    cv::erode(sourceImg, dstImg, element);
    [_resultImg setImage:MatToUIImage(dstImg)];
}

/*
    下面几个都是非线性滤波，代码很简单，重点理解原理：http://blog.csdn.net/poem_qianmo/article/details/23184547
 */
-(void)nolinearBlurTest{
    WeakSelf;
    
    void (^medianBlurBlock)(CGFloat) = ^(CGFloat progress){
        [weakSelf medianBlur:3+floor(progress*5)*2];//size必须大于1的奇数
    };
    void (^bilateralFilterBlock)(CGFloat) = ^(CGFloat progress){
        [weakSelf bilateralFilter:1+progress*50];//size必须大于1
    };
    
    [SlidersView showSlidersViewWithBlocks:@[
                                             @{@"callback":medianBlurBlock,@"title":@"中值滤波"},
                                             @{@"callback":bilateralFilterBlock,@"title":@"双边滤波"}
                                             ] OtherParms:@{@"parentView":self.view}];
}

-(void)medianBlur:(CGFloat)size{
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    cv::medianBlur(sourceImg, dstImg, size);
    [_resultImg setImage:MatToUIImage(dstImg)];
    /*
     第三个参数，int类型的ksize，孔径的线性尺寸（aperture linear size），注意这个参数必须是大于1的奇数，比如：3，5，7，9 ...
     */
}

-(void)bilateralFilter:(CGFloat)size{
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    cv::cvtColor(sourceImg,sourceImg,CV_BGR2RGB);//之前使用原图做‘双边滤波’，报错说只能处理1通道或三通道的图像，所以我就处理成三通道
    cv::bilateralFilter(sourceImg, dstImg, size, size*2, size/2);//处理之后图像偏蓝色，需要研究函数原理
    [_resultImg setImage:MatToUIImage(dstImg)];
    /*
     第三个参数，int类型的d，表示在过滤过程中每个像素邻域的直径。如果这个值我们设其为非正数，那么OpenCV会从第五个参数sigmaSpace来计算出它来。
     第四个参数，double类型的sigmaColor，颜色空间滤波器的sigma值。这个参数的值越大，就表明该像素邻域内有更宽广的颜色会被混合到一起，产生较大的半相等颜色区域。
     第五个参数，double类型的sigmaSpace坐标空间中滤波器的sigma值，坐标空间的标注方差。他的数值越大，意味着越远的像素会相互影响，从而使更大的区域足够相似的颜色获取相同的颜色。当d>0，d指定了邻域大小且与sigmaSpace无关。否则，d正比于sigmaSpace。
     */
}

/*
    下面几个都是线性滤波，代码很简单，重点理解原理：http://blog.csdn.net/poem_qianmo/article/details/22745559
 */
-(void)linearBlurTest{
    
    WeakSelf;
    
    void (^boxFilterBlock)(CGFloat) = ^(CGFloat progress){
        [weakSelf boxFilter:(progress+0.1)*10];//size必须大于1
    };
    void (^blurBlock)(CGFloat) = ^(CGFloat progress){
        [weakSelf blur:(progress+0.1)*10];//size必须大于1
    };
    void (^gaussianBlock)(CGFloat) = ^(CGFloat progress){
        [weakSelf gaussianBlur:1+floor(progress*5)*2];//size必须大于1，且为奇数
        /*
         ceil(x)返回不小于x的最小整数值（然后转换为double型）。
         floor(x)返回不大于x的最大整数值。
         round(x)返回x的四舍五入整数值。
         */
    };
    
    [SlidersView showSlidersViewWithBlocks:@[
                                             @{@"callback":boxFilterBlock,@"title":@"方框滤波"},
                                             @{@"callback":blurBlock,@"title":@"均值滤波"},
                                             @{@"callback":gaussianBlock,@"title":@"高斯模糊"}
                                             ] OtherParms:@{@"parentView":self.view}];
    
}
//高斯模糊
-(void)gaussianBlur:(CGFloat)size{
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    cv::GaussianBlur(sourceImg, dstImg, cv::Size(size,size), 0,0);
    [_resultImg setImage:MatToUIImage(dstImg)];
}
//均值滤波
-(void)blur:(CGFloat)size{
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    cv::blur(sourceImg, dstImg, cv::Size(size,size));
    [_resultImg setImage:MatToUIImage(dstImg)];
}
//方框滤波
-(void)boxFilter:(CGFloat)size{
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    cv::boxFilter(sourceImg, dstImg, -1, cv::Size(size,size));
    [_resultImg setImage:MatToUIImage(dstImg)];
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
                dstImg.at<cv::Vec3b>(y,x)[c]= cv::saturate_cast<uchar>( (contrast*3)*(sourceImg.at<cv::Vec3b>(y,x)[c] ) + bright*255);
            }
        }
    }
    
    [_resultImg setImage:MatToUIImage(dstImg)];
    
    /*
     0、原理就是根据以下公式来更改像素值：g(i,j)=a*f(i,j)+b
     （1）参数f(x)表示源图像像素。
     （2）参数g(x) 表示输出图像像素。
     （3）参数a（需要满足a>0）被称为增益（gain），常常被用来控制图像的对比度。
     （4）参数b通常被称为偏置（bias），常常被用来控制图像的亮度。
     （5）亮度和对比度只是用来调整图像的概念，图像自身并没有亮度、对比度的概念，当让图像有个平均亮度，看字眼就知道是什么意思了。所以我可以说，图像就是不同亮度的像素组成。
     1、为了访问图像的每一个像素，我们使用这样的语法： image.at<Vec3b>(y,x)[c]。其中，y是像素所在的行， x是像素所在的列， c是R、G、B（对应0、1、2）其中之一。
     2、因为我们的运算结果可能超出像素取值范围（溢出），还可能是非整数（如果是浮点数的话），所以我们要用saturate_cast对结果进行转换，以确保它为有效值。
     3、这里的a也就是对比度，一般为了观察的效果，取值为0.0到3.0的浮点值，这里乘以3表示原像素值要增大为三倍，对比度加强，超过255即为白色
     4、亮度最大为255，再大也没用
     */
    
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
