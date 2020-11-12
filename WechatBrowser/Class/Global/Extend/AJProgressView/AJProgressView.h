//
//  AJProgressView.h
//
//  Created by ajsong on 16/10/17.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AJProgressView : UIView
@property (nonatomic,strong) UIColor *progressColor; //进度颜色
@property (nonatomic,strong) UIColor *trackColor; //轨道颜色
@property (nonatomic,assign) CGFloat thickness; //线框厚度
@property (nonatomic,assign) CGFloat progress; //当前进度
@property (nonatomic,strong) UILabel *label; //中间文字
@property (nonatomic,strong) UIView *backgroundView; //背景,遮挡用
@property (nonatomic,assign) BOOL autoFont; //自动设置中间百分比文字的字体大小
@property (nonatomic,assign) BOOL autoText; //自动设置中间百分比文字
@end
