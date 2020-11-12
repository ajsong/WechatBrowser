//
//  UIView+Extend.m
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#pragma mark - UIView+Extend
@interface UIClickWrapper : NSObject
@property (nonatomic,weak) id target;
@property (nonatomic,copy) void(^action)(id target, UIView *sender, UIGestureRecognizer *recognizer);
@property (nonatomic,assign) NSTimeInterval clickInterval;
@property (nonatomic,assign) NSTimeInterval clickTime;
- (instancetype)initWithTarget:(id)target action:(void(^)(id target, UIView *sender, UIGestureRecognizer *recognizer))action;
@end
@implementation UIClickWrapper
- (instancetype)initWithTarget:(id)target action:(void(^)(id target, UIView *sender, UIGestureRecognizer *recognizer))action{
	if (self = [super init]) {
		self.target = target;
		self.action = action;
	}
	return self;
}
- (void)action:(UITapGestureRecognizer *)sender{
	if (NSDate.date.timeIntervalSince1970 - self.clickTime < self.clickInterval) return;
	//CGPoint point = [sender locationInView:sender.view]; //获取触点在视图中的坐标
	if (self.clickInterval>0) self.clickTime = NSDate.date.timeIntervalSince1970;
	self.action(_target, sender.view, sender);
}
- (void)dealloc{
	_target = nil;
	_action = nil;
	_clickTime = 0;
}
@end

@implementation UIView (GlobalExtend)
- (CGFloat)left{
	return self.frame.origin.x;
}

- (CGFloat)top{
	return self.frame.origin.y;
}

- (CGFloat)right{
	return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom{
	return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)width{
	return self.frame.size.width;
}

- (CGFloat)height{
	return self.frame.size.height;
}

- (CGPoint)origin{
	return self.frame.origin;
}

- (CGSize)size{
	return self.frame.size;
}

- (CGFloat)maxRight{
	CGFloat right = 0;
	for (UIView *subview in self.subviews) {
		if (subview.right > right) right = subview.right;
	}
	return right;
}

- (CGFloat)maxBottom{
	CGFloat bottom = 0;
	for (UIView *subview in self.subviews) {
		if (subview.bottom > bottom) bottom = subview.bottom;
	}
	return bottom;
}

- (CGFloat)getLeftUntil:(UIView*)view{
	CGFloat left = self.frame.origin.x;
	UIView *superView = self.superview;
	while (![superView isEqual:view]) {
		left += superView.frame.origin.x;
		superView = superView.superview;
		if (superView==nil) break;
	}
	return left;
}

- (CGFloat)getTopUntil:(UIView*)view{
	CGFloat top = self.frame.origin.y;
	UIView *superView = self.superview;
	while (![superView isEqual:view]) {
		top += superView.frame.origin.y;
		superView = superView.superview;
		if (superView==nil) break;
	}
	return top;
}

- (CGFloat)getWidthPercent:(CGFloat)percent{
	return self.frame.size.width * (percent / 100);
}

- (CGFloat)getHeightPercent:(CGFloat)percent{
	return self.frame.size.height * (percent / 100);
}

- (CGPoint)offset{
	UIView *view = self;
	CGFloat x = 0;
	CGFloat y = 0;
	while (view) {
		if ([view.superview isKindOfClass:[UIScrollView class]]) {
			y -= ((UIScrollView*)view.superview).contentOffset.y;
		}
		x += view.frame.origin.x;
		y += view.frame.origin.y;
		view = view.superview;
	}
	return CGPointMake(x, y);
}

- (void)setLeft:(CGFloat)newLeft{
	CGRect frame = self.frame;
	frame.origin.x = (isnan(newLeft) ? 0 : newLeft);
	self.frame = frame;
}

- (void)setTop:(CGFloat)newTop{
	CGRect frame = self.frame;
	frame.origin.y = (isnan(newTop) ? 0 : newTop);
	self.frame = frame;
}

- (void)setRight:(CGFloat)newRight{
	if (!self.superview) return;
	CGRect frame = self.frame;
	frame.origin.x = self.superview.width - frame.size.width - (isnan(newRight) ? 0 : newRight);
	self.frame = frame;
}

- (void)setBottom:(CGFloat)newBottom{
	if (!self.superview) return;
	CGRect frame = self.frame;
	frame.origin.y = self.superview.height - frame.size.height - (isnan(newBottom) ? 0 : newBottom);
	self.frame = frame;
}

- (void)setWidth:(CGFloat)newWidth{
	CGRect frame = self.frame;
	frame.size.width = (isnan(newWidth) ? 0 : newWidth);
	self.frame = frame;
}

- (void)setHeight:(CGFloat)newHeight{
	CGRect frame = self.frame;
	frame.size.height = (isnan(newHeight) ? 0 : newHeight);
	self.frame = frame;
}

- (void)setOrigin:(CGPoint)newOrigin{
	CGRect frame = self.frame;
	frame.origin = newOrigin;
	self.frame = frame;
}

- (void)setSize:(CGSize)newSize{
	CGRect frame = self.frame;
	frame.size = newSize;
	self.frame = frame;
}

- (CGPoint)getCenter{
	return CGPointMake(self.width/2, self.height/2);
}

- (CGFloat)centerX{
	return self.width / 2;
}
- (void)setCenterX{
	self.centerX = 0;
}
- (void)setCenterX:(CGFloat)offset{
	if (!self.superview) return;
	CGRect superFrame = self.superview.frame;
	CGRect frame = self.frame;
	frame.origin.x = (superFrame.size.width - frame.size.width) / 2 + offset;
	self.frame = frame;
}

- (CGFloat)centerY{
	return self.height / 2;
}
- (void)setCenterY{
	self.centerY = 0;
}
- (void)setCenterY:(CGFloat)offset{
	if (!self.superview) return;
	CGRect superFrame = self.superview.frame;
	CGRect frame = self.frame;
	frame.origin.y = (superFrame.size.height - frame.size.height) / 2 + offset;
	self.frame = frame;
}

- (void)setCenterXY{
	if (!self.superview) return;
	CGRect superFrame = self.superview.frame;
	CGRect frame = self.frame;
	frame.origin.x = (superFrame.size.width - frame.size.width) / 2;
	frame.origin.y = (superFrame.size.height - frame.size.height) / 2;
	self.frame = frame;
}

- (CGFloat)subviewMinBottom{
	if (!self.subviews.count) return 0;
	CGFloat bottom = [self.subviews.firstObject bottom];
	for (int i=1; i<self.subviews.count; i++) {
		UIView *subview = self.subviews[i];
		if (subview.bottom<bottom) bottom = subview.bottom;
	}
	return bottom;
}

- (CGFloat)subviewMaxBottom{
	if (!self.subviews.count) return 0;
	CGFloat bottom = 0;
	for (int i=0; i<self.subviews.count; i++) {
		UIView *subview = self.subviews[i];
		if (subview.bottom>bottom) bottom = subview.bottom;
	}
	return bottom;
}

//当前在屏幕上的位置
- (CGRect)screenFrame{
	CGPoint origin = CGPointZero;
	for (UIView *view = self; view; view = view.superview) {
		origin.x += view.left;
		origin.y += view.top;
		if ([view isKindOfClass:[UIScrollView class]]) {
			UIScrollView *scrollView = (UIScrollView *)view;
			origin.x -= scrollView.contentOffset.x;
			origin.y -= scrollView.contentOffset.y;
		}
	}
	return CGRectMake(origin.x, origin.y, self.width, self.height);
}

- (CGFloat)leftAnimate{
	return self.left;
}
- (void)setLeftAnimate:(CGFloat)newLeft{
	CGRect frame = self.frame;
	frame.origin.x = newLeft;
	[UIView animateWithDuration:0.3 animations:^{
		self.frame = frame;
	}];
}

- (CGFloat)topAnimate{
	return self.top;
}
- (void)setTopAnimate:(CGFloat)newTop{
	CGRect frame = self.frame;
	frame.origin.y = newTop;
	[UIView animateWithDuration:0.3 animations:^{
		self.frame = frame;
	}];
}

- (CGFloat)widthAnimate{
	return self.width;
}
- (void)setWidthAnimate:(CGFloat)newWidth{
	CGRect frame = self.frame;
	frame.size.width = newWidth;
	[UIView animateWithDuration:0.3 animations:^{
		self.frame = frame;
	}];
}

- (CGFloat)heightAnimate{
	return self.height;
}
- (void)setHeightAnimate:(CGFloat)newHeight{
	CGRect frame = self.frame;
	frame.size.height = newHeight;
	[UIView animateWithDuration:0.3 animations:^{
		self.frame = frame;
	}];
}

- (void)setWidthPercent:(CGFloat)newWidth{
	CGFloat width = 0;
	CGRect frame = self.frame;
	if (self.superview) width = self.superview.frame.size.width * (newWidth / 100);
	frame.size.width = width;
	self.frame = frame;
}

- (void)setHeightPercent:(CGFloat)newHeight{
	CGFloat height = 0;
	CGRect frame = self.frame;
	if (self.superview) height = self.superview.frame.size.height * (newHeight / 100);
	frame.size.height = height;
	self.frame = frame;
}

- (void)setWidthAndChangeNextLeft:(CGFloat)width completion:(void (^)(UIView *view))completion{
	[self setWidthAndChangeNextLeft:width animate:nil completion:completion];
}
- (void)setWidthAndChangeNextLeft:(CGFloat)width animate:(void (^)(UIView *view))animate completion:(void (^)(UIView *view))completion{
	if (self.width==width) {
		if (animate) animate(self);
		if (completion) completion(self);
		return;
	}
	NSArray *nextViews = self.nextViews;
	for (UIView *view in nextViews) {
		if (![view.element[@"marginLeft"] isset]) {
			CGFloat marginLeft = view.left - view.prevView.right;
			view.element[@"marginLeft"] = @(marginLeft);
		}
	}
	[UIView animateWithDuration:0.3 animations:^{
		self.width = width;
		for (UIView *view in nextViews) {
			view.left = view.prevView.right + [view.element[@"marginLeft"] floatValue];
		}
		if (animate) animate(self);
	} completion:^(BOOL finished) {
		if (completion) completion(self);
	}];
}
//设置以后的兄弟view的marginTop,需要在改变自身高度之前设置
- (void)changeNextTop:(BOOL)preSetMarginTop{
	NSArray *nextViews = self.nextViews;
	for (UIView *view in nextViews) {
		if (![view.element[@"marginTop"] isset]) view.element[@"marginTop"] = @(view.top - view.prevView.bottom);
	}
	if (!preSetMarginTop) {
		[UIView animateWithDuration:0.3 animations:^{
			for (UIView *view in nextViews) {
				view.top = view.prevView.bottom + [view.element[@"marginTop"] floatValue];
			}
		}];
	}
}
- (void)setHeightAndChangeNextTop:(CGFloat)height completion:(void (^)(UIView *view))completion{
	[self setHeightAndChangeNextTop:height animate:nil completion:completion];
}
- (void)setHeightAndChangeNextTop:(CGFloat)height animate:(void (^)(UIView *view))animate completion:(void (^)(UIView *view))completion{
	if (self.height==height) {
		//if (animate) animate(self);
		//if (completion) completion(self);
		//return;
	}
	NSArray *nextViews = self.nextViews;
	for (UIView *view in nextViews) {
		if (![view.element[@"marginTop"] isset]) view.element[@"marginTop"] = @(view.top - view.prevView.bottom);
	}
	[UIView animateWithDuration:0.3 animations:^{
		self.height = height;
		for (UIView *view in nextViews) {
			view.top = view.prevView.bottom + [view.element[@"marginTop"] floatValue];
		}
		if (animate) animate(self);
	} completion:^(BOOL finished) {
		if (completion) completion(self);
	}];
}

- (UIColor*)shadow{
	return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void)setShadow:(UIColor*)color{
	self.layer.shadowOffset = CGSizeMake(0, 1);
	self.layer.shadowOpacity = 1;
	self.layer.shadowColor = color.CGColor;
	self.layer.shadowRadius = 0;
}

- (void)removeSubviewWithTag:(NSInteger)tag{
	[[self viewWithTag:tag] removeFromSuperview];
}

- (void)removeSubviewWithClass:(Class)cls{
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:cls]) {
			[subview removeFromSuperview];
		}
	}
}

