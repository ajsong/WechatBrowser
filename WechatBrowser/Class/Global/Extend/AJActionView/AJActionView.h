//
//  AJActionView.h
//
//  Created by ajsong on 15/9/14.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AJActionViewDelegate;

@interface UIPickerView (GlobalExtend)
- (UIColor *)separatorColor;
- (void)setSeparatorColor:(UIColor *)separatorColor;
@end

@interface AJActionView : UIView
@property (nonatomic,weak) id<AJActionViewDelegate> delegate;
@property (nonatomic,strong) UIView *mainView; //主容器
@property (nonatomic,strong) UIToolbar *barView; //磨砂背景
@property (nonatomic,strong) NSString *title; //标题
@property (nonatomic,strong) UIView *view; //显示内容
@property (nonatomic,strong) NSArray *buttons; //按钮数组, 不设置即默认只有一个确定按钮
@property (nonatomic,strong) NSArray *buttonColors; //按钮字体颜色, 对应按钮数组数量
@property (nonatomic,strong) UIColor *submitTextColor; //确定按钮文字颜色,默认蓝色
@property (nonatomic,strong) UIColor *cancelTextColor; //取消按钮文字颜色,默认蓝色
@property (nonatomic,strong) UIColor *cancelBackgroundColor; //取消按钮背景色,默认白色磨砂
@property (nonatomic,assign) CGFloat scale; //背景缩放
- (instancetype)initWithTitle:(NSString*)title view:(UIView*)view delegate:(id<AJActionViewDelegate>)delegate;
- (void)create;
- (void)show;
- (void)close;
@end

@protocol AJActionViewDelegate<NSObject>
@optional
- (void)AJActionViewWillShow:(AJActionView*)actionView;
- (void)AJActionViewDidSubmit:(AJActionView*)actionView;
- (void)AJActionViewDidClose:(AJActionView*)actionView;
- (void)AJActionView:(AJActionView*)actionView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
