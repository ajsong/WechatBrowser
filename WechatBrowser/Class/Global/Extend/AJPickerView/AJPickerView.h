//
//  AJPickerView.h
//
//  Created by ajsong on 15/6/8.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AJPickerViewDelegate;

@interface AJPickerView : UIView
@property (nonatomic,weak) id<AJPickerViewDelegate> delegate;
@property (nonatomic,strong) AJActionView *actionView;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSArray *data; //数据,支持字典,但需要含有字符串子元素,否则显示空白
@property (nonatomic,assign) NSInteger component; //滚筒列数,默认1个
@property (nonatomic,strong) NSString *nameKey; //如果数据子元素为字典,即使用该值获取,默认为空
@property (nonatomic,strong) NSString *subKey; //下级标识,默认为空,例如 @[@{@"name":@"名称", @"children":@[]}] children就是subKey
@property (nonatomic,assign) NSInteger index;
- (void)show;
- (void)close;
- (void)setIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setIndex:(NSInteger)index inComponent:(NSInteger)component;
- (void)setIndex:(NSInteger)index inComponent:(NSInteger)component animated:(BOOL)animated;
@end

@protocol AJPickerViewDelegate<NSObject>
@optional
- (NSString *)AJPickerView:(AJPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (void)AJPickerView:(AJPickerView*)pickerView didSelectRows:(NSArray *)indexs;
- (void)AJPickerView:(AJPickerView*)pickerView didSelectItems:(NSArray *)items;
- (void)AJPickerView:(AJPickerView*)pickerView didSubmitRows:(NSArray *)indexs;
- (void)AJPickerView:(AJPickerView*)pickerView didSubmitItems:(NSArray *)items;
- (void)AJPickerViewWillShow:(AJPickerView*)pickerView;
- (void)AJPickerViewDidClose:(AJPickerView*)pickerView;
@end
