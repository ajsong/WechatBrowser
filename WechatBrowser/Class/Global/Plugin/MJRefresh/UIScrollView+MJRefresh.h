//
//  UIScrollView+MJRefresh.h
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"

@interface UIScrollView (MJRefreshExtend)
@property (nonatomic,weak) MJRefreshHeaderView *header;
@property (nonatomic,weak) MJRefreshFooterView *footer;
@property (nonatomic,weak) UIView *headerView;
@property (nonatomic,weak) UIView *footerNoMore; //尾部提示

#pragma mark - 运行时相关
- (void)MJRefreshAutoContentSize;

//加载效果
- (void)setHeaderLoadingType:(MJRefreshLoadingType)headerLoadingType;
- (void)setFooterLoadingType:(MJRefreshLoadingType)footerLoadingType;
//全局加载效果设置
+ (void)setHeaderLoadingType:(MJRefreshLoadingType)headerLoadingType;
+ (void)setFooterLoadingType:(MJRefreshLoadingType)footerLoadingType;

#pragma mark - 头部控件
/**
 *  添加一个头部控件
 *
 *  @param view 头部控件
 *  @param height 默认显示高度
 *  @param scale 下拉放大
 */
- (void)addHeaderView:(UIView*)view;
- (void)addHeaderView:(UIView*)view scale:(BOOL)scale;
- (void)addHeaderView:(UIView*)view callback:(void (^)(UIView *headerView, CGFloat offsetY))callback;
- (void)addHeaderView:(UIView*)view scale:(BOOL)scale callback:(void (^)(UIView *headerView, CGFloat offsetY))callback;

#pragma mark - 下拉刷新
/**
 *  添加一个下拉刷新头部控件
 *
 *  @param callback 回调
 */
- (void)addHeaderWithCallback:(void (^)(void))callback;

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderWithTarget:(id)target action:(SEL)action;

/**
 *  添加一个下拉刷新头部控件(使用UIActivityIndicatorView)
 *
 *  @param callback 回调
 */
- (void)addHeaderActivityWithStyle:(UIActivityIndicatorViewStyle)style callback:(void (^)(void))callback;

/**
 *  添加一个下拉刷新头部控件(使用UIActivityIndicatorView)
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderActivityWithStyle:(UIActivityIndicatorViewStyle)style target:(id)target action:(SEL)action;

/**
 *  头部控件刷新完毕还原停止动画后执行
 */
- (void)headerDidEndRefreshWithCallback:(void (^)(void))callback;
- (void)headerDidEndRefreshWithTarget:(id)target action:(SEL)action;

/**
 *  移除下拉刷新头部控件
 */
- (void)removeHeader;

/**
 *  主动让下拉刷新头部控件进入刷新状态
 */
- (void)headerBeginRefreshing;

/**
 *  让下拉刷新头部控件停止刷新状态
 */
- (void)headerEndRefreshing;

/**
 *  下拉刷新头部控件的可见性
 */
@property (nonatomic, assign, getter = isHeaderHidden) BOOL headerHidden;

/**
 *  是否正在下拉刷新
 */
@property (nonatomic, assign, readonly, getter = isHeaderRefreshing) BOOL headerRefreshing;

#pragma mark - 上拉刷新
/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param callback 回调
 */
- (void)addFooterWithCallback:(void (^)(void))callback;

/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addFooterWithTarget:(id)target action:(SEL)action;

/**
 *  尾部控件刷新完毕还原停止动画后执行
 */
- (void)footerDidEndRefreshWithCallback:(void (^)(void))callback;
- (void)footerDidEndRefreshWithTarget:(id)target action:(SEL)action;

/**
 *  添加一个尾部提示(一般上拉加载没有数据时显示)
 */
- (void)addFooterNoMoreView:(UIView*)view;
- (void)addFooterNoMoreText:(NSString*)text;

/**
 *  移除上拉刷新尾部控件
 */
- (void)removeFooter;

/**
 *  主动让上拉刷新尾部控件进入刷新状态
 */
- (void)footerBeginRefreshing;

/**
 *  让上拉刷新尾部控件停止刷新状态
 */
- (void)footerEndRefreshing;

/**
 *  上拉刷新头部控件的可见性
 */
@property (nonatomic, assign, getter = isFooterHidden) BOOL footerHidden;

/**
 *  是否正在上拉刷新
 */
@property (nonatomic, assign, readonly, getter = isFooterRefreshing) BOOL footerRefreshing;


#pragma mark - 控件内容设置
/**
 *  设置头部箭头图片
 */
@property (copy, nonatomic) NSString *headerArrowImageName; // 默认:@"blueArrow"

/**
 *  设置头部控件的文字
 */
@property (copy, nonatomic) NSString *headerPullToRefreshText; // 默认:@"下拉可以刷新"
@property (copy, nonatomic) NSString *headerReleaseToRefreshText; // 默认:@"松开立即刷新"
@property (copy, nonatomic) NSString *headerRefreshingText; // 默认:@"正在刷新中..."

/**
 *  设置尾部箭头图片
 */
@property (copy, nonatomic) NSString *footerArrowImageName; // 默认:@"blueArrow"

/**
 *  设置尾部控件的文字
 */
@property (copy, nonatomic) NSString *footerPullToRefreshText; // 默认:@"上拉加载更多数据"
@property (copy, nonatomic) NSString *footerReleaseToRefreshText; // 默认:@"松开加载更多数据"
@property (copy, nonatomic) NSString *footerRefreshingText; // 默认:@"正在加载中..."

@end

@interface UIWindow (MJRefreshExtend)
@property (nonatomic, assign) MJRefreshLoadingType headerLoadingType;
@property (nonatomic, assign) MJRefreshLoadingType footerLoadingType;
@end
