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
                @{@"editName":@"pyramidTest",@"editBrief":@"图像金字塔"},
                @{@"editName":@"findEdge",@"editBrief":@"边缘检测"},
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

//图像金字塔：高斯金字塔、拉普拉斯金字塔与图片尺寸缩放
/*
 1、基本概念：
 （1）显示分辨率（屏幕分辨率）是屏幕图像的精密度，是指显示器所能显示的像素有多少
 （2）图像分辨率则是单位英寸中所包含的像素点数，其定义更趋近于分辨率本身的定义
 （3）高斯金字塔(Gaussianpyramid): 用来向下采样（逐渐丢失图像信息，图像变小），主要的图像金字塔
 （4）拉普拉斯金字塔(Laplacianpyramid): 用来从金字塔低层图像重建上层未采样图像，在数字图像处理中也即是预测残差，可以对图像进行最大程度的还原，配合高斯金字塔一起使用
 （5）resize函数：专门用于放大缩小的函数
 */
-(void)pyramidTest{
    WeakSelf;
    
    void (^resizeBlock)(CGFloat,NSString*) = ^(CGFloat progress,NSString* titleStr){
        [weakSelf resize:1+floor(progress*10) withTitle:titleStr];//size必须大于1
    };
    
    [SlidersView showSlidersViewWithBlocks:@[
                                             @{@"callback":resizeBlock,@"title":@"resize"},
                                             @{@"callback":resizeBlock,@"title":@"pyrUp"},
                                             @{@"callback":resizeBlock,@"title":@"pyrDown"}
                                             ] OtherParms:@{@"parentView":self.view}];
}

-(void)resize:(CGFloat)size withTitle:(NSString*)titleStr{
    DebugLog(@"size---%.2f",size);
    
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    if ([titleStr isEqualToString:@"resize"]) {
        // 【1】创建与src同类型和大小的矩阵(dst)
        dstImg.cv::Mat::zeros( sourceImg.rows/size ,sourceImg.cols/size, CV_8UC3);
        cv::resize(sourceImg, dstImg, cv::Size(),1/size,1/size);
        [_resultImg setImage:MatToUIImage(dstImg)];
        return;
    }else if ([titleStr isEqualToString:@"pyrUp"]){
        for (int i=0; i<3; i++) {//这里循环次数不能超过2，不知与手机或图片本身有关系没
            cv::pyrUp(sourceImg, sourceImg,cv::Size(sourceImg.cols*2,sourceImg.rows*2));//这两处对参数的设置有要求，除了2还没试出其它可用参数，也懒得看了
        }
        [_resultImg setImage:MatToUIImage(sourceImg)];
        DebugLog(@"pyrUpover");
        return;
    }else if ([titleStr isEqualToString:@"pyrDown"]){
        for (int i=0; i<size; i++) {
            cv::pyrDown(sourceImg, sourceImg,cv::Size(sourceImg.cols/2,sourceImg.rows/2));//这两处对参数的设置有要求，除了2还没试出其它可用参数，也懒得看了
        }
        [_resultImg setImage:MatToUIImage(sourceImg)];
        DebugLog(@"pyrDownover");
        return;
    }
    
}


//边缘检测:Canny算子,Sobel算子,Laplace算子,Scharr滤波器
/*
 边缘检测的一般步骤:
 1）滤波：边缘检测的算法主要是基于图像强度的一阶和二阶导数，但导数通常对噪声很敏感，因此必须采用滤波器来改善与噪声有关的边缘检测器的性能。常见的滤波方法主要有高斯滤波，即采用离散化的高斯函数产生一组归一化的高斯核（具体见“高斯滤波原理及其编程离散化实现方法”一文），然后基于高斯核函数对图像灰度矩阵的每一点进行加权求和（具体程序实现见下文）。
 2）增强：增强边缘的基础是确定图像各点邻域强度的变化值。增强算法可以将图像灰度点邻域强度值有显著变化的点凸显出来。在具体编程实现时，可通过计算梯度幅值来确定。
 3）检测：经过增强的图像，往往邻域中有很多点的梯度值比较大，而在特定的应用中，这些点并不是我们要找的边缘点，所以应该采用某种方法来对这些点进行取舍。实际工程中，常用的方法是通过阈值化方法来检测。
 */
