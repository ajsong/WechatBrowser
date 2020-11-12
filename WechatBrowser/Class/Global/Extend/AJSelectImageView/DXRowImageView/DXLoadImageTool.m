//
//  DXLoadImageTool.m
//  DXImagePickController
//
//  Created by simon on 16/7/1.
//  Copyright © 2016年 DINGXU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "DXLoadImageTool.h"
#import "DXImagePickModel.h"

@implementation DXLoadImageTool

+ (void)loadAllPhoto:(void(^)(NSArray *models))complete{
	if (!complete) return;
	NSMutableArray *models = [NSMutableArray arrayWithCapacity:20];
	PHFetchOptions *option = [[PHFetchOptions alloc] init];
	if (@available(iOS 9.0, *)) option.fetchLimit = 20;
	//ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
	option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
	PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
	[fetchResult enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (idx >= 20) {
			*stop = YES;
			return;
		}
		[models addObject:obj];
	}];
	[fetchResult enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (idx >= 20) {
			*stop = YES;
			return;
		}
		PHAsset *asset = (PHAsset*)obj;
		PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
		options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
		[[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *__nullable result, NSDictionary *__nullable info) {
			for (NSInteger i=0; i<models.count; i++) {
				if ([models[i] isEqual:asset]) {
					UIImage *image = [result fitToSize:CGSizeMake(0, 150*SCREEN_SCALE)];
					DXImagePickModel *model = [DXImagePickModel new];
					model.asset = asset;
					model.image = image;
					model.count = 0;
					[models replaceObjectAtIndex:i withObject:model];
					break;
				}
			}
			for (NSInteger i=0; i<models.count; i++) {
				if ([models[i] isKindOfClass:[PHAsset class]]) break;
				if (i == models.count-1) {
					complete(models);
				}
			}
		}];
	}];
}

+ (void)getImageOfAsset:(PHAsset *)asset complection:(void (^)(UIImage *result))complection{
	if ([asset isKindOfClass:[PHAsset class]]) {
		PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
		options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
		[[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *__nullable result, NSDictionary *__nullable info) {
			if (complection) {
				complection(result);
			}
		}];
	}
}


@end
