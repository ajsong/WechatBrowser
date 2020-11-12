//
//  AJGoodsContent.h
//
//  Created by ajsong on 2017/3/16.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AJGoodsContentDelegate<NSObject>
@optional
- (void)AJGoodsContentWithImage:(UIImage*)image uploadComplete:(void (^)(NSString *url))complete;
- (void)AJGoodsContentWithData:(NSDictionary*)data;
@end

@interface AJGoodsContent : UIViewController
@property (nonatomic,weak) id<AJGoodsContentDelegate> delegate;
@property (nonatomic,strong) NSString *html;
@property (nonatomic,strong) UIColor *btnColor;
@property (nonatomic,assign) BOOL insertImage;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) NSString *upyunPath;
@property (nonatomic,strong) NSString *qiniuToken;
@property (nonatomic,strong) NSString *placeholder;
@property (nonatomic,strong) NSString *editorUrl;
@end
