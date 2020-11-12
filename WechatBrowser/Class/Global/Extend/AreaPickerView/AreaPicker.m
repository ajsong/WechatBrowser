//
//  AreaPicker.m
//
//  Created by ajsong on 15/4/15.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AreaPicker.h"

#define kAddressFileName @"address"
#define kAreaPickerSubMark @"area"

@interface AreaPicker ()<UIPickerViewDataSource,UIPickerViewDelegate>{
	BOOL _inited;
	NSMutableArray *_address;
	NSMutableArray *_excess;
	NSMutableArray *_provinceArray;
	NSMutableArray *_cityArray;
	NSMutableArray *_districtArray;
	NSInteger _provinceIndex;
	NSInteger _cityIndex;
	NSInteger _districtIndex;
	BOOL _selectedArea;
}
@end

@implementation AreaPicker

- (instancetype)init{
	self = [super init];
	if (self) {
		[self setupInit];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		[self setupInit];
	}
	return self;
}

- (void)setupInit{
	if (_inited) return;
	_inited = YES;
	self.backgroundColor = [UIColor clearColor];
	
	_address = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAddressFileName ofType:@"plist"]];
	_excess = [[NSMutableArray alloc]init];
	[_excess addObject:_address[34]];
	[_excess addObject:_address[35]];
	[_address removeObjectAtIndex:35];
	[_address removeObjectAtIndex:34];
	
	_provinceArray = [[NSMutableArray alloc]init];
	_cityArray = [[NSMutableArray alloc]init];
	_districtArray = [[NSMutableArray alloc]init];
	
	for (int i=0; i<_address.count; i++) {
		[_provinceArray addObject:_address[i][@"name"]];
	}
	_province = _address[0][@"name"];
	_provinceCode = _address[0][@"code"];
	
	NSArray *cityArr = _address[0][kAreaPickerSubMark];
	_city = cityArr[0][@"name"];
	_cityCode = cityArr[0][@"code"];
	
	NSArray *districtArr = cityArr[0][kAreaPickerSubMark];
	_district = districtArr[0][@"name"];
	_districtCode = districtArr[0][@"code"];
	
	_picker = [[UIPickerView alloc]init];
	_picker.separatorColor = COLOR_GE;
	_picker.backgroundColor = [UIColor clearColor];
	_picker.delegate = self;
	_picker.dataSource = self;
	[self addSubview:_picker];
	
	self.frame = CGRectMake(0, 0, _picker.frame.size.width, _picker.frame.size.height);
	[self performSelector:@selector(previewSelect) withObject:nil afterDelay:0.1];
}

- (void)setIsAll:(BOOL)isAll{
	_isAll = isAll;
	if (isAll) {
		if (_address.count==36) return;
		for (int i=0; i<_excess.count; i++) {
			[_address addObject:_excess[i]];
		}
		[_provinceArray removeAllObjects];
		for (int i=0; i<_address.count; i++) {
			[_provinceArray addObject:_address[i][@"name"]];
		}
		[_picker reloadComponent:PROVINCE_COMPONENT];
	} else {
		if (_address.count!=36) return;
		[_address removeObjectAtIndex:35];
		[_address removeObjectAtIndex:34];
	}
}

