//
//  UITableView+Extend.h
//
//  Created by ajsong on 2018/11/28.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - UITableView+UICollectionView+Extend
@interface UITableView (GlobalExtend)
@property (nonatomic,strong) UIView *emptyView;
- (UITableViewCell*)cellForKey:(NSString*)key;
- (void)setCell:(UITableViewCell*)cacheCell forKey:(NSString*)key;
@end

@interface UICollectionView (GlobalExtend)
- (UICollectionViewCell*)cellForKey:(NSString*)key;
- (void)setCell:(UICollectionViewCell*)cacheCell forKey:(NSString*)key;
@end
/*
 NSString *key = FORMAT(@"%@%ld%ld", self.class, (long)indexPath.section, (long)indexPath.row);
 UITableViewCell *cacheCell = [tableView cacheCellForKey:key];
 if (cacheCell) return cacheCell;
 [tableView setCacheCell:cell forKey:key];
 */

@class UICollectionViewIndex;
@protocol UICollectionViewIndexDelegate <NSObject>
@optional
- (void)collectionViewIndex:(UICollectionViewIndex *)collectionViewIndex didSelectAtIndex:(NSInteger)index withTitle:(NSString *)title;
- (void)collectionViewIndex:(UICollectionViewIndex *)collectionViewIndex didSelectAtIndex:(NSInteger)index withButton:(UIButton *)button;
- (void)collectionViewIndexTouchesBegan:(UICollectionViewIndex *)collectionViewIndex;
- (void)collectionViewIndexTouchesEnd:(UICollectionViewIndex *)collectionViewIndex;
@end
@interface UICollectionViewIndex : UIView
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *titleIndexes; //索引内容数组
@property (nonatomic,assign) CGFloat textWidth; //字框宽度,默认self.width
@property (nonatomic,assign) CGFloat textHeight; //字框高度,默认16
@property (nonatomic,strong) UIColor *textColor; //字体颜色,默认COLORTEXT
@property (nonatomic,strong) UIColor *selectedTextColor; //选中时字体颜色
@property (nonatomic,strong) UIColor *bgColor; //字框背景颜色,默认透明
@property (nonatomic,strong) UIColor *selectedBgColor; //选中时字框背景颜色,默认透明
@property (nonatomic,assign) CGFloat fontSize; //字体大小,默认12
@property (nonatomic,weak) id<UICollectionViewIndexDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame withCollectionView:(UICollectionView*)collectionView;
@end
