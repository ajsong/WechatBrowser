//
//  AJEditAction.h
//
//  Created by ajsong on 2016/10/10.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
	AJEditActionDeleteTypeNormal = 0,
	AJEditActionDeleteTypeFade,
	AJEditActionDeleteTypeLeft,
	AJEditActionDeleteTypeRight,
} AJEditActionDeleteType;

@protocol AJEditActionDelegate;

@interface AJEditAction : UIView
@property (nonatomic,weak) id<AJEditActionDelegate> delegate;
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) NSArray *rowActions;
@property (nonatomic,strong) NSMutableArray *leftActions;
@property (nonatomic,strong) NSMutableArray *rightActions;
@property (nonatomic,strong) UIButton *restoreBtn;
@property (nonatomic,assign) BOOL isOpening;
- (void)showRightButtons;
- (void)showLeftButtons;
- (void)restoreWithAction:(void (^)(AJEditAction *editView))action;
- (void)deleteWithAction:(void (^)(AJEditAction *editView))action;
- (void)deleteWithType:(AJEditActionDeleteType)type action:(void (^)(AJEditAction *editView))action;
@end

@protocol AJEditActionDelegate<NSObject>
@optional
- (NSArray*)AJEditActions:(AJEditAction*)editView;
- (void)AJEditAction:(AJEditAction*)editView scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)AJEditAction:(AJEditAction*)editView scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)AJEditAction:(AJEditAction*)editView scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (NSInteger)AJEditActionLeftOperateOfButtonIndex:(AJEditAction*)editView;
- (NSInteger)AJEditActionRightOperateOfButtonIndex:(AJEditAction*)editView;
@end

typedef enum : NSInteger {
	AJRowActionTypeRight = 0,
	AJRowActionTypeLeft,
} AJRowActionType;

@interface AJRowAction : NSObject
@property (nonatomic,assign) AJRowActionType type;
@property (nonatomic,strong) UIButton *btn;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) UIColor *titleColor;
@property (nonatomic,strong) UIFont *font;
@property (nonatomic,strong) UIImage *ico;
@property (nonatomic,strong) UIColor *backgroundColor;
@property (nonatomic,copy) void (^action)(AJEditAction *editView, AJRowAction *rowAction);
+ (AJRowAction*)rowActionWithTitle:(NSString*)title titleColor:(UIColor*)titleColor font:(UIFont*)font backgroundColor:(UIColor*)backgroundColor action:(void (^)(AJEditAction *editView, AJRowAction *rowAction))action;
+ (AJRowAction*)rowActionWithIco:(UIImage*)ico backgroundColor:(UIColor*)backgroundColor action:(void (^)(AJEditAction *editView, AJRowAction *rowAction))action;
+ (AJRowAction*)rowActionWithAction:(void (^)(AJEditAction *editView, AJRowAction *rowAction))action;
@end
