//
//  MJPhotoBrowser.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "Global.h"
#import "MJPhotosView.h"
#import "MJPhotosToolbar.h"

#define kPadding 10*SCREEN_SCALE
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface MJPhotosBrowser () <MJPhotosViewDelegate>{
    // 滚动的view
	UIScrollView *_photoScrollView;
    // 所有的图片view
	NSMutableSet *_visiblePhotoViews;
	NSMutableSet *_reusablePhotoViews;
	// 当前图片
	MJPhotosView *_photoView;
    // 工具条
	MJPhotosToolbar *_toolbar;
    // 一开始的状态栏
    BOOL _statusBarIsHidden;
	// 当前查看的图片索引
	NSInteger _lastIndex;
	// 是否显示在window
	BOOL _showInWidow;
	// 准备初始化
	BOOL _willInit;
}
@end

@implementation MJPhotosBrowser

- (UIView*)statusBar{
	UIView *statusBar = nil;
	NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
	NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	id object = [UIApplication sharedApplication];
	if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
	return statusBar;
}

- (instancetype)init{
	if (self = [super init]) {
		_photos = [[NSArray alloc]init];
		_showSaveBtn = YES;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	if (!_showInWidow && self.navigationController) [self.navigationController setNavigationBarHidden:YES animated:YES];
	if (!_statusBarIsHidden) {
		[UIView animateWithDuration:0.3 animations:^{
			[self statusBar].alpha = 0;
		}];
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	if (!_showInWidow && self.navigationController) [self.navigationController setNavigationBarHidden:NO animated:YES];
	if (!_statusBarIsHidden) {
		[UIView animateWithDuration:0.3 animations:^{
			[self statusBar].alpha = 1;
		}];
	}
}

- (void)viewDidLoad{
	[super viewDidLoad];
	if (@available(iOS 11.0, *)) {
		_photoScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
	} else if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
	_statusBarIsHidden = [UIApplication sharedApplication].isStatusBarHidden;
	if (!_statusBarIsHidden) {
		[UIView animateWithDuration:0.3 animations:^{
			[self statusBar].alpha = 0;
		}];
	}
	
	self.view.frame = [UIScreen mainScreen].bounds;
	if (_showInWidow) {
		self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
	} else {
		if (self.navigationController) [self.navigationController setNavigationBarHidden:YES animated:YES];
		self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0];
		[self showInWidow:NO];
	}
}

- (void)show{
	[self showInWidow:YES];
}

- (void)showInWidow:(BOOL)yesOrNo{
	if (!_photos.count) return;
	_showInWidow = yesOrNo;
	[self createToolbar];
	[self createScrollView];
	
	if (yesOrNo) {
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		[window addSubview:self.view];
		[window.rootViewController addChildViewController:self];
		[UIView animateWithDuration:MJPhotoAnimateDuration animations:^{
			self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0];
		}];
	}

	_lastIndex = _currentPhotoIndex;
	if (_currentPhotoIndex == 0) {
		[self performSelector:@selector(showPhotos) withObject:nil afterDelay:0];
	}
}

- (void)pushReturn{
	if (self.navigationController) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark 创建UIScrollView
- (void)createScrollView{
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.origin.x -= kPadding;
    frame.size.width += kPadding * 2;
	_photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
	_photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_photoScrollView.pagingEnabled = YES;
	_photoScrollView.delegate = self;
	_photoScrollView.showsHorizontalScrollIndicator = NO;
	_photoScrollView.showsVerticalScrollIndicator = NO;
	_photoScrollView.backgroundColor = [UIColor clearColor];
	_photoScrollView.contentSize = CGSizeMake(frame.size.width * _photos.count, 0);
	_photoScrollView.contentOffset = CGPointMake(frame.size.width * _currentPhotoIndex, 0);
	[self.view addSubview:_photoScrollView];
	[self.view bringSubviewToFront:_toolbar];
}

#pragma mark 创建工具条
- (void)createToolbar{
	CGFloat barWH = 44*SCREEN_SCALE;
	_toolbar = [[MJPhotosToolbar alloc] init];
	_toolbar.frame = CGRectMake(self.view.frame.size.width - barWH, self.view.frame.size.height - barWH, barWH, barWH);
	_toolbar.alpha = 0;
	_toolbar.currentPhotoIndex = _currentPhotoIndex;
	_toolbar.showInfo = _showInfo;
	_toolbar.showSaveBtn = _showSaveBtn;
	_toolbar.btnView = _btnView;
	[self.view addSubview:_toolbar];
	_toolbar.photos = _photos;
	
	[UIView animateWithDuration:MJPhotoAnimateDuration animations:^{
		_toolbar.alpha = 1.0;
	} completion:^(BOOL finished) {
		[_toolbar showIndexLabel:YES];
	}];
}

- (void)reloadData{
	[_toolbar reloadData];
}

#pragma mark 设置图片
- (void)setPhotos:(NSArray *)photos{
	if (!photos.count) return;
    _photos = photos;
    if (photos.count) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    for (int i=0; i<_photos.count; i++) {
		MJPhotos *photo = _photos[i];
		if (!photo.srcImage) {
			photo.srcImage = photo.srcImageView.image ? photo.srcImageView.image : [self getImageFromView:photo.srcImageView];
		}
		photo.index = i;
        photo.firstShow = i == _currentPhotoIndex;
	}
}

- (UIImage *)getImageFromView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

#pragma mark 设置选中的图片
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex{
	_currentPhotoIndex = currentPhotoIndex;
	if (!_photos.count) return;
    for (int i=0; i<_photos.count; i++) {
        MJPhotos *photo = _photos[i];
		photo.firstShow = i == currentPhotoIndex;
	}
    if ([self isViewLoaded]) {
        _photoScrollView.contentOffset = CGPointMake(_photoScrollView.frame.size.width * _currentPhotoIndex, 0);
        [self performSelector:@selector(showPhotos) withObject:nil afterDelay:0];
    }
}

#pragma mark 显示照片
- (void)showPhotos{
    // 只有一张图片
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
	CGRect visibleBounds = _photoScrollView.bounds;
	NSInteger firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
	NSInteger lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = _photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = _photos.count - 1;
	
	// 回收不再显示的ImageView
    NSInteger photoViewIndex;
	for (MJPhotosView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
		if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
			[_reusablePhotoViews addObject:photoView];
			[photoView removeFromSuperview];
		}
	}
    
	[_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
	
	for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
		if (![self isShowingPhotoViewAtIndex:index]) {
			[self showPhotoViewAtIndex:index];
		}
	}
}

