//
//  ViewController.m
//  tupiancaijian
//
//  Created by iOS开发 on 17/6/27.
//  Copyright © 2017年 iOS开发. All rights reserved.
//

#import "ViewController.h"
#import "PhotoViewController.h"
#import "PassImageDelegate.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


typedef struct __attribute__((objc_boxable)){
    float width,height;
}QSCRsize;

@interface ViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PassImageDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PhotoViewController * PhotoView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 60, 40)];
    button.backgroundColor  = [UIColor blueColor];
    [button addTarget:self action:@selector(choseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 150, self.view.bounds.size.width, self.view.bounds.size.width)];
    [self.view addSubview:_imageView];
    
}

//弹出选项列表选择图片来源
- (void)choseButtonClicked:(id)sender {
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
        }else{
            NSLog(@"模拟器无法打开相机");
        }
        [self presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:camera];
    [alertController addAction:photo];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma 拍照选择照片协议方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    NSData *data;
    
    if ([mediaType isEqualToString:@"public.image"]){
        
        //切忌不可直接使用originImage，因为这是没有经过格式化的图片数据，可能会导致选择的图片颠倒或是失真等现象的发生，从UIImagePickerControllerOriginalImage中的Origin可以看出，很原始，哈哈
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSLog(@"%@",self);
        //图片压缩，因为原图都是很大的，不必要传原图
        UIImage *scaleImage = [self scaleImage:originImage toScale:0.3];
        
        //以下这两步都是比较耗时的操作，最好开一个HUD提示用户，这样体验会好些，不至于阻塞界面
        if (UIImagePNGRepresentation(scaleImage) == nil) {
            //将图片转换为JPG格式的二进制数据
            data = UIImageJPEGRepresentation(scaleImage, 1);
        } else {
            //将图片转换为PNG格式的二进制数据
            data = UIImagePNGRepresentation(scaleImage);
        }
        //将二进制数据生成UIImage
        UIImage *image = [UIImage imageWithData:data];
//        打印尺寸
        QSCRsize size = {image.size.width,image.size.height};
        NSValue *value = @(size);
        NSLog(@"%@",value);
        
        //将图片传递给截取界面进行截取并设置回调方法（协议）
        if (size.height >= size.width) {
            _PhotoView = [[PhotoViewController alloc] initWithImage:image cropFrame:CGRectMake(0, (ScreenHeight - ScreenWidth)/2 , ScreenWidth, ScreenWidth)];
        } else {
            _PhotoView = [[PhotoViewController alloc] initWithImage:image cropFrame:CGRectMake(0, (ScreenHeight - (ScreenWidth * size.height / size.width))/2 , ScreenWidth, ScreenWidth * size.height / size.width)];
        }
        _PhotoView.delegate = self;
        [picker pushViewController:_PhotoView animated:YES];
        
    }
}
- (void)passImage:(UIImage *)image{
    self.imageView.image = image;
}
#pragma mark- 缩放图片
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
