//
//  UIView+Extend.h
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DragSubviewsDelegate<NSObject>
@optional
- (void)dragSubviewsSortBegan:(UIView*)subview;
- (void)dragSubviewsSortChanged:(UIView*)subview fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex sorts:(NSArray*)sorts;
- (void)dragSubviewsSortChanged:(UIView*)subview;
- (void)dragSubviewsSortRelease:(UIView*)subview;
- (void)dragSubviewsSortEnded:(UIView*)subview;
@end

#pragma mark - UIView+Extend
typedef enum : NSInteger {
	UIPanGestureRecognizerDirectionUndefined = 0,
	UIPanGestureRecognizerDirectionUp,
	UIPanGestureRecognizerDirectionDown,
	UIPanGestureRecognizerDirectionLeft,
	UIPanGestureRecognizerDirectionRight,
} UIPanGestureRecognizerDirection;

typedef enum : NSInteger {
	GeLineTypeTop = 0,
	GeLineTypeBottom,
	GeLineTypeLeft,
	GeLineTypeRight,
	GeLineTypeTopBottom,
	GeLineTypeLeftRight,
	GeLineTypeLeftTop,
	GeLineTypeLeftBottom,
	GeLineTypeRightTop,
	GeLineTypeRightBottom,
	GeLineTypeAll,
} GeLineType;

typedef enum : NSInteger {
	GeLineTopTag = 58797263,
	GeLineBottomTag,
	GeLineLeftTag,
	GeLineRightTag,
} GeLineTag;

typedef enum : NSInteger {
	UIViewMatchXTop = 0,
	UIViewMatchXBottom,
} UIViewMatchX;

