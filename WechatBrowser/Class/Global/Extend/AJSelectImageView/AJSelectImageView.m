//
//  AJSelectImageView.m
//
//  Created by ajsong on 2018/8/31.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AJSelectImageView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "TZPhotoPreviewController.h"
#import "TZGifPhotoPreviewController.h"
#import "TZLocationManager.h"
#import "DXRowImageView.h"

#define kFastFaceViewTag 83427

@interface AJSelectImageView ()<DragSubviewsDelegate,AJSelectImageDelegate,DXRowImageViewDelegate,
UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
	AJSelectImage *_selectImage;
	NSInteger _cellNum;
	UIView *_imagesView;
	UIView *_plusView;
	BOOL _uploading;
	UIButton *_deleteBtn;
	NSMutableArray *_skipViews;
	
	NSMutableArray *_fastImages;
	UIView *_fastView;
	DXRowImageView *_rowImageView;
	UIButton *_fastSend;
}
@end

@implementation AJSelectImageView

- (instancetype)init{
	self = [super init];
	if (self) {
		[self defaultData];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		[self defaultData];
	}
	return self;
}

- (void)defaultData{
	_isSort = YES;
	_max = 9;
	_isFast = YES;
	_maxWidth = 1000;
	_maxHeight = 1000;
	_imageWidth = 44*SCREEN_SCALE;
	_offset = 20*SCREEN_SCALE;
	_images = [[NSMutableArray alloc]init];
	_imageUrls = [[NSMutableArray alloc]init];
	_tips = @"提示：长按图片可排序与删除";
	_tipsColor = COLORCCC;
	_tipsFont = FONT(9);
	_tipsLabel = [[UILabel alloc]init];
	_skipViews = [[NSMutableArray alloc]init];
	
	_fastImages = [[NSMutableArray alloc]init];
	_toolItemColor = COLOR_SYSTEM_BLUE;
	
	_selectImage = [AJSelectImage sharedHelper];
	[_selectImage restore];
	_selectImage.maxWidth = _maxWidth;
	_selectImage.maxHeight = _maxHeight;
	_selectImage.delegate = self;
}

- (void)setImages:(NSMutableArray *)images{
	if (!images.isArray) return;
	if (!_imageUrls.isArray) {
		NSMutableArray *imageUrls = [[NSMutableArray alloc]init];
		for (UIImage *image in images) {
			[imageUrls addObject:@""];
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[self uploadComplete:images urls:imageUrls];
			});
		});
	} else {
		_images = images;
	}
}

- (void)setImageUrls:(NSMutableArray *)imageUrls{
	if (!imageUrls.isArray) return;
	if (!_images.isArray) {
		[imageUrls cacheImageAndCompletion:^(NSArray *images) {
			[self uploadComplete:images urls:imageUrls];
		}];
	} else {
		_imageUrls = imageUrls;
	}
}

- (void)setMaxWidth:(CGFloat)maxWidth{
	_maxWidth = maxWidth;
	_selectImage.maxWidth = maxWidth;
}
- (void)setMaxHeight:(CGFloat)maxHeight{
	_maxHeight = maxHeight;
	_selectImage.maxHeight = maxHeight;
}

