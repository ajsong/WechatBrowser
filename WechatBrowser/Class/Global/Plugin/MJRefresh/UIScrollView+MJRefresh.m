//
//  UIScrollView+MJRefresh.m
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "MJRefreshConst.h"
#import "UIScrollView+MJRefresh.h"
#import "UIView+MJRefreshExtension.h"

#define MJRefreshFooterNoMoreHeight (64.f*SCREEN_SCALE)

@implementation UIScrollView (MJRefreshExtend)

#pragma mark - 运行时相关
static char MJRefreshHeaderViewKey;
static char MJRefreshFooterViewKey;
static char MJHeaderViewKey;
static char MJRefreshFooterNoMoreKey;

- (MJRefreshHeaderView *)header{
	return objc_getAssociatedObject(self, &MJRefreshHeaderViewKey);
}
- (void)setHeader:(MJRefreshHeaderView *)header {
	[[self viewWithTag:MJRefreshViewTag] removeFromSuperview];
	[self addSubview:header];
	CGRect frame = header.frame;
	frame.size.width = self.frame.size.width;
	frame.origin.x = 0;
	frame.origin.y = -self.contentInset.top - frame.size.height;
	header.frame = frame;
	((UIViewController*)[self viewController:header]).edgesForExtendedLayout = UIRectEdgeNone;
	if (![self isKindOfClass:[UITableView class]] && ![self isKindOfClass:[UICollectionView class]]) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				if (self.contentSize.height+self.contentInset.top+self.contentInset.bottom <= self.frame.size.height) {
					self.contentSize = CGSizeMake(self.contentSize.width, self.frame.size.height-(self.contentInset.top+self.contentInset.bottom)+0.5);
				}
			});
		});
	}
	[self willChangeValueForKey:@"MJRefreshHeaderViewKey"];
	objc_setAssociatedObject(self, &MJRefreshHeaderViewKey, header, OBJC_ASSOCIATION_ASSIGN);
	[self didChangeValueForKey:@"MJRefreshHeaderViewKey"];
}

- (MJRefreshFooterView *)footer{
	return objc_getAssociatedObject(self, &MJRefreshFooterViewKey);
}
- (void)setFooter:(MJRefreshFooterView *)footer {
	[[self viewWithTag:MJRefreshViewTag+1] removeFromSuperview];
	[self addSubview:footer];
	CGRect frame = footer.frame;
	frame.size.width = self.frame.size.width;
	frame.origin.x = 0;
	frame.origin.y = self.frame.size.height;
	footer.frame = frame;
	[self willChangeValueForKey:@"MJRefreshFooterViewKey"];
	objc_setAssociatedObject(self, &MJRefreshFooterViewKey, footer, OBJC_ASSOCIATION_ASSIGN);
	[self didChangeValueForKey:@"MJRefreshFooterViewKey"];
}

- (UIView *)headerView{
	return objc_getAssociatedObject(self, &MJHeaderViewKey);
}
- (void)setHeaderView:(UIView *)headerView{
	[self addHeaderView:headerView];
}

- (UIViewController*)viewController:(UIView*)view{
	for (UIView *next = view.superview; next; next = next.superview) {
		UIResponder *nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}
- (void)MJRefreshAutoContentSize{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, MJRefreshsSlowAnimationDuration * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			CGFloat height = self.contentSize.height;
			if (height <= self.frame.size.height-self.contentInset.top-self.contentInset.bottom) {
				height = self.frame.size.height-self.contentInset.top-self.contentInset.bottom + 0.5;
			}
			self.contentSize = CGSizeMake(self.contentSize.width, height);
		});
	});
}

- (MJRefreshLoadingType)headerLoadingType{
	return [self.element[@"headerLoadingType"]integerValue];
}
- (MJRefreshLoadingType)footerLoadingType{
	return [self.element[@"footerLoadingType"]integerValue];
}
- (void)setHeaderLoadingType:(MJRefreshLoadingType)headerLoadingType{
	self.element[@"headerLoadingType"] = @(headerLoadingType);
}
- (void)setFooterLoadingType:(MJRefreshLoadingType)footerLoadingType{
	self.element[@"footerLoadingType"] = @(footerLoadingType);
}

