//
//  UIButton+Extend.h
//
//  Created by ajsong on 2019/2/11.
//  Copyright © 2019 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - UIControl+Extend
@interface UIControl (GlobalExtend)
- (void)addTarget:(id)target action:(void(^)(id target, id sender))action;
- (void)addTarget:(id)target event:(UIControlEvents)event action:(void(^)(id target, id sender))action;
- (void)removeControlEvent:(UIControlEvents)event;
@end


#pragma mark - UIButton+Extend
typedef enum : NSInteger {
	UIButtonStyleTop = 0, //image上,label下
	UIButtonStyleLeft, //image左,label右
	UIButtonStyleBottom, //image下,label上
	UIButtonStyleRight, //image右,label左
} UIButtonStyle;

@interface UIButton (GlobalExtend)
@property (nonatomic,assign) UIButtonStyle style;
- (UIEdgeInsets)autoWidth;
- (void)setAutoWidth:(UIEdgeInsets)padding;
- (void)setImageUrl:(NSString *)imageUrl forState:(UIControlState)state;
- (void)setImageRect:(CGRect)imageRect; //image大小,需使用UIIButton,x设为负数即自动居中,要放在setImage:forState:之前
- (void)setStyle:(UIButtonStyle)style offset:(CGFloat)offset;
@end

@interface UIIButton : UIButton
@end