- (void)didMoveToSuperview{
	_cellNum = floor(self.width/(_imageWidth+_offset)) + 1;
	_selectImage.maxCount = _count;
	
	_imagesView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, _imageWidth)];
	[self addSubview:_imagesView];
	
	if (_count>1) {
		_fastView = [[UIView alloc]initWithFrame:APPCurrentView.bounds];
		_fastView.top = APPCurrentView.height;
		[_fastView clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
			[target fastRestore];
		}];
		[APPCurrentView addSubview:_fastView];
		
		UIView *faceView = [[UIView alloc]initWithFrame:CGRectMake(0, _fastView.height-(37+150)*SCREEN_SCALE, _fastView.width, (37+150)*SCREEN_SCALE)];
		faceView.tag = kFastFaceViewTag;
		[_fastView addSubview:faceView];
		[faceView addToolbar];
		
		UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		indicatorView.frame = CGRectMake((faceView.width-20)/2, (150*SCREEN_SCALE-20)/2, 20, 20);
		indicatorView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
		indicatorView.tag = 538423;
		[faceView addSubview:indicatorView];
		[indicatorView startAnimating];
		
		_rowImageView = [DXRowImageView rowImageViewWithFrame:CGRectMake(0, 0, _fastView.width, 150*SCREEN_SCALE)];
		_rowImageView.count = _count;
		_rowImageView.rowImageViewDelegate = self;
		[faceView addSubview:_rowImageView];
		
		UIView *toolView = [[UIView alloc]initWithFrame:CGRectMake(0, _rowImageView.bottom, _fastView.width, 37*SCREEN_SCALE)];
		[faceView addSubview:toolView];
		UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 65*SCREEN_SCALE, toolView.height)];
		btn.titleLabel.font = FONT(13);
		btn.backgroundColor = [UIColor clearColor];
		[btn setTitle:@"相册" forState:UIControlStateNormal];
		[btn setTitleColor:_toolItemColor forState:UIControlStateNormal];
		[btn addTarget:self action:^(id target, id sender) {
			[AJSelectImage imagePickerWithMaxCount:_count-_images.count containsAssets:NO completion:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
				[_fastImages removeAllObjects];
				[_fastImages addObjectsFromArray:photos];
				[target fastUpload];
			}];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					[target fastRestore];
				});
			});
		}];
		[toolView addSubview:btn];
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			btn = [[UIButton alloc]initWithFrame:btn.frameRight];
			btn.titleLabel.font = FONT(13);
			btn.backgroundColor = [UIColor clearColor];
			[btn setTitle:@"拍照" forState:UIControlStateNormal];
			[btn setTitleColor:_toolItemColor forState:UIControlStateNormal];
			[btn addTarget:self action:^(id target, id sender) {
				UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
				imagePicker.delegate = target;
				imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
				imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
				if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
					[APPCurrentController presentViewController:imagePicker animated:YES completion:nil];
				} else {
					NSLog(@"模拟器中无法打开照相机,请在真机中使用");
				}
			}];
			[toolView addSubview:btn];
		}
		_fastSend = [[UIButton alloc]initWithFrame:CGRectMake(toolView.width-btn.width, 0, btn.width, toolView.height)];
		_fastSend.titleLabel.font = btn.titleLabel.font;
		_fastSend.backgroundColor = [UIColor clearColor];
		[_fastSend setTitle:@"确定" forState:UIControlStateNormal];
		[_fastSend setTitleColor:_toolItemColor forState:UIControlStateNormal];
		[_fastSend setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
		_fastSend.enabled = NO;
		[_fastSend addTarget:self action:@selector(fastUpload) forControlEvents:UIControlEventTouchUpInside];
		[toolView addSubview:_fastSend];
	}
	
	_plusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _imageWidth, _imageWidth)];
	_plusView.backgroundColor = COLORWHITE;
	[_imagesView addSubview:_plusView];
	if (_dashLine) {
		[_plusView addDashBorder:0.5*SCREEN_SCALE pattern:@[@4, @2] color:(_borderColor?_borderColor:COLOR_GE)];
	} else {
		[_plusView addGeWithType:GeLineTypeAll color:_borderColor?_borderColor:COLOR_GE];
	}
	UILabel *label = [[UILabel alloc]initWithFrame:_plusView.bounds];
	label.text = @"＋";
	label.textColor = COLORCCC;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONTPRICE(28);
	label.backgroundColor = [UIColor clearColor];
	[_plusView addSubview:label];
	[_plusView clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		[APPCurrentView endEditing:YES];
		if (_uploading) return;
		if (_images.count>=_max) {
			[ProgressHUD showError:FORMAT(@"最多可选择%ld张图片", (long)_max)];
			return;
		}
		if (_count>1) {
			if (_isFast) {
				_fastView.height = APPCurrentView.height;
				UIView *faceView = [_fastView viewWithTag:kFastFaceViewTag];
				faceView.top = _fastView.height - faceView.height;
				[APPCurrentView bringSubviewToFront:_fastView];
				[UIView animateWithDuration:0.3 animations:^{
					_fastView.top = 0;
				} completion:^(BOOL finished) {
					if (!_rowImageView.dataArray.isArray) {
						dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
							[DXLoadImageTool loadAllPhoto:^(NSArray *photos) {
								dispatch_async(dispatch_get_main_queue(), ^{
									[(UIActivityIndicatorView*)[_fastView viewWithTag:538423] stopAnimating];
									_rowImageView.dataArray = photos;
								});
							}];
						});
					}
				}];
			} else {
				[AJSelectImage imagePickerWithMaxCount:_count-_images.count containsAssets:NO completion:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
					[_fastImages removeAllObjects];
					[_fastImages addObjectsFromArray:photos];
					[self fastUpload];
				}];
			}
		} else {
			_uploading = YES;
			if (_upyunFolder.length) {
				_selectImage.upyunFolder = _upyunFolder;
				[_selectImage didSelectedImage:^(AJSelectImage *selectImage) {
					[target uploadComplete:selectImage.images urls:selectImage.imageUrls];
				}];
			} else if (_qiniuToken.length) {
				_selectImage.qiniuToken = _qiniuToken;
				[_selectImage didSelectedImage:^(AJSelectImage *selectImage) {
					[target uploadComplete:selectImage.images urls:selectImage.imageUrls];
				}];
			} else if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageView:selectedWithImages:uploadComplete:)]) {
				[_selectImage didSelectedImage:^(AJSelectImage *selectImage) {
					[_delegate AJSelectImageView:self selectedWithImages:selectImage.images uploadComplete:^(NSArray *urls) {
						[target uploadComplete:selectImage.images urls:urls];
					}];
				}];
			} else {
				[_selectImage didSelectedImage:^(AJSelectImage *selectImage) {
					[target uploadComplete:selectImage.images urls:selectImage.images];
				}];
			}
		}
	}];
	
	if (_tips.length) {
		_tipsLabel.frame = _imagesView.frameBottom;
		_tipsLabel.height = 36*SCREEN_SCALE;
		_tipsLabel.text = _tips;
		_tipsLabel.textColor = _tipsColor;
		_tipsLabel.font = _tipsFont;
		_tipsLabel.backgroundColor = [UIColor clearColor];
		_tipsLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
		_tipsLabel.minimumScaleFactor = 0.8;
		_tipsLabel.adjustsFontSizeToFitWidth = YES;
		[self addSubview:_tipsLabel];
	}
	
	self.height = self.lastSubview.bottom;
	
	_deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 44*SCREEN_SCALE)];
	_deleteBtn.titleLabel.font = FONT(12);
	_deleteBtn.backgroundColor = COLORRED;
	_deleteBtn.adjustsImageWhenHighlighted = NO;
	[_deleteBtn setImage:IMG(@"seleteimage-delete") forState:UIControlStateNormal];
	[_deleteBtn setImage:IMG(@"seleteimage-delete-activate") forState:UIControlStateSelected];
	[_deleteBtn setTitle:@"拖到此处删除" forState:UIControlStateNormal];
	[_deleteBtn setTitle:@"松手即可删除" forState:UIControlStateSelected];
	[_deleteBtn setTitleColor:COLORWHITE forState:UIControlStateNormal];
	[_deleteBtn setStyle:UIButtonStyleTop];
	[APPCurrentView addSubview:_deleteBtn];
}