- (void)removeAllSubviews{
	[self removeAllSubviewsExceptTag:-327865];
}

- (void)removeAllSubviewsExceptTag:(NSInteger)tag{
	for (UIView *subview in self.subviews) {
		if (subview.tag!=MJRefreshViewTag && subview.tag!=(MJRefreshViewTag+1) && subview.tag!=(MJRefreshViewTag+2) //MJRefresh的控件
			&& !([subview isKindOfClass:[UIImageView class]] && (subview.width<3 || subview.height<3)) //UIScrollView的滚动条
			&& subview.tag!=tag) {
			[subview removeFromSuperview];
		}
	}
}

- (void)removeAllDelegate{
	if ([self respondsToSelector:@selector(delegate)]) {
		[self performSelector:@selector(setDelegate:) withObject:nil];
	}
	for (UIView *subview in self.subviews) {
		[subview removeAllDelegate];
	}
}

- (void)removeAllGestures{
	NSArray *recognizers = [self.gestureRecognizers copy];
	for (UIGestureRecognizer *recognizer in recognizers) {
		[self removeGestureRecognizer:recognizer];
	}
}
- (void)removeAllGesturesWithSubViews{
	[self removeAllGestures];
	for (UIView *subview in self.subviews) {
		[subview removeAllGesturesWithSubViews];
	}
	[UIView animateWithDuration:0 animations:^{

	}];
}

- (void)shake:(CGFloat)range{
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.duration = 0.5;
	animation.values = @[ @(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0) ];
	[self.layer addAnimation:animation forKey:@"shake"];
}

- (void)shakeRepeat:(CGFloat)range{
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.duration = 0.6;
	animation.values = @[ @(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0) ];
	animation.repeatCount = NSIntegerMax;
	[self.layer addAnimation:animation forKey:@"shake"];
}

- (void)shakeX:(CGFloat)range{
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.duration = 0.6;
	animation.values = @[ @(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0) ];
	[self.layer addAnimation:animation forKey:@"shake"];
}

- (NSInteger)index{
	if (!self) return NSNotFound;
	NSInteger index = NSNotFound;
	for (int i=0; i<self.superview.subviews.count; i++) {
		if ([self.superview.subviews[i] isEqual:self]) {
			index = i;
			break;
		}
	}
	return index;
}

- (NSInteger)indexOfSubview:(UIView*)subview{
	if (!self || !subview) return NSNotFound;
	NSInteger index = NSNotFound;
	for (int i=0; i<self.subviews.count; i++) {
		if ([self.subviews[i] isEqual:subview]) {
			index = i;
			break;
		}
	}
	return index;
}

- (UIView*)subviewAtIndex:(NSInteger)index{
	if (!self) return nil;
	UIView *subview = nil;
	for (NSInteger i=0; i<self.subviews.count; i++) {
		if (i == index) return self.subviews[i];
	}
	return subview;
}

- (UIView*)firstSubview{
	if (!self) return nil;
	if (![self isKindOfClass:[UIScrollView class]]) return self.subviews.firstObject;
	for (NSInteger i=0; i<self.subviews.count; i++) {
		UIView *view = self.subviews[i];
		if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2) //MJRefresh的控件
			|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3)) //UIScrollView的滚动条
			|| [view isKindOfClass:NSClassFromString(@"UIKeyboardCandidateInlineFloatingView")] //软键盘
			) continue;
		return view;
	}
	return nil;
}

- (UIView*)lastSubview{
	if (!self) return nil;
	if (![self isKindOfClass:[UIScrollView class]]) return self.subviews.lastObject;
	UIView *subview = nil;
	for (NSInteger i=0; i<self.subviews.count; i++) {
		UIView *view = self.subviews[i];
		if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2)
			|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3))
			|| [view isKindOfClass:NSClassFromString(@"UIKeyboardCandidateInlineFloatingView")]
			) continue;
		subview = view;
	}
	return subview;
}

- (UIView*)prevView{
	if (!self) return nil;
	UIView *superview = self.superview;
	if (![superview.subviews.firstObject isEqual:self]) {
		UIView *brother = nil;
		for (int i=0; i<superview.subviews.count; i++) {
			UIView *view = superview.subviews[i];
			if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2)
				|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3))
				|| [view isKindOfClass:NSClassFromString(@"UIKeyboardCandidateInlineFloatingView")]
				) continue;
			if ([view isEqual:self]) return brother;
			brother = view;
		}
	}
	return nil;
}

- (UIView*)prevView:(NSInteger)count{
	if (!self) return nil;
	if (count==0) return self;
	if (count<0) return [self nextView:labs(count)];
	UIView *view = self.prevView;
	for (NSInteger i=1; i<count; i++) {
		view = view.prevView;
	}
	return view;
}

- (NSMutableArray*)prevViews{
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	if (!self) return subviews;
	UIView *superview = self.superview;
	if (![superview.subviews.firstObject isEqual:self]) {
		for (int i=0; i<superview.subviews.count; i++) {
			UIView *view = superview.subviews[i];
			if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2)
				|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3))
				|| [view isKindOfClass:NSClassFromString(@"UIKeyboardCandidateInlineFloatingView")]
				) continue;
			if ([view isEqual:self]) break;
			[subviews addObject:view];
		}
	}
	return subviews;
}

- (UIView*)nextView{
	if (!self) return nil;
	UIView *superview = self.superview;
	if (![superview.subviews.lastObject isEqual:self]) {
		for (int i=0; i<superview.subviews.count; i++) {
			UIView *view = superview.subviews[i];
			if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2)
				|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3))
				|| [view isKindOfClass:NSClassFromString(@"UIKeyboardCandidateInlineFloatingView")]
				) continue;
			if ([view isEqual:self]) return superview.subviews[i+1];
		}
	}
	return nil;
}

- (UIView*)nextView:(NSInteger)count{
	if (!self) return nil;
	if (count==0) return self;
	if (count<0) return [self prevView:labs(count)];
	UIView *view = self.nextView;
	for (NSInteger i=1; i<count; i++) {
		view = view.nextView;
	}
	return view;
}

- (NSMutableArray*)nextViews{
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	if (!self) return subviews;
	UIView *superview = self.superview;
	if (![superview.subviews.lastObject isEqual:self]) {
		BOOL start = NO;
		for (int i=0; i<superview.subviews.count; i++) {
			UIView *view = superview.subviews[i];
			if (view.tag==MJRefreshViewTag || view.tag==(MJRefreshViewTag+1) || view.tag==(MJRefreshViewTag+2)
				|| ([view isKindOfClass:[UIImageView class]] && (view.width<3 || view.height<3))
				|| [view isKindOfClass:NSClassFromString(@"UIKeyboardCandidateInlineFloatingView")]
				) continue;
			if (start) [subviews addObject:view];
			if ([view isEqual:self]) start = YES;
		}
	}
	return subviews;
}

- (CGRect)frameTop{
	return [self frameTop:0];
}
- (CGRect)frameTop:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.y -= frame.size.height + margin;
	return frame;
}

- (CGRect)frameLeft{
	return [self frameLeft:0];
}
- (CGRect)frameLeft:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.x -= frame.size.width + margin;
	return frame;
}

- (CGRect)frameRight{
	return [self frameRight:0];
}
- (CGRect)frameRight:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.x += frame.size.width + margin;
	return frame;
}

- (CGRect)frameBottom{
	return [self frameBottom:0];
}
- (CGRect)frameBottom:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.y += frame.size.height + margin;
	return frame;
}

- (void)floatRight:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.x = self.superview.frame.size.width - frame.size.width - margin;
	self.frame = frame;
}

- (void)floatBottom:(CGFloat)margin{
	CGRect frame = self.frame;
	frame.origin.y = self.superview.frame.size.height - frame.size.height - margin;
	self.frame = frame;
}

- (NSArray*)allSubviews{
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	for (UIView *subview in self.subviews) {
		[subviews addObject:subview];
		if (subview.subviews.count) {
			NSArray *arr = subview.allSubviews;
			for (UIView *sv in arr) [subviews addObject:sv];
		}
	}
	return subviews;
}

- (NSArray*)allSubviewsWithFormat{
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	for (UIView *subview in self.subviews) {
		[subviews addObject:subview];
		if (subview.subviews.count) [subviews addObject:subview.allSubviewsWithFormat];
	}
	return subviews;
}

- (void)subviewsLog{
	[self subviewsLogWithLevel:1];
}
- (void)subviewsLogWithLevel:(int)level{
	if (!self.subviews.count) return;
	for (UIView *subview in self.subviews) {
		NSString *blank = @"";
		for (int i=1; i<level; i++) {
			blank = [NSString stringWithFormat:@"  %@", blank];
		}
		NSLog(@"%@%d: %@", blank, level, subview);
		[subview subviewsLogWithLevel:(level+1)];
	}
}

- (NSArray*)subviewsOfTag:(NSInteger)tag{
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	for (UIView *subview in self.allSubviews) {
		if (subview.tag == tag) [subviews addObject:subview];
	}
	return subviews;
}

- (NSArray*)subviewsOfFind:(Class)cls{
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	for (UIView *subview in self.allSubviews) {
		if ([subview isKindOfClass:cls]) [subviews addObject:subview];
	}
	return subviews;
}

- (NSArray*)subviewsOfChildren:(Class)cls{
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:cls]) [subviews addObject:subview];
	}
	return subviews;
}

- (UIView*)parentOfClass:(Class)cls{
	UIView *parent = self.superview;
	while (![parent isKindOfClass:cls]) {
		parent = parent.superview;
		if (parent==nil) break;
	}
	return parent;
}

- (UIViewController*)viewController{
	for (UIView *view = self.superview; view; view = view.superview) {
		UIResponder *nextResponder = view.nextResponder;
		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}

- (BOOL)hasSubview:(UIView*)subview{
	for (UIView *view in self.allSubviews) {
		if ([view isEqual:subview]) return YES;
	}
	return NO;
}

- (BOOL)hasSubviewOfClass:(Class)cls{
	for (UIView *view in self.allSubviews) {
		if ([view isKindOfClass:cls]) return YES;
	}
	return NO;
}

- (UIView*)cloneView{
	NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self];
	return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
}

- (UIViewMatchX)matchX{
	return [self.element[@"matchX"]integerValue];
}
- (void)setMatchX:(UIViewMatchX)matchX{
	self.element[@"matchX"] = @(matchX);
	if (isX) {
		CGRect frame = self.frame;
		switch (matchX) {
			case UIViewMatchXTop:{
				if (!APPCurrentController.navigationControllerKK || APPCurrentController.navigationControllerKK.isNavigationBarHidden) {
					if ([self isKindOfClass:[UIScrollView class]]) {
						[(UIScrollView*)self setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
					} else {
						frame.size.height += 44;
						for (UIView *subview in self.subviews) {
							subview.top += 44;
						}
					}
				}
				break;
			}
			case UIViewMatchXBottom:{
				if (!APPCurrentController.tabBarControllerKK || APPCurrentController.tabBarControllerKK.tabBarHidden) {
					if ([self isKindOfClass:[UIScrollView class]]) {
						[(UIScrollView*)self setContentInset:UIEdgeInsetsMake(0, 0, 34, 0)];
					} else {
						frame.origin.y -= 34;
						frame.size.height += 34;
					}
				}
				break;
			}
		}
		self.frame = frame;
	}
}

//是否显示在屏幕上
- (BOOL)isShowInScreen{
	if (self == nil) return NO;
	CGRect screenRect = [UIScreen mainScreen].bounds;
	CGRect rect = [self convertRect:self.frame fromView:nil]; //转换view对应window的Rect
	if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) return NO;
	if (self.hidden) return NO;
	if (self.superview == nil) return NO;
	if (CGSizeEqualToSize(rect.size, CGSizeZero)) return NO;
	CGRect intersectionRect = CGRectIntersection(rect, screenRect); //获取view与window交叉的Rect
	if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) return NO;
	return YES;
}