+ (void)setHeaderLoadingType:(MJRefreshLoadingType)headerLoadingType{
	KEYWINDOW.element[@"headerLoadingType"] = @(headerLoadingType);
}
+ (void)setFooterLoadingType:(MJRefreshLoadingType)footerLoadingType{
	KEYWINDOW.element[@"footerLoadingType"] = @(footerLoadingType);
}

#pragma mark - 头部控件
- (void)addHeaderView:(UIView*)view{
	[self addHeaderView:view callback:nil];
}
- (void)addHeaderView:(UIView*)view scale:(BOOL)scale{
	[self addHeaderView:view scale:scale callback:nil];
}
- (void)addHeaderView:(UIView*)view callback:(void (^)(UIView *headerView, CGFloat offsetY))callback{
	[self addHeaderView:view scale:YES callback:callback];
}
- (void)addHeaderView:(UIView*)view scale:(BOOL)scale callback:(void (^)(UIView *headerView, CGFloat offsetY))callback{
	if (view.frame.size.width<self.frame.size.width) return;
	[[self viewWithTag:MJRefreshViewTag-1] removeFromSuperview];
	CGRect frame = view.frame;
	frame.origin.y = -frame.size.height;
	view.frame = frame;
	view.tag = MJRefreshViewTag - 1;
	[self addSubview:view];
	[self performSelector:@selector(sendSubviewToBack:) withObject:view afterDelay:0];
	if ([view isKindOfClass:[UIImageView class]] && view.frame.size.width==self.frame.size.width) {
		view.clipsToBounds = YES;
		((UIImageView*)view).contentMode = UIViewContentModeScaleAspectFill;
	}
	if (scale) {
		for (UIView *subview in view.subviews) {
			if ([subview isKindOfClass:[UIImageView class]] && subview.frame.size.width==self.frame.size.width) {
				subview.clipsToBounds = YES;
				((UIImageView*)subview).contentMode = UIViewContentModeScaleAspectFill;
				[self element:subview][@"top"] = @(subview.frame.origin.y);
				[self element:subview][@"percent"] = @(subview.frame.size.height / view.frame.size.height);
			}
		}
	}
	self.element[@"headerView"] = view;
	self.element[@"headerViewScale"] = @(scale);
	if (callback) self.element[@"headerViewCallback"] = callback;
	[self willChangeValueForKey:@"MJHeaderViewKey"];
	objc_setAssociatedObject(self, &MJHeaderViewKey, view, OBJC_ASSOCIATION_ASSIGN);
	[self didChangeValueForKey:@"MJHeaderViewKey"];
	
	UIEdgeInsets contentInset;
	CGPoint contentOffset;
	if (self.element[@"contentInset"]) {
		contentInset = UIEdgeInsetsFromString(self.element[@"contentInset"]);
		contentOffset = CGPointFromString(self.element[@"contentOffset"]);
	} else {
		contentInset = self.contentInset;
		contentOffset = self.contentOffset;
		self.element[@"contentInset"] = NSStringFromUIEdgeInsets(contentInset);
		self.element[@"contentOffset"] = NSStringFromCGPoint(contentOffset);
	}
	contentInset.top += frame.size.height;
	self.contentInset = contentInset;
	contentOffset.y -= frame.size.height;
	self.contentOffset = contentOffset;
	
	if (self.header) {
		CGRect frame = self.header.frame;
		frame.origin.y = -self.contentInset.top - frame.size.height;
		self.header.frame = frame;
	}
	
	[self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	CGPoint newOffset = [change[@"new"] CGPointValue];
	[self scrollViewDidScroll:newOffset];
}
- (void)scrollViewDidScroll:(CGPoint)contentOffset{
	UIView *view = self.element[@"headerView"];
	if (!view) return;
	BOOL scale = [self.element[@"headerViewScale"] boolValue];
	void (^callback)(UIView *headerView, CGFloat offsetY) = self.element[@"headerViewCallback"];
	CGFloat offsetY = contentOffset.y;
	if (scale) {
		if (offsetY>0) offsetY = 0;
		CGRect frame = view.frame;
		frame.size.height = fabs(offsetY);
		frame.origin.y = -frame.size.height;
		view.frame = frame;
		for (UIView *subview in view.subviews) {
			if ([subview isKindOfClass:[UIImageView class]] && subview.frame.size.width==self.frame.size.width) {
				CGFloat percent = [[self element:subview][@"percent"]floatValue];
				CGRect rect = subview.frame;
				rect.origin.y = [[self element:subview][@"top"]floatValue] * percent;
				rect.size.height = frame.size.height * percent;
				subview.frame = rect;
			}
		}
	}
	if (callback) callback(view, offsetY);
}
- (NSMutableDictionary*)element{
	return [self element:self];
}
- (NSMutableDictionary*)element:(UIView*)view{
	NSMutableDictionary *ele = objc_getAssociatedObject(view, @"MJRefreshElement");
	if (!ele) {
		ele = [[NSMutableDictionary alloc]init];
		objc_setAssociatedObject(view, @"MJRefreshElement", ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return ele;
}
- (CGSize)fitToSize:(CGSize)size originSize:(CGSize)origin{
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat iw = origin.width;
	CGFloat ih = origin.height;
	CGFloat nw = iw;
	CGFloat nh = ih;
	if (iw>0 && ih>0) {
		if (width>0 && height>0) {
			if (iw<=width && ih<=height) {
				nw = iw;
				nh = ih;
			} else {
				if (iw/ih >= width/height) {
					if (iw>width) {
						nw = width;
						nh = (ih*width)/iw;
					}
				} else {
					if (ih>height) {
						nw = (iw*height)/ih;
						nh = height;
					}
				}
			}
		} else {
			if (width==0 && height>0) {
				nw = (iw*height)/ih;
				nh = height;
			} else if (width>0 && height==0) {
				nw = width;
				nh = (ih*width)/iw;
			}
		}
	}
	if (width>0) {
		if (width>nw) {
			size = CGSizeMake(nw, size.height);
		}
	} else {
		size = CGSizeMake(nw, size.height);
	}
	if (height>0) {
		if (height>nh) {
			size = CGSizeMake(size.width, nh);
		}
	} else {
		size = CGSizeMake(size.width, nh);
	}
	return size;
}

#pragma mark - 下拉刷新
/**
 *  添加一个下拉刷新头部控件
 *
 *  @param callback 回调
 */
- (void)addHeaderWithCallback:(void (^)(void))callback
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			// 1.创建新的header
			if (!self.header) {
				MJRefreshHeaderView *header = [MJRefreshHeaderView header];
				header.backgroundColor = [UIColor clearColor];
				header.tag = MJRefreshViewTag;
				if (self.headerLoadingType==MJRefreshLoadingTypeNone) {
					if (KEYWINDOW.headerLoadingType==MJRefreshLoadingTypeNone) {
						header.loadingType = MJRefreshLoadingTypeWrite;
					} else {
						header.loadingType = KEYWINDOW.headerLoadingType;
					}
				}
				self.header = header;
			}
			
			// 2.设置block回调
			self.header.beginRefreshingCallback = callback;
			
			self.headerHidden = YES;
			
			self.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, self.contentInset.bottom, 0.0f);
		});
	});
}

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderWithTarget:(id)target action:(SEL)action
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			// 1.创建新的header
			if (!self.header) {
				MJRefreshHeaderView *header = [MJRefreshHeaderView header];
				header.backgroundColor = [UIColor clearColor];
				header.tag = MJRefreshViewTag;
				if (self.headerLoadingType==MJRefreshLoadingTypeNone) {
					if (KEYWINDOW.headerLoadingType==MJRefreshLoadingTypeNone) {
						header.loadingType = MJRefreshLoadingTypeWrite;
					} else {
						header.loadingType = KEYWINDOW.headerLoadingType;
					}
				}
				self.header = header;
			}
			
			// 2.设置目标和回调方法
			self.header.beginRefreshingTaget = target;
			self.header.beginRefreshingAction = action;
			
			self.headerHidden = YES;
			
			self.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, self.contentInset.bottom, 0.0f);
		});
	});
}