@interface UIView (GlobalExtend)<UIGestureRecognizerDelegate>
- (CGFloat)left;
- (CGFloat)top;
- (CGFloat)right;
- (CGFloat)bottom;
- (CGFloat)width;
- (CGFloat)height;
- (CGPoint)origin;
- (CGSize)size;
- (CGFloat)maxRight;
- (CGFloat)maxBottom;
- (CGFloat)getLeftUntil:(UIView*)view;
- (CGFloat)getTopUntil:(UIView*)view;
- (CGFloat)getWidthPercent:(CGFloat)percent;
- (CGFloat)getHeightPercent:(CGFloat)percent;
- (CGPoint)offset;
- (void)setLeft:(CGFloat)newLeft;
- (void)setTop:(CGFloat)newTop;
- (void)setRight:(CGFloat)newRight;
- (void)setBottom:(CGFloat)newBottom;
- (void)setWidth:(CGFloat)newWidth;
- (void)setHeight:(CGFloat)newHeight;
- (void)setOrigin:(CGPoint)newOrigin;
- (void)setSize:(CGSize)newSize;
- (CGPoint)getCenter;
- (CGFloat)centerX;
- (void)setCenterX;
- (void)setCenterX:(CGFloat)offset;
- (CGFloat)centerY;
- (void)setCenterY;
- (void)setCenterY:(CGFloat)offset;
- (void)setCenterXY;
- (CGFloat)subviewMinBottom;
- (CGFloat)subviewMaxBottom;
- (CGRect)screenFrame;
- (CGFloat)leftAnimate;
- (void)setLeftAnimate:(CGFloat)newLeft;
- (CGFloat)topAnimate;
- (void)setTopAnimate:(CGFloat)newTop;
- (CGFloat)widthAnimate;
- (void)setWidthAnimate:(CGFloat)newWidth;
- (CGFloat)heightAnimate;
- (void)setHeightAnimate:(CGFloat)newHeight;
- (void)setWidthPercent:(CGFloat)newWidth;
- (void)setHeightPercent:(CGFloat)newHeight;
- (void)setWidthAndChangeNextLeft:(CGFloat)width completion:(void (^)(UIView *view))completion;
- (void)setWidthAndChangeNextLeft:(CGFloat)width animate:(void (^)(UIView *view))animate completion:(void (^)(UIView *view))completion;
- (void)changeNextTop:(BOOL)preSetMarginTop;
- (void)setHeightAndChangeNextTop:(CGFloat)height completion:(void (^)(UIView *view))completion;
- (void)setHeightAndChangeNextTop:(CGFloat)height animate:(void (^)(UIView *view))animate completion:(void (^)(UIView *view))completion;
- (UIColor*)shadow;
- (void)setShadow:(UIColor*)color;
- (void)removeSubviewWithTag:(NSInteger)tag;
- (void)removeSubviewWithClass:(Class)cls;
- (void)removeAllSubviews;
- (void)removeAllSubviewsExceptTag:(NSInteger)tag;
- (void)removeAllDelegate;
- (void)removeAllGestures;
- (void)removeAllGesturesWithSubViews;
- (void)shake:(CGFloat)range;
- (void)shakeRepeat:(CGFloat)range;
- (void)shakeX:(CGFloat)range;
- (NSInteger)index;
- (NSInteger)indexOfSubview:(UIView*)subview;
- (UIView*)subviewAtIndex:(NSInteger)index;
- (UIView*)firstSubview;
- (UIView*)lastSubview;
- (UIView*)prevView;
- (UIView*)prevView:(NSInteger)count;
- (NSMutableArray*)prevViews;
- (UIView*)nextView;
- (UIView*)nextView:(NSInteger)count;
- (NSMutableArray*)nextViews;
- (CGRect)frameTop;
- (CGRect)frameTop:(CGFloat)margin;
- (CGRect)frameLeft;
- (CGRect)frameLeft:(CGFloat)margin;
- (CGRect)frameRight;
- (CGRect)frameRight:(CGFloat)margin;
- (CGRect)frameBottom;
- (CGRect)frameBottom:(CGFloat)margin;
- (void)floatRight:(CGFloat)margin;
- (void)floatBottom:(CGFloat)margin;
- (NSArray*)allSubviews;
- (NSArray*)allSubviewsWithFormat;
- (void)subviewsLog;
- (void)subviewsLogWithLevel:(int)level;
- (NSArray*)subviewsOfTag:(NSInteger)tag;
- (NSArray*)subviewsOfFind:(Class)cls;
- (NSArray*)subviewsOfChildren:(Class)cls;
- (UIView*)parentOfClass:(Class)cls;
- (UIViewController*)viewController;
- (BOOL)hasSubview:(UIView*)subview;
- (BOOL)hasSubviewOfClass:(Class)cls;
- (UIView*)cloneView;
- (UIViewMatchX)matchX;
- (void)setMatchX:(UIViewMatchX)matchX;
- (BOOL)isShowInScreen;
- (BOOL)isShowInSuperview;
- (NSArray*)backgroundColors;
- (void)setBackgroundColors:(NSArray*)backgroundColors;
- (void)setBackgroundColors:(NSArray*)backgroundColors start:(CGPoint)start end:(CGPoint)end;
- (UIImage*)backgroundImage;
- (void)setBackgroundImage:(UIImage*)backgroundImage;
- (NSArray*)gradientLayerColors;
- (void)setGradientLayerColors:(NSArray*)colors;
- (void)setGradientLayerColors:(NSArray*)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
- (void)opacityIn:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)opacityOut:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)opacityTo:(NSInteger)opacity duration:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)opacityFn:(NSTimeInterval)duration afterHidden:(void (^)(void))afterHidden completion:(void (^)(void))completion;
- (void)fadeIn:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)fadeOut:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)removeOut:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)scaleFlipHorizontal;
- (void)scaleFlipVertical;
- (void)scaleViewWithPercent:(CGFloat)percent;
- (void)scaleAnimateWithTime:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)(void))completion;
- (void)scaleAnimateWithTime:(NSTimeInterval)time percent:(CGFloat)percent animations:(void (^)(void))animations completion:(void (^)(void))completion;
- (void)scaleAnimateBouncesWithTime:(NSTimeInterval)time completion:(void (^)(void))completion;
- (void)scaleAnimateBouncesWithTime:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)(void))completion;
- (void)rotatedViewWithDegrees:(CGFloat)degrees;
- (void)rotatedViewWithDegrees:(CGFloat)degrees center:(CGPoint)center;
- (void)rotatedAnimateWithTime:(NSTimeInterval)time degrees:(CGFloat)degrees completion:(void (^)(void))completion;
- (void)rotated3DWithTime:(NSTimeInterval)duration afterHidden:(void (^)(void))afterHidden completion:(void (^)(void))completion;
- (void)shockAnimate;
- (void)setCornerRadius:(UIRectCorner)rectCorner radius:(CGFloat)radius;
- (void)setMotionEffect:(CGFloat)extent;
- (void)gamecenterAnimateWithCircleDuration:(NSTimeInterval)circleDuration scaleXDuration:(NSTimeInterval)scaleXDuration scaleYDuration:(NSTimeInterval)scaleYDuration;
- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (void)addTapGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action;
- (void)addDBTapGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (void)addDBTapGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action;
- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (void)addLongPressGestureRecognizerWithTouches:(NSInteger)touches target:(id)target action:(SEL)action;
- (void)addSwipeGestureRecognizerWithDirection:(UISwipeGestureRecognizerDirection)direction target:(id)target action:(SEL)action;
- (void)addSwipeGestureRecognizerWithDirection:(UISwipeGestureRecognizerDirection)direction touches:(NSInteger)touches target:(id)target action:(SEL)action;
- (void)addPanGestureRecognizerWithCompletion:(void (^)(UIPanGestureRecognizerDirection direction))completion;
- (void)addRotationGestureRecognizerWithCompletion:(void (^)(NSInteger rotate))completion;
- (void)addPinchGestureRecognizerWithCompletion:(void (^)(NSInteger scale))completion;
- (void)addSubviews:(NSMutableArray*)subviews marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r;
- (void)addSubview:(UIView*)subview atIndex:(NSInteger)index x:(CGFloat)x y:(CGFloat)y marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r completion:(void (^)(void))completion;
- (void)addSubviewsAgainWithX:(CGFloat)x y:(CGFloat)y marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r;
- (CGRect)autoXYWithSubview:(UIView*)subview marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb;
- (CGRect)autoXYWithSubview:(UIView*)subview frame:(CGRect)subviewFrame marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb;
- (UIView*)addGeWithType:(GeLineType)type;
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color;
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color wide:(CGFloat)wide;
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color margin:(UIEdgeInsets)margin;
- (UIView*)addGeWithType:(GeLineType)type color:(UIColor*)color wide:(CGFloat)wide margin:(UIEdgeInsets)margin;
- (void)removeGeLine;
- (void)removeGeLine:(NSInteger)tag;
- (void)showMenuControllerWithTitles:(NSArray*)titles actions:(NSArray*)actions;
- (void)addToolbar;
- (void)addToolbar:(UIBarStyle)barStyle;
- (void)addToWindow;
- (UIImage*)toImage;
- (UIImage*)toImageWithRect:(CGRect)frame;
- (NSData*)toPDF;
- (void)clickInTarget:(id)target action:(void(^)(id target, UIView *sender, UIGestureRecognizer *recognizer))action;
- (void)dbClickInTarget:(id)target action:(void(^)(id target, UIView *sender, UIGestureRecognizer *recognizer))action;
- (void)longClickInTarget:(id)target action:(void(^)(id target, UIView *sender, UIGestureRecognizer *recognizer))action;
- (void)longClickForQRCode:(void(^)(UIView *sender, UIGestureRecognizer *recognizer, NSString *qrcode))action;
- (void)dragSubviewsWithTarget:(id<DragSubviewsDelegate>)target;
- (void)dragSubviewsWithTarget:(id<DragSubviewsDelegate>)target lockRect:(CGRect)lockRect;
- (void)dragSubviewsWithTarget:(id<DragSubviewsDelegate>)target skipViews:(NSArray*)skipViews;
- (void)dragSubviewsWithTarget:(id<DragSubviewsDelegate>)target lockRect:(CGRect)lockRect skipViews:(NSArray*)skipViews;
- (void)blur;
- (void)blur:(UIColor*)backgroundColor radius:(NSNumber*)radius;
- (void)Unblur;
- (NSArray*)irregularPoints;
- (void)setIrregularPoints:(NSArray *)irregularPoints;
- (CGFloat)irregularCornerRadius;
- (void)setIrregularCornerRadius:(CGFloat)irregularCornerRadius;
- (CGFloat)irregularBorderWidth;
- (void)setIrregularBorderWidth:(CGFloat)irregularBorderWidth;
- (UIColor*)irregularBorderColor;
- (void)setIrregularBorderColor:(UIColor *)irregularBorderColor;
- (UIBezierPath*)irregularPath;
- (void)setIrregularPath:(UIBezierPath *)irregularPath;
- (void)irregularMask;
- (void)addLine:(CGPoint)begin to:(CGPoint)end width:(CGFloat)width color:(UIColor*)color;
- (void)addDashLine:(CGPoint)begin to:(CGPoint)end pattern:(NSArray*)pattern width:(CGFloat)width color:(UIColor*)color;
- (void)addDashBorder:(CGFloat)width pattern:(NSArray*)pattern color:(UIColor *)color;
- (void)addLines:(NSArray*)points width:(CGFloat)width color:(UIColor*)color;
- (void)addSquare:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color;
- (void)addCircle:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color;
- (void)addDiamond:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color;
- (void)addArcLine:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise width:(CGFloat)width color:(UIColor*)color;
- (void)addBezierLine:(CGPoint)begin to:(CGPoint)end controlPoint:(CGPoint)controlPoint width:(CGFloat)width color:(UIColor*)color;
- (void)addBezierLine:(CGPoint)begin to:(CGPoint)end controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2 width:(CGFloat)width color:(UIColor*)color;
@end

