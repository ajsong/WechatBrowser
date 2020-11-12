//
//  AJSelectImage.m
//
//  Created by ajsong on 2016/10/10.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import "AJSelectImage.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "TZPhotoPreviewController.h"
#import "TZGifPhotoPreviewController.h"
#import "TZLocationManager.h"

@interface AJSelectImage ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>{
	UIStatusBarStyle _statusBarStyle;
	BOOL _isCamera;
}
@end

@implementation AJSelectImage

- (instancetype)init{
	self = [super init];
	if (self) {
		[self restore];
	}
	return self;
}

- (void)setImageUrls:(NSMutableArray *)imageUrls{
	_imageUrls = imageUrls;
	if (imageUrls.isArray) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[_images removeAllObjects];
				for (int i=0; i<_imageUrls.count; i++) {
					[_imageUrls[i] cacheImageAndCompletion:^(UIImage *image, NSData *imageData) {
						if (!_reselectImages) image.element[@"camera"] = @YES;
						[_images replaceObjectAtIndex:i withObject:image];
					}];
				}
			});
		});
	}
}

#pragma mark - 重置属性
- (void)restore{
	_sender = nil;
	_delegate = nil;
	_title = @"选择图片";
	_maxCount = 0;
	_maxWidth = 1000;
	_maxHeight = 1000;
	_clipType = ClipNone;
	_upyunFolder = @""; //uploadfiles
	_qiniuToken = @"";
	_showLoading = YES;
	_progress = nil;
	_completion = nil;
	_tag = 0;
	[self clearImages];
}

#pragma mark - 清除图片组
- (void)clearImages{
	[_assets removeAllObjects];
	[_images removeAllObjects];
	[_imageUrls removeAllObjects];
	_assets = [[NSMutableArray alloc]init];
	_images = [[NSMutableArray alloc]init];
	_imageUrls = [[NSMutableArray alloc]init];
}

#pragma mark - 选择图片
- (void)selectImage{
	NSString *title = _title;
	if (_maxCount>0) {
		if (!_reselectImages && _images.count>=_maxCount) {
			[ProgressHUD showError:FORMAT(@"最多只能选择%ld张图片", (long)_maxCount)];
			return;
		}
		NSString *text = @"还可选择%ld张图片";
		if (_images.count==0) text = @"可选择%ld张图片";
		title = FORMAT(text, (long)(_maxCount-_images.count));
	} else {
		[self clearImages];
	}
	_isCamera = NO;
	_statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
	NSMutableArray *buttons = [[NSMutableArray alloc]init];
	[buttons addObject:@"从相册选择"];
	//判断是否支持相机
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) [buttons addObject:@"拍照"];
	[UIAlertController action:title buttons:buttons block:^(NSInteger buttonIndex) {
		if (buttonIndex==0) {
			if (_maxCount==0) {
				[self pickImageFromAlbum];
			} else {
				[self pickImagesFromAlbum];
			}
		} else if (buttonIndex==1) {
			if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
			[self pickImageFromCamera];
		} else {
			return;
		}
	}];
}

