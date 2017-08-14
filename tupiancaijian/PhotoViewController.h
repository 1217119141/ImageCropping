//
//  PhotoViewController.h
//  tupiancaijian
//
//  Created by iOS开发 on 17/6/27.
//  Copyright © 2017年 iOS开发. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PassImageDelegate.h"


@interface PhotoViewController : UIViewController

@property (nonatomic, assign) id<PassImageDelegate> delegate;
@property (nonatomic, strong) UIImage *image;

/**
 *  图片裁剪界面初始化
 *
 *  @param originalImage 需要裁剪的图片
 *  @param cropFrame  裁剪框的size 目前裁剪框的宽度为屏幕宽度
 *
 *  @return <#return value description#>
 */

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame;

@end
