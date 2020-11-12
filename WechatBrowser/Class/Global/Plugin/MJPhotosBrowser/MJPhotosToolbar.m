//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "Global.h"
#import "MJPhotos.h"
#import "MJPhotosToolbar.h"

#define kScrollViewMaxHeight 100

@interface MJPhotosToolbar(){
	CGRect _originFrame;
	CGRect _originIndexLableFrame;
	UILabel *_indexLabel;
	UILabel *_titleLabel;
	UILabel *_contentLabel;
	UIButton *_moreBtn;
	UIButton *_saveImageBtn;
	BOOL _showMore;
	BOOL _titleAndContentUpdating;
	NSTimer *_indexLabelTimer;
}
@end

@implementation MJPhotosToolbar

- (void)setPhotos:(NSArray *)photos{
	CGFloat width = self.superview.frame.size.width;
	CGFloat height = self.superview.frame.size.height;
	CGFloat w = self.frame.size.height;
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
	//self.backgroundColor = [UIColor redColor];
	
	_originFrame = self.frame;
    _photos = photos;
    
	if (_photos.count) {
		// 显示页码
		_originIndexLableFrame = CGRectMake(-(width/2+width/4-w), -(height-w)+(isX?STATUSBAR_HEIGHT:0), width/2, w);
		if (!_indexLabel) {
			_indexLabel = [[UILabel alloc]initWithFrame:_originIndexLableFrame];
			if (_photos.count>1) _indexLabel.text = [NSString stringWithFormat:@"%ld / %ld", (long)_currentPhotoIndex + 1, (long)_photos.count];
			_indexLabel.textColor = [UIColor whiteColor];
			_indexLabel.textAlignment = NSTextAlignmentCenter;
			_indexLabel.font = [UIFont boldSystemFontOfSize:14*SCREEN_SCALE];
			_indexLabel.backgroundColor = [UIColor clearColor];
			[self addSubview:_indexLabel];
		}
    }
	
	// 箭头按钮
	_moreBtn = [[UIButton alloc]initWithFrame:self.bounds];
	[_moreBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser_more"] forState:UIControlStateNormal];
	[_moreBtn addTarget:self action:@selector(changeMore) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_moreBtn];
	
    // 保存图片按钮
    _saveImageBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, w, w, w)];
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser_save"] forState:UIControlStateNormal];
    [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
	_saveImageBtn.hidden = !_showSaveBtn;
    [self addSubview:_saveImageBtn];
	
	if (_btnView) {
		CGRect frame = _btnView.frame;
		frame.origin.x = _saveImageBtn.origin.x + _saveImageBtn.size.width;
		frame.origin.y = _saveImageBtn.origin.y;
		_btnView.frame = frame;
		[self addSubview:_btnView];
	}
	
	// 创建标题与描述
	if (!_titleLabel) {
		UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, w, width, 0)];
		view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
		view.alpha = 0.0;
		[self addSubview:view];
		
		_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 10*SCREEN_SCALE, view.frame.size.width - 10*SCREEN_SCALE*2, 0)];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.font = [UIFont boldSystemFontOfSize:15.f*SCREEN_SCALE];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.numberOfLines = 0;
		[view addSubview:_titleLabel];
		
		[UIView animateWithDuration:MJPhotoAnimateDuration animations:^{
			view.alpha = 1.0;
		}];
	}
	if (!_contentLabel) {
		UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, w, width, 0)];
		scrollView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
		scrollView.alpha = 0.0;
		[self addSubview:scrollView];
		
		_contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 10*SCREEN_SCALE, scrollView.frame.size.width - 10*SCREEN_SCALE*2, 0)];
		_contentLabel.textColor = [UIColor whiteColor];
		_contentLabel.font = [UIFont systemFontOfSize:12.f*SCREEN_SCALE];
		_contentLabel.backgroundColor = [UIColor clearColor];
		_contentLabel.numberOfLines = 0;
		[scrollView addSubview:_contentLabel];
		
		[UIView animateWithDuration:MJPhotoAnimateDuration animations:^{
			scrollView.alpha = 1.0;
		}];
	}
	
	BOOL hasText = NO;
	for (int i=0; i<_photos.count; i++) {
		MJPhotos *photo = _photos[i];
		if (photo.title.length) {
			if (photo.firstShow) {
				NSString *string = photo.title;
				CGSize s = [string autoHeight:_titleLabel.font width:_titleLabel.frame.size.width];
				_titleLabel.text = string;
				_titleLabel.height = s.height;
				
				UIView *view = _titleLabel.superview;
				view.height = s.height + 10*SCREEN_SCALE*2;
			}
			hasText = YES;
		}
		
		if (photo.content.length) {
			if (photo.firstShow) {
				NSString *string = photo.content;
				CGSize s = [string autoHeight:_contentLabel.font width:_contentLabel.frame.size.width];
				_contentLabel.text = string;
				_contentLabel.height = s.height;
				
				CGFloat height = s.height;
				if (height > kScrollViewMaxHeight-10*SCREEN_SCALE*2) height = kScrollViewMaxHeight-10*SCREEN_SCALE*2;
				UIScrollView *scrollView = (UIScrollView*)_contentLabel.superview;
				scrollView.height = height + 10*SCREEN_SCALE*2;
				scrollView.contentSize = CGSizeMake(scrollView.width, _contentLabel.bottom+10);
			}
			hasText = YES;
		}
	}
	
	if (!hasText && !_showSaveBtn && !_btnView) {
		_moreBtn.hidden = YES;
		CGRect frame = self.frame;
		frame.size.width = 0;
		self.frame = frame;
		return;
	}
	
	if (_showInfo) [self changeMore];
}

