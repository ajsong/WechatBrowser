//
//  CCPCalendarView.m
//  CCPCalendar
//
//  Created by Ceair on 17/5/25.
//  Copyright © 2017年 ccp. All rights reserved.
//

#import "CCPCalendarView.h"
#import "CCPCalendarHeader.h"
#import "NSDate+CCPCalendar.h"
#import "UIView+CCPView.h"
#import "CCPCalendarModel.h"
#import "CCPCalendarTable.h"

@interface CCPCalendarView()
{
    CGFloat bottomH;
    CGFloat scrStart;

}
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) CCPCalendarHeader *headerView;
@property (nonatomic, strong) NSMutableArray *selectArr;
@end

@implementation CCPCalendarView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectArr = [NSMutableArray array];
    }
    return self;
}

- (void)initSubviews {
    NSCAssert(self.manager, @"manager不可为空");
    [self headerView];
    [self createBottomView];
    [self createScr];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        _dateFormatter.timeZone = [NSTimeZone localTimeZone];
        _dateFormatter.locale = [NSLocale currentLocale];
    }
    return _dateFormatter;
}

- (CCPCalendarHeader *)headerView {
    if (!_headerView) {
        _headerView = [[CCPCalendarHeader alloc] init];
        _headerView.manager = self.manager;
        [_headerView initSubviews];
        CGFloat h = [_headerView getSupH];
        _headerView.frame = CGRectMake(0, 0, main_width, h);
        [self addSubview:_headerView];
    }
    return _headerView;
}

- (void)complete {
    if (self.manager.complete) {
        NSMutableArray *marr = [NSMutableArray array];
		if (self.manager.selectType == selectTypeSingle) {
			if (self.manager.selectArr.count == 0) {
				if (self.manager.close) {
					self.manager.close();
				}
				return;
			}
		}
        for (NSDate *date in self.manager.selectArr) {
            NSString *year = [NSString stringWithFormat:@"%ld", (long)[date getYear]];
            NSString *month = [NSString stringWithFormat:@"%02ld", (long)[date getMonth]];
            NSString *day = [NSString stringWithFormat:@"%02ld", (long)[date getDay]];
            NSString *weekString = [date weekString];
            NSInteger week = [date getWeek];
            NSString *ccpDate = [NSString stringWithFormat:@"%@-%@-%@", year, month, day];
            NSArray *arr = @[ccpDate, year, month, day, weekString, @(week)];
            CCPCalendarModel *model = [[CCPCalendarModel alloc] initWithArray:arr];
            [marr addObject:model];
        }
        self.manager.complete(marr);
        if (self.manager.close) {
            self.manager.close();
        }
    }
}

/*
 * 底部
 */
- (void)createBottomView {
    CGFloat t_gap = 15 * scale_h;
    CGFloat btnH = 49 * scale_h;
    UIView *bottomV = [[UIView alloc] init];
    bottomV.backgroundColor = [UIColor clearColor];
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveBtn.backgroundColor = [self.manager.normalTextColor setAlpha:0.2];
    _saveBtn.frame = CGRectMake(0, t_gap, main_width, btnH);
    [_saveBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_saveBtn setTitle:@"确定" forState:UIControlStateDisabled];
    [_saveBtn setTitleColor:self.manager.normalTextColor forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[self.manager.normalTextColor setAlpha:0.7] forState:UIControlStateDisabled];
	//_saveBtn.layer.cornerRadius = 5 * scale_w;
    _saveBtn.titleLabel.font = [UIFont systemFontOfSize:17 * scale_h];
    [_saveBtn addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    [bottomV addSubview:_saveBtn];
    CGFloat H = bottomH = [bottomV getSupH];
    bottomV.frame = CGRectMake(0, main_height - H, main_width, H);
    [self addSubview:bottomV];
}

//日历部分
- (void)createScr {
    CCPCalendarTable *table = [[CCPCalendarTable alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), main_width, main_height - bottomH - CGRectGetMaxY(self.headerView.frame)) manager:self.manager];
    [self addSubview:table];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"create date" forState:UIControlStateNormal];
    btn.layer.borderColor = self.manager.normalTextColor.CGColor;
    btn.layer.borderWidth = 1.0;
    btn.layer.cornerRadius = 3.0;
    btn.frame = CGRectMake(main_width - 120, CGRectGetMinY(table.frame) + 10, 110, 30);
    [btn addTarget:self action:@selector(scrToCreate) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
//    [self addSubview:btn];
}

- (void)scrToCreate {
    if (self.manager.scrToCreateDate) {
        self.manager.scrToCreateDate();
    }
}

@end
