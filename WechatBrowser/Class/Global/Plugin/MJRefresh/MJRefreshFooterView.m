//
//  MJRefreshFooterView.m
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJRefreshConst.h"
#import "MJRefreshFooterView.h"
#import "UIView+MJRefreshExtension.h"
#import "UIScrollView+MJRefreshExtension.h"

@interface MJRefreshFooterView()
@property (assign, nonatomic) int lastRefreshCount;
@end

@implementation MJRefreshFooterView

+ (instancetype)footer
{
	return [[MJRefreshFooterView alloc] init];
}

+ (MJRefreshFooterView*)createWithFrame:(CGRect)frame subviews:(void (^)(MJRefreshBaseView *))subviews changeState:(void (^)(MJRefreshStates, MJRefreshBaseView *))changeState{
	MJRefreshFooterView *footerView = [[MJRefreshFooterView alloc]initWithFrame:frame];
	if (subviews) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				subviews(footerView);
			});
		});
	}
	if (changeState) footerView.changeState = changeState;
	return footerView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self initialize];
	}
	return self;
}

- (void)initialize{
	switch (self.loadingType) {
		case MJRefreshLoadingTypeNormal:{
			self.arrowImageName = MJRefreshArrowImageName;
			self.pullToRefreshText = MJRefreshFooterPullToRefresh;
			self.releaseToRefreshText = MJRefreshFooterReleaseToRefresh;
			self.refreshingText = MJRefreshFooterRefreshing;
			break;
		}
		default:{
			
			break;
		}
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	switch (self.loadingType) {
		case MJRefreshLoadingTypeWrite:{
			return;
			break;
		}
		default:{
			
			break;
		}
	}
	[self initialize];
	
	self.statusLabel.frame = self.bounds;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	// 旧的父控件
	[self.superview removeObserver:self forKeyPath:MJRefreshContentSize context:nil];
	
	if (newSuperview) { // 新的父控件
		// 监听
		[newSuperview addObserver:self forKeyPath:MJRefreshContentSize options:NSKeyValueObservingOptionNew context:nil];
		/*
		if (isX) {
			UIEdgeInsets insets = self.scrollView.contentInset;
			insets.bottom -= 34;
			self.scrollView.contentInset = insets;
			self.scrollViewOriginalInset = self.scrollView.contentInset;
		}
		*/
		// 重新调整frame
		[self adjustFrameWithContentSize];
	}
}

#pragma mark 重写调整frame
- (void)adjustFrameWithContentSize
{
	// 内容的高度
	CGFloat contentHeight = self.scrollView.mj_contentSizeHeight;
	// 表格的高度
	CGFloat scrollHeight = self.scrollView.mj_height - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom;
	// 设置位置和尺寸
	self.mj_y = MAX(contentHeight, scrollHeight);
}

#pragma mark 监听UIScrollView的属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// 不能跟用户交互，直接返回
	if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
	
	if ([MJRefreshContentSize isEqualToString:keyPath]) {
		// 调整frame
		[self adjustFrameWithContentSize];
	} else if ([MJRefreshContentOffset isEqualToString:keyPath]) {
		//这个返回一定要放这个位置
		// 如果正在刷新，直接返回
		if (self.state == MJRefreshStatesRefreshing) return;
		
		// 调整状态
		[self adjustStateWithContentOffset];
	}
}

/**
 *  调整状态
 */
- (void)adjustStateWithContentOffset
{
	// 当前的contentOffset
	CGFloat currentOffsetY = self.scrollView.mj_contentOffsetY;
	// 尾部控件刚好出现的offsetY
	CGFloat happenOffsetY = [self happenOffsetY];
	
	// 如果是向下滚动到看不见尾部控件，直接返回
	if (currentOffsetY <= happenOffsetY) return;
	
	if (self.scrollView.isDragging) {
		// 普通 和 即将刷新 的临界点
		CGFloat normal2pullingOffsetY = happenOffsetY + self.mj_height;
		
		if (self.state == MJRefreshStatesNormal && currentOffsetY > normal2pullingOffsetY) {
			// 转为即将刷新状态
			self.state = MJRefreshStatesPulling;
		} else if (self.state == MJRefreshStatesPulling && currentOffsetY <= normal2pullingOffsetY) {
			// 转为普通状态
			self.state = MJRefreshStatesNormal;
		}
		
		switch (self.loadingType) {
			case MJRefreshLoadingTypeWrite:{
				//当前拖拽比例
				CGFloat dropRate = - currentOffsetY / self.mj_height;
				dropRate = MAX(MIN(dropRate, 1), 0);
				self.pullingProgress = dropRate;
				return;
				break;
			}
			default:{
				
				break;
			}
		}
		if (self.images) {
			CGFloat currentY = currentOffsetY-(self.scrollView.mj_contentSizeHeight-self.scrollView.mj_height)-self.scrollView.mj_contentInsetBottom;
			NSInteger rate = (int)fabs(self.mj_height / self.images.count);
			NSInteger currentIndex = (int)fabs(fmod(currentY, self.mj_height) / rate);
			if (currentIndex > self.images.count-1) currentIndex -= self.images.count;
			self.imagesView.image = self.images[currentIndex];
		}
	} else if (self.state == MJRefreshStatesPulling) {// 即将刷新 && 手松开
		// 开始刷新
		self.state = MJRefreshStatesRefreshing;
		
		switch (self.loadingType) {
			case MJRefreshLoadingTypeWrite:{
				return;
				break;
			}
			default:{
				
				break;
			}
		}
		if (self.images) {
			if (self.gif) {
				self.imagesView.hidden = YES;
				self.gifView.hidden = NO;
			} else {
				self.imagesView.animationImages = self.images;
				[self.imagesView startAnimating];
			}
		}
	}
}