/**
 *  添加一个下拉刷新头部控件(使用UIActivityIndicatorView)
 *
 *  @param callback 回调
 */
- (void)addHeaderActivityWithStyle:(UIActivityIndicatorViewStyle)style callback:(void (^)(void))callback
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!self.header) {
				UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:style];
				self.header = [MJRefreshHeaderView createWithFrame:CGRectZero subviews:^(MJRefreshHeaderView *headerView) {
					[headerView addSubview:activity];
					CGRect frame = activity.frame;
					frame.origin = CGPointMake((headerView.width-activity.width)/2, (headerView.height-activity.height)/2);
					activity.frame = frame;
					[activity startAnimating];
				} changeState:^(MJRefreshStates state, MJRefreshHeaderView *headerView) {
					switch (state) {
						case MJRefreshStatesRefreshing:{
							[activity startAnimating];
							break;
						}
						default:
							break;
					}
				}];
			}
			
			self.header.beginRefreshingCallback = callback;
			
			self.headerHidden = YES;
			
			self.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, self.contentInset.bottom, 0.0f);
		});
	});
}

/**
 *  添加一个下拉刷新头部控件(使用UIActivityIndicatorView)
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderActivityWithStyle:(UIActivityIndicatorViewStyle)style target:(id)target action:(SEL)action
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!self.header) {
				UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:style];
				self.header = [MJRefreshHeaderView createWithFrame:CGRectZero subviews:^(MJRefreshHeaderView *headerView) {
					[headerView addSubview:activity];
					CGRect frame = activity.frame;
					frame.origin = CGPointMake((headerView.width-activity.width)/2, (headerView.height-activity.height)/2);
					activity.frame = frame;
					[activity startAnimating];
				} changeState:^(MJRefreshStates state, MJRefreshHeaderView *headerView) {
					switch (state) {
						case MJRefreshStatesRefreshing:{
							[activity startAnimating];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
							if (target && [target respondsToSelector:action]) {
								[target performSelector:action withObject:nil];
							}
#pragma clang diagnostic pop
							break;
						}
						default:
							break;
					}
				}];
			}
			
			self.headerHidden = YES;
			
			self.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, self.contentInset.bottom, 0.0f);
		});
	});
}

/**
 *  头部控件刷新完毕还原停止动画后执行
 */
