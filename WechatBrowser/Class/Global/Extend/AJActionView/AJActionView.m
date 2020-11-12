//
//  AJActionView.m
//
//  Created by ajsong on 15/9/14.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AJActionView.h"

@implementation UIPickerView (GlobalExtend)
- (UIColor *)separatorColor{
	return self.element[@"separatorColor"];
}
- (void)setSeparatorColor:(UIColor *)separatorColor{
	self.element[@"separatorColor"] = separatorColor;
	for (UIView *speartorView in self.subviews) {
		if (speartorView.frame.size.height<1) {
			speartorView.backgroundColor = separatorColor;
		}
	}
}
@end


@implementation AJActionView{
	UIView *_overlay;
	NSValue *_keyboardBoundsValue;
	UILabel *_titleLabel;
}

- (instancetype)init{
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_mainView = [[UIView alloc]initWithFrame:CGRectMake(8*SCREEN_SCALE, 0, SCREEN_WIDTH-8*SCREEN_SCALE*2, 0)];
		_barView = [[UIToolbar alloc]init];
		_submitTextColor = [UIColor colorWithRed:0.f/255 green:122.f/255 blue:255.f/255 alpha:1];
		_cancelTextColor = [UIColor colorWithRed:0.f/255 green:122.f/255 blue:255.f/255 alpha:1];
	}
	return self;
}

- (instancetype)initWithTitle:(NSString*)title view:(UIView*)view delegate:(id<AJActionViewDelegate>)delegate{
	self = [self init];
	if (self) {
		_title = title;
		_view = view;
		_delegate = delegate;
		[self performSelector:@selector(create) withObject:nil afterDelay:0];
	}
	return self;
}

- (void)setTitle:(NSString *)title{
	_title = title;
	_titleLabel.text = _title;
}

