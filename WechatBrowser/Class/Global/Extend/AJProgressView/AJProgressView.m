//
//  AJProgressView.m
//
//  Created by ajsong on 16/10/17.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "Global.h"

@implementation AJProgressView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = YES;
		self.layer.masksToBounds = YES;
		self.layer.cornerRadius = frame.size.height / 2;
		
		_progressColor = [UIColor colorWithWhite:0 alpha:0.7];
		_trackColor = [UIColor colorWithWhite:0 alpha:0.1];
		_thickness = 4*SCREEN_SCALE;
		_autoFont = YES;
		_autoText = YES;
		
		_backgroundView = [[UIView alloc]initWithFrame:self.bounds];
		[self addSubview:_backgroundView];
		
		_label = [[UILabel alloc]initWithFrame:self.bounds];
		_label.textColor = [UIColor blackColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.backgroundColor = [UIColor clearColor];
		[self addSubview:_label];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
	[super setFrame:frame];
	_backgroundView.frame = self.bounds;
	_label.frame = self.bounds;
}

- (void)setProgress:(CGFloat)progress{
	_progress = progress;
   [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    [self drawTrack];
    [self drawProgress];
    [self drawCenter];
    [self setText];
}

- (void)drawTrack{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize size = self.bounds.size;
    CGPoint center = CGPointMake(size.width / 2, size.height / 2);
    CGFloat radius = size.width / 2;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, -M_PI_2, 2*M_PI, 0);
    CGContextSetFillColorWithColor(context, _trackColor.CGColor);
    CGContextFillPath(context);
}

- (void)drawProgress{
    if (_progress == 0 || _progress > 1) return;
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGSize size = self.bounds.size;
	CGPoint center = CGPointMake(size.width / 2, size.height / 2);
	CGFloat radius = size.width / 2;
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, center.x, center.y);
	CGContextAddArc(context, center.x, center.y, radius, -M_PI_2, 2*M_PI*_progress-M_PI_2, 0);
	CGContextSetFillColorWithColor(context, _progressColor.CGColor);
	CGContextFillPath(context);
}

- (void)drawCenter{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize size = self.bounds.size;
    CGPoint center = CGPointMake(size.width / 2, size.height / 2);
    CGFloat radius = size.width / 2 - _thickness;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, center.x, center.y);
	CGContextAddArc(context, center.x, center.y, radius, -M_PI_2, 2*M_PI, 0);
	CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
	CGContextFillPath(context);
}

- (void)setText{
	NSString *percent = @"";
    if (_progress == 1) {
        percent = @"100";
    } else if (_progress < 1 && _progress >= 0){
        percent = [NSString stringWithFormat:@"%0.1f", _progress*100];
	}
	if (_autoFont) {
		CGFloat fontSize = ceilf((self.bounds.size.width-_thickness*2) * 0.4);
		_label.font = FONT(fontSize);
	}
	if (_autoText) _label.text = percent;
}

@end
