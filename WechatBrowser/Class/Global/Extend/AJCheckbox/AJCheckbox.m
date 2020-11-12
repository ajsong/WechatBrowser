//
//  AJCheckbox.m
//
//  Created by ajsong on 15/6/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AJCheckbox.h"

@implementation AJCheckboxSubview
- (void)setDisabled:(BOOL)disabled{
	_disabled = disabled;
	if (disabled) {
		if (_caller.disabledBackgroundColor) self.backgroundColor = _caller.disabledBackgroundColor;
		if (_caller.disabledBorderColor) self.layer.borderColor = _caller.disabledBorderColor.CGColor;
		if (_caller.disabledTextColor) self.label.textColor = _caller.disabledTextColor;
		if (_caller.disabledImage) self.box.image = _caller.disabledImage;
	} else {
		if (_isSelected) {
			if (_caller.selectedBackgroundColor) self.backgroundColor = _caller.selectedBackgroundColor;
			if (_caller.selectedBorderColor) self.layer.borderColor = _caller.selectedBorderColor.CGColor;
			if (_caller.selectedTextColor) self.label.textColor = _caller.selectedTextColor;
			if (_caller.selectedImage) self.box.image = _caller.selectedImage;
		} else {
			if (_caller.backgroundColor) self.backgroundColor = _caller.backgroundColor;
			if (_caller.borderColor) self.layer.borderColor = _caller.borderColor.CGColor;
			if (_caller.textColor) self.label.textColor = _caller.textColor;
			if (_caller.image) self.box.image = _caller.image;
		}
	}
}
@end

@implementation AJCheckbox

- (instancetype)init{
	self = [super init];
	if (self) {
		[self setup];
	}
	return self;
}

- (instancetype)initWithObjects:(NSArray*)objects type:(CheckboxType)type size:(CGSize)size image:(UIImage*)image selectedImage:(UIImage*)selectedImage font:(UIFont*)font{
	self = [super init];
	if (self) {
		[self setup];
		_type = type;
		_size = size;
		_image = image;
		_selectedImage = selectedImage;
		_font = font;
		[self performSelector:@selector(addObjects:) withObject:objects afterDelay:0];
	}
	return self;
}

- (void)setup{
	_views = [[NSMutableArray alloc]init];
	_objects = [[NSMutableArray alloc]init];
	_datas = [[NSMutableArray alloc]init];
	_selectedTexts = [[NSMutableArray alloc]init];
	_selectedIndexs = [[NSMutableArray alloc]init];
	_selectedDatas = [[NSMutableArray alloc]init];
	_selectedViews = [[NSMutableArray alloc]init];
	_unselectedViews = [[NSMutableArray alloc]init];
	_size = CGSizeMakeScale(@30, @30);
	_textColor = COLORTEXT;
	_textAlignment = NSTextAlignmentLeft;
	_padding = UIEdgeInsetsZero;
	_font = FONT(13);
	_animateBox = YES;
}

- (void)paradeViews{
	if (_delegate && [_delegate respondsToSelector:@selector(AJCheckbox:selectedViews:unselectedViews:)]) {
		[_delegate AJCheckbox:self selectedViews:_selectedViews unselectedViews:_unselectedViews];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJCheckbox:isSelectedAll:)]) {
		BOOL isSelectedAll = YES;
		for (int i=0; i<_views.count; i++) {
			AJCheckboxSubview *boxView = _views[i];
			if (!boxView.isSelected) {
				isSelectedAll = NO;
				break;
			}
		}
		[_delegate AJCheckbox:self isSelectedAll:isSelectedAll];
	}
}

- (void)addData:(id)data{
	[_datas addObject:data];
}

- (UIView*)addObject:(id)object{
	return [self addObject:object data:nil selected:NO disabled:NO];
}

- (UIView*)addObject:(id)object data:(id)data{
	return [self addObject:object data:data selected:NO disabled:NO];
}

- (UIView*)addObject:(id)object selected:(BOOL)selected{
	return [self addObject:object data:nil selected:selected disabled:NO];
}

- (UIView*)addObject:(id)object data:(id)data selected:(BOOL)selected{
	return [self addObject:object data:data selected:selected disabled:NO];
}

- (UIView*)addObject:(id)object disabled:(BOOL)disabled{
	return [self addObject:object data:nil selected:NO disabled:disabled];
}

- (UIView*)addObject:(id)object selected:(BOOL)selected disabled:(BOOL)disabled{
	return [self addObject:object data:nil selected:selected disabled:disabled];
}

