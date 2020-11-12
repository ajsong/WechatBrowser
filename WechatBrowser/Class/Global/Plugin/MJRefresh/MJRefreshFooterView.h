//
//  MJRefreshTableFooterView.h
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJRefreshBaseView.h"

@interface MJRefreshFooterView : MJRefreshBaseView
+ (instancetype)footer;
+ (MJRefreshFooterView*)createWithFrame:(CGRect)frame subviews:(void (^)(MJRefreshBaseView *))subviews changeState:(void (^)(MJRefreshStates state, MJRefreshBaseView *footerView))changeState;
@end