//是否显示在superview上
- (BOOL)isShowInSuperview{
	if (self.superview == nil) return NO;
	return CGRectIntersectsRect(self.superview.bounds, self.frame);
}

//背景色渐变,默认左右,start[0,0]是左上角,end[1,1]是右下角
- (NSArray*)backgroundColors{
	return nil;
}
- (void)setBackgroundColors:(NSArray*)backgroundColors{
	[self setBackgroundColors:backgroundColors start:CGPointMake(0, 0) end:CGPointMake(1, 0)];
}
- (void)setBackgroundColors:(NSArray *)backgroundColors start:(CGPoint)start end:(CGPoint)end{
	NSMutableArray *colors = [[NSMutableArray alloc]init];
	for (UIColor *color in backgroundColors) {
		if (color) [colors addObject:(id)color.CGColor];
	}
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = self.bounds;
	gradient.colors = colors;
	gradient.startPoint = start;
	gradient.endPoint = end;
	[self.layer insertSublayer:gradient atIndex:0];
}

- (UIImage*)backgroundImage{
	return [self.backgroundColor imageWithSize:CGSizeMake(self.width, self.height)];
}
//背景图
- (void)setBackgroundImage:(UIImage*)backgroundImage{
	//self.backgroundColor = [UIColor clearColor];
	self.layer.backgroundColor = (__bridge CGColorRef)([UIColor colorWithPatternImage:backgroundImage]);
}

//渐变背景色, 默认上下渐变
- (NSArray*)gradientLayerColors{
	return self.element[@"gradientLayerColor"];
}
- (void)setGradientLayerColors:(NSArray*)colors{
	[self setGradientLayerColors:colors startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 1)];
}
- (void)setGradientLayerColors:(NSArray*)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
	if (!self || !colors.isArray) return;
	self.element[@"gradientLayerColor"] = colors;
	self.backgroundColor = [UIColor gradientColors:colors bounds:self.bounds startPoint:startPoint endPoint:endPoint];
}

