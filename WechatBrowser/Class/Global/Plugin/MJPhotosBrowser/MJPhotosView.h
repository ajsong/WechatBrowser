//
//  MJZoomingScrollView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJPhotosBrowser, MJPhotos, MJPhotosView;

@protocol MJPhotosViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(MJPhotosView *)photoView;
- (void)photoViewSingleTap:(MJPhotosView *)photoView;
- (void)photoViewDidEndZoom:(MJPhotosView *)photoView;
@end

@interface MJPhotosView : UIScrollView
// 图片
@property (nonatomic, retain) MJPhotos *photo;
// 代理
@property (nonatomic, weak) id<MJPhotosViewDelegate> photoViewDelegate;
// 状态栏状态
@property (nonatomic, assign) BOOL statusBarHidden;
// 是否显示在window
@property (nonatomic, assign) BOOL showInWidow;
// 前一张图片显示原图
- (void)setOriginImage;
@end