- (void)setProvince:(NSString *)province{
	_province = province;
	if (!province.length) return;
	for (int i=0; i<_address.count; i++) {
		if ([[AreaPicker replace:_address[i][@"name"]] isEqualToString:[AreaPicker replace:_province]]) {
			_provinceIndex = i;
			_provinceCode = _address[i][@"code"];
			
			NSArray *cityArr = _address[i][kAreaPickerSubMark];
			_city = cityArr[0][@"name"];
			_cityCode = cityArr[0][@"code"];
			
			NSArray *districtArr = cityArr[0][kAreaPickerSubMark];
			_district = districtArr[0][@"name"];
			_districtCode = districtArr[0][@"code"];
			
			[_picker selectRow:_provinceIndex inComponent:PROVINCE_COMPONENT animated:YES];
			[_picker selectRow:_cityIndex inComponent:CITY_COMPONENT animated:YES];
			[_picker selectRow:_districtIndex inComponent:DISTRICT_COMPONENT animated:YES];
			break;
		}
	}
	_selectedArea = YES;
}
- (void)setCity:(NSString *)city{
	_city = city;
	if (!city.length) return;
	BOOL findArea = NO;
	for (int i=0; i<_address.count; i++) {
		NSArray *cityArr = _address[i][kAreaPickerSubMark];
		for (int j=0; j<cityArr.count; j++) {
			if ([[AreaPicker replace:cityArr[j][@"name"]] isEqualToString:[AreaPicker replace:_city]]) {
				if (_province.length && [[AreaPicker replace:_address[i][@"name"]] isEqualToString:[AreaPicker replace:_province]]) {
					_cityIndex = j;
					_cityCode = cityArr[j][@"code"];
					
					_provinceIndex = i;
					_province = _address[i][@"name"];
					_provinceCode = _address[i][@"code"];
					
					NSArray *districtArr = cityArr[j][kAreaPickerSubMark];
					_district = districtArr[0][@"name"];
					_districtCode = districtArr[0][@"code"];
					
					[_picker selectRow:_provinceIndex inComponent:PROVINCE_COMPONENT animated:YES];
					[_picker selectRow:_cityIndex inComponent:CITY_COMPONENT animated:YES];
					[_picker selectRow:_districtIndex inComponent:DISTRICT_COMPONENT animated:YES];
					findArea = YES;
					break;
				}
				if (!_province.length) {
					_cityIndex = j;
					_cityCode = cityArr[j][@"code"];
					
					_provinceIndex = i;
					_province = _address[i][@"name"];
					_provinceCode = _address[i][@"code"];
					
					NSArray *districtArr = cityArr[j][kAreaPickerSubMark];
					_district = districtArr[0][@"name"];
					_districtCode = districtArr[0][@"code"];
					
					[_picker selectRow:_provinceIndex inComponent:PROVINCE_COMPONENT animated:YES];
					[_picker selectRow:_cityIndex inComponent:CITY_COMPONENT animated:YES];
					[_picker selectRow:_districtIndex inComponent:DISTRICT_COMPONENT animated:YES];
					findArea = YES;
					break;
				}
			}
		}
		if (findArea) break;
	}
	_selectedArea = YES;
}
- (void)setDistrict:(NSString *)district{
	_district = district;
	if (!district.length) return;
	BOOL findArea = NO;
	for (int i=0; i<_address.count; i++) {
		NSArray *cityArr = _address[i][kAreaPickerSubMark];
		for (int j=0; j<cityArr.count; j++) {
			NSArray *districtArr = cityArr[j][kAreaPickerSubMark];
			for (int k=0; k<districtArr.count; k++) {
				if ([[AreaPicker replace:districtArr[k][@"name"]] isEqualToString:[AreaPicker replace:_district]]) {
					if (_city.length && [[AreaPicker replace:cityArr[j][@"name"]] isEqualToString:[AreaPicker replace:_city]]) {
						_districtIndex = k;
						_districtCode = districtArr[k][@"code"];
						
						_cityIndex = j;
						_city = cityArr[j][@"name"];
						_cityCode = cityArr[j][@"code"];
						
						_provinceIndex = i;
						_province = _address[i][@"name"];
						_provinceCode = _address[i][@"code"];
						
						[_picker selectRow:_provinceIndex inComponent:PROVINCE_COMPONENT animated:YES];
						[_picker selectRow:_cityIndex inComponent:CITY_COMPONENT animated:YES];
						[_picker selectRow:_districtIndex inComponent:DISTRICT_COMPONENT animated:YES];
						findArea = YES;
						break;
					}
					if (!_city.length) {
						_districtIndex = k;
						_districtCode = districtArr[k][@"code"];
						
						_cityIndex = j;
						_city = cityArr[j][@"name"];
						_cityCode = cityArr[j][@"code"];
						
						_provinceIndex = i;
						_province = _address[i][@"name"];
						_provinceCode = _address[i][@"code"];
						
						[_picker selectRow:_provinceIndex inComponent:PROVINCE_COMPONENT animated:YES];
						[_picker selectRow:_cityIndex inComponent:CITY_COMPONENT animated:YES];
						[_picker selectRow:_districtIndex inComponent:DISTRICT_COMPONENT animated:YES];
						findArea = YES;
						break;
					}
				}
			}
			if (findArea) break;
		}
		if (findArea) break;
	}
	_selectedArea = YES;
}

