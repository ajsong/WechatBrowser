//
//  UILabel+Extend.h
//
//  Created by ajsong on 2019/2/11.
//  Copyright © 2019 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - UILabel+Extend
@interface UILabel (GlobalExtend)
@property (nonatomic,strong) NSDictionary *attributed; //样式设置
- (UIEdgeInsets)autoWidth;
- (void)setAutoWidth:(UIEdgeInsets)padding;
- (UIEdgeInsets)autoHeight;
- (void)setAutoHeight:(UIEdgeInsets)padding;
- (UIEdgeInsets)autoWidthAndHeight;
- (void)setAutoWidthAndHeight:(UIEdgeInsets)padding;
- (UIFont*)priceFont;
- (void)setPriceFont:(UIFont*)priceFont;
- (void)setPriceFont:(UIFont*)priceFont color:(UIColor*)color;
@end


#pragma mark - UIILabel
typedef enum : NSInteger {
	NSTextAlignmentMiddle = 0,
	NSTextAlignmentTop,
	NSTextAlignmentBottom,
} NSTextAlignmentVertical;
typedef enum : NSInteger {
	NSLineTypeNone, //没有画线
	NSLineTypeTop, //上边画线
	NSLineTypeMiddle, //中间画线
	NSLineTypeBottom, //下边画线
} NSLineType;
typedef enum : NSInteger {
	NSTextAlignTypeLeft = 0, //左边对齐
	NSTextAlignTypeTop, //顶部对齐
	NSTextAlignTypeBottom, //底部对齐
	NSTextAlignTypeRight, //右边对齐
	NSTextAlignTypeCenter, //水平/垂直对齐(默认中心对齐)
	/*[label textAlign:^(UIIMaker *make) {
		make.alignType(NSTextAlignTypeRight).alignType(NSTextAlignTypeCenter);
	}];*/
} NSTextAlignType;
@class UIIMaker;
@interface UIILabel : UILabel
@property (nonatomic,strong) NSString *placeholder;
@property (nonatomic,strong) UIColor *placeholderColor;
@property (nonatomic,assign) NSLineType lineType; //画线类型
@property (nonatomic,strong) UIColor *lineColor; //画线颜色
@property (nonatomic,assign) CGFloat lineWidth; //画线厚度
@property (nonatomic,assign) UIEdgeInsets padding; //填充空间
@property (nonatomic,assign) NSInteger separateLength; //用空格分隔字符
@property (nonatomic,strong) NSArray *gradientColors; //背景色渐变数组
/*!
 @brief 行高
 */
@property (nonatomic,assign) IBInspectable CGFloat lineHeight; //行高
@property (nonatomic,assign) NSTextAlignmentVertical textAlignmentVertical; //垂直位置
- (void)setSeparateLength:(NSInteger)separateLength separator:(NSString*)separator;
- (void)textAlign:(void(^)(UIIMaker *make))alignType; //文本对齐
@end

@interface UIIMaker : NSObject
@property(nonatomic,strong) NSMutableArray *typeArray; //存放对齐样式
- (UIIMaker *(^)(NSTextAlignType type))alignType; //添加对齐样式
@end
