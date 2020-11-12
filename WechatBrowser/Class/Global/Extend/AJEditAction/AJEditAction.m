//
//  AJEditAction.m
//
//  Created by ajsong on 2016/10/10.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import "Global.h"

#define ACTION_LEFT_BTN_TAG 763874
#define ACTION_RIGHT_BTN_TAG 773874

@implementation AJRowAction
+ (AJRowAction*)rowActionWithTitle:(NSString *)title titleColor:(UIColor*)titleColor font:(UIFont*)font backgroundColor:(UIColor*)backgroundColor action:(void (^)(AJEditAction *editView, AJRowAction *rowAction))action{
	AJRowAction *rowAction = [AJRowAction rowActionWithAction:action];
	rowAction.title = title;
	rowAction.titleColor = titleColor;
	rowAction.font = font;
	rowAction.backgroundColor = backgroundColor;
	return rowAction;
}
+ (AJRowAction*)rowActionWithIco:(UIImage *)ico backgroundColor:(UIColor*)backgroundColor action:(void (^)(AJEditAction *editView, AJRowAction *rowAction))action{
	AJRowAction *rowAction = [AJRowAction rowActionWithAction:action];
	rowAction.ico = ico;
	rowAction.backgroundColor = backgroundColor;
	return rowAction;
}
+ (AJRowAction*)rowActionWithAction:(void (^)(AJEditAction *editView, AJRowAction *rowAction))action{
	AJRowAction *rowAction = [[AJRowAction alloc]init];
	rowAction.action = action;
	return rowAction;
}
@end

@interface AJEditAction ()<UIScrollViewDelegate>{
	CGFloat _leftWidth;
	CGFloat _rightWidth;
	BOOL _isDraging;
	BOOL _isRestoring;
	BOOL _isSendToBack;
	BOOL _isDeleting;
	AJEditAction *_brotherOfOpening;
}
@end

@implementation AJEditAction

- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		[self setupInit];
	}
	return self;
}

- (void)setFrame:(CGRect)frame{
	[super setFrame:frame];
	[self setupInit];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
	[super setBackgroundColor:backgroundColor];
	_contentView.backgroundColor = backgroundColor;
}

- (void)addSubview:(UIView *)view{
	if (!_scrollView || !_scrollView.superview) {
		[super addSubview:view];
		return;
	}
	[_contentView addSubview:view];
}

- (void)setupInit{
	if (!_scrollView) {
		_rowActions = [[NSArray alloc]init];
		_leftActions = [[NSMutableArray alloc]init];
		_rightActions = [[NSMutableArray alloc]init];

		_scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];

		_contentView = [[UIView alloc]initWithFrame:_scrollView.bounds];
		_contentView.clipsToBounds = YES;
		[_scrollView addSubview:_contentView];

		_restoreBtn = [[UIButton alloc]initWithFrame:_contentView.bounds];
		_restoreBtn.backgroundColor = [UIColor clearColor];
		_restoreBtn.hidden = YES;
		[_restoreBtn addTarget:self action:^(id target, id sender) {
			[target restoreWithAction:nil];
		}];
		[_contentView addSubview:_restoreBtn];

		self.clipsToBounds = YES;
		self.backgroundColor = [UIColor whiteColor];
	}
}

