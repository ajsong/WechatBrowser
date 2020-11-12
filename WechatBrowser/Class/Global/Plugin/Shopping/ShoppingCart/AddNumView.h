//
//  AddNumView.h
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddNumViewDelegate <NSObject>
- (void)AddNumView:(NSInteger)quantity btnType:(NSInteger)btnType;
- (void)changeBegin:(UITextField*)textField;
- (void)changeValue:(UITextField*)textField;
- (void)blur:(UITextField*)textField;
@end

@interface AddNumView : UIView
@property (nonatomic,weak) id<AddNumViewDelegate>delegate;
@property (nonatomic,assign) NSInteger numInteger;
@property (nonatomic,assign) NSInteger minInteger;
@property (nonatomic,assign) NSInteger maxInteger;
@property (nonatomic,assign) NSInteger stocks;
@end