#pragma mark - 从相册获取图片
- (void)pickImageFromAlbum{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[APPCurrentController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - 从相册获取多张图片
- (void)pickImagesFromAlbum{
	TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:_maxCount columnNumber:4 delegate:self pushPhotoPickerVc:YES];
	imagePickerVc.selectedAssets = _assets; //已选中的图片数组
	imagePickerVc.photoWidth = _maxWidth; //选择后的图片宽度
	imagePickerVc.allowTakePicture = NO; //允许内部调用照相
	imagePickerVc.allowTakeVideo = NO; //允许内部调用录视频
	imagePickerVc.allowPickingVideo = NO; //允许选择视频
	imagePickerVc.allowPickingGif = YES; //允许选择gif
	imagePickerVc.showSelectedIndex = YES; //显示图片序号
	[APPCurrentController presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
	BOOL canUpload = YES;
	if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImage:willSelectedWithImages:)]) {
		NSMutableArray *images = [[NSMutableArray alloc]init];
		for (int i=0; i<photos.count; i++) {
			if (_images.count>=_maxCount) {
				canUpload = NO;
				break;
			}
			UIImage *image = photos[i];
			[images addObject:image];
		}
		if (canUpload) {
			canUpload = [_delegate AJSelectImage:self willSelectedWithImages:images];
		}
	}
	if (!canUpload) {
		if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageDismissViewController:)]) {
			[_delegate AJSelectImageDismissViewController:self];
		}
		return;
	}
	
	[_assets removeAllObjects];

	if (!_reselectImages) {
		NSMutableIndexSet *albums = [[NSMutableIndexSet alloc]init];
		for (int i=0; i<_images.count; i++) {
			UIImage *image = _images[i];
			if (![image.element[@"camera"] isset]) [albums addIndex:i];
		}
		[_images removeObjectsAtIndexes:albums];
		[_imageUrls removeObjectsAtIndexes:albums];
	} else {
		[_images removeAllObjects];
		[_imageUrls removeAllObjects];
	}
	
	BOOL isUploadImage = ((_delegate && [_delegate respondsToSelector:@selector(AJSelectImage:didSelectedWithImage:uploadComplete:)]) ||
						  _upyunFolder.length ||
						  _qiniuToken.length);

	NSMutableArray *images = [[NSMutableArray alloc]init];
	for (int i=0; i<photos.count; i++) {
		if (_images.count>=_maxCount) break;
		UIImage *image = photos[i];
		if (_maxWidth>0 || _maxHeight>0) {
			image = [image fitToSize:CGSizeMake(_maxWidth, _maxHeight) scale:NO];
		}
		[_assets addObject:assets[i]];
		[_images addObject:image];

		if (isUploadImage) {
			CGFloat rand = (arc4random() % 89999999) + 10000000;
			NSString *imageName = [NSString stringWithFormat:@"%.f", rand];
			[_imageUrls addObject:imageName];
			[images addObject:@{@"image":image, @"imageName":imageName}];
		} else {
			[_imageUrls addObject:API_URL];
		}
	}

	if (isUploadImage) {
		if (_showLoading) [ProgressHUD show:nil];
		if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageUploadingImage:)]) {
			[_delegate AJSelectImageUploadingImage:self];
		}
		
		for (int i=0; i<images.count; i++) {
			UIImage *image = images[i][@"image"];
			NSString *imageName = images[i][@"imageName"];
			if (_upyunFolder.length) {
				[image.imageQualityMiddle UploadToUpyun:_upyunFolder imageName:imageName completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
					NSInteger index = [_imageUrls indexOfObject:imageName];
					if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:imageUrl];
				}];
			} else if (_qiniuToken.length) {
				[image.imageQualityMiddle UploadToQiniu:_qiniuToken imageName:imageName completion:^(UIImage *image, NSString *imageUrl, NSString *imageName) {
					NSInteger index = [_imageUrls indexOfObject:imageName];
					if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:imageUrl];
				}];
			} else if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImage:didSelectedWithImage:uploadComplete:)]) {
				[_delegate AJSelectImage:self didSelectedWithImage:image uploadComplete:^(NSString *url) {
					NSInteger index = [_imageUrls indexOfObject:imageName];
					if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:url];
				}];
			}
		}
	}

	[self performSelector:@selector(selectedImage) withObject:nil afterDelay:0.3];
}

#pragma mark - 从摄像头获取图片
- (void)pickImageFromCamera{
	_isCamera = YES;
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[APPCurrentController presentViewController:imagePicker animated:YES completion:nil];
	} else {
		NSLog(@"模拟器中无法打开照相机,请在真机中使用");
	}
}

#pragma mark - 获取图片交互
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
	UIImage *image = info[UIImagePickerControllerOriginalImage];
	if (_clipType==ClipNone) {
		if (_saveToAlbum && picker.sourceType==UIImagePickerControllerSourceTypeCamera){
			UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil); //保存到相册
		}
		if (_maxWidth>0 || _maxHeight>0) {
			image = [image fitToSize:CGSizeMake(_maxWidth, _maxHeight) scale:NO];
		}
		[self uploadImage:image];
		[picker dismissViewControllerAnimated:YES completion:^{
			if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageDismissViewController:)]) {
				[_delegate AJSelectImageDismissViewController:self];
			}
		}];
	} else {
		void (^completion)(PHAsset *asset, NSError *error) = ^(PHAsset *asset, NSError *error){
			if (error) {
				NSLog(@"图片保存失败 %@", error);
			} else {
				TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
				TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
					[_assets addObject:asset];
					[self uploadImage:cropImage];
					[picker dismissViewControllerAnimated:YES completion:^{
						if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageDismissViewController:)]) {
							[_delegate AJSelectImageDismissViewController:self];
						}
					}];
				}];
				imagePicker.allowPickingImage = YES;
				imagePicker.needCircleCrop = _clipType==ClipCircular;
				imagePicker.circleCropRadius = floor(100*SCREEN_SCALE);
				[APPCurrentController presentViewController:imagePicker animated:YES completion:nil];
			}
		};
		if (_isCamera) {
			[[TZImageManager manager] savePhotoWithImage:image location:nil completion:completion];
		} else {
			NSURL *referenceURL = info[UIImagePickerControllerReferenceURL];
			NSString *localIdentifier = referenceURL.absoluteString;
			NSArray *urls = [localIdentifier explode:@"?id="];
			localIdentifier = urls[1];
			urls = [localIdentifier explode:@"&ext="];
			localIdentifier = urls[0];
			PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
			completion(asset, nil);
		}
	}
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[picker dismissViewControllerAnimated:YES completion:^{
		if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageDismissViewController:)]) {
			[_delegate AJSelectImageDismissViewController:self];
		}
	}];
}

