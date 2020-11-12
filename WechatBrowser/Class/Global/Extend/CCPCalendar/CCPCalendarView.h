//
//  CCPCalendarView.h
//
//  Created by Ceair on 17/5/25.
//  Copyright © 2017年 ccp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCPCalendarManager;

@interface CCPCalendarView : UIView
@property (nonatomic,strong) CCPCalendarManager *manager;
//底部按钮
@property (nonatomic,strong) UIButton *saveBtn;
- (void)initSubviews;
@end