- (void)headerDidEndRefreshWithCallback:(void (^)(void))callback{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			self.header.didEndRefreshCallback = callback;
		});
	});
}
- (void)headerDidEndRefreshWithTarget:(id)target action:(SEL)action{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			self.header.didEndRefreshTaget = target;
			self.header.didEndRefreshAction = action;
		});
	});
}

/**
 *  移除下拉刷新头部控件
 */
- (void)removeHeader
{
	[self.header removeFromSuperview];
	self.header = nil;
}

/**
 *  主动让下拉刷新头部控件进入刷新状态
 */
- (void)headerBeginRefreshing
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!self.header) return;
			self.headerHidden = NO;
			if (self.footer) self.footerHidden = NO;
			[self.header beginRefreshing];
		});
	});
}

/**
 *  让下拉刷新头部控件停止刷新状态
 */
- (void)headerEndRefreshing
{
	if (!self.header) return;
	[self.header endRefreshing];
	if (self.footer) [self performSelector:@selector(footerHandle) withObject:nil afterDelay:0.0];
}

/**
 *  下拉刷新头部控件的可见性
 */
- (void)setHeaderHidden:(BOOL)hidden
{
	self.header.hidden = hidden;
}

- (BOOL)isHeaderHidden
{
	return self.header.isHidden;
}

- (BOOL)isHeaderRefreshing
{
	return self.header.state == MJRefreshStatesRefreshing;
}

/**
 *  箭头图片
 */
- (void)setHeaderArrowImageName:(NSString *)headerArrowImageName
{
	self.header.arrowImageName = headerArrowImageName;
}

- (NSString *)headerArrowImageName
{
	return self.header.arrowImageName;
}

/**
 *  文字
 */
- (void)setHeaderPullToRefreshText:(NSString *)headerPullToRefreshText
{
	self.header.pullToRefreshText = headerPullToRefreshText;
}

- (NSString *)headerPullToRefreshText
{
	return self.header.pullToRefreshText;
}

- (void)setHeaderReleaseToRefreshText:(NSString *)headerReleaseToRefreshText
{
	self.header.releaseToRefreshText = headerReleaseToRefreshText;
}

- (NSString *)headerReleaseToRefreshText
{
	return self.header.releaseToRefreshText;
}

- (void)setHeaderRefreshingText:(NSString *)headerRefreshingText
{
	self.header.refreshingText = headerRefreshingText;
}