//渐显与渐隐
- (void)opacityIn:(NSTimeInterval)duration completion:(void (^)(void))completion{
	if (!self) return;
	[UIView animateWithDuration:duration animations:^{
		self.alpha = 1;
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

- (void)opacityOut:(NSTimeInterval)duration completion:(void (^)(void))completion{
	if (!self) return;
	[UIView animateWithDuration:duration animations:^{
		self.alpha = 0;
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

- (void)opacityTo:(NSInteger)opacity duration:(NSTimeInterval)duration completion:(void (^)(void))completion{
	if (!self) return;
	[UIView animateWithDuration:duration animations:^{
		self.alpha = opacity;
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//渐隐且执行后渐显
- (void)opacityFn:(NSTimeInterval)duration afterHidden:(void (^)(void))afterHidden completion:(void (^)(void))completion{
	if (!self) return;
	[UIView animateWithDuration:duration animations:^{
		self.alpha = 0;
	} completion:^(BOOL finished) {
		if (afterHidden!=nil) afterHidden();
		[UIView animateWithDuration:duration animations:^{
			self.alpha = 1;
		} completion:^(BOOL finished) {
			if (completion) completion();
		}];
	}];
}

- (void)fadeIn:(NSTimeInterval)duration completion:(void (^)(void))completion{
	if (!self) return;
	self.hidden = NO;
	[self opacityIn:duration completion:completion];
}

- (void)fadeOut:(NSTimeInterval)duration completion:(void (^)(void))completion{
	if (!self) return;
	[self opacityOut:duration completion:^{
		self.hidden = YES;
		if (completion) completion();
	}];
}

//渐隐后删除自身
- (void)removeOut:(NSTimeInterval)duration completion:(void (^)(void))completion{
	if (!self) return;
	[self opacityOut:duration completion:^{
		[self removeFromSuperview];
		if (completion) completion();
	}];
}

//水平翻转
- (void)scaleFlipHorizontal{
	self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
}
//垂直翻转
- (void)scaleFlipVertical{
	self.transform = CGAffineTransformMakeScale(1.0, -1.0);
}

//缩放View
- (void)scaleViewWithPercent:(CGFloat)percent{
	if (!self) return;
	if (percent<=0) percent = 0.001;
	self.transform = CGAffineTransformScale(CGAffineTransformIdentity, percent, percent);
}

//动画缩放View
- (void)scaleAnimateWithTime:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)(void))completion{
	[self scaleAnimateWithTime:time percent:percent animations:nil completion:completion];
}
- (void)scaleAnimateWithTime:(NSTimeInterval)time percent:(CGFloat)percent animations:(void (^)(void))animations completion:(void (^)(void))completion{
	if (!self) return;
	if (percent<=0) percent = 0.001;
	[UIView animateWithDuration:time animations:^{
		[self scaleViewWithPercent:percent];
		if (animations) animations();
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//动画缩放View, 回弹效果
- (void)scaleAnimateBouncesWithTime:(NSTimeInterval)time completion:(void (^)(void))completion{
	[self scaleAnimateBouncesWithTime:time percent:0.2 completion:completion];
}
- (void)scaleAnimateBouncesWithTime:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)(void))completion{
	if (!self) return;
	if (percent<=0) percent = 0.001;
	[self scaleAnimateWithTime:time percent:1.0+percent completion:^{
		[self scaleAnimateWithTime:time percent:1.0 completion:^{
			if (completion) completion();
		}];
	}];
}

//角度旋转View
- (void)rotatedViewWithDegrees:(CGFloat)degrees{
	if (!self) return;
	self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (M_PI*(degrees)/180.0));
}

//指定中心点旋转View, center参数为百分比
- (void)rotatedViewWithDegrees:(CGFloat)degrees center:(CGPoint)center{
	if (!self) return;
	CGRect frame = self.frame;
	self.layer.anchorPoint = center; //设置旋转的中心点
	self.frame = frame; //设置anchorPont会使view的frame改变,需重新赋值
	[self rotatedViewWithDegrees:degrees];
}

//动画旋转View
- (void)rotatedAnimateWithTime:(NSTimeInterval)time degrees:(CGFloat)degrees completion:(void (^)(void))completion{
	if (!self) return;
	[UIView animateWithDuration:time animations:^{
		[self rotatedViewWithDegrees:degrees];
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//3D动画旋转View
- (void)rotated3DWithTime:(NSTimeInterval)duration afterHidden:(void (^)(void))afterHidden completion:(void (^)(void))completion{
	if (!self) return;
	[UIView animateWithDuration:duration animations:^{
		CATransform3D transform = CATransform3DIdentity;
		transform.m34 = 1.0 / -500;
		transform = CATransform3DRotate(transform, 90.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
		self.layer.transform = transform;
	} completion:^(BOOL finished) {
		if (afterHidden) afterHidden();
		CATransform3D transform = CATransform3DIdentity;
		transform.m34 = 1.0 / -500;
		transform = CATransform3DRotate(transform, -90.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
		self.layer.transform = transform;
		[UIView animateWithDuration:duration animations:^{
			CATransform3D transform = CATransform3DIdentity;
			transform.m34 = 1.0 / -500;
			transform = CATransform3DRotate(transform, 0.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
			self.layer.transform = transform;
		} completion:^(BOOL finished) {
			if (completion) completion();
		}];
	}];
}

//震动
- (void)shockAnimate{
	CAKeyframeAnimation * animate = [CAKeyframeAnimation animation];
	animate.keyPath = @"transform.rotation";
	animate.values = @[@(degreesToRadian(-4)), @(degreesToRadian(4)), @(degreesToRadian(-4))];
	animate.repeatCount = MAXFLOAT;
	animate.duration = 0.25;
	[self.layer addAnimation:animate forKey:nil];
}

//设置某些角为圆角, UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
- (void)setCornerRadius:(UIRectCorner)rectCorner radius:(CGFloat)radius{
	if (!self) return;
	UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
												   byRoundingCorners:rectCorner
														 cornerRadii:CGSizeMake(radius, radius)];
	CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
	maskLayer.frame = self.bounds;
	maskLayer.path = maskPath.CGPath;
	self.layer.mask = maskLayer;
}

//重力偏移, 像桌面的图标一样倾斜机身会偏移
- (void)setMotionEffect:(CGFloat)extent{
#if (defined(__IPHONE_7_0))
	// Add motion effects
	UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalEffect.minimumRelativeValue = @(-extent);
	horizontalEffect.maximumRelativeValue = @( extent);
	UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalEffect.minimumRelativeValue = @(-extent);
	verticalEffect.maximumRelativeValue = @( extent);
	UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
	motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];
	[self addMotionEffect:motionEffectGroup];
#endif
}

//GameCenter气泡动画
- (void)gamecenterAnimateWithCircleDuration:(NSTimeInterval)circleDuration scaleXDuration:(NSTimeInterval)scaleXDuration scaleYDuration:(NSTimeInterval)scaleYDuration{
	[self.layer removeAllAnimations];
	//绕中心圆移动
	if (circleDuration>0) {
		CAKeyframeAnimation *path = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		path.calculationMode = kCAAnimationPaced;
		path.fillMode = kCAFillModeForwards;
		path.removedOnCompletion = NO;
		path.repeatCount = INFINITY;
		path.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		path.duration = circleDuration;
		CGMutablePathRef curvedPath = CGPathCreateMutable();
		CGRect circleContainer = CGRectInset(self.frame, self.frame.size.width/2-3*SCREEN_SCALE, self.frame.size.width/2-3*SCREEN_SCALE);
		CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
		path.path = curvedPath;
		CGPathRelease(curvedPath);
		[self.layer addAnimation:path forKey:@"circleAnimation"];
	}
	//X方向上的缩放
	if (scaleXDuration>0) {
		CAKeyframeAnimation *scaleX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
		scaleX.values = @[@1.0, @1.1, @1.0];
		scaleX.keyTimes = @[@0.0, @0.5, @1.0];
		scaleX.repeatCount = INFINITY;
		scaleX.autoreverses = YES;
		scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		scaleX.duration = scaleXDuration;
		[self.layer addAnimation:scaleX forKey:@"scaleXAnimation"];
	}
	//Y方向上的缩放
	if (scaleYDuration>0) {
		CAKeyframeAnimation *scaleY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
		scaleY.values = @[@1.0, @1.1, @1.0];
		scaleY.keyTimes = @[@0.0, @0.5, @1.0];
		scaleY.repeatCount = INFINITY;
		scaleY.autoreverses = YES;
		scaleY.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		scaleY.duration = scaleYDuration;
		[self.layer addAnimation:scaleY forKey:@"scaleYAnimation"];
	}
}

//点击
- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action{
	[self addTapGestureRecognizerWithTouches:1 target:target action:action];
}
- (void)addTapGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	recognizer.delegate = target;
	recognizer.numberOfTapsRequired = 1;
	recognizer.numberOfTouchesRequired = touches;
	[self addGestureRecognizer:recognizer];
}

//双击
- (void)addDBTapGestureRecognizerWithTarget:(id)target action:(SEL)action{
	[self addDBTapGestureRecognizerWithTouches:1 target:target action:action];
}
- (void)addDBTapGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UITapGestureRecognizer *singleTap = nil;
	for (UITapGestureRecognizer *r in self.gestureRecognizers) {
		if ([r isKindOfClass:[UITapGestureRecognizer class]]) {
			singleTap = r;
			break;
		}
	}
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	recognizer.delegate = target;
	recognizer.numberOfTapsRequired = 2;
	recognizer.numberOfTouchesRequired = touches;
	if (singleTap) [singleTap requireGestureRecognizerToFail:recognizer];
	[self addGestureRecognizer:recognizer];
}

//长按
- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)action{
	[self addLongPressGestureRecognizerWithTouches:1 target:target action:action];
}
- (void)addLongPressGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
	recognizer.delegate = target;
	recognizer.numberOfTouchesRequired = touches;
	[self addGestureRecognizer:recognizer];
}

//拨动
- (void)addSwipeGestureRecognizerWithDirection:(UISwipeGestureRecognizerDirection)direction target:(id)target action:(SEL)action{
	[self addSwipeGestureRecognizerWithDirection:direction touches:1 target:target action:action];
}
- (void)addSwipeGestureRecognizerWithDirection:(UISwipeGestureRecognizerDirection)direction touches:(NSInteger)touches target:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:target action:action];
	recognizer.delegate = target;
	recognizer.direction = direction;
	recognizer.numberOfTouchesRequired = touches;
	[self addGestureRecognizer:recognizer];
}

//划动
- (void)addPanGestureRecognizerWithCompletion:(void (^)(UIPanGestureRecognizerDirection direction))completion{
	if (completion==nil) return;
	self.element[@"completion"] = completion;
	self.userInteractionEnabled = YES;
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	recognizer.delegate = self;
	recognizer.maximumNumberOfTouches = 1;
	recognizer.delaysTouchesBegan = YES;
	[self addGestureRecognizer:recognizer];
}
- (void)handlePan:(UIPanGestureRecognizer*)recognizer{
	static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan: {
			if (direction == UIPanGestureRecognizerDirectionUndefined) {
				CGPoint velocity = [recognizer velocityInView:recognizer.view];
				BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
				if (isVerticalGesture) {
					if (velocity.y > 0) {
						direction = UIPanGestureRecognizerDirectionDown;
					} else {
						direction = UIPanGestureRecognizerDirectionUp;
					}
				} else {
					if (velocity.x > 0) {
						direction = UIPanGestureRecognizerDirectionRight;
					} else {
						direction = UIPanGestureRecognizerDirectionLeft;
					}
				}
			}
			break;
		}
		case UIGestureRecognizerStateChanged: {
			break;
		}
		case UIGestureRecognizerStateEnded: {
			/*
			 switch (direction) {
				case UIPanGestureRecognizerDirectionUp: {
			 completion(1);
			 break;
				}
				case UIPanGestureRecognizerDirectionDown: {
			 completion(2);
			 break;
				}
				case UIPanGestureRecognizerDirectionLeft: {
			 completion(3);
			 break;
				}
				case UIPanGestureRecognizerDirectionRight: {
			 completion(4);
			 break;
				}
				default: {
			 completion(0);
			 break;
				}
			 }
			 */
			void (^completion)(UIPanGestureRecognizerDirection direction) = self.element[@"completion"];
			completion(direction);
			direction = UIPanGestureRecognizerDirectionUndefined;
			break;
		}
		default:
			break;
	}
}

//旋转
- (void)addRotationGestureRecognizerWithCompletion:(void (^)(NSInteger rotate))completion{
	self.element[@"rotationGesture"] = @YES;
	if (completion) self.element[@"completion"] = completion;
	self.userInteractionEnabled = YES;
	self.multipleTouchEnabled = YES;
	UIRotationGestureRecognizer *recognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
	recognizer.delegate = self;
	[self addGestureRecognizer:recognizer];
}
- (void)handleRotation:(UIRotationGestureRecognizer*)recognizer{
	if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
		recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
		CGFloat rotate = atan2f(recognizer.view.transform.b, recognizer.view.transform.a);
		recognizer.rotation = 0;
		if (self.element[@"completion"]) {
			void (^completion)(NSInteger rotate) = self.element[@"completion"];
			completion(rotate);
		}
	}
}

//张开捏合
- (void)addPinchGestureRecognizerWithCompletion:(void (^)(NSInteger scale))completion{
	self.element[@"pinchGesture"] = @YES;
	if (completion) self.element[@"completion"] = completion;
	self.userInteractionEnabled = YES;
	self.multipleTouchEnabled = YES;
	UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	recognizer.delegate = self;
	[self addGestureRecognizer:recognizer];
}
- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer{
	if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
		CGFloat scale = recognizer.scale;
		recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, scale, scale);
		recognizer.scale = 1;
		if (self.element[@"completion"]) {
			void (^completion)(NSInteger scale) = self.element[@"completion"];
			completion(scale);
		}
	}
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer{
	return gestureRecognizer.view.element[@"rotationGesture"] && otherGestureRecognizer.view.element[@"pinchGesture"];
}

//添加子对象且自动排版,类似于WEB的DIV+CSS自动排版
- (void)addSubviews:(NSMutableArray*)subviews marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r{
	if (!subviews.count) return;
	NSNumber *pr = @0;
	NSNumber *pb = @0;
	int i = 0;
	for (UIView *subview in subviews) {
		if (i==0) {
			subview.element[@"begin"] = @YES;
			subview.element[@"first"] = @YES;
		}
		[self addSubview:subview];
		subview.frame = [self autoXYWithSubview:subview marginPT:t marginPL:l marginPR:r prevRight:&pr prevBottom:&pb];
		i++;
	}
}

//添加子对象到指定层且自动排版, index: < 0(从最后向前倒数添加), = NSNotFound(从最后面添加)
- (void)addSubview:(UIView*)subview atIndex:(NSInteger)index x:(CGFloat)x y:(CGFloat)y marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r completion:(void (^)(void))completion{
	if (!subview) return;
	if (index>0 && self.subviews.count<=index) index = NSNotFound;
	CGRect frame = subview.frame;
	if (index == NSNotFound) {
		UIView *lastView = self.lastSubview;
		frame.origin.x = lastView.right + x;
		frame.origin.y = lastView.top;
		subview.frame = frame;
		[self addSubview:subview];
	} else {
		NSInteger idx = index;
		if (index < 0) idx = self.subviews.count + index;
		if (idx < 0) idx = 0;
		UIView *prevView = [self subviewAtIndex:idx-1];
		frame.origin.x = prevView.right + x;
		frame.origin.y = prevView.top;
		subview.frame = frame;
		[self insertSubview:subview atIndex:idx];
	}
	[subview scaleViewWithPercent:0];
	[subview scaleAnimateWithTime:0.3 percent:1 completion:nil];
	NSArray *subviews = self.subviews;
	NSNumber *pr = @0;
	NSNumber *pb = @0;
	int i = 0;
	for (UIView *subview in self.subviews) {
		if (i==0) {
			subview.element[@"begin"] = @YES;
			subview.element[@"first"] = @YES;
		} else {
			[subview removeElement:@"begin"];
			[subview removeElement:@"first"];
		}
		CGRect frame = subview.frame;
		frame.origin.x = x;
		frame.origin.y = y;
		frame = [self autoXYWithSubview:subview frame:frame marginPT:t marginPL:l marginPR:r prevRight:&pr prevBottom:&pb];
		[UIView animateWithDuration:0.3 animations:^{
			subview.frame = frame;
		} completion:^(BOOL finished) {
			if (completion && i==subviews.count-1) completion();
		}];
		i++;
	}
}

//子对象重新自动排版
- (void)addSubviewsAgainWithX:(CGFloat)x y:(CGFloat)y marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r{
	if (!self.subviews.count) return;
	NSNumber *pr = @0;
	NSNumber *pb = @0;
	int i = 0;
	for (UIView *subview in self.subviews) {
		if (i==0) {
			subview.element[@"begin"] = @YES;
			subview.element[@"first"] = @YES;
		} else {
			[subview removeElement:@"begin"];
			[subview removeElement:@"first"];
		}
		CGRect frame = subview.frame;
		frame.origin.x = x;
		frame.origin.y = y;
		frame = [self autoXYWithSubview:subview frame:frame marginPT:t marginPL:l marginPR:r prevRight:&pr prevBottom:&pb];
		[UIView animateWithDuration:0.3 animations:^{
			subview.frame = frame;
		}];
		i++;
	}
}

//固定宽度区域内自动调整X、Y坐标(换行),需在循环外部设定prevRight、prevBottom为[NSNumber numberWithFloat:0]
- (CGRect)autoXYWithSubview:(UIView*)subview marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb{
	return [self autoXYWithSubview:subview frame:subview.frame marginPT:t marginPL:l marginPR:r prevRight:pr prevBottom:pb];
}
- (CGRect)autoXYWithSubview:(UIView*)subview frame:(CGRect)subviewFrame marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb{
	CGFloat x = [*pr floatValue];
	CGFloat y = [*pb floatValue];
	CGFloat w = floor(subviewFrame.size.width);
	CGFloat h = floor(subviewFrame.size.height);
	if (x==0) x = l;
	if (y==0) y = t;
	if (!subview.element[@"begin"]) x += floor(subviewFrame.origin.x);
	CGRect frame = CGRectMake(x, y, w, h);
	if (x+w > self.width-r) {
		UIView *firstView;
		for (NSInteger i=subview.index-1; i>=0; i--) {
			UIView *prevView = [subview prevView:subview.index-i];
			if ([prevView.element[@"first"] isset]) {
				firstView = prevView;
				break;
			}
		}
		x = l;
		y = floor(firstView.frame.origin.y) + floor(firstView.frame.size.height) + floor(subviewFrame.origin.y);
		frame = CGRectMake(x, y, w, h);
		subview.element[@"first"] = @YES;
	}
	x += w;
	*pr = @(x);
	*pb = @(y);
	return frame;
}

//创建间隔线
- (UIView*)addGeWithType:(GeLineType)type{
	return [self addGeWithType:type color:COLOR_GE_LIGHT];
}
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color{
	return [self addGeWithType:type color:color wide:0.5*SCREEN_SCALE];
}
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color wide:(CGFloat)wide{
	return [self addGeWithType:type color:color wide:wide margin:UIEdgeInsetsZero];
}
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color margin:(UIEdgeInsets)margin{
	return [self addGeWithType:type color:color wide:0.5*SCREEN_SCALE margin:margin];
}
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color wide:(CGFloat)wide margin:(UIEdgeInsets)margin{
	self.element[@"geLineType"] = @(type);
	UIView *ge;
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;
	switch (type) {
		case GeLineTypeLeftRight:{
			[self removeGeLine:GeLineLeftTag];
			[self removeGeLine:GeLineRightTag];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, margin.top, wide-margin.left-margin.right, height-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineLeftTag;
			[self addSubview:ge];
			[self performSelector:@selector(bringSubviewToFront:) withObject:ge afterDelay:0.1];
			ge = [[UIView alloc]initWithFrame:CGRectMake(width-wide+margin.left, margin.top, wide-margin.left-margin.right, height-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineRightTag;
			[self addSubview:ge];
			break;
		}
		case GeLineTypeTopBottom:{
			[self removeGeLine:GeLineTopTag];
			[self removeGeLine:GeLineBottomTag];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, margin.top, width-margin.left-margin.right, wide-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineTopTag;
			[self addSubview:ge];
			[self performSelector:@selector(bringSubviewToFront:) withObject:ge afterDelay:0.1];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, height-wide+margin.top, width-margin.left-margin.right, wide-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineBottomTag;
			[self addSubview:ge];
			break;
		}
		case GeLineTypeLeftTop:{
			[self removeGeLine:GeLineTopTag];
			[self removeGeLine:GeLineLeftTag];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, margin.top, width-margin.left-margin.right, wide-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineTopTag;
			[self addSubview:ge];
			[self performSelector:@selector(bringSubviewToFront:) withObject:ge afterDelay:0.1];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, margin.top, wide-margin.left-margin.right, height-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineLeftTag;
			[self addSubview:ge];
			break;
		}
		case GeLineTypeLeftBottom:{
			[self removeGeLine:GeLineLeftTag];
			[self removeGeLine:GeLineBottomTag];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, margin.top, wide-margin.left-margin.right, height-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineLeftTag;
			[self addSubview:ge];
			[self performSelector:@selector(bringSubviewToFront:) withObject:ge afterDelay:0.1];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, height-wide+margin.top, width-margin.left-margin.right, wide-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineBottomTag;
			[self addSubview:ge];
			break;
		}
		case GeLineTypeRightTop:{
			[self removeGeLine:GeLineTopTag];
			[self removeGeLine:GeLineRightTag];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, margin.top, width-margin.left-margin.right, wide-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineTopTag;
			[self addSubview:ge];
			[self performSelector:@selector(bringSubviewToFront:) withObject:ge afterDelay:0.1];
			ge = [[UIView alloc]initWithFrame:CGRectMake(width-wide+margin.left, margin.top, wide-margin.left-margin.right, height-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineRightTag;
			[self addSubview:ge];
			break;
		}
		case GeLineTypeRightBottom:{
			[self removeGeLine:GeLineBottomTag];
			[self removeGeLine:GeLineRightTag];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, height-wide+margin.top, width-margin.left-margin.right, wide-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineBottomTag;
			[self addSubview:ge];
			[self performSelector:@selector(bringSubviewToFront:) withObject:ge afterDelay:0.1];
			ge = [[UIView alloc]initWithFrame:CGRectMake(width-wide+margin.left, margin.top, wide-margin.left-margin.right, height-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineRightTag;
			[self addSubview:ge];
			break;
		}
		case GeLineTypeAll:{
			[self removeGeLine];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, margin.top, width-margin.left-margin.right, wide-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineTopTag;
			[self addSubview:ge];
			[self performSelector:@selector(bringSubviewToFront:) withObject:ge afterDelay:0.1];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, margin.top, wide-margin.left-margin.right, height-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineLeftTag;
			[self addSubview:ge];
			[self performSelector:@selector(bringSubviewToFront:) withObject:ge afterDelay:0.1];
			ge = [[UIView alloc]initWithFrame:CGRectMake(margin.left, height-wide+margin.top, width-margin.left-margin.right, wide-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineBottomTag;
			[self addSubview:ge];
			[self performSelector:@selector(bringSubviewToFront:) withObject:ge afterDelay:0.1];
			ge = [[UIView alloc]initWithFrame:CGRectMake(width-wide+margin.left, margin.top, wide-margin.left-margin.right, height-margin.top-margin.bottom)];
			ge.backgroundColor = color;
			ge.tag = GeLineRightTag;
			[self addSubview:ge];
			break;
		}
		default:{
			ge = [[UIView alloc]init];
			switch (type) {
				case GeLineTypeTop:{
					[self removeGeLine:GeLineTopTag];
					ge.frame = CGRectMake(margin.left, margin.top, width-margin.left-margin.right, wide-margin.top-margin.bottom);
					ge.tag = GeLineTopTag;
					break;
				}
				case GeLineTypeLeft:{
					[self removeGeLine:GeLineLeftTag];
					ge.frame = CGRectMake(margin.left, margin.top, wide-margin.left-margin.right, height-margin.top-margin.bottom);
					ge.tag = GeLineLeftTag;
					break;
				}
				case GeLineTypeBottom:{
					[self removeGeLine:GeLineBottomTag];
					ge.frame = CGRectMake(margin.left, height-wide+margin.top, width-margin.left-margin.right, wide-margin.top-margin.bottom);
					ge.tag = GeLineBottomTag;
					break;
				}
				case GeLineTypeRight:{
					[self removeGeLine:GeLineRightTag];
					ge.frame = CGRectMake(width-wide+margin.left, margin.top, wide-margin.left-margin.right, height-margin.top-margin.bottom);
					ge.tag = GeLineRightTag;
					break;
				}
				default:
					return nil;
					break;
			}
			ge.backgroundColor = color;
			[self addSubview:ge];
			break;
		}
	}
	[self performSelector:@selector(bringSubviewToFront:) withObject:ge afterDelay:0.1];
	return ge;
}
//删除间隔线
- (void)removeGeLine{
	[self removeGeLine:0];
}
- (void)removeGeLine:(NSInteger)tag{
	if (tag>0) {
		for (UIView *subview in self.subviews) {
			if (subview.tag==tag) {
				[subview removeFromSuperview];
			}
		}
	} else {
		for (UIView *subview in self.subviews) {
			if (subview.tag==GeLineTopTag || subview.tag==GeLineLeftTag || subview.tag==GeLineBottomTag || subview.tag==GeLineRightTag) {
				[subview removeFromSuperview];
			}
		}
	}
}

- (void)showMenuControllerWithTitles:(NSArray*)titles actions:(NSArray*)actions{
	[self.superview becomeFirstResponder];
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	menuController.element[@"view"] = self;
	NSMutableArray *items = [[NSMutableArray alloc]init];
	for (int i=0; i<titles.count; i++) {
		UIMenuItem *menuItem = [[UIMenuItem alloc]initWithTitle:titles[i] action:NSSelectorFromString(actions[i])];
		[items addObject:menuItem];
	}
	menuController.menuItems = items;
	[menuController setTargetRect:self.frame inView:self.superview];
	[menuController setMenuVisible:NO];
	[menuController setMenuVisible:YES animated:YES];
}

- (void)addToolbar{
	[self addToolbar:UIBarStyleDefault];
}
- (void)addToolbar:(UIBarStyle)barStyle{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			NSInteger tag = 785623753;
			[[self viewWithTag:tag] removeFromSuperview];
			UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:self.bounds];
			toolbar.barStyle = barStyle;
			toolbar.tag = tag;
			toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			[self insertSubview:toolbar atIndex:0];
		});
	});
}

//添加到window, 一般在didFinishLaunchingWithOptions方法的makeKeyAndVisible前面调用
- (void)addToWindow{
	//监测didFinishLaunchingNotification
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
		//等didFinishLaunchingWithOptions方法结束后,将其添加到window上(不然会检测是否有rootViewController)
		dispatch_async(dispatch_get_main_queue(), ^{
			[[[UIApplication sharedApplication].delegate window] addSubview:self];
		});
	}];
}

//转为UIImage
- (UIImage*)toImage{
	UIImage *image = nil;
	if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
		[self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	} else {
		//UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
		[self.layer renderInContext:UIGraphicsGetCurrentContext()];
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	return image;
}

//指定区域转为UIImage
- (UIImage*)toImageWithRect:(CGRect)frame{
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

//转为PDF数据
- (NSData*)toPDF{
	CGRect bounds = self.bounds;
	NSMutableData* data = [NSMutableData data];
	CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
	CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
	CGDataConsumerRelease(consumer);
	if (!context) return nil;
	CGPDFContextBeginPage(context, NULL);
	CGContextTranslateCTM(context, 0, bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	[self.layer renderInContext:context];
	CGPDFContextEndPage(context);
	CGPDFContextClose(context);
	CGContextRelease(context);
	return data;
}

//点击
- (void)clickInTarget:(id)target action:(void(^)(id target, UIView *sender, UIGestureRecognizer *recognizer))action{
	if (!action) return;
	UIClickWrapper *wrapper = self.element[@"wrapperTap"];
	if (!wrapper) {
		wrapper = [[UIClickWrapper alloc] initWithTarget:target action:action];
		wrapper.clickInterval = 0.5;
		self.element[@"wrapperTap"] = wrapper;
	}
	[self addTapGestureRecognizerWithTarget:wrapper action:@selector(action:)];
}

//双击
- (void)dbClickInTarget:(id)target action:(void(^)(id target, UIView *sender, UIGestureRecognizer *recognizer))action{
	if (!action) return;
	UIClickWrapper *wrapper = self.element[@"wrapperDbTap"];
	if (!wrapper) {
		wrapper = [[UIClickWrapper alloc] initWithTarget:target action:action];
		wrapper.clickInterval = 0.5;
		self.element[@"wrapperDbTap"] = wrapper;
	}
	[self addDBTapGestureRecognizerWithTarget:wrapper action:@selector(action:)];
}

//长按
- (void)longClickInTarget:(id)target action:(void(^)(id target, UIView *sender, UIGestureRecognizer *recognizer))action{
	if (!action) return;
	UIClickWrapper *wrapper = self.element[@"wrapperLongTap"];
	if (!wrapper) {
		wrapper = [[UIClickWrapper alloc] initWithTarget:target action:action];
		wrapper.clickInterval = 0.5;
		self.element[@"wrapperLongTap"] = wrapper;
	}
	[self addLongPressGestureRecognizerWithTarget:wrapper action:@selector(action:)];
}
//长按图片识别二维码
- (void)longClickForQRCode:(void(^)(UIView *sender, UIGestureRecognizer *recognizer, NSString *qrcode))action{
	if (!action) return;
	self.element[@"longBlockForQRCode"] = action;
	[self addLongPressGestureRecognizerWithTarget:self action:@selector(onLongClick:)];
}
- (void)onLongClick:(UIGestureRecognizer*)recognizer{
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		if (recognizer.view.element[@"longBlockForQRCode"]) {
			NSString *qrcode = @"";
			void(^action)(UIView *sender, UIGestureRecognizer *recognizer, NSString *qrcode) = recognizer.view.element[@"longClickForQRCode"];
			if ([recognizer.view isKindOfClass:[UIImageView class]]) {
				UIImageView *imageView = (UIImageView*)self;
				if (imageView.image) qrcode = [QRCodeGenerator QRStringFromImage:imageView.image alert:nil];
			}
			action(recognizer.view, recognizer, qrcode);
		}
	}
}

//长按拖曳排序
- (void)dragSubviewsWithTarget:(id<DragSubviewsDelegate>)target{
	[self dragSubviewsWithTarget:target skipViews:nil];
}
- (void)dragSubviewsWithTarget:(id<DragSubviewsDelegate>)target lockRect:(CGRect)lockRect{
	[self dragSubviewsWithTarget:target lockRect:lockRect skipViews:nil];
}
- (void)dragSubviewsWithTarget:(id<DragSubviewsDelegate>)target skipViews:(NSArray*)skipViews{
	[self dragSubviewsWithTarget:target lockRect:CGRectZero skipViews:skipViews];
}
- (void)dragSubviewsWithTarget:(id<DragSubviewsDelegate>)target lockRect:(CGRect)lockRect skipViews:(NSArray*)skipViews{
	if (target) self.element[@"sortTarget"] = target;
	if (skipViews) self.element[@"skipViews"] = skipViews;
	self.element[@"lockRect"] = NSStringFromCGRect(lockRect);
	NSMutableArray *sorts = [[NSMutableArray alloc]init];
	NSMutableArray *subviews = [[NSMutableArray alloc]init];
	for (NSInteger i=0; i<self.subviews.count; i++) {
		UIView *subview = self.subviews[i];
		if (skipViews) {
			BOOL isSkip = NO;
			for (UIView *skipView in skipViews) {
				if ([subview isEqual:skipView]) {isSkip = YES;break;}
			}
			if (isSkip) continue;
		}
		if (subview.element[@"skipView"]) continue;
		[subviews addObject:subview];
	}
	for (NSInteger i=0; i<subviews.count; i++) {
		UIView *subview = subviews[i];
		if (!subview.element[@"bindDragSort"]) {
			if (!subview.element[@"longPress"]) {
				subview.userInteractionEnabled = YES;
				UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressDragSort:)];
				[subview addGestureRecognizer:lp];
				subview.element[@"longPress"] = lp;
			}
		}
		[sorts addObject:@(i)];
		subview.element[@"bindDragSort"] = @YES;
		subview.element[@"dragSort"] = @(i);
		subview.element[@"dragX"] = @(subview.left);
		subview.element[@"dragY"] = @(subview.top);
	}
	self.element[@"dragSorts"] = sorts;
	if (target && [target respondsToSelector:@selector(dragSubviewsSortChanged:fromIndex:toIndex:sorts:)]) {
		[target dragSubviewsSortChanged:self.firstSubview fromIndex:0 toIndex:0 sorts:sorts];
	}
}
- (void)longPressDragSort:(UIGestureRecognizer*)recognizer{
	id<DragSubviewsDelegate> target = self.element[@"sortTarget"];
	CGRect lockRect = CGRectFromString(self.element[@"lockRect"]);
	NSArray *skipViews = self.element[@"skipViews"];
	UIView *view = recognizer.view;
	CGPoint point = [recognizer locationInView:self];
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		UINavigationController *navigationController = APPCurrentController.navigationController;
		if ([navigationController isKindOfClass:[KKNavigationController class]]) {
			navigationController.disableDragBack = YES;
		}
		if (target && [target respondsToSelector:@selector(dragSubviewsSortBegan:)]) {
			[target dragSubviewsSortBegan:view];
		}
		//开始的时候改变拖动view的外观(放大，改变颜色等)
		[UIView animateWithDuration:0.2 animations:^{
			if (![self.element[@"disableScale"]boolValue]) view.transform = CGAffineTransformMakeScale(1.2, 1.2);
			view.alpha = 0.7;
		}];
		if (![self.element[@"disableShake"]boolValue]) {
			CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
			shakeAnimation.duration = 0.08;
			shakeAnimation.autoreverses = YES;
			shakeAnimation.repeatCount = MAXFLOAT;
			shakeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(view.layer.transform, -0.06, 0, 0, 1)];
			shakeAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(view.layer.transform, 0.06, 0, 0, 1)];
			[view.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
		}
		//把拖动view放到最上层
		view.element[@"sortIndex"] = @(view.index);
		[self bringSubviewToFront:view];
		//保存最新的移动位置
		view.element[@"valuePoint"] = NSStringFromCGPoint(view.center);
		CGPoint viewPoint = [recognizer locationInView:view];
		view.element[@"viewPoint"] = NSStringFromCGPoint(viewPoint);
	} else if (recognizer.state == UIGestureRecognizerStateChanged) {
		view.element[@"sortMoved"] = @YES;
		CGPoint viewPoint = CGPointFromString(view.element[@"viewPoint"]);
		//更新拖动view的center
		if (!CGRectEqualToRect(lockRect, CGRectZero)) {
			CGFloat halfWidth = view.width/2;
			CGFloat halfHeight = view.height/2;
			CGFloat x = point.x+(halfWidth-viewPoint.x);
			CGFloat y = point.y+(halfHeight-viewPoint.y);
			if (lockRect.origin.x!=MAXFLOAT && x-halfWidth<lockRect.origin.x) x = lockRect.origin.x+halfWidth;
			if (lockRect.size.width!=MAXFLOAT && x+halfWidth>lockRect.origin.x+lockRect.size.width) x = lockRect.origin.x+lockRect.size.width-halfWidth;
			if (lockRect.origin.y!=MAXFLOAT && y-halfHeight<lockRect.origin.y) y = lockRect.origin.y+halfHeight;
			if (lockRect.size.height!=MAXFLOAT && y+halfHeight>lockRect.origin.y+lockRect.size.height) y = lockRect.origin.y+lockRect.size.height-halfHeight;
			point = CGPointMake(x, y);
		}
		view.center = point;
		for (UIView *subview in self.subviews) {
			if (skipViews) {
				BOOL isSkip = NO;
				for (UIView *skipView in skipViews) {
					if ([subview isEqual:skipView]) {isSkip = YES;break;}
				}
				if (isSkip) continue;
			}
			if (subview.element[@"skipView"]) continue;
			//判断是否移动到另一个view区域
			//CGRectContainsPoint(rect, point) 判断某个点是否被某个frame包含
			if (CGRectContainsPoint(subview.frame, point) && ![subview isEqual:view]) {
				NSInteger fromIndex = [view.element[@"dragSort"]integerValue];
				NSInteger toIndex = [subview.element[@"dragSort"]integerValue];
				if (toIndex > fromIndex) {
					[self insertSubview:view aboveSubview:subview];
					//往后移动
					//把拖动view的下一个subview移动到拖动view的记录位置(valuePoint),并把subview的位置记为新的nextPoint,把拖动view的sort值-1
					[UIView animateWithDuration:0.2 animations:^{
						CGPoint valuePoint = CGPointFromString(view.element[@"valuePoint"]);
						CGPoint nextPoint;
						for (NSInteger i=fromIndex+1; i<=toIndex; i++) {
							UIView *next = nil;
							for (UIView *sv in self.subviews) {
								if (skipViews) {
									BOOL isSkip = NO;
									for (UIView *skipView in skipViews) {
										if ([sv isEqual:skipView]) {isSkip = YES;break;}
									}
									if (isSkip) continue;
								}
								if (sv.element[@"skipView"]) continue;
								if ([sv.element[@"dragSort"]integerValue]==i) {
									next = sv;
									break;
								}
							}
							nextPoint = next.center;
							next.center = valuePoint;
							valuePoint = nextPoint;
							next.element[@"dragSort"] = @([next.element[@"dragSort"]integerValue]-1);
						}
						view.element[@"dragSort"] = @(toIndex);
						view.element[@"valuePoint"] = NSStringFromCGPoint(valuePoint);
					} completion:^(BOOL finished) {
						NSMutableArray *sorts = self.element[@"dragSorts"];
						id obj = sorts[fromIndex];
						[sorts removeObjectAtIndex:fromIndex];
						[sorts insertObject:obj atIndex:toIndex];
						if (target && [target respondsToSelector:@selector(dragSubviewsSortChanged:fromIndex:toIndex:sorts:)]) {
							[target dragSubviewsSortChanged:view fromIndex:fromIndex toIndex:toIndex sorts:sorts];
						}
					}];
				} else {
					[self insertSubview:view belowSubview:subview];
					//往前移动
					//把拖动view的上一个subview移动到记录到拖动view的记录位置(valuePoint),并把subview的位置记为新的nextPoint,把拖动view的sort值+1
					[UIView animateWithDuration:0.2 animations:^{
						CGPoint valuePoint = CGPointFromString(view.element[@"valuePoint"]);
						CGPoint nextPoint;
						for (NSInteger i=fromIndex-1; i>=toIndex; i--) {
							UIView *next = nil;
							for (UIView *sv in self.subviews) {
								if (skipViews) {
									BOOL isSkip = NO;
									for (UIView *skipView in skipViews) {
										if ([sv isEqual:skipView]) {isSkip = YES;break;}
									}
									if (isSkip) continue;
								}
								if (sv.element[@"skipView"]) continue;
								if ([sv.element[@"dragSort"]integerValue]==i) {
									next = sv;
									break;
								}
							}
							nextPoint = next.center;
							next.center = valuePoint;
							valuePoint = nextPoint;
							next.element[@"dragSort"] = @([next.element[@"dragSort"]integerValue]+1);
						}
						view.element[@"dragSort"] = @(toIndex);
						view.element[@"valuePoint"] = NSStringFromCGPoint(valuePoint);
					} completion:^(BOOL finished) {
						NSMutableArray *sorts = self.element[@"dragSorts"];
						id obj = sorts[fromIndex];
						[sorts removeObjectAtIndex:fromIndex];
						[sorts insertObject:obj atIndex:toIndex];
						if (target && [target respondsToSelector:@selector(dragSubviewsSortChanged:fromIndex:toIndex:sorts:)]) {
							[target dragSubviewsSortChanged:view fromIndex:fromIndex toIndex:toIndex sorts:sorts];
						}
					}];
				}
			}
		}
		if (target && [target respondsToSelector:@selector(dragSubviewsSortChanged:)]) {
			[target dragSubviewsSortChanged:view];
		}
	} else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
		UINavigationController *navigationController = APPCurrentController.navigationController;
		if ([navigationController isKindOfClass:[KKNavigationController class]]) {
			navigationController.disableDragBack = NO;
		}
		if (target && [target respondsToSelector:@selector(dragSubviewsSortRelease:)]) {
			[target dragSubviewsSortRelease:view];
		}
		//结束的时候恢复拖动view的外观(放大，改变颜色等)
		[UIView animateWithDuration:0.2 animations:^{
			view.transform = CGAffineTransformMakeScale(1.0, 1.0);
			view.alpha = 1;
			view.center = CGPointFromString(view.element[@"valuePoint"]);
		} completion:^(BOOL finished) {
			if (![view.element[@"sortMoved"]boolValue]) {
				[view.superview insertSubview:view atIndex:INTEGER(view.element[@"sortIndex"])];
			}
			view.removeElement = @"sortMoved";
			if (target && [target respondsToSelector:@selector(dragSubviewsSortEnded:)]) {
				[target dragSubviewsSortEnded:view];
			}
		}];
		[view.layer removeAnimationForKey:@"shakeAnimation"];
	}
}

