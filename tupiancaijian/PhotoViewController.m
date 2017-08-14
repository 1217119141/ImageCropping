//
//  PhotoViewController.m
//  tupiancaijian
//
//  Created by iOS开发 on 17/6/27.
//  Copyright © 2017年 iOS开发. All rights reserved.
//

#import "PhotoViewController.h"
#import "UIImage+FitInSize.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


#define SCREENWIDTH   [UIScreen mainScreen].bounds.size.width

@interface PhotoViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIImage *inputImage; //输入Image
@property (nonatomic,strong) UIImageView *imgView; //显示图片
@property (nonatomic,assign) CGRect cropRect; //裁剪的rect
@property (nonatomic,retain) UIView *cropperView; //裁剪边框
@property (nonatomic,assign) double imageScale; //裁剪与实际图片比例
@property (nonatomic, retain) UIView *overlayView; //覆盖的黑色透明遮罩
@property (nonatomic,assign) double translateX;
@property (nonatomic,assign) double translateY;
@end

@implementation PhotoViewController

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame{
    self = [super init];
    if (self) {
        _translateX =0;
        _translateY =0;
        self.cropRect = cropFrame;
        self.inputImage = originalImage;
        _imageScale = cropFrame.size.width/self.inputImage.size.width;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
     [self initView];
    
    //添加导航栏和完成按钮
    UINavigationBar *naviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    [self.view addSubview:naviBar];
    
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"图片裁剪"];
    [naviBar pushNavigationItem:naviItem animated:YES];
    
    //保存按钮
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(saveButton)];
    naviItem.rightBarButtonItem = doneItem;
    
    //比例按钮
    UIBarButtonItem *proportionItem = [[UIBarButtonItem alloc] initWithTitle:@"比例" style:UIBarButtonItemStylePlain target:self action:@selector(proportionButton)];
    naviItem.leftBarButtonItem = proportionItem;
    
  
}
- (void)initView{
    
    CGFloat oriWidth = self.cropRect.size.width;
    CGFloat oriHeight = self.inputImage.size.height * (oriWidth / self.inputImage.size.width);
    CGFloat oriX = self.cropRect.origin.x + (self.cropRect.size.width - oriWidth) / 2;
    CGFloat oriY = self.cropRect.origin.y + (self.cropRect.size.height - oriHeight) / 2;
    
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(oriX, oriY, oriWidth, oriHeight)];
    self.imgView.backgroundColor = [UIColor whiteColor];
    self.imgView.image = self.inputImage;
    [self.view addSubview:self.imgView];
    
    self.cropperView = [[UIView alloc] initWithFrame:self.cropRect];
    self.cropperView.backgroundColor = [UIColor clearColor];
    self.cropperView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cropperView.layer.borderWidth = 1.5;
    [self.view addSubview:self.cropperView];
    
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.alpha = 0.5f;
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.userInteractionEnabled = NO;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.overlayView];
    [self overlayClipping];
   
    [self setupGestureRecognizer];
    
}

-(void)proportionButton
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *proportion1 = [UIAlertAction actionWithTitle:@"正方形" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.cropperView.bounds = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH * 1);
        [self overlayClipping];
    }];
    UIAlertAction *proportion2 = [UIAlertAction actionWithTitle:@"2:3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageScale = 2./3.;
        self.cropperView.bounds = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH * 2./3.);
        [self overlayClipping];
    }];
    UIAlertAction *proportion3 = [UIAlertAction actionWithTitle:@"3:5" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageScale = 3./5.;
        self.cropperView.bounds = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH * 3./5.);
        [self overlayClipping];
    }];
    UIAlertAction *proportion4 = [UIAlertAction actionWithTitle:@"3:4" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageScale = 3./4.;
        self.cropperView.bounds = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH * 3./4.);
        [self overlayClipping];
    }];
    UIAlertAction *proportion5 = [UIAlertAction actionWithTitle:@"4:5" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageScale = 4./5.;
        self.cropperView.bounds = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH * 4./5.);
        [self overlayClipping];
    }];
    UIAlertAction *proportion6 = [UIAlertAction actionWithTitle:@"5:7" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageScale = 5./7.;
        self.cropperView.bounds = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH * 5./7.);
        [self overlayClipping];
    }];
    UIAlertAction *proportion7 = [UIAlertAction actionWithTitle:@"9:16" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.imageScale = 9./16.;
        self.cropperView.bounds = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH * 9./16.);
        [self overlayClipping];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:proportion1];
    [alertController addAction:proportion2];
    [alertController addAction:proportion3];
    [alertController addAction:proportion4];
    [alertController addAction:proportion5];
    [alertController addAction:proportion6];
    [alertController addAction:proportion7];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