- (UIView*)addObject:(id)object data:(id)data selected:(BOOL)selected disabled:(BOOL)disabled{
	if (_textHeight<=0) _textHeight = _size.height;
	CGSize s = CGSizeMake(_textWidth, _textHeight);
	if (_textWidth<=0 && [object isKindOfClass:[NSString class]]) {
		NSDictionary *attributes = @{NSFontAttributeName:_font};
		NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		CGRect rect = [object boundingRectWithSize:CGSizeMake(MAXFLOAT, _textHeight) options:options attributes:attributes context:NULL];
		s = CGSizeMake(rect.size.width, _textHeight);
	}

	if (!UIEdgeInsetsEqualToEdgeInsets(_padding, UIEdgeInsetsZero)) {
		s.width += _padding.left + _padding.right;
		_textHeight += _padding.top + _padding.bottom;
	}
	CGFloat width = s.width + (_hiddenBox?0:_size.width);
	if (width<_minWidth) width = _minWidth;
	if (_hiddenBox && s.width<_minWidth) s.width = _minWidth;

	AJCheckboxSubview *boxView = [[AJCheckboxSubview alloc]initWithFrame:CGRectMake(0, 0, width, _textHeight)];
	boxView.clipsToBounds = YES;
	if ([object isKindOfClass:[NSString class]]) boxView.text = object;
	if (_backgroundColor) boxView.backgroundColor = _backgroundColor;
	if (_borderWidth>0) boxView.layer.borderWidth = _borderWidth;
	if (_borderColor) boxView.layer.borderColor = _borderColor.CGColor;
	if (_cornerRadius>0) {
		boxView.layer.masksToBounds = YES;
		boxView.layer.cornerRadius = _cornerRadius;
	}
	[boxView clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		AJCheckboxSubview *boxView = (AJCheckboxSubview*)sender;
		if (!_unselected && boxView.disabled) return;
		[target changeView:boxView];
	}];

	CGFloat boxX = 0;
	CGFloat labelX = _hiddenBox ? 0 : _size.width;
	if (_orderType == CheckboxOrderTypeRight) {
		boxX = boxView.frame.size.width - _size.width;
		labelX = 0;
	}

	UIImageView *box = [[UIImageView alloc]initWithFrame:CGRectMake(boxX, (_textHeight-_size.height)/2, _size.width, _size.height)];
	box.image = _image;
	box.hidden = _hiddenBox;
	box.tag = CheckboxTagBox;
	[boxView addSubview:box];
	boxView.box = box;

	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(labelX, 0, s.width, _textHeight)];
	if ([object isKindOfClass:[NSString class]]) label.text = object;
	label.textColor = _textColor;
	label.textAlignment = _textAlignment;
	label.font = _font;
	label.backgroundColor = [UIColor clearColor];
	label.hidden = _hiddenLabel;
	label.tag = CheckboxTagLabel;
	if (_fontFit) {
		label.lineBreakMode = NSLineBreakByTruncatingMiddle;
		label.minimumScaleFactor = 0.8;
		label.adjustsFontSizeToFitWidth = YES;
	}
	[boxView addSubview:label];
	boxView.label = label;

	boxView.caller = self;
	boxView.data = data;
	boxView.disabled = disabled;

	[_views addObject:boxView];
	[_objects addObject:object];
	if (data) [_datas addObject:data];
	if (selected) {
		NSInteger index = _objects.count-1;
		[_selectedViews addObject:boxView];
		boxView.isSelected = YES;
		if (_selectedBackgroundColor) boxView.backgroundColor = _selectedBackgroundColor;
		if (_selectedBorderColor) boxView.layer.borderColor = _selectedBorderColor.CGColor;
		if (_selectedTextColor) label.textColor = _selectedTextColor;
		box.image = _selectedImage;
		[_selectedTexts addObject:object];
		[_selectedIndexs addObject:@(index)];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				if (_datas.isArray) [_selectedDatas addObject:_datas[index]];
				if (_delegate && [_delegate respondsToSelector:@selector(AJCheckbox:selectedTexts:selectedIndexs:selectedDatas:)]) {
					[_delegate AJCheckbox:self selectedTexts:_selectedTexts selectedIndexs:_selectedIndexs selectedDatas:_selectedDatas];
				}
			});
		});
	} else {
		[_unselectedViews addObject:boxView];
	}

	[self performSelector:@selector(paradeViews) withObject:nil afterDelay:0];

	return boxView;
}

- (void)addObjects:(NSArray*)objects{
	for (id object in objects) {
		[self addObject:object];
	}
}