- (NSString *)headerRefreshingText
{
	return self.header.refreshingText;
}

#pragma mark - 上拉刷新
/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param callback 回调
 */
- (void)addFooterWithCallback:(void (^)(void))callback
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			// 1.创建新的footer
			if (!self.footer) {
				[[self viewWithTag:MJRefreshViewTag+1] removeFromSuperview];
				MJRefreshFooterView *footer = [MJRefreshFooterView footer];
				footer.backgroundColor = [UIColor clearColor];
				footer.tag = MJRefreshViewTag + 1;
				if (self.footerLoadingType==MJRefreshLoadingTypeNone) {
					if (KEYWINDOW.footerLoadingType==MJRefreshLoadingTypeNone) {
						footer.loadingType = MJRefreshLoadingTypeActivity;
					} else {
						footer.loadingType = KEYWINDOW.footerLoadingType;
					}
				}
				self.footer = footer;
			}
			
			// 2.设置block回调
			self.footer.beginRefreshingCallback = callback;
			
			self.footerHidden = YES;
			
			self.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, self.contentInset.bottom, 0.0f);
		});
	});
}

/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addFooterWithTarget:(id)target action:(SEL)action
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			// 1.创建新的footer
			if (!self.footer) {
				MJRefreshFooterView *footer = [MJRefreshFooterView footer];
				footer.backgroundColor = [UIColor clearColor];
				footer.tag = MJRefreshViewTag + 1;
				if (self.footerLoadingType==MJRefreshLoadingTypeNone) {
					if (KEYWINDOW.footerLoadingType==MJRefreshLoadingTypeNone) {
						footer.loadingType = MJRefreshLoadingTypeActivity;
					} else {
						footer.loadingType = KEYWINDOW.footerLoadingType;
					}
				}
				self.footer = footer;
			}
			
			// 2.设置目标和回调方法
			self.footer.beginRefreshingTaget = target;
			self.footer.beginRefreshingAction = action;
			
			self.footerHidden = YES;
			
			self.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, self.contentInset.bottom, 0.0f);
		});
	});
}

/**
 *  尾部控件刷新完毕还原停止动画后执行
 */
- (void)footerDidEndRefreshWithCallback:(void (^)(void))callback{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			self.footer.didEndRefreshCallback = callback;
		});
	});
}
- (void)footerDidEndRefreshWithTarget:(id)target action:(SEL)action{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			self.footer.didEndRefreshTaget = target;
			self.footer.didEndRefreshAction = action;
		});
	});
}

/**
 *  添加一个尾部提示(一般上拉加载没有数据时显示)
 */
- (void)setFooterNoMore:(UILabel *)footerNoMore{
	[self willChangeValueForKey:@"MJRefreshFooterNoMoreKey"];
	objc_setAssociatedObject(self, &MJRefreshFooterNoMoreKey, footerNoMore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"MJRefreshFooterNoMoreKey"];
}
- (UIView *)footerNoMore{
	return objc_getAssociatedObject(self, &MJRefreshFooterNoMoreKey);
}
- (void)addFooterNoMoreView:(UIView*)view{
	CGRect frame = view.frame;
	if (self.footerNoMore) {
		for (UIView *subview in self.footerNoMore.subviews) {
			[subview removeFromSuperview];
		}
		frame.origin.y = 0;
		view.frame = frame;
		[self.footerNoMore addSubview:view];
		self.footerNoMore.frame = CGRectMake(0, self.contentSize.height, self.frame.size.width, frame.size.height);
	} else {
		[[self viewWithTag:MJRefreshViewTag+2] removeFromSuperview];
		UIView *footerNoMore = [[UIView alloc]initWithFrame:CGRectZero];
		footerNoMore.hidden = YES;
		footerNoMore.tag = MJRefreshViewTag + 2;
		self.footerNoMore = footerNoMore;
		frame.origin.y = 0;
		view.frame = frame;
		[self.footerNoMore addSubview:view];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				self.footerNoMore.frame = CGRectMake(0, self.contentSize.height, self.frame.size.width, frame.size.height);
				[self insertSubview:self.footerNoMore belowSubview:self];
			});
		});
	}
}
- (void)addFooterNoMoreText:(NSString*)text{
	if (!text.length) return;
	UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, MJRefreshFooterNoMoreHeight)];
	footerLabel.text = text;
	footerLabel.textColor = [UIColor colorWithRed:204/255.f green:204/255.f blue:204/255.f alpha:1.f];
	footerLabel.textAlignment = NSTextAlignmentCenter;
	footerLabel.font = FONT(12);
	footerLabel.backgroundColor = [UIColor clearColor];
	[self addFooterNoMoreView:footerLabel];
}

