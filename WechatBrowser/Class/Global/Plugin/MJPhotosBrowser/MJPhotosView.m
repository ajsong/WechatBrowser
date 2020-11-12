//
//  MJZoomingScrollView.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import "Global.h"
#import "MJPhotosView.h"
#import "MJPhotos.h"

@interface MJPhotosView ()<UIScrollViewDelegate>{
	BOOL _doubleTap;
	GIFImageView *_imageView;
}
@end

@implementation MJPhotosView

- (id)initWithFrame:(CGRect)frame{
	if ((self = [super initWithFrame:frame])) {
		self.clipsToBounds = YES;
		
		// 图片
		_imageView = [[GIFImageView alloc]init];
		_imageView.clipsToBounds = YES;
		_imageView.contentMode = UIViewContentModeScaleAspectFill;
		[self addSubview:_imageView];
		
		// 属性
		self.backgroundColor = [UIColor clearColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		// 单击
		UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		singleTap.delaysTouchesBegan = YES;
		singleTap.numberOfTapsRequired = 1;
		[self addGestureRecognizer:singleTap];
		
		// 双击
		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
		doubleTap.numberOfTapsRequired = 2;
		[self addGestureRecognizer:doubleTap];
	}
	return self;
}

- (UIView*)statusBar{
	UIView *statusBar = nil;
	NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
	NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	id object = [UIApplication sharedApplication];
	if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
	return statusBar;
}

#pragma mark - photoSetter
- (void)setPhoto:(MJPhotos *)photo {
	_photo = photo;
	[self showImage];
}

- (void)setOriginImage{
	_photo.srcImageView.image = _photo.srcImage;
}

#pragma mark 显示图片
- (void)showImage{
	if (_photo.firstShow) { // 首次显示
		UIImage *image = [_photo.srcImage isKindOfClass:[GIFImage class]] ? [(GIFImage*)_photo.srcImage getFrameWithIndex:0] : _photo.srcImage;
		_imageView.image = image; // 占位图片
		if (_showInWidow) _photo.srcImageView.image = nil;
		if (_photo.image) {
			self.scrollEnabled = YES;
			_imageView.image = _photo.image;
			[self adjustFrame];
		} else {
			self.scrollEnabled = NO;
			__unsafe_unretained MJPhotosView *_self = self;
			__unsafe_unretained MJPhotos *photo = _photo;
			[_imageView setUrl:_photo.url placeholder:image completion:^(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache) {
				photo.image = image;
				[_self adjustFrame];
			}];
		}
	} else {
		[self photoStartLoad];
	}
}

#pragma mark 开始加载图片
- (void)photoStartLoad{
	if (_photo.image) {
		self.scrollEnabled = YES;
		UIImage *image = [_photo.image isKindOfClass:[GIFImage class]] ? [(GIFImage*)_photo.image getFrameWithIndex:0] : _photo.image;
		_imageView.image = image;
		[self adjustFrame];
	} else {
		self.scrollEnabled = NO;
		__unsafe_unretained MJPhotosView *_self = self;
		__unsafe_unretained MJPhotos *photo = _photo;
		UIImage *image = [_photo.srcImage isKindOfClass:[GIFImage class]] ? [(GIFImage*)_photo.srcImage getFrameWithIndex:0] : _photo.srcImage;
		[_imageView setUrl:_photo.url placeholder:image completion:^(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache) {
			photo.image = image;
			[_self photoDidFinishLoadWithImage:image];
		}];
	}
}

#pragma mark 加载完毕
- (void)photoDidFinishLoadWithImage:(UIImage *)image{
	if (image) {
		self.scrollEnabled = YES;
		_photo.image = image;
		if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
			[self.photoViewDelegate photoViewImageFinishLoad:self];
		}
	}
	[self adjustFrame];
}
#pragma mark 调整frame
- (void)adjustFrame{
	if (_imageView.image == nil) return;
	
	// 基本尺寸参数
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	
	CGFloat imageWidth = _imageView.image.size.width;
	CGFloat imageHeight = _imageView.image.size.height;
	
	// 设置伸缩比例
	CGFloat minScale = width / imageWidth;
	if (minScale > 1) {
		minScale = 1.0;
	}
	CGFloat maxScale = 3.0;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
	
	CGRect imageFrame = CGRectMake(0, 0, width, imageHeight * width / imageWidth);
	// 内容尺寸
	self.contentSize = CGSizeMake(0, imageFrame.size.height);
	
	// y值
	if (imageFrame.size.height < height) {
		imageFrame.origin.y = (height - imageFrame.size.height) / 2.0;
	} else {
		imageFrame.origin.y = 0;
	}
	
	if (_photo.firstShow) { // 第一次显示的图片
		_photo.firstShow = NO;
		_imageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
		//[UIView animateWithDuration:MJPhotoAnimateDuration animations:^{
		[UIView animateWithDuration:.5f delay:0 usingSpringWithDamping:.6f initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			_imageView.frame = imageFrame;
		} completion:^(BOOL finished) {
			_imageView.image = _photo.image;
			[self photoStartLoad];
		}];
	} else {
		_imageView.frame = imageFrame;
		_imageView.image = _photo.image;
	}
}

