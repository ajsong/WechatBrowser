//
//  KKNavigationController.h
//
//  Created by Coneboy_K on 13-12-2.
//  Copyright (c) 2013年 Coneboy_K. All rights reserved. MIT
//  WELCOME TO MY BLOG  http://www.coneboy.com
//

#import <UIKit/UIKit.h>

#define DISMISS_COMPLETION_DELAY 0.5

@protocol KKNavigationControllerDelegate;

@interface KKNavigationController : UINavigationController<UINavigationControllerDelegate>
@property (nonatomic,assign) BOOL systemDragBack; //系统形式返回(全屏拖曳返回,非只是边缘),默认NO,否则非系统形式
@property (nonatomic,assign) BOOL disableDragBack; //全局禁止拖曳返回
@property (nonatomic,assign) BOOL hiddenBackText; //隐藏返回按钮文字
@property (nonatomic,weak) id<KKNavigationControllerDelegate> navigationKKDelegate;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion;
- (UIViewController *)popViewControllerForPopItemAnimated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion;
- (UIViewController *)popToViewControllerOfIndex:(NSInteger)index animated:(BOOL)animated;
- (UIViewController *)popToViewControllerOfIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion;
- (UIViewController *)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated;
- (UIViewController *)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion;
@end

@interface UIViewController (KKNavigationController)
@property (nonatomic,assign) BOOL disableDragBack;
- (KKNavigationController*)navigationControllerKK;
@end

@protocol KKNavigationControllerDelegate <NSObject>
@optional
- (NSInteger)navigationPopToViewControllerOfIndex:(KKNavigationController *)navigationController; //拖曳或点击返回按钮到指定索引视图
- (Class)navigationPopToViewControllerOfClass:(KKNavigationController *)navigationController; //拖曳或点击返回按钮到指定类视图
- (void)navigationWillPushViewController:(KKNavigationController *)navigationController; //当前视图跳转到下个视图前执行
- (void)navigationWillPopViewController:(KKNavigationController *)navigationController isGesture:(BOOL)flag; //退出当前视图前执行
- (void)navigationWillPopFromViewController:(KKNavigationController *)navigationController isGesture:(BOOL)flag; //返回到当前视图前执行,isGesture是否拖曳返回
- (void)navigationDidPopFromViewController:(KKNavigationController *)navigationController isGesture:(BOOL)flag; //返回到当前视图即将显示时执行
- (void)navigationDidBeginGesture:(KKNavigationController *)navigationController; //当前视图拖曳前执行
- (void)navigationDidEndGesture:(KKNavigationController *)navigationController; //当前视图拖曳释放时执行
@end

//自定义UIBarButtonItem
typedef enum : NSInteger {
	KKNavigationItemTypeLeft = 0,
	KKNavigationItemTypeCenter,
	KKNavigationItemTypeRight,
} KKNavigationItemType;

@interface KKNavigationBarItem : NSObject
@property (nonatomic,strong) UIButton *contentBarItem;
@property (nonatomic,strong) UIView *titleView;
@property (nonatomic,strong) UIBarButtonItem *barButtonItem;
@property (nonatomic,strong) UIButton *leftBarButtonItem;
@property (nonatomic,strong) UIButton *rightBarButtonItem;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,assign) KKNavigationItemType itemType;
@property (nonatomic,strong) UIView *customView;
@property (nonatomic,assign) BOOL isTextView;
@property (nonatomic,assign) BOOL isCustomView;
+ (KKNavigationBarItem*)itemWithTitle:(NSString *)title textColor:(UIColor *)color fontSize:(CGFloat)font itemType:(KKNavigationItemType)type;
+ (KKNavigationBarItem*)itemWithImage:(UIImage *)image size:(CGSize)size type:(KKNavigationItemType)type;
+ (KKNavigationBarItem*)itemWithImageUrl:(NSString *)imageUrl size:(CGSize)size type:(KKNavigationItemType)type;
+ (KKNavigationBarItem*)itemWithCustomeView:(UIView *)customView type:(KKNavigationItemType)type;
- (void)setItemWithNavigationItem:(UINavigationItem *)navigationItem itemType:(KKNavigationItemType)type;
- (void)addTarget:(id)target action:(SEL)selector forControlEvents:(UIControlEvents)event;
- (void)addTarget:(id)target action:(void(^)(id target, id sender))action;
- (void)addTarget:(id)target event:(UIControlEvents)event action:(void(^)(id target, id sender))action;
@end
@interface UINavigationItem (KKNavigationBarItem)
- (KKNavigationBarItem*)setItemWithTitle:(NSString *)title textColor:(UIColor *)color fontSize:(CGFloat)font itemType:(KKNavigationItemType)type;
- (KKNavigationBarItem*)setItemWithImage:(UIImage *)image size:(CGSize)size itemType:(KKNavigationItemType)type;
- (KKNavigationBarItem*)setItemWithImageUrl:(NSString *)imageUrl size:(CGSize)size itemType:(KKNavigationItemType)type;
- (KKNavigationBarItem*)setItemWithCustomView:(UIView *)customView itemType:(KKNavigationItemType)type;
- (KKNavigationBarItem*)setItemWithSpacerWidth:(CGFloat)width itemType:(KKNavigationItemType)type;
- (KKNavigationBarItem*)changeItemWithImage:(UIImage *)image itemType:(KKNavigationItemType)type;
- (KKNavigationBarItem*)changeItemWithImageUrl:(NSString *)imageUrl itemType:(KKNavigationItemType)type;
@end
@interface UIViewController (KKNavigationBarItem)
- (UIView*)navigationBarKK;
- (KKNavigationBarItem*)navigationItemKK;
- (KKNavigationBarItem*)navigationLeftItem;
- (KKNavigationBarItem*)navigationRightItem;
@end