//增加磨砂玻璃效果
- (void)blur{
	[self blur:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] radius:@5];
}
- (void)blur:(UIColor*)backgroundColor radius:(NSNumber*)radius{
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	CIContext *context = [CIContext contextWithOptions:nil];
	CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
	CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[gaussianBlurFilter setValue:imageToBlur forKey:@"inputImage"];
	[gaussianBlurFilter setValue:radius forKey:@"inputRadius"];
	CIImage *resultImage = [gaussianBlurFilter valueForKey:@"outputImage"];
	CGImageRef cgImage = [context createCGImage:resultImage fromRect:self.bounds];
	UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	imageView.tag = -1;
	imageView.image = blurredImage;
	[imageView scaleViewWithPercent:1.1];
	UIView *overlay = [[UIView alloc] initWithFrame:self.bounds];
	overlay.tag = -2;
	overlay.backgroundColor = backgroundColor;
	[self addSubview:imageView];
	[self addSubview:overlay];
}
- (void)Unblur{
	[[self viewWithTag:-1] removeFromSuperview];
	[[self viewWithTag:-2] removeFromSuperview];
}

//不规则图形
- (NSArray*)irregularPoints{
	return self.element[@"irregularPoints"];
}
- (void)setIrregularPoints:(NSArray *)irregularPoints{
	self.element[@"irregularPoints"] = irregularPoints;
}
- (CGFloat)irregularCornerRadius{
	return [self.element[@"irregularCornerRadius"] floatValue];
}
- (void)setIrregularCornerRadius:(CGFloat)irregularCornerRadius{
	self.element[@"irregularCornerRadius"] = @(irregularCornerRadius);
}
- (CGFloat)irregularBorderWidth{
	return [self.element[@"irregularBorderWidth"] floatValue];
}
- (void)setIrregularBorderWidth:(CGFloat)irregularBorderWidth{
	self.element[@"irregularBorderWidth"] = @(irregularBorderWidth);
}
- (UIColor*)irregularBorderColor{
	return self.element[@"irregularBorderColor"];
}
- (void)setIrregularBorderColor:(UIColor *)irregularBorderColor{
	self.element[@"irregularBorderColor"] = irregularBorderColor;
}
- (UIBezierPath*)irregularPath{
	return self.element[@"irregularPath"];
}
- (void)setIrregularPath:(UIBezierPath *)irregularPath{
	self.element[@"irregularPath"] = irregularPath;
}
- (void)irregularMask{
	if (!self.irregularPoints.count) return;
	self.userInteractionEnabled = YES;
	self.irregularPath = [[UIBezierPath alloc] init];
	if (self.irregularCornerRadius>0) {
		//calculate the Turning point of every corner.
		NSMutableArray *array = [NSMutableArray array];
		for (int i=0; i<self.irregularPoints.count; i++) {
			CGPoint pointStart, pointEnd;
			if (i<self.irregularPoints.count-1) {
				pointStart = [self.irregularPoints[i] CGPointValue];
				pointEnd = [self.irregularPoints[i+1] CGPointValue];
			} else {
				pointStart = [self.irregularPoints[i] CGPointValue];
				pointEnd = [self.irregularPoints[0] CGPointValue];
			}
			[array addObject:[NSValue valueWithCGPoint:pointStart]];
			if (pointStart.x == pointEnd.x) {
				BOOL boolY = pointEnd.y-pointStart.y>0;
				pointStart.y = pointStart.y + self.irregularCornerRadius*(boolY? 1 : -1);
				pointEnd.y = pointEnd.y - self.irregularCornerRadius*(boolY? 1 : -1);
			} else if (pointStart.y == pointEnd.y){
				BOOL boolX = pointEnd.x-pointStart.x>0;
				pointStart.x = pointStart.x + self.irregularCornerRadius*(boolX? 1 : -1);
				pointEnd.x = pointEnd.x - self.irregularCornerRadius*(boolX? 1 : -1);
			} else {
				CGFloat tempL = (pointEnd.y-pointStart.y)/(pointEnd.x-pointStart.x);
				CGFloat cutX = sqrtf(self.irregularCornerRadius*self.irregularCornerRadius/(1+tempL*tempL));
				CGFloat cutY = fabs(cutX*tempL);
				BOOL boolX = pointEnd.x-pointStart.x>0;
				BOOL boolY = pointEnd.y-pointStart.y>0;
				pointStart.x = pointStart.x + cutX*(boolX? 1 : -1);
				pointStart.y = pointStart.y + cutY*(boolY? 1 : -1);
				pointEnd.x = pointEnd.x - cutX*(boolX? 1 : -1);
				pointEnd.y = pointEnd.y - cutY*(boolY? 1 : -1);
			}
			[array addObject:[NSValue valueWithCGPoint:pointStart]];
			[array addObject:[NSValue valueWithCGPoint:pointEnd]];
		}
		//calculate the control point of every corner.
		NSMutableArray *arrayM = [NSMutableArray array];
		for (int i=1; i<array.count; i=i+3) {
			CGPoint firstP, nextP, pointP;
			if (i<array.count-3) {
				firstP = [array[i+1] CGPointValue];
				nextP = [array[i+3] CGPointValue];
				pointP = [array[i+2] CGPointValue];
			} else {
				firstP = [array[i+1] CGPointValue];
				nextP = [array[1] CGPointValue];
				pointP = [array[0] CGPointValue];
			}
			[arrayM addObject:[NSValue valueWithCGPoint:firstP]];
			[arrayM addObject:[NSValue valueWithCGPoint:pointP]];
			[arrayM addObject:[NSValue valueWithCGPoint:nextP]];
		}
		//set the path of maskLayer.
		for (int i=0; i <arrayM.count; i=i+3) {
			CGPoint pathPoint = [arrayM[i] CGPointValue];
			if (i==0) {
				[self.irregularPath moveToPoint:pathPoint];
			} else {
				[self.irregularPath addLineToPoint:pathPoint];
			}
			CGPoint cPoint = [arrayM[i+1] CGPointValue];
			CGPoint endPoint = [arrayM[i+2] CGPointValue];
			[self.irregularPath addQuadCurveToPoint:endPoint controlPoint:cPoint];
			if (i==arrayM.count-3) {
				pathPoint = [arrayM[0] CGPointValue];
				[self.irregularPath addLineToPoint:pathPoint];
			}
		}
	} else {
		//set the path of maskLayer.
		for (int i=0; i<self.irregularPoints.count; i++) {
			CGPoint pathPoint = [self.irregularPoints[i] CGPointValue];
			if (i==0) {
				[self.irregularPath moveToPoint:pathPoint];
			} else {
				[self.irregularPath addLineToPoint:pathPoint];
			}
			if (i==self.irregularPoints.count-1) {
				pathPoint = [self.irregularPoints[0] CGPointValue];
				[self.irregularPath addLineToPoint:pathPoint];
			}
		}
	}
	//do mask action.
	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	maskLayer.path = [self.irregularPath CGPath];
	maskLayer.fillColor = [[UIColor whiteColor] CGColor];
	maskLayer.frame = self.bounds;
	self.layer.mask = maskLayer;
	//do border action.
	CAShapeLayer *maskBorderLayer = [CAShapeLayer layer];
	maskBorderLayer.path = [self.irregularPath CGPath];
	maskBorderLayer.fillColor = [[UIColor clearColor] CGColor];
	maskBorderLayer.strokeColor = self.irregularBorderColor ? [self.irregularBorderColor CGColor] : [[UIColor whiteColor] CGColor];
	maskBorderLayer.lineWidth = self.irregularBorderWidth ? self.irregularBorderWidth : 1;
	[self.layer addSublayer:maskBorderLayer];
}