- (void)removeObject:(id)object{
	NSUInteger i = [_objects indexOfObject:object];
	if (i == NSNotFound) return;
	[_selectedViews removeObject:_views[i]];
	[_unselectedViews removeObject:_views[i]];
	if (_datas.isArray) [_datas removeObjectAtIndex:i];
	AJCheckboxSubview *boxView = _views[i];
	NSUInteger index = [_selectedTexts indexOfObject:boxView.text];
	if (index != NSNotFound) {
		[_selectedTexts removeObjectAtIndex:index];
		[_selectedIndexs removeObjectAtIndex:index];
		if (_datas.isArray) [_selectedDatas removeObjectAtIndex:index];
	}
	[_views removeObjectAtIndex:i];
	[_objects removeObjectAtIndex:i];
	[self performSelector:@selector(paradeViews) withObject:nil afterDelay:0];
}

- (void)removeAllObjects{
	for (UIView *view in _views) {
		[view removeFromSuperview];
	}
	_views = [[NSMutableArray alloc]init];
	_objects = [[NSMutableArray alloc]init];
	_datas = [[NSMutableArray alloc]init];
	_selectedTexts = [[NSMutableArray alloc]init];
	_selectedIndexs = [[NSMutableArray alloc]init];
	_selectedDatas = [[NSMutableArray alloc]init];
	_selectedViews = [[NSMutableArray alloc]init];
	_unselectedViews = [[NSMutableArray alloc]init];
	[self performSelector:@selector(paradeViews) withObject:nil afterDelay:0];
}

- (void)selectObject:(id)object{
	if (!object) return;
	NSUInteger index = [_objects indexOfObject:object];
	if (index == NSNotFound) return;
	AJCheckboxSubview *boxView = _views[index];
	[self changeView:boxView];
}

- (void)selectObjectNoDelegate:(id)object{
	if (!object) return;
	NSUInteger index = [_objects indexOfObject:object];
	if (index == NSNotFound) return;
	AJCheckboxSubview *boxView = _views[index];
	[self changeView:boxView status:CheckboxStatusAuto didSelectedWithDelegate:NO];
}

- (void)selectObjectAtIndex:(NSInteger)index{
	if (index>=_views.count || index<0) return;
	AJCheckboxSubview *boxView = _views[index];
	[self changeView:boxView];
}

- (void)selectObjectAtIndexNoDelegate:(NSInteger)index{
	if (index>=_views.count || index<0) return;
	AJCheckboxSubview *boxView = _views[index];
	[self changeView:boxView status:CheckboxStatusAuto didSelectedWithDelegate:NO];
}

- (BOOL)isSelectedWithText:(NSString *)text{
	if (text.length) {
		return [_selectedTexts containsObject:text];
	}
	return NO;
}

- (BOOL)isSelectedAtIndex:(NSInteger)index{
	if (index>=0 && index<_objects.count) {
		return [_selectedIndexs containsObject:@(index)];
	}
	return NO;
}

- (void)animateImage:(UIView*)box{
	[box scaleAnimateBouncesWithTime:0.15 percent:0.15 completion:nil];
	/*/
	 [box.layer removeAllAnimations];
	 CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	 scaoleAnimation.duration = 0.15;
	 scaoleAnimation.values = @[@1.0, @1.2, @1.0];
	 scaoleAnimation.fillMode = kCAFillModeForwards;
	 [box.layer addAnimation:scaoleAnimation forKey:@"transform.scale"];
	 //*/
}

- (void)selectAllObject{
	if (_type == CheckboxTypeRadio) return;
	[_selectedTexts removeAllObjects];
	[_selectedIndexs removeAllObjects];
	[_selectedDatas removeAllObjects];
	for (int i=0; i<_objects.count; i++) {
		[_selectedTexts addObject:_objects[i]];
		[_selectedIndexs addObject:@(i)];
		if (_datas.isArray) [_selectedDatas addObject:_datas[i]];
	}
	for (AJCheckboxSubview *boxView in _views) {
		if (boxView.disabled) {
			if (_disabledBackgroundColor) boxView.backgroundColor = _disabledBackgroundColor;
			if (_disabledBorderColor) boxView.layer.borderColor = _disabledBorderColor.CGColor;
			if (_disabledTextColor) boxView.label.textColor = _disabledTextColor;
			if (_disabledImage) boxView.box.image = _disabledImage;
		} else {
			boxView.isSelected = YES;
			if (_selectedBackgroundColor) boxView.backgroundColor = _selectedBackgroundColor;
			if (_selectedBorderColor) boxView.layer.borderColor = _selectedBorderColor.CGColor;
			UIImageView *box = boxView.box;
			box.image = _selectedImage;
			UILabel *label = boxView.label;
			if (_selectedTextColor) label.textColor = _selectedTextColor;
			if (_animateBox) [self animateImage:box];
			if (_animateView) [self animateImage:boxView];
		}
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJCheckbox:selectedTexts:selectedIndexs:selectedDatas:)]) {
		[_delegate AJCheckbox:self selectedTexts:_selectedTexts selectedIndexs:_selectedIndexs selectedDatas:_selectedDatas];
	}

	_selectedViews = _views;
	_unselectedViews = [[NSMutableArray alloc]init];
	[self performSelector:@selector(paradeViews) withObject:nil afterDelay:0];
}

