//
//  AJSelectImageView.h
//
//  Created by ajsong on 2018/8/31.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

/*
- (void)AJSelectImageViewSortBegan:(AJSelectImageView *)imageView{
	[_scrollView bringSubviewToFront:_imageView.superview];
}
- (void)AJSelectImageViewSortEnded:(AJSelectImageView *)imageView{
	[_scrollView sendSubviewToBack:_imageView.superview];
}
- (void)AJSelectImageView:(AJSelectImageView *)imageView selectedWithImages:(NSArray *)images uploadComplete:(void (^)(NSArray *))complete{
	[ProgressHUD show:nil];
	NSMutableArray *array = [[NSMutableArray alloc]init];
	for (int i=0; i<images.count; i++) {
		[array addObject:FORMAT(@"%d", i)];
	}
	for (int i=0; i<images.count; i++) {
		[Common uploadApiWithParams:@[@"other", @"uploadfile"] data:@{@"filename.png":images[i]} feedback:ApiNonSuccessMessage success:^(NSMutableDictionary *json) {
			NSString *url = json[@"data"];
			[array replaceObjectAtIndex:i withObject:url];
			BOOL isUploadComplele = YES;
			for (int i=0; i<array.count; i++) {
				if ([array[i] isInt]) {
					isUploadComplele = NO;
					break;
				}
			}
			if (isUploadComplele) complete(array);
		} fail:nil];
	}
}
- (void)AJSelectImageView:(AJSelectImageView *)imageView didSelectedWithImages:(NSArray *)images imageUrls:(NSArray *)imageUrls{
	_image = [NSMutableArray arrayWithArray:imageUrls];
}
*/

#import <UIKit/UIKit.h>
@class AJSelectImageView;

@protocol AJSelectImageViewDelegate<NSObject>
@optional
- (void)AJSelectImageViewSortBegan:(AJSelectImageView*)imageView;
- (void)AJSelectImageViewSortChanged:(AJSelectImageView*)imageView fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex sorts:(NSArray*)sorts;
- (void)AJSelectImageViewSortChanged:(AJSelectImageView*)imageView;
- (void)AJSelectImageViewSortRelease:(AJSelectImageView*)imageView;
- (void)AJSelectImageViewSortEnded:(AJSelectImageView*)imageView;
//选中图片执行
- (void)AJSelectImageView:(AJSelectImageView*)imageView didSelectImageView:(UIImageView*)imageView;
//使用代理上传已选择图片,上传完后需要手动调用 complete(url);
- (void)AJSelectImageView:(AJSelectImageView*)imageView selectedWithImages:(NSArray*)images uploadComplete:(void (^)(NSArray *urls))complete;
- (void)AJSelectImageView:(AJSelectImageView*)imageView didSelectedWithImages:(NSArray*)images imageUrls:(NSArray*)imageUrls;
@end

@interface AJSelectImageView : UIView
@property (nonatomic,weak) id<AJSelectImageViewDelegate> delegate;
@property (nonatomic,assign) BOOL isSort; //可否排序,默认YES
@property (nonatomic,assign) NSInteger max; //最多上传图片数,默认9张
@property (nonatomic,assign) NSInteger count; //从相册选择时最多选择图片数,0或1为单选,默认0
@property (nonatomic,assign) BOOL isFast; //多选时使用快选模式,默认YES
@property (nonatomic,assign) CGFloat maxWidth; //最大图片宽度,默认1000
@property (nonatomic,assign) CGFloat maxHeight; //最大图片高度,默认1000
@property (nonatomic,assign) CGFloat imageWidth; //图片宽高,默认44
@property (nonatomic,assign) CGFloat offset; //图片间距,默认20,这样一行放5个图片
@property (nonatomic,strong) UIColor *borderColor; //边框颜色,不设即没有边框,默认没有
@property (nonatomic,assign) BOOL dashLine; //边框为虚线
@property (nonatomic,strong) NSMutableArray *images; //已选择图片组
@property (nonatomic,strong) NSMutableArray *imageUrls; //已上传图片网址组
@property (nonatomic,strong) NSString *tips; //提示文字,为空即不显示提示标签,默认 提示：长按图片可排序与删除
@property (nonatomic,strong) UIColor *tipsColor; //提示文字颜色,默认CCC
@property (nonatomic,strong) UIFont *tipsFont; //提示文字颜色,默认9
@property (nonatomic,strong) UILabel *tipsLabel; //提示标签
@property (nonatomic,assign) CGFloat deleteBtnOffsetY; //删除按钮向上偏移
@property (nonatomic,strong) NSString *upyunFolder; //又拍云存放位置
@property (nonatomic,strong) NSString *qiniuToken; //七牛token,又拍云和七牛都为空即使用代理操作
@property (nonatomic,strong) UIColor *toolItemColor; //快捷选图的按钮文字颜色,默认系统蓝色
@end
