//
// Copyright (c) 2013 Related Code - http://relatedcode.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ProgressHUD.h"

@implementation hudBar
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor]; //设置为背景透明,可以在这里设置背景图片
		self.clearsContextBeforeDrawing = YES;
	}
	return self;
}
- (void)drawRect:(CGRect)rect {
	
}
@end

@interface ProgressHUD (){
	NSValue *_keyboardBoundsValue;
	AJProgressView *_progressView;
}
@end

@implementation ProgressHUD

+ (ProgressHUD*)shared {
	static dispatch_once_t once = 0;
	static ProgressHUD *progressHUD;
	dispatch_once(&once, ^{ progressHUD = [[ProgressHUD alloc] init]; });
	return progressHUD;
}

+ (void)show:(NSString*)status {
	[[self shared] hudMake:status image:nil imageSize:CGSizeZero autoSpin:YES autoHide:NO];
}

+ (void)show:(NSString*)status image:(UIImage*)image imageSize:(CGSize)imageSize {
	[[self shared] hudMake:status image:image imageSize:imageSize autoSpin:NO autoHide:NO];
}

+ (void)showNormal:(NSString*)status {
	[[self shared] hudMake:status image:nil imageSize:CGSizeZero autoSpin:NO autoHide:YES];
}

+ (void)showSuccess:(NSString*)status {
	[[self shared] hudMake:status image:IMG(@"success-white") imageSize:CGSizeMake(28*SCREEN_SCALE, 28*SCREEN_SCALE) autoSpin:NO autoHide:YES];
}

+ (void)showError:(NSString*)status {
	[[self shared] hudMake:status image:IMG(@"error-white") imageSize:CGSizeMake(28*SCREEN_SCALE, 28*SCREEN_SCALE) autoSpin:NO autoHide:YES];
}

+ (void)showTrouble:(NSString*)status {
	[[self shared] hudMake:status image:IMG(@"trouble-white") imageSize:CGSizeMake(28*SCREEN_SCALE, 28*SCREEN_SCALE) autoSpin:NO autoHide:YES];
}

+ (void)showWarning:(NSString*)status {
	[[self shared] hudMake:status image:IMG(@"warning-white") imageSize:CGSizeMake(28*SCREEN_SCALE, 28*SCREEN_SCALE) autoSpin:NO autoHide:YES];
}

+ (void)showProgress:(double)totalCount completed:(double)completed {
	[[self shared] hudMake:nil image:nil imageSize:CGSizeZero totalCount:totalCount completed:completed autoSpin:NO autoHide:NO];
}

+ (void)dismiss {
	[ProgressHUD dismiss:0.3];
}

+ (void)dismiss:(NSTimeInterval)delay {
	[NSObject cancelPreviousPerformRequestsWithTarget:[self shared] selector:@selector(setHide) object:nil];
	[[self shared] performSelector:@selector(setHide) withObject:nil afterDelay:delay];
}

+ (BOOL)isShowing {
	return [[self shared] isShowing];
}

+ (void)hiddenBg:(BOOL)hidden {
	[[self shared] setHiddenBg:hidden];
}

- (instancetype)init {
	self = [super initWithFrame:[UIScreen mainScreen].bounds];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ProgressHUDKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ProgressHUDKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate respondsToSelector:@selector(window)]) _window = [delegate performSelector:@selector(window)];
	else _window = [[UIApplication sharedApplication] keyWindow];
	_bg = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
	_bg.hidden = YES;
	[_window addSubview:_bg];
	_hud = nil;
	_hudColor = [UIColor colorWithWhite:0 alpha:0.6];
	_spinner = nil;
	_spinnerColor = [UIColor whiteColor];
	_image = nil;
	_label = nil;
	_textColor = [UIColor whiteColor];
	_textFont = FONTBOLD(16);
	self.alpha = 0;
	return self;
}

- (void)setHiddenBg:(BOOL)hiddenBg{
	_hiddenBg = hiddenBg;
}

- (void)hudMake:(NSString*)status image:(UIImage*)image imageSize:(CGSize)imageSize autoSpin:(BOOL)autoSpin autoHide:(BOOL)autoHide {
	[self hudMake:status image:image imageSize:imageSize totalCount:0.f completed:0.f autoSpin:autoSpin autoHide:autoHide];
}

