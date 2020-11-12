//
//  MJPhotoToolbar.h
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJPhotosToolbar : UIView
// 所有的图片对象
@property (nonatomic, retain) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSInteger currentPhotoIndex;
// 默认显示图片信息
@property (nonatomic, assign) BOOL showInfo;
//显示保存图片按钮
@property (nonatomic, assign) BOOL showSaveBtn;
// 工具条扩展按钮
@property (nonatomic, retain) UIView *btnView;

//显示页码后隐藏
- (void)showIndexLabel:(BOOL)autoHidden;
// 更新标题与描述
- (void)reloadData;
@end
