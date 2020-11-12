//
//  DXLoadImageTool.h
//  DXImagePickController
//
//  Created by simon on 16/7/1.
//  Copyright © 2016年 DINGXU. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHAsset;

@interface DXLoadImageTool : NSObject
//获取所有照片
+ (void)loadAllPhoto:(void(^)(NSArray *models))complete;
//通过PHAsset获取高清图
+ (void)getImageOfAsset:(PHAsset *)asset complection:(void (^)(UIImage *result))complection;
@end
