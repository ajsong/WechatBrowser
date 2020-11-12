//
//  UIImage+Extend.m
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

//gif用
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
//模糊图片用
#import <Accelerate/Accelerate.h>

#pragma mark - UIImageView+Extend
@implementation UIImageView (GlobalExtend)
- (UIImage*)placeholder{
	return self.element[@"placeholder"];
}
- (void)setPlaceholder:(UIImage*)placeholder{
	self.element[@"placeholder"] = placeholder;
	CGFloat placeholderWidth = 70.f;
	if (placeholder.size.width < placeholderWidth) placeholderWidth = placeholder.size.width;
	UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((self.width-placeholderWidth)/2, (self.height-placeholderWidth)/2, placeholderWidth, placeholderWidth)];
	img.image = placeholder;
	[self addSubview:img];
}
- (BOOL)loading{
	return [self.element[@"loading"] boolValue];
}
- (void)setLoading:(BOOL)loading{
	self.element[@"loading"] = @(loading);
	if (loading) {
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		indicator.hidesWhenStopped = YES;
		[self addSubview:indicator];
		CGRect frame = indicator.frame;
		frame.origin.x = (self.width-frame.size.width)/2;
		frame.origin.y = (self.height-frame.size.height)/2;
		indicator.frame = frame;
		[indicator startAnimating];
	}
}
- (UIEdgeInsets)autoWidth{
	return UIEdgeInsetsFromString(self.element[@"autoWidth"]);
}
- (void)setAutoWidth:(UIEdgeInsets)padding{
	self.element[@"autoWidth"] = NSStringFromUIEdgeInsets(padding);
	CGFloat height = self.height;
	CGFloat iw = self.image.size.width;
	CGFloat ih = self.image.size.height;
	CGFloat nw = 0;
	CGFloat nh = 0;
	if (ih<=height) {
		nw = iw;
		nh = height;
	} else {
		nw = (iw*height)/ih;
		nh = height;
	}
	if (!UIEdgeInsetsEqualToEdgeInsets(padding, UIEdgeInsetsZero)) {
		nw += padding.left + padding.right;
	}
	self.width = nw;
}

