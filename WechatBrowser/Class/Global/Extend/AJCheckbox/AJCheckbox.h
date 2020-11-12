//
//  AJCheckbox.h
//
//  Created by ajsong on 15/6/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

/*
AJCheckbox *box = [[AJCheckbox alloc]init];
box.delegate = self;
box.orderType = CheckboxOrderTypeRight;
box.type = CheckboxTypeCheckbox;
box.image = IMG(@"c-tick");
box.selectedImage = IMG(@"c-tick-x");
box.textColor = COLORTEXT;
box.font = FONT(14);
box.size = CGSizeMakeScale(@25, @25);
box.textWidth = SCREEN_WIDTH - 25 - 24;
box.textHeight = 54;
*/

#import <Foundation/Foundation.h>

@class AJCheckbox, AJCheckboxSubview;

typedef enum : NSInteger {
	CheckboxTypeRadio = 0,
	CheckboxTypeCheckbox,
} CheckboxType;

typedef enum : NSInteger {
	CheckboxOrderTypeLeft = 0,
	CheckboxOrderTypeRight,
} CheckboxOrderType;

typedef enum : NSInteger {
	CheckboxStatusUnselect = 0,
	CheckboxStatusSelect,
	CheckboxStatusAuto,
} CheckboxStatus;

typedef enum : NSInteger {
	CheckboxTagBox = 2987462,
	CheckboxTagLabel,
} CheckboxTag;

@protocol AJCheckboxDelegate<NSObject>
@optional
- (void)AJCheckbox:(AJCheckbox *)checkbox didSelectedView:(AJCheckboxSubview *)view status:(CheckboxStatus)status atIndex:(NSInteger)index;
- (void)AJCheckbox:(AJCheckbox *)checkbox selectedTexts:(NSMutableArray *)texts selectedIndexs:(NSMutableArray *)indexs selectedDatas:(NSMutableArray *)datas;
- (void)AJCheckbox:(AJCheckbox *)checkbox selectedViews:(NSArray *)selectedViews unselectedViews:(NSArray *)unselectedViews;
- (void)AJCheckbox:(AJCheckbox *)checkbox isSelectedAll:(BOOL)isSelectedAll;
@end

@interface AJCheckboxSubview : UIView
@property (nonatomic,strong) AJCheckbox *caller; //调用者
@property (nonatomic,strong) id data; //数据值
@property (nonatomic,strong) UIImageView *box; //选项框
@property (nonatomic,strong) UILabel *label; //标签
@property (nonatomic,strong) NSString *text; //标签文字
@property (nonatomic,assign) BOOL isSelected; //当前是否选中
@property (nonatomic,assign,getter=isDisabled) BOOL disabled; //禁用
@end

@interface AJCheckbox : NSObject
@property (nonatomic,weak) id<AJCheckboxDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *datas; //数据集
@property (nonatomic,strong) NSMutableArray *objects; //子元素
@property (nonatomic,strong) NSMutableArray *views; //选项框组
@property (nonatomic,strong) NSMutableArray *selectedViews; //已选中的选项框
@property (nonatomic,strong) NSMutableArray *unselectedViews; //未选中的选项框
@property (nonatomic,strong) NSMutableArray *selectedTexts; //已选中的选项框的标签
@property (nonatomic,strong) NSMutableArray *selectedIndexs; //已选中的选项框的索引
@property (nonatomic,strong) NSMutableArray *selectedDatas; //已选中的选项框的数据集
@property (nonatomic,assign) CheckboxType type; //选项框类型,默认CheckboxTypeRadio
@property (nonatomic,assign) CheckboxOrderType orderType; //选项框位置,默认CheckboxOrderTypeLeft
@property (nonatomic,assign) CGSize size; //选项框尺寸,默认30*30
@property (nonatomic,strong) UIImage *image; //选项框默认图
@property (nonatomic,strong) UIImage *selectedImage; //选项框选中图
@property (nonatomic,strong) UIImage *disabledImage; //选项框禁用图
@property (nonatomic,strong) UIColor *textColor; //标签文字默认颜色,默认COLORTEXT
@property (nonatomic,strong) UIColor *selectedTextColor; //选项选中文字颜色
@property (nonatomic,strong) UIColor *disabledTextColor; //选项禁用文字颜色
@property (nonatomic,assign) NSTextAlignment textAlignment; //标签文字对齐方式,默认NSTextAlignmentLeft
@property (nonatomic,assign) CGFloat borderWidth; //边框厚度
@property (nonatomic,strong) UIColor *borderColor; //边框默认颜色
@property (nonatomic,strong) UIColor *selectedBorderColor; //选项选中边框颜色
@property (nonatomic,strong) UIColor *disabledBorderColor; //选项禁用边框颜色
@property (nonatomic,strong) UIColor *backgroundColor; //选项的默认背景色(views内每个view)
@property (nonatomic,strong) UIColor *selectedBackgroundColor; //选项选中背景色
@property (nonatomic,strong) UIColor *disabledBackgroundColor; //选项禁用背景色
@property (nonatomic,assign) CGFloat cornerRadius; //选项的圆角
@property (nonatomic,assign) CGFloat textWidth; //标签宽度,不设定即自动宽度
@property (nonatomic,assign) CGFloat textHeight; //标签高度,不设定即按选项框尺寸的高度
@property (nonatomic,assign) CGFloat minWidth; //标签最小宽度
@property (nonatomic,assign) UIEdgeInsets padding; //标签padding,默认UIEdgeInsetsZero
@property (nonatomic,strong) UIFont *font; //标签字体,默认13
@property (nonatomic,assign) BOOL fontFit; //标签字体自动缩放(缩放字体以达到能尽量显示完整)
@property (nonatomic,assign) BOOL hiddenBox; //隐藏选项框
@property (nonatomic,assign) BOOL hiddenLabel; //隐藏标签文字
@property (nonatomic,assign) BOOL animateBox; //动画显示选中项的选项框,默认YES
@property (nonatomic,assign) BOOL animateView; //动画显示选中项(整个view),默认NO
@property (nonatomic,assign) BOOL unselected; //CheckboxTypeRadio时可反选取消,默认NO
@property (nonatomic,assign) NSInteger tag;

- (instancetype)initWithObjects:(NSArray*)objects type:(CheckboxType)type size:(CGSize)size image:(UIImage*)image selectedImage:(UIImage*)selectedImage font:(UIFont*)font;
- (void)addData:(id)data;
- (UIView*)addObject:(id)object;
- (UIView*)addObject:(id)object data:(id)data;
- (UIView*)addObject:(id)object selected:(BOOL)selected;
- (UIView*)addObject:(id)object data:(id)data selected:(BOOL)selected;
- (UIView*)addObject:(id)object disabled:(BOOL)disabled;
- (UIView*)addObject:(id)object selected:(BOOL)selected disabled:(BOOL)disabled;
- (UIView*)addObject:(id)object data:(id)data selected:(BOOL)selected disabled:(BOOL)disabled;
- (void)addObjects:(NSArray*)objects;
- (void)removeObject:(id)object;
- (void)removeAllObjects;
- (void)selectObject:(id)object;
- (void)selectObjectNoDelegate:(id)object;
- (void)selectObjectAtIndex:(NSInteger)index;
- (void)selectObjectAtIndexNoDelegate:(NSInteger)index;
- (BOOL)isSelectedWithText:(NSString*)text;
- (BOOL)isSelectedAtIndex:(NSInteger)index;
- (void)selectAllObject;
- (void)unselectAllObject;
- (void)disabledAllObject;
- (void)undisabledAllObject;
@end