- (void)setCurrentPhotoIndex:(NSInteger)currentPhotoIndex{
	_currentPhotoIndex = currentPhotoIndex;
	if (!_indexLabel) return;
	// 更新标题与描述
	[self updateTitleAndContent];
	// 更新页码
	if (_photos.count>1) _indexLabel.text = [NSString stringWithFormat:@"%ld / %ld", (long)_currentPhotoIndex + 1, (long)_photos.count];
	// 按钮
	MJPhotos *photo = _photos[_currentPhotoIndex];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			_saveImageBtn.enabled = photo.image!=nil && photo.save;
		});
	});
}

- (void)changeMore{
	if (!_showMore) {
		CGFloat width = self.superview.frame.size.width;
		CGRect frame = self.frame;
		frame.size.width = width;
		frame.origin.x = 0;
		self.frame = frame;
		
		frame = _indexLabel.frame;
		frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
		_indexLabel.frame = frame;
		
		frame = _moreBtn.frame;
		frame.origin.x = width - frame.size.width;
		_moreBtn.frame = frame;
		
		[UIView animateWithDuration:0.3 animations:^{
			self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
			_moreBtn.transform = CGAffineTransformMakeRotation((M_PI*(180.0)/180.0));
			
			CGRect frame = _saveImageBtn.frame;
			frame.origin.y = 0;
			_saveImageBtn.frame = frame;
			
			frame = _contentLabel.superview.frame;
			frame.origin.y = -frame.size.height;
			_contentLabel.superview.frame = frame;
			
			frame = _titleLabel.superview.frame;
			frame.origin.y = _contentLabel.superview.top - frame.size.height;
			_titleLabel.superview.frame = frame;
			
			if (_btnView) {
				frame = _btnView.frame;
				frame.origin.y = 0;
				_btnView.frame = frame;
			}
		}];
	} else {
		[UIView animateWithDuration:0.3 animations:^{
			self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
			_moreBtn.transform = CGAffineTransformMakeRotation((M_PI*(0.0)/180.0));
			
			CGRect frame = _saveImageBtn.frame;
			frame.origin.y = self.frame.size.height;
			_saveImageBtn.frame = frame;
			
			frame = _titleLabel.superview.frame;
			frame.origin.y = self.frame.size.height;
			_titleLabel.superview.frame = frame;
			
			frame = _contentLabel.superview.frame;
			frame.origin.y = self.frame.size.height;
			_contentLabel.superview.frame = frame;
			
			if (_btnView) {
				frame = _btnView.frame;
				frame.origin.y = self.frame.size.height;
				_btnView.frame = frame;
			}
		} completion:^(BOOL finished) {
			self.frame = _originFrame;
			_indexLabel.frame = _originIndexLableFrame;
			_moreBtn.frame = self.bounds;
		}];
	}
	_showMore = !_showMore;
}

