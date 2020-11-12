//
//  UILabel+RichText.h
//
//  Created by ajsong on 2019/4/4.
//  Copyright © 2019 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RichTextDelegate <NSObject>
@optional
/**
 *  RichTextDelegate
 *
 *  @param string  点击的字符串
 *  @param range   点击的字符串range
 *  @param index   点击的字符在数组中的index
 */
- (void)didClickString:(NSString *)string range:(NSRange)range index:(NSInteger)index;
@end

@interface UILabel (RichText)

/**
 *  是否打开点击效果，默认是打开
 */
@property (nonatomic, assign) BOOL enabledClickEffect;

/**
 *  点击效果颜色 默认lightGrayColor
 */
@property (nonatomic, strong) UIColor *clickEffectColor;

/**
 *  给文本添加Block点击事件回调
 *
 *  @param strings  需要添加的字符串数组
 *  @param clickAction 点击事件回调
 */
- (void)clickWithStrings:(NSArray <NSString *> *)strings action:(void (^) (NSString *string, NSRange range, NSInteger index))action;

/**
 *  给文本添加点击事件delegate回调
 *
 *  @param strings  需要添加的字符串数组
 *  @param delegate 富文本代理
 */
- (void)clickWithStrings:(NSArray <NSString *> *)strings delegate:(id <RichTextDelegate> )delegate;

@end
