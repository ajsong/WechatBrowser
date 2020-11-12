//
//  JKNotifier.m
//
//  Created by Jakey on 15/5/21.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "JKNotifier.h"

NSString * const JKNotifierBarDismiss = @"JKNotifierBarDismiss";

@interface JKNotifier()
@property (nonatomic,strong) NSMutableArray *notifierBars;
@property (nonatomic,strong) UIImage *defaultIcon;
@property (nonatomic,strong) NSString *appName;
@end

@implementation JKNotifier

+ (JKNotifier*)shareInstance{
	static dispatch_once_t onceToken;
	static JKNotifier *notifier;
	dispatch_once(&onceToken, ^{ notifier = [[self alloc]init]; });
	return notifier;
}

- (instancetype)init{
	self = [super init];
	if (self) {
		self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
		self.clipsToBounds = YES;
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
		self.hidden = YES;
		[KEYWINDOW addSubview:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(JKNotifierBarDismiss:) name:JKNotifierBarDismiss object:nil];
	}
	return self;
}

#pragma mark - getter
- (NSString*)appName{
	if (!_appName) {
		_appName =  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]?:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	}
	return _appName;
}
- (UIImage*)defaultIcon{
	if (!_defaultIcon) {
		_defaultIcon = [self loadPlistIcon] ?:IMGAPPICON?:[UIImage imageNamed:@"JKNotifier_Icon"];
	}
	return _defaultIcon;
}
- (NSMutableArray*)notifierBars{
	if (!_notifierBars) {
		_notifierBars = [[NSMutableArray alloc]init];
	}
	return _notifierBars;
}

#pragma mark - class method
+ (JKNotifierBar*)show:(NSString*)note{
	return [JKNotifier show:note name:nil];
}

+ (JKNotifierBar*)show:(NSString*)note name:(NSString*)name{
	return [JKNotifier showAuto:note name:name icon:nil dismiss:-1];
}

+ (JKNotifierBar*)showAuto:(NSString*)note{
	return [JKNotifier showAuto:note dismiss:JKN_DISMISS_TIME];
}

+ (JKNotifierBar*)showAuto:(NSString*)note name:(NSString*)name icon:(UIImage*)icon{
	return [JKNotifier showAuto:note name:name icon:icon dismiss:JKN_DISMISS_TIME];
}

+ (JKNotifierBar*)showAuto:(NSString *)note dismiss:(NSTimeInterval)delay{
	return [self showAuto:note name:nil icon:nil dismiss:delay];
}

+ (JKNotifierBar*)showAuto:(NSString*)note name:(NSString*)name icon:(UIImage*)icon dismiss:(NSTimeInterval)delay{
	JKNotifierBar *bar = [[self shareInstance] show:note
											   name:name?:[self shareInstance].appName
											   icon:icon?:[self shareInstance].defaultIcon
											dismiss:delay];
	return bar;
}

+ (void)dismiss{
	JKNotifier *notifier = [self shareInstance];
	CGRect frame = notifier.frame;
	frame.origin.y = -frame.size.height;
	[UIView animateWithDuration:0.3 animations:^{
		notifier.frame = frame;
	} completion:^(BOOL finished) {
		[notifier removeAllSubviews];
		notifier.top = 0;
		notifier.height = 0;
		notifier.hidden = YES;
		[notifier setNeedsDisplay];
	}];
}

#pragma mark - instance method
- (JKNotifierBar*)show:(NSString*)note name:(NSString*)name icon:(UIImage*)icon dismiss:(NSTimeInterval)delay{
	AudioServicesPlaySystemSound(1007);
	JKNotifierBar *notifierBar = [[JKNotifierBar alloc]init];
	[notifierBar show:note name:name icon:icon dismiss:delay];
	CGRect frame = notifierBar.frame;
	CGFloat height = frame.size.height;
	frame.origin.y = 20;
	frame.size.height = 0;
	notifierBar.frame = frame;
	[self insertSubview:notifierBar atIndex:0];
	[self.notifierBars addObject:notifierBar];
	self.hidden = NO;
	
	__weak typeof(notifierBar) _notifierBar = notifierBar;
	[notifierBar setHeightAndChangeNextTop:height animate:^(UIView *view) {
		self.height = self.lastSubview.bottom + 12*SCREEN_SCALE;
		[self setNeedsDisplay];
	} completion:^(UIView *view) {
		self.height = self.lastSubview.bottom + 12*SCREEN_SCALE;
		[self setNeedsDisplay];
	}];
	//[notifierBar.layer removeAllAnimations]; //停止 UIView animateWithDuration:animations: 的动画
	return notifierBar;
}

- (void)JKNotifierBarDismiss:(NSNotification *)notification{
	if (self.notifierBars.count==1) {
		[JKNotifier dismiss];
		return;
	}
	JKNotifierBar *notifierBar = notification.userInfo[@"notifierBar"];
	__weak typeof(notifierBar) _notifierBar = notifierBar;
	[notifierBar setHeightAndChangeNextTop:0 animate:^(UIView *view) {
		self.height = self.lastSubview.bottom + 12*SCREEN_SCALE;
	} completion:^(UIView *view) {
		[self.notifierBars removeObject:_notifierBar];
		[_notifierBar removeFromSuperview];
		if (self.notifierBars.count==1) {
			[JKNotifier dismiss];
			return;
		}
		self.height = self.lastSubview.bottom + 12*SCREEN_SCALE;
		[self setNeedsDisplay];
	}];
}

#pragma mark - helper
- (UIImage*)loadPlistIcon{
	NSString *iconString = @"Icon.png";
	NSArray *icons = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIconFiles"];
	if (!icons) {
		iconString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIconFile"];
	} else {
		iconString = icons[0];
	}
	return [UIImage imageNamed:iconString];
}

- (void)drawRect:(CGRect)rect{
	UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
	UIBezierPath *round = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((rect.size.width-35*SCREEN_SCALE)/2, rect.size.height-(5+7)*SCREEN_SCALE, 35*SCREEN_SCALE, 5*SCREEN_SCALE) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10*SCREEN_SCALE, 10*SCREEN_SCALE)];
	[path appendPath:[round bezierPathByReversingPath]];
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = path.CGPath;
	[self.layer setMask:shapeLayer];
}

@end