- (void)rowImageView:(DXRowImageView *)collectionView didSeletectedArray:(NSArray *)array{
	_fastSend.enabled = array.count>0;
	NSMutableArray *images = [NSMutableArray arrayWithArray:[array valueForKeyPath:@"originImage"]];
	for (NSInteger i=0; i<images.count; i++) {
		UIImage *image = images[i];
		image = [image fitToSize:CGSizeMake(_maxWidth, _maxHeight)];
		[images replaceObjectAtIndex:i withObject:image];
	}
	[_fastImages removeAllObjects];
	[_fastImages addObjectsFromArray:images];
	if (array.count) {
		[_fastSend setTitle:FORMAT(@"确定(%zd)", array.count) forState:UIControlStateNormal];
		_fastSend.enabled = YES;
	} else {
		[_fastSend setTitle:@"确定" forState:UIControlStateNormal];
		_fastSend.enabled = NO;
	}
}
- (void)rowImageViewDidSeletectedFull:(DXRowImageView *)collectionView{
	[ProgressHUD showError:FORMAT(@"最多可选择%ld张图片", (long)(_count-_images.count))];
}

- (void)fastRestore{
	[UIView animateWithDuration:0.3 animations:^{
		_fastView.top = APPCurrentView.height;
	} completion:^(BOOL finished) {
		[_rowImageView removeAllImages];
		_rowImageView.count = _count - _images.count;
		[_fastSend setTitle:@"确定" forState:UIControlStateNormal];
		_fastSend.enabled = NO;
	}];
}