/**
 *  移除上拉刷新尾部控件
 */
- (void)removeFooter
{
	[self.footer removeFromSuperview];
	self.footer = nil;
}

/**
 *  主动让上拉刷新尾部控件进入刷新状态
 */
- (void)footerBeginRefreshing
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!self.footer) return;
			[self.footer beginRefreshing];
		});
	});
}

/**
 *  让上拉刷新尾部控件停止刷新状态
 */
- (void)footerEndRefreshing
{
	if (!self.footer) return;
	[self.footer endRefreshing];
	
	CGFloat originContentSizeHeight = self.footer.scrollViewContentSizeHeight;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (originContentSizeHeight >= self.contentSize.height) {
				self.footerHidden = YES;
				self.footerNoMore.hidden = NO;
				self.footerNoMore.frame = CGRectMake(0, self.contentSize.height, self.frame.size.width, MJRefreshFooterNoMoreHeight);
			}
		});
	});
}

/**
 *  上拉刷新头部控件的可见性
 */
- (void)setFooterHidden:(BOOL)hidden
{
	self.footer.hidden = hidden;
}

- (BOOL)isFooterHidden
{
	return self.footer.isHidden;
}

- (BOOL)isFooterRefreshing
{
	return self.footer.state == MJRefreshStatesRefreshing;
}

/**
 *  判断尾部控件是否应该隐藏
 */
- (void)footerHandle{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.contentSize.height + self.footer.scrollViewOriginalInset.top + self.footer.scrollViewOriginalInset.bottom <= self.frame.size.height) {
				self.footerHidden = YES;
				self.footerNoMore.hidden = YES;
			} else {
				self.footerHidden = NO;
				CGRect frame = self.footer.frame;
				frame.origin.y = self.contentSize.height<self.frame.size.height ? self.frame.size.height : self.contentSize.height;
				self.footer.frame = frame;
			}
		});
	});
}

/**
 *  箭头图片
 */
- (void)setFooterArrowImageName:(NSString *)footerArrowImageName
{
	self.footer.arrowImageName = footerArrowImageName;
}

- (NSString *)footerArrowImageName
{
	return self.footer.arrowImageName;
}

/**
 *  文字
 */
- (void)setFooterPullToRefreshText:(NSString *)footerPullToRefreshText
{
	self.footer.pullToRefreshText = footerPullToRefreshText;
}

- (NSString *)footerPullToRefreshText
{
	return self.footer.pullToRefreshText;
}

- (void)setFooterReleaseToRefreshText:(NSString *)footerReleaseToRefreshText
{
	self.footer.releaseToRefreshText = footerReleaseToRefreshText;
}

- (NSString *)footerReleaseToRefreshText
{
	return self.footer.releaseToRefreshText;
}

- (void)setFooterRefreshingText:(NSString *)footerRefreshingText
{
	self.footer.refreshingText = footerRefreshingText;
}

- (NSString *)footerRefreshingText
{
	return self.footer.refreshingText;
}

@end

@implementation UIWindow (MJRefreshExtend)
- (MJRefreshLoadingType)headerLoadingType{
	return [objc_getAssociatedObject(self, _cmd) integerValue];
}
- (void)setHeaderLoadingType:(MJRefreshLoadingType)headerLoadingType{
	objc_setAssociatedObject(self, @selector(headerLoadingType), @(headerLoadingType), OBJC_ASSOCIATION_ASSIGN);
}
- (MJRefreshLoadingType)footerLoadingType{
	return [objc_getAssociatedObject(self, _cmd) integerValue];
}
- (void)setFooterLoadingType:(MJRefreshLoadingType)footerLoadingType{
	objc_setAssociatedObject(self, @selector(footerLoadingType), @(footerLoadingType), OBJC_ASSOCIATION_ASSIGN);
}
@end
