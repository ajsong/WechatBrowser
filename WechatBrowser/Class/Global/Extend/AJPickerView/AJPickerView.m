//
//  AJPickerView.m
//
//  Created by ajsong on 15/6/8.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AJPickerView.h"
#import "AJActionView.h"

#define SCREEN [UIScreen mainScreen].bounds

@interface AJPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate,AJActionViewDelegate>{
	NSMutableArray *_pickerData;
	UIPickerView *_pickerView;
}
@end

@implementation AJPickerView

- (instancetype)init{
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_pickerData = [[NSMutableArray alloc]init];
		_actionView = [[AJActionView alloc]init];
		[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
	}
	return self;
}

- (void)loadViews{
	_pickerView = [[UIPickerView alloc]init];
	_pickerView.separatorColor = COLOR_GE;
	_pickerView.backgroundColor = [UIColor clearColor];
	_pickerView.delegate = self;
	_pickerView.dataSource = self;
	
	_actionView.view = _pickerView;
	_actionView.delegate = self;
	[_actionView performSelector:@selector(create) withObject:nil afterDelay:0];
}

- (void)setTitle:(NSString *)title{
	_title = title;
	_actionView.title = title;
}

- (void)setData:(NSArray *)data{
	if (!data || !data.count) return;
	_data = data;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			[_pickerData removeAllObjects];
			if ([_data isKindOfClass:[NSArray class]]) {
				_pickerData = [NSMutableArray arrayWithArray:_data];
			} else {
				_pickerData = [NSMutableArray arrayWithObjects:_data, nil];
			}
			if (!_component) _component = [self getLevel:data];
			[_pickerView reloadAllComponents];
		});
	});
}

- (NSInteger)getLevel:(NSArray *)datas{
	NSInteger level = 1;
	if (_subKey.length) {
		NSDictionary *type = [NSDictionary dictionary];
		for (NSDictionary *data in datas) {
			if ([data[_subKey]isArray]) {
				type = data;
				break;
			}
		}
		if (type.isDictionary) {
			level += [self getLevel:type[_subKey]];
		}
	}
	return level;
}

- (void)setIndex:(NSInteger)index{
	[self setIndex:index inComponent:0];
}
- (void)setIndex:(NSInteger)index animated:(BOOL)animated{
	[self setIndex:index inComponent:0 animated:animated];
}
- (void)setIndex:(NSInteger)index inComponent:(NSInteger)component{
	[self setIndex:index inComponent:component animated:YES];
}
- (void)setIndex:(NSInteger)index inComponent:(NSInteger)component animated:(BOOL)animated{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (component==NSNotFound || ![_pickerView numberOfComponents]) return;
			if (index==NSNotFound || ![_pickerView numberOfRowsInComponent:component]) return;
			_index = index;
			[_pickerView selectRow:index inComponent:component animated:animated];
		});
	});
}

- (void)show{
	[_actionView show];
}

- (void)close{
	[_actionView close];
}

#pragma mark - AJActionViewDelegate
- (void)AJActionViewWillShow:(AJActionView *)actionView{
	if (!_pickerData.count) return;
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerViewWillShow:)]) {
		[_delegate AJPickerViewWillShow:self];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectRows:)]) {
		NSMutableArray *indexs = [[NSMutableArray alloc]init];
		for (int i=0; i<_component; i++) {
			[indexs addObject:@([_pickerView selectedRowInComponent:i])];
		}
		[_delegate AJPickerView:self didSelectRows:indexs];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectItems:)]) {
		NSMutableArray *items = [[NSMutableArray alloc]init];
		for (int i=0; i<_component; i++) {
			if (_subKey.length && i) {
				[items addObject:[self getParent:i][_subKey][[_pickerView selectedRowInComponent:i]]];
			} else {
				[items addObject:_pickerData[[_pickerView selectedRowInComponent:i]]];
			}
		}
		[_delegate AJPickerView:self didSelectItems:items];
	}
}

- (void)AJActionViewDidClose:(AJActionView *)actionView{
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerViewDidClose:)]) {
		[_delegate AJPickerViewDidClose:self];
	}
}