- (void)setDelegate:(id<AJEditActionDelegate>)delegate{
	_delegate = delegate;
	if (_delegate && [_delegate respondsToSelector:@selector(AJEditActions:)]) {
		_rowActions = [_delegate AJEditActions:self];
		if (!_rowActions.isArray) return;

		_leftActions = [[NSMutableArray alloc]init];
		_rightActions = [[NSMutableArray alloc]init];
		for (int i=0; i<5; i++) {
			[[self viewWithTag:ACTION_LEFT_BTN_TAG+i] removeFromSuperview];
			[[self viewWithTag:ACTION_RIGHT_BTN_TAG+i] removeFromSuperview];
		}
		for (int i=0; i<_rowActions.count; i++) {
			AJRowAction *rowAction = _rowActions[i];
			if (rowAction.type==AJRowActionTypeLeft) {
				[_leftActions addObject:rowAction];
			} else {
				[_rightActions insertObject:rowAction atIndex:0];
			}
		}
		CGFloat left = self.width;
		for (int i=0; i<_rightActions.count; i++) {
			AJRowAction *rowAction = _rightActions[i];
			CGSize size = CGSizeZero;
			if (rowAction.title.length) {
				size = [rowAction.title autoWidth:rowAction.font height:self.height];
				size.width += 15*SCREEN_SCALE*2;
			}
			if (rowAction.ico) {
				size.width = rowAction.ico.size.width + 20*SCREEN_SCALE*2;
			}

			UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(left-size.width, 0, size.width, self.height)];
			btn.backgroundColor = rowAction.backgroundColor;
			btn.adjustsImageWhenHighlighted = NO;
			if (rowAction.title.length) {
				btn.titleLabel.font = rowAction.font;
				[btn setTitle:rowAction.title forState:UIControlStateNormal];
				[btn setTitleColor:rowAction.titleColor forState:UIControlStateNormal];
			}
			if (rowAction.ico) {
				[btn setImage:rowAction.ico forState:UIControlStateNormal];
			}
			[btn addTarget:self action:^(id target, id sender) {
				if (rowAction.action) rowAction.action(target, rowAction);
			}];
			btn.tag = ACTION_RIGHT_BTN_TAG + i;
			btn.hidden = YES;
			btn.element[@"originFrame"] = NSStringFromCGRect(btn.frame);
			[self insertSubview:btn atIndex:0];
			rowAction.btn = btn;
			_rightWidth += size.width;
			left = btn.left;
		}

		CGFloat right = 0;
		for (int i=0; i<_leftActions.count; i++) {
			AJRowAction *rowAction = _leftActions[i];
			CGSize size = CGSizeZero;
			if (rowAction.title.length) {
				size = [rowAction.title autoWidth:rowAction.font height:self.height];
				size.width += 15*SCREEN_SCALE*2;
			}
			if (rowAction.ico) {
				size.width = rowAction.ico.size.width + 20*SCREEN_SCALE*2;
			}
			if (size.width<self.height) size.width = self.height;

			UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(right, 0, size.width, self.height)];
			btn.backgroundColor = rowAction.backgroundColor;
			btn.adjustsImageWhenHighlighted = NO;
			if (rowAction.title.length) {
				btn.titleLabel.font = rowAction.font;
				[btn setTitle:rowAction.title forState:UIControlStateNormal];
				[btn setTitleColor:rowAction.titleColor forState:UIControlStateNormal];
			}
			if (rowAction.ico) {
				[btn setImage:rowAction.ico forState:UIControlStateNormal];
			}
			[btn addTarget:self action:^(id target, id sender) {
				if (rowAction.action) rowAction.action(target, rowAction);
			}];
			btn.tag = ACTION_LEFT_BTN_TAG + i;
			btn.hidden = YES;
			btn.element[@"originFrame"] = NSStringFromCGRect(btn.frame);
			[self insertSubview:btn atIndex:0];
			rowAction.btn = btn;
			_leftWidth += size.width;
			right = btn.right;
		}

		_scrollView.contentInset = UIEdgeInsetsMake(0, _leftWidth, 0, _rightWidth);
		_scrollView.contentOffset = CGPointMake(0, 0);
		_scrollView.contentSize = CGSizeMake(self.width+0.1, self.height);
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (_leftWidth==0 && _scrollView.contentOffset.x < 0) {
		_scrollView.contentOffset = CGPointMake(0, 0);
		return;
	}
	if (_rightWidth==0 && _scrollView.contentOffset.x > 0) {
		_scrollView.contentOffset = CGPointMake(0, 0);
		return;
	}
	if (_isRestoring) return;
	if (_brotherOfOpening && ![_brotherOfOpening isEqual:self]) {
		_scrollView.contentOffset = CGPointMake(0, 0);
		return;
	}
	if (_rightActions.isArray) {
		if (_scrollView.contentOffset.x < _rightWidth+_leftWidth && !_isSendToBack) {
			_isSendToBack = YES;
			for (int i=0; i<_rightActions.count; i++) {
				[self sendSubviewToBack:[self viewWithTag:ACTION_RIGHT_BTN_TAG+i]];
			}
		}
		if (_delegate && [_delegate respondsToSelector:@selector(AJEditActionRightOperateOfButtonIndex:)]) {
			NSInteger index = [_delegate AJEditActionRightOperateOfButtonIndex:self];
			if (!_isDeleting && _isDraging && index<_rightActions.count) {
				AJRowAction *rowAction = _rightActions[index];
				UIButton *btn = rowAction.btn;
				if (fabs(_scrollView.contentOffset.x)-_rightWidth >= (_scrollView.width-_rightWidth)/4) {
					[self bringSubviewToFront:btn];
					[UIView animateWithDuration:0.15 animations:^{
						btn.frame = CGRectMake(0, 0, self.width, self.height);
					}];
				} else {
					[UIView animateWithDuration:0.15 animations:^{
						btn.frame = CGRectFromString(btn.element[@"originFrame"]);
					}];
				}
			}
		}
	}
	if (_leftActions.isArray) {
		if (_scrollView.contentOffset.x > -_leftWidth && !_isSendToBack) {
			_isSendToBack = YES;
			for (int i=0; i<_leftActions.count; i++) {
				[self sendSubviewToBack:[self viewWithTag:ACTION_LEFT_BTN_TAG+i]];
			}
		}
		if (_delegate && [_delegate respondsToSelector:@selector(AJEditActionLeftOperateOfButtonIndex:)]) {
			NSInteger index = [_delegate AJEditActionLeftOperateOfButtonIndex:self];
			if (!_isDeleting && _isDraging && index<_leftActions.count) {
				AJRowAction *rowAction = _leftActions[index];
				UIButton *btn = rowAction.btn;
				if (fabs(_scrollView.contentOffset.x) >= _leftWidth+(_scrollView.width-_leftWidth)/4) {
					[self bringSubviewToFront:btn];
					[UIView animateWithDuration:0.15 animations:^{
						btn.frame = CGRectMake(0, 0, self.width, self.height);
					}];
				} else {
					[UIView animateWithDuration:0.15 animations:^{
						btn.frame = CGRectFromString(btn.element[@"originFrame"]);
					}];
				}
			}
		}
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJEditAction:scrollViewDidScroll:)]) {
		[_delegate AJEditAction:self scrollViewDidScroll:_scrollView];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	[self willBeginDragging];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[self didEndDragging];
}