#pragma mark - UIView+CPYLayout
@interface UIView (CPYLayout)
- (UIView *)topToSuperview:(CGFloat)constant;
- (UIView *)leftToSuperview:(CGFloat)constant;
- (UIView *)rightToSuperview:(CGFloat)constant;
- (UIView *)bottomToSuperview:(CGFloat)constant;
- (UIView *)topToView:(UIView *)toView constant:(CGFloat)constant;
- (UIView *)leftToView:(UIView *)toView constant:(CGFloat)constant;
- (UIView *)rightToView:(UIView *)toView constant:(CGFloat)constant;
- (UIView *)bottomToView:(UIView *)toView constant:(CGFloat)constant;
- (UIView *)alignXToView:(UIView *)toView;
- (UIView *)alignYToView:(UIView *)toView;
- (UIView *)alignXToSuperview;
- (UIView *)alignYToSuperview;
- (UIView *)centerToSuperview;
- (UIView *)alignXToView:(UIView *)toView offset:(CGFloat)offset;
- (UIView *)alignYToView:(UIView *)toView offset:(CGFloat)offset;
- (UIView *)constraintWidth:(CGFloat)width;
- (UIView *)constraintHeight:(CGFloat)height;
- (UIView *)constraintSize:(CGSize)size;
- (NSLayoutConstraint *)constraintTop;
- (NSLayoutConstraint *)constraintLeft;
- (NSLayoutConstraint *)constraintBottom;
- (NSLayoutConstraint *)constraintRight;
- (NSLayoutConstraint *)constraintLeading;
- (NSLayoutConstraint *)constraintTrailing;
- (UIView *)constraintEqualTo:(NSLayoutAttribute)attribute toView:(UIView *)toView toAttribute:(NSLayoutAttribute)toAttribute constant:(CGFloat)constant;
@end

