//
//  DragView.m
//
//  Created by ajsong on 15/4/21.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "Global.h"
#import "DragView.h"

@implementation DragView

//点击
- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	[self addGestureRecognizer:recognizer];
}

//长按
- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)action{
	self.userInteractionEnabled = YES;
	UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
	[self addGestureRecognizer:recognizer];
}

//拨动, 0:no, 1:up, 2:down, 3:left, 4:right
- (void)addPanGestureRecognizerWithCompletion:(void (^)(NSInteger direction))completion{
	if (completion==nil) return;
	self.element[@"direction"] = @0;
	self.element[@"completion"] = completion;
	self.userInteractionEnabled = YES;
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self addGestureRecognizer:recognizer];
}
- (void)handlePan:(UIPanGestureRecognizer*)recognizer{
	CGPoint translation = [recognizer translationInView:recognizer.view];
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		self.element[@"direction"] = @0;
	} else if (recognizer.state == UIGestureRecognizerStateChanged) {
		NSInteger direction = [self getMoveDirectionWithTranslation:translation direction:[self.element[@"direction"] integerValue]];
		self.element[@"direction"] = @(direction);
	} else if (recognizer.state == UIGestureRecognizerStateEnded) {
		NSInteger direction = [self.element[@"direction"] integerValue];
		void (^completion)(NSInteger direction) = self.element[@"completion"];
		completion(direction);
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

//移动
- (void)addDragGestureRecognizerWithOutParent:(BOOL)outParent completion:(void (^)(CGPoint center))completion{
	self.element[@"dragGesture"] = @YES;
	self.element[@"outParent"] = @(outParent);
	if (completion) self.element[@"completion"] = completion;
	self.userInteractionEnabled = YES;
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(emptyDrag:)];
	recognizer.cancelsTouchesInView = NO;
	[self addGestureRecognizer:recognizer];
}
- (void)emptyDrag:(UIPanGestureRecognizer*)recognizer{
	return;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if (!self.element[@"dragGesture"]) return;
	CGPoint startPoint = [[touches anyObject] locationInView:self];
	self.element[@"startPoint"] = [NSValue valueWithCGPoint:startPoint];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	if (!self.element[@"dragGesture"]) return;
	CGPoint startPoint = [self.element[@"startPoint"] CGPointValue];
	BOOL outParent = [self.element[@"outParent"] boolValue];
	CGPoint lastPoint = [[touches anyObject] locationInView:self];
	CGFloat dx = lastPoint.x - startPoint.x;
	CGFloat dy = lastPoint.y - startPoint.y;
	CGPoint newCenter = CGPointMake(self.center.x+dx, self.center.y+dy);
	if (_delegate && [_delegate respondsToSelector:@selector(dragViewInArea:)]) {
		UIEdgeInsets edgeInsets = [_delegate dragViewInArea:self];
		CGFloat halfX = CGRectGetMidX(self.bounds);
		CGFloat halfY = CGRectGetMidY(self.bounds);
		newCenter.x = MIN(edgeInsets.right-halfX, MAX(edgeInsets.left, newCenter.x));
		newCenter.y = MIN(edgeInsets.bottom-halfY, MAX(edgeInsets.top, newCenter.y));
	} else {
		if (!outParent) {
			CGFloat halfX = CGRectGetMidX(self.bounds);
			CGFloat halfY = CGRectGetMidY(self.bounds);
			newCenter.x = MIN(self.superview.bounds.size.width-halfX, MAX(halfX, newCenter.x));
			newCenter.y = MIN(self.superview.bounds.size.height-halfY, MAX(halfY, newCenter.y));
		}
	}
	self.center = newCenter;
	if (_delegate && [_delegate respondsToSelector:@selector(dragViewDidMove:)]) {
		[_delegate dragViewDidMove:self];
	}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if (!self.element[@"dragGesture"]) return;
	if (self.element[@"completion"]) {
		void (^completion)(CGPoint center) = self.element[@"completion"];
		completion(self.center);
	}
}

- (NSInteger)getMoveDirectionWithTranslation:(CGPoint)translation direction:(NSInteger)direction{
	CGFloat gestureMinimumTranslation = 50.f;
	if (direction!=0) return direction;
	if (fabs(translation.x) > gestureMinimumTranslation) {
		BOOL gestureHorizontal = (translation.y==0.0) ? YES : (fabs(translation.x / translation.y) > 5.0);
		if (gestureHorizontal) {
			if (translation.x>0.0) return 4;
			else return 3;
		}
	} else if (fabs(translation.y) > gestureMinimumTranslation) {
		BOOL gestureVertical = (translation.x==0.0) ? YES : (fabs(translation.y / translation.x) > 5.0);
		if (gestureVertical) {
			if (translation.y>0.0) return 2;
			else return 1;
		}
	}
	return direction;
}

@end