//完成截取
-(void)saveButton
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(PassImageDelegate)]) {
        [self.delegate passImage:[self getCroppedImage]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) setupGestureRecognizer
{
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAction:)];
    [pinchGestureRecognizer setDelegate:self];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [panGestureRecognizer setDelegate:self];
    
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //默认为NO,这里设置为YES
    return YES;
}
- (void)zoomAction:(UIGestureRecognizer *)sender {
    
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    static CGFloat lastScale=1;
    
    if([sender state] == UIGestureRecognizerStateBegan) {
        lastScale =1;
    }
    
    if ([sender state] == UIGestureRecognizerStateChanged
        || [sender state] == UIGestureRecognizerStateEnded) {
        CGRect imgViewFrame = _imgView.frame;
        CGFloat minX,minY,maxX,maxY,imgViewMaxX,imgViewMaxY;
        minX= CGRectGetMinX(_cropRect);
        minY= CGRectGetMinY(_cropRect);
        maxX= CGRectGetMaxX(_cropRect);
        maxY= CGRectGetMaxY(_cropRect);
        
        CGFloat currentScale = [[self.imgView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
        const CGFloat kMaxScale = 3.0;
        CGFloat newScale = 1 -  (lastScale - factor);
        newScale = MIN(newScale, kMaxScale / currentScale);
        
        imgViewFrame.size.width = imgViewFrame.size.width * newScale;
        imgViewFrame.size.height = imgViewFrame.size.height * newScale;
        imgViewFrame.origin.x = self.imgView.center.x - imgViewFrame.size.width/2;
        imgViewFrame.origin.y = self.imgView.center.y - imgViewFrame.size.height/2;
        
        imgViewMaxX= CGRectGetMaxX(imgViewFrame);
        imgViewMaxY= CGRectGetMaxY(imgViewFrame);
        
        NSInteger collideState = 0;
        
        if(imgViewFrame.origin.x >= minX)
        {
            collideState = 1;
        }
        else if(imgViewFrame.origin.y >= minY)
        {
            collideState = 2;
        }
        else if(imgViewMaxX <= maxX)
        {
            collideState = 3;
        }
        else if(imgViewMaxY <= maxY)
        {
            collideState = 4;
        }
        
        if(collideState >0)
        {
            
            if(lastScale - factor <= 0)
            {
                lastScale = factor;
                CGAffineTransform transformN = CGAffineTransformScale(self.imgView.transform, newScale, newScale);
                self.imgView.transform = transformN;
            }
            else
            {
                lastScale = factor;
                
                CGPoint newcenter = _imgView.center;
                
                if(collideState ==1 || collideState ==3)
                {
                    newcenter.x = _cropperView.center.x;
                }
                else if(collideState ==2 || collideState ==4)
                {
                    newcenter.y = _cropperView.center.y;
                }
                
                [UIView animateWithDuration:0.5f animations:^(void) {
                    
                    self.imgView.center = newcenter;
                    [sender reset];
                    
                } ];
                
            }
            
        }
        else
        {
            CGAffineTransform transformN = CGAffineTransformScale(self.imgView.transform, newScale, newScale);
            self.imgView.transform = transformN;
            lastScale = factor;
        }
        
    }
    
}
- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.cropperView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(
                                        self.cropperView.frame.origin.x + self.cropperView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.cropperView.frame.origin.x - self.cropperView.frame.size.width,
                                        self.overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.view.frame.size.width,
                                        self.cropperView.frame.origin.y));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.cropperView.frame.origin.y + self.cropperView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.cropperView.frame.origin.y + self.cropperView.frame.size.height));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}
