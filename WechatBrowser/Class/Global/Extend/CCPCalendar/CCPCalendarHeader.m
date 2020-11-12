//
//  CCPCalendarHeader.m
//  CCPCalendar
//
//  Created by Ceair on 17/5/25.
//  Copyright © 2017年 ccp. All rights reserved.
//

#import "CCPCalendarHeader.h"
#import "UIView+CCPView.h"
#import "NSDate+CCPCalendar.h"

@interface CCPCalendarHeader()
{
    /*
     * l_gap,r_gap 左右距离
     * big_l_gap,big_r_gap 大字左右距离
     * t_gap 上方间距
     */
    CGFloat l_gap,r_gap,big_l_gap,big_r_gap,t_gap;
    
    UIButton *l_btn,*r_btn;
    UILabel *l_label, *r_label;
}
@end

@implementation CCPCalendarHeader

- (instancetype)init {
    if (self = [super init]) {
        l_gap = r_gap = scale_w * 20.0;
        big_l_gap = big_r_gap = scale_w * 25.0;
        t_gap = scale_h * 15;
        self.backgroundColor = [UIColor clearColor];
        [self addObserver:self forKeyPath:@"manager.selectArr" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"manager.startTitle" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)initSubviews {
    [self functionBtns];
    [self showSelect];
    [self weeks];
    [self line];
    CGFloat h = [self getSupH];
    UIView *bLine = [[UIView alloc] initWithFrame:CGRectMake(0, h, main_width, 1)];
    bLine.backgroundColor = [self.manager.normalTextColor setAlpha:0.2];
    [self addSubview:bLine];
}

/*
 * 最上方按钮
 */
- (void)functionBtns {
    r_btn = [UIButton buttonWithType:UIButtonTypeCustom];
	[r_btn setTitle:@"清除" forState:UIControlStateNormal];
	[r_btn setTitleColor:self.manager.normalTextColor forState:UIControlStateNormal];
    r_btn.titleLabel.font = [UIFont systemFontOfSize:14.0 * scale_w];
    [r_btn addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    r_btn.frame = CGRectMake(main_width - r_gap - [self r_btn_w], t_gap + 5, [self r_btn_w], scale_w * 25);
    r_btn.hidden = YES;
    [self addSubview:r_btn];
	
	l_btn = [UIButton buttonWithType:UIButtonTypeCustom];
	[l_btn setTitle:@"关闭" forState:UIControlStateNormal];
	[l_btn setTitleColor:self.manager.normalTextColor forState:UIControlStateNormal];
	l_btn.titleLabel.font = [UIFont systemFontOfSize:14.0 * scale_w];
	l_btn.frame = CGRectMake(l_gap, t_gap + 5, [self r_btn_w], scale_w * 25);
	[l_btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
	[l_btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
	[self addSubview:l_btn];
}

//中间显示大字
- (void)showSelect {
    l_label = [[UILabel alloc] init];
    l_label.font = [UIFont systemFontOfSize:scale_w * 20];
    l_label.textColor = self.manager.normalTextColor;
    l_label.textAlignment = NSTextAlignmentLeft;
    l_label.numberOfLines = 2;
    [self addSubview:l_label];
    if (self.manager.selectType == selectTypeMultiple) {
        r_label = [[UILabel alloc] init];
        r_label.font = l_label.font;
        r_label.textColor = self.manager.normalTextColor;
        r_label.textAlignment = NSTextAlignmentRight;
        r_label.numberOfLines = 2;
        [self addSubview:r_label];
    }
    [self displayLabel];
}

//星期
- (void)weeks {
	//NSArray *arr = @[@"SUN", @"Mon", @"TUE", @"WED", @"THU", @"FRI", @"SAT"];
	NSArray *arr = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    CGFloat w = main_width / 7;
    CGFloat y;
    for (int idx = 0; idx < arr.count; idx ++) {
        NSString *week = arr[idx];
        UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(w * idx , CGRectGetMaxY(l_label.frame) + 15 * scale_h, w, 25 * scale_h)];
        //y = CGRectGetMaxY(weekLabel.frame);
        weekLabel.textAlignment = NSTextAlignmentCenter;
        weekLabel.font = [UIFont systemFontOfSize:14 * scale_h];
        weekLabel.textColor = self.manager.normalTextColor;
        weekLabel.text = week;
        [self addSubview:weekLabel];
    }
}

//中间斜线
- (void)line {
    if (self.manager.selectType == selectTypeMultiple) {
        CGFloat distance = 25 * scale_w;
        CGFloat centerX = main_width / 2;
        CGPoint startP = CGPointMake(centerX - distance, CGRectGetMaxY(l_label.frame) - 5);
        CGPoint endP = CGPointMake(centerX + distance, CGRectGetMinY(r_label.frame) + 5);
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:startP];
        [path addLineToPoint:endP];
        CAShapeLayer *shapeL = [CAShapeLayer layer];
        shapeL.path = path.CGPath;
        shapeL.lineWidth = 0.5;
        shapeL.strokeColor = self.manager.normalTextColor.CGColor;
        [self.layer addSublayer:shapeL];
    }
}

- (CGFloat)r_btn_w {
    NSString *tt = r_btn.titleLabel.text;
    CGRect rect = [tt boundingRectWithSize:CGSizeMake(1000, 25 * scale_w) options:NSStringDrawingUsesFontLeading attributes:@{NSForegroundColorAttributeName : self.manager.normalTextColor, NSFontAttributeName : [UIFont systemFontOfSize:14 * scale_w]} context:nil];
    return rect.size.width;
}

- (void)displayLabel {
    CGFloat top = 15 * scale_h;
    CGFloat h = 48 * scale_h;
    if (![self.manager.startTitle isEqualToString:l_label.text]) {
        l_label.text = self.manager.startTitle;
        CGFloat w = [l_label widthBy:h];
        l_label.frame = CGRectMake(big_l_gap, CGRectGetMaxY(l_btn.frame) + top, w, h);
    }
    if (![self.manager.endTitle isEqualToString:r_label.text]) {
        r_label.text = self.manager.endTitle;
        CGFloat w = [r_label widthBy:h];
        r_label.frame = CGRectMake(main_width - big_r_gap - w, CGRectGetMaxY(l_btn.frame) + top, w, h);
    }
}

- (void)close {
    if (self.manager.close) {
        self.manager.close();
    }
}

- (void)clear {
    [[self.manager mutableArrayValueForKey:@"selectArr"] removeAllObjects];
    if (self.manager.clean) {
        self.manager.clean();
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"manager.selectArr"]) {
        NSArray *arr = self.manager.selectArr.copy;
        if (arr.count == 0) {
            self.manager.startTitle = self.manager.endTitle = nil;
        }
        else if (arr.count == 1) {
            self.manager.endTitle = nil;
            NSDate *date = arr.firstObject;
            self.manager.startTitle = [NSString stringWithFormat:@"%ld月%02ld日\n%@",(long)[date getMonth],(long)[date getDay],[date weekString]];
            
        }
        else if (arr.count == 2){
            NSDate *date1 = arr.firstObject;
            NSDate *date2 = arr[1];
            self.manager.startTitle = [NSString stringWithFormat:@"%ld月%02ld日\n%@",(long)[date1 getMonth],(long)[date1 getDay],[date1 weekString]];
            self.manager.endTitle = [NSString stringWithFormat:@"%ld月%02ld日\n%@",(long)[date2 getMonth],(long)[date2 getDay],[date2 weekString]];
        }
        [self displayLabel];
    }
    else if ([keyPath isEqualToString:@"manager.startTitle"]) {
        if (![self.manager.startTitle isEqualToString:[@"开始" stringByAppendingFormat:@"\n%@",@"日期"]]) {
            r_btn.hidden = NO;
        }
        else {
            r_btn.hidden = YES;
        }
    }
}

@end