- (void)addLine:(CGPoint)begin to:(CGPoint)end width:(CGFloat)width color:(UIColor*)color{
	UIBezierPath *path = [UIBezierPath bezierPath];
	//[path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0f];
	[path moveToPoint:begin];
	[path addLineToPoint:end];
	CAShapeLayer *layer = [CAShapeLayer layer];
	layer.lineWidth = width;
	layer.strokeColor = color.CGColor;
	layer.fillColor = nil; //默认为blackColor
	layer.path = path.CGPath;
	[self.layer addSublayer:layer];
}
- (void)addDashLine:(CGPoint)begin to:(CGPoint)end pattern:(NSArray*)pattern width:(CGFloat)width color:(UIColor*)color{
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:begin];
	[path addLineToPoint:end];
	CAShapeLayer *layer = [CAShapeLayer layer];
	layer.lineWidth = width;
	layer.strokeColor = color.CGColor;
	layer.fillColor = nil;
	layer.lineDashPattern = pattern; //虚线点长与两点之间的间隔,例如@[@3, @2]
	layer.path = path.CGPath;
	[self.layer addSublayer:layer];
}
- (void)addDashBorder:(CGFloat)width pattern:(NSArray*)pattern color:(UIColor *)color{
	CAShapeLayer *border = [CAShapeLayer layer];
	border.strokeColor = color.CGColor;
	border.fillColor = [UIColor clearColor].CGColor;
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius];
	border.path = path.CGPath;
	border.frame = self.bounds;
	border.lineWidth = width;
	//border.lineCap = @"square"; //设置线条的样式
	border.lineDashPattern = pattern;
	[self.layer addSublayer:border];
}
- (void)addLines:(NSArray*)points width:(CGFloat)width color:(UIColor*)color{
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointFromString(points.firstObject)];
	for (int i=1; i<points.count; i++) {
		[path addLineToPoint:CGPointFromString(points[i])];
	}
	CAShapeLayer *layer = [CAShapeLayer layer];
	layer.lineWidth = width;
	layer.strokeColor = color.CGColor;
	layer.fillColor = nil;
	layer.path = path.CGPath;
	[self.layer addSublayer:layer];
}
- (void)addSquare:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color{
	UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
	CAShapeLayer *layer = [CAShapeLayer layer];
	if (solid) {
		layer.strokeColor = nil;
		layer.fillColor = color.CGColor;
	} else {
		layer.lineWidth = width;
		layer.strokeColor = color.CGColor;
		layer.fillColor = nil;
	}
	layer.path = path.CGPath;
	//self.layer.mask = layer; //作为蒙版添加,即路径以外的转为透明
	[self.layer addSublayer:layer];
}
- (void)addCircle:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color{
	UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
	CAShapeLayer *layer = [CAShapeLayer layer];
	if (solid) {
		layer.strokeColor = nil;
		layer.fillColor = color.CGColor;
	} else {
		layer.lineWidth = width;
		layer.strokeColor = color.CGColor;
		layer.fillColor = nil;
	}
	layer.path = path.CGPath;
	[self.layer addSublayer:layer];
}
- (void)addDiamond:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color{
	CGFloat l = rect.origin.x;
	CGFloat t = rect.origin.y;
	CGFloat w = rect.size.width;
	CGFloat h = rect.size.height;
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(l+w/2, t)];
	[path addLineToPoint:CGPointMake(l+w, t+h/2)];
	[path addLineToPoint:CGPointMake(l+w/2, t+h)];
	[path addLineToPoint:CGPointMake(l, t+h/2)];
	[path addLineToPoint:CGPointMake(l+w/2, t)];
	CAShapeLayer *layer = [CAShapeLayer layer];
	if (solid) {
		layer.strokeColor = nil;
		layer.fillColor = color.CGColor;
	} else {
		layer.lineWidth = width;
		layer.strokeColor = color.CGColor;
		layer.fillColor = nil;
	}
	layer.path = path.CGPath;
	[self.layer addSublayer:layer];
}
- (void)addArcLine:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise width:(CGFloat)width color:(UIColor*)color{
	//clockwise: NO逆时针,YES顺时针
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
	CAShapeLayer *layer = [CAShapeLayer layer];
	layer.lineWidth = width;
	layer.strokeColor = color.CGColor;
	layer.fillColor = nil;
	layer.path = path.CGPath;
	[self.layer addSublayer:layer];
}
- (void)addBezierLine:(CGPoint)begin to:(CGPoint)end controlPoint:(CGPoint)controlPoint width:(CGFloat)width color:(UIColor*)color{
	//二次贝塞尔曲线
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:begin];
	[path addQuadCurveToPoint:end controlPoint:controlPoint];
	CAShapeLayer *layer = [CAShapeLayer layer];
	layer.lineWidth = width;
	layer.strokeColor = color.CGColor;
	layer.fillColor = nil;
	layer.path = path.CGPath;
	[self.layer addSublayer:layer];
}
- (void)addBezierLine:(CGPoint)begin to:(CGPoint)end controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2 width:(CGFloat)width color:(UIColor*)color{
	//三次贝塞尔曲线
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:begin];
	[path addCurveToPoint:end controlPoint1:controlPoint1 controlPoint2:controlPoint2];
	CAShapeLayer *layer = [CAShapeLayer layer];
	layer.lineWidth = width;
	layer.strokeColor = color.CGColor;
	layer.fillColor = nil;
	layer.path = path.CGPath;
	[self.layer addSublayer:layer];
}
@end