- (void)fastUpload{
	_uploading = YES;
	if (_upyunFolder.length) {
		[ProgressHUD show:nil];
		[_fastImages UploadToUpyun:_upyunFolder each:^(NSMutableDictionary *json, NSString *imageUrl, NSInteger index) {
			if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:imageUrl];
		} completion:^(NSArray *images, NSArray *imageUrls, NSArray *imageNames) {
			[self uploadComplete:images urls:imageUrls];
		}];
	} else if (_qiniuToken.length) {
		[ProgressHUD show:nil];
		[_fastImages UploadToQiniu:_qiniuToken each:^(NSString *imageUrl, NSInteger index) {
			if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:imageUrl];
		} completion:^(NSArray *images, NSArray *imageUrls, NSArray *imageNames) {
			[self uploadComplete:images urls:imageUrls];
		}];
	} else if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageView:selectedWithImages:uploadComplete:)]) {
		[_delegate AJSelectImageView:self selectedWithImages:_fastImages uploadComplete:^(NSArray *urls) {
			[self uploadComplete:_fastImages urls:urls];
		}];
	} else {
		[self uploadComplete:_fastImages urls:_fastImages];
	}
}

- (void)uploadComplete:(NSArray*)images urls:(NSArray*)urls{
	_uploading = NO;
	if (!images.isArray) {
		[ProgressHUD showError:@"上传完成没有任何图片"];
		return;
	}
	
	[_skipViews addObject:_plusView];
	
	[_images addObjectsFromArray:images];
	[_imageUrls addObjectsFromArray:urls];
	
	for (int i=0; i<images.count; i++) {
		UIView *subview = [[UIView alloc]initWithFrame:CGRectMake(_offset, _offset, _imageWidth, _imageWidth)];
		if (_borderColor) {
			if (_dashLine) {
				[subview addDashBorder:0.5*SCREEN_SCALE pattern:@[@4, @2] color:_borderColor];
			} else {
				[subview addGeWithType:GeLineTypeAll color:_borderColor];
			}
		}
		subview.element[@"image"] = images[i];
		subview.element[@"url"] = urls[i];
		
		UIImageView *pic = [[UIImageView alloc]initWithFrame:subview.bounds];
		pic.image = images[i];
		if ([urls[i] isKindOfClass:[NSString class]]) pic.url = urls[i];
		[subview addSubview:pic];
		
		if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageView:didSelectImageView:)]) {
			[pic clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
				[_delegate AJSelectImageView:target didSelectImageView:(UIImageView*)sender];
			}];
		}
		
		if (!_isSort) {
			[_skipViews addObject:subview];
		}
		
		if (_images.count>=_max) {
			_plusView.hidden = YES;
		}
		
		[_imagesView addSubview:subview atIndex:_plusView.index x:_offset y:_offset marginPT:0 marginPL:0 marginPR:0 completion:nil];
		if (_images.count>_cellNum) {
			[_imagesView setHeightAndChangeNextTop:_imagesView.lastSubview.bottom completion:nil];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					[self setHeightAndChangeNextTop:self.lastSubview.bottom completion:nil];
				});
			});
		}
	}
	
	[_imagesView dragSubviewsWithTarget:self lockRect:CGRectZero skipViews:_skipViews];
	[self fastRestore];
	
	if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageView:didSelectedWithImages:imageUrls:)]) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[_delegate AJSelectImageView:self didSelectedWithImages:_images imageUrls:_imageUrls];
			});
		});
	}
}

//拍照用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
	UIImage *image = info[UIImagePickerControllerOriginalImage];
	if (picker.sourceType==UIImagePickerControllerSourceTypeCamera){
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil); //保存到相册
	}
	if (_maxWidth>0 || _maxHeight>0) {
		image = [image fitToSize:CGSizeMake(_maxWidth, _maxHeight) scale:NO];
	}
	[picker dismissViewControllerAnimated:YES completion:nil];
	CGFloat rand = (arc4random() % 89999999) + 10000000;
	NSString *imageName = [NSString stringWithFormat:@"%.f", rand];
	if (_upyunFolder.length) {
		[image.imageQualityMiddle UploadToUpyun:_upyunFolder imageName:imageName progress:nil completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
			[self uploadComplete:@[image] urls:@[imageUrl]];
		}];
	} else if (_qiniuToken.length) {
		[image.imageQualityMiddle UploadToQiniu:_qiniuToken imageName:imageName progress:nil completion:^(UIImage *image, NSString *imageUrl, NSString *imageName) {
			[self uploadComplete:@[image] urls:@[imageUrl]];
		}];
	} else if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageView:selectedWithImages:uploadComplete:)]) {
		[_delegate AJSelectImageView:self selectedWithImages:@[image] uploadComplete:^(NSArray *urls) {
			[self uploadComplete:@[image] urls:@[urls.firstObject]];
		}];
	} else {
		[self uploadComplete:@[image] urls:@[image]];
	}
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)AJSelectImage:(AJSelectImage *)selectImage willSelectedWithImages:(NSArray *)images{
	if (images.count > _max) {
		return NO;
	}
	return YES;
}
- (void)AJSelectImageDidSelectedImage:(AJSelectImage *)selectImage{
	[self uploadComplete:selectImage.images urls:selectImage.imageUrls];
}
- (void)AJSelectImageDismissViewController:(AJSelectImage *)selectImage{
	_uploading = NO;
}

