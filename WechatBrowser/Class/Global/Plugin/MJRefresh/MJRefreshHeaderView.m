//
//  MJRefreshHeaderView.m
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJRefreshConst.h"
#import "MJRefreshHeaderView.h"
#import "UIView+MJRefreshExtension.h"
#import "UIScrollView+MJRefreshExtension.h"

@interface MJRefreshHeaderView()
// 最后的更新时间
@property (nonatomic, strong) NSDate *lastUpdateTime;
@end

@implementation MJRefreshHeaderView

#pragma mark - 控件初始化
/**
 *  时间标签
 */
- (UILabel *)lastUpdateTimeLabel
{
	if (!_lastUpdateTimeLabel) {
		// 1.创建控件
		UILabel *lastUpdateTimeLabel = [[UILabel alloc] init];
		lastUpdateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		lastUpdateTimeLabel.font = FONTBOLD(12);
		lastUpdateTimeLabel.textColor = MJRefreshsLabelTextColor;
		lastUpdateTimeLabel.backgroundColor = self.backgroundColor;
		lastUpdateTimeLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_lastUpdateTimeLabel = lastUpdateTimeLabel];
		[self sendSubviewToBack:_lastUpdateTimeLabel];
		
		// 2.加载时间
		self.lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:MJRefreshHeaderTimeKey];
		
		if (self.images) _lastUpdateTimeLabel.hidden = YES;
	}
	return _lastUpdateTimeLabel;
}

+ (instancetype)header
{
	return [[MJRefreshHeaderView alloc] init];
}

+ (MJRefreshHeaderView*)createWithFrame:(CGRect)frame subviews:(void (^)(MJRefreshHeaderView *))subviews changeState:(void (^)(MJRefreshStates, MJRefreshHeaderView *))changeState{
	MJRefreshHeaderView *headerView = [[MJRefreshHeaderView alloc]initWithFrame:frame];
	if (subviews) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				subviews(headerView);
			});
		});
	}
	if (changeState) headerView.changeState = changeState;
	return headerView;
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
			self.pullToRefreshText = MJRefreshHeaderPullToRefresh;
			self.releaseToRefreshText = MJRefreshHeaderReleaseToRefresh;
			self.refreshingText = MJRefreshHeaderRefreshing;
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
	
	CGFloat statusX = 0;
	CGFloat statusY = 5*SCREEN_SCALE;
	CGFloat statusWidth = self.mj_width;
	CGFloat statusHeight = self.mj_height * 0.5;
	
	// 1.状态标签
	self.statusLabel.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight);
	
	// 2.时间标签
	CGFloat lastUpdateX = 0;
	CGFloat lastUpdateY = statusX + statusHeight;
	CGFloat lastUpdateWidth = statusWidth;
	CGFloat lastUpdateHeight = statusHeight;
	self.lastUpdateTimeLabel.frame = CGRectMake(lastUpdateX, lastUpdateY, lastUpdateWidth, lastUpdateHeight);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	// 设置自己的位置和尺寸
	self.mj_y = - self.mj_height;
}