- (void)setProvinceCode:(NSString *)provinceCode{
	_provinceCode = provinceCode;
	if (!provinceCode.length) return;
	for (int i=0; i<_address.count; i++) {
		if ([_address[i][@"code"] isEqualToString:_provinceCode]) {
			_provinceIndex = i;
			_province = _address[i][@"name"];
			
			NSArray *cityArea = _address[i][kAreaPickerSubMark];
			_city = cityArea[0][@"name"];
			_cityCode = cityArea[0][@"code"];
			
			NSArray *districtArea = cityArea[0][kAreaPickerSubMark];
			_district = districtArea[0][@"name"];
			_districtCode = districtArea[0][@"code"];
			
			[_picker selectRow:_provinceIndex inComponent:PROVINCE_COMPONENT animated:YES];
			[_picker selectRow:_cityIndex inComponent:CITY_COMPONENT animated:YES];
			[_picker selectRow:_districtIndex inComponent:DISTRICT_COMPONENT animated:YES];
			break;
		}
	}
	_selectedArea = YES;
}
- (void)setCityCode:(NSString *)cityCode{
	_cityCode = cityCode;
	if (!cityCode.length) return;
	BOOL findArea = NO;
	for (int i=0; i<_address.count; i++) {
		NSArray *cityArr = _address[i][kAreaPickerSubMark];
		for (int j=0; j<cityArr.count; j++) {
			if ([cityArr[j][@"code"] isEqualToString:_cityCode]) {
				_cityIndex = j;
				_city = cityArr[j][@"name"];
				
				_provinceIndex = i;
				_province = _address[i][@"name"];
				_provinceCode = _address[i][@"code"];
				
				NSArray *districtArr = cityArr[j][kAreaPickerSubMark];
				_district = districtArr[0][@"name"];
				_districtCode = districtArr[0][@"code"];
				
				[_picker selectRow:_provinceIndex inComponent:PROVINCE_COMPONENT animated:YES];
				[_picker selectRow:_cityIndex inComponent:CITY_COMPONENT animated:YES];
				[_picker selectRow:_districtIndex inComponent:DISTRICT_COMPONENT animated:YES];
				findArea = YES;
				break;
			}
		}
		if (findArea) break;
	}
	_selectedArea = YES;
}
- (void)setDistrictCode:(NSString *)districtCode{
	_districtCode = districtCode;
	if (!districtCode.length) return;
	BOOL findArea = NO;
	for (int i=0; i<_address.count; i++) {
		NSArray *cityArr = _address[i][kAreaPickerSubMark];
		for (int j=0; j<cityArr.count; j++) {
			NSArray *districtArr = cityArr[j][kAreaPickerSubMark];
			for (int k=0; k<districtArr.count; k++) {
				if ([districtArr[k][@"code"] isEqualToString:_districtCode]) {
					_districtIndex = k;
					_district = districtArr[k][@"name"];
					
					_cityIndex = j;
					_city = cityArr[j][@"name"];
					_cityCode = cityArr[j][@"code"];
					
					_provinceIndex = i;
					_province = _address[i][@"name"];
					_provinceCode = _address[i][@"code"];
					
					[_picker selectRow:_provinceIndex inComponent:PROVINCE_COMPONENT animated:YES];
					[_picker selectRow:_cityIndex inComponent:CITY_COMPONENT animated:YES];
					[_picker selectRow:_districtIndex inComponent:DISTRICT_COMPONENT animated:YES];
					findArea = YES;
					break;
				}
			}
			if (findArea) break;
		}
		if (findArea) break;
	}
	_selectedArea = YES;
}

- (void)previewSelect{
	if (!_selectedArea) {
		NSInteger provinceIndex = 0;
		NSInteger cityIndex = 0;
		NSInteger districtIndex = 0;
		
		BOOL findArea = NO;
		for (int i=0; i<_address.count; i++) {
			NSArray *cityArr = _address[i][kAreaPickerSubMark];
			for (int j=0; j<cityArr.count; j++) {
				NSArray *districtArr = cityArr[j][kAreaPickerSubMark];
				for (int k=0; k<districtArr.count; k++) {
					if ([districtArr[k][@"name"] isEqualToString:_district]) {
						districtIndex = k;
						cityIndex = j;
						provinceIndex = i;
						findArea = YES;
						break;
					}
				}
				if (findArea) break;
			}
			if (findArea) break;
		}
		
		_provinceIndex = provinceIndex;
		_cityIndex = cityIndex;
		_districtIndex = districtIndex;
	}
	
	[self selectProvinceRow:_provinceIndex];
	[self selectCityRow:_cityIndex];
	
	[_picker selectRow:_provinceIndex inComponent:PROVINCE_COMPONENT animated:NO];
	[_picker selectRow:_cityIndex inComponent:CITY_COMPONENT animated:NO];
	[_picker selectRow:_districtIndex inComponent:DISTRICT_COMPONENT animated:NO];
}