- (void)willBeginDragging{
	if (_isRestoring) return;
	NSArray *editViews = [self.superview subviewsOfFind:[AJEditAction class]];
	for (AJEditAction *editView in editViews) {
		if (editView.isOpening && ![editView isEqual:self]) {
			[editView restoreWithAction:nil];
			break;
		}
	}
	_isDraging = YES;
	if (_rowActions.isArray) {
		NSArray *editViews = [self.superview subviewsOfFind:[AJEditAction class]];
		AJEditAction *editAction = nil;
		for (AJEditAction *editView in editViews) {
			if (editView.isOpening && ![editView isEqual:self]) {
				editAction = editView;
				break;
			}
		}
		if (editAction) {
			_brotherOfOpening = editAction;
			[editAction restoreWithAction:nil];
			return;
		}
	}
	[_contentView bringSubviewToFront:_restoreBtn];
	if (_rightActions.isArray) {
		for (int i=0; i<_rightActions.count; i++) {
			[self sendSubviewToBack:[self viewWithTag:ACTION_RIGHT_BTN_TAG+i]];
			[[self viewWithTag:ACTION_RIGHT_BTN_TAG+i] setHidden:NO];
		}
	}
	if (_leftActions.isArray) {
		for (int i=0; i<_leftActions.count; i++) {
			[self sendSubviewToBack:[self viewWithTag:ACTION_LEFT_BTN_TAG+i]];
			[[self viewWithTag:ACTION_LEFT_BTN_TAG+i] setHidden:NO];
		}
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJEditAction:scrollViewWillBeginDragging:)]) {
		[_delegate AJEditAction:self scrollViewWillBeginDragging:_scrollView];
	}
}

