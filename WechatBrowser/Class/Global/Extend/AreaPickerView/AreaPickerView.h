//
//  AreaPickerView.h
//
//  Created by ajsong on 15/4/8.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AreaPicker.h"

@protocol AreaPickerViewDelegate;

@interface AreaPickerView : UIView
@property (nonatomic,weak) id<AreaPickerViewDelegate> delegate;
@property (nonatomic,strong) AJActionView *actionView;
@property (nonatomic,strong) UIPickerView *picker;
@property (nonatomic,strong) NSString *province;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *district;
@property (nonatomic,strong) NSString *provinceCode;
@property (nonatomic,strong) NSString *cityCode;
@property (nonatomic,strong) NSString *districtCode;
@property (nonatomic,assign) BOOL autoLocation; //自动获取当前位置,默认YES
@property (nonatomic,assign) BOOL isAll; //显示所有地区,包括外国,默认NO

- (void)show;
- (void)close;
+ (NSString*)replace:(NSString*)string;
+ (NSString*)provinceName:(NSString*)provinceCode;
+ (NSString*)cityName:(NSString*)cityCode;
+ (NSString*)districtName:(NSString*)districtCode;
+ (NSString*)provinceCode:(NSString*)provinceName;
+ (NSString*)cityCode:(NSString*)cityName;
+ (NSString*)districtCode:(NSString*)districtName;
+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district;
+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district address:(NSString*)address;
+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district apart:(NSString*)apart;
+ (NSString*)comboWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district address:(NSString*)address apart:(NSString*)apart;
@end

@protocol AreaPickerViewDelegate<NSObject>
@optional
- (void)AreaPickerView:(AreaPickerView*)pickerView didSubmitWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district combo:(NSString*)combo;
- (void)AreaPickerView:(AreaPickerView*)pickerView didSelectWithProvince:(NSString*)province city:(NSString*)city district:(NSString*)district combo:(NSString*)combo;
- (void)AreaPickerView:(AreaPickerView*)pickerView didSubmitWithProvinceCode:(NSString*)provinceCode cityCode:(NSString*)cityCode districtCode:(NSString*)districtCode;
- (void)AreaPickerView:(AreaPickerView*)pickerView didSelectWithProvinceCode:(NSString*)provinceCode cityCode:(NSString*)cityCode districtCode:(NSString*)districtCode;
@end
