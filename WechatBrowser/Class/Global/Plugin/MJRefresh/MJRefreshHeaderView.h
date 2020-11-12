//
//  MJRefreshHeaderView.h
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJRefreshBaseView.h"

@interface MJRefreshHeaderView : MJRefreshBaseView
@property (nonatomic, weak) UILabel *lastUpdateTimeLabel;
+ (instancetype)header;
+ (MJRefreshHeaderView*)createWithFrame:(CGRect)frame subviews:(void (^)(MJRefreshHeaderView *headerView))subviews changeState:(void (^)(MJRefreshStates state, MJRefreshHeaderView *headerView))changeState;
@end