-(void)findEdge{
    WeakSelf;
    
    void (^candy1Block)(CGFloat) = ^(CGFloat progress){
        [weakSelf candy1:3+floor(progress*100)];//size必须大于1
    };
    void (^candy2Block)(CGFloat) = ^(CGFloat progress){
        [weakSelf candy2:3+floor(progress*100)];//size必须大于1
    };
    void (^candy3Block)(CGFloat) = ^(CGFloat progress){
        [weakSelf candy3:3+floor(progress*100)];//size必须大于1
    };
    void (^sobelBlock)(CGFloat,NSString*) = ^(CGFloat progress,NSString* titleStr){
        [weakSelf sobel:1+floor(progress*2) withTitle:titleStr];//size必须大于1
    };
    void (^laplaceBlock)(CGFloat) = ^(CGFloat progress){
        [weakSelf laplace:1+floor(progress*5)];//size必须大于1
    };
    void (^scharrBlock)(CGFloat,NSString*) = ^(CGFloat progress,NSString* titleStr){
        [weakSelf scharr:3+floor(progress*10) withTitle:titleStr];//size必须大于1
    };
    [SlidersView showSlidersViewWithBlocks:@[
                                             @{@"callback":candy1Block,@"title":@"Canny普通"},
                                             @{@"callback":candy2Block,@"title":@"Canny中级"},
                                             @{@"callback":candy3Block,@"title":@"Canny高级"},
                                             @{@"callback":sobelBlock,@"title":@"Sobel1"},
                                             @{@"callback":sobelBlock,@"title":@"Sobel2"},
                                             @{@"callback":sobelBlock,@"title":@"Sobel3"},
                                             @{@"callback":laplaceBlock,@"title":@"Laplace"},
                                             @{@"callback":scharrBlock,@"title":@"Scharr1"},
                                             @{@"callback":scharrBlock,@"title":@"Scharr2"},
                                             @{@"callback":scharrBlock,@"title":@"Scharr3"}
                                             ] OtherParms:@{@"parentView":self.view}];
}

-(void)candy1:(CGFloat)size{
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    cv::Canny(sourceImg, dstImg, 2*size,size,3);
    [_resultImg setImage:MatToUIImage(dstImg)];
}

-(void)candy2:(CGFloat)size{
    cv::Mat sourceImg,dstImg;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    cv::cvtColor(sourceImg, sourceImg, CV_BGR2GRAY);
    cv::blur(sourceImg, sourceImg, cv::Size(3,3));
    cv::Canny(sourceImg, dstImg, 2*size,size,3);
    [_resultImg setImage:MatToUIImage(dstImg)];
}

-(void)candy3:(CGFloat)size{
    cv::Mat sourceImg,dstImg,gray,edge;
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    // 【1】创建与src同类型和大小的矩阵(dst)
    dstImg.cv::Mat::zeros( sourceImg.size(), sourceImg.type());
    // 【2】将原图像转换为灰度图像
    cv::cvtColor(sourceImg, gray, CV_BGR2GRAY);
    // 【3】先用使用 3x3内核来降噪
    cv::blur(gray, edge, cv::Size(3,3));
    // 【4】运行Canny算子
    cv::Canny(edge, edge, 2*size,size,3);
    //【5】将g_dstImage内的所有元素设置为0
    dstImg = cv::Scalar::all(0);
    //【6】使用Canny算子输出的边缘图edge作为掩码，来将原图g_srcImage拷到目标图g_dstImage中
    sourceImg.copyTo(dstImg,edge);
    [_resultImg setImage:MatToUIImage(dstImg)];
}

