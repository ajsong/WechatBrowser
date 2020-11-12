//
//  UIViewController+Extend.h
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PRESENT_OVERLAY_TAG 20040724
#define PRESENT_ACTION_TAG 20050724
#define PRESENT_ALERT_TAG 20060724
#define SHOWLOGIN_DIDLOGINED @"showLoginDidLogined"

#pragma mark - UIViewController+Extend
typedef enum : NSInteger {
	ShowLoginTypePush = 0,
	ShowLoginTypePresent,
} ShowLoginType;

typedef enum : NSInteger {
	DYActionViewDown = 0, //从下到上
	DYActionViewUp, //从上到下
	DYActionViewLeft, //从左到右
	DYActionViewRight, //从右到左
} DYActionViewDirection;

typedef enum : NSInteger {
	DYAlertViewNoAnimation = 0, //没有动画
	DYAlertViewUp, //从上到下
	DYAlertViewDown, //从下到上
	DYAlertViewLeft, //从左到右
	DYAlertViewRight, //从右到左
	DYAlertViewFade, //渐显渐隐
	DYAlertViewScale, //放大缩小
} DYAlertViewAnimation;

@interface UIViewController (GlobalExtend)<UIGestureRecognizerDelegate>
- (void)isNetworking;
- (void)CommonSuccess:(NSDictionary *)json;
- (void)CommonError:(NSDictionary *)json;
- (BOOL)isLogin;
- (BOOL)isLogin:(BOOL)showLogin;
- (void)pushLogin;
- (void)presentLogin;
- (void)showLogin;
- (void)showLogin:(ShowLoginType)type;
- (void)showLogin:(ShowLoginType)type selector:(SEL)selector;
- (NSInteger)performSelectorInteger:(SEL)aSelector withObjects:(id)arguments;
- (int)performSelectorInt:(SEL)aSelector withObjects:(id)arguments;
- (CGFloat)performSelectorFloat:(SEL)aSelector withObjects:(id)arguments;
- (BOOL)performSelectorBool:(SEL)aSelector withObjects:(id)arguments;
- (id)performSelector:(SEL)aSelector withObjects:(id)arguments;
- (BOOL)isPushController;
- (void)presentController:(UIViewController *)viewController;
- (void)presentController:(UIViewController *)viewController animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)pushControllerWithClass:(NSString*)classString;
- (void)presentControllerWithClass:(NSString*)classString;
- (void)presentActionViewController:(UIViewController*)vc;
- (void)presentActionViewController:(UIViewController*)vc direction:(DYActionViewDirection)direction;
- (void)presentActionView:(UIView*)view;
- (void)presentActionView:(UIView*)view direction:(DYActionViewDirection)direction;
- (void)presentActionViewAlways:(UIView*)view;
- (void)presentActionViewAlways:(UIView*)view direction:(DYActionViewDirection)direction;
- (void)presentActionView:(UIView*)view inView:(UIView*)target;
- (void)presentActionView:(UIView*)view inView:(UIView*)target direction:(DYActionViewDirection)direction;
- (void)presentActionView:(UIView*)view always:(BOOL)always inView:(UIView*)target;
- (void)presentActionView:(UIView*)view closeCompletion:(void (^)(void))closeCompletion;
- (void)presentActionView:(UIView*)view always:(BOOL)always inView:(UIView*)target direction:(DYActionViewDirection)direction closing:(void (^)(void))closing closeCompletion:(void (^)(void))closeCompletion;
- (void)dismissActionView;
- (void)dismissActionView:(void (^)(void))closeCompletion;
- (void)presentAlertViewController:(UIViewController*)vc;
- (void)presentAlertView:(UIView*)view;
- (void)presentAlertView:(UIView*)view animation:(DYAlertViewAnimation)animation;
- (void)presentAlertView:(UIView*)view animation:(DYAlertViewAnimation)animation closeCompletion:(void (^)(void))closeCompletion;
- (void)presentAlertViewAlways:(UIView*)view animation:(DYAlertViewAnimation)animation;
- (void)presentAlertViewAlways:(UIView*)view animation:(DYAlertViewAnimation)animation closeCompletion:(void (^)(void))closeCompletion;
- (void)presentAlertView:(UIView*)view always:(BOOL)always inView:(UIView*)target animation:(DYAlertViewAnimation)animation;
- (void)presentAlertView:(UIView*)view always:(BOOL)always inView:(UIView*)target animation:(DYAlertViewAnimation)animation closeCompletion:(void (^)(void))closeCompletion;
- (void)dismissAlertView;
- (void)dismissAlertView:(DYAlertViewAnimation)animation;
- (void)dismissAlertView:(DYAlertViewAnimation)animation closeCompletion:(void (^)(void))closeCompletion;
- (void)positionWithTitle:(NSString*)title text:(NSString*)text placeholder:(NSString*)placeholder submit:(void(^)(NSString *text))submit;
- (void)positionWithTitle:(NSString*)title text:(NSString*)text placeholder:(NSString*)placeholder keyboardType:(UIKeyboardType)keyboardType btnTitle:(NSString*)btnTitle btnTitleColor:(UIColor*)btnTitleColor btnBgColor:(UIColor*)btnBgColor animation:(DYAlertViewAnimation)animation subview:(UIView *(^)(UIView *view))subviewBlock submit:(void(^)(NSString *text))submit;
- (void)positionWithTitle:(NSString*)title view:(UIView*)view submit:(void(^)())submit;
- (void)positionWithTitle:(NSString*)title view:(UIView*)view btnTitle:(NSString*)btnTitle btnTitleColor:(UIColor*)btnTitleColor btnBgColor:(UIColor*)btnBgColor animation:(DYAlertViewAnimation)animation subview:(UIView *(^)(UIView *view))subviewBlock submit:(void(^)())submit;
- (UIViewController*)parentTarget;
- (UIView*)statusBar;
- (CGFloat)statusBarHeight;
- (CGFloat)navigationAndStatusBarHeight;
- (CGFloat)height;
- (void)navigationHiddenFollowScrollView:(UIScrollView*)scrollView;
@end
