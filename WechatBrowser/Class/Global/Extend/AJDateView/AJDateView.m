//
//  AJDateView.m
//
//  Created by ajsong on 2014-9-1.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AJDateView.h"

@interface AJDateView ()<UIPickerViewDataSource,UIPickerViewDelegate,AJActionViewDelegate>{
	UIView *_mainView;
	UIPickerView *_pickerView;
	
	NSMutableArray *_types;
	NSMutableDictionary *_rowNumData;
	NSMutableArray *_labels;
	NSMutableArray *_dates;
	
	NSInteger _minYear;
	NSInteger _maxYear;
	
	NSMutableArray *_years;
	NSMutableArray *_months;
	NSMutableArray *_days;
	NSMutableArray *_hours;
	NSMutableArray *_minutes;
	
	NSInteger _yearIndex;
	NSInteger _monthIndex;
	NSInteger _dayIndex;
	NSInteger _hourIndex;
	NSInteger _minuteIndex;
	
	NSMutableArray *_yearTexts;
}
@end

@implementation AJDateView

- (instancetype)init{
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_actionView = [[AJActionView alloc]init];
		_date = [NSDate date];
		_title = @"选择时间";
		_type = @"ymd";
		_minimumDate = [Global dateFromString:@"1900-01-01 00:00"];
		_maximumDate = [Global dateFromString:@"2099-12-31 23:59"];
		_minYear = [[Global formatDate:_minimumDate format:@"yyyy"]integerValue];
		_maxYear = [[Global formatDate:_maximumDate format:@"yyyy"]integerValue];
		_textFont = FONT(18);
		_textColor = [UIColor blackColor];
		_dateColor = [UIColor blackColor];
		_labels = [[NSMutableArray alloc]init];
		_dates = [[NSMutableArray alloc]init];
		_yearTexts = [[NSMutableArray alloc]init];
		_years = [[NSMutableArray alloc]init];
		_months = [[NSMutableArray alloc]init];
		_days = [[NSMutableArray alloc]init];
		_hours = [[NSMutableArray alloc]init];
		_minutes = [[NSMutableArray alloc]init];
		[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
	}
	return self;
}

- (void)loadViews{
	if (!_type.length) {
		[ProgressHUD showError:@"缺少时间类型"];
		return;
	}
	
	_types = [_type splitString];
	_rowNumData = [[NSMutableDictionary alloc]init];
	
	for (NSInteger i=_minYear; i<=_maxYear; i++) {
		[_years addObject:[NSString stringWithFormat:@"%ld", (long)i]];
		[_yearTexts addObject:[NSString stringWithFormat:@" %ld", (long)i]];
	}
	
	for (int i=0; i<60; i++) {
		NSString *num = [NSString stringWithFormat:@"%02d", i];
		if (0<i && i<=12) [_months addObject:num];
		if (i<24) [_hours addObject:num];
		[_minutes addObject:num];
	}
	
	for (NSString *s in _types) {
		if (!s.length) continue;
		if ([s.lowercaseString isEqualToString:@"yyyy"] || [s.lowercaseString isEqualToString:@"y"]) {
			[_dates addObject:@"y"];
			[_rowNumData setObject:_years forKey:@"y"];
		} else if ([s.lowercaseString isEqualToString:@"m"] || [s.lowercaseString isEqualToString:@"mm"]) {
			[_dates addObject:@"m"];
			[_rowNumData setObject:_months forKey:@"m"];
		} else if ([s.lowercaseString isEqualToString:@"d"] || [s.lowercaseString isEqualToString:@"dd"]) {
			[_dates addObject:@"d"];
			[_rowNumData setObject:_days forKey:@"d"];
		} else if ([s.lowercaseString isEqualToString:@"h"] || [s.lowercaseString isEqualToString:@"hh"]) {
			[_dates addObject:@"h"];
			[_rowNumData setObject:_hours forKey:@"h"];
		} else if ([s.lowercaseString isEqualToString:@"n"] || [s.lowercaseString isEqualToString:@"nn"]) {
			[_dates addObject:@"n"];
			[_rowNumData setObject:_minutes forKey:@"n"];
		} else {
			[_labels addObject:s];
		}
	}
	
	_pickerView = [[UIPickerView alloc]init];
	_pickerView.separatorColor = COLOR_GE;
	_pickerView.backgroundColor = [UIColor clearColor];
	_pickerView.showsSelectionIndicator = YES;
	_pickerView.delegate = self;
	_pickerView.dataSource = self;
	_mainView = [[UIView alloc]initWithFrame:_pickerView.bounds];
	[_mainView addSubview:_pickerView];
	if (_labels.count) [self addLabels:_labels];
	
	_actionView.title = _title;
	_actionView.view = _mainView;
	_actionView.delegate = self;
	[_actionView performSelector:@selector(create) withObject:nil afterDelay:0];
	
	[self selectDate:_date animated:NO];
}

- (void)setTitle:(NSString *)title{
	_title = title;
	_actionView.title = _title;
}