-(void)sobel:(CGFloat)size withTitle:(NSString*)titleStr{
    cv::Mat sourceImg,grad_x, grad_y,abs_grad_x, abs_grad_y,dst;
    
    //【1】载入原始图
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    
    //【2】求 X方向梯度
    cv::Sobel( sourceImg, grad_x, CV_16S, size, 0, size*2+1, 1, 1, cv::BORDER_DEFAULT );
    cv::convertScaleAbs( grad_x, abs_grad_x );
    if ([titleStr isEqualToString:@"Sobel1"]) {
        [_resultImg setImage:MatToUIImage(grad_x)];//执行cv::convertScaleAbs后，全白，不知原因
        return;
    }
    
    //【3】求Y方向梯度
    cv::Sobel( sourceImg, grad_y, CV_16S, 0, size, size*2+1, 1, 1, cv::BORDER_DEFAULT );
    cv::convertScaleAbs( grad_y, abs_grad_y );
    if ([titleStr isEqualToString:@"Sobel2"]) {
        [_resultImg setImage:MatToUIImage(grad_y)];
        return;
    }
    
    //【4】合并梯度(近似)
    cv::addWeighted( grad_x, 0.5, grad_y, 0.5, 0, dst );
    [_resultImg setImage:MatToUIImage(dst)];
    
    /*Sobel函数：
     第四个参数，int类型dx，x 方向上的差分阶数。
     第五个参数，int类型dy，y方向上的差分阶数。
     第六个参数，int类型ksize，有默认值3，表示Sobel核的大小;必须取1，3，5或7。
     */
    
}

-(void)laplace:(CGFloat)size{
    /*
     第三个参数，int类型的ddept，目标图像的深度。
     第四个参数，int类型的ksize，用于计算二阶导数的滤波器的孔径尺寸，大小必须为正奇数，且有默认值1。
     第五个参数，double类型的scale，计算拉普拉斯值的时候可选的比例因子，有默认值1。
     第六个参数，double类型的delta，表示在结果存入目标图（第二个参数dst）之前可选的delta值，有默认值0。
     */
    
    //【0】变量的定义
    cv::Mat sourceImg,dstImg,gray,abs_dst;
    
    //【1】载入原始图
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    
    //【3】使用高斯滤波消除噪声
    GaussianBlur( sourceImg, sourceImg, cv::Size(3,3), 0, 0, cv::BORDER_DEFAULT );
    
    //【4】转换为灰度图
    cvtColor( sourceImg, gray, CV_RGB2GRAY );
    
    //【5】使用Laplace函数,输入图像必须为灰度图
    Laplacian( gray, dstImg, CV_16S, 1+size*2, 1, 0, cv::BORDER_DEFAULT );
    
    //【6】计算绝对值，并将结果转换成8位
    convertScaleAbs( dstImg, abs_dst );
    
    [_resultImg setImage:MatToUIImage(abs_dst)];//这次必须执行convertScaleAbs，否则是一张白图，没搞明白
    
}

//主要是配合Sobel算子的运算而存在的,一个万年备胎
-(void)scharr:(CGFloat)size withTitle:(NSString*)titleStr{
    cv::Mat sourceImg,grad_x, grad_y,abs_grad_x, abs_grad_y,dst;
    
    //【1】载入原始图
    UIImageToMat([UIImage imageNamed:sourceImgName_],sourceImg);
    
    Scharr( sourceImg, grad_x, CV_16S, 1, 0, 1, 0, cv::BORDER_DEFAULT );
    convertScaleAbs( grad_x, abs_grad_x );
    if ([titleStr isEqualToString:@"scharr1"]) {
        [_resultImg setImage:MatToUIImage(grad_x)];//执行cv::convertScaleAbs后，全白，不知原因
        return;
    }
    
    //【4】求Y方向梯度
    Scharr( sourceImg, grad_y, CV_16S, 0, 1, 1, 0, cv::BORDER_DEFAULT );
    convertScaleAbs( grad_y, abs_grad_y );
    if ([titleStr isEqualToString:@"scharr2"]) {
        [_resultImg setImage:MatToUIImage(grad_y)];//执行cv::convertScaleAbs后，全白，不知原因
        return;
    }
    
    //【5】合并梯度(近似)
    addWeighted( grad_x, 0.5, grad_y, 0.5, 0, dst );
    [_resultImg setImage:MatToUIImage(dst)];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