- (void)getLocation{
	[[CCLocationManager shareLocation] getCoordinateAndAddress:^(CLLocationCoordinate2D locationCorrrdinate, NSString *province, NSString *city, NSString *district, NSString *address, NSString *addressDetail, NSDictionary *dictionary) {
		province = [self replace:province];
		city = [self replace:city];
		district = [self replace:district];
		
		NSInteger provinceIndex = 0;
		NSInteger cityIndex = 0;
		NSInteger districtIndex = 0;
		
		BOOL findArea = NO;
		if (district.length) {
			for (int i=0; i<_address.count; i++) {
				NSArray *cityArr = _address[i][kAreaPickerSubMark];
				for (int j=0; j<cityArr.count; j++) {
					NSArray *districtArr = cityArr[j][kAreaPickerSubMark];
					for (int k=0; k<districtArr.count; k++) {
						if ([districtArr[k][@"name"] isEqualToString:district]) {
							if (city.length) {
								if ([cityArr[j][@"name"] isEqualToString:city]) {
									districtIndex = k;
									cityIndex = j;
									provinceIndex = i;
									findArea = YES;
									break;
								}
							} else {
								districtIndex = k;
								cityIndex = j;
								provinceIndex = i;
								findArea = YES;
								break;
							}
						}
					}
					if (findArea) break;
				}
				if (findArea) break;
			}
			_provinceIndex = provinceIndex;
			[self setCityArray:provinceIndex];
			[self setDistrictArray:cityIndex];
		} else if (city.length) {
			for (int i=0; i<_address.count; i++) {
				NSArray *cityArr = _address[i][kAreaPickerSubMark];
				for (int j=0; j<cityArr.count; j++) {
					if ([cityArr[j][@"name"] isEqualToString:city]) {
						if (province.length) {
							if ([_address[i][@"name"] isEqualToString:province]) {
								cityIndex = j;
								provinceIndex = i;
								findArea = YES;
								break;
							}
						} else {
							cityIndex = j;
							provinceIndex = i;
							findArea = YES;
							break;
						}
					}
				}
				if (findArea) break;
			}
			[self setCityArray:provinceIndex];
		} else if (province.length) {
			for (int i=0; i<_address.count; i++) {
				if ([_address[i][@"name"] isEqualToString:province]) {
					provinceIndex = i;
					break;
				}
			}
		}
		
		_provinceIndex = provinceIndex;
		_cityIndex = cityIndex;
		_districtIndex = districtIndex;
		
		[self selectProvinceRow:provinceIndex];
		[_picker selectRow:provinceIndex inComponent:PROVINCE_COMPONENT animated:YES];
		
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self selectCityRow:cityIndex];
				[_picker selectRow:cityIndex inComponent:CITY_COMPONENT animated:YES];
				
				dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						[_picker selectRow:districtIndex inComponent:DISTRICT_COMPONENT animated:YES];
						[self selectRow];
						
						if (_delegate && [_delegate respondsToSelector:@selector(AreaPicker:didSelectWithProvince:city:district:combo:)]) {
							NSString *combo = [AreaPickerView comboWithProvince:_province city:_city district:_district];
							[_delegate AreaPicker:self didSelectWithProvince:_province city:_city district:_district combo:combo];
						}
						if (_delegate && [_delegate respondsToSelector:@selector(AreaPicker:didSelectWithProvinceCode:cityCode:districtCode:)]) {
							[_delegate AreaPicker:self didSelectWithProvinceCode:_provinceCode cityCode:_cityCode districtCode:_districtCode];
						}
					});
				});
			});
		});
	}];
}

- (NSString*)replace:(NSString*)string{
	string = [AreaPicker clearSuffix:string];
	return string;
}

- (void)setCityArray:(NSInteger)provinceIndex{
	_cityArray = [[NSMutableArray alloc]init];
	_districtArray = [[NSMutableArray alloc]init];
	if (provinceIndex >= _address.count) return;
	NSArray *cityArr = _address[provinceIndex][kAreaPickerSubMark];
	for (int j=0; j<cityArr.count; j++) {
		[_cityArray addObject:cityArr[j][@"name"]];
	}
	NSArray *districtArr = cityArr[0][kAreaPickerSubMark];
	for (int k=0; k<districtArr.count; k++) {
		[_districtArray addObject:districtArr[k][@"name"]];
	}
}

