//
//  AJPhotosView.m
//
//  Created by ajsong on 15/10/18.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AJPhotosView.h"

@interface AJPhotosView ()<UIScrollViewDelegate>{
	NSTimer *_pageTimer;
	NSMutableArray *_items;
}
@end

@implementation AJPhotosView

- (instancetype)init{
	self = [super init];
	if (self) {
		self.frame = SCREEN_BOUNDS;
		[self setupUI];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
		[self setupUI];
    }
    return self;
}

- (void)setupUI{
	self.clipsToBounds = YES;
	_items = [[NSMutableArray alloc]init];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	_scrollView.clipsToBounds = NO;
	_scrollView.pagingEnabled = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.scrollsToTop = NO;
	_scrollView.delegate = self;
	[_scrollView.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
	[self addSubview:_scrollView];
	
	_pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - AJPHOTOS_CONTROL_HEIGHT, self.frame.size.width, AJPHOTOS_CONTROL_HEIGHT)];
	_pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
	_pageControl.currentPage = 0;
	_pageControl.backgroundColor = [UIColor clearColor];
	_pageControl.userInteractionEnabled = YES;
	[self addSubview:_pageControl];
	
	_pageTimer = nil;
	_scrollTime = 0;
	_controlPosition = AJPhotosControlPositionCenter;
	_autoHidden = YES;
	_loop = YES;
}

- (void)setPageControlMarginBottom:(CGFloat)pageControlMarginBottom{
	CGRect frame = _pageControl.frame;
	frame.origin.y = self.frame.size.height - AJPHOTOS_CONTROL_HEIGHT - pageControlMarginBottom;
	_pageControl.frame = frame;
}

- (void)setMargin:(CGFloat)margin{
	_margin = margin;
	_scrollView.frame = CGRectMake(margin, 0, self.frame.size.width-margin*2, self.frame.size.height);
}

- (void)setIndex:(NSInteger)index{
	_index = index;
	[self scrollToPage:index];
}

- (void)reloadData{
	[_scrollView removeAllSubviews];
	[_items removeAllObjects];
	if (!_dataSource) return;
	[self setDataSource:_dataSource];
}

- (void)setDataSource:(id<AJPhotosDataSource>)dataSource{
	_dataSource = dataSource;
	[self performSelector:@selector(setDataSource) withObject:nil afterDelay:0];
}

- (void)setDataSource{
	CGSize size = _scrollView.frame.size;
	NSInteger pages = [_dataSource AJPhotosViewNumberOfPages:self];
	if (pages==0) {
		if (_dataSource && [_dataSource respondsToSelector:@selector(AJPhotosViewNullPages:)]) {
			[_dataSource AJPhotosViewNullPages:self];
		}
		return;
	}
	
	CGSize pointSize = [_pageControl sizeForNumberOfPages:pages];
	CGFloat x = 0;
	switch (_controlPosition) {
		case AJPhotosControlPositionCenter:
			x = (_scrollView.frame.size.width - pointSize.width)/2;
			break;
		case AJPhotosControlPositionLeft:
			x = 10*SCREEN_SCALE;
			break;
		case AJPhotosControlPositionRight:
			x = _scrollView.frame.size.width - pointSize.width - 10*SCREEN_SCALE;
			break;
		default:
			break;
	}
	_pageControl.frame = CGRectMake(x+_scrollView.left, _pageControl.frame.origin.y, pointSize.width, _pageControl.frame.size.height);
	_pageControl.numberOfPages = pages;
	_pageControl.hidden = (_controlPosition == AJPhotosControlPositionNone) || (pages==1 && _autoHidden);
	
	[_scrollView removeAllSubviews];
	for (NSInteger i=0; i<pages; i++) {
		[_items addObject:[_dataSource AJPhotosView:self viewAtIndex:i]];
	}
	
	if (!_loop) {
		_scrollView.contentSize = CGSizeMake(size.width * pages, size.height);
		for (NSInteger i=0; i<pages; i++) {
			UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(size.width * i, 0, _scrollView.width, _scrollView.height)];
			[_scrollView addSubview:itemView];
			UIView *view = _items[i];
			[itemView addSubview:view];
		}
		[_scrollView scrollRectToVisible:CGRectMake(size.width * _pageControl.currentPage, 0, size.width, size.height) animated:NO];
		return;
	}
	
	_scrollView.contentSize = CGSizeMake(size.width * (pages+2), size.height);
	
	UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _scrollView.width, _scrollView.height)];
	[_scrollView addSubview:itemView];
	UIView *firstView = [_dataSource AJPhotosView:self viewAtIndex:pages-1];
	[itemView addSubview:firstView];
	
	for (NSInteger i=0; i<pages; i++) {
		UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(size.width * (i+1), 0, _scrollView.width, _scrollView.height)];
		[_scrollView addSubview:itemView];
		UIView *view = _items[i];
		[itemView addSubview:view];
	}
	
	itemView = [[UIView alloc]initWithFrame:CGRectMake(size.width * (pages+1), 0, _scrollView.width, _scrollView.height)];
	[_scrollView addSubview:itemView];
	UIView *lastView = [_dataSource AJPhotosView:self viewAtIndex:0];
	[itemView addSubview:lastView];
	
	[_scrollView scrollRectToVisible:CGRectMake(size.width * (_pageControl.currentPage+1), 0, size.width, size.height) animated:NO];
	
	if (_scrollTime>0) {
		[self start];
	}
}