- (void)hudMake:(NSString*)status image:(UIImage*)image imageSize:(CGSize)imageSize totalCount:(double)totalCount completed:(double)completed autoSpin:(BOOL)autoSpin autoHide:(BOOL)autoHide {
	_hiding = NO;
	dispatch_async(dispatch_get_main_queue(), ^{
		[_progressView removeFromSuperview];
		_progressView = nil;
		[self hudCreate:imageSize totalCount:totalCount completed:completed];
		if (!totalCount) {
			_label.text = status;
			_label.hidden = (status==nil || status.length<=0) ? YES : NO;
			_image.image = image;
			_image.hidden = (image==nil) ? YES : NO;
			if (autoSpin) [_spinner startAnimating];
			else [_spinner stopAnimating];
		}
		//[self hudOrient];
		[self hudSize];
		[self hudShow];
		if (autoHide) {
			NSTimeInterval sleep = _label.text.length * 0.2 + 0.5;
			[ProgressHUD dismiss:sleep];
		}
	});
}

- (void)ProgressHUDKeyboardWillShow:(NSNotification *)notification {
	NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
	_keyboardBoundsValue = keyboardBoundsValue;
	[self ProgressHUDAdjustViewForKeyboardReveal];
}
- (void)ProgressHUDKeyboardWillHide:(NSNotification *)notification {
	_keyboardBoundsValue = nil;
	CGRect bounds = [UIScreen mainScreen].bounds;
	CGRect frame = _hud.frame;
	frame.origin.y = (bounds.size.height - frame.size.height) / 2;
	[UIView animateWithDuration:0.3 animations:^{
		_hud.frame = frame;
	}];
}
- (void)ProgressHUDAdjustViewForKeyboardReveal {
	if (!_keyboardBoundsValue) return;
	CGRect bounds = [UIScreen mainScreen].bounds;
	CGRect frame = _hud.frame;
	CGRect keyboardbound = [_keyboardBoundsValue CGRectValue];
	frame.origin.y = (bounds.size.height - keyboardbound.size.height - frame.size.height) / 2;
	[UIView animateWithDuration:0.3 animations:^{
		_hud.frame = frame;
	}];
}