- (void)dragSubviewsSortBegan:(UIView *)subview{
	[self bringSubviewToFront:_imagesView];
	[_imagesView bringSubviewToFront:subview];
	[APPCurrentView bringSubviewToFront:_deleteBtn];
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		_deleteBtn.top = APPCurrentView.height - _deleteBtn.height - _deleteBtnOffsetY;
	} completion:nil];
	if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageViewSortBegan:)]) {
		[_delegate AJSelectImageViewSortBegan:self];
	}
}

- (void)dragSubviewsSortChanged:(UIView *)subview fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex sorts:(NSArray *)sorts{
	if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageViewSortChanged:fromIndex:toIndex:sorts:)]) {
		[_delegate AJSelectImageViewSortChanged:self fromIndex:fromIndex toIndex:toIndex sorts:sorts];
	}
}

- (void)dragSubviewsSortChanged:(UIView *)subview{
	CGRect subviewRect = [self convertRect:subview.frame toView:APPCurrentView];
	CGRect deleteBtnRect = [APPCurrentView convertRect:_deleteBtn.frame toView:APPCurrentView];
	if (subviewRect.origin.y + subviewRect.size.height >= deleteBtnRect.origin.y) {
		_deleteBtn.selected = YES;
	} else {
		_deleteBtn.selected = NO;
	}
	[_deleteBtn setStyle:UIButtonStyleTop];
	if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageViewSortChanged:)]) {
		[_delegate AJSelectImageViewSortChanged:self];
	}
}

- (void)dragSubviewsSortRelease:(UIView *)subview{
	CGRect subviewRect = [self convertRect:subview.frame toView:APPCurrentView];
	CGRect deleteBtnRect = [APPCurrentView convertRect:_deleteBtn.frame toView:APPCurrentView];
	if (subviewRect.origin.y + subviewRect.size.height >= deleteBtnRect.origin.y) {
		if ([_skipViews containsObject:subview]) {
			[_skipViews removeObject:subview];
		}
		[_images removeObject:subview.element[@"image"]];
		[_imageUrls removeObject:subview.element[@"url"]];
		if (_images.count<_max) {
			_plusView.hidden = NO;
		}
		[subview removeFromSuperview];
		[_imagesView addSubviewsAgainWithX:_offset y:_offset marginPT:0 marginPL:0 marginPR:0];
		if (_images.count<_cellNum) {
			[_imagesView setHeightAndChangeNextTop:_imagesView.lastSubview.bottom completion:nil];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					[self setHeightAndChangeNextTop:self.lastSubview.bottom completion:nil];
				});
			});
		}
		[_imagesView dragSubviewsWithTarget:self lockRect:CGRectZero skipViews:_skipViews];
		[self fastRestore];
		if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageView:didSelectedWithImages:imageUrls:)]) {
			[_delegate AJSelectImageView:self didSelectedWithImages:_images imageUrls:_imageUrls];
		}
	}
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		_deleteBtn.top = SCREEN_HEIGHT;
	} completion:^(BOOL finished) {
		_deleteBtn.selected = NO;
	}];
	if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageViewSortRelease:)]) {
		[_delegate AJSelectImageViewSortRelease:self];
	}
}

- (void)dragSubviewsSortEnded:(UIView *)subview{
	[_plusView.superview bringSubviewToFront:_plusView];
	if (_isSort && subview.superview) {
		[_images removeAllObjects];
		[_imageUrls removeAllObjects];
		for (UIView *item in subview.superview.subviews) {
			if (item.element[@"image"] && item.element[@"url"]) {
				[_images addObject:item.element[@"image"]];
				[_imageUrls addObject:item.element[@"url"]];
			}
		}
		if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageView:didSelectedWithImages:imageUrls:)]) {
			[_delegate AJSelectImageView:self didSelectedWithImages:_images imageUrls:_imageUrls];
		}
	}
	if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageViewSortEnded:)]) {
		[_delegate AJSelectImageViewSortEnded:self];
	}
}

@end