- (void)AJActionViewDidSubmit:(AJActionView *)actionView{
	if (!_pickerData.count) return;
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSubmitRows:)]) {
		NSMutableArray *indexs = [[NSMutableArray alloc]init];
		for (int i=0; i<_component; i++) {
			[indexs addObject:@([_pickerView selectedRowInComponent:i])];
		}
		[_delegate AJPickerView:self didSubmitRows:indexs];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSubmitItems:)]) {
		NSMutableArray *items = [[NSMutableArray alloc]init];
		for (int i=0; i<_component; i++) {
			if (_subKey.length && i) {
				[items addObject:[self getParent:i][_subKey][[_pickerView selectedRowInComponent:i]]];
			} else {
				[items addObject:_pickerData[[_pickerView selectedRowInComponent:i]]];
			}
		}
		[_delegate AJPickerView:self didSubmitItems:items];
	}
}

- (void)selectPickerView:(UIPickerView *)pickerView row:(NSInteger)row component:(NSInteger)component{
	if (component==_component-1) return;
	if (!_subKey.length) return;
	for (NSInteger i=component+1; i<_component; i++) {
		[pickerView reloadComponent:i];
		[pickerView selectRow:0 inComponent:i animated:YES];
	}
}

- (NSDictionary *)getParent:(NSInteger)component{
	NSDictionary *data = [NSDictionary dictionary];
	NSInteger componentIndex = 0;
	while (componentIndex < component) {
		if (_subKey.length && componentIndex) {
			data = data[_subKey][[_pickerView selectedRowInComponent:componentIndex]];
		} else {
			data = _pickerData[[_pickerView selectedRowInComponent:componentIndex]];
		}
		componentIndex++;
	}
	return data;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return _component;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if (!_pickerData.isArray) return 0;
	if (component) {
		if (_subKey.length) {
			if (![[self getParent:component][_subKey]isArray]) return 0;
			return [[self getParent:component][_subKey] count];
		} else {
			return [_pickerData[component] count];
		}
	} else {
		return _pickerData.count;
	}
}

#pragma mark - UIPickerViewDelegate
- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	pickerView.separatorColor = COLOR_GE;
	
	if (!_pickerData.isArray) return nil;
	id title;
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:titleForRow:forComponent:)]) {
		title = [_delegate AJPickerView:self titleForRow:row forComponent:component];
	} else {
		if (_subKey.length && component) {
			title = [self getParent:component][_subKey][row];
		} else {
			title = _pickerData[row];
		}
	}
	if ([title isKindOfClass:[NSDictionary class]]) {
		if (_nameKey) {
			title = [title objectForKey:_nameKey];
		} else {
			if ([title objectForKey:@"title"]) {
				title = [title objectForKey:@"title"];
			} else if ([title objectForKey:@"name"]) {
				title = [title objectForKey:@"name"];
			} else {
				for (id obj in title) {
					if ([title[obj] isKindOfClass:[NSString class]]) {
						title = [title[obj] copy];
						break;
					}
				}
			}
		}
	}
	if (![title isKindOfClass:[NSString class]] || ![title length]) title = @"";
	if ([title length]) title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	CGFloat g = 0;
	if (SCREEN_WIDTH==320) g = 8*SCREEN_SCALE*2 + 10*SCREEN_SCALE*2;
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, pickerView.width-g, 32)];
	label.text = title;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(20);
	label.backgroundColor = [UIColor clearColor];
	label.lineBreakMode = NSLineBreakByTruncatingMiddle;
	label.minimumScaleFactor = 0.5;
	label.adjustsFontSizeToFitWidth = YES;
	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if (!_pickerData.isArray) return;
	[self selectPickerView:pickerView row:row component:component];
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectRows:)]) {
		NSMutableArray *indexs = [[NSMutableArray alloc]init];
		for (NSInteger i=0; i<_component; i++) {
			[indexs addObject:@([_pickerView selectedRowInComponent:i])];
		}
		[_delegate AJPickerView:self didSelectRows:indexs];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJPickerView:didSelectItems:)]) {
		NSMutableArray *items = [[NSMutableArray alloc]init];
		for (NSInteger i=0; i<_component; i++) {
			if (_subKey.length && i) {
				[items addObject:[self getParent:i][_subKey][[_pickerView selectedRowInComponent:i]]];
			} else {
				[items addObject:_pickerData[[_pickerView selectedRowInComponent:i]]];
			}
		}
		[_delegate AJPickerView:self didSelectItems:items];
	}
}

@end
