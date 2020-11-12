//
//  AreaPicker.h
//
//  Created by ajsong on 15/4/15.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCLocationManager.h"

#define PROVINCE_COMPONENT  0
#define CITY_COMPONENT      1
#define DISTRICT_COMPONENT  2

@class AreaPicker;

@protocol AreaPickerDelegate<NSObject>
@optional
- (void)AreaPicker:(AreaPicker*)areaPicker didSelectWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district combo:(NSString*)combo;
- (void)AreaPicker:(AreaPicker*)areaPicker didSelectWithProvinceCode:(NSString*)provinceCode cityCode:(NSString*)cityCode districtCode:(NSString*)districtCode;
@end

@interface AreaPicker : UIView
@property (nonatomic,weak) id<AreaPickerDelegate> delegate;
@property (nonatomic,strong) UIPickerView *picker;
@property (nonatomic,strong) NSString *province;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *district;
@property (nonatomic,strong) NSString *provinceCode;
@property (nonatomic,strong) NSString *cityCode;
@property (nonatomic,strong) NSString *districtCode;
@property (nonatomic,assign) BOOL isAll;

- (void)getLocation;
- (void)selectRow;
+ (NSString*)replace:(NSString*)string;
+ (NSString*)getProvince:(NSString*)code;
+ (NSString*)getProvinceCode:(NSString*)name;
+ (NSString*)getCity:(NSString*)code;
+ (NSString*)getCityCode:(NSString*)name;
+ (NSString*)getDistrict:(NSString*)code;
+ (NSString*)getDistrictCode:(NSString*)name;
+ (BOOL)isInt:(NSString*)str;
@end