#pragma mark - 状态相关
#pragma mark 设置最后的更新时间
- (void)setLastUpdateTime:(NSDate *)lastUpdateTime
{
	_lastUpdateTime = lastUpdateTime;
	
	// 1.归档
	[[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:MJRefreshHeaderTimeKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// 2.更新时间
	[self updateTimeLabel];
}

#pragma mark 更新时间字符串
- (void)updateTimeLabel
{
	if (!self.lastUpdateTime) return;
	
	// 1.获得年月日
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
	NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:_lastUpdateTime];
	NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
	
	// 2.格式化日期
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	if ([cmp1 day] == [cmp2 day]) { // 今天
		formatter.dateFormat = @"今天 HH:mm";
	} else if ([cmp1 year] == [cmp2 year]) { // 今年
		formatter.dateFormat = @"MM-dd HH:mm";
	} else {
		formatter.dateFormat = @"yyyy-MM-dd HH:mm";
	}
	NSString *time = [formatter stringFromDate:self.lastUpdateTime];
	
	// 3.显示日期
	self.lastUpdateTimeLabel.text = [NSString stringWithFormat:@"最后更新：%@", time];
}

#pragma mark - 监听UIScrollView的contentOffset属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// 不能跟用户交互就直接返回
	if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
	
	// 如果正在刷新，直接返回
	if (self.state == MJRefreshStatesRefreshing) return;
	
	if ([MJRefreshContentOffset isEqualToString:keyPath]) {
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
	// 头部控件刚好出现的offsetY
	CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
	
	// 如果是向上滚动到看不见头部控件，直接返回
	if (currentOffsetY >= happenOffsetY) return;
	
	if (self.scrollView.isDragging) {
		// 普通 和 即将刷新 的临界点
		CGFloat normal2pullingOffsetY = happenOffsetY - self.mj_height;
		
		if (self.state == MJRefreshStatesNormal && currentOffsetY < normal2pullingOffsetY) {
			// 转为即将刷新状态
			self.state = MJRefreshStatesPulling;
		} else if (self.state == MJRefreshStatesPulling && currentOffsetY >= normal2pullingOffsetY) {
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
			NSInteger rate = (int)fabs(self.mj_height / self.images.count);
			NSInteger currentIndex = (int)fabs(fmod(currentOffsetY, self.mj_height) / rate);
			if (currentIndex > self.images.count-1) currentIndex -= self.images.count;
			self.imagesView.image = self.images[currentIndex];
		}
	} else if (self.state == MJRefreshStatesPulling) {// 即将刷新 && 手松开
		// 开始刷新
		self.state = MJRefreshStatesRefreshing;
		
		UIView *footer = [self.superview viewWithTag:MJRefreshViewTag+1];
		UIView *footerTip = [self.superview viewWithTag:MJRefreshViewTag+2];
		if (footer) footer.hidden = NO;
		if (footerTip) footerTip.hidden = YES;
		
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

#pragma mark 设置状态
- (void)setState:(MJRefreshStates)state
{
	// 1.一样的就直接返回
	if (self.state == state) return;
	
	// 2.保存旧状态
	MJRefreshStates oldState = self.state;
	
	// 3.调用父类方法
	[super setState:state];
	
	// 4.根据状态执行不同的操作
	switch (state) {
		case MJRefreshStatesNormal: // 下拉可以刷新
		{
			// 刷新完毕
			if (MJRefreshStatesRefreshing == oldState) {
				switch (self.loadingType) {
					case MJRefreshLoadingTypeNormal:{
						self.arrowImage.transform = CGAffineTransformIdentity;
						// 保存刷新时间
						self.lastUpdateTime = [NSDate date];
						break;
					}
					default:{
						
						break;
					}
				}
				[UIView animateWithDuration:MJRefreshsSlowAnimationDuration animations:^{
					//这句代码修复了，top值不断累加的bug
					//self.scrollView.mj_contentInsetTop -= self.mj_height;
					self.scrollView.mj_contentInsetTop = self.scrollViewOriginalInset.top;
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
			break;
		}
			
		case MJRefreshStatesPulling: // 松开可立即刷新
		{
			switch (self.loadingType) {
				case MJRefreshLoadingTypeNormal:{
					// 执行动画
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
			
		case MJRefreshStatesRefreshing: // 正在刷新中
		{
			// 执行动画
			[UIView animateWithDuration:MJRefreshsFastAnimationDuration animations:^{
				// 1.增加滚动区域
				CGFloat top = self.scrollViewOriginalInset.top + self.mj_height;
				self.scrollView.mj_contentInsetTop = top;
				
				// 2.设置滚动位置
				self.scrollView.mj_contentOffsetY = -top;
			}];
			break;
		}
			
		default:
			break;
	}
}

@end