#pragma mark - 上传图片
- (void)uploadImage:(UIImage*)image{
	if (!_reselectImages) {
		if (_isCamera) image.element[@"camera"] = @YES;
	} else {
		[_images removeAllObjects];
		[_imageUrls removeAllObjects];
	}
	[_images addObject:image];
	
	BOOL isUploadImage = ((_delegate && [_delegate respondsToSelector:@selector(AJSelectImage:didSelectedWithImage:uploadComplete:)]) ||
						  _upyunFolder.length ||
						  _qiniuToken.length);

	CGFloat rand = (arc4random() % 89999999) + 10000000;
	NSString *imageName = [NSString stringWithFormat:@"%.f", rand];
	if (isUploadImage) {
		[_imageUrls addObject:imageName];
		//if (_showLoading) [ProgressHUD show:nil];
		if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageUploadingImage:)]) {
			[_delegate AJSelectImageUploadingImage:self];
		}
	} else {
		[_imageUrls addObject:API_URL];
	}

	if (_upyunFolder.length) {
		[image.imageQualityMiddle UploadToUpyun:_upyunFolder imageName:imageName progress:_showLoading?_progress:nil completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
			NSInteger index = [_imageUrls indexOfObject:imageName];
			if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:imageUrl];
		}];
	} else if (_qiniuToken.length) {
		[image.imageQualityMiddle UploadToQiniu:_qiniuToken imageName:imageName progress:_showLoading?_progress:nil completion:^(UIImage *image, NSString *imageUrl, NSString *imageName) {
			NSInteger index = [_imageUrls indexOfObject:imageName];
			if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:imageUrl];
		}];
	} else if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImage:didSelectedWithImage:uploadComplete:)]) {
		[_delegate AJSelectImage:self didSelectedWithImage:image uploadComplete:^(NSString *url) {
			if (![url isUrl]) url = FORMAT(@"%@%@", API_URL, url);
			NSInteger index = [_imageUrls indexOfObject:imageName];
			if (index != NSNotFound) [_imageUrls replaceObjectAtIndex:index withObject:url];
		}];
	}

	[self performSelector:@selector(selectedImage) withObject:nil afterDelay:0.3];
}

- (void)selectedImage{
	if ([self uploadComplete]) {
		[ProgressHUD dismiss];
		if (_completion) {
			_completion(self);
		} else if (_delegate && [_delegate respondsToSelector:@selector(AJSelectImageDidSelectedImage:)]) {
			[_delegate AJSelectImageDidSelectedImage:self];
		}
		return;
	}
	[self performSelector:@selector(selectedImage) withObject:nil afterDelay:1.0];
}

- (BOOL)uploadComplete{
	if (!_upyunFolder.length && !_qiniuToken.length) return YES;
	BOOL isUploaded = YES;
	for (int i=0; i<_imageUrls.count; i++) {
		if (![_imageUrls[i] isUrl]) {
			isUploaded = NO;
			break;
		}
	}
	return isUploaded;
}

- (void)didSelectedImage:(void (^)(AJSelectImage *))completion{
	_completion = completion;
	[self selectImage];
}

+ (AJSelectImage*)sharedHelper{
	static dispatch_once_t once = 0;
	static AJSelectImage *sharedHelper;
	dispatch_once(&once, ^{ sharedHelper = [[AJSelectImage alloc] init]; });
	return sharedHelper;
}

