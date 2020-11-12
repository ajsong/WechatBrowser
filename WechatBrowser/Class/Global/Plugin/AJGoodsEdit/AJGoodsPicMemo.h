//
//  AJGoodsPicMemo.h
//
//  Created by ajsong on 2017/3/15.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AJGoodsPicMemoDelegate<NSObject>
@optional
- (void)AJGoodsPicMemoWithData:(NSDictionary*)data;
@end

@class MJPhotosBrowser;

@interface AJGoodsPicMemo : UIViewController
@property (nonatomic,weak) id<AJGoodsPicMemoDelegate> delegate;
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,strong) MJPhotosBrowser *browser;
@property (nonatomic,strong) UIColor *textColor;
@end
