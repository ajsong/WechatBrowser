//
//  QiniuHelper.h
//
//  Created by ajsong on 2017/7/11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCQiniuUploadManager.h"

@interface QiniuHelper : NSObject
@property (nonatomic,strong) QNUploadManager *manager;
+ (QiniuHelper*)sharedHelper;
+ (void)UploadToQiniu:(NSData*)imageData imageName:(NSString*)imageName token:(NSString*)token completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion;
+ (void)UploadToQiniu:(NSData*)imageData imageName:(NSString*)imageName token:(NSString*)token progress:(void (^)(NSString *key, float percent))progress completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion;
@end
