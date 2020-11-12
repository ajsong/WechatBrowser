//
//  AJRatingView.m
//
//  Created by ajsong on 15/11/6.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AJRatingView.h"

@implementation AJRatingView{
	UIView *_foreView;
	UITapGestureRecognizer *_tapGesture;
	UIPanGestureRecognizer *_panGesture;
	BOOL _setuped;
}

- (instancetype)init{
	self = [super init];
	if (self) {
		[self setup];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)setup{
	if (_setuped) return;
	_setuped = YES;
	_type = AJRatingViewTypeInteger;
	_min = 1.f;
	_max = 5.f;
	_score = 3.f;
	_count = 5;
	_size = CGSizeMake(20*SCREEN_SCALE, 20*SCREEN_SCALE);
	_change = YES;
	[self performSelector:@selector(config) withObject:nil afterDelay:0];
}

- (void)config{
	if (_type == AJRatingViewTypeInteger) _score = (NSInteger)_score;
	CGRect frame = self.frame;
	frame.size.width = (_size.width + _distance) * (_change ? _count : _score) - _distance;
	frame.size.height = _size.height;
	self.frame = frame;
	
	UIView *grayView = [[UIView alloc]initWithFrame:self.bounds];
	[self addSubview:grayView];
	
	_foreView = [[UIView alloc]initWithFrame:self.bounds];
	_foreView.clipsToBounds = YES;
	[self addSubview:_foreView];
	
	for (int i=0; i<_count; i++) {
		if (_image) {
			UIImageView *grayStar = [[UIImageView alloc]initWithFrame:CGRectMake((_size.width+_distance)*i, 0, _size.width, _size.height)];
			grayStar.image = _image;
			[grayView addSubview:grayStar];
		}
		
		UIImageView *foreStar = [[UIImageView alloc]initWithFrame:CGRectMake((_size.width+_distance)*i, 0, _size.width, _size.height)];
		foreStar.image = _selectedImage;
		[_foreView addSubview:foreStar];
	}
	
	if (_change) {
		_tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureEvent:)];
		_panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureEvent:)];
		[self addGestureRecognizer:_tapGesture];
		[self addGestureRecognizer:_panGesture];
	}
	
	if (_type == AJRatingViewTypeInteger) _score = (NSInteger)_score;
	CGFloat sc = _score / _max * self.frame.size.width;
	CGPoint p = CGPointMake(sc, 0);
	[self changeForeViewWithPoint:p];
}

- (void)setChange:(BOOL)change{
	_change = change;
	[self removeGestureRecognizer:_tapGesture];
	[self removeGestureRecognizer:_panGesture];
	if (change) {
		_tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureEvent:)];
		_panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureEvent:)];
		[self addGestureRecognizer:_tapGesture];
		[self addGestureRecognizer:_panGesture];
	}
}

- (void)setScore:(CGFloat)score{
	_score = score;
	if (_type == AJRatingViewTypeInteger) _score = (NSInteger)_score;
	[self performSelector:@selector(setupForeViewWithPoint) withObject:nil afterDelay:0.1];
}

- (void)setupForeViewWithPoint{
	CGFloat width = (_size.width + _distance) * _count - _distance;
	CGFloat sc = _score / _max * width;
	if (!_change) {
		CGRect frame = self.frame;
		frame.size.width = sc;
		frame.size.height = _size.height;
		self.frame = frame;
	}
	CGPoint p = CGPointMake(sc, 0);
	[self changeForeViewWithPoint:p];
}

- (void)setType:(AJRatingViewType)type{
	_type = type;
	[self setScore:_score];
}

- (void)tapGestureEvent:(UITapGestureRecognizer*)sender{
	CGPoint point = [sender locationInView:self];
	if (point.x < 0) return;
	if (_type == AJRatingViewTypeInteger) {
		NSInteger count = (NSInteger)(point.x / (_size.width+_distance)) + 1;
		point.x = (_size.width+_distance) * count;
	}
	[self changeForeViewWithPoint:point];
}

- (void)panGestureEvent:(UIPanGestureRecognizer*)sender{
	CGPoint point = [sender locationInView:self];
	if (point.x < 0) return;
	if (_type == AJRatingViewTypeInteger) {
		NSInteger count = (NSInteger)(point.x / (_size.width+_distance)) + 1;
		point.x = (_size.width+_distance) * count;
	}
	[self changeForeViewWithPoint:point];
}

#pragma mark - 设置星星
- (void)changeForeViewWithPoint:(CGPoint)point{
	if (point.x < 0 || !_foreView) return;
	
	CGFloat width = self.frame.size.width;
	if (point.x < _min / _max * width) {
		point.x = _min / _max * width;
	} else if (point.x > width) {
		point.x = width;
	}
	CGFloat sc = point.x / width;
	
	CGRect frame = _foreView.frame;
	frame.size.width = point.x;
	_foreView.frame = frame;
	
	_score = sc * _max;
	
	if (_type == AJRatingViewTypeInteger) _score = (NSInteger)_score;
	
	if (_delegate && [_delegate respondsToSelector:@selector(AJRatingView:score:)]) {
		[_delegate AJRatingView:self score:_score];
	}
}

@end
