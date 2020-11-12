//
//  MJPhotoBrowser.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

/*
NSMutableArray *photos = [[NSMutableArray alloc]init];
for (int i=0; i<list.count; i++) {
	MJPhotos *photo = [[MJPhotos alloc] init];
	photo.url = list[i][@"pic"];
	photo.srcImageView = pic;
	[photos addObject:photo];
}
if (photos.count) {
	NSInteger tag = pic.tag - 100;
	MJPhotosBrowser *browser = [[MJPhotosBrowser alloc]init];
	browser.currentPhotoIndex = tag;
	browser.photos = photos;
	browser.delegate = self;
	[browser show];
}
*/

#import <UIKit/UIKit.h>
#import "MJPhotos.h"

@protocol MJPhotosBrowserDelegate;
@interface MJPhotosBrowser : UIViewController <UIScrollViewDelegate>
// 代理
@property (nonatomic, weak) id<MJPhotosBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, retain) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
// 默认显示图片信息
@property (nonatomic, assign) BOOL showInfo;
//显示保存图片按钮
@property (nonatomic, assign) BOOL showSaveBtn;
// 工具条扩展按钮
@property (nonatomic, retain) UIView *btnView;

// 显示
- (void)show;
// 更新标题与描述
- (void)reloadData;
@end

@protocol MJPhotosBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(MJPhotosBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index direction:(NSInteger)direction;
- (void)photoViewSingleTap;
- (void)photoViewDidEndZoom;
@end
