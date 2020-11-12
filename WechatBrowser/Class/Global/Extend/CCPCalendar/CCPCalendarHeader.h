//
//  CCPCalendarHeader.h
//
//  Created by Ceair on 17/5/25.
//  Copyright © 2017年 ccp. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCPCalendarManager;

@interface CCPCalendarHeader : UIView

@property (nonatomic, strong) CCPCalendarManager *manager;

- (void)displayLabel;
- (void)initSubviews;
@end
