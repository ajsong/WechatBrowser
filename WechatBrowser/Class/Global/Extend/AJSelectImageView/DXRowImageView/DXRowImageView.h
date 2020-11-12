//
//  DXRowImageView.h
//  DXImagePickController
//
//  Created by simon on 16/7/1.
//  Copyright © 2016年 DINGXU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXImagePickModel.h"
#import "DXLoadImageTool.h"

@class DXRowImageView;
@protocol DXRowImageViewDelegate <NSObject>
@optional
//选择或取消选择照片的代理方法
- (void)rowImageView:(DXRowImageView *)collectionView didSeletectedArray:(NSArray *)array;
- (void)rowImageViewDidSeletectedFull:(DXRowImageView *)collectionView;
@end

@interface DXRowImageView : UICollectionView
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,assign) NSInteger count;
@property (nonatomic,weak) id<DXRowImageViewDelegate> rowImageViewDelegate;
+ (instancetype)rowImageViewWithFrame:(CGRect)frame;
- (void)removeAllImages;
@end
