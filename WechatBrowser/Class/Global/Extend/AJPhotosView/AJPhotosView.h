//
//  AJPhotosView.h
//
//  Created by ajsong on 15/10/18.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AJPHOTOS_CONTROL_HEIGHT 20

@class AJPhotosView;

@protocol AJPhotosDataSource<NSObject>
@required
- (NSInteger)AJPhotosViewNumberOfPages:(AJPhotosView*)photosView; //页数
- (UIView*)AJPhotosView:(AJPhotosView*)photosView viewAtIndex:(NSInteger)index; //每页视图
@optional
- (void)AJPhotosViewNullPages:(AJPhotosView*)photosView; //没有页数
@end

@protocol AJPhotosDelegate<NSObject>
@optional
- (void)AJPhotosView:(AJPhotosView*)photosView panLeftEdge:(UIPanGestureRecognizer*)panParam; //滑动左边界时传递手势
- (void)AJPhotosView:(AJPhotosView*)photosView panRightEdge:(UIPanGestureRecognizer*)panParam; //滑动右边界时传递手势
- (void)AJPhotosView:(AJPhotosView*)photosView scrollViewDidEndDecelerating:(UIScrollView*)scrollView viewAtIndex:(NSInteger)index;
- (void)AJPhotosView:(AJPhotosView*)photosView scrollViewWillBeginDragging:(UIScrollView*)scrollView viewAtIndex:(NSInteger)index;
- (void)AJPhotosView:(AJPhotosView*)photosView scrollViewDidEndDragging:(UIScrollView*)scrollView viewAtIndex:(NSInteger)index;
@end

typedef enum : NSInteger {
	AJPhotosControlPositionCenter = 0, //居中
	AJPhotosControlPositionLeft, //居左
	AJPhotosControlPositionRight, //居右
	AJPhotosControlPositionNone, //隐藏
} AJPhotosControlPosition;

@interface AJPhotosView : UIView
@property (nonatomic,retain) id<AJPhotosDataSource> dataSource;
@property (nonatomic,retain) id<AJPhotosDelegate> delegate;
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,assign) NSTimeInterval scrollTime; //滚动间隔
@property (nonatomic,assign) NSInteger index; //当前页索引
@property (nonatomic,retain) UIPageControl *pageControl; //点容器
@property (nonatomic,assign) AJPhotosControlPosition controlPosition; //点位置
@property (nonatomic,retain) UIColor *pageIndicatorTintColor; //点默认颜色
@property (nonatomic,retain) UIColor *currentPageIndicatorTintColor; //点当前颜色
@property (nonatomic,assign) CGFloat pageControlMarginBottom; //点距离底部高度
@property (nonatomic,assign) BOOL autoHidden; //只有一页时自动隐藏点容器,默认YES
@property (nonatomic,assign) BOOL loop; //循环滚动,默认YES
@property (nonatomic,assign) CGFloat margin; //scrollView距离AJPhotosView两侧的间隔
- (void)scrollToPrevPage;
- (void)scrollToNextPage;
- (void)scrollToPage:(NSInteger)index;
- (void)start;
- (void)stop;
- (void)reloadData;
@end
