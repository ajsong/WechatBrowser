//
//  UIButton+Extend.m
//
//  Created by ajsong on 2019/2/11.
//  Copyright © 2019 @MARIO. All rights reserved.
//

#import "UIButton+Extend.h"


#pragma mark - UIControl+Extend
@interface UIControlWrapper : NSObject
@property (nonatomic,weak) id target;
@property (nonatomic,assign) UIControlEvents event;
@property (nonatomic,copy) void(^action)(id target, id sender);
@property (nonatomic,assign) NSTimeInterval clickInterval;
@property (nonatomic,assign) NSTimeInterval clickTime;
- (instancetype)initWithTarget:(id)target event:(UIControlEvents)event action:(void(^)(id target, id sender))action;
@end
@implementation UIControlWrapper
- (instancetype)initWithTarget:(id)target event:(UIControlEvents)event action:(void(^)(id target, id sender))action{
	if (self = [super init]) {
		self.target = target;
		self.event = event;
		self.action = action;
	}
	return self;
}
- (void)action:(id)sender{
	if (NSDate.date.timeIntervalSince1970 - self.clickTime < self.clickInterval) return;
	if (self.clickInterval>0) self.clickTime = NSDate.date.timeIntervalSince1970;
	self.action(_target, sender);
}
- (void)dealloc{
	_target = nil;
	_event = 0;
	_action = nil;
	_clickTime = 0;
}
@end
@implementation UIControl (GlobalExtend)
- (void)addTarget:(id)target action:(void(^)(id target, id sender))action{
	[self addTarget:(id)target event:UIControlEventTouchUpInside action:action];
}
- (void)addTarget:(id)target event:(UIControlEvents)event action:(void(^)(id target, id sender))action{
	if (!action) return;
	UIControlWrapper *wrapper = self.element[@"wrapper"];
	if (!wrapper) {
		wrapper = [[UIControlWrapper alloc] initWithTarget:target event:event action:action];
		wrapper.clickInterval = 0.5;
		self.element[@"wrapper"] = wrapper;
	}
	[self addTarget:wrapper action:@selector(action:) forControlEvents:event];
}
- (void)removeControlEvent:(UIControlEvents)event{
	UIControlWrapper *wrapper = self.element[@"wrapper"];
	if (wrapper) {
		[self removeTarget:wrapper action:@selector(action:) forControlEvents:event];
		self.removeElement = @"wrapper";
	}
}
@end


#pragma mark - UIButton+Extend
@implementation UIButton (GlobalExtend)
- (UIEdgeInsets)autoWidth{
	return UIEdgeInsetsFromString(self.element[@"autoWidth"]);
}
- (void)setAutoWidth:(UIEdgeInsets)padding{
	self.element[@"autoWidth"] = NSStringFromUIEdgeInsets(padding);
	NSString *title = [self titleForState:UIControlStateNormal];
	CGSize size = [title autoWidth:self.titleLabel.font height:self.height];
	if (!UIEdgeInsetsEqualToEdgeInsets(padding, UIEdgeInsetsZero)) {
		size.width += padding.left + padding.right;
	}
	self.width = size.width;
}
- (void)setImageUrl:(NSString *)imageUrl forState:(UIControlState)state{
	if (!imageUrl.length) return;
	[imageUrl loadImageAndCompletion:^(UIImage *image, NSData *imageData) {
		[self setImage:image forState:state];
	}];
}
- (void)setImageRect:(CGRect)imageRect{
	self.element[@"imageRect"] = NSStringFromCGRect(imageRect);
}
- (UIButtonStyle)style{
	return [self.element[@"style"] integerValue];
}
- (void)setStyle:(UIButtonStyle)style{
	self.element[@"style"] = @(style);
	[self setStyle:style offset:0];
}
- (void)setStyle:(UIButtonStyle)style offset:(CGFloat)offset{
	CGRect imageRect = self.element[@"imageRect"] ? CGRectFromString(self.element[@"imageRect"]) : CGRectZero;
	//1.得到imageView和titleLabel的宽、高
	CGFloat imageWidth = imageRect.size.width ? imageRect.size.width : self.imageView.frame.size.width;
	CGFloat imageHeight = imageRect.size.height ? imageRect.size.height : self.imageView.frame.size.height;
	CGFloat labelWidth = 0.0;
	CGFloat labelHeight = 0.0;
	if (@available(iOS 8.0, *)) { //由于iOS8中titleLabel的size为0，用下面的这种设置
		labelWidth = self.titleLabel.intrinsicContentSize.width;
		labelHeight = self.titleLabel.intrinsicContentSize.height;
	} else {
		labelWidth = self.titleLabel.frame.size.width;
		labelHeight = self.titleLabel.frame.size.height;
	}
	//2.声明全局的imageEdgeInsets和labelEdgeInsets
	UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
	UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
	//3.根据style和space得到imageEdgeInsets和labelEdgeInsets的值
	switch (style) {
		case UIButtonStyleTop:{
			imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-offset/2.0, 0, 0, -labelWidth);
			//labelEdgeInsets = UIEdgeInsetsMake(0, -30, -imageHeight-offset/2.0, 0);
			labelEdgeInsets = UIEdgeInsetsMake(imageHeight, -imageWidth, 0, 0);
			break;
		}
		case UIButtonStyleLeft:{
			imageEdgeInsets = UIEdgeInsetsMake(0, -offset/2.0, 0, offset/2.0);
			labelEdgeInsets = UIEdgeInsetsMake(0, offset/2.0, 0, -offset/2.0);
			break;
		}
		case UIButtonStyleBottom:{
			imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-offset/2.0, -labelWidth);
			labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-offset/2.0, -imageWidth, 0, 0);
			break;
		}
		case UIButtonStyleRight:{
			imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+offset/2.0, 0, -labelWidth-offset/2.0);
			labelEdgeInsets = UIEdgeInsetsMake(0, -imageWidth-offset/2.0, 0, imageWidth+offset/2.0);
			break;
		}
	}
	//4.赋值
	self.titleEdgeInsets = labelEdgeInsets;
	self.imageEdgeInsets = imageEdgeInsets;
}
@end

@interface UIIButton ()
@end
@implementation UIIButton
- (CGRect)imageRectForContentRect:(CGRect)contentRect{
	if (!self.element[@"imageRect"]) return CGRectZero;
	CGRect rect = CGRectFromString(self.element[@"imageRect"]);
	if (rect.origin.x<0) {
		NSString *text = self.titleLabel.text;
		if (text.length) {
			CGSize s = [text autoWidth:self.titleLabel.font height:contentRect.size.height];
			rect.origin.x = (contentRect.size.width - (rect.size.width+s.width)) / 2;
		} else {
			rect.origin.x = (contentRect.size.width - rect.size.width) / 2;
		}
	}
	self.titleEdgeInsets = UIEdgeInsetsZero;
	return rect;
}
@end
