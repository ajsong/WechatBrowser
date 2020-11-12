//
//  UIImage+Extend.h
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - UIImageView+Extend
@interface UIImageView (GlobalExtend)
- (UIImage*)placeholder;
- (void)setPlaceholder:(UIImage*)placeholder;
- (BOOL)loading;
- (void)setLoading:(BOOL)loading;
- (UIEdgeInsets)autoWidth;
- (void)setAutoWidth:(UIEdgeInsets)padding;
- (UIEdgeInsets)autoHeight;
- (void)setAutoHeight:(UIEdgeInsets)padding;
- (id)url;
- (void)setUrl:(id)url;
- (void)setUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion;
- (void)setUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate;
- (void)cacheImageWithUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion;
- (void)cacheImageWithUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate;
- (void)animationWithPlist:(NSString *)plistName duration:(NSTimeInterval)duration completion:(void (^)(void))completion;
@end


#pragma mark - UIImage+Extend
@interface UIImage (GlobalExtend)
+ (UIImage*)imageFile:(NSString*)name;
+ (UIImage*)imageFilename:(NSString*)name;
- (void)saveImageToPhotos;
- (void)saveToAlbumWithCompletion:(void (^)(BOOL success))completion;
- (void)saveImageToDocumentWithName:(NSString*)name;
- (void)saveImageToTmpWithName:(NSString*)name;
- (NSData*)imageQuality:(CGFloat)quality;
- (NSData*)imageQualityHigh;
- (NSData*)imageQualityMiddle;
- (NSData*)imageQualityLow;
- (UIImage*)fitToSize:(CGSize)size;
- (UIImage*)fitToSize:(CGSize)size scale:(BOOL)scale;
- (UIImage*)fitToSize:(CGSize)size scale:(BOOL)scale fix:(CGFloat)fix;
- (UIImage*)changeToSize:(CGSize)size;
- (UIImage*)addImage:(UIImage*)image;
- (UIImage*)croppedInRect:(CGRect)bounds;
- (NSData*)data;
- (NSString*)base64;
- (NSString*)base64WithMark;
- (NSString*)suffix;
- (NSString*)mimeType;
- (BOOL)hasAlpha;
- (BOOL)isPNG;
- (BOOL)isGIF;
- (UIImage*)imageBlackToTransparent;
- (UIImage*)renderWithTintColor:(UIColor*)color;
- (UIImage*)overlayWithColor:(UIColor*)color;
- (UIImage*)gray;
- (UIImage*)blurWithRadius:(CGFloat)radius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor;
- (void)UploadToUpyun:(NSString*)upyunFolder completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToUpyun:(NSString*)upyunFolder progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToQiniu:(NSString*)token completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToQiniu:(NSString*)token progress:(void (^)(NSProgress *progress))progress completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToQiniu:(NSString*)token imageName:(NSString*)imageName completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToQiniu:(NSString*)token imageName:(NSString*)imageName progress:(void (^)(NSProgress *progress))progress completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion;
@end