- (void)setControlPosition:(AJPhotosControlPosition)controlPosition{
	_controlPosition = controlPosition;
	NSInteger pages = [_dataSource AJPhotosViewNumberOfPages:self];
	CGSize pointSize = [_pageControl sizeForNumberOfPages:pages];
	CGFloat x = 0;
	switch (_controlPosition) {
		case AJPhotosControlPositionCenter:
			x = (_scrollView.frame.size.width - pointSize.width)/2;
			break;
		case AJPhotosControlPositionLeft:
			x = 10*SCREEN_SCALE;
			break;
		case AJPhotosControlPositionRight:
			x = _scrollView.frame.size.width - pointSize.width - 10*SCREEN_SCALE;
			break;
		default:
			break;
	}
	_pageControl.frame = CGRectMake(x+_scrollView.left, _pageControl.frame.origin.y, pointSize.width, _pageControl.frame.size.height);
	_pageControl.hidden = _controlPosition == AJPhotosControlPositionNone;
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor{
	_pageIndicatorTintColor = pageIndicatorTintColor;
	_pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor{
	_currentPageIndicatorTintColor = currentPageIndicatorTintColor;
	_pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

- (void)scrollToPrevPage{
	NSInteger pages = [_dataSource AJPhotosViewNumberOfPages:self];
	if (pages<=1) return;
	CGSize size = _scrollView.frame.size;
	NSInteger index = _pageControl.currentPage;
	index--;
	if (index<0) {
		[_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentSize.width-size.width, 0, size.width, size.height) animated:NO];
		index = pages - 1;
	}
	[_scrollView scrollRectToVisible:CGRectMake(size.width*(index+(_loop?1:0)), 0, size.width, size.height) animated:YES];
	_pageControl.currentPage = index;
	_index = index;
}

- (void)scrollToNextPage{
	NSInteger pages = [_dataSource AJPhotosViewNumberOfPages:self];
	if (pages<=1) return;
	CGSize size = _scrollView.frame.size;
	NSInteger index = _pageControl.currentPage;
	index++;
	if (index>=pages) {
		[_scrollView scrollRectToVisible:CGRectMake(0, 0, size.width, size.height) animated:NO];
		index = 0;
	}
	[_scrollView scrollRectToVisible:CGRectMake(size.width*(index+(_loop?1:0)), 0, size.width, size.height) animated:YES];
	_pageControl.currentPage = index;
	_index = index;
}

- (void)scrollToPage:(NSInteger)index{
	NSInteger pages = [_dataSource AJPhotosViewNumberOfPages:self];
	if (pages<=1) return;
	CGSize size = _scrollView.frame.size;
	if (index>=pages) {
		index = 0;
	} else if (index<0) {
		index = pages - 1;
	}
	[_scrollView scrollRectToVisible:CGRectMake(size.width*index, 0, size.width, size.height) animated:YES];
	_pageControl.currentPage = index;
	_index = index;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	CGSize size = _scrollView.frame.size;
	NSInteger index = floor(floor(fabs(_scrollView.contentOffset.x)) / floor(size.width));
	if (!_loop) {
		_pageControl.currentPage = index;
		return;
	}
	
	NSInteger pages = [_dataSource AJPhotosViewNumberOfPages:self];
	if (index==0) {
		[_scrollView scrollRectToVisible:CGRectMake(size.width*pages, 0, size.width, size.height) animated:NO];
		_pageControl.currentPage = pages - 1;
	} else if (index==pages+1) {
		[_scrollView scrollRectToVisible:CGRectMake(size.width, 0, size.width, size.height) animated:NO];
		_pageControl.currentPage = 0;
	} else {
		_pageControl.currentPage = index - 1;
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPhotosView:scrollViewDidEndDecelerating:viewAtIndex:)]) {
		[_delegate AJPhotosView:self scrollViewDidEndDecelerating:scrollView viewAtIndex:_pageControl.currentPage];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	[self stop];
	if (_delegate && [_delegate respondsToSelector:@selector(AJPhotosView:scrollViewWillBeginDragging:viewAtIndex:)]) {
		[_delegate AJPhotosView:self scrollViewWillBeginDragging:scrollView viewAtIndex:_pageControl.currentPage];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (_scrollTime>0 && _loop) {
		[self start];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPhotosView:scrollViewDidEndDragging:viewAtIndex:)]) {
		[_delegate AJPhotosView:self scrollViewDidEndDragging:scrollView viewAtIndex:_pageControl.currentPage];
	}
}

//传递滑动事件给下一层
-(void)scrollHandlePan:(UIPanGestureRecognizer*)panParam{
	//当滑道左边界时，传递滑动事件给代理
	if(_scrollView.contentOffset.x <= 0) {
		if (_delegate && [_delegate respondsToSelector:@selector(AJPhotosView:panLeftEdge:)]) {
			[_delegate AJPhotosView:self panLeftEdge:panParam];
		}
	} else if(_scrollView.contentOffset.x >= _scrollView.contentSize.width - _scrollView.frame.size.width) {
		if (_delegate && [_delegate respondsToSelector:@selector(AJPhotosView:panRightEdge:)]) {
			[_delegate AJPhotosView:self panRightEdge:panParam];
		}
	}
}

- (void)start{
	if (_scrollTime>0) {
		[self stop];
		_pageTimer = [NSTimer scheduledTimerWithTimeInterval:_scrollTime target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
	}
}

- (void)stop{
	[_pageTimer invalidate];
	_pageTimer = nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
	UIView *view = [super hitTest:point withEvent:event];
	if ([view isEqual:self]) {
		for (UIView *subview in _scrollView.subviews) {
			CGPoint offset = CGPointMake(point.x - _scrollView.frame.origin.x + _scrollView.contentOffset.x - subview.frame.origin.x,
										 point.y - _scrollView.frame.origin.y + _scrollView.contentOffset.y - subview.frame.origin.y);
			if ((view = [subview hitTest:offset withEvent:event])) {
				return view;
			}
		}
		return _scrollView;
	}
	return view;
}

@end
