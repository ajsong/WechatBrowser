//
//  AJDateView.h
//
//  Created by ajsong on 2014-9-1.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AJDateView;
@protocol AJDateViewDelegate<NSObject>
@optional
- (void)AJDateView:(AJDateView*)dateView didSelectWithDate:(NSDate*)date year:(NSString*)year month:(NSString*)month;
- (void)AJDateView:(AJDateView*)dateView didSubmitWithDate:(NSDate*)date year:(NSString*)year month:(NSString*)month;
@end

@interface AJDateView : UIView
@property (nonatomic,weak) id<AJDateViewDelegate> delegate;
@property (nonatomic,strong) AJActionView *actionView;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *type; //时间类型, 如:y年m月d日h时n分
@property (nonatomic,strong) NSDate *date;
@property (nonatomic,strong) NSDate *minimumDate;
@property (nonatomic,strong) NSDate *maximumDate;
@property (nonatomic,strong) UIFont *textFont; //文字字体
@property (nonatomic,strong) UIColor *textColor; //文字颜色
@property (nonatomic,strong) UIColor *dateColor; //日期颜色
- (void)show;
- (void)close;
@end