- (void)didEndDragging{
	if (_isRestoring) return;
	_isDraging = NO;
	if (_brotherOfOpening) {
		_brotherOfOpening = nil;
		return;
	}
	if (_rightActions.isArray) {
		if (_scrollView.contentOffset.x >= _rightWidth/2) {
			_isOpening = YES;
			[_scrollView setContentOffset:CGPointMake(_rightWidth, 0) animated:YES];
			NSArray *editViews = [self.superview subviewsOfFind:[AJEditAction class]];
			for (AJEditAction *editView in editViews) {
				[editView.contentView bringSubviewToFront:editView.restoreBtn];
				editView.restoreBtn.hidden = NO;
			}
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					for (int i=0; i<_rightActions.count; i++) {
						[self bringSubviewToFront:[self viewWithTag:ACTION_RIGHT_BTN_TAG+i]];
					}
				});
			});
			if (_delegate && [_delegate respondsToSelector:@selector(AJEditActionRightOperateOfButtonIndex:)]) {
				NSInteger index = [_delegate AJEditActionRightOperateOfButtonIndex:self];
				if (index<_rightActions.count && fabs(_scrollView.contentOffset.x)-_rightWidth >= (_scrollView.width-_rightWidth)/4) {
					_isDeleting = YES;
					AJRowAction *rowAction = _rightActions[index];
					UIButton *btn = rowAction.btn;
					if (rowAction.action) rowAction.action(self, rowAction);
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
						dispatch_async(dispatch_get_main_queue(), ^{
							[self bringSubviewToFront:btn];
						});
					});
				}
			}
		} else {
			if (_scrollView.contentOffset.x > 0) [self restoreWithAction:nil];
		}
	}
	if (_leftActions.isArray) {
		if (_scrollView.contentOffset.x <= -_leftWidth/2) {
			_isOpening = YES;
			[_scrollView setContentOffset:CGPointMake(-_leftWidth, 0) animated:YES];
			NSArray *editViews = [self.superview subviewsOfFind:[AJEditAction class]];
			for (AJEditAction *editView in editViews) {
				[editView.contentView bringSubviewToFront:editView.restoreBtn];
				editView.restoreBtn.hidden = NO;
			}
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					for (int i=0; i<_leftActions.count; i++) {
						[self bringSubviewToFront:[self viewWithTag:ACTION_LEFT_BTN_TAG+i]];
					}
				});
			});
			if (_delegate && [_delegate respondsToSelector:@selector(AJEditActionLeftOperateOfButtonIndex:)]) {
				NSInteger index = [_delegate AJEditActionLeftOperateOfButtonIndex:self];
				if (index<_leftActions.count && fabs(_scrollView.contentOffset.x) >= _leftWidth+(_scrollView.width-_leftWidth)/4) {
					_isDeleting = YES;
					AJRowAction *rowAction = _leftActions[index];
					UIButton *btn = rowAction.btn;
					if (rowAction.action) rowAction.action(self, rowAction);
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
						dispatch_async(dispatch_get_main_queue(), ^{
							[self bringSubviewToFront:btn];
						});
					});
				}
			}
		} else {
			if (_scrollView.contentOffset.x < 0) [self restoreWithAction:nil];
		}
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJEditAction:scrollViewDidEndDragging:)]) {
		[_delegate AJEditAction:self scrollViewDidEndDragging:_scrollView];
	}
}