+ (AJSelectImage*)selectImage:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage selectImageWithTitle:@"选择图片" upyunFolder:nil completion:completion];
}
+ (AJSelectImage*)selectImageWithTitle:(NSString *)title completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage selectImageWithTitle:title upyunFolder:nil completion:completion];
}
+ (AJSelectImage*)selectImageWithUpyunFolder:(NSString *)upyunFolder completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage selectImageWithTitle:@"选择图片" upyunFolder:upyunFolder completion:completion];
}
+ (AJSelectImage*)selectImageWithQiniuToken:(NSString*)qiniuToken completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage selectImageWithTitle:@"选择图片" qiniuToken:qiniuToken completion:completion];
}
+ (AJSelectImage*)selectImageWithTitle:(NSString *)title upyunFolder:(NSString *)upyunFolder completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage selectImageWithTitle:title upyunFolder:upyunFolder clipType:ClipNone completion:completion];
}
+ (AJSelectImage*)selectImageWithTitle:(NSString *)title qiniuToken:(NSString*)qiniuToken completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage selectImageWithTitle:title upyunFolder:nil qiniuToken:qiniuToken clipType:ClipNone completion:completion];
}
+ (AJSelectImage*)selectImageWithTitle:(NSString *)title upyunFolder:(NSString *)upyunFolder clipType:(ClipImageType)clipType completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage selectImageWithTitle:title upyunFolder:upyunFolder qiniuToken:nil clipType:clipType completion:completion];
}
+ (AJSelectImage*)selectImageWithTitle:(NSString *)title upyunFolder:(NSString *)upyunFolder qiniuToken:(NSString*)qiniuToken clipType:(ClipImageType)clipType completion:(void (^)(AJSelectImage *selectImage))completion{
	AJSelectImage *selectImage = [AJSelectImage sharedHelper];
	[selectImage restore];
	selectImage.title = title;
	selectImage.upyunFolder = upyunFolder;
	selectImage.qiniuToken = qiniuToken;
	selectImage.clipType = clipType;
	selectImage.progress = ^(NSProgress *progress){
		[ProgressHUD showProgress:progress.totalUnitCount completed:progress.completedUnitCount];
	};
	[selectImage didSelectedImage:completion];
	return selectImage;
}

+ (AJSelectImage*)clipImage:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage clipImageWithTitle:@"选择图片" upyunFolder:nil completion:completion];
}
+ (AJSelectImage*)clipImageWithTitle:(NSString *)title completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage clipImageWithTitle:title upyunFolder:nil completion:completion];
}
+ (AJSelectImage*)clipImageWithUpyunFolder:(NSString *)upyunFolder completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage clipImageWithTitle:@"选择图片" upyunFolder:upyunFolder completion:completion];
}
+ (AJSelectImage*)clipImageWithQiniuToken:(NSString*)qiniuToken completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage clipImageWithTitle:@"选择图片" qiniuToken:qiniuToken completion:completion];
}
+ (AJSelectImage*)clipImageWithTitle:(NSString *)title upyunFolder:(NSString *)upyunFolder completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage selectImageWithTitle:title upyunFolder:upyunFolder clipType:ClipSquare completion:completion];
}
+ (AJSelectImage*)clipImageWithTitle:(NSString *)title qiniuToken:(NSString*)qiniuToken completion:(void (^)(AJSelectImage *selectImage))completion{
	return [AJSelectImage selectImageWithTitle:title upyunFolder:nil qiniuToken:qiniuToken clipType:ClipSquare completion:completion];
}

+ (AJSelectImage*)imagePickerWithMaxCount:(NSInteger)maxCount completion:(void (^)(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto))completion{
	return [AJSelectImage imagePickerWithMaxCount:maxCount containsAssets:YES completion:completion];
}
+ (AJSelectImage*)imagePickerWithMaxCount:(NSInteger)maxCount containsAssets:(BOOL)containsAssets completion:(void (^)(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto))completion{
	AJSelectImage *selectImage = [AJSelectImage sharedHelper];
	TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
	if (containsAssets) imagePickerVc.selectedAssets = selectImage.assets; //已选中的图片数组
	imagePickerVc.photoWidth = selectImage.maxWidth; //选择后的图片宽度
	imagePickerVc.allowTakePicture = NO; //允许内部调用照相
	imagePickerVc.allowTakeVideo = NO; //允许内部调用录视频
	imagePickerVc.allowPickingVideo = NO; //允许选择视频
	imagePickerVc.allowPickingGif = YES; //允许选择gif
	imagePickerVc.showSelectedIndex = YES; //显示图片序号
	[imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
		if (containsAssets) {
			[selectImage.assets removeAllObjects];
			selectImage.assets = [NSMutableArray arrayWithArray:assets];
		}
		if (completion) completion(photos, assets, isSelectOriginalPhoto);
	}];
	[APPCurrentController presentViewController:imagePickerVc animated:YES completion:nil];
	return selectImage;
}

@end