- (void)panAction:(UIPanGestureRecognizer *)gesture {
    
    static CGPoint prevLoc;
    CGPoint location = [gesture locationInView:self.view];
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        prevLoc = location;
    }
    
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded))
    {
        
        CGFloat minX,minY,maxX,maxY,imgViewMaxX,imgViewMaxY;
        
        _translateX =  (location.x - prevLoc.x);
        _translateY =  (location.y - prevLoc.y);
        
        CGPoint center = self.imgView.center;
        minX= CGRectGetMinX(self.cropperView.frame);
        minY= CGRectGetMinY(self.cropperView.frame);
        maxX= CGRectGetMaxX(self.cropperView.frame);
        maxY= CGRectGetMaxY(self.cropperView.frame);
        
        center.x =center.x +_translateX;
        center.y = center.y +_translateY;
        
        imgViewMaxX= center.x + _imgView.frame.size.width/2;
        imgViewMaxY= center.y+ _imgView.frame.size.height/2;
        
        if(  (center.x - (_imgView.frame.size.width/2) ) >= minX)
        {
            center.x = minX + (_imgView.frame.size.width/2) ;
        }
        if( center.y - (_imgView.frame.size.height/2) >= minY)
        {
            center.y = minY + (_imgView.frame.size.height/2) ;
        }
        if(imgViewMaxX <= maxX)
        {
            center.x = maxX - (_imgView.frame.size.width/2);
        }
        if(imgViewMaxY <= maxY)
        {
            center.y = maxY - (_imgView.frame.size.height/2);
        }
        
        self.imgView.center = center;
        prevLoc = location;
    }
}



//获得裁剪图片
- (UIImage*) getCroppedImage {
    
    double zoomScale = [[self.imgView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
    double rotationZ = [[self.imgView.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    
    CGPoint cropperViewOrigin = CGPointMake( (_cropperView.frame.origin.x - _imgView.frame.origin.x)  *1/zoomScale ,
                                            ( _cropperView.frame.origin.y - _imgView.frame.origin.y ) * 1/zoomScale
                                            );
    CGSize cropperViewSize = CGSizeMake(_cropperView.frame.size.width * (1/zoomScale) ,_cropperView.frame.size.height * (1/zoomScale));
    
    CGRect CropinView = CGRectMake(cropperViewOrigin.x, cropperViewOrigin.y, cropperViewSize.width  , cropperViewSize.height);
    
    CGSize CropinViewSize = CGSizeMake((CropinView.size.width*(1/_imageScale)),(CropinView.size.height*(1/_imageScale)));
    
    
    if((NSInteger)CropinViewSize.width % 2 == 1)
    {
        CropinViewSize.width = ceil(CropinViewSize.width);
    }
    if((NSInteger)CropinViewSize.height % 2 == 1)
    {
        CropinViewSize.height = ceil(CropinViewSize.height);
    }
    
    CGRect CropRectinImage = CGRectMake((NSInteger)(CropinView.origin.x * (1/_imageScale)) ,(NSInteger)( CropinView.origin.y * (1/_imageScale)), (NSInteger)CropinViewSize.width,(NSInteger)CropinViewSize.height);
    
    UIImage *rotInputImage = [[_inputImage fixOrientation] imageRotatedByRadians:rotationZ];
    UIImage *newImage = [rotInputImage cropImage:CropRectinImage];
    
    if(newImage.size.width != self.cropRect.size.width)
    {
        newImage = [newImage resizedImageToFitInSize:self.cropRect.size scaleIfSmaller:YES];
    }
    
    return newImage;
}

//保存图片
- (BOOL) saveCroppedImage:(NSString *) path {
    
    return [UIImagePNGRepresentation([self getCroppedImage]) writeToFile:path atomically:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