- (void)showRightButtons{
	if (!_rightActions.isArray) return;
	[self willBeginDragging];
	[_scrollView setContentOffset:CGPointMake(_rightWidth, 0) animated:YES];
	[self performSelector:@selector(didEndDragging) withObject:nil afterDelay:0.3];
}

- (void)showLeftButtons{
	if (!_leftActions.isArray) return;
	[self willBeginDragging];
	[_scrollView setContentOffset:CGPointMake(-_leftWidth, 0) animated:YES];
	[self performSelector:@selector(didEndDragging) withObject:nil afterDelay:0.3];
}

- (void)restoreWithAction:(void (^)(AJEditAction *editView))action{
	if (_isRestoring) return;
	_isRestoring = YES;
	_isSendToBack = NO;
	for (int i=0; i<_rightActions.count; i++) {
		[self sendSubviewToBack:[self viewWithTag:ACTION_RIGHT_BTN_TAG+i]];
	}
	for (int i=0; i<_leftActions.count; i++) {
		[self sendSubviewToBack:[self viewWithTag:ACTION_LEFT_BTN_TAG+i]];
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			[_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
			NSArray *editViews = [self.superview subviewsOfFind:[AJEditAction class]];
			for (AJEditAction *editView in editViews) {
				if (editView.isOpening && ![editView isEqual:self]) [editView restoreWithAction:nil];
				editView.restoreBtn.hidden = YES;
			}
		});
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			_isOpening = NO;
			_isRestoring = NO;
			_brotherOfOpening = nil;
			for (int i=0; i<_rightActions.count; i++) {
				[[self viewWithTag:ACTION_RIGHT_BTN_TAG+i] setHidden:YES];
			}
			for (int i=0; i<_leftActions.count; i++) {
				[[self viewWithTag:ACTION_LEFT_BTN_TAG+i] setHidden:YES];
			}
			if (action) action(self);
		});
	});
}

- (void)deleteWithAction:(void (^)(AJEditAction *editView))action{
	[self deleteWithType:AJEditActionDeleteTypeNormal action:action];
}

- (void)deleteWithType:(AJEditActionDeleteType)type action:(void (^)(AJEditAction *editView))action{
	self.superview.clipsToBounds = YES;
	[self setHeightAndChangeNextTop:0 completion:nil];
	switch (type) {
		case AJEditActionDeleteTypeFade:{
			[UIView animateWithDuration:0.3 animations:^{
				_scrollView.alpha = 0;
			} completion:^(BOOL finished) {
				[self removeAll];
			}];
			break;
		}
		case AJEditActionDeleteTypeLeft:{
			[UIView animateWithDuration:0.3 animations:^{
				_scrollView.left = -_scrollView.width;
			} completion:^(BOOL finished) {
				[self removeAll];
			}];
			break;
		}
		case AJEditActionDeleteTypeRight:{
			[UIView animateWithDuration:0.3 animations:^{
				_scrollView.left = _scrollView.width;
			} completion:^(BOOL finished) {
				[self removeAll];
			}];
			break;
		}
		default:
			[self performSelector:@selector(removeAll) withObject:nil afterDelay:0.3];
			break;
	}
	if (action) action(self);
}

- (void)removeAll{
	for (int i=0; i<_rightActions.count; i++) {
		[[self viewWithTag:ACTION_RIGHT_BTN_TAG+i] removeFromSuperview];
	}
	for (int i=0; i<_leftActions.count; i++) {
		[[self viewWithTag:ACTION_LEFT_BTN_TAG+i] removeFromSuperview];
	}
	[_contentView removeFromSuperview];
	_contentView = nil;
	_scrollView.delegate = nil;
	[_scrollView removeFromSuperview];
	_scrollView = nil;
	_delegate = nil;
	[self removeFromSuperview];
}

@end