- (void)unselectAllObject{
	[_selectedTexts removeAllObjects];
	[_selectedIndexs removeAllObjects];
	[_selectedDatas removeAllObjects];
	for (AJCheckboxSubview *boxView in _views) {
		if (boxView.disabled) {
			if (_disabledBackgroundColor) boxView.backgroundColor = _disabledBackgroundColor;
			if (_disabledBorderColor) boxView.layer.borderColor = _disabledBorderColor.CGColor;
			if (_disabledTextColor) boxView.label.textColor = _disabledTextColor;
			if (_disabledImage) boxView.box.image = _disabledImage;
		} else {
			boxView.isSelected = NO;
			if (_backgroundColor) boxView.backgroundColor = _backgroundColor;
			if (_borderColor) boxView.layer.borderColor = _borderColor.CGColor;
			UIImageView *box = boxView.box;
			box.image = _image;
			UILabel *label = boxView.label;
			label.textColor = _textColor;
			if (_animateBox) [self animateImage:box];
			if (_animateView) [self animateImage:boxView];
		}
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJCheckbox:selectedTexts:selectedIndexs:selectedDatas:)]) {
		[_delegate AJCheckbox:self selectedTexts:_selectedTexts selectedIndexs:_selectedIndexs selectedDatas:_selectedDatas];
	}

	_selectedViews = [[NSMutableArray alloc]init];
	_unselectedViews = _views;
	[self performSelector:@selector(paradeViews) withObject:nil afterDelay:0];
}

- (void)disabledAllObject{
	for (AJCheckboxSubview *boxView in _views) {
		boxView.disabled = YES;
	}
}

- (void)undisabledAllObject{
	for (AJCheckboxSubview *boxView in _views) {
		boxView.disabled = NO;
	}
}

- (void)changeView:(AJCheckboxSubview*)view{
	[self changeView:view status:CheckboxStatusAuto didSelectedWithDelegate:YES];
}