- (UIEdgeInsets)autoHeight{
	return UIEdgeInsetsFromString(self.element[@"autoHeight"]);
}
- (void)setAutoHeight:(UIEdgeInsets)padding{
	self.element[@"autoHeight"] = NSStringFromUIEdgeInsets(padding);
	CGFloat width = self.width;
	CGFloat iw = self.image.size.width;
	CGFloat ih = self.image.size.height;
	CGFloat nw = 0;
	CGFloat nh = 0;
	if (iw<=width) {
		nw = width;
		nh = ih;
	} else {
		nw = width;
		nh = (ih*width)/iw;
	}
	if (!UIEdgeInsetsEqualToEdgeInsets(padding, UIEdgeInsetsZero)) {
		nh += padding.top + padding.bottom;
	}
	self.height = nh;
}
- (id)url{
	return self.element[@"url"];
}
- (void)setUrl:(id)url{
	[self setUrl:url placeholder:self.image completion:nil];
}
- (void)setUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion{
	[self setUrl:url placeholder:placeholder completion:completion animate:nil];
}
- (void)setUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate{
	self.clipsToBounds = YES;
	self.contentMode = UIViewContentModeScaleAspectFill;
	if (![url isset] && ![placeholder isset]) return;
	if (![url isset] && [placeholder isset]) {
		CGFloat maxImageWidth = 90*SCREEN_SCALE;
		CGFloat placeholderWidth = 70*SCREEN_SCALE;
		UIImage *subImg;
		if ([placeholder isKindOfClass:[NSString class]]) {
			subImg = [UIImage imageNamed:placeholder];
		} else if ([placeholder isKindOfClass:[NSData class]]) {
			subImg = [[UIImage alloc]initWithData:placeholder];
		} else if ([placeholder isKindOfClass:[UIImage class]]) {
			subImg = placeholder;
		}
		if (self.width <= subImg.size.width) {
			self.image = subImg;
		} else if (self.width >= maxImageWidth) {
			UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((self.width-placeholderWidth)/2, (self.height-placeholderWidth)/2, placeholderWidth, placeholderWidth)];
			img.image = subImg;
			self.image = nil;
			[self addSubview:img];
		}
		return;
	}
	if (self.element[@"image"] && self.url && [self.url isEqual:url] && [self.element[@"image"] isKindOfClass:[UIImage class]]) {
		for (UIView *subview in self.subviews) {
			if ([subview isKindOfClass:[AJProgressView class]]) {
				[subview removeFromSuperview];
			}
		}
		self.image = self.element[@"image"];
		if (completion) completion(self, self.image, self.image.data, YES, YES);
		return;
	}
	//if (self.url && [self.url isEqual:url]) return;
	if (![url isKindOfClass:[NSString class]] && ![url isKindOfClass:[NSData class]] && ![url isKindOfClass:[UIImage class]]) return;
	if ([url isKindOfClass:[NSData class]] || [url isKindOfClass:[UIImage class]]) {
		self.element[@"url"] = url;
		BOOL isData = [url isKindOfClass:[NSData class]];
		self.image = isData ? [UIImage imageWithData:url] : url;
		if (completion) completion(self, self.image, isData ? url : self.image.data, YES, NO);
		return;
	}
	NSString *imageUrl = ((NSString*)url).length ? url : @"";
	self.element[@"url"] = imageUrl;
	[Global cacheToImageView:self url:imageUrl placeholder:placeholder completion:completion animate:animate];
}
- (void)cacheImageWithUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion{
	[self setUrl:url placeholder:placeholder completion:completion animate:nil];
}
- (void)cacheImageWithUrl:(id)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate{
	[self setUrl:url placeholder:placeholder completion:completion animate:animate];
}
- (void)animationWithPlist:(NSString *)plistName duration:(NSTimeInterval)duration completion:(void (^)(void))completion{
	if (self.isAnimating) return;
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
	NSArray *plist = [[NSArray alloc]initWithContentsOfFile:plistPath];
	NSMutableArray *images = [[NSMutableArray alloc]init];
	for (NSInteger i=0; i<plist.count; i++) {
		//imageNamed: 有缓存直到程序退出(文件名)
		//imageWithContentsOfFile: 没有缓存自动释放(文件全路径)
		NSString *filePath = [[NSBundle mainBundle] pathForResource:plist[i] ofType:nil];
		UIImage *image = [UIImage imageWithContentsOfFile:filePath];
		[images addObject:image];
	}
	self.animationImages = images;
	self.animationRepeatCount = 1; //重复次数,0表示无限重复
	self.animationDuration = duration; //动画总时间
	[self startAnimating];
	[self performSelector:@selector(startAnimating) withObject:nil afterDelay:duration];
	[self performSelector:@selector(setAnimationImages:) withObject:nil afterDelay:duration]; //播放完后清除内存
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC + 0.1);
	dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion();
			});
		}
	});
}
@end