#pragma mark - UIView+CPYLayout
@implementation UIView (CPYLayout)
// to superview
- (UIView *)topToSuperview:(CGFloat)constant {
	[self constraintEqualTo:NSLayoutAttributeTop toView:self.superview toAttribute:NSLayoutAttributeTop constant:constant];
	return self;
}
- (UIView *)leftToSuperview:(CGFloat)constant {
	[self constraintEqualTo:NSLayoutAttributeLeft toView:self.superview toAttribute:NSLayoutAttributeLeft constant:constant];
	return self;
}
- (UIView *)rightToSuperview:(CGFloat)constant {
	[self constraintEqualTo:NSLayoutAttributeRight toView:self.superview toAttribute:NSLayoutAttributeRight constant:-constant];
	return self;
}
- (UIView *)bottomToSuperview:(CGFloat)constant {
	[self constraintEqualTo:NSLayoutAttributeBottom toView:self.superview toAttribute:NSLayoutAttributeBottom constant:-constant];
	return self;
}
// to view
- (UIView *)topToView:(UIView *)toView constant:(CGFloat)constant {
	[self constraintEqualTo:NSLayoutAttributeBottom toView:toView toAttribute:NSLayoutAttributeTop constant:-constant];
	return self;
}
- (UIView *)leftToView:(UIView *)toView constant:(CGFloat)constant {
	[self constraintEqualTo:NSLayoutAttributeRight toView:toView toAttribute:NSLayoutAttributeLeft constant:-constant];
	return self;
}
- (UIView *)rightToView:(UIView *)toView constant:(CGFloat)constant {
	[self constraintEqualTo:NSLayoutAttributeLeft toView:toView toAttribute:NSLayoutAttributeRight constant:constant];
	return self;
}
- (UIView *)bottomToView:(UIView *)toView constant:(CGFloat)constant {
	[self constraintEqualTo:NSLayoutAttributeTop toView:toView toAttribute:NSLayoutAttributeBottom constant:constant];
	return self;
}
// align
- (UIView *)alignXToView:(UIView *)toView {
	[self alignXToView:toView offset:0];
	return self;
}
- (UIView *)alignYToView:(UIView *)toView {
	[self alignYToView:toView offset:0];
	return self;
}
- (UIView *)alignXToSuperview {
	[self alignXToView:self.superview offset:0];
	return self;
}
- (UIView *)alignYToSuperview {
	[self alignYToView:self.superview offset:0];
	return self;
}
- (UIView *)centerToSuperview {
	[[self alignYToSuperview] alignXToSuperview];
	return self;
}
- (UIView *)alignXToView:(UIView *)toView offset:(CGFloat)offset {
	[self constraintEqualTo:NSLayoutAttributeCenterX toView:toView toAttribute:NSLayoutAttributeCenterX constant:offset];
	return self;
}
- (UIView *)alignYToView:(UIView *)toView offset:(CGFloat)offset {
	[self constraintEqualTo:NSLayoutAttributeCenterY toView:toView toAttribute:NSLayoutAttributeCenterY constant:offset];
	return self;
}
// size
- (UIView *)constraintWidth:(CGFloat)width {
	[self constraintEqualTo:NSLayoutAttributeWidth toView:nil toAttribute:NSLayoutAttributeNotAnAttribute constant:width];
	return self;
}
- (UIView *)constraintHeight:(CGFloat)height {
	[self constraintEqualTo:NSLayoutAttributeHeight toView:nil toAttribute:NSLayoutAttributeNotAnAttribute constant:height];
	return self;
}
- (UIView *)constraintSize:(CGSize)size {
	[[self constraintWidth:size.width] constraintHeight:size.height];
	return self;
}
- (NSLayoutConstraint *)constraintTop {
	return [self constraintOfType:NSLayoutAttributeTop];
}
- (NSLayoutConstraint *)constraintLeft {
	return [self constraintOfType:NSLayoutAttributeLeft];
}
- (NSLayoutConstraint *)constraintBottom {
	return [self constraintOfType:NSLayoutAttributeBottom];
}
- (NSLayoutConstraint *)constraintRight {
	return [self constraintOfType:NSLayoutAttributeRight];
}
- (NSLayoutConstraint *)constraintLeading {
	return [self constraintOfType:NSLayoutAttributeLeading];
}
- (NSLayoutConstraint *)constraintTrailing {
	return [self constraintOfType:NSLayoutAttributeTrailing];
}
- (NSLayoutConstraint *)constraintOfType:(NSLayoutAttribute)attribte {
	if (self.superview) {
		for (NSLayoutConstraint *each in self.superview.constraints) {
			if ([each isMemberOfClass:[NSLayoutConstraint class]]) {
				if (([each.firstItem isEqual:self] && each.firstAttribute==attribte) || ([each.secondItem isEqual:self] && each.secondAttribute==attribte)) {
					return each;
					break;
				}
			}
		}
	}
	return nil;
}
- (UIView *)constraintEqualTo:(NSLayoutAttribute)attribute toView:(UIView *)toView toAttribute:(NSLayoutAttribute)toAttribute constant:(CGFloat)constant {
	self.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:NSLayoutRelationEqual toItem:toView attribute:toAttribute multiplier:1 constant:constant];
	constraint.active = YES;
	return self;
}
@end

