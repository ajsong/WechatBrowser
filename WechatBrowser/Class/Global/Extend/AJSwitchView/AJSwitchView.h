//
//  AJSwitchView.h
//
//  Created by ajsong on 2018/12/28.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AJSwitchView,AJSwitchViewButton;

@protocol AJSwitchViewDelegate<NSObject>
@optional
- (void)AJSwitchView:(AJSwitchView*)switchView button:(AJSwitchViewButton*)button atIndex:(NSInteger)index;
- (void)AJSwitchView:(AJSwitchView*)switchView didSelectAtIndex:(NSInteger)index value:(id)value;
//防止上面方法里操作太多，且点击太快未完成操作，执行selectedHandler(YES)即操作完毕，与上面方法冲突，上面方法优先
- (void)AJSwitchView:(AJSwitchView*)switchView didSelectAtIndex:(NSInteger)index value:(id)value completeHandler:(void (^)(BOOL result))completeHandler;
- (BOOL)AJSwitchView:(AJSwitchView*)switchView shouldSelectAtIndex:(NSInteger)index value:(id)value;
@end

@interface AJSwitchViewButton : UIButton
@property (nonatomic,strong) UIColor *bgColor;
@property (nonatomic,strong) UIColor *selectedBgColor;
@end

@interface AJSwitchView : UIView
@property (nonatomic,weak) id<AJSwitchViewDelegate> delegate;
@property (nonatomic,assign) BOOL createSelected; //创建后立即调用 -AJSwitchView:didSelectAtIndex:value:,默认YES
@property (nonatomic,strong) NSArray *nameArray; //文字内容的数组,设置值会重新加载AJSwitchView
@property (nonatomic,strong) NSArray *valueArray; //内容对应的值的数组
@property (nonatomic,strong) NSArray *buttons; //选项集数组
@property (nonatomic,strong) UIColor *overlayColor; //两端渐变遮盖的颜色,默认白色
@property (nonatomic,strong) UIColor *textColor; //默认字体颜色,默认COLORTEXT
@property (nonatomic,strong) UIColor *bgColor; //默认背景色,默认COLORCLEAR
@property (nonatomic,strong) UIColor *selectedTextColor; //选中的字体颜色,默认COLORTEXT
@property (nonatomic,strong) UIColor *selectedBgColor; //选中的背景色,默认COLORCLEAR
@property (nonatomic,strong) UIFont *font; //字体
@property (nonatomic,strong) UIScrollView *scrollView; //因数组过多而产生滚动(无需设置,自动生成)
@property (nonatomic,assign) BOOL isScroll; //是否因为数组过多产生了滚动
@property (nonatomic,assign) BOOL lineHidden; //隐藏选项相隔线,默认YES
@property (nonatomic,assign) UIEdgeInsets lineMargin; //选项相隔线距离上下边距
@property (nonatomic,strong) UIColor *lineColor; //选项相隔线颜色,默认COLOR_GE_LIGHT
@property (nonatomic,assign) CGFloat lineWidth; //相隔线宽度,默认0.5*SCREEN_SCALE
@property (nonatomic,strong) UIColor *geLineColor; //底部相隔线颜色,设为nil即不显示,默认COLOR_GE_LIGHT
@property (nonatomic,assign) CGFloat padding; //产生滚动后每格的左右边距
@property (nonatomic,assign) BOOL autoFontWidth; //每项宽度自动按字体设置
@property (nonatomic,assign) CGFloat minWidth; //自动宽度时最小宽度
@property (nonatomic,assign) NSInteger index; //默认选中项|当前选中项
@property (nonatomic,assign) NSInteger lastIndex; //上一个选中项
@property (nonatomic,strong) UIView *column; //底部滚动条
@property (nonatomic,assign) CGFloat columnWidth; //底部滚动条宽度
@property (nonatomic,assign) CGFloat columnHeight; //底部滚动条高度,默认3*SCREEN_SCALE
@property (nonatomic,strong) UIColor *columnColor; //底部滚动条颜色,默认COLORRED
@property (nonatomic,assign) CGPoint columnMargin; //底部滚动条偏移
@property (nonatomic,assign) CGFloat columnPadding; //产生滚动后底部滚动条的左右边距
@property (nonatomic,assign) BOOL columnHidden; //隐藏底部滚动条,默认NO
@property (nonatomic,assign) BOOL disable; //禁用,默认NO
- (void)setSelectAtIndex:(NSInteger)index;
- (void)setUnselectAtIndex:(NSInteger)index;
@end
