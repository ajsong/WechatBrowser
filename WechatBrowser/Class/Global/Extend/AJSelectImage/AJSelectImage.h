//
//  AJSelectImage.h
//
//  Created by ajsong on 2016/10/10.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AJSelectImageDelegate;

typedef enum{
	ClipNone = -1,
	ClipCircular, //圆形裁剪
	ClipSquare //方形裁剪
}ClipImageType;

@interface AJSelectImage : NSObject
@property (nonatomic,weak) id<AJSelectImageDelegate> delegate;
@property (nonatomic,strong) id sender; //调起selectImage方法的触发者,默认nil
@property (nonatomic,strong) NSString *title; //UIActionSheet的title,默认选择图片
@property (nonatomic,assign) NSInteger maxCount; //从相册选择时最多选择图片数,0为单选,默认0
@property (nonatomic,strong) NSMutableArray *assets; //选择的图片项目
@property (nonatomic,strong) NSMutableArray *images; //选择的图片
@property (nonatomic,strong) NSMutableArray *imageUrls; //图片上传后的网址,数量将对应images
@property (nonatomic,assign) CGFloat maxWidth; //图片宽最多尺寸,默认1000
@property (nonatomic,assign) CGFloat maxHeight; //图片高最多尺寸,默认1000,maxWidth与maxHeight都为0即上传原图
@property (nonatomic,strong) NSString *upyunFolder; //上传到又拍云的位置(设置后选择图片自动上传到又拍云),默认为空
@property (nonatomic,strong) NSString *qiniuToken; //上传到七牛需要的token
@property (nonatomic,assign) BOOL showLoading; //上传期间显示loading,默认YES
@property (nonatomic,assign) BOOL reselectImages; //选择多图时是否重新选择,不记录前一次的选择,默认NO
@property (nonatomic,assign) BOOL uploadComplete; //自动上传完成,如果!upyunFolder.length即直接为YES
@property (nonatomic,assign) BOOL saveToAlbum; //照相取图同时保存到相册,默认NO
@property (nonatomic,assign) void (^progress)(NSProgress *progress); //上传进度
@property (nonatomic,assign) ClipImageType clipType; //裁剪类型(单选有效),默认不裁剪
@property (nonatomic,copy) void (^completion)(AJSelectImage *); //上传或选择完成后回调
@property (nonatomic,assign) NSInteger tag;

- (void)selectImage;
- (void)pickImageFromAlbum;
- (void)pickImagesFromAlbum;
- (void)pickImageFromCamera;
- (void)restore;
- (void)clearImages;
- (void)didSelectedImage:(void (^)(AJSelectImage *selectImage))completion;

+ (AJSelectImage*)sharedHelper;
+ (AJSelectImage*)selectImage:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)selectImageWithTitle:(NSString *)title completion:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)selectImageWithUpyunFolder:(NSString *)upyunFolder completion:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)selectImageWithQiniuToken:(NSString*)qiniuToken completion:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)selectImageWithTitle:(NSString *)title upyunFolder:(NSString *)upyunFolder completion:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)selectImageWithTitle:(NSString *)title qiniuToken:(NSString*)qiniuToken completion:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)selectImageWithTitle:(NSString *)title upyunFolder:(NSString *)upyunFolder clipType:(ClipImageType)clipType completion:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)selectImageWithTitle:(NSString *)title upyunFolder:(NSString *)upyunFolder qiniuToken:(NSString*)qiniuToken clipType:(ClipImageType)clipType completion:(void (^)(AJSelectImage *selectImage))completion;

+ (AJSelectImage*)clipImage:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)clipImageWithTitle:(NSString*)title completion:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)clipImageWithUpyunFolder:(NSString*)upyunFolder completion:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)clipImageWithQiniuToken:(NSString*)qiniuToken completion:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)clipImageWithTitle:(NSString*)title upyunFolder:(NSString*)upyunFolder completion:(void (^)(AJSelectImage *selectImage))completion;
+ (AJSelectImage*)clipImageWithTitle:(NSString*)title qiniuToken:(NSString*)qiniuToken completion:(void (^)(AJSelectImage *selectImage))completion;

+ (AJSelectImage*)imagePickerWithMaxCount:(NSInteger)maxCount completion:(void (^)(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto))completion;
+ (AJSelectImage*)imagePickerWithMaxCount:(NSInteger)maxCount containsAssets:(BOOL)containsAssets completion:(void (^)(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto))completion;

@end

@protocol AJSelectImageDelegate<NSObject>
@optional
- (BOOL)AJSelectImage:(AJSelectImage*)selectImage willSelectedWithImages:(NSArray*)images;
//使用代理上传已选择图片,上传完后需要手动调用 complete(urls);
- (void)AJSelectImage:(AJSelectImage*)selectImage didSelectedWithImage:(UIImage*)image uploadComplete:(void (^)(NSString *url))complete;
- (void)AJSelectImageUploadingImage:(AJSelectImage*)selectImage;
- (void)AJSelectImageDidSelectedImage:(AJSelectImage*)selectImage;
- (void)AJSelectImageDismissViewController:(AJSelectImage*)selectImage;
@end