- (void)create{
	[_overlay removeFromSuperview];
	for (UIView *subview in _mainView.subviews) {
		[subview removeFromSuperview];
	}
	for (UIView *subview in self.subviews) {
		[subview removeFromSuperview];
	}
	
	UIWindow *window = (UIWindow*)[[UIApplication sharedApplication].windows objectAtIndex:0];
	
	_overlay = [[UIView alloc]initWithFrame:SCREEN_BOUNDS];
	_overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
	_overlay.userInteractionEnabled = YES;
	_overlay.alpha = 0;
	_overlay.hidden = YES;
	[window addSubview:_overlay];
	
	UIButton *dismissBtn = [[UIButton alloc]initWithFrame:_overlay.bounds];
	dismissBtn.backgroundColor = [UIColor clearColor];
	[dismissBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
	[_overlay addSubview:dismissBtn];
	
	_mainView.clipsToBounds = YES;
	_mainView.layer.masksToBounds = YES;
	_mainView.layer.cornerRadius = 5*SCREEN_SCALE;
	[self addSubview:_mainView];
	
	[_mainView addSubview:_barView];
	
	CGRect frame = _view.bounds;
	if (_title.length) {
		_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _mainView.frame.size.width, 30*SCREEN_SCALE)];
		_titleLabel.text = _title;
		_titleLabel.textColor = [UIColor colorWithRed:153/255.f green:153/255.f blue:153/255.f alpha:1.f];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.font = [UIFont systemFontOfSize:12*SCREEN_SCALE];
		_titleLabel.backgroundColor = [UIColor clearColor];
		[_mainView addSubview:_titleLabel];
		frame.origin.y = _titleLabel.frame.size.height;
	}
	
	frame.origin.x = (_mainView.frame.size.width - frame.size.width) / 2;
	_view.frame = frame;
	[_mainView addSubview:_view];
	
	CGFloat top = _view.bottom;
	UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, top-0.5*SCREEN_SCALE, _mainView.frame.size.width, 0.5*SCREEN_SCALE)];
	line.backgroundColor = [UIColor colorWithWhite:0.756 alpha:1.000];
	[_mainView addSubview:line];
	
	if (_buttons && _buttons.count) {
		for (int i=0; i<_buttons.count; i++) {
			UIColor *color;
			if (_buttonColors && _buttonColors.count && i<=_buttonColors.count-1) {
				color = _buttonColors[i];
			} else {
				color = [UIColor colorWithRed:0.f/255 green:122.f/255 blue:255.f/255 alpha:1];
			}
			UIButton *submit = [[UIButton alloc]initWithFrame:CGRectMake(0, top, _mainView.frame.size.width, 44*SCREEN_SCALE)];
			submit.titleLabel.font = FONT(18);
			submit.backgroundColor = [UIColor clearColor];
			[submit setTitle:_buttons[i] forState:UIControlStateNormal];
			[submit setTitleColor:color forState:UIControlStateNormal];
			[submit addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
			submit.tag = i + 74350;
			[_mainView addSubview:submit];
			top += submit.frame.size.height;
		}
	} else {
		UIButton *submit = [[UIButton alloc]initWithFrame:CGRectMake(0, top, _mainView.frame.size.width, 44*SCREEN_SCALE)];
		submit.titleLabel.font = FONT(18);
		submit.backgroundColor = [UIColor clearColor];
		[submit setTitle:@"确定" forState:UIControlStateNormal];
		[submit setTitleColor:_submitTextColor forState:UIControlStateNormal];
		[submit addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
		[_mainView addSubview:submit];
		top += submit.frame.size.height;
	}
	
	_mainView.frame = CGRectMake(_mainView.frame.origin.x, 0, _mainView.frame.size.width, top);
	_barView.frame = _mainView.bounds;
	
	UIView *cancelView = [[UIView alloc]initWithFrame:CGRectMake(_mainView.frame.origin.x, _mainView.frame.size.height+8*SCREEN_SCALE, _mainView.frame.size.width, 44*SCREEN_SCALE)];
	cancelView.layer.masksToBounds = YES;
	cancelView.layer.cornerRadius = 5*SCREEN_SCALE;
	[self addSubview:cancelView];
	
	if (!_cancelBackgroundColor) {
		UIToolbar *cancelBar = [[UIToolbar alloc]init];
		cancelBar.frame = cancelView.bounds;
		cancelBar.clipsToBounds = YES;
		[cancelView addSubview:cancelBar];
	}
	
	UIButton *cancel = [[UIButton alloc]initWithFrame:cancelView.bounds];
	cancel.titleLabel.font = [UIFont boldSystemFontOfSize:18*SCREEN_SCALE];
	if (_cancelBackgroundColor) {
		cancel.backgroundColor = _cancelBackgroundColor;
	} else {
		cancel.backgroundColor = [UIColor clearColor];
	}
	[cancel setTitle:@"取消" forState:UIControlStateNormal];
	[cancel setTitleColor:_cancelTextColor forState:UIControlStateNormal];
	[cancel addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
	[cancelView addSubview:cancel];
	
	self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, cancelView.bottom+8*SCREEN_SCALE);
	self.hidden = YES;
	[window addSubview:self];
}

- (void)show{
	UIViewController *controller = APPCurrentController;
	[controller.view endEditing:YES];
	_overlay.hidden = NO;
	_overlay.alpha = 0;
	self.frame = CGRectMake(0, SCREEN_BOUNDS.size.height, SCREEN_BOUNDS.size.width, self.frame.size.height);
	self.hidden = NO;
	[UIView animateWithDuration:0.3 animations:^{
		if (_scale) controller.view.transform = CGAffineTransformMakeScale(_scale, _scale);
		_overlay.alpha = 1;
		self.frame = CGRectMake(0, SCREEN_BOUNDS.size.height-self.frame.size.height-(isX?34:0), SCREEN_BOUNDS.size.width, self.frame.size.height);
		if (_delegate && [_delegate respondsToSelector:@selector(AJActionViewWillShow:)]) {
			[_delegate AJActionViewWillShow:self];
		}
	}];
}

- (void)close{
	UIViewController *controller = APPCurrentController;
	[UIView animateWithDuration:0.3 animations:^{
		if (_scale) controller.view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
		_overlay.alpha = 0;
		self.frame = CGRectMake(0, SCREEN_BOUNDS.size.height, SCREEN_BOUNDS.size.width, self.frame.size.height);
	} completion:^(BOOL finished) {
		_overlay.hidden = YES;
		self.hidden = YES;
		if (_delegate && [_delegate respondsToSelector:@selector(AJActionViewDidClose:)]) {
			[_delegate AJActionViewDidClose:self];
		}
	}];
}

- (void)submit{
	if (_delegate && [_delegate respondsToSelector:@selector(AJActionViewDidSubmit:)]) {
		[_delegate AJActionViewDidSubmit:self];
	}
	[self close];
}

- (void)clickedButton:(UIButton*)sender{
	if (_delegate && [_delegate respondsToSelector:@selector(AJActionView:clickedButtonAtIndex:)]) {
		NSInteger tag = sender.tag - 74350;
		[_delegate AJActionView:self clickedButtonAtIndex:tag];
	}
	[self close];
}

@end