#pragma mark - NSArray+CPYLayout
@implementation NSArray (CPYLayout)
- (void)equalWidthWithMargin:(CGFloat)margin space:(CGFloat)space {
	for (NSInteger i=0; i<self.count; i++) {
		UIView *tmp = self[i];
		if (i == 0) { //设置第一 View 到父 View 的左边距
			[tmp leftToSuperview:margin];
		}
		if ([tmp isEqual:self.lastObject]) { //最后一个，设置到父 View 右边距
			[tmp rightToSuperview:margin];
		} else { //不是最后一个，设置宽度相等和到下一个 View 的间距
			UIView *next = self[i+1];
			[[tmp constraintEqualTo:NSLayoutAttributeWidth toView:next toAttribute:NSLayoutAttributeWidth constant:0] rightToView:next constant:space];
		}
		[tmp alignYToSuperview]; //设置居中
	}
}
- (void)equalHeightWithMargin:(CGFloat)margin space:(CGFloat)space {
	for (NSInteger i=0; i<self.count; i++) {
		UIView *tmp = self[i];
		if (i == 0) { //第一个，设置到父 View 顶部边距
			[tmp topToSuperview:margin];
		}
		if ([tmp isEqual:self.lastObject]) { //最后一个，设置到父 View 下边距
			[tmp bottomToSuperview:margin];
		} else { //不是最后一个，设置高度相等和到下一个 View 的间距
			UIView *next = self[i+1];
			[[tmp constraintEqualTo:NSLayoutAttributeHeight toView:next toAttribute:NSLayoutAttributeHeight constant:0] bottomToView:next constant:space];
		}
		[tmp alignXToSuperview]; //设置居中
	}
}
@end


@interface UIDrawView (){
	NSMutableArray *_drawData;
}
@end
@implementation UIDrawView
- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_drawData = [[NSMutableArray alloc]init];
	}
	return self;
}
- (void)layoutSubviews{
	[self setNeedsDisplay];
}
//直线
- (void)drawLine:(CGContextRef)context from:(CGPoint)begin to:(CGPoint)end width:(CGFloat)width color:(UIColor*)color{
	CGContextSetStrokeColorWithColor(context, color.CGColor); //设置线的颜色, 不设置默认是黑色
	CGContextSetLineWidth(context, width); //设置线宽度, 默认1像素
	//CGFloat dashArray[] = {3, 5};
	//CGContextSetLineDash(context, 0, dashArray, 2); //虚线
	CGContextMoveToPoint(context, begin.x, begin.y); //起始点
	CGContextAddLineToPoint(context, end.x, end.y); //结束点
	CGContextStrokePath(context); //开始绘制
}
//多条直线
- (void)drawLines:(CGContextRef)context points:(NSArray*)point width:(CGFloat)width color:(UIColor*)color{
	CGContextSetStrokeColorWithColor(context, color.CGColor);
	CGContextSetLineWidth(context, width);
	NSInteger count = point.count;
	CGPoint points[count];
	for (int i=0; i<count; i++) {
		points[i] = [point[i] CGPointValue];
	}
	CGContextAddLines(context, points, count); //points代表点数, 第一个点为起点
	CGContextStrokePath(context);
}
//矩形
- (void)drawSquare:(CGContextRef)context solid:(BOOL)solid rect:(CGRect)rect width:(CGFloat)width color:(UIColor*)color{
	if (solid) {
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGContextFillRect(context, rect);
	} else {
		CGContextSetStrokeColorWithColor(context, color.CGColor);
		CGContextSetLineWidth(context, width);
		CGContextAddRect(context, rect);
	}
	CGContextStrokePath(context);
}
//圆形
- (void)drawCircle:(CGContextRef)context solid:(BOOL)solid rect:(CGRect)rect width:(CGFloat)width color:(UIColor*)color{
	if (solid) {
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGContextFillEllipseInRect(context, rect);
	} else {
		CGContextSetStrokeColorWithColor(context, color.CGColor);
		CGContextSetLineWidth(context, width);
		CGContextAddEllipseInRect(context, rect); //在这个区域中画圆
	}
	CGContextStrokePath(context);
}
//菱形
- (void)drawDiamond:(CGContextRef)context solid:(BOOL)solid rect:(CGRect)rect width:(CGFloat)width color:(UIColor*)color{
	CGFloat l = rect.origin.x;
	CGFloat t = rect.origin.y;
	CGFloat w = rect.size.width;
	CGFloat h = rect.size.height;
	CGContextMoveToPoint(context, l+w/2, t);
	CGContextAddLineToPoint(context, l+w, t+h/2);
	CGContextAddLineToPoint(context, l+w/2, t+h);
	CGContextAddLineToPoint(context, l, t+h/2);
	CGContextAddLineToPoint(context, l+w/2, t);
	if (solid) {
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGContextFillPath(context);
	} else {
		CGContextSetStrokeColorWithColor(context, color.CGColor);
		CGContextSetLineWidth(context, width);
		CGContextStrokePath(context);
	}
}
//弧线
- (void)drawArcLine:(CGContextRef)context{
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
	CGContextSetLineWidth(context, 2.0);
	//CGContextAddArc(context, 圆心X, 圆心Y, 半径, 开始角度, 结束角度, 0顺时1逆时);
	CGContextAddArc(context, 320/2, 200, 50, 0, 180*(M_PI/180), 0);
	CGContextStrokePath(context);
}
//贝塞尔曲线
- (void)drawBezierLine:(CGContextRef)context{
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, 50, 50);//起始点
	CGContextAddCurveToPoint(context, 100, 100, 150, 200, 150, 450);
	CGContextAddQuadCurveToPoint(context, 150, 100, 300, 400);
	CGContextStrokePath(context);
}
- (void)drawRect:(CGRect)rect{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, self.bounds); //先清除旧图
	for (NSDictionary *item in _drawData) {
		NSDictionary *data = item[@"data"];
		switch ([item[@"type"]integerValue]) {
			case UIDrawViewTypeLine:{
				[self drawLine:context from:CGPointFromString(data[@"begin"]) to:CGPointFromString(data[@"end"]) width:[data[@"width"]floatValue] color:data[@"color"]];
				break;
			}
			case UIDrawViewTypeLines:{
				[self drawLines:context points:data[@"points"] width:[data[@"width"]floatValue] color:data[@"color"]];
				break;
			}
			case UIDrawViewTypeSquare:{
				[self drawSquare:context solid:[data[@"solid"]boolValue] rect:CGRectFromString(data[@"rect"]) width:[data[@"width"]floatValue] color:data[@"color"]];
				break;
			}
			case UIDrawViewTypeCircle:{
				[self drawCircle:context solid:[data[@"solid"]boolValue] rect:CGRectFromString(data[@"rect"]) width:[data[@"width"]floatValue] color:data[@"color"]];
				break;
			}
			case UIDrawViewTypeDiamond:{
				[self drawDiamond:context solid:[data[@"solid"]boolValue] rect:CGRectFromString(data[@"rect"]) width:[data[@"width"]floatValue] color:data[@"color"]];
				break;
			}
			default:
				break;
		}
	}
}
- (void)setLine:(CGPoint)begin to:(CGPoint)end width:(CGFloat)width color:(UIColor*)color{
	NSDictionary *data = @{
						   @"begin":NSStringFromCGPoint(begin),
						   @"end":NSStringFromCGPoint(end),
						   @"width":@(width),
						   @"color":color
						   };
	[self setDrawData:data type:UIDrawViewTypeLine];
}
- (void)setLines:(NSArray*)points width:(CGFloat)width color:(UIColor*)color{
	NSDictionary *data = @{
						   @"points":points,
						   @"width":@(width),
						   @"color":color
						   };
	[self setDrawData:data type:UIDrawViewTypeLines];
}
- (void)setSquare:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color{
	NSDictionary *data = @{
						   @"solid":@(solid),
						   @"rect":NSStringFromCGRect(rect),
						   @"width":@(width),
						   @"color":color
						   };
	[self setDrawData:data type:UIDrawViewTypeSquare];
}
- (void)setCircle:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color{
	NSDictionary *data = @{
						   @"solid":@(solid),
						   @"rect":NSStringFromCGRect(rect),
						   @"width":@(width),
						   @"color":color
						   };
	[self setDrawData:data type:UIDrawViewTypeCircle];
}
- (void)setDiamond:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color{
	NSDictionary *data = @{
						   @"solid":@(solid),
						   @"rect":NSStringFromCGRect(rect),
						   @"width":@(width),
						   @"color":color
						   };
	[self setDrawData:data type:UIDrawViewTypeDiamond];
}
- (void)setDrawData:(NSDictionary*)data type:(UIDrawViewType)type{
	[_drawData addObject:@{@"data":data, @"type":@(type)}];
}
@end
