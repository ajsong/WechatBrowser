//
//  AJSwitchView.m
//
//  Created by ajsong on 2018/12/28.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import "AJSwitchView.h"

@interface AJSwitchViewButton ()
@end
@implementation AJSwitchViewButton
- (void)setSelected:(BOOL)selected{
	[super setSelected:selected];
	if (selected) {
		self.backgroundColor = _selectedBgColor;
	} else {
		self.backgroundColor = _bgColor;
	}
}
@end

@interface AJSwitchView ()<UIScrollViewDelegate>{
	BOOL _selecting;
	UIImageView *_overlayLeft;
	UIImageView *_overlayRight;
}
@end
@implementation AJSwitchView
- (instancetype)init{
	return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		_createSelected = YES;
		_textColor = COLORTEXT;
		_bgColor = COLORCLEAR;
		_selectedTextColor = COLORTEXT;
		_selectedBgColor = COLORCLEAR;
		_padding = 10*SCREEN_SCALE;
		_columnHeight = 3*SCREEN_SCALE;
		_columnColor = COLORRED;
		_columnMargin = CGPointZero;
		_columnPadding = _padding;
		_lastIndex = NSNotFound;
		_lineHidden = YES;
		_lineMargin = UIEdgeInsetsZero;
		_lineColor = COLOR_GE_LIGHT;
		_lineWidth = 0.5*SCREEN_SCALE;
		_geLineColor = COLOR_GE_LIGHT;
		_buttons = [[NSMutableArray alloc]init];
	}
	return self;
}
- (void)setDisable:(BOOL)disable{
	_disable = disable;
}
- (void)setLineHidden:(BOOL)lineHidden{
	_lineHidden = lineHidden;
	if (!lineHidden) return;
	if (!_buttons.count) return;
	for (int i=0; i<_buttons.count; i++) {
		[_buttons[i] removeGeLine:GeLineRightTag];
	}
}
- (void)setColumnHidden:(BOOL)columnHidden{
	_columnHidden = columnHidden;
	if (!_column) return;
	_column.hidden = columnHidden;
}
- (void)setIndex:(NSInteger)index{
	if (!_nameArray.isArray || index<0 || index>=_nameArray.count || index==NSNotFound) index = 0;
	_index = index;
	if (!_buttons.count) return;
	[self selectValue:_buttons[index]];
}
- (void)setNameArray:(NSArray *)nameArray{
	_nameArray = nameArray;
	_index = 0;
	if (!self.superview) return;
	[self performSelector:@selector(setupItems) withObject:nil afterDelay:0];
}
- (void)willMoveToSuperview:(UIView *)newSuperview{
	[self setupItems];
}
- (void)setupItems{
	[_scrollView removeAllSubviews];
	[_scrollView removeFromSuperview];
	_scrollView = nil;
	[self removeAllSubviews];
	if (!_nameArray.isArray || !_valueArray.isArray || _nameArray.count!=_valueArray.count) return;
	
	_scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.contentSize = self.bounds.size;
	_scrollView.delegate = self;
	[self addSubview:_scrollView];
	
	_isScroll = NO;
	UIFont *font = _font ? _font : FONT(14.f);
	CGFloat w = floorf(self.frame.size.width / _nameArray.count);
	CGFloat totalWidth = 0;
	for (int i=0; i<_nameArray.count; i++) {
		CGSize s = [_nameArray[i] autoWidth:font height:self.height];
		totalWidth += s.width + _padding*2;
	}
	if (totalWidth>self.frame.size.width) {
		_isScroll = YES;
		
		UIImage *overlayImage = [UIImage imageNamed:@"scroll-overlay"];
		if (_overlayColor) overlayImage = [overlayImage overlayWithColor:_overlayColor];
		
		_overlayLeft = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40*SCREEN_SCALE, self.height)];
		_overlayLeft.image = [overlayImage changeToSize:_overlayLeft.frame.size];
		[_overlayLeft scaleFlipHorizontal];
		_overlayLeft.alpha = 0;
		_overlayLeft.hidden = YES;
		[self addSubview:_overlayLeft];
		
		_overlayRight = [[UIImageView alloc]initWithFrame:CGRectMake(self.width-_overlayLeft.width+1*SCREEN_SCALE, 0, _overlayLeft.width, _overlayLeft.height)];
		_overlayRight.image = [overlayImage changeToSize:_overlayRight.frame.size];
		[self addSubview:_overlayRight];
	}
	_buttons = [[NSMutableArray alloc]init];
	CGFloat left = 0;
	for (int i=0; i<_nameArray.count; i++) {
		if (_isScroll || _autoFontWidth) {
			CGSize s = [_nameArray[i] autoWidth:font height:self.height];
			if (s.width < _minWidth) s.width = _minWidth;
			w = s.width + _padding*2;
		}
		AJSwitchViewButton *button = [[AJSwitchViewButton alloc]initWithFrame:CGRectMake(left, 0, w, self.height)];
		button.bgColor = _bgColor;
		button.selectedBgColor = _selectedBgColor;
		button.titleLabel.font = font;
		button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
		button.adjustsImageWhenHighlighted = NO;
		[button setTitle:_nameArray[i] forState:UIControlStateNormal];
		[button setTitleColor:_textColor forState:UIControlStateNormal];
		[button setTitleColor:_selectedTextColor forState:UIControlStateSelected];
		button.tag = i + 54263;
		if (_createSelected && i==_index) button.selected = YES;
		[button addTarget:self action:^(id target, id sender) {
			[target selectValue:(AJSwitchViewButton*)sender];
		}];
		[_scrollView addSubview:button];
		if (_delegate && [_delegate respondsToSelector:@selector(AJSwitchView:button:atIndex:)]) {
			[_delegate AJSwitchView:self button:button atIndex:i];
		}
		if (!_lineHidden && i<_nameArray.count-1) [button addGeWithType:GeLineTypeRight color:_lineColor wide:_lineWidth margin:_lineMargin];
		[_buttons addObject:button];
		left = button.right;
	}
	_scrollView.contentSize = CGSizeMake(left, _scrollView.height);
	
	CGFloat columnWidth = _columnWidth ? _columnWidth : self.width/_nameArray.count;
	CGFloat columnHeight = _columnHeight;
	CGFloat columnLeft = -SCREEN_WIDTH*2;
	if (_createSelected) columnLeft = (self.width/_nameArray.count)*_index + (self.width/_nameArray.count-columnWidth)/2;
	if (_isScroll || _autoFontWidth) {
		CGFloat w = [(UIView*)_buttons[_index] width];
		if (w < _minWidth) w = _minWidth;
		columnWidth = w - _columnPadding*2;
		if (_createSelected) columnLeft = [_buttons[_index] left] + (w-columnWidth)/2;
	}
	_column = [[UIView alloc]initWithFrame:CGRectMake(columnLeft+_columnMargin.x, self.height-columnHeight+_columnMargin.y, columnWidth, columnHeight)];
	_column.backgroundColor = _columnColor;
	_column.hidden = _columnHidden;
	[_scrollView addSubview:_column];
	[_scrollView performSelector:@selector(bringSubviewToFront:) withObject:_column afterDelay:0.1];
	
	if (_geLineColor) [self addGeWithType:GeLineTypeBottom color:_geLineColor];
	
	if (_createSelected) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self setSelectAtIndex:_index];
			});
		});
	}
}
- (void)selectValue:(AJSwitchViewButton*)button{
	if (_disable) return;
	NSInteger index = button.tag - 54263;
	[self setSelectAtIndex:index];
}
- (void)setSelectAtIndex:(NSInteger)index{
	if (index<0 || index>=_buttons.count || index==NSNotFound || _selecting) return;
	BOOL allowSelected = YES;
	if (_delegate && [_delegate respondsToSelector:@selector(AJSwitchView:shouldSelectAtIndex:value:)]) {
		allowSelected = [_delegate AJSwitchView:self shouldSelectAtIndex:index value:_valueArray[index]];
	}
	if (!allowSelected) return;
	for (UIButton *button in _buttons) {
		button.selected = NO;
	}
	UIButton *button = _buttons[index];
	button.selected = YES;
	
	CGFloat columnWidth = _columnWidth ? _columnWidth : self.width/_nameArray.count;
	CGFloat columnLeft = (self.width/_nameArray.count)*index + (self.width/_nameArray.count-columnWidth)/2;
	if (_isScroll || _autoFontWidth) {
		CGFloat w = button.width;
		if (w < _minWidth) w = _minWidth;
		columnWidth = w - _columnPadding*2;
		columnLeft = button.left + (w-columnWidth)/2;
	}
	[UIView animateWithDuration:0.3 animations:^{
		_column.alpha = 1;
		_column.frame = CGRectMake(columnLeft, _column.top, columnWidth, _column.height);
	}];
	
	CGFloat scrollWidth = _scrollView.width;
	CGFloat buttonLeft = button.left;
	CGFloat buttonRight = button.right;
	if (buttonRight-scrollWidth>_scrollView.contentOffset.x) {
		[_scrollView setContentOffset:CGPointMake(buttonRight-scrollWidth, 0) animated:YES];
	} else if (buttonLeft<_scrollView.contentOffset.x) {
		[_scrollView setContentOffset:CGPointMake(buttonLeft, 0) animated:YES];
	}
	
	_lastIndex = _index;
	_index = index;
	
	if (_delegate) {
		if ([_delegate respondsToSelector:@selector(AJSwitchView:didSelectAtIndex:value:)]) {
			[_delegate AJSwitchView:self didSelectAtIndex:index value:_valueArray[index]];
		} else if ([_delegate respondsToSelector:@selector(AJSwitchView:didSelectAtIndex:value:completeHandler:)]) {
			_selecting = YES;
			[_delegate AJSwitchView:self didSelectAtIndex:index value:_valueArray[index] completeHandler:^(BOOL result) {
				_selecting = !result;
			}];
		}
	}
}
- (void)setUnselectAtIndex:(NSInteger)index{
	if (index>=_buttons.count) return;
	UIButton *button = _buttons[index];
	button.selected = NO;
	if (_lastIndex==index || (_lastIndex==NSNotFound && index==0)) {
		[UIView animateWithDuration:0.3 animations:^{
			_column.alpha = 0;
		} completion:^(BOOL finished) {
			_column.left = -_column.width;
		}];
	}
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (scrollView.contentOffset.x <= 0) {
		[_overlayLeft fadeOut:0.3 completion:nil];
	} else {
		[_overlayLeft fadeIn:0.3 completion:nil];
	}
	CGFloat x = [FORMAT(@"%.f", scrollView.contentOffset.x) floatValue];
	CGFloat w = [FORMAT(@"%.f", scrollView.contentSize.width-scrollView.frame.size.width) floatValue];
	if (x >= w) {
		[_overlayRight fadeOut:0.3 completion:nil];
	} else {
		[_overlayRight fadeIn:0.3 completion:nil];
	}
}
@end