#pragma mark - UIImage+Extend
@implementation UIImage (GlobalExtend)
//加载图片,png专用
+ (UIImage*)imageFile:(NSString*)name{
	BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:FORMAT(@"%@@2x.png", name) ofType:nil]];
	if (fileExist) {
		return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:FORMAT(@"%@@2x.png", name) ofType:nil]];
	} else {
		return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:FORMAT(@"%@.png", name) ofType:nil]];
	}
}
+ (UIImage*)imageFilename:(NSString*)name{
	return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:FORMAT(@"%@", name) ofType:nil]];
}
//保存图片到相册
- (void)saveImageToPhotos{
	[Global saveImageToPhotos:self];
}
//保存图片到相册,保持图片清晰
- (void)saveToAlbumWithCompletion:(void (^)(BOOL success))completion{
	[Global saveToAlbumWithImage:self completion:completion];
}
//保存图片到Document
- (void)saveImageToDocumentWithName:(NSString*)name{
	[Global saveImageToDocument:self withName:name];
}
//保存图片到Tmp
- (void)saveImageToTmpWithName:(NSString*)name{
	[Global saveImageToTmp:self withName:name];
}
//修改图片质量,且转为NSData,只支持jpg图片
- (NSData*)imageQuality:(CGFloat)quality{
	if (self.isPNG) return UIImagePNGRepresentation(self);
	return UIImageJPEGRepresentation(self, quality);
}
- (NSData*)imageQualityHigh{
	return [self imageQuality:0.8];
}
- (NSData*)imageQualityMiddle{
	return [self imageQuality:0.5];
}
- (NSData*)imageQualityLow{
	return [self imageQuality:0.1];
}
//等比缩放
- (UIImage*)fitToSize:(CGSize)size{
	return [self fitToSize:size scale:YES fix:0.0];
}
- (UIImage*)fitToSize:(CGSize)size scale:(BOOL)scale{
	return [self fitToSize:size scale:scale fix:0.0];
}
- (UIImage*)fitToSize:(CGSize)size scale:(BOOL)scale fix:(CGFloat)fix{
	if (!self) return nil;
	if (self.isGIF) return self;
	CGFloat left = 0;
	CGFloat top = 0;
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat iw = self.size.width;
	CGFloat ih = self.size.height;
	CGFloat nw = iw;
	CGFloat nh = ih;
	if (iw<=width && ih<=height) return self;
	if (iw<=0 || ih<=0) return self;
	if (width>0 && height>0) {
		if (iw<=width && ih<=height) {
			nw = iw;
			nh = ih;
		} else {
			if (iw/ih >= width/height) {
				if (iw>width) {
					nw = width;
					nh = (ih*width)/iw;
				}
			} else {
				if (ih>height) {
					nw = (iw*height)/ih;
					nh = height;
				}
			}
		}
	} else {
		if (width==0 && height>0) {
			nw = (iw*height)/ih;
			nh = height;
		} else if (width>0 && height==0) {
			nw = width;
			nh = (ih*width)/iw;
		} else if (width==0 && height==0 && fix>0) {
			if (iw>ih) {
				nw = (iw*fix)/ih;
				nh = fix;
			} else {
				nw = fix;
				nh = (ih*fix)/iw;
			}
		}
	}
	if (width>0) {
		if (width>nw) {
			size = CGSizeMake(nw, size.height);
		} else {
			left = (width-nw)/2;
		}
	} else {
		size = CGSizeMake(nw, size.height);
	}
	if (height>0) {
		if (height>nh) {
			size = CGSizeMake(size.width, nh);
		} else {
			top = (height-nh)/2;
		}
	} else {
		size = CGSizeMake(size.width, nh);
	}
	//创建一个bitmap的context,并把它设置成为当前正在使用的context
	if (scale) {
		UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
	} else {
		UIGraphicsBeginImageContext(size);
	}
	//不失真放大
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	//绘制改变大小的图片
	[self drawInRect:CGRectMake(left, top, nw, nh)];
	//从当前context中创建一个改变大小后的图片
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	//使当前的context出堆栈
	UIGraphicsEndImageContext();
	//返回新的改变大小后的图片
	return newImage;
}
//改变图片大小
- (UIImage*)changeToSize:(CGSize)size{
	UIGraphicsBeginImageContext(size);
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}
//合并图片
- (UIImage*)addImage:(UIImage*)image{
	UIGraphicsBeginImageContext(self.size);
	[self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
	[image drawInRect:CGRectMake((self.size.width-image.size.width)/2, (self.size.height-image.size.height)/2, self.size.width, self.size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
//裁剪图片
- (UIImage*)croppedInRect:(CGRect)bounds{
	CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, bounds);
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, bounds, imageRef);
	UIImage *smallImage = [UIImage imageWithCGImage:imageRef];
	UIGraphicsEndImageContext();
	CGImageRelease(imageRef);
	return smallImage;
}
//转NSData
- (NSData*)data{
	if (!self.images) {
		NSData *data = UIImageJPEGRepresentation(self, 1.0f);
		if (!data) data =  UIImagePNGRepresentation(self);
		return data;
	} else {
		NSDictionary *userInfo = nil;
		NSMutableArray *images = [[NSMutableArray alloc]init];
		for (int i=0; i<self.images.count; i++) {
			if (![self.images[i] isKindOfClass:[NSNull class]]) {
				[images addObject:self.images[i]];
			}
		}
		size_t frameCount = images.count;
		NSTimeInterval frameDuration = self.duration / frameCount;
		NSDictionary *frameProperties = @{(__bridge NSString *)kCGImagePropertyGIFDictionary: @{(__bridge NSString *)kCGImagePropertyGIFDelayTime:@(frameDuration)}};
		NSMutableData *mutableData = [NSMutableData data];
		CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)mutableData, kUTTypeGIF, frameCount, NULL);
		NSUInteger loopCount = 1;
		NSDictionary *imageProperties = @{(__bridge NSString *)kCGImagePropertyGIFDictionary: @{(__bridge NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)}};
		CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)imageProperties);
		for (size_t idx = 0; idx < images.count; idx++) {
			CGImageDestinationAddImage(destination, [[images objectAtIndex:idx] CGImage], (__bridge CFDictionaryRef)frameProperties);
		}
		BOOL success = CGImageDestinationFinalize(destination);
		CFRelease(destination);
		if (!success) {
			NSLog(@"%@", @{NSLocalizedDescriptionKey:@"无法完成目标图像"});
		}
		return [NSData dataWithData:mutableData];
	}
}
//转base64
- (NSString*)base64{
	return [self.data base64EncodedStringWithOptions:0];
}
//转base64,带标识
- (NSString*)base64WithMark{
	NSString *mimeType = @"image/jpeg";
	if (self.isPNG) mimeType = @"image/png";
	return [NSString stringWithFormat:@"data:%@;base64,%@", mimeType, self.base64];
}
//后缀名
- (NSString*)suffix{
	if (!self) return @"";
	if (self.hasAlpha) return @"png";
	NSData *data = self.data;
	NSString *format = @"";
	uint8_t c;
	[data getBytes:&c length:1];
	switch (c) {
		case 0xFF:
			format = @"jpg";
			break;
		case 0x89:
			format = @"png";
			break;
		case 0x47:
			format = @"gif";
			break;
		case 0x49:
		case 0x4D:
			format = @"tiff";
			break;
		case 0x42:
			format = @"bmp";
			break;
		case 0x52:
			// R as RIFF for WEBP
			if ([data length] < 12) return format;
			NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
			if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
				format = @"webp";
			}
			break;
	}
	return format;
}
//图片MimeType
- (NSString*)mimeType{
	if (!self) return @"";
	if (self.hasAlpha) return @"image/png";
	NSData *data = self.data;
	NSString *format = @"";
	uint8_t c;
	[data getBytes:&c length:1];
	switch (c) {
		case 0xFF:
			format = @"image/jpeg";
			break;
		case 0x89:
			format = @"image/png";
			break;
		case 0x47:
			format = @"image/gif";
			break;
		case 0x49:
		case 0x4D:
			format = @"image/tiff";
			break;
		case 0x42:
			format = @"application/x-bmp";
			break;
		case 0x52:
			// R as RIFF for WEBP
			if ([data length] < 12) return format;
			NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
			if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
				format = @"image/webp";
			}
			break;
	}
	return format;
}
- (BOOL)hasAlpha{
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
	return (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst ||
			alpha == kCGImageAlphaPremultipliedLast || alpha == kCGImageAlphaOnly);
}
//是否PNG
- (BOOL)isPNG{
	return self.hasAlpha;
}
//是否GIF
- (BOOL)isGIF{
	return [self.suffix isEqualToString:@"gif"];
}
//将白色变成透明
void ProviderReleaseData(void *info, const void *data, size_t size){
	free((void*)data);
}
- (UIImage*)imageBlackToTransparent{
	const int imageWidth = self.size.width;
	const int imageHeight = self.size.height;
	size_t bytesPerRow = imageWidth * 4;
	uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
												 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
	CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
	//遍历像素
	int pixelNum = imageWidth * imageHeight;
	uint32_t* pCurPtr = rgbImageBuf;
	for (int i=0; i<pixelNum; i++, pCurPtr++){
		if ((*pCurPtr & 0xFFFFFF00) == 0xffffff00) { //将白色变成透明
			uint8_t* ptr = (uint8_t*)pCurPtr;
			ptr[0] = 0;
		} else {
			//改成下面的代码，会将图片转成想要的颜色
			uint8_t* ptr = (uint8_t*)pCurPtr;
			ptr[3] = 0; //0~255
			ptr[2] = 0;
			ptr[1] = 0;
		}
	}
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
	CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
										kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
										NULL, true, kCGRenderingIntentDefault);
	CGDataProviderRelease(dataProvider);
	UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	return resultUIImage;
}
//渲染颜色
- (UIImage*)renderWithTintColor:(UIColor*)color{
	CGBlendMode blendMode = kCGBlendModeOverlay;
	UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
	[color setFill];
	CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
	UIRectFill(bounds);
	[self drawInRect:bounds blendMode:blendMode alpha:1.0f];
	if (blendMode != kCGBlendModeDestinationIn) [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
	UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return tintedImage;
}
//颜色叠加
- (UIImage*)overlayWithColor:(UIColor*)color{
	UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0, self.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
	CGContextClipToMask(context, rect, self.CGImage);
	[color setFill];
	CGContextFillRect(context, rect);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
//图片去色
- (UIImage*)gray{
	CGFloat width = self.size.width;
	CGFloat height = self.size.height;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);
	if (context==NULL) return nil;
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
	UIImage *image = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
	CGContextRelease(context);
	return image;
}
//模糊图片, [image blurWithRadius:30 tintColor:[UIColor colorWithWhite:1.0 alpha:0.3] saturationDeltaFactor:1.8]
- (UIImage*)blurWithRadius:(CGFloat)radius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor{
	// check pre-conditions
	if (self.size.width < 1 || self.size.height < 1) {
		NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
		return nil;
	}
	if (!self.CGImage) {
		NSLog (@"*** error: image must be backed by a CGImage: %@", self);
		return nil;
	}
	CGRect imageRect = {CGPointZero, self.size};
	UIImage *effectImage = self;
	BOOL hasBlur = radius > __FLT_EPSILON__;
	BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
	if (hasBlur || hasSaturationChange) {
		UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
		CGContextRef effectInContext = UIGraphicsGetCurrentContext();
		CGContextScaleCTM(effectInContext, 1.0, -1.0);
		CGContextTranslateCTM(effectInContext, 0, -self.size.height);
		CGContextDrawImage(effectInContext, imageRect, self.CGImage);
		vImage_Buffer effectInBuffer;
		effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
		effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
		effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
		effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
		UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
		CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
		vImage_Buffer effectOutBuffer;
		effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
		effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
		effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
		effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
		if (hasBlur) {
			CGFloat inputRadius = radius * [[UIScreen mainScreen] scale];
			NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
			if (radius % 2 != 1) {
				radius += 1;
			}
			vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
			vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
			vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
		}
		BOOL effectImageBuffersAreSwapped = NO;
		if (hasSaturationChange) {
			CGFloat s = saturationDeltaFactor;
			CGFloat floatingPointSaturationMatrix[] = {
				0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
				0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
				0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
				0,                    0,                    0,  1,
			};
			const int32_t divisor = 256;
			NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
			int16_t saturationMatrix[matrixSize];
			for (NSUInteger i = 0; i < matrixSize; ++i) {
				saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
			}
			if (hasBlur) {
				vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
				effectImageBuffersAreSwapped = YES;
			}
			else {
				vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
			}
		}
		if (!effectImageBuffersAreSwapped) effectImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		if (effectImageBuffersAreSwapped) effectImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	// set up output context
	UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
	CGContextRef outputContext = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(outputContext, 1.0, -1.0);
	CGContextTranslateCTM(outputContext, 0, -self.size.height);
	// draw base image
	CGContextDrawImage(outputContext, imageRect, self.CGImage);
	// draw effect image
	if (hasBlur) {
		CGContextSaveGState(outputContext);
		CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
		CGContextRestoreGState(outputContext);
	}
	// add in color tint
	if (tintColor) {
		CGContextSaveGState(outputContext);
		CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
		CGContextFillRect(outputContext, imageRect);
		CGContextRestoreGState(outputContext);
	}
	// output image is ready
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return outputImage;
}
//又拍云上传图片
- (void)UploadToUpyun:(NSString*)upyunFolder completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToUpyun:upyunFolder imageName:nil completion:completion];
}
- (void)UploadToUpyun:(NSString*)upyunFolder progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToUpyun:upyunFolder imageName:nil progress:progress completion:completion];
}
//又拍云上传图片, 指定文件名(不包含后缀)
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToUpyun:upyunFolder imageName:imageName progress:nil completion:completion];
}
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	if (self.size.width<=0) {
		[ProgressHUD showError:@"图片无效"];
		return;
	}
	if (!imageName.length) imageName = [Global datetimeAndRandom];
	NSData *imageData = self.data;
	[imageData UploadToUpyun:upyunFolder imageName:imageName progress:progress completion:completion];
}
//七牛上传图片
- (void)UploadToQiniu:(NSString*)token completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToQiniu:token imageName:nil progress:nil completion:completion];
}
- (void)UploadToQiniu:(NSString*)token progress:(void (^)(NSProgress *progress))progress completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToQiniu:token imageName:nil progress:progress completion:completion];
}
//七牛上传图片, 指定文件名(不包含后缀)
- (void)UploadToQiniu:(NSString*)token imageName:(NSString*)imageName completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToQiniu:token imageName:imageName progress:nil completion:completion];
}
- (void)UploadToQiniu:(NSString*)token imageName:(NSString*)imageName progress:(void (^)(NSProgress *progress))progress completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	if (self.size.width<=0) {
		[ProgressHUD showError:@"图片无效"];
		return;
	}
	if (!imageName.length) imageName = [Global datetimeAndRandom];
	NSData *imageData = self.data;
	[imageData UploadToQiniu:token imageName:imageName progress:progress completion:completion];
}
@end