- (void)setDistrictArray:(NSInteger)cityIndex{
	_districtArray = [[NSMutableArray alloc]init];
	if (_provinceIndex >= _address.count) return;
	NSArray *cityArr = _address[_provinceIndex][kAreaPickerSubMark];
	if (cityIndex >= cityArr.count) return;
	NSArray *districtArr = cityArr[cityIndex][kAreaPickerSubMark];
	for (int k=0; k<districtArr.count; k++) {
		[_districtArray addObject:districtArr[k][@"name"]];
	}
}

- (void)selectProvinceRow:(NSInteger)row{
	_provinceIndex = row;
	[self setCityArray:row];
	
	[_picker reloadComponent:CITY_COMPONENT];
	[_picker selectRow:0 inComponent:CITY_COMPONENT animated:YES];
	[_picker reloadComponent:DISTRICT_COMPONENT];
	[_picker selectRow:0 inComponent:DISTRICT_COMPONENT animated:YES];
	
	[self selectRow];
}

- (void)selectCityRow:(NSInteger)row{
	_cityIndex = row;
	[self setDistrictArray:row];
	
	[_picker reloadComponent:DISTRICT_COMPONENT];
	[_picker selectRow:0 inComponent:DISTRICT_COMPONENT animated:YES];
	
	[self selectRow];
}

- (void)selectRow{
	NSInteger provinceIndex = [_picker selectedRowInComponent:PROVINCE_COMPONENT];
	NSInteger cityIndex = [_picker selectedRowInComponent:CITY_COMPONENT];
	NSInteger districtIndex = [_picker selectedRowInComponent:DISTRICT_COMPONENT];
	
	_province = _address[provinceIndex][@"name"];
	_provinceCode = _address[provinceIndex][@"code"];
	
	NSArray *cityArr = _address[provinceIndex][kAreaPickerSubMark];
	_city = cityArr[cityIndex][@"name"];
	_cityCode = cityArr[cityIndex][@"code"];
	
	NSArray *districtArr = cityArr[cityIndex][kAreaPickerSubMark];
	_district = districtArr[districtIndex][@"name"];
	_districtCode = districtArr[districtIndex][@"code"];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if (component == PROVINCE_COMPONENT) return _provinceArray.count;
	if (component == CITY_COMPONENT) return _cityArray.count;
	if (component == DISTRICT_COMPONENT) return _districtArray.count;
	return 0;
}

#pragma mark - UIPickerViewDelegate
- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	pickerView.separatorColor = COLOR_GE;
	
	UILabel *label = [UILabel new];
	if (component == PROVINCE_COMPONENT) label.text = _provinceArray[row];
	if (component == CITY_COMPONENT) label.text = _cityArray[row];
	if (component == DISTRICT_COMPONENT) label.text = _districtArray[row];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(20);
	label.backgroundColor = [UIColor clearColor];
	label.lineBreakMode = NSLineBreakByTruncatingMiddle;
	label.minimumScaleFactor = 0.8;
	label.adjustsFontSizeToFitWidth = YES;
	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if (component == PROVINCE_COMPONENT) {
		[self selectProvinceRow:row];
	} else if (component == CITY_COMPONENT) {
		[self selectCityRow:row];
	} else {
		[self selectRow];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AreaPicker:didSelectWithProvince:city:district:combo:)]) {
		NSString *combo = [AreaPickerView comboWithProvince:_province city:_city district:_district];
		[_delegate AreaPicker:self didSelectWithProvince:_province city:_city district:_district combo:combo];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AreaPicker:didSelectWithProvinceCode:cityCode:districtCode:)]) {
		[_delegate AreaPicker:self didSelectWithProvinceCode:_provinceCode cityCode:_cityCode districtCode:_districtCode];
	}
}

+ (NSString*)replace:(NSString*)string{
	if (string.length) {
		string = [AreaPicker clearSuffix:string];
		string = [string stringByReplacingOccurrencesOfString:@"省" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"市" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"区" withString:@""];
	}
	return string;
}