- (void)hudCreate:(CGSize)imageSize totalCount:(double)totalCount completed:(double)completed {
	if (_hud == nil) {
		_hud = [[hudBar alloc] initWithFrame:CGRectZero];
		_hud.backgroundColor = _hudColor;
		_hud.alpha = 1;
		_hud.layer.cornerRadius = 10*SCREEN_SCALE;
		_hud.layer.masksToBounds = YES;
		[_hud clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
			[ProgressHUD dismiss:0];
		}];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	if (_hud.superview == nil) [_window addSubview:_hud];
	if (totalCount>0) {
		if (_progressView == nil) {
			_progressView = [[AJProgressView alloc]initWithFrame:CGRectMake(0, 0, 40*SCREEN_SCALE, 40*SCREEN_SCALE)];
			_progressView.progressColor = COLORWHITE;
			_progressView.label.hidden = YES;
			[_hud addSubview:_progressView];
		}
		_progressView.progress = (float)completed / totalCount;
		return;
	}
	if (_spinner == nil) {
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_spinner.color = _spinnerColor;
		_spinner.hidesWhenStopped = YES;
	}
	if (_spinner.superview == nil) [_hud addSubview:_spinner];
	if (_image != nil) [_image removeFromSuperview];
	_image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
	if (_image.superview == nil) [_hud addSubview:_image];
	if (_label == nil) {
		_label = [[UILabel alloc] initWithFrame:CGRectZero];
		_label.font = _textFont;
		_label.textColor = _textColor;
		_label.backgroundColor = [UIColor clearColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		_label.numberOfLines = 0;
	}
	if (_label.superview == nil) [_hud addSubview:_label];
}

- (void)hudDestroy {
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[_label removeFromSuperview]; _label = nil;
	[_image removeFromSuperview]; _image = nil;
	[_spinner removeFromSuperview]; _spinner = nil;
	[_hud removeFromSuperview]; _hud = nil;
}

- (void)rotate:(NSNotification*)notification {
	//[self hudOrient];
}

- (BOOL)isShowing {
	return self.alpha != 0;
}

- (void)hudOrient {
	CGFloat rotate = 0.0;
	UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
	if (orient == UIInterfaceOrientationPortrait)			rotate = 0.0;
	if (orient == UIInterfaceOrientationPortraitUpsideDown)	rotate = M_PI;
	if (orient == UIInterfaceOrientationLandscapeLeft)		rotate = - M_PI_2;
	if (orient == UIInterfaceOrientationLandscapeRight)		rotate = + M_PI_2;
	_hud.transform = CGAffineTransformMakeRotation(rotate);
}

- (void)hudSize {
	CGRect labelRect = CGRectZero;
	CGFloat hudWidth = 100*SCREEN_SCALE, hudHeight = 100*SCREEN_SCALE;
	if (_progressView == nil) {
		if (_label.text != nil) {
			NSDictionary *attributes = @{NSFontAttributeName:_label.font};
			NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
			labelRect = [_label.text boundingRectWithSize:CGSizeMake(200*SCREEN_SCALE, 300*SCREEN_SCALE) options:options attributes:attributes context:NULL];
			labelRect.origin.x = 12*SCREEN_SCALE;
			labelRect.origin.y = 66*SCREEN_SCALE;
			hudWidth = labelRect.size.width + 24*SCREEN_SCALE;
			if (_image != nil) {
				if (hudWidth < 22*SCREEN_SCALE + _image.frame.size.width + 22*SCREEN_SCALE) {
					hudWidth = 22*SCREEN_SCALE + _image.frame.size.width + 22*SCREEN_SCALE;
					labelRect.origin.x = 0;
					labelRect.size.width = hudWidth;
				}
				hudHeight = 22*SCREEN_SCALE + _image.frame.size.height + 22*SCREEN_SCALE + labelRect.size.height + 8*SCREEN_SCALE;
				labelRect.origin.y = 22*SCREEN_SCALE + _image.frame.size.height + 15*SCREEN_SCALE;
			} else {
				hudHeight = labelRect.size.height + 80*SCREEN_SCALE;
			}
			if (hudWidth < 100*SCREEN_SCALE) {
				hudWidth = 100*SCREEN_SCALE;
				labelRect.origin.x = 0;
				labelRect.size.width = hudWidth;
			}
		}
	}
	CGSize screen = [UIScreen mainScreen].bounds.size;
	_hud.center = CGPointMake(screen.width/2, screen.height/2);
	_hud.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
	if (_progressView == nil) {
		CGRect frame = _image.frame;
		frame.origin.x = (hudWidth-frame.size.width)/2;
		frame.origin.y = (_label.text==nil) ? (hudHeight-frame.size.height)/2 : 22*SCREEN_SCALE;
		_image.frame = frame;
		_spinner.center = _image.center;
		_label.frame = labelRect;
	} else {
		_progressView.center = CGPointMake(_hud.frame.size.width/2, _hud.frame.size.height/2);
	}
	
	if (!_keyboardBoundsValue) return;
	CGRect bounds = [UIScreen mainScreen].bounds;
	CGRect frame = _hud.frame;
	CGRect keyboardbound = [_keyboardBoundsValue CGRectValue];
	frame.origin.y = (bounds.size.height - keyboardbound.size.height - frame.size.height) / 2;
	_hud.frame = frame;
}

- (void)hudShow {
	if (![self isShowing]) {
		self.alpha = 1;
		_bg.hidden = _hiddenBg;
		_hud.alpha = 0;
		_hud.transform = CGAffineTransformScale(_hud.transform, 1.4, 1.4);
		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;
		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			_hud.transform = CGAffineTransformScale(_hud.transform, 1/1.4, 1/1.4);
			_hud.alpha = 1;
		} completion:nil];
	}
}

- (void)setHide{
	_hiding = YES;
	[self hudHide];
}

- (void)hudHide {
	if (![self isShowing] || !_hiding) return;
	dispatch_async(dispatch_get_main_queue(), ^{
		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;
		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			_hud.transform = CGAffineTransformScale(_hud.transform, 0.7, 0.7);
			_hud.alpha = 0.5;
		} completion:^(BOOL finished){
			[self hudDestroy];
			_bg.hidden = YES;
			self.alpha = 0;
		}];
	});
}

@end