- (void)addLabels:(NSArray *)nameArr{
	for (id subView in _mainView.subviews) {
		if ([subView isKindOfClass:[UILabel class]]) [subView removeFromSuperview];
	}
	for (int i=0; i<nameArr.count; i++) {
		NSString *string = nameArr[i];
		CGSize s = [string autoWidth:_textFont height:40*SCREEN_SCALE];
		CGFloat x = _mainView.width/(nameArr.count*2)+(([_types.firstObject isEqualToString:@"y"]&&[_dates[i]isEqualToString:@"y"])?30*SCREEN_SCALE:(_types.count<4?0:18*SCREEN_SCALE))+_mainView.width/nameArr.count*i;
		if (nameArr.count>=4 && i==nameArr.count-1) x -= 5*SCREEN_SCALE;
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(x, (_mainView.height-40*SCREEN_SCALE)/2, s.width, 40*SCREEN_SCALE)];
		label.text = string;
		label.textColor =  _textColor;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = _textFont;
		label.backgroundColor = [UIColor clearColor];
		[_mainView addSubview:label];
	}
}

- (void)setDate:(NSDate *)date{
	_date = date;
	[self selectDate:_date animated:YES];
}

- (void)setTextColor:(UIColor *)textColor{
	_textColor = textColor;
	for (id subview in _mainView.subviews) {
		if ([subview isKindOfClass:[UILabel class]]) {
			UILabel *label = subview;
			label.textColor = textColor;
		}
	}
}

- (void)setMinimumDate:(NSDate *)minimumDate{
	_minimumDate = minimumDate;
	if ([_date compare:minimumDate] == NSOrderedAscending) _date = minimumDate;
	_minYear = [[Global formatDate:_minimumDate format:@"yyyy"]integerValue];
	[self selectDate:_date animated:NO];
}

- (void)setMaximumDate:(NSDate *)maximumDate{
	_maximumDate = maximumDate;
	if ([_date compare:maximumDate] == NSOrderedDescending) _date = maximumDate;
	_maxYear = [[Global formatDate:_maximumDate format:@"yyyy"]integerValue];
}

- (NSArray *)getNumberOfRowsInComponent{
	NSInteger dayNum = [self daysFromYear:[_years[_yearIndex]integerValue] month:[_months[_monthIndex]integerValue]];
	NSMutableArray *rows = [[NSMutableArray alloc]init];
	for (NSString *s in _types) {
		if (!s.length) continue;
		if ([s.lowercaseString isEqualToString:@"yyyy"] || [s.lowercaseString isEqualToString:@"y"]) {
			[rows addObject:@(_years.count)];
		} else if ([s.lowercaseString isEqualToString:@"m"] || [s.lowercaseString isEqualToString:@"mm"]) {
			[rows addObject:@(_months.count)];
		} else if ([s.lowercaseString isEqualToString:@"d"] || [s.lowercaseString isEqualToString:@"dd"]) {
			[rows addObject:@(dayNum)];
			[_rowNumData setObject:_days forKey:@"d"];
		} else if ([s.lowercaseString isEqualToString:@"h"] || [s.lowercaseString isEqualToString:@"hh"]) {
			[rows addObject:@(_hours.count)];
		} else if ([s.lowercaseString isEqualToString:@"n"] || [s.lowercaseString isEqualToString:@"nn"]) {
			[rows addObject:@(_minutes.count)];
		}
	}
	return rows;
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return _dates.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	NSArray *numberArr = [self getNumberOfRowsInComponent];
	return [numberArr[component]integerValue];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
	return 40*SCREEN_SCALE;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	pickerView.separatorColor = COLOR_GE;
	
	UILabel *label = [UILabel new];
	if ([_dates[component] isEqualToString:@"y"]) {
		label.text = _yearTexts[row];
	} else {
		label.text = _rowNumData[_dates[component]][row];
	}
	label.textColor = _dateColor;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = _textFont;
	label.backgroundColor = [UIColor clearColor];
	label.lineBreakMode = NSLineBreakByTruncatingMiddle;
	label.minimumScaleFactor = 0.8;
	label.adjustsFontSizeToFitWidth = YES;
	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if ([_dates[component] isEqualToString:@"y"]) _yearIndex = row;
	if ([_dates[component] isEqualToString:@"m"]) _monthIndex = row;
	if ([_dates[component] isEqualToString:@"d"]) _dayIndex = row;
	if ([_dates[component] isEqualToString:@"h"]) _hourIndex = row;
	if ([_dates[component] isEqualToString:@"n"]) _minuteIndex = row;
	if (!([@"y" inArray:_dates]==NSNotFound && [@"m" inArray:_dates]==NSNotFound && [@"d" inArray:_dates]==NSNotFound)) {
		if (component<=1){
			[self daysFromYear:[_years[_yearIndex] integerValue] month:[_months[_monthIndex]integerValue]];
			if (_days.count-1<_dayIndex) _dayIndex = _days.count-1;
		}
		if ([@"y" inArray:_dates]==NSNotFound) [self daysFromYear:[_years[_yearIndex] integerValue] month:[_months[_monthIndex]integerValue]];
	}
	[pickerView reloadAllComponents];
	
	NSString *date = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", _years[_yearIndex], _months[_monthIndex], _days[_dayIndex], _hours[_hourIndex], _minutes[_minuteIndex]];
	_date = [Global dateFromString:date];
	
	if ([_date compare:_minimumDate] == NSOrderedAscending) {
		_date = _minimumDate;
		[self selectDate:_minimumDate animated:YES];
	} else if ([_date compare:_maximumDate] == NSOrderedDescending) {
		_date = _maximumDate;
		[self selectDate:_maximumDate animated:YES];
	}
	
	if (_delegate && [_delegate respondsToSelector:@selector(AJDateView:didSelectWithDate:year:month:)]) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[_delegate AJDateView:self didSelectWithDate:_date year:STRING(_years[_yearIndex]) month:STRING(_months[_monthIndex])];
			});
		});
	}
}