#pragma mark - 手势处理
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
	_doubleTap = NO;
	[self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}
- (void)hide{
	if (_doubleTap) return;
	_photo.srcImageView.image = nil;
	if (_showInWidow) {
		if (self.zoomScale == self.maximumZoomScale) {
			[self setZoomScale:self.minimumZoomScale animated:YES];
			[self performSelector:@selector(hideImageView) withObject:nil afterDelay:0.5];
		} else {
			[self hideImageView];
		}
	} else {
		[self hideImageView];
	}
}
- (void)hideImageView{
	if (!_showInWidow) {
		_photo.srcImageView.image = _photo.srcImage;
		if (!_statusBarHidden) {
			[UIView animateWithDuration:0.3 animations:^{
				[self statusBar].alpha = 1;
			}];
		}
		if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
			[self.photoViewDelegate photoViewSingleTap:self];
		}
		if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)]) {
			[self.photoViewDelegate photoViewDidEndZoom:self];
		}
		return;
	}
	CGRect sourceFrame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
	CGRect screenFrame = [UIScreen mainScreen].bounds;
	BOOL isInScreen = CGRectIntersectsRect(sourceFrame, screenFrame);
	
	UIImage *image = [_photo.srcImage isKindOfClass:[GIFImage class]] ? [(GIFImage*)_photo.srcImage getFrameWithIndex:0] : _photo.srcImage;
	[UIView animateWithDuration:MJPhotoAnimateDuration animations:^{
		if (isInScreen) {
			_imageView.image = image;
			_imageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
		} else {
			_photo.srcImageView.image = _photo.srcImage;
			_imageView.alpha = 0.0;
		}
		if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
			[self.photoViewDelegate photoViewSingleTap:self];
		}
	} completion:^(BOOL finished) {
		_photo.srcImageView.image = _photo.srcImage;
		[_imageView removeFromSuperview];
		_imageView = nil;
		if (!_statusBarHidden) {
			[UIView animateWithDuration:0.3 animations:^{
				[self statusBar].alpha = 1;
			}];
		}
		if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)]) {
			[self.photoViewDelegate photoViewDidEndZoom:self];
		}
	}];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
	_doubleTap = YES;
	CGPoint touchPoint = [tap locationInView:_imageView];
	if (self.zoomScale == self.maximumZoomScale) {
		[self setZoomScale:self.minimumZoomScale animated:YES];
	} else {
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
	}
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	CGPoint centerPoint = CGPointMake(scrollView.contentSize.width / 2, scrollView.contentSize.height / 2);
	// 水平居中
	if (_imageView.frame.size.width <= scrollView.frame.size.width) {
		centerPoint.x = scrollView.frame.size.width / 2;
	}
	// 垂直居中
	if (_imageView.frame.size.height <= scrollView.frame.size.height) {
		centerPoint.y = scrollView.frame.size.height / 2;
	}
	_imageView.center = centerPoint;
}

@end
