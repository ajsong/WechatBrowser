//
//  MJPhoto.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <Foundation/Foundation.h>

#define MJPhotoAnimateDuration 0.4

@interface MJPhotos : NSObject
@property (nonatomic, strong) NSString *url; // 图片网址
@property (nonatomic, strong) UIImage *image; // 完整的图片
@property (nonatomic, strong) UIImageView *srcImageView; // 来源imageView
@property (nonatomic, strong) UIImage *srcImage; // 来源imageView的image
@property (nonatomic, strong) NSString *title; //图片标题
@property (nonatomic, strong) NSString *content; //图片描述

@property (nonatomic, assign) BOOL save; // 能否保存到相册
@property (nonatomic, assign) int index; // 索引
@property (nonatomic, assign) BOOL firstShow; // 是否点击的第一张
@end