#pragma mark - tools
//通过年月求每月天数
- (NSInteger)daysFromYear:(NSInteger)year month:(NSInteger)month{
	NSInteger numYear  = year;
	NSInteger numMonth = month;
	BOOL isRunNian = numYear%4==0 ? (numYear%100==0?(numYear%400==0?YES:NO):YES) : NO;
	switch (numMonth) {
		case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
			[self setDayArray:31];
			return 31;
		}
		case 4:case 6:case 9:case 11:{
			[self setDayArray:30];
			return 30;
		}
		case 2:{
			if (isRunNian) {
				[self setDayArray:29];
				return 29;
			} else {
				[self setDayArray:28];
				return 28;
			}
		}
		default:
			break;
	}
	return 0;
}

//设置每月的天数数组
- (void)setDayArray:(NSInteger)num{
	[_days removeAllObjects];
	for (int i=1; i<=num; i++) {
		[_days addObject:[NSString stringWithFormat:@"%02d", i]];
	}
}

//滚动到指定的时间位置
- (void)selectDate:(NSDate *)date animated:(BOOL)animated{
	if (!date) date = [NSDate date];
	[self daysFromYear:date.year month:date.month];
	
	_yearIndex = date.year-_minYear;
	_monthIndex = date.month-1;
	_dayIndex = date.day-1;
	_hourIndex = date.hour;
	_minuteIndex = date.minute;
	
	NSMutableArray *indexArray = [[NSMutableArray alloc]init];
	for (NSString *s in _types) {
		if (!s.length) continue;
		if ([s.lowercaseString isEqualToString:@"yyyy"] || [s.lowercaseString isEqualToString:@"y"]) {
			[indexArray addObject:@(_yearIndex)];
		} else if ([s.lowercaseString isEqualToString:@"m"] || [s.lowercaseString isEqualToString:@"mm"]) {
			[indexArray addObject:@(_monthIndex)];
		} else if ([s.lowercaseString isEqualToString:@"d"] || [s.lowercaseString isEqualToString:@"dd"]) {
			[indexArray addObject:@(_dayIndex)];
		} else if ([s.lowercaseString isEqualToString:@"h"] || [s.lowercaseString isEqualToString:@"hh"]) {
			[indexArray addObject:@(_hourIndex)];
		} else if ([s.lowercaseString isEqualToString:@"n"] || [s.lowercaseString isEqualToString:@"nn"]) {
			[indexArray addObject:@(_minuteIndex)];
		}
	}
	
	[_pickerView reloadAllComponents];
	
	for (int i=0; i<indexArray.count; i++) {
		[_pickerView selectRow:[indexArray[i]integerValue] inComponent:i animated:animated];
	}
}

- (void)show{
	[_actionView show];
}

- (void)close{
	[_actionView close];
}

#pragma mark - AJActionViewDelegate
- (void)AJActionViewWillShow:(AJActionView *)actionView{
	NSString *date = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", _years[_yearIndex], _months[_monthIndex], _days[_dayIndex], _hours[_hourIndex], _minutes[_minuteIndex]];
	_date = [Global dateFromString:date];
	if (_delegate && [_delegate respondsToSelector:@selector(AJDateView:didSelectWithDate:year:month:)]) {
		[_delegate AJDateView:self didSelectWithDate:_date year:STRING(_years[_yearIndex]) month:STRING(_months[_monthIndex])];
	}
}

- (void)AJActionViewDidSubmit:(AJActionView *)actionView{
	NSString *date = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", _years[_yearIndex], _months[_monthIndex], _days[_dayIndex], _hours[_hourIndex], _minutes[_minuteIndex]];
	_date = [Global dateFromString:date];
	if (_delegate && [_delegate respondsToSelector:@selector(AJDateView:didSubmitWithDate:year:month:)]) {
		[_delegate AJDateView:self didSubmitWithDate:_date year:STRING(_years[_yearIndex]) month:STRING(_months[_monthIndex])];
	}
}

@end
