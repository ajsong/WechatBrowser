//
//  CCPCalendarManager.m
//
//  Created by Ceair on 17/5/25.
//  Copyright © 2017年 ccp. All rights reserved.
//

#import "CCPCalendarManager.h"
#import "CCPCalendarView.h"

@interface CCPCalendarManager()

@end

@implementation CCPCalendarManager

- (UIWindow *)appWindow {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.window;
}

- (instancetype)init{
	self = [super init];
	if (self) {
		_selectArr = [NSMutableArray array];
		_selectBtns = [NSMutableArray array];
		_createDate = [NSDate date];
		_todayTextColor = rgba(255, 30, 30, 1.0);
		_normalTextColor = rgba(255, 255, 255, 1.0);
		_selectedTextColor = rgba(35, 59, 97, 1.0);
		_disableTextColor = [_normalTextColor setAlpha:0.3];
		_normalBgColor = [UIColor clearColor];
		_selectedBgColor = [UIColor whiteColor];
		_dateEnableRange = [NSArray array];
		_startTitle = [@"开始" stringByAppendingFormat:@"\n%@",@"日期"];
		_endTitle = [@"结束" stringByAppendingFormat:@"\n%@",@"日期"];
		_postionDate = [NSDate date];
	}
	return self;
}

- (void)setSelectedDate:(NSArray<NSString *> *)selectedDate{
	_selectedDate = selectedDate;
	if (selectedDate.isArray) {
		for (NSString *date in selectedDate) {
			[_selectArr addObject:[Global dateFromString:date]];
		}
	}
}

- (void)setNormalTextColor:(UIColor *)normalTextColor{
	_normalTextColor = normalTextColor;
	_disableTextColor = [_normalTextColor setAlpha:0.3];
}

- (CCPCalendarView*)cal{
	if (!_cal) {
		_cal = [[CCPCalendarView alloc] init];
		_cal.frame = CGRectMake(0, main_height, main_width, main_height);
		_cal.manager = self;
		if (!_backgroundColor) {
			_cal.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-date"]];
		} else {
			_cal.backgroundColor = _backgroundColor;
		}
		[_cal initSubviews];
		[[self appWindow] addSubview:_cal];
	}
	return _cal;
}

- (void)showCalendar{
	[self cal];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		_cal.frame = CGRectMake(0, 0, main_width, main_height);
	} completion:nil];
}

- (closeBlock)close {
    __weak typeof(_cal)weekAV = _cal;
    __weak typeof(self)ws = self;
    if (!_close) {
        _close = ^() {
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                weekAV.frame = CGRectMake(0, main_height, main_width, main_height);
            } completion:^(BOOL finished) {
                if (ws.clean) {
                    ws.clean();
                }
            }];
        };
    }
    return _close;
}

//单选有过去
+ (void)showSinglePast:(completeBlock)complete {
    CCPCalendarManager *manager = [CCPCalendarManager new];
    manager.isShowPast = YES;
    manager.complete = complete;
    [manager showCalendar];
}
//多选有过去
+ (void)showMultiplePast:(completeBlock)complete {
    CCPCalendarManager *manager = [CCPCalendarManager new];
    manager.isShowPast = YES;
    manager.selectType = selectTypeMultiple;
    manager.complete = complete;
    [manager showCalendar];
}
//单选多个有过去
+ (void)showSingleMultiplePast:(completeBlock)complete {
	CCPCalendarManager *manager = [CCPCalendarManager new];
	manager.isShowPast = YES;
	manager.selectType = selectTypeSingleMultiple;
	manager.complete = complete;
	[manager showCalendar];
}
//单选没过去
+ (void)showSingle:(completeBlock)complete {
    CCPCalendarManager *manager = [CCPCalendarManager new];
    manager.isShowPast = NO;
    manager.complete = complete;
    [manager showCalendar];
}
//多选没过去
+ (void)showMultiple:(completeBlock)complete {
    CCPCalendarManager *manager = [CCPCalendarManager new];
    manager.isShowPast = NO;
    manager.selectType = selectTypeMultiple;
    manager.complete = complete;
    [manager showCalendar];
}
//单选多个没过去
+ (void)showSingleMultiple:(completeBlock)complete {
	CCPCalendarManager *manager = [CCPCalendarManager new];
	manager.isShowPast = NO;
	manager.selectType = selectTypeSingleMultiple;
	manager.complete = complete;
	[manager showCalendar];
}

//单选有过去
- (void)showSinglePast:(completeBlock)complete {
    self.isShowPast = YES;
    self.selectType = selectTypeSingle;
    self.complete = complete;
    [self showCalendar];
}
//多选有过去
- (void)showMultiplePast:(completeBlock)complete {
    self.isShowPast = YES;
    self.selectType = selectTypeMultiple;
    self.complete = complete;
    [self showCalendar];
}
//单选多个有过去
- (void)showSingleMultiplePast:(completeBlock)complete {
	self.isShowPast = YES;
	self.selectType = selectTypeSingleMultiple;
	self.complete = complete;
	[self showCalendar];
}
//单选没过去
- (void)showSingle:(completeBlock)complete {
    self.isShowPast = NO;
    self.selectType = selectTypeSingle;
    self.complete = complete;
    [self showCalendar];
}
//多选没过去
- (void)showMultiple:(completeBlock)complete {
    self.isShowPast = NO;
    self.selectType = selectTypeMultiple;
    self.complete = complete;
    [self showCalendar];
}
//单选多个没过去
- (void)showSingleMultiple:(completeBlock)complete {
	self.isShowPast = NO;
	self.selectType = selectTypeSingleMultiple;
	self.complete = complete;
	[self showCalendar];
}

@end
