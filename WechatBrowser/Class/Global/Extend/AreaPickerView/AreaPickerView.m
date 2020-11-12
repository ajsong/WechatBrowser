//
//  AreaPickerView.m
//
//  Created by ajsong on 15/4/8.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AreaPickerView.h"
#import "AJActionView.h"

@interface AreaPickerView ()<AJActionViewDelegate,AreaPickerDelegate>{
	AreaPicker *_areaPicker;
	BOOL _firstShow;
}
@end

@implementation AreaPickerView

- (instancetype)init{
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_firstShow = YES;
		_autoLocation = YES;
		
		_areaPicker = [[AreaPicker alloc]init];
		_areaPicker.delegate = self;
		_picker = _areaPicker.picker;
		
		_actionView = [[AJActionView alloc]init];
		_actionView.delegate = self;
		_actionView.title = @"选择地区";
		_actionView.view = _areaPicker;
		_actionView.delegate = self;
		[_actionView performSelector:@selector(create) withObject:nil afterDelay:0];
	}
	return self;
}

- (void)setIsAll:(BOOL)isAll{
	_areaPicker.isAll = isAll;
}

- (void)setProvince:(NSString *)province{
	province = [AreaPickerView provinceName:province];
	_province = province;
	_areaPicker.province = province;
	if (!province.length) return;
	_autoLocation = NO;
}
- (void)setCity:(NSString *)city{
	city = [AreaPickerView cityName:city];
	_city = city;
	_areaPicker.city = city;
	if (!city.length) return;
	_autoLocation = NO;
}
-(void)setDistrict:(NSString *)district{
	district = [AreaPickerView districtName:district];
	_district = district;
	_areaPicker.district = district;
	if (!district.length) return;
	_autoLocation = NO;
}

- (void)setProvinceCode:(NSString *)provinceCode{
	_provinceCode = provinceCode;
	_areaPicker.provinceCode = provinceCode;
	if (!provinceCode.length) return;
	_autoLocation = NO;
}
- (void)setCityCode:(NSString *)cityCode{
	_cityCode = cityCode;
	_areaPicker.cityCode = cityCode;
	if (!cityCode.length) return;
	_autoLocation = NO;
}
- (void)setDistrictCode:(NSString *)districtCode{
	_districtCode = districtCode;
	_areaPicker.districtCode = districtCode;
	if (!districtCode.length) return;
	_autoLocation = NO;
}

- (void)show{
	if (_autoLocation && _firstShow && !_district.length) [_areaPicker getLocation];
	_firstShow = NO;
	[_actionView show];
}

- (void)close{
	[_actionView close];
}

#pragma mark - AJActionViewDelegate
- (void)AJActionViewWillShow:(AJActionView *)actionView{
	[_areaPicker selectRow];
	if (_delegate && [_delegate respondsToSelector:@selector(AreaPickerView:didSelectWithProvince:city:district:combo:)]) {
		NSString *combo = [AreaPickerView comboWithProvince:_areaPicker.province city:_areaPicker.city district:_areaPicker.district];
		[_delegate AreaPickerView:self didSelectWithProvince:_areaPicker.province city:_areaPicker.city district:_areaPicker.district combo:combo];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AreaPickerView:didSelectWithProvinceCode:cityCode:districtCode:)]) {
		[_delegate AreaPickerView:self didSelectWithProvinceCode:_areaPicker.provinceCode cityCode:_areaPicker.cityCode districtCode:_areaPicker.districtCode];
	}
}

- (void)AJActionViewDidSubmit:(AJActionView *)actionView{
	if (_delegate && [_delegate respondsToSelector:@selector(AreaPickerView:didSubmitWithProvince:city:district:combo:)]) {
		NSString *combo = [AreaPickerView comboWithProvince:_areaPicker.province city:_areaPicker.city district:_areaPicker.district];
		[_delegate AreaPickerView:self didSubmitWithProvince:_areaPicker.province city:_areaPicker.city district:_areaPicker.district combo:combo];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AreaPickerView:didSubmitWithProvinceCode:cityCode:districtCode:)]) {
		[_delegate AreaPickerView:self didSubmitWithProvinceCode:_areaPicker.provinceCode cityCode:_areaPicker.cityCode districtCode:_areaPicker.districtCode];
	}
}

- (void)AreaPicker:(AreaPicker *)areaPicker didSelectWithProvince:(NSString *)province city:(NSString *)city district:(NSString *)district combo:(NSString *)combo{
	if (_delegate && [_delegate respondsToSelector:@selector(AreaPickerView:didSelectWithProvince:city:district:combo:)]) {
		[_delegate AreaPickerView:self didSelectWithProvince:_areaPicker.province city:_areaPicker.city district:_areaPicker.district combo:combo];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AreaPickerView:didSelectWithProvinceCode:cityCode:districtCode:)]) {
		[_delegate AreaPickerView:self didSelectWithProvinceCode:_areaPicker.provinceCode cityCode:_areaPicker.cityCode districtCode:_areaPicker.districtCode];
	}
}
- (void)AreaPicker:(AreaPicker *)areaPicker didSelectWithProvinceCode:(NSString *)provinceCode cityCode:(NSString *)cityCode districtCode:(NSString *)districtCode{
	if (_delegate && [_delegate respondsToSelector:@selector(AreaPickerView:didSelectWithProvinceCode:cityCode:districtCode:)]) {
		[_delegate AreaPickerView:self didSelectWithProvinceCode:_areaPicker.provinceCode cityCode:_areaPicker.cityCode districtCode:_areaPicker.districtCode];
	}
}

+ (NSString*)replace:(NSString*)string{
	return [AreaPicker replace:string];
}

+ (NSString*)provinceName:(NSString *)provinceCode{
	if (!provinceCode.length) return @"";
	return [AreaPicker getProvince:provinceCode];
}
+ (NSString*)cityName:(NSString *)cityCode{
	if (!cityCode.length) return @"";
	return [AreaPicker getCity:cityCode];
}
+ (NSString*)districtName:(NSString *)districtCode{
	if (!districtCode.length) return @"";
	return [AreaPicker getDistrict:districtCode];
}

+ (NSString*)provinceCode:(NSString *)provinceName{
	if (!provinceName.length) return @"";
	return [AreaPicker getProvinceCode:provinceName];
}
+ (NSString*)cityCode:(NSString *)cityName{
	if (!cityName.length) return @"";
	return [AreaPicker getCityCode:cityName];
}
+ (NSString*)districtCode:(NSString *)districtName{
	if (!districtName.length) return @"";
	return [AreaPicker getDistrictCode:districtName];
}

+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district{
	return [AreaPickerView comboWithProvince:province city:city district:district apart:nil];
}

+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district address:(NSString*)address{
	return [AreaPickerView comboWithProvince:province city:city district:district address:address apart:nil];
}

+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district apart:(NSString *)apart{
	province = [AreaPickerView provinceName:province];
	city = [AreaPickerView cityName:city];
	district = [AreaPickerView districtName:district];
	NSString *combo = province;
	if ([province indexOf:city]==NSNotFound && [city indexOf:province]==NSNotFound) combo = [combo stringByAppendingFormat:@"%@%@", apart.length?apart:@"", city];
	combo = [combo stringByAppendingFormat:@"%@%@", apart.length?apart:@"", district];
	return combo;
}

+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district address:(NSString*)address apart:(NSString *)apart{
	NSString *combo = [AreaPickerView comboWithProvince:province city:city district:district apart:apart];
	return [NSString stringWithFormat:@"%@%@%@", combo, apart.length?apart:@"", address];
}

@end
