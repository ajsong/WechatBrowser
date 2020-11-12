//
//  JKNotifier.h
//
//  Created by Jakey on 15/5/21.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JKNotifierBar.h"

#define JKN_DISMISS_TIME 4

UIKIT_EXTERN NSString * const JKNotifierBarDismiss;

@interface JKNotifier : UIView

+ (JKNotifier*)shareInstance;

/**
 *  显示一个Notifer，需要手动点击关闭
 *
 *  @param note Notifer 内容
 *
 *  @return JKNotifierBar
 */
+ (JKNotifierBar*)show:(NSString*)note;

/**
 *  显示一个Notifer，需要手动点击关闭
 *
 *  @param note    Notifer 内容
 *  @param name Notifer 自定义APP名称 默认读取CFBundleName
 *
 *  @return JKNotifierBar
 */
+ (JKNotifierBar*)show:(NSString*)note name:(NSString*)name;

/**
 *  显示一个Notifer,4秒后自动关闭
 *
 *  @param note Notifer 内容
 *
 *  @return JKNotifierBar
 */
+ (JKNotifierBar*)showAuto:(NSString*)note;

/**
 *  显示一个Notifer,delay秒后自动关闭
 *
 *  @param note  Notifer 内容
 *  @param delay 自动关闭时间
 *
 *  @return JKNotifierBar
 */
+ (JKNotifierBar*)showAuto:(NSString *)note dismiss:(NSTimeInterval)delay;

/**
 *  显示一个Notifer,内容，名称，图标
 *
 *  @param note    Notifer 内容
 *  @param name APP名称
 *  @param icon APP图标
 *
 *  @return JKNotifierBar
 */
+ (JKNotifierBar*)showAuto:(NSString*)note name:(NSString*)name icon:(UIImage*)icon;

/**
 *  显示一个Notifer,内容，名称，图标，关闭时间
 *
 *  @param note    Notifer 内容
 *  @param name APP名称
 *  @param icon APP图标
 *  @param delay   自动关闭时间
 *
 *  @return JKNotifierBar
 */
+ (JKNotifierBar*)showAuto:(NSString*)note name:(NSString*)name icon:(UIImage*)icon dismiss:(NSTimeInterval)delay;

/**
 *  立即关闭所有Notifer
 */
+ (void)dismiss;

@end