- (void)changeView:(AJCheckboxSubview*)view status:(CheckboxStatus)status didSelectedWithDelegate:(BOOL)flag{
	[APPCurrentView endEditing:YES];
	if (!_unselected && view.disabled) return;
	NSUInteger index = NSNotFound;
	if (_type == CheckboxTypeRadio) {
		[_selectedTexts removeAllObjects];
		[_selectedIndexs removeAllObjects];
		[_selectedDatas removeAllObjects];
		BOOL boxViewStatus = NO;
		for (int i=0; i<_views.count; i++) {
			AJCheckboxSubview *boxView = _views[i];
			if ([boxView isEqual:view]) {
				index = i;
				boxViewStatus = boxView.isSelected;
			}
			if (boxView.disabled) {
				if (_disabledBackgroundColor) boxView.backgroundColor = _disabledBackgroundColor;
				if (_disabledBorderColor) boxView.layer.borderColor = _disabledBorderColor.CGColor;
				if (_disabledTextColor) boxView.label.textColor = _disabledTextColor;
				if (_disabledImage) boxView.box.image = _disabledImage;
			} else {
				boxView.isSelected = NO;
				if (_backgroundColor) boxView.backgroundColor = _backgroundColor;
				if (_borderColor) boxView.layer.borderColor = _borderColor.CGColor;
				boxView.box.image = _image;
				boxView.label.textColor = _textColor;
			}
		}
		if (_unselected && boxViewStatus) {
			if (_backgroundColor) view.backgroundColor = _backgroundColor;
			if (_borderColor) view.layer.borderColor = _borderColor.CGColor;
			view.box.image = _image;
			if (_animateBox) [self animateImage:view.box];
			if (_animateView) [self animateImage:view];
			if (_textColor) view.label.textColor = _textColor;
			status = CheckboxStatusUnselect;
		} else {
			view.isSelected = YES;
			if (_selectedBackgroundColor) view.backgroundColor = _selectedBackgroundColor;
			if (_selectedBorderColor) view.layer.borderColor = _selectedBorderColor.CGColor;
			view.box.image = _selectedImage;
			if (_animateBox) [self animateImage:view.box];
			if (_animateView) [self animateImage:view];
			if (_selectedTextColor) view.label.textColor = _selectedTextColor;
			[_selectedTexts addObject:view.text];
			if ([_objects indexOfObject:view.text]!=NSNotFound) {
				[_selectedIndexs addObject:@([_objects indexOfObject:view.text])];
			}
			if (_datas.isArray && [_objects indexOfObject:view.text]!=NSNotFound) {
				[_selectedDatas addObject:_datas[[_objects indexOfObject:view.text]]];
			}
			status = CheckboxStatusSelect;
		}
	} else if (_type == CheckboxTypeCheckbox) {
		for (int i=0; i<_views.count; i++) {
			AJCheckboxSubview *boxView = _views[i];
			if ([boxView isEqual:view]) index = i;
		}
		if (status == CheckboxStatusAuto) {
			if (!view.isSelected) {
				view.isSelected = YES;
				if (_selectedBackgroundColor) view.backgroundColor = _selectedBackgroundColor;
				if (_selectedBorderColor) view.layer.borderColor = _selectedBorderColor.CGColor;
				view.box.image = _selectedImage;
				if (_selectedTextColor) view.label.textColor = _selectedTextColor;
				status = CheckboxStatusSelect;
			} else {
				view.isSelected = NO;
				if (_backgroundColor) view.backgroundColor = _backgroundColor;
				if (_borderColor) view.layer.borderColor = _borderColor.CGColor;
				view.box.image = _image;
				view.label.textColor = _textColor;
				status = CheckboxStatusUnselect;
			}
		} else if (status == CheckboxStatusSelect) {
			view.isSelected = YES;
			if (_selectedBackgroundColor) view.backgroundColor = _selectedBackgroundColor;
			if (_selectedBorderColor) view.layer.borderColor = _selectedBorderColor.CGColor;
			view.box.image = _selectedImage;
			if (_selectedTextColor) view.label.textColor = _selectedTextColor;
		} else if (status == CheckboxStatusUnselect) {
			view.isSelected = NO;
			if (_backgroundColor) view.backgroundColor = _backgroundColor;
			if (_borderColor) view.layer.borderColor = _borderColor.CGColor;
			view.box.image = _image;
			view.label.textColor = _textColor;
		}
		if (_animateBox) [self animateImage:view.box];
		if (_animateView) [self animateImage:view];
		if (status == CheckboxStatusSelect) {
			[_selectedTexts addObject:view.text];
			if ([_objects indexOfObject:view.text]!=NSNotFound) {
				[_selectedIndexs addObject:@([_objects indexOfObject:view.text])];
			}
			if (_datas.isArray && [_objects indexOfObject:view.text]!=NSNotFound) {
				[_selectedDatas addObject:_datas[[_objects indexOfObject:view.text]]];
			}
		} else {
			NSUInteger i = [_selectedTexts indexOfObject:view.text];
			if (i != NSNotFound) {
				[_selectedTexts removeObjectAtIndex:i];
				[_selectedIndexs removeObjectAtIndex:i];
				if (_datas.isArray) [_selectedDatas removeObjectAtIndex:i];
			}
		}
	}

	if (index!=NSNotFound && flag && _delegate && [_delegate respondsToSelector:@selector(AJCheckbox:didSelectedView:status:atIndex:)]) {
		[_delegate AJCheckbox:self didSelectedView:view status:status atIndex:index];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJCheckbox:selectedTexts:selectedIndexs:selectedDatas:)]) {
		[_delegate AJCheckbox:self selectedTexts:_selectedTexts selectedIndexs:_selectedIndexs selectedDatas:_selectedDatas];
	}

	_selectedViews = [[NSMutableArray alloc]init];
	_unselectedViews = [[NSMutableArray alloc]init];
	for (int i=0; i<_views.count; i++) {
		NSInteger index = [_selectedIndexs indexOfObject:@(i)];
		if (index != NSNotFound) {
			[_selectedViews addObject:_views[i]];
		} else {
			[_unselectedViews addObject:_views[i]];
		}
	}
	[self performSelector:@selector(paradeViews) withObject:nil afterDelay:0];
}

@end