+ (NSString*)clearSuffix:(NSString*)string{
	if (string.length) {
		string = [string stringByReplacingOccurrencesOfString:@"特别行政区" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"维吾尔" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"回族" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"壮族" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"自治区" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"藏族" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"羌族" withString:@""];
		string = [string stringByReplacingOccurrencesOfString:@"自治州" withString:@""];
	}
	return string;
}

+ (NSString*)getProvince:(NSString*)code{
	if (![AreaPicker isInt:code]) return code;
	NSString *name = @"";
	NSArray *address = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAddressFileName ofType:@"plist"]];
	for (int i=0; i<address.count; i++) {
		if ([[AreaPicker replace:address[i][@"code"]] isEqualToString:[AreaPicker replace:code]]) {
			name = address[i][@"name"];
			break;
		}
	}
	return name;
}
+ (NSString*)getProvinceCode:(NSString*)name{
	if ([AreaPicker isInt:name]) return name;
	NSString *code = @"";
	NSArray *address = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAddressFileName ofType:@"plist"]];
	for (int i=0; i<address.count; i++) {
		if ([[AreaPicker replace:address[i][@"name"]] isEqualToString:[AreaPicker replace:name]]) {
			code = address[i][@"code"];
			break;
		}
	}
	return code;
}

+ (NSString*)getCity:(NSString*)code{
	if (![AreaPicker isInt:code]) return code;
	NSString *name = @"";
	NSArray *address = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAddressFileName ofType:@"plist"]];
	BOOL findArea = NO;
	for (int i=0; i<address.count; i++) {
		NSArray *cityArr = address[i][kAreaPickerSubMark];
		for (int j=0; j<cityArr.count; j++) {
			if ([[AreaPicker replace:cityArr[j][@"code"]] isEqualToString:[AreaPicker replace:code]]) {
				name = cityArr[j][@"name"];
				findArea = YES;
				break;
			}
		}
		if (findArea) break;
	}
	return name;
}
+ (NSString*)getCityCode:(NSString*)name{
	if ([AreaPicker isInt:name]) return name;
	NSString *code = @"";
	NSArray *address = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAddressFileName ofType:@"plist"]];
	BOOL findArea = NO;
	for (int i=0; i<address.count; i++) {
		NSArray *cityArr = address[i][kAreaPickerSubMark];
		for (int j=0; j<cityArr.count; j++) {
			if ([[AreaPicker replace:cityArr[j][@"name"]] isEqualToString:[AreaPicker replace:name]]) {
				code = cityArr[j][@"code"];
				findArea = YES;
				break;
			}
		}
		if (findArea) break;
	}
	return code;
}

+ (NSString*)getDistrict:(NSString*)code{
	if (![AreaPicker isInt:code]) return code;
	NSString *name = @"";
	NSArray *address = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAddressFileName ofType:@"plist"]];
	BOOL findArea = NO;
	for (int i=0; i<address.count; i++) {
		NSArray *cityArr = address[i][kAreaPickerSubMark];
		for (int j=0; j<cityArr.count; j++) {
			NSArray *districtArr = cityArr[j][kAreaPickerSubMark];
			for (int k=0; k<districtArr.count; k++) {
				if ([[AreaPicker replace:districtArr[k][@"code"]] isEqualToString:[AreaPicker replace:code]]) {
					name = districtArr[k][@"name"];
					findArea = YES;
					break;
				}
			}
			if (findArea) break;
		}
		if (findArea) break;
	}
	return name;
}
+ (NSString*)getDistrictCode:(NSString*)name{
	if ([AreaPicker isInt:name]) return name;
	NSString *code = @"";
	NSArray *address = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAddressFileName ofType:@"plist"]];
	BOOL findArea = NO;
	for (int i=0; i<address.count; i++) {
		NSArray *cityArr = address[i][kAreaPickerSubMark];
		for (int j=0; j<cityArr.count; j++) {
			NSArray *districtArr = cityArr[j][kAreaPickerSubMark];
			for (int k=0; k<districtArr.count; k++) {
				if ([[AreaPicker replace:districtArr[k][@"name"]] isEqualToString:[AreaPicker replace:name]]) {
					code = districtArr[k][@"code"];
					findArea = YES;
					break;
				}
			}
			if (findArea) break;
		}
		if (findArea) break;
	}
	return code;
}

+ (BOOL)isInt:(NSString*)str{
	if (!str.length) return NO;
	NSScanner *scan = [NSScanner scannerWithString:str];
	int val;
	return [scan scanInt:&val] && [scan isAtEnd];
}

@end