#pragma mark 显示一个图片view
- (void)showPhotoViewAtIndex:(NSInteger)index{
    MJPhotosView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[MJPhotosView alloc] init];
        photoView.photoViewDelegate = self;
		photoView.statusBarHidden = _statusBarIsHidden;
		photoView.showInWidow = _showInWidow;
	}
	
    // 调整当前页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= kPadding * 2;
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    MJPhotos *photo = _photos[index];
    photoView.frame = photoViewFrame;
	photoView.photo = photo;
	
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
	
	if (_photoView) [_photoView setOriginImage];
	_photoView = photoView;
	
    [self loadImageNearIndex:index];
}

#pragma mark 加载index附近的图片
- (void)loadImageNearIndex:(NSInteger)index{
	if (_photos.count==1) return;
	
    if (index > 0) {
		MJPhotos *photo = _photos[index - 1];
		if ([photo.url isKindOfClass:[NSString class]]) {
			[Global cacheImageWithUrl:photo.url completion:nil];
		}
    }
	
    if (index < _photos.count - 1) {
		MJPhotos *photo = _photos[index + 1];
		if ([photo.url isKindOfClass:[NSString class]]) {
			[Global cacheImageWithUrl:photo.url completion:nil];
		}
    }
}

#pragma mark index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index{
	for (MJPhotosView *photoView in _visiblePhotoViews) {
		if (kPhotoViewIndex(photoView) == index) {
           return YES;
        }
    }
	return  NO;
}

#pragma mark 循环利用某个view
- (MJPhotosView *)dequeueReusablePhotoView{
    MJPhotosView *photoView = [_reusablePhotoViews anyObject];
	if (photoView) {
		[_reusablePhotoViews removeObject:photoView];
	}
	return photoView;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (!_willInit) {
		_willInit = YES;
		[self performSelector:@selector(showPhotos) withObject:nil afterDelay:0];
	} else {
		[self showPhotos];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	[_toolbar showIndexLabel:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	NSInteger index = floorf(floor(scrollView.contentOffset.x) / floor(scrollView.frame.size.width));
	[_toolbar showIndexLabel:YES];
	if (_lastIndex == index) return;
	_currentPhotoIndex = index;
	_toolbar.currentPhotoIndex = _currentPhotoIndex;
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:didChangedToPageAtIndex:direction:)]) {
		NSInteger direction = 0;
		if (_lastIndex > _currentPhotoIndex) {
			direction = -1;
		} else if (_lastIndex < _currentPhotoIndex) {
			direction = 1;
		}
		[self.delegate photoBrowser:self didChangedToPageAtIndex:_currentPhotoIndex direction:direction];
	}
	
	_lastIndex = _currentPhotoIndex;
}

#pragma mark - MJPhotoView代理
- (void)photoViewSingleTap:(MJPhotosView *)photoView{
	if (_showInWidow) {
		self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
	}
	[_toolbar removeFromSuperview];
	if (self.delegate && [self.delegate respondsToSelector:@selector(photoViewSingleTap)]) {
		[self.delegate photoViewSingleTap];
	}
}

- (void)photoViewDidEndZoom:(MJPhotosView *)photoView{
	if (self.delegate && [self.delegate respondsToSelector:@selector(photoViewDidEndZoom)]) {
		[self.delegate photoViewDidEndZoom];
	}
	if (_showInWidow) {
		[self.view removeFromSuperview];
		[self removeFromParentViewController];
	} else {
		[self pushReturn];
	}
}

- (void)photoViewImageFinishLoad:(MJPhotosView *)photoView{
	//_toolbar.currentPhotoIndex = _currentPhotoIndex;
}

@end