#pragma mark - 状态相关
#pragma mark 设置状态
- (void)setState:(MJRefreshStates)state
{
	// 1.一样的就直接返回
	if (self.state == state) return;
	
	// 2.保存旧状态
	MJRefreshStates oldState = self.state;
	
	// 3.调用父类方法
	[super setState:state];
	
	// 4.根据状态来设置属性
	switch (state)
	{
		case MJRefreshStatesNormal:
		{
			// 刷新完毕
			if (MJRefreshStatesRefreshing == oldState) {
				switch (self.loadingType) {
					case MJRefreshLoadingTypeNormal:{
						self.arrowImage.transform = CGAffineTransformIdentity;
						break;
					}
					default:{
						
						break;
					}
				}
				[UIView animateWithDuration:MJRefreshsSlowAnimationDuration animations:^{
					self.scrollView.mj_contentInsetBottom = self.scrollViewOriginalInset.bottom;
				}];
			} else {
				switch (self.loadingType) {
					case MJRefreshLoadingTypeNormal:{
						// 执行动画
						[UIView animateWithDuration:MJRefreshsFastAnimationDuration animations:^{
							self.arrowImage.transform = CGAffineTransformIdentity;
						}];
						break;
					}
					default:{
						
						break;
					}
				}
			}
			
			CGFloat deltaH = [self heightForContentBreakView];
			int currentCount = [self totalDataCountInScrollView];
			// 刚刷新完毕
			if (MJRefreshStatesRefreshing == oldState && deltaH > 0 && currentCount != self.lastRefreshCount) {
				self.scrollView.mj_contentOffsetY = self.scrollView.mj_contentOffsetY;
			}
			break;
		}
			
		case MJRefreshStatesPulling:
		{
			switch (self.loadingType) {
				case MJRefreshLoadingTypeNormal:{
					[UIView animateWithDuration:MJRefreshsFastAnimationDuration animations:^{
						self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
					}];
					break;
				}
				default:{
					
					break;
				}
			}
			break;
		}
			
		case MJRefreshStatesRefreshing:
		{
			// 记录刷新前的数量
			self.lastRefreshCount = [self totalDataCountInScrollView];
			
			[UIView animateWithDuration:MJRefreshsFastAnimationDuration animations:^{
				CGFloat bottom = self.mj_height + self.scrollViewOriginalInset.bottom;
				CGFloat deltaH = [self heightForContentBreakView];
				if (deltaH < 0) { // 如果内容高度小于view的高度
					bottom -= deltaH;
				}
				self.scrollView.mj_contentInsetBottom = bottom;
			}];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.scrollView layoutIfNeeded];
				if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
					self.scrollViewContentSizeHeight = ((UICollectionView*)self.scrollView).collectionViewLayout.collectionViewContentSize.height;
				} else {
					self.scrollViewContentSizeHeight = self.scrollView.contentSize.height;
				}
			});
			break;
		}
			
		default:
			break;
	}
}

- (int)totalDataCountInScrollView
{
	int totalCount = 0;
	if ([self.scrollView isKindOfClass:[UITableView class]]) {
		UITableView *tableView = (UITableView *)self.scrollView;
		
		for (int section = 0; section<tableView.numberOfSections; section++) {
			totalCount += [tableView numberOfRowsInSection:section];
		}
	} else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
		UICollectionView *collectionView = (UICollectionView *)self.scrollView;
		
		for (int section = 0; section<collectionView.numberOfSections; section++) {
			totalCount += [collectionView numberOfItemsInSection:section];
		}
	}
	return totalCount;
}

#pragma mark 获得scrollView的内容 超出 view 的高度
- (CGFloat)heightForContentBreakView
{
	CGFloat h = self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top;
	return self.scrollView.contentSize.height - h;
}

#pragma mark - 在父类中用得上
/**
 *  刚好看到上拉刷新控件时的contentOffset.y
 */
- (CGFloat)happenOffsetY
{
	CGFloat deltaH = [self heightForContentBreakView];
	if (deltaH > 0) {
		return deltaH - self.scrollViewOriginalInset.top;
	} else {
		return - self.scrollViewOriginalInset.top;
	}
}

@end