- (void)saveImage{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MJPhotos *photo = _photos[_currentPhotoIndex];
        UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        [ProgressHUD showError:@"保存失败"];
    } else {
        MJPhotos *photo = _photos[_currentPhotoIndex];
        photo.save = NO;
		_saveImageBtn.enabled = NO;
		[ProgressHUD showSuccess:@"成功保存到相册"];
    }
}

- (void)showIndexLabel:(BOOL)autoHidden{
	[_indexLabelTimer invalidate];
	_indexLabelTimer = nil;
	[UIView animateWithDuration:0.3 animations:^{
		_indexLabel.alpha = 1;
	} completion:^(BOOL finished) {
		if (autoHidden) {
			_indexLabelTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(showAndHideIndexLabel) userInfo:nil repeats:NO];
		}
	}];
}
- (void)showAndHideIndexLabel{
	[_indexLabelTimer invalidate];
	_indexLabelTimer = nil;
	[UIView animateWithDuration:0.3 animations:^{
		_indexLabel.alpha = 0;
	}];
}

- (void)reloadData{
	[self updateTitleAndContent];
}

- (void)updateTitleAndContent{
	if (_titleAndContentUpdating) return;
	_titleAndContentUpdating = YES;
	
	MJPhotos *photo = _photos[_currentPhotoIndex];
	
	if (_titleLabel) {
		if (photo.title.length) {
			[UIView animateWithDuration:0.3 animations:^{
				_titleLabel.alpha = 0.0;
			} completion:^(BOOL finished) {
				NSString *string = photo.title;
				CGSize s = [string autoHeight:_titleLabel.font width:_titleLabel.frame.size.width];
				_titleLabel.text = string;
				
				[UIView animateWithDuration:0.3 animations:^{
					_titleLabel.height = s.height;
					_titleLabel.superview.height = s.height + 10*SCREEN_SCALE*2;
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.3 animations:^{
						_titleLabel.alpha = 1.0;
					} completion:^(BOOL finished) {
						_titleAndContentUpdating = NO;
					}];
				}];
			}];
		} else {
			[UIView animateWithDuration:0.3 animations:^{
				_titleLabel.alpha = 0.0;
				_titleLabel.superview.height = 0;
			} completion:^(BOOL finished) {
				_titleAndContentUpdating = NO;
			}];
		}
	}
	
	if (_contentLabel) {
		if (photo.content.length) {
			[UIView animateWithDuration:0.3 animations:^{
				_contentLabel.alpha = 0.0;
			} completion:^(BOOL finished) {
				NSString *string = photo.content;
				CGSize s = [string autoHeight:_contentLabel.font width:_contentLabel.frame.size.width];
				_contentLabel.text = string;
				
				CGFloat height = s.height;
				if (height > kScrollViewMaxHeight-10*SCREEN_SCALE*2) height = kScrollViewMaxHeight-10*SCREEN_SCALE*2;
				UIScrollView *scrollView = (UIScrollView*)_contentLabel.superview;
				
				[UIView animateWithDuration:0.3 animations:^{
					_contentLabel.height = s.height;
					scrollView.height = height + 10*SCREEN_SCALE*2;
					scrollView.contentSize = CGSizeMake(scrollView.width, _contentLabel.bottom+10);
					if (_showMore) scrollView.top = -scrollView.height;
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.3 animations:^{
						if (_titleLabel && _showMore) _titleLabel.superview.top = scrollView.top - _titleLabel.superview.height;
						_contentLabel.alpha = 1.0;
					} completion:^(BOOL finished) {
						_titleAndContentUpdating = NO;
					}];
				}];
			}];
		} else {
			UIScrollView *scrollView = (UIScrollView*)_contentLabel.superview;
			[UIView animateWithDuration:0.3 animations:^{
				_contentLabel.alpha = 0.0;
				scrollView.height = 0;
				if (_showMore) {
					scrollView.top = -scrollView.height;
					if (_titleLabel) _titleLabel.superview.top = scrollView.top - _titleLabel.superview.height;
				}
			} completion:^(BOOL finished) {
				_titleAndContentUpdating = NO;
			}];
		}
	}
}

@end