#pragma mark - NSArray+CPYLayout
@interface NSArray (CPYLayout)
- (void)equalWidthWithMargin:(CGFloat)margin space:(CGFloat)space;
- (void)equalHeightWithMargin:(CGFloat)margin space:(CGFloat)space;
@end

typedef enum : NSInteger {
	UIDrawViewTypeLine = 1, //直线
	UIDrawViewTypeLines, //多条直线
	UIDrawViewTypeSquare, //正方或长方
	UIDrawViewTypeCircle, //圆形或椭圆
	UIDrawViewTypeDiamond, //菱形
} UIDrawViewType;
@interface UIDrawView : UIView
- (void)setLine:(CGPoint)begin to:(CGPoint)end width:(CGFloat)width color:(UIColor*)color;
- (void)setLines:(NSArray*)points width:(CGFloat)width color:(UIColor*)color;
- (void)setSquare:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color;
- (void)setCircle:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color;
- (void)setDiamond:(CGRect)rect solid:(BOOL)solid width:(CGFloat)width color:(UIColor*)color;
@end

/*
不规则图形
UIView *irregular = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
irregular.backgroundColor = [UIColor yellowColor];
[self.view addSubview:irregular];
irregular.irregularPoints = @[[NSValue valueWithCGPoint:CGPointMake(40, 100)],
[NSValue valueWithCGPoint:CGPointMake(160, 250)],
[NSValue valueWithCGPoint:CGPointMake(280, 100)],
[NSValue valueWithCGPoint:CGPointMake(240, 50)],
[NSValue valueWithCGPoint:CGPointMake(80, 50)]];
irregular.irregularCornerRadius = 3;
irregular.irregularBorderWidth  = 10;
irregular.irregularBorderColor  = [UIColor redColor];
[irregular irregularMask];

检测是否点中不规则图形内部
CGPoint point = [recognizer locationInView:recognizer.view];
if ([tapGestrue.view.irregularPath containsPoint:point]) NSLog(@"点中了");
*/
