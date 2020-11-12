//
//  DXRowImageView.m
//  DXImagePickController
//
//  Created by simon on 16/7/1.
//  Copyright © 2016年 DINGXU. All rights reserved.
//

#import "DXRowImageView.h"
#import "DXImageCollectionCell.h"

@interface DXRowImageView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,DXImageCollectionCellDelegate>
@property (nonatomic,strong) NSMutableArray *seletedArray;
@end
@implementation DXRowImageView

+ (instancetype)rowImageViewWithFrame:(CGRect)frame{
	UICollectionViewFlowLayout *fowlayout = [[UICollectionViewFlowLayout alloc]init];
	fowlayout.itemSize = CGSizeMake(150*SCREEN_SCALE, 150*SCREEN_SCALE);
	fowlayout.minimumInteritemSpacing = 4;
	fowlayout.minimumLineSpacing = 4;
	fowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return [[self alloc]initWithFrame:frame collectionViewLayout:fowlayout];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingNone;
    [self registerClass:[DXImageCollectionCell class] forCellWithReuseIdentifier:@"collectionCell"];
    self.delegate = self;
    self.dataSource = self;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	//self.contentInset = UIEdgeInsetsMake(0, 0, 0, 400);
    return self;
}

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [self reloadData];
    [self scrollViewDidScroll:self];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DXImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    DXImagePickModel *model = self.dataArray[indexPath.item];
    model.offset = self.contentOffset;
    cell.model = model;
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    DXImagePickModel *model = self.dataArray[indexPath.item];
    return model.image.size;
}

#pragma mark - UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	NSArray *cells = [self visibleCells];
    for (DXImageCollectionCell *cell in cells) {
        DXImagePickModel *model = self.dataArray[[[self indexPathForCell:cell] item]];
        model.offset = scrollView.contentOffset;
        cell.model = model;
    };
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	
}

- (void)removeAllImages{
    [self.seletedArray removeAllObjects];
    [self.dataArray setValue:@(0) forKeyPath:@"count"];
    [self reloadData];
}

#pragma mark - DXImageCollectionCellDelegate
- (void)imageCollectionCell:(DXImageCollectionCell *)collectionCell selectedButtonDidSelected:(UIButton *)selectedButton{
    DXImagePickModel *selectedModel = collectionCell.model;
    for (DXImagePickModel *model in self.dataArray) {
        if ([model isEqual:selectedModel]) {
            if ([self.seletedArray containsObject:model]) {
                model.count = 0;
                [self.seletedArray removeObject:model];
                NSMutableArray *temp = [NSMutableArray arrayWithCapacity:10];
                for (DXImagePickModel *seltedModel in self.seletedArray) {
                    [temp addObject:seltedModel];
                }
                [self.seletedArray removeAllObjects];
                [self.seletedArray addObjectsFromArray:temp];
            } else {
				if (self.count>0 && self.seletedArray.count>=self.count) {
					if ([self.rowImageViewDelegate respondsToSelector:@selector(rowImageViewDidSeletectedFull:)]) {
						[self.rowImageViewDelegate rowImageViewDidSeletectedFull:self];
					}
					return;
				} else {
					if (model.originImage) {
						[self.seletedArray addObject:model];
					} else {
						[DXLoadImageTool getImageOfAsset:model.asset complection:^(UIImage *result) {
							model.originImage = result;
							[self.seletedArray addObject:model];
							[self reloadCollectionView];
						}];
					}
				}
            }
			break;
		}
    }
	[self reloadCollectionView];
}

- (void)reloadCollectionView{
	for (DXImagePickModel *model in self.dataArray) {
		NSInteger index = [self.seletedArray indexOfObject:model];
		if (index!=NSNotFound && index+1) {
			model.count = index + 1;
		} else {
			model.count = 0;
		}
	}
	if ([self.rowImageViewDelegate respondsToSelector:@selector(rowImageView:didSeletectedArray:)]) {
		[self.rowImageViewDelegate rowImageView:self didSeletectedArray:[self.seletedArray copy]];
	}
	[self reloadData];
}

- (NSMutableArray *)seletedArray{
    if (!_seletedArray) {
        _seletedArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _seletedArray;
}

@end
