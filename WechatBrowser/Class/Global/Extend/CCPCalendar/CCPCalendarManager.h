//
//  CCPCalendarManager.h
//
//  Created by Ceair on 17/5/25.
//  Copyright © 2017年 ccp. All rights reserved.
//

/*
[CCPCalendarManager showMutil:^(NSArray *stArr) {
	[stArr enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		NSLog(@"obj.ccpDate---%@",[obj valueForKey:@"ccpDate"]);
		NSLog(@"obj.week---%@",[obj valueForKey:@"week"]);
	}];
}];
[CCPCalendarManager showSignalPast:^(NSArray *stArr) {
	[stArr enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		NSLog(@"obj.ccpDate---%@",[obj valueForKey:@"ccpDate"]);
		NSLog(@"obj.week---%@",[obj valueForKey:@"week"]);
	}];
}];
*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UILabel+CCPLabel.h"
#import "CCPCalendarView.h"

#define main_width  [UIScreen mainScreen].bounds.size.width
#define main_height [UIScreen mainScreen].bounds.size.height
#define main_bounds [UIScreen mainScreen].bounds
#define rgba(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/1.0]

//相对iphone6布局
#define scale_w main_width / 375.0
#define scale_h main_height / 667.0

/*
 * 日历选择类型
 * 0: 单选
 * 1: 双选 范围选择
 * 2: 单选多个
 */
typedef NS_ENUM(NSInteger, CCPCalendarSelectType) {
    selectTypeSingle = 0,
	selectTypeMultiple,
	selectTypeSingleMultiple,
};

@class CCPCalendarView;

//关闭
typedef void(^closeBlock)(void);
//清除
typedef void(^cleanBlock)(void);
//点击日期
typedef void(^clickBlock)(UIButton *btn);
//选择完成
typedef void(^completeBlock)(NSArray <__kindof NSObject *> *stArr);

@interface CCPCalendarManager : NSObject
//日历
@property (nonatomic,strong) CCPCalendarView *cal;
//背景色,不设置即使用背景图
@property (nonatomic,strong) UIColor *backgroundColor;
//今天字体颜色
@property (nonatomic,strong) UIColor *todayTextColor;
//默认字体颜色
@property (nonatomic,strong) UIColor *normalTextColor;
//无法点击的颜色
@property (nonatomic,strong) UIColor *disableTextColor;
//字体选中颜色
@property (nonatomic,strong) UIColor *selectedTextColor;
//默认背景颜色
@property (nonatomic,strong) UIColor *normalBgColor;
//选中背景颜色
@property (nonatomic,strong) UIColor *selectedBgColor;
//选中状态(点击 未放开) 图片名
@property (nonatomic,strong) NSString *touchImg;
//选中状态(点击 放开) 图片名
@property (nonatomic,strong) NSString *touchedImg;
//日历创建的日期
@property (nonatomic,strong) NSDate *createDate;
//开始标题
@property (nonatomic,strong) NSString *startTitle;
//结束标题
@property (nonatomic,strong) NSString *endTitle;
//是否需要显示生成日期之前的日历
@property (nonatomic,assign) BOOL isShowPast;
//日历类型 单选 多选 单选多个
@property (nonatomic,assign) CCPCalendarSelectType selectType;
//关闭block
@property (copy,nonatomic) closeBlock close;
//清除block
@property (copy) cleanBlock clean;
//点击日期按钮block
@property (copy) clickBlock click;
//结束选择block
@property (copy) completeBlock complete;
//滚动到指定创建日历的日期位置
@property (copy) cleanBlock scrToCreateDate;
//仅在Multiple时保存 选择开始标记
@property (nonatomic,assign) NSInteger startTag;
//仅在Multiple时保存 选择结束标记
@property (nonatomic,assign) NSInteger endTag;
//此属性用于一段日历的生成 此属性为一段日历的结束日期
@property (nonatomic,strong) NSDate *createEndDate;
//选中的日期
@property (nonatomic,strong) NSMutableArray *selectArr;
//选择的日期按钮
@property (nonatomic,strong) NSMutableArray *selectBtns;
//可用日期范围, 第一个元素为开始 第二个元素为结束 默认为空
@property (nonatomic,strong) NSArray<NSDate *> *dateEnableRange;
//日历创建时停留的位置
@property (nonatomic,strong) NSDate *postionDate;
//已选日期 默认为空
@property (nonatomic,strong) NSArray<NSString *> *selectedDate;

//单选有过去
+ (void)showSinglePast:(completeBlock)complete;
//多选有过去
+ (void)showMultiplePast:(completeBlock)complete;
//单选多个有过去
+ (void)showSingleMultiplePast:(completeBlock)complete;
//单选没过去
+ (void)showSingle:(completeBlock)complete;
//多选没过去
+ (void)showMultiple:(completeBlock)complete;
//单选多个没过去
+ (void)showSingleMultiple:(completeBlock)complete;

//单选有过去
- (void)showSinglePast:(completeBlock)complete;
//多选有过去
- (void)showMultiplePast:(completeBlock)complete;
//单选多多个有过去
- (void)showSingleMultiplePast:(completeBlock)complete;
//单选没过去
- (void)showSingle:(completeBlock)complete;
//多选没过去
- (void)showMultiple:(completeBlock)complete;
//单选多个没过去
- (void)showSingleMultiple:(completeBlock)complete;

@end
