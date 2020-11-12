//
//  Global.m
//
//  Created by ajsong on 2014-9-1.
//  Copyright (c) 2014 @jsong. All rights reserved.
//

#import "Global.h"
#import "sys/utsname.h" //设备类型
#import <AVFoundation/AVFoundation.h> //声音
#import <AssetsLibrary/ALAssetsLibrary.h> //相册
#import <LocalAuthentication/LocalAuthentication.h> //Touch ID
#import <MessageUI/MessageUI.h> //发短信
#import "SDWebImagePrefetcher.h"
#import <MapKit/MapKit.h> //调起地图

//extern NSString *CTSettingCopyMyPhoneNumber();

#pragma mark - AFNetWorking单例
static AFNetwork *networkManager = nil;
@interface AFNetwork()
@property (nonatomic,strong) AFHTTPSessionManager *manager;
@end
@implementation AFNetwork
+ (AFNetwork *)shared{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		networkManager = [[AFNetwork alloc] init];
		networkManager.manager = [AFHTTPSessionManager manager];
		networkManager.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		//添加安全策略，及允许无效证书访问
		AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
		security.validatesDomainName = NO;
		security.allowInvalidCertificates = YES;
		networkManager.manager.securityPolicy = security;
	});
	return networkManager;
}
@end


@implementation Global

#pragma mark - 系统
//获取当前显示的视图
+ (UIViewController*)currentController{
	return KEYWINDOW.currentController;
}

//判断是否竖屏
+ (BOOL)verticalScreen:(UIViewController*)view{
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation==UIInterfaceOrientationPortrait || orientation==UIInterfaceOrientationPortraitUpsideDown) {
		//portrait
		return YES;
	} else {
		//landscape
		return NO;
	}
}

//是否新版本
+ (BOOL)isNewVersion{
	NSInteger version = [[[@"app_version" getUserDefaultsString] replace:@"." to:@""]integerValue];
	[@"app_version" setUserDefaultsWithData:APP_VERSION];
	if (version <= 0) return YES;
	return version > [[APP_VERSION replace:@"." to:@""]integerValue];
}

//设备类型
+ (NSString*)deviceString{
	struct utsname systemInfo;
	uname(&systemInfo);
	NSString *string = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	return string;
}
+ (NSString*)device{
	NSString *device = [Global deviceString];
	if ([device isEqualToString:@"iPhone3,1"]) return @"iPhone4";
	if ([device isEqualToString:@"iPhone4,1"]) return @"iPhone4s";
	if ([device isEqualToString:@"iPhone5,2"]) return @"iPhone5";
	if ([device isEqualToString:@"iPhone6,1"]) return @"iPhone5s";
	if ([device isEqualToString:@"iPhone7,2"]) return @"iPhone6";
	if ([device isEqualToString:@"iPhone7,1"]) return @"iPhone6Plus";
	if ([device isEqualToString:@"iPhone8,1"]) return @"iPhone6s";
	if ([device isEqualToString:@"iPhone8,2"]) return @"iPhone6sPlus";
	if ([device isEqualToString:@"iPad2,1"] || [device isEqualToString:@"iPad2,2"] || [device isEqualToString:@"iPad2,3"]) return @"iPad2";
	if ([device isEqualToString:@"i386"]) return @"Simulator";
	if ([device isEqualToString:@"x86_64"]) return @"Simulator";
	return device;
}

//获取本机号码
+ (NSString*)getTelephonyNumber{
	//return CTSettingCopyMyPhoneNumber();
	return @"";
}

//复制到粘贴板
+ (void)copyString:(NSString*)string{
	UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
	pasteBoard.string = string;
}

//获取本地储存
+ (id)getUserDefaults:(NSString*)key{
	return [key getUserDefaults];
}
+ (NSString*)getUserDefaultsString:(NSString*)key{
	return [key getUserDefaultsString];
}
+ (NSInteger)getUserDefaultsInteger:(NSString*)key{
	return [key getUserDefaultsInteger];
}
+ (CGFloat)getUserDefaultsFloat:(NSString*)key{
	return [key getUserDefaultsFloat];
}
+ (BOOL)getUserDefaultsBool:(NSString*)key{
	return [key getUserDefaultsBool];
}
+ (NSMutableArray*)getUserDefaultsArray:(NSString*)key{
	return [key getUserDefaultsArray];
}
+ (NSMutableDictionary*)getUserDefaultsDictionary:(NSString*)key{
	return [key getUserDefaultsDictionary];
}

//保存到本地储存
+ (void)setUserDefaults:(NSString*)key data:(id)data{
	[key setUserDefaultsWithData:data];
}

//删除本地储存
+ (void)deleteUserDefaults:(NSString*)key{
	[key deleteUserDefaults];
}

//是否越狱
+ (BOOL)isJailbroken{
	NSString *cydiaPath = @"/Applications/Cydia.app";
	NSString *aptPath = @"/private/var/lib/apt/";
	if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath] || [[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
		return YES;
	}
	return NO;
}

#pragma mark - 导航
//设置状态栏颜色需在Info.plist设置 View controller-based status bar appearance : NO
//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//获取状态栏
+ (UIView*)statusBar{
	UIView *statusBar = nil;
	NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
	NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	id object = [UIApplication sharedApplication];
	if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
	return statusBar;
}

//状态栏高度
+ (CGFloat)statusBarHeight{
	return [UIApplication sharedApplication].statusBarFrame.size.height;
}

//隐藏状态栏
+ (void)statusBarHidden:(BOOL)hidden animated:(BOOL)animated{
	UIViewController *controller = [Global currentController];
	if ([controller respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
		//!IOS6
		[controller performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
		//setNeedsStatusBarAppearanceUpdate 在push或present的controller里调用才起作用
		/*
		 //需在view里面增加这个方法
		 -(BOOL)prefersStatusBarHidden{
		 return YES; //隐藏为YES,显示为NO
		 }
		 */
	}
	//BOOL isFullScreen = [UIApplication sharedApplication].statusBarHidden;
	if (animated) {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationSlide];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden];
	}
}

//状态栏文字颜色
+ (void)statusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated{
	[[UIApplication sharedApplication] setStatusBarStyle:style animated:animated];
}

//导航栏+状态栏高度
+ (CGFloat)navigationAndStatusBarHeight{
	UIViewController *controller = [Global currentController];
	CGFloat height = [Global statusBarHeight];
	return controller.navigationController.navigationBar.frame.size.height + height;
}

//导航栏高度
+ (CGFloat)navigationHeight{
	UIViewController *controller = [Global currentController];
	if (!controller.navigationController) return 0;
	return controller.navigationController.navigationBar.frame.size.height;
}

//导航栏背景图
+ (void)navigationBackgroundImage:(UIImage *)image{
	UIViewController *controller = [Global currentController];
	if (!controller.navigationController) return;
	[controller.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

//导航栏背景透明(需要一张透明图片)
+ (void)navigationTranslucent{
	UIViewController *controller = [Global currentController];
	if (!controller.navigationController) return;
	controller.navigationController.navigationBar.translucent = YES;
	[Global navigationBackgroundImage:[UIImage imageNamed:@"space"]];
}

#pragma mark - 颜色
//网页颜色转UIColor
+ (UIColor*)colorFromHexRGB:(NSString*)colorString{
	return [Global colorFromHexRGB:colorString alpha:1.f];
}

//网页颜色转UIColor+透明度
+ (UIColor*)colorFromHexRGB:(NSString*)colorString alpha:(CGFloat)alpha{
	if (colorString==nil || !colorString.length) return nil;
	if ([colorString hasPrefix:@"#"]) colorString = [colorString substringFromIndex:1];
	if (colorString.length==3) {
		NSString *red = [colorString substringWithRange:NSMakeRange(0, 1)];
		NSString *green = [colorString substringWithRange:NSMakeRange(1, 1)];
		NSString *blue = [colorString substringWithRange:NSMakeRange(2, 1)];
		colorString = [NSString stringWithFormat:@"%@%@%@%@%@%@", red, red, green, green, blue, blue];
	}
	UIColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	NSScanner *scanner = [NSScanner scannerWithString:colorString];
	(void)[scanner scanHexInt:&colorCode];
	redByte = (unsigned char)(colorCode >> 16);
	greenByte = (unsigned char)(colorCode >> 8);
	blueByte = (unsigned char)(colorCode);
	result = [UIColor colorWithRed:(CGFloat)redByte/0xff green:(CGFloat)greenByte/0xff blue:(CGFloat)blueByte/0xff alpha:alpha];
	return result;
}

//UIImage转UIColor
+ (UIColor*)colorFromImage:(UIImage*)img{
	return [UIColor colorWithPatternImage:img];
}

//UIImage转UIColor, 并设置宽高
+ (UIColor*)colorFromImage:(UIImage*)img size:(CGSize)size{
	UIGraphicsBeginImageContext(size);
	[img drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return [UIColor colorWithPatternImage:newImage];
}

//获取两个颜色之间, value偏向color2的百分比
+ (UIColor*)colorBetweenColor1:(UIColor*)color1 color2:(UIColor*)color2 percent:(CGFloat)percent{
	percent = MIN(MAX(percent, 0.0), 1.0);
	CGFloat red1 = 0.0, green1 = 0.0, blue1 = 0.0, alpha1 = 0.0;
	[color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
	CGFloat red2 = 0.0, green2 = 0.0, blue2 = 0.0, alpha2 = 0.0;
	[color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
	return [UIColor colorWithRed:(red2-red1) * percent + red1
						   green:(green2-green1) * percent + green1
							blue:(blue2-blue1) * percent + blue1
						   alpha:(alpha2-alpha1) * percent + alpha1];
}

//颜色渐变, 0:从上到下, 1:从左到右, 2:左上到右下, 3:右上到左下
+ (UIImage*)gradientColors:(NSArray*)colors gradientType:(NSInteger)gradientType size:(CGSize)size{
	NSMutableArray *ar = [[NSMutableArray alloc]init];
	for (UIColor *color in colors) {
		[ar addObject:(id)color.CGColor];
	}
	UIGraphicsBeginImageContextWithOptions(size, YES, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGColorSpaceRef colorSpace = CGColorGetColorSpace([colors.lastObject CGColor]);
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
	CGPoint start = CGPointMake(0.0, 0.0);
	CGPoint end = CGPointMake(0.0, 0.0);
	switch (gradientType) {
		case 0:
			start = CGPointMake(0.0, 0.0);
			end = CGPointMake(0.0, size.height);
			break;
		case 1:
			start = CGPointMake(0.0, 0.0);
			end = CGPointMake(size.width, 0.0);
			break;
		case 2:
			start = CGPointMake(0.0, 0.0);
			end = CGPointMake(size.width, size.height);
			break;
		case 3:
			start = CGPointMake(size.width, 0.0);
			end = CGPointMake(0.0, size.height);
			break;
		default:
			break;
	}
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	CGGradientRelease(gradient);
	CGContextRestoreGState(context);
	//CGColorSpaceRelease(colorSpace);
	UIGraphicsEndImageContext();
	return image;
}

#pragma mark - 图片
//快速加载图片(待验证)
+ (UIImage*)decodeImage:(UIImage*)image{
	if(image==nil) return nil;
	UIGraphicsBeginImageContext(image.size);
	{
		[image drawAtPoint:CGPointMake(0, 0)];
		image = UIGraphicsGetImageFromCurrentImageContext();
	}
	UIGraphicsEndImageContext();
	return image;
}

//把图片指定颜色变透明，colorArray:[NSArray arrayWithObjects:@"250",@"255",@"250",@"255",@"250",@"255",nil]
+ (UIImage*)maskingImage:(UIImage*)image colorArray:(NSArray*)color{
	CGImageRef ref = image.CGImage;
	const CGFloat colorMasking[6] = {250,255,250,255,250,255};
	//for (int i = 0; i<6; i++) colorMasking[i] = [color[i] floatValue]; //被遮蔽(透明)的颜色
	CGImageRef imageRef = CGImageCreateWithMaskingColors(ref, colorMasking);
	imageRef = [self AddAlphaChannel:imageRef];
	return [UIImage imageWithCGImage:imageRef];
}
+ (CGImageRef)AddAlphaChannel:(CGImageRef)image{
	if ( CGImageGetAlphaInfo(image) == kCGImageAlphaNone || CGImageGetAlphaInfo(image) == kCGImageAlphaNoneSkipFirst || CGImageGetAlphaInfo(image) == kCGImageAlphaNoneSkipLast ) {
		size_t width = CGImageGetWidth(image);
		size_t height = CGImageGetHeight(image);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef offScreenContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
		CGColorSpaceRelease(colorSpace);
		CGImageRef retVal = NULL;
		if (offScreenContext != NULL) {
			CGContextDrawImage(offScreenContext, CGRectMake(0, 0, width, height), image);
			retVal = CGBitmapContextCreateImage(offScreenContext);
			CGContextRelease(offScreenContext);
		}
		return retVal;
	}
	return image;
}

//保存图片到相册
+ (void)saveImageToPhotos:(UIImage*)image{
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
	NSString *mst = nil;
	NSString *msg = nil;
	if(error != NULL){
		mst = @"保存失败";
		msg = [NSString stringWithFormat:@"%@",error];
	}else{
		mst = @"保存成功";
		msg = @"图片已保存到手机相册";
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:mst message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
	[alert show];
}

//保存图片到相册,保持图片清晰
+ (void)saveToAlbumWithImage:(UIImage*)image completion:(void (^)(BOOL success))completion{
	NSData *imageData = UIImagePNGRepresentation(image);
	if (!imageData.length) imageData = UIImageJPEGRepresentation(image, 1.0f);
	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
	[assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error){
		BOOL success = YES;
		if (error) success = NO;
		if (completion) completion(success);
	}];
}

//保存图片到Document
+ (void)saveImageToDocument:(UIImage*)image withName:(NSString*)imageName{
	NSData *imageData = UIImagePNGRepresentation(image);
	if (!imageData.length) imageData = UIImageJPEGRepresentation(image, 1.0f);
	NSString *filePath = [Global getFilePathFromDocument:imageName];
	[imageData writeToFile:filePath atomically:NO];
}

//保存图片到Tmp
+ (void)saveImageToTmp:(UIImage*)image withName:(NSString*)imageName{
	NSData *imageData = UIImagePNGRepresentation(image);
	if (!imageData.length) imageData = UIImageJPEGRepresentation(image, 1.0f);
	NSString *filePath = [Global getFilePathFromTmp:imageName];
	[imageData writeToFile:filePath atomically:NO];
}

//获取图片
+ (UIImage*)imageFile:(NSString*)imageName{
	return [UIImage imageWithContentsOfFile:imageName];
}

//从Document文件夹获取图片
+ (UIImage*)imageFileFromDocument:(NSString*)imageName{
	NSString *imagePath = [Global getFilePathFromDocument:imageName];
	return [UIImage imageWithContentsOfFile:imagePath];
}

//从Tmp文件夹获取图片
+ (UIImage*)imageFileFromTmp:(NSString*)imageName{
	NSString *imagePath = [Global getFilePathFromTmp:imageName];
	return [UIImage imageWithContentsOfFile:imagePath];
}

//模糊图片, 例 [Global blurImageWith:image radius:30 tintColor:[UIColor colorWithWhite:1.0 alpha:0.3] saturationDeltaFactor:1.8];
+ (UIImage*)blurImageWith:(UIImage*)image radius:(CGFloat)radius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor{
	return [image blurWithRadius:radius tintColor:tintColor saturationDeltaFactor:saturationDeltaFactor];
}

//角度旋转图片
+ (UIImage*)rotatedImage:(UIImage*)image degrees:(CGFloat)degrees{
	UIView *rotatedViewBox = [[UIView alloc]initWithFrame:CGRectMake(0, 0, image.size.height, image.size.width)];
	CGAffineTransform t = CGAffineTransformMakeRotation((M_PI*(degrees)/180.0));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, rotatedSize.width/2.0f, rotatedSize.height/2.0f);
	CGContextRotateCTM(context, (M_PI*(degrees)/180.0));
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(-image.size.height/2.0f, -image.size.width/2.0f, image.size.height, image.size.width), image.CGImage);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

//旋转图片
+ (UIImage*)rotatedImage:(UIImage*)image rotate:(CGFloat)rotate{
	CGAffineTransform t = CGAffineTransformMakeRotation(rotate);
	CGRect sizeRect = (CGRect){.size = image.size};
	CGRect destRect = CGRectApplyAffineTransform(sizeRect, t);
	CGSize rotatedSize = destRect.size;
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, rotatedSize.width/2.0f, rotatedSize.height/2.0f);
	CGContextRotateCTM(context, rotate);
	[image drawInRect:CGRectMake(-image.size.width/2.0f, -image.size.height/2.0f, image.size.width, image.size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

//去色
+ (UIImage*)grayImage:(UIImage*)image{
	int type = 1;
	CGImageRef imageRef = image.CGImage;
	size_t width  = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);
	size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
	size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
	size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	bool shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
	CGColorRenderingIntent intent = CGImageGetRenderingIntent(imageRef);
	CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
	CFDataRef data = CGDataProviderCopyData(dataProvider);
	UInt8 *buffer = (UInt8*)CFDataGetBytePtr(data);
	NSUInteger x, y;
	for (y = 0; y < height; y++) {
		for (x = 0; x < width; x++) {
			UInt8 *tmp;
			tmp = buffer + y * bytesPerRow + x * 4;
			UInt8 red,green,blue;
			red = *(tmp + 0);
			green = *(tmp + 1);
			blue = *(tmp + 2);
			UInt8 brightness;
			switch (type) {
				case 1: //黑白
					brightness = (77 * red + 28 * green + 151 * blue) / 256;
					*(tmp + 0) = brightness;
					*(tmp + 1) = brightness;
					*(tmp + 2) = brightness;
					break;
				case 2:
					*(tmp + 0) = red;
					*(tmp + 1) = green * 0.7;
					*(tmp + 2) = blue * 0.4;
					break;
				case 3: //反色
					*(tmp + 0) = 255 - red;
					*(tmp + 1) = 255 - green;
					*(tmp + 2) = 255 - blue;
					break;
				default: //正常
					*(tmp + 0) = red;
					*(tmp + 1) = green;
					*(tmp + 2) = blue;
					break;
			}
		}
	}
	CFDataRef effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
	CGDataProviderRef effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
	CGImageRef effectedCgImage = CGImageCreate(width, height,
											   bitsPerComponent, bitsPerPixel, bytesPerRow,
											   colorSpace, bitmapInfo, effectedDataProvider,
											   NULL, shouldInterpolate, intent);
	UIImage *effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
	CGImageRelease(effectedCgImage);
	CFRelease(effectedDataProvider);
	CFRelease(effectedData);
	CFRelease(data);
	return effectedImage;
}

//动画UIImageView
+ (void)animateImage:(UIImageView*)imageView duration:(NSTimeInterval)time repeat:(NSInteger)repeat images:(UIImage*)image,...{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:image];
	id obj; va_list args; va_start(args, image);
	while ((obj = va_arg(args, id))) {
		[array addObject:obj];
	}
	va_end(args);
	imageView.animationImages = [NSArray arrayWithArray:array]; //图片帧
	imageView.animationDuration = time; //动画时间
	imageView.animationRepeatCount = repeat; //重复次数,0表示无限重复
	[imageView startAnimating]; //开始动画
}

#pragma mark - FSO
//获取完整文件名(带后缀名)
+ (NSString*)getFileFullname:(NSString*)filePath{
	return [filePath getFullFilename];
}

//获取文件名(不带后缀名)
+ (NSString*)getFilename:(NSString*)filePath{
	return [filePath getFilename];
}

//获取后缀名
+ (NSString*)getSuffix:(NSString*)filePath{
	return [filePath getSuffix];
}

//获取Document文件夹路径
+ (NSString*)getDocument{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

//获取Tmp文件夹路径
+ (NSString*)getTmp{
	return NSTemporaryDirectory();
}

//获取Library/Caches文件夹路径
+ (NSString*)getCaches{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	return [path objectAtIndex:0];
}

//从Document获取文件路径
+ (NSString*)getFilePathFromDocument:(NSString*)filename{
	NSString *documentPath = [Global getDocument];
	return [documentPath stringByAppendingPathComponent:filename];
}

//从Tmp获取文件路径
+ (NSString*)getFilePathFromTmp:(NSString*)filename{
	NSString *tempPath = NSTemporaryDirectory();
	return [tempPath stringByAppendingPathComponent:filename];
}

//从Library/Caches获取文件路径
+ (NSString*)getFilePathFromCaches:(NSString*)filename{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [path objectAtIndex:0];
	return [cachePath stringByAppendingPathComponent:filename];
}

//从APP内部获取文件
+ (NSString*)getFilePathFromAPP:(NSString*)filename{
	return [[NSBundle mainBundle] pathForResource:filename ofType:nil];
}

//获取指定文件的内容
+ (NSData*)getFileData:(NSString*)filePath{
	return [NSData dataWithContentsOfFile:filePath];
}

//从Document获取指定文件的内容
+ (NSData*)getFileDataFromDocument:(NSString*)filename{
	return [Global getFileData:[Global getFilePathFromDocument:filename]];
}

//从Tmp获取指定文件的内容
+ (NSData*)getFileDataFromTmp:(NSString*)filename{
	return [Global getFileData:[Global getFilePathFromTmp:filename]];
}

//从Library/Caches获取指定文件的内容
+ (NSData*)getFileDataFromCaches:(NSString*)filename{
	return [Global getFileData:[Global getFilePathFromCaches:filename]];
}

//获取指定文件的字符串内容
+ (NSString*)getFileText:(NSString*)filePath{
	NSFileHandle* fh = [NSFileHandle fileHandleForReadingAtPath:filePath];
	NSData *data = [fh readDataToEndOfFile];
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	//return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

//从Document获取指定文件的字符串内容
+ (NSString*)getFileTextFromDocument:(NSString*)filename{
	return [Global getFileText:[Global getFilePathFromDocument:filename]];
}

//从Tmp获取指定文件的字符串内容
+ (NSString*)getFileTextFromTmp:(NSString*)filename{
	return [Global getFileText:[Global getFilePathFromTmp:filename]];
}

//从Library/Caches获取指定文件的字符串内容
+ (NSString*)getFileTextFromCaches:(NSString*)filename{
	return [Global getFileText:[Global getFilePathFromCaches:filename]];
}

//获取文件列表
+ (NSArray*)getFileList:(NSString*)folderPath{
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
}

//获取Document文件列表
+ (NSArray*)getFileListFromDocument{
	return [Global getFileList:[Global getDocument]];
}

//获取Document文件列表
+ (NSArray*)getFileListFromTmp{
	return [Global getFileList:[Global getTmp]];
}

//获取Document文件列表
+ (NSArray*)getFileListFromCaches{
	return [Global getFileList:[Global getCaches]];
}

//判断文件是否存在
+ (BOOL)fileExist:(NSString*)filePath{
	return [[NSFileManager defaultManager] fileExistsAtPath:[filePath replace:@"\\" to:@"/"]];
}

//判断Document里某文件是否存在
+ (BOOL)fileExistFromDocument:(NSString*)filename{
	return [[NSFileManager defaultManager] fileExistsAtPath:[Global getFilePathFromDocument:filename]];
}

//判断Document里某文件是否存在
+ (BOOL)fileExistFromTmp:(NSString*)filename{
	return [[NSFileManager defaultManager] fileExistsAtPath:[Global getFilePathFromTmp:filename]];
}

//判断Document里某文件是否存在
+ (BOOL)fileExistFromCaches:(NSString*)filename{
	return [[NSFileManager defaultManager] fileExistsAtPath:[Global getFilePathFromCaches:filename]];
}

//判断APP里某文件是否存在
+ (BOOL)fileExistFromAPP:(NSString*)filename{
	return [[NSFileManager defaultManager] fileExistsAtPath:[Global getFilePathFromAPP:filename]];
}

//判断文件夹是否存在
+ (BOOL)folderExist:(NSString*)folderPath{
	folderPath = [folderPath replace:@"\\" to:@"/"];
	BOOL isDir;
	BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];
	return (existed==YES && isDir==YES);
}

//生成文件夹,支持多级生成
+ (BOOL)makeDir:(NSString*)folderPath{
	folderPath = [folderPath replace:@"\\" to:@"/"];
	if (![Global folderExist:folderPath]) {
		NSError *error;
		BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
		if (error) NSLog(@"%@", error);
		return result;
	}
	return YES;
}

//在Document生成文件夹
+ (BOOL)makeDirFromDocument:(NSString*)foldername{
	foldername = [foldername replace:@"\\" to:@"/"];
	NSString *path = [Global getFilePathFromDocument:foldername];
	return [Global makeDir:path];
}

//在Tmp生成文件夹
+ (BOOL)makeDirFromTmp:(NSString*)foldername{
	foldername = [foldername replace:@"\\" to:@"/"];
	NSString *path = [Global getFilePathFromTmp:foldername];
	return [Global makeDir:path];
}

//在Library/Caches生成文件夹
+ (BOOL)makeDirFromCaches:(NSString*)foldername{
	foldername = [foldername replace:@"\\" to:@"/"];
	NSString *path = [Global getFilePathFromCaches:foldername];
	return [Global makeDir:path];
}

//清空文件夹, killme:是否同时删除自己
+ (void)deleteDir:(NSString*)folderPath killme:(BOOL)kill{
	folderPath = [folderPath replace:@"\\" to:@"/"];
	if ([Global folderExist:folderPath]) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *contents = [fileManager contentsOfDirectoryAtPath:folderPath error:NULL];
		NSEnumerator *e = [contents objectEnumerator];
		NSString *filename;
		while ((filename = [e nextObject])) {
			[fileManager removeItemAtPath:[folderPath stringByAppendingPathComponent:filename] error:NULL];
		}
		if (kill) [fileManager removeItemAtPath:folderPath error:nil];
	}
}

//在Document清空文件夹
+ (void)deleteDirFromDocument:(NSString*)foldername killme:(BOOL)kill{
	[Global deleteDir:[Global getFilePathFromDocument:foldername] killme:kill];
}

//在Tmp清空文件夹
+ (void)deleteDirFromTmp:(NSString*)foldername killme:(BOOL)kill{
	[Global deleteDir:[Global getFilePathFromTmp:foldername] killme:kill];
}

//在Library/Caches清空文件夹
+ (void)deleteDirFromCaches:(NSString*)foldername killme:(BOOL)kill{
	[Global deleteDir:[Global getFilePathFromCaches:foldername] killme:kill];
}

//生成文件, NSData内容
+ (BOOL)saveFile:(NSString*)filePath data:(NSData*)fileData{
	if ([Global fileExist:filePath]) return YES;
	NSArray *array = [filePath split:@"/"];
	[Global makeDir:[filePath replace:array[array.count-1] to:@""]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager createFileAtPath:filePath contents:fileData attributes:nil];
}

//在Document生成文件, NSData内容
+ (BOOL)saveFileToDocument:(NSString*)filename data:(NSData*)fileData{
	return [Global saveFile:[Global getFilePathFromDocument:filename] data:fileData];
}

//在Tmp生成文件, NSData内容
+ (BOOL)saveFileToTmp:(NSString*)filename data:(NSData*)fileData{
	return [Global saveFile:[Global getFilePathFromTmp:filename] data:fileData];
}

//在Library/Caches生成文件, NSData内容
+ (BOOL)saveFileToCaches:(NSString*)filename data:(NSData*)fileData{
	return [Global saveFile:[Global getFilePathFromCaches:filename] data:fileData];
}

//生成文件, NSString内容
+ (BOOL)saveFile:(NSString*)filePath content:(NSString*)content new:(BOOL)flag{
	if (![Global fileExist:filePath] || flag) {
		NSArray *array = [filePath split:@"/"];
		[Global makeDir:[filePath replace:array[array.count-1] to:@""]];
		return [[content dataUsingEncoding:NSUTF8StringEncoding] writeToFile:filePath atomically:YES];
	}
	NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
	//找到并定位到outFile的末尾位置(在此后追加文件)
	[outFile seekToEndOfFile];
	//读取inFile并且将其内容写到outFile中
	NSData *buffer = [content dataUsingEncoding:NSUTF8StringEncoding];
	[outFile writeData:buffer];
	[outFile closeFile];
	return YES;
}

//在Document生成文件, NSString内容
+ (BOOL)saveFileToDocument:(NSString*)filename content:(NSString*)content new:(BOOL)flag{
	return [Global saveFile:[Global getFilePathFromDocument:filename] content:content new:flag];
}

//在Tmp生成文件, NSString内容
+ (BOOL)saveFileToTmp:(NSString*)filename content:(NSString*)content new:(BOOL)flag{
	return [Global saveFile:[Global getFilePathFromTmp:filename] content:content new:flag];
}

//在Library/Caches生成文件, NSString内容
+ (BOOL)saveFileToCaches:(NSString*)filename content:(NSString*)content new:(BOOL)flag{
	return [Global saveFile:[Global getFilePathFromCaches:filename] content:content new:flag];
}

//修改文件夹名
+ (void)renameFolder:(NSString*)folderPath to:(NSString*)newName{
	[Global renameFile:folderPath to:newName];
}

//修改文件名
+ (void)renameFile:(NSString*)filePath to:(NSString*)newName{
	if ([Global fileExist:filePath]) {
		NSArray *pathArr = [filePath split:@"/"];
		NSString *newPath = [NSString stringWithFormat:@"%@%@", [filePath replace:pathArr.lastObject to:@""], newName];
		[[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newPath error:nil];
	}
}

//删除文件
+ (BOOL)deleteFile:(NSString*)filePath{
	if ([Global fileExist:filePath]) {
		return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
	}
	return NO;
}

//在Document删除文件
+ (BOOL)deleteFileFromDocument:(NSString*)filename{
	return [Global deleteFile:[Global getFilePathFromDocument:filename]];
}

//在Tmp删除文件
+ (BOOL)deleteFileFromTmp:(NSString*)filename{
	return [Global deleteFile:[Global getFilePathFromTmp:filename]];
}

//在Library/Caches删除文件
+ (BOOL)deleteFileFromCaches:(NSString*)filename{
	return [Global deleteFile:[Global getFilePathFromCaches:filename]];
}

//获取文件大小
+ (long long)fileSize:(NSString*)filePath{
	if ([Global fileExist:filePath]) {
		NSFileManager *manager = [NSFileManager defaultManager];
		NSDictionary *attributes = [manager attributesOfItemAtPath:filePath error:nil];
		//NSLog(@"%@",attributes);
		NSNumber *fileSize = [attributes objectForKey:NSFileSize];
		return [fileSize longLongValue];
	}
	return 0;
}

//获取目录所占空间大小
+ (long long)folderSize:(NSString*)folderPath{
	if (![Global fileExist:folderPath]) return 0;
	NSFileManager *manager = [NSFileManager defaultManager];
	NSEnumerator *childFiles = [[manager subpathsAtPath:folderPath] objectEnumerator];
	NSString *filename;
	long long size = 0;
	while ((filename = [childFiles nextObject]) != nil){
		NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:filename];
		size += [Global fileSize:fileAbsolutePath];
	}
	return size;
}

//格式化文件大小, %.2f 保留两位小数, %02d 不足两位即前面补0
+ (NSString*)formatSize:(long long)size unit:(NSString*)unit{
	if (!unit.length) {
		if (size>0) {
			if (size>1073741824) {
				return [NSString stringWithFormat:@"%0.2fGB", (CGFloat)size/1073741824];
			} else if (size>1048576) {
				return [NSString stringWithFormat:@"%0.2fMB", (CGFloat)size/1048576];
			} else if (size>1024) {
				return [NSString stringWithFormat:@"%0.0fKB", (CGFloat)size/1024];
			} else {
				return [NSString stringWithFormat:@"%llubytes", size];
			}
		}
	} else {
		if (size>0) {
			NSArray *unitName = @[@"GB", @"MB", @"KB"];
			NSInteger index = [unitName indexOfObject:unit.uppercaseString];
			switch (index) {
				case 0:
					return [NSString stringWithFormat:@"%0.2fGB", (CGFloat)size/1073741824];
					break;
				case 1:
					return [NSString stringWithFormat:@"%0.2fMB", (CGFloat)size/1048576];
					break;
				case 2:
					return [NSString stringWithFormat:@"%0.0fKB", (CGFloat)size/1024];
					break;
				default:
					return [NSString stringWithFormat:@"%llubytes", size];
					break;
			}
		}
	}
	return @"0KB";
}

//获取文件(夹)属性
+ (NSMutableDictionary*)fileAttributes:(NSString*)filePath{
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
	if ([Global fileExist:filePath]) {
		NSError *error = nil;
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
		if (fileAttributes != nil) {
			//id fileType = [fileAttributes objectForKey:NSFileType];
			NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
			NSString *fileOwner = [fileAttributes objectForKey:NSFileOwnerAccountName];
			NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
			NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
			if ([fileSize floatValue]) { //单位字节
				[attributes setObject:fileSize forKey:@"size"]; //[fileSize unsignedLongLongValue]
			}
			if (fileOwner) {
				[attributes setObject:fileOwner forKey:@"owner"];
			}
			if (fileModDate) {
				[attributes setObject:fileModDate forKey:@"moddate"];
			}
			if (fileCreateDate) {
				[attributes setObject:fileCreateDate forKey:@"createdate"];
			}
		}
	}
	return attributes;
}

//获取本地Array类型Plist文件
+ (NSMutableArray*)getPlistArray:(NSString*)filePath{
	return [[NSMutableArray alloc]initWithContentsOfFile:filePath];
}

//获取本地Dictionary类型Plist文件
+ (NSMutableDictionary*)getPlistDictionary:(NSString*)filePath{
	return [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
}

//从Tmp获取Array类型Plist文件
+ (NSMutableArray*)getPlistArrayFromTmp:(NSString*)filename{
	return [[NSMutableArray alloc]initWithContentsOfFile:[Global getFilePathFromTmp:filename]];
}

//从Tmp获取Dictionary类型Plist文件
+ (NSMutableDictionary*)getPlistDictionaryFromTmp:(NSString*)filename{
	return [[NSMutableDictionary alloc]initWithContentsOfFile:[Global getFilePathFromTmp:filename]];
}

//保存Plist文件
+ (BOOL)savePlist:(NSString*)filePath data:(id)data{
	NSError *error;
	NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:data
																   format:NSPropertyListXMLFormat_v1_0
																  options:0
																	error:&error];
	if (plistData) {
		return [plistData writeToFile:filePath atomically:YES];
	} else {
		NSLog(@"%@", error);
		return NO;
	}
}

//保存Plist文件到Document
+ (BOOL)savePlistToDocument:(NSString*)filename data:(id)data{
	NSString *filePath = [Global getFilePathFromDocument:[NSString stringWithFormat:@"%@.plist",filename]];
	return [Global savePlist:filePath data:data];
}

//保存Plist文件到Tmp
+ (BOOL)savePlistToTmp:(NSString*)filename data:(id)data{
	NSString *filePath = [Global getFilePathFromTmp:[NSString stringWithFormat:@"%@.plist",filename]];
	return [Global savePlist:filePath data:data];
}

//保存Plist文件到Caches
+ (BOOL)savePlistToCaches:(NSString*)filename data:(id)data{
	NSString *filePath = [Global getFilePathFromCaches:[NSString stringWithFormat:@"%@.plist",filename]];
	return [Global savePlist:filePath data:data];
}

#pragma mark - NETWORK
//GET提交(不执行返回操作)
+ (void)get:(NSString*)url{
	[Global get:url data:nil completion:nil fail:nil];
}

//GET提交
+ (void)get:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	[Global get:url data:data options:nil timeout:5 completion:completion fail:fail];
}
+ (void)get:(NSString*)url data:(NSDictionary*)data options:(NSDictionary*)options completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	[Global get:url data:data options:options timeout:5 completion:completion fail:fail];
}

//POST提交
+ (void)post:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	[Global post:url data:data timeout:5 completion:completion fail:fail];
}

//上传提交
+ (void)upload:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	[Global upload:url data:data options:nil timeout:30 progress:nil completion:completion fail:fail];
}
+ (void)upload:(NSString*)url data:(NSDictionary*)data progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	[Global upload:url data:data options:nil timeout:30 progress:progress completion:completion fail:fail];
}

//POST提交(判断是否有文件上传)
+ (void)postAuto:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	BOOL formData = NO;
	if (data.count) {
		for (NSString *key in data) {
			if ([data[key] isKindOfClass:[UIImage class]] || [data[key] isKindOfClass:[NSData class]]) {
				formData = YES;
				break;
			}
		}
	}
	if (!formData) {
		[Global post:url data:data completion:completion fail:fail];
	} else {
		[Global upload:url data:data completion:completion fail:fail];
	}
}

//POST提交,可设置超时时间(判断是否有文件上传)
+ (void)postAuto:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	BOOL formData = NO;
	if (data.count) {
		for (NSString *key in data) {
			if ([data[key] isKindOfClass:[UIImage class]] || [data[key] isKindOfClass:[NSData class]]) {
				formData = YES;
				break;
			}
		}
	}
	if (!formData) {
		[Global post:url data:data timeout:timeout completion:completion fail:fail];
	} else {
		[Global upload:url data:data options:nil timeout:timeout progress:nil completion:completion fail:fail];
	}
}

//GET提交,可设置超时时间
+ (void)getNative:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	NSMutableDictionary *datas = [NSMutableDictionary dictionaryWithDictionary:data];
	if (url.element[@"retry"]) {
		url.element[@"retry"] = @([url.element[@"retry"]integerValue]-1);
	} else {
		url.element[@"retry"] = @3;
	}
	NSString *postData = @"";
	if (data.count) {
		NSMutableArray *param = [[NSMutableArray alloc]init];
		for (NSString *key in data) {
			[param addObject:key];
			[param addObject:[[NSString stringWithFormat:@"%@", data[key]] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		postData = [param componentsJoinedByString:@"&"];
		NSRange range = [postUrl rangeOfString:@"?"];
		if ([postUrl substringFromIndex:NSMaxRange(range)]) postData = [NSString stringWithFormat:@"?%@", postData];
	}
	postUrl = [NSString stringWithFormat:@"%@%@", postUrl, postData];
	postUrl = [postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
	[request setHTTPMethod:@"GET"];
	NSOperationQueue *queue = [[NSOperationQueue alloc]init];
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		//NSURLSession *session = [NSURLSession sharedSession];
		//NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error) {
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@", error.localizedDescription, (long)error.code, postUrl);
			if (error.code==-1001) {
				if ([url.element[@"retry"]integerValue]>1) {
					[Global get:url data:datas options:nil timeout:timeout completion:completion fail:fail];
					return;
				}
				[ProgressHUD showTrouble:@"网络超时"];
			}
			//error.code==-1003 //未能找到使用指定主机名的服务器
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"]; //网络连接已中断
			if (fail) {
				dispatch_async(dispatch_get_main_queue(), ^{
					fail(error.localizedDescription, error.code);
				});
			}
		} else {
			NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
			NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
			if (responseCode>=200 && responseCode<300) {
				if (completion) {
					dispatch_async(dispatch_get_main_queue(), ^{
						completion(result);
					});
				}
			} else {
				NSLog(@"Httperror:%@ Errorcode:%ld\n%@", result, (long)responseCode, postUrl);
				if (fail) {
					dispatch_async(dispatch_get_main_queue(), ^{
						fail(result, responseCode);
					});
				}
			}
		}
	}];
	//[dataTask resume];
}

//POST提交,可设置超时时间
+ (void)postNative:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	NSData *postData = [NSData data];
	if (data.isDictionary) {
		NSMutableArray *param = [[NSMutableArray alloc]init];
		for (NSString *key in data) {
			[param addObject:[NSString stringWithFormat:@"%@=%@", key, [data[key] jsonString]]];
		}
		postData = [[param componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	}
	postUrl = [postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%ld", (unsigned long)postData.length];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"Mozilla/4.0 (compatible; OpenOffice.org)" forHTTPHeaderField:@"User-Agent"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:postData];
	NSOperationQueue *queue = [[NSOperationQueue alloc]init];
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		//NSURLSession *session = [NSURLSession sharedSession];
		//NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error) {
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@", error.localizedDescription, (long)error.code, postUrl);
			if (error.code==-1001) [ProgressHUD showTrouble:@"网络超时"];
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"];
			if (fail) {
				dispatch_async(dispatch_get_main_queue(), ^{
					fail(error.localizedDescription, error.code);
				});
			}
		} else {
			NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
			NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
			if (responseCode>=200 && responseCode<300) {
				if (completion) {
					dispatch_async(dispatch_get_main_queue(), ^{
						completion(result);
					});
				}
			} else {
				NSLog(@"Httperror:%@ Errorcode:%ld\n%@", result, (long)responseCode, postUrl);
				if (fail) {
					dispatch_async(dispatch_get_main_queue(), ^{
						fail(result, responseCode);
					});
				}
			}
		}
	}];
	//[dataTask resume];
}

//上传提交,可设置超时时间
+ (void)uploadNative:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	NSInteger count = 0;
	for (NSString *key in data) {
		if ([data[key] isKindOfClass:[UIImage class]] || [data[key] isKindOfClass:[NSData class]]) count++;
	}
	if (!count) count = 1;
	timeout = timeout * count;
	postUrl = [postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
	[request setHTTPMethod:@"POST"];
	NSString *boundary = @"----WebKitFormBoundaryEmJo8eX0Rq7BDl9l";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	NSMutableData *body = [NSMutableData data];
	int i = 1;
	for (NSString *key in data) {
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		if ([data[key] isKindOfClass:[UIImage class]]) {
			UIImage *post = data[key];
			NSData *imageData = post.data;
			NSString *suffix = post.suffix;
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%d.%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", key, i, suffix] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[NSData dataWithData:imageData]];
		} else if ([data[key] isKindOfClass:[NSData class]]) {
			NSData *post = data[key];
			NSArray *postArr = [[NSString stringWithFormat:@"%@", key] componentsSeparatedByString:@"."];
			NSString *prefix = postArr[0];
			NSString *suffix = postArr[1];
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%d.%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", prefix, i, suffix] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[NSData dataWithData:post]];
		} else {
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[data[key] jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		[body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		i++;
	}
	[body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody:body];
	NSOperationQueue *queue = [[NSOperationQueue alloc]init];
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		//NSURLSession *session = [NSURLSession sharedSession];
		//NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error) {
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@", error.localizedDescription, (long)error.code, postUrl);
			if (error.code==-1001) [ProgressHUD showTrouble:@"网络超时"];
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"];
			if (fail) {
				dispatch_async(dispatch_get_main_queue(), ^{
					fail(error.localizedDescription, error.code);
				});
			}
		} else {
			NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
			NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
			if (responseCode>=200 && responseCode<300) {
				if (completion) {
					dispatch_async(dispatch_get_main_queue(), ^{
						completion(result);
					});
				}
			} else {
				NSLog(@"Httperror:%@ Errorcode:%ld\n%@", result, (long)responseCode, postUrl);
				if (fail) {
					dispatch_async(dispatch_get_main_queue(), ^{
						fail(result, responseCode);
					});
				}
			}
		}
	}];
	//[dataTask resume];
}

//GET提交,可设置超时时间(timeout==[-1不限制, 0默认60秒, >0自定义秒数])
+ (void)get:(NSString*)url data:(NSDictionary*)data options:(NSDictionary*)options timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithDictionary:data];
	if (url.element[@"retry"]) {
		url.element[@"retry"] = @([url.element[@"retry"]integerValue]-1);
	} else {
		url.element[@"retry"] = @(API_REQUEST_RETRY);
	}
	NSString *userAgent = [@"webUserAgent" getUserDefaultsString];
	[AFNetwork shared].manager.requestSerializer = [AFHTTPRequestSerializer serializer];
	[[AFNetwork shared].manager.requestSerializer setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[[AFNetwork shared].manager.requestSerializer setValue:APP_BUILD_VERSION forHTTPHeaderField:@"APP_BUILD_VERSION"];
	[[AFNetwork shared].manager.requestSerializer setValue:SDK_VERSION forHTTPHeaderField:@"APP_SDK_VERSION"];
	[[AFNetwork shared].manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	if (API_AUTH.length) [[AFNetwork shared].manager.requestSerializer setValue:FORMAT(@"Basic %@",API_AUTH) forHTTPHeaderField:@"Authorization"];
	if (options.isDictionary) {
		if ([options[@"header"] isDictionary]) {
			NSDictionary *header = options[@"header"];
			for (NSString *headerField in header) {
				[[AFNetwork shared].manager.requestSerializer setValue:header[headerField] forHTTPHeaderField:headerField];
			}
		}
	}
	if (timeout==-1) {
		[AFNetwork shared].manager.requestSerializer.timeoutInterval = INFINITY;
	} else if (timeout>0) {
		[AFNetwork shared].manager.requestSerializer.timeoutInterval = timeout;
	}
	//[AFNetwork shared].manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
	//NSDictionary *requestHeaders = [AFNetwork shared].manager.requestSerializer.HTTPRequestHeaders;
	//NSLog(@"%@", requestHeaders.descriptionASCII);
	[[AFNetwork shared].manager GET:postUrl parameters:postData progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
		//NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
		//NSLog(@"%@", response.allHeaderFields);
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
				completion(result.trim);
			});
		}
	} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSDictionary *responseHeaders = ((NSHTTPURLResponse *)task.response).allHeaderFields;
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@\n%@", error.localizedDescription, (long)error.code, postUrl, responseHeaders.descriptionASCII);
			if (error.code==-1001 || error.code==-1003 || error.code==-1004 || error.code==-999) {
				if ([url.element[@"retry"]integerValue]>1) {
					[Global get:url data:data options:options timeout:timeout completion:completion fail:fail];
					return;
				}
				[ProgressHUD showTrouble:@"网络超时"];
			}
			//error.code==-1003 //未能找到使用指定主机名的服务器
			//error.code==-1004 //未能连接到服务器
			//error.code==-999 //连接已取消
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"];
			if (error.code==-1011) [ProgressHUD showTrouble:@"请求不允许"];
			if (fail) fail(error.localizedDescription, error.code);
		});
	}];
}

//POST提交,可设置超时时间(timeout==[-1不限制, 0默认60秒, >0自定义秒数])
+ (void)post:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	return [Global post:url data:data options:nil timeout:timeout completion:completion fail:fail];
}
+ (void)postJSON:(NSString*)url data:(id)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	return [Global post:url data:data options:@{@"type":@"json"} timeout:timeout completion:completion fail:fail];
}
+ (void)postJSON:(NSString*)url data:(id)data options:(NSDictionary*)options completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	return [Global post:url data:data options:options timeout:5 completion:completion fail:fail];
}
//type = json[json数据提交], raw[body二进制数据提交], 其他[普通数据key:value形式提交]
+ (void)post:(NSString*)url data:(id)data options:(NSDictionary*)options timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithDictionary:data];
	if (url.element[@"retry"]) {
		url.element[@"retry"] = @([url.element[@"retry"]integerValue]-1);
	} else {
		url.element[@"retry"] = @(API_REQUEST_RETRY);
	}
	NSString *userAgent = [@"webUserAgent" getUserDefaultsString];
	NSString *type = @"html";
	if (options.isDictionary && options[@"type"]) type = options[@"type"];
	[AFNetwork shared].manager.requestSerializer = [type isEqualToString:@"json"] ? [AFJSONRequestSerializer serializer] : [AFHTTPRequestSerializer serializer];
	[[AFNetwork shared].manager.requestSerializer setValue:APP_BUILD_VERSION forHTTPHeaderField:@"APP_BUILD_VERSION"];
	[[AFNetwork shared].manager.requestSerializer setValue:SDK_VERSION forHTTPHeaderField:@"APP_SDK_VERSION"];
	[[AFNetwork shared].manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	if (API_AUTH.length) [[AFNetwork shared].manager.requestSerializer setValue:FORMAT(@"Basic %@",API_AUTH) forHTTPHeaderField:@"Authorization"];
	if (options.isDictionary) {
		if ([options[@"header"] isDictionary]) {
			NSDictionary *header = options[@"header"];
			for (NSString *headerField in header) {
				[[AFNetwork shared].manager.requestSerializer setValue:header[headerField] forHTTPHeaderField:headerField];
			}
		}
	}
	if (timeout==-1) {
		[AFNetwork shared].manager.requestSerializer.timeoutInterval = INFINITY;
	} else if (timeout>0) {
		[AFNetwork shared].manager.requestSerializer.timeoutInterval = timeout;
	}
	if ([type isEqualToString:@"raw"]) {
		[[AFNetwork shared].manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[[AFNetwork shared].manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, id parameters, NSError * __autoreleasing * error) {
			id rawData = [data copy];
			if (API_PUBLIC_KEY.length) {
				NSMutableArray *arr = [[data jsonString] str_split:117];
				NSMutableArray *datas = [[NSMutableArray alloc]init];
				for (int i=0; i<arr.count; i++) {
					NSString *rsa = [Common RsaPublicEncode:arr[i]];
					[datas addObject:rsa.length?rsa:@""];
				}
				rawData = [datas implode:@""];
				rawData = [rawData base64];
			}
			return rawData;
		}];
	}
	//NSDictionary *requestHeaders = [AFNetwork shared].manager.requestSerializer.HTTPRequestHeaders;
	//NSLog(@"%@", requestHeaders.descriptionASCII);
	[[AFNetwork shared].manager POST:postUrl parameters:postData progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
		//NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
		//NSLog(@"%@", response.allHeaderFields);
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
				completion(result.trim);
			});
		}
	} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSDictionary *responseHeaders = ((NSHTTPURLResponse *)task.response).allHeaderFields;
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@\n%@\n%@", error.localizedDescription, (long)error.code, postUrl, postData, responseHeaders.descriptionASCII);
			if (error.code==-1001 || error.code==-1003 || error.code==-1004 || error.code==-999) {
				if ([url.element[@"retry"]integerValue]>1) {
					[Global post:url data:data options:options timeout:timeout completion:completion fail:fail];
					return;
				}
				[ProgressHUD showTrouble:@"网络超时"];
			}
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"];
			if (error.code==-1011) [ProgressHUD showTrouble:@"请求不允许"];
			if (fail) fail(error.localizedDescription, error.code);
		});
	}];
}

//上传提交,可设置超时时间(timeout==[-1不限制, 0默认60秒, >0自定义秒数])
+ (void)upload:(NSString*)url data:(NSDictionary*)data options:(NSDictionary*)options timeout:(NSTimeInterval)timeout progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	NSString *postUrl = [url copy];
	NSTimeInterval postTimeout = timeout;
	if (url.element[@"retry"]) {
		url.element[@"retry"] = @([url.element[@"retry"]integerValue]-1);
	} else {
		url.element[@"retry"] = @(API_REQUEST_RETRY);
	}
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	NSString *userAgent = [@"webUserAgent" getUserDefaultsString];
	NSInteger count = 0;
	for (NSString *key in data) {
		if ([data[key] isKindOfClass:[UIImage class]] || [data[key] isKindOfClass:[NSData class]]) {
			count++;
		} else {
			[postData setValue:data[key] forKey:key];
		}
	}
	if (!count) count = 1;
	postTimeout = postTimeout * count;
	[AFNetwork shared].manager.requestSerializer = [AFHTTPRequestSerializer serializer];
	[[AFNetwork shared].manager.requestSerializer setValue:APP_BUILD_VERSION forHTTPHeaderField:@"APP_BUILD_VERSION"];
	[[AFNetwork shared].manager.requestSerializer setValue:SDK_VERSION forHTTPHeaderField:@"APP_SDK_VERSION"];
	[[AFNetwork shared].manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	if (API_AUTH.length) [[AFNetwork shared].manager.requestSerializer setValue:FORMAT(@"Basic %@",API_AUTH) forHTTPHeaderField:@"Authorization"];
	NSString *type = @"html";
	if (options.isDictionary) {
		if (options[@"type"]) type = options[@"type"];
		if ([options[@"header"] isDictionary]) {
			NSDictionary *header = options[@"header"];
			for (NSString *headerField in header) {
				[[AFNetwork shared].manager.requestSerializer setValue:header[headerField] forHTTPHeaderField:headerField];
			}
		}
	}
	if (postTimeout==-1) {
		[AFNetwork shared].manager.requestSerializer.timeoutInterval = INFINITY;
	} else if (postTimeout>0) {
		[AFNetwork shared].manager.requestSerializer.timeoutInterval = postTimeout;
	}
	if ([type isEqualToString:@"raw"]) {
		[[AFNetwork shared].manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[[AFNetwork shared].manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, id parameters, NSError * __autoreleasing * error) {
			return [data copy];
		}];
	}
	//NSDictionary *requestHeaders = [AFNetwork shared].manager.requestSerializer.HTTPRequestHeaders;
	//NSLog(@"%@", requestHeaders.descriptionASCII);
	[[AFNetwork shared].manager POST:postUrl parameters:postData constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
		//上传文件的key格式为:字段名.后缀名, 例如:avatar.png
		for (NSString *key in data) {
			if ([data[key] isKindOfClass:[UIImage class]]) {
				UIImage *post = data[key];
				NSData *fileData = post.data;
				NSArray *postArr = [key componentsSeparatedByString:@"."];
				NSString *name = postArr[0];
				NSString *mimeType = post.mimeType;
				[formData appendPartWithFileData:fileData name:name fileName:key mimeType:mimeType];
			} else if ([data[key] isKindOfClass:[NSData class]]) {
				NSData *fileData = data[key];
				NSArray *postArr = [key componentsSeparatedByString:@"."];
				NSString *name = postArr[0];
				NSString *mimeType = fileData.mimeType;
				[formData appendPartWithFileData:fileData name:name fileName:key mimeType:mimeType];
			}
		}
	} progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
		//NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
		//NSLog(@"%@", response.allHeaderFields);
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
				completion(result.trim);
			});
		}
	} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSDictionary *responseHeaders = ((NSHTTPURLResponse *)task.response).allHeaderFields;
			NSLog(@"Httperror:%@ Errorcode:%ld\n%@\n%@\n%@", error.localizedDescription, (long)error.code, postUrl, data, responseHeaders.descriptionASCII);
			if (error.code==-1001 || error.code==-1003 || error.code==-1004 || error.code==-999) {
				if ([url.element[@"retry"]integerValue]>1) {
					[Global upload:url data:data options:options timeout:timeout progress:progress completion:completion fail:fail];
					return;
				}
				[ProgressHUD showTrouble:@"网络超时"];
			}
			if (error.code==-1005) [ProgressHUD showTrouble:@"网络不稳定，请重试"];
			if (error.code==-1011) [ProgressHUD showTrouble:@"请求不允许"];
			if (fail) fail(error.localizedDescription, error.code);
		});
	}];
}

//下载网络文件
+ (void)download:(NSString*)url completion:(void (^)(NSString *fileName, NSData *fileData, BOOL exist))completion{
	if (!url.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) completion(nil, nil, NO);
		});
		return;
	}
	if ([url indexOf:@"://"]==NSNotFound) url = [NSString stringWithFormat:@"%@%@", API_URL, url];
	dispatch_queue_t queue = dispatch_queue_create("downloadFile", DISPATCH_QUEUE_CONCURRENT);
	//dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:DOWNLOAD_TIMEOUT];
		[request setHTTPMethod:@"GET"];
		NSOperationQueue *queue = [[NSOperationQueue alloc]init];
		[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
			if (error) {
				NSLog(@"Httperror:%@%ld", error.localizedDescription, (long)error.code);
			} else {
				NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
				NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
				if (responseCode>=200 && responseCode<300) {
					dispatch_async(dispatch_get_main_queue(), ^{
						if (completion) completion([url getFilename], data, YES);
					});
					return;
				} else {
					NSLog(@"Httperror:%ld\n%@", (long)responseCode, result);
					if (responseCode == 404) [ProgressHUD showError:@"远程文件不存在"];
				}
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				if (completion) completion(nil, nil, NO);
			});
		}];
	});
}

//下载网络图片
+ (void)downloadImage:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion{
	[Global downloadImage:url size:CGSizeZero completion:completion];
}

//下载网络图片,且直接缩放
+ (void)downloadImage:(NSString*)url size:(CGSize)size completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion{
	if (!url.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) completion(nil, nil, NO);
		});
		return;
	}
	if ([url indexOf:@"://"]==NSNotFound) url = [NSString stringWithFormat:@"%@%@", API_URL, url];
	[FileDownloader downloadWithUrl:url completion:^(NSData *data, BOOL exist) {
		UIImage *image = [UIImage imageWithData:data];
		if (size.width) image = [image fitToSize:size];
		if (completion) completion(image, size.width ? image.data : data, YES);
	} fail:^(NSString *description, NSInteger code) {
		if (code == 404) [ProgressHUD showError:@"图片不存在"];
		if (completion) completion(nil, nil, NO);
	}];
}

//直接下载网络图片到指定路径
+ (void)downloadImageToPath:(NSString*)savePath url:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion{
	if (!savePath.length || !url.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) completion(nil, nil, NO);
		});
		return;
	}
	if ([Global fileExist:savePath]) {
		if (completion) completion([Global imageFile:savePath], [Global getFileData:savePath], YES);
		return;
	}
	[Global downloadImage:url completion:^(UIImage *image, NSData *imageData, BOOL exist) {
		[Global saveFile:savePath data:imageData];
		if (completion) completion(image, imageData, exist);
	}];
}

//缓存网络图片
+ (void)cacheImageWithUrl:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData))completion{
	if (!url.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) completion(nil, nil);
		});
		return;
	}
	[Global cacheImageWithUrls:@[url] completion:^(NSArray *images) {
		if (completion) {
			UIImage *image = images.firstObject;
			if ([image isKindOfClass:[NSNull class]]) {
				completion(nil, nil);
			} else {
				completion(image, image.data);
			}
		}
	}];
}

//SDWebImage预缓存图片
+ (void)cacheImageWithUrls:(NSArray*)urls completion:(void (^)(NSArray *images))completion{
	NSMutableArray *arr = [[NSMutableArray alloc]init];
	for (int i=0; i<urls.count; i++) {
		NSString *url = urls[i];
		if (!url.length) continue;
		if ([url indexOf:@"://"]==NSNotFound) url = [NSString stringWithFormat:@"%@%@", API_URL, url];
		NSURL *u = [NSURL URLWithString:url];
		if (!u) continue;
		[arr addObject:u];
	}
	if (!arr.count) {
		if (completion) completion(nil);
		return;
	}
	NSMutableArray *images = [[NSMutableArray alloc]init];
	for (NSURL *url in arr) {
		[images addObject:url.absoluteString];
	}
	for (int i=0; i<images.count; i++) {
		UIImageView *imageView = [[UIImageView alloc]init];
		[imageView sd_setImageWithURL:[NSURL URLWithString:images[i]] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			if (error) {
				[images replaceObjectAtIndex:i withObject:[NSNull null]];
			} else {
				[images replaceObjectAtIndex:i withObject:image];
			}
			BOOL loadFull = YES;
			for (id obj in images) {
				if ([obj isKindOfClass:[NSString class]]) {
					loadFull = NO;
					break;
				}
			}
			if (loadFull) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (completion) completion(images);
				});
			}
		}];
	}
}

//缓存网络图片到UIImageView
+ (void)cacheToImageView:(UIImageView*)imageView url:(NSString*)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion{
	[Global cacheToImageView:imageView url:url placeholder:placeholder completion:completion animate:nil];
}

//缓存网络图片到UIImageView,支持完成后动画显示
+ (void)cacheToImageView:(UIImageView*)imageView url:(NSString*)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate{
	CGFloat maxImageWidth = 90*SCREEN_SCALE;
	CGFloat placeholderWidth = 70*SCREEN_SCALE;
	imageView.image = nil;
	imageView.clipsToBounds = YES;
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	for (UIView *subview in imageView.subviews) {
		if (([subview isKindOfClass:[UIImageView class]] && subview.width==placeholderWidth) ||
			[subview isKindOfClass:[AJProgressView class]]) {
			[subview removeFromSuperview];
		}
	}
	if (!url.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (placeholder) {
				UIImage *subImg;
				if ([placeholder isKindOfClass:[NSString class]]) {
					subImg = [UIImage imageNamed:placeholder];
				} else if ([placeholder isKindOfClass:[NSData class]]) {
					subImg = [[UIImage alloc]initWithData:placeholder];
				} else if ([placeholder isKindOfClass:[UIImage class]]) {
					subImg = placeholder;
				}
				if (imageView.width >= maxImageWidth) {
					UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((imageView.width-placeholderWidth)/2, (imageView.height-placeholderWidth)/2, placeholderWidth, placeholderWidth)];
					img.image = subImg;
					imageView.image = nil;
					[imageView addSubview:img];
				} else {
					imageView.image = subImg;
				}
			}
			if (completion) completion(imageView, nil, nil, NO, NO);
			imageView.element[@"exist"] = @NO;
		});
		return;
	}
	if ([url indexOf:@"://"]==NSNotFound) url = [NSString stringWithFormat:@"%@%@", API_URL, url];
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	if (imageView.frame.size.width>=35*SCREEN_SCALE && imageView.frame.size.height>=35*SCREEN_SCALE) {
		NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]];
		if (![[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				AJProgressView *progressView = [[AJProgressView alloc]initWithFrame:CGRectMake(imageView.left+(imageView.width-30*SCREEN_SCALE)/2, imageView.top+(imageView.height-30*SCREEN_SCALE)/2, 30*SCREEN_SCALE, 30*SCREEN_SCALE)];
				progressView.progressColor = COLORMAIN;
				progressView.label.hidden = YES;
				[imageView.superview addSubview:progressView];
				imageView.element[@"progressView"] = progressView;
			});
		}
	}
	[imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
		if (imageView.element[@"progressView"] && expectedSize>0) {
			AJProgressView *progressView = imageView.element[@"progressView"];
			dispatch_async(dispatch_get_main_queue(), ^{
				progressView.progress = (double)receivedSize / expectedSize;
			});
		}
	} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (imageView.element[@"progressView"]) {
				AJProgressView *progressView = imageView.element[@"progressView"];
				[progressView removeFromSuperview];
				imageView.removeElement = @"progressView";
			}
			if (error) {
				if (placeholder) {
					UIImage *subImg;
					if ([placeholder isKindOfClass:[NSString class]]) {
						subImg = [UIImage imageNamed:placeholder];
					} else if ([placeholder isKindOfClass:[NSData class]]) {
						subImg = [[UIImage alloc]initWithData:placeholder];
					} else if ([placeholder isKindOfClass:[UIImage class]]) {
						subImg = placeholder;
					}
					if (imageView.width >= maxImageWidth) {
						UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((imageView.width-placeholderWidth)/2, (imageView.height-placeholderWidth)/2, placeholderWidth, placeholderWidth)];
						img.image = subImg;
						imageView.image = nil;
						[imageView addSubview:img];
					} else {
						imageView.image = subImg;
					}
					CGFloat alpha = imageView.alpha;
					imageView.alpha = 0;
					[UIView animateWithDuration:0.3 animations:^(void) {
						imageView.alpha = alpha;
					}];
				}
				if (completion) completion(imageView, nil, nil, NO, NO);
				imageView.element[@"exist"] = @NO;
			} else {
				BOOL isCache = cacheType != SDImageCacheTypeNone;
				if (!isCache) {
					if (animate) {
						animate(imageView, isCache);
					} else {
						CGFloat alpha = imageView.alpha;
						imageView.alpha = 0;
						[UIView animateWithDuration:0.3 animations:^(void) {
							imageView.alpha = alpha;
						}];
					}
				} else {
					if (animate) animate(imageView, isCache);
				}
				imageView.element[@"image"] = image;
				imageView.element[@"exist"] = @YES;
				if (completion) completion(imageView, image, image.data, YES, isCache);
			}
		});
	}];
}

#pragma mark - 日期
//本地当前时间
+ (NSString*)now{
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	return [formatter stringFromDate:[NSDate date]];
}

//本地当前Unix时间戳
+ (NSTimeInterval)unix{
	return [[NSDate date] timeIntervalSince1970];
}

//时间转为Unix时间戳
+ (NSTimeInterval)unixFromDate:(id)dt{
	if ([dt isKindOfClass:[NSString class]]) dt = [Global dateFromString:dt];
	return [dt timeIntervalSince1970];
}

//Unix时间戳转为时间
+ (NSDate*)dateFromUnix:(NSTimeInterval)unix{
	NSString *unixString = [NSString stringWithFormat:@"%.f", (double)unix];
	if (unixString.length==13) unix = floor(unix/1000);
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:unix];
	NSInteger seconds = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:date];
	return [date dateByAddingTimeInterval:seconds];
}

//NSDateFormatter格式
//unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
//字符串转日期
+ (NSDate*)dateFromString:(NSString*)str{
	NSArray *match = [str preg_match:@"^(\\d{4})-(\\d{1,2})(?:-(\\d{1,2})(?: (\\d{1,2})(?::(\\d{1,2})(?::(\\d{1,2}))?)?)?)?$"];
	if (!match.count) match = [str preg_match:@"^(?:(\\d{4})-(\\d{1,2})-(\\d{1,2}) )?(\\d{1,2}):(\\d{1,2})(?::(\\d{1,2}))?$"];
	if (!match.count) return nil;
	NSArray *group = match[0][@"group"];
	NSInteger year = [group[0]length] ? [group[0]integerValue] : [Global getYear:[NSDate date]];
	NSInteger month = [group[1]length] ? [group[1]integerValue] : [Global getMonth:[NSDate date]];
	NSInteger day = [group[2]length] ? [group[2]integerValue] : 1;
	NSInteger hour = [group[3]length] ? [group[3]integerValue] : 0;
	NSInteger minute = [group[4]length] ? [group[4]integerValue] : 0;
	NSInteger second = [group[5]length] ? [group[5]integerValue] : 0;
	year = year ? year : 1970;
	month = month ? month : 1;
	day = day ? day : 1;
	hour = hour ? hour : 0;
	minute = minute ? minute : 0;
	second = second ? second : 0;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
	return [formatter dateFromString:FORMAT(@"%ld-%ld-%ld %ld:%ld:%ld +0800", (long)year, (long)month, (long)day, (long)hour, (long)minute, (long)second)];
}

//日期转字符串
+ (NSString*)formatDate:(id)dt{
	return [Global formatDate:dt format:@"yyyy-MM-dd"];
}

//时间格式化
+ (NSString*)formatDate:(id)dt format:(NSString*)str{
	if ([dt isKindOfClass:[NSString class]]) dt = [Global dateFromString:dt];
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:str];
	if ([str indexOf:@"eee"]!=NSNotFound) {
		NSArray *weekdayAry = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
		[formatter setShortWeekdaySymbols:weekdayAry]; //eee使用上面自定义
	}
	return [formatter stringFromDate:dt];
}

//日期时间转字符串
+ (NSString*)formatDateTime:(id)dt{
	return [Global formatDate:dt format:@"yyyy-MM-dd HH:mm:ss"];
}

//时间转字符串
+ (NSString*)formatTime:(id)dt{
	return [Global formatDate:dt format:@"HH:mm:ss"];
}

//获取年份
+ (NSInteger)getYear:(NSDate*)date{
	NSDateComponents *comps = [Global compts:date];
	return [comps year];
}
//获取月份
+ (NSInteger)getMonth:(NSDate*)date{
	NSDateComponents *comps = [Global compts:date];
	return [comps month];
}
//获取日期为周几, 1:日, 2:一, 3:二, 4:三, 5:四, 6:五, 7:六
+ (NSInteger)getWeek:(NSDate*)date{
	NSDateComponents *comps = [Global compts:date];
	return [comps weekday];
}
//获取日
+ (NSInteger)getDay:(NSDate*)date{
	NSDateComponents *comps = [Global compts:date];
	return [comps day];
}
//获取时
+ (NSInteger)getHour:(NSDate*)date{
	NSDateComponents *comps = [Global compts:date];
	return [comps hour];
}
//获取分
+ (NSInteger)getMinute:(NSDate*)date{
	NSDateComponents *comps = [Global compts:date];
	return [comps minute];
}
//获取秒
+ (NSInteger)getSecond:(NSDate*)date{
	NSDateComponents *comps = [Global compts:date];
	return [comps second];
}
+ (NSCalendar *)calendar{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[[NSTimeZone systemTimeZone] secondsFromGMTForDate:[NSDate date]]];
	return calendar;
}
+ (NSDateComponents *)compts:(NSDate *)date{
	NSDateComponents *compts = [[Global calendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
	return compts;
}

+ (NSTimeInterval)oneYear{
	return 60 * 60 * 24 * 365;
}

+ (NSTimeInterval)oneMonth{
	return 60 * 60 * 24 * 30;
}
+ (NSTimeInterval)oneMonth:(NSInteger)days{
	return 60 * 60 * 24 * days;
}

+ (NSTimeInterval)oneWeek{
	return 60 * 60 * 24 * 7;
}

+ (NSTimeInterval)oneDay{
	return 60 * 60 * 24;
}

//获取偏移时间
+ (NSInteger)getDateOffset:(NSInteger)delay range:(NSString*)range{
	NSArray *intervalName = @[@"yyyy", @"m", @"w", @"d", @"h", @"n", @"s"];
	NSInteger index = [intervalName indexOfObject:range];
	NSDate *dateNow;
	switch (index) {
		case 0:case 1:case 3:dateNow = [NSDate dateWithTimeIntervalSinceNow:delay*24*60*60];break;
		case 2:dateNow = [NSDate dateWithTimeIntervalSinceNow:delay*7*24*60*60];break;
		case 4:dateNow = [NSDate dateWithTimeIntervalSinceNow:delay*60*60];break;
		case 5:dateNow = [NSDate dateWithTimeIntervalSinceNow:delay*60];break;
		case 6:default:dateNow = [NSDate dateWithTimeIntervalSinceNow:delay];break;
	}
	NSDateComponents *comps = [[Global calendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:dateNow];
	NSInteger num = 0;
	switch (index) {
		case 0:num = [comps year];break;
		case 1:num = [comps month];break;
		case 2:num = [comps weekday];break;
		case 3:num = [comps day];break;
		case 4:num = [comps hour];break;
		case 5:num = [comps minute];break;
		case 6:default:num = [comps second];break;
	}
	return num;
}

//时间递增
+ (NSDate*)dateAdd:(NSString*)range interval:(NSInteger)number date:(id)dt{
	if ([dt isKindOfClass:[NSString class]]) dt = [Global dateFromString:dt];
	NSArray *intervalName = @[@"yyyy", @"m", @"w", @"d", @"h", @"n", @"s"];
	NSInteger index = [intervalName indexOfObject:range];
	NSDateComponents *comps = [[NSDateComponents alloc]init];
	switch (index) {
		case 0:[comps setYear:number];break;
		case 1:[comps setMonth:number];break;
		case 2:[comps setDay:([comps day]+7*number)];break;
		case 3:[comps setDay:number];break;
		case 4:[comps setHour:number];break;
		case 5:[comps setMinute:number];break;
		case 6:default:[comps setSecond:number];break;
	}
	NSDate *date = [[Global calendar] dateByAddingComponents:comps toDate:dt options:0];
	return date;
}

//时间相隔
+ (NSInteger)dateDiff:(NSString*)range earlyDate:(id)earlyDate lateDate:(id)lateDate{
	if ([earlyDate isKindOfClass:[NSString class]]) earlyDate = [Global dateFromString:earlyDate];
	if ([lateDate isKindOfClass:[NSString class]]) lateDate = [Global dateFromString:lateDate];
	NSArray *intervalName = @[@"yyyy", @"m", @"w", @"d", @"h", @"n", @"s"];
	NSInteger index = [intervalName indexOfObject:range];
	NSTimeInterval time = [lateDate timeIntervalSinceDate:earlyDate];
	switch (index) {
		case 0:time = time / (60 * 60 * 24 * 365);break;
		case 1:time = time / (60 * 60 * 24 * 30);break;
		case 2:time = time / (60 * 60 * 24 * 7);break;
		case 3:time = time / (60 * 60 * 24);break;
		case 4:time = time / (60 * 60);break;
		case 5:time = time / 60;break;
		case 6:default:time = time;break;
	}
	return time;
}

//获取指定时间所在周的第一天与最后一天(根据系统本地区域)
+ (NSArray*)getWeeksBeginAndEnd:(id)dt{
	if ([dt isKindOfClass:[NSString class]]) dt = [Global dateFromString:dt];
	NSDateComponents *dateComps = [[Global calendar] components:NSCalendarUnitWeekday fromDate:dt];
	NSInteger daycount = [dateComps weekday] - 2;
	NSDate *weekdaybegin = [dt dateByAddingTimeInterval:-daycount*60*60*24];
	NSDate *weekdayend = [dt dateByAddingTimeInterval:(6-daycount)*60*60*24];
	return [NSArray arrayWithObjects:weekdaybegin, weekdayend, nil];
}

//日期时间+4位随机数
+ (NSString*)datetimeAndRandom{
	CGFloat rand = (arc4random() % 8999) + 1000;
	NSString *datetime = [Global formatDate:[NSDate date] format:@"yyyyMMddHHmmss"];
	return [NSString stringWithFormat:@"%@%.f", datetime, rand];
}

//农历的年份（生肖）例如：甲子（鼠）年
+ (NSString *)getChineseYearWithDate:(NSDate *)date{
	NSArray *years = [NSArray arrayWithObjects:
							 @"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
							 @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛巳",  @"壬午",  @"癸未",
							 @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
							 @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸卯",
							 @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
							 @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥", nil];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
	NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
	NSString *year = [years objectAtIndex:comps.year-1];
	NSString *str = nil;
	if ([year hasSuffix:@"子"]) {
		str = @"鼠";
	} else if ([year hasSuffix:@"丑"]) {
		str = @"牛";
	} else if ([year hasSuffix:@"寅"]) {
		str = @"虎";
	} else if ([year hasSuffix:@"卯"]) {
		str = @"兔";
	} else if ([year hasSuffix:@"辰"]) {
		str = @"龙";
	} else if ([year hasSuffix:@"巳"]) {
		str = @"蛇";
	} else if ([year hasSuffix:@"午"]) {
		str = @"马";
	} else if ([year hasSuffix:@"未"]) {
		str = @"羊";
	} else if ([year hasSuffix:@"申"]) {
		str = @"猴";
	} else if ([year hasSuffix:@"酉"]) {
		str = @"鸡";
	} else if ([year hasSuffix:@"戌"]) {
		str = @"狗";
	} else if ([year hasSuffix:@"亥"]) {
		str = @"猪";
	}
	return [NSString stringWithFormat:@"%@(%@)年", year, str];
}

//农历的月、日
+ (NSString *)getChineseCalendarWithDate:(NSDate *)date{
	NSArray *months = [NSArray arrayWithObjects:
							@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
							@"九月", @"十月", @"冬月", @"腊月", nil];
	NSArray *days = [NSArray arrayWithObjects:
						  @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
						  @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
						  @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
	NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
	NSString *month = [months objectAtIndex:comps.month-1];
	NSString *day = [days objectAtIndex:comps.day-1];
	NSString *str =[NSString stringWithFormat:@"%@%@", month, day];
	return str;
}

//本年或者本月的第几周 第一个参数传YES 得到本年的第几周 NO为本月的第几周
+ (NSInteger)getWeekInYearOrMouth:(BOOL)inYear date:(NSDate *)date{
	NSDateComponents *comps = [[Global calendar] components:NSCalendarUnitWeekOfYear | NSCalendarUnitWeekOfMonth fromDate:date];
	if (inYear) {
		return comps.weekOfYear;
	} else {
		return comps.weekOfMonth;
	}
}

#pragma mark - UI操作
//UILabel多行
+ (UILabel*)multiLine:(CGRect)frame string:(NSString*)string font:(UIFont*)font{
	CGSize size = [string autoHeight:font width:frame.size.width];
	frame.size.height = size.height;
	UILabel *label = [[UILabel alloc]initWithFrame:frame];
	label.text = string;
	label.font = font;
	label.numberOfLines = 0;
	return label;
}

//UILabel多行且设定行高
+ (UILabel*)multiLine:(CGRect)frame string:(NSString*)string font:(UIFont*)font lineheight:(CGFloat)linespace{
	UILabel *label = [Global multiLine:frame string:string font:font];
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:string];
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
	[paragraphStyle setLineSpacing:linespace];
	[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
	label.attributedText = attributedString;
	[label sizeToFit];
	return label;
}

//放大且渐隐view
+ (void)zoomView:(UIView*)view{
	[Global zoomView:view duration:0.3 percent:1.4];
}
+ (void)zoomView:(UIView*)view duration:(CGFloat)duration percent:(CGFloat)percent{
	[UIView animateWithDuration:duration animations:^{
		[Global scaleView:view percent:percent];
		view.alpha = 0;
	} completion:^(BOOL finished) {
		[view removeFromSuperview];
	}];
}

//动画移动view
+ (void)moveView:(UIView*)view to:(CGRect)frame time:(CGFloat)time{
	// 动画开始
	[UIView beginAnimations:nil context:nil];
	// 动画时间曲线 EaseInOut效果
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	// 动画时间
	[UIView setAnimationDuration:time];
	[view setFrame:frame];
	// 动画结束
	[UIView commitAnimations];
}

//抛物线移动view
+ (void)throwView:(UIView*)view endpoint:(CGPoint)endpoint completion:(void (^)(void))completion{
	UIBezierPath *path = [UIBezierPath bezierPath];
	CGPoint startPoint = view.center; //起点
	[path moveToPoint:startPoint];
	//贝塞尔曲线控制点
	CGFloat sx = startPoint.x;
	CGFloat sy = startPoint.y;
	CGFloat ex = endpoint.x;
	CGFloat ey = endpoint.y;
	CGFloat x = sx + (ex - sx) / 3;
	CGFloat y = sy + (ey - sy) * 0.5 - 400;
	[path addQuadCurveToPoint:endpoint controlPoint:CGPointMake(x, y)];
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	animation.path = path.CGPath;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.duration = 0.8;
	animation.autoreverses = NO;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	[view.layer addAnimation:animation forKey:@"throw"];
	if (completion) {
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion();
			});
		});
	}
}

//旋转屏幕
+ (void)transformScreen:(UIViewController*)view{
	[Global transformScreen:view orientation:@"top"];
}

//旋转屏幕,可设置方向
+ (void)transformScreen:(UIViewController*)view orientation:(NSString*)orientation{
	UIInterfaceOrientation o;
	CGRect navFrame;
	CGRect viewFrame;
	CGAffineTransform m;

	if ([orientation isEqualToString:@"left"]) {
		o = UIInterfaceOrientationLandscapeLeft;
		navFrame = CGRectMake(64, 224, [UIScreen mainScreen].bounds.size.height, 32);
		viewFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, view.view.frame.size.width);
		m = CGAffineTransformMakeRotation(M_PI_2);
	} else if ([orientation isEqualToString:@"right"]) {
		o = UIInterfaceOrientationLandscapeRight;
		navFrame = CGRectMake(64, 224, [UIScreen mainScreen].bounds.size.height, 32);
		viewFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, view.view.frame.size.width);
		m = CGAffineTransformMakeRotation(M_PI*1.5);
	} else if ([orientation isEqualToString:@"bottom"]) {
		o = UIInterfaceOrientationPortraitUpsideDown;
		navFrame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
		viewFrame = CGRectMake(0, 0, view.view.frame.size.width, view.view.frame.size.height);
		m = CGAffineTransformMakeRotation(0);
	} else {
		o = UIInterfaceOrientationPortrait;
		navFrame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
		viewFrame = CGRectMake(0, 0, view.view.frame.size.width, view.view.frame.size.height);
		m = CGAffineTransformMakeRotation(0);
	}

	//状态栏动画持续时间
	CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
	//设置旋转动画
	[UIView animateWithDuration:duration animations:^{
		[[UIApplication sharedApplication] setStatusBarOrientation:o animated:YES];
		//设置导航栏旋转
		view.navigationController.navigationBar.frame = navFrame;
		view.navigationController.navigationBar.transform = m;
		//设置视图旋转
		view.view.bounds = viewFrame;
		view.view.transform = m;
	}];
}

//缩放View
+ (void)scaleView:(UIView*)view percent:(CGFloat)percent{
	if (percent==0) percent = 0.01;
	view.transform = CGAffineTransformMakeScale(percent, percent);
}

//动画缩放View
+ (void)scaleAnimate:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)(void))completion{
	if (percent==0) percent = 0.01;
	[UIView animateWithDuration:time animations:^{
		view.transform = CGAffineTransformMakeScale(percent, percent);
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//动画缩放View,回弹效果
+ (void)scaleAnimateBounces:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)(void))completion{
	[Global scaleAnimateBounces:view time:time percent:percent bounce:0.2 completion:completion];
}
+ (void)scaleAnimateBounces:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent bounce:(CGFloat)bounce completion:(void (^)(void))completion{
	if (percent==0) percent = 0.01;
	/*
	 [Global scaleAnimate:view time:time percent:percent+bounce completion:^{
		[Global scaleAnimate:view time:time percent:percent completion:^{
	 if (completion) completion();
		}];
	 }];
	 */
	[view.layer removeAllAnimations];
	CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	scaoleAnimation.duration = time;
	scaoleAnimation.values = @[@(percent), @(percent+bounce), @(percent)];
	scaoleAnimation.fillMode = kCAFillModeForwards;
	[view.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) completion();
		});
	});
}

//角度旋转View
+ (void)rotatedView:(UIView*)view degrees:(CGFloat)degrees{
	view.transform = CGAffineTransformMakeRotation((M_PI*(degrees)/180.0));
}

//指定中心点旋转View,CGPoint参数为百分比
+ (void)rotatedView:(UIView*)view degrees:(CGFloat)degrees center:(CGPoint)center{
	CGRect frame = view.frame;
	view.layer.anchorPoint = center; //设置旋转的中心点
	view.frame = frame; //设置anchorPont会使view的frame改变,需重新赋值
	view.transform = CGAffineTransformMakeRotation((M_PI*(degrees)/180.0));
}

//2D动画旋转
+ (void)rotateAnimate:(UIView*)view time:(NSTimeInterval)time degrees:(CGFloat)degrees completion:(void (^)(void))completion{
	CGAffineTransform t = view.transform;
	[UIView animateWithDuration:time animations:^{
		view.transform = CGAffineTransformRotate(t, (M_PI*(degrees)/180.0));
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//指定中心点2D动画旋转
+ (void)rotateAnimate:(UIView*)view time:(NSTimeInterval)time degrees:(CGFloat)degrees center:(CGPoint)center completion:(void (^)(void))completion{
	CGAffineTransform t = view.transform;
	CGRect frame = view.frame;
	view.layer.anchorPoint = center;
	view.frame = frame;
	[UIView animateWithDuration:time animations:^{
		view.transform = CGAffineTransformRotate(t, (M_PI*(degrees)/180.0));
	} completion:^(BOOL finished) {
		if (completion) completion();
	}];
}

//3D动画旋转
+ (void)rotate3DAnimate:(UIView*)view delegate:(id)delegate{
	CAAnimation *animateRotate = [Global rotate3DAnimate];
	CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
	groupAnimation.delegate = delegate;
	groupAnimation.removedOnCompletion = NO;
	groupAnimation.duration = 1;
	groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	groupAnimation.repeatCount = 1;
	groupAnimation.fillMode = kCAFillModeForwards;
	groupAnimation.animations = [NSArray arrayWithObjects:animateRotate,nil];
	[view.layer addAnimation:groupAnimation forKey:@"animationRotate"];
	/*
	 在delegate里面可增加动画结束后执行的方法
	 -(void)animationDidStop:(CAAnimation*)animation finished:(BOOL)flag
	 */
}
+ (CAAnimation*)rotate3DAnimate{
	CATransform3D rotationTransform = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
	animation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
	animation.duration = 0.3;
	animation.autoreverses = YES;
	animation.cumulative = YES;
	animation.repeatCount = 1;
	animation.beginTime = 0.1;
	animation.delegate = (id)self;
	return animation;
}

//地图翻起动画效果
+ (void)pageCurlAnimation:(UIView*)view time:(NSTimeInterval)time delegate:(id)delegate{
	CATransition *animation = [CATransition animation];
	[animation setDelegate:delegate];
	[animation setDuration:time];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnon-literal-null-conversion"
	[animation setTimingFunction:UIViewAnimationCurveEaseInOut];
#pragma clang diagnostic pop
	if (!view.element[@"pageCurl"]) {
		animation.type = @"pageCurl";
		animation.fillMode = kCAFillModeForwards;
		animation.endProgress = 0.40;
		view.element[@"pageCurl"] = @YES;
	} else {
		animation.type = @"pageUnCurl";
		animation.fillMode = kCAFillModeBackwards;
		animation.startProgress = 0.30;
		[view removeElement:@"pageCurl"];
	}
	[animation setRemovedOnCompletion:NO];
	[view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
	[view.layer addAnimation:animation forKey:@"pageCurlAnimation"];
}

//指定列数for循环自动调整X、Y坐标(换行),需在循环外部设定uIndex、vIndex为[NSNumber numberWithFloat:0]
/*
 NSNumber *k = [NSNumber numberWithInteger:0];
 NSNumber *l = [NSNumber numberWithInteger:0];
 for(int i=0; i<arr.count; i++){
	ele.frame = [Global autoXYWithCellCount:2 width:100 height:50 blank:10 marginTop:10 marginLeft:10 uIndex:&k vIndex:&l];
 }
 */
+ (CGRect)autoXYWithCellCount:(NSInteger)count width:(CGFloat)w height:(CGFloat)h blank:(CGFloat)b marginTop:(CGFloat)t marginLeft:(CGFloat)l uIndex:(NSNumber**)u vIndex:(NSNumber**)v{
	CGFloat i = [*u floatValue];
	CGFloat j = [*v floatValue];
	CGFloat x = l + (w + b) * i;
	CGFloat y = t + (h + b) * j;
	CGRect frame = CGRectMake(x, y, w, h);
	if (fmod(i+1, count)==0) {
		i = 0;
		j++;
	} else {
		i++;
	}
	*u = [NSNumber numberWithFloat:i];
	*v = [NSNumber numberWithFloat:j];
	return frame;
}

//固定宽度区域内自动调整X、Y坐标(换行),需在循环外部设定prevRight、prevBottom为[NSNumber numberWithFloat:0]
+ (CGRect)autoXYInWidth:(CGFloat)width subview:(UIView*)subview marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb{
	return [Global autoXYInWidth:width subview:subview frame:subview.frame marginPT:t marginPL:l marginPR:r prevRight:pr prevBottom:pb];
}
+ (CGRect)autoXYInWidth:(CGFloat)width subview:(UIView*)subview frame:(CGRect)subviewFrame marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb{
	CGFloat x = [*pr floatValue];
	CGFloat y = [*pb floatValue];
	CGFloat w = floor(subviewFrame.size.width);
	CGFloat h = floor(subviewFrame.size.height);
	if (x==0) x = l;
	if (y==0) y = t;
	if (!subview.element[@"first"]) x += floor(subviewFrame.origin.x);
	CGRect frame = CGRectMake(x, y, w, h);
	if (x+w > width-r) {
		UIView *prevView = [subview prevView:[subview.superview.element[@"cellCount"]integerValue]];
		x = l;
		y = floor(prevView.frame.origin.y) + floor(prevView.frame.size.height) + floor(subviewFrame.origin.y);
		frame = CGRectMake(x, y, w, h);
	}
	x += w;
	*pr = [NSNumber numberWithFloat:x];
	*pb = [NSNumber numberWithFloat:y];
	return frame;
}

//在指定UIView内自动排版,类似于WEB的DIV+CSS自动排版
+ (void)autoLayoutWithView:(UIView*)view subviews:(NSMutableArray*)subviews marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r{
	if (!subviews.count) return;
	[view addSubviews:subviews marginPT:t marginPL:l marginPR:r];
}

+ (void)showMenuControllerWithTarget:(UIView*)target titles:(NSArray*)titles actions:(NSArray*)actions{
	[target showMenuControllerWithTitles:titles actions:actions];
}

#pragma mark - 其他
//格式化小数,支持四舍五入
+ (float)decimalFormat:(float)num scale:(int)scale{
	NSString *format = [NSString stringWithFormat:@"0%@", scale>0?@".":@""];
	for (int i=0; i<scale; i++) {
		format = [format stringByAppendingString:@"0"];
	}
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
	[formatter setPositiveFormat:format];
	NSString *number = [formatter stringFromNumber:[NSNumber numberWithFloat:num]];
	return [number floatValue];
}

//获取当前IP
+ (NSString*)getIP{
	NSError *error;
	//NSString *url = @"http://ip.taobao.com/service/getIpInfo.php?ip=myip";
	NSString *string = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://pv.sohu.com/cityjson"] encoding:0x80000421 error:&error];
	NSDictionary *json = string.formatJson;
	if ([json[@"code"]integerValue] != 0) return @"";
	return json[@"data"][@"ip"];
	/*
	 NSError *error;
	 NSString *ip = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://pv.sohu.com/cityjson"] encoding:0x80000421 error:&error];
	 if (error) {
		NSLog(@"%@",error);
		ip = @"";
	 } else {
		ip = [Global cropHtml:ip startStr:@"cip\": \"" overStr:@"\", \"cid"];
		ip = [Global trim:ip];
	 }
	 return ip;
	 */
}

//倒计时算法
+ (NSMutableDictionary*)countdown:(NSInteger)seconds{
	NSInteger day = (NSInteger)seconds/(24*60*60);
	NSInteger hour = (NSInteger)(seconds%(24*60*60))/(60*60);
	NSInteger minute = (NSInteger)(seconds%(60*60))/60;
	NSInteger second = (NSInteger)(seconds%60);
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			@(day),@"day",
			@(hour),@"hour",
			@(minute),@"minute",
			@(second),@"second",
			nil];
}

//等比缩放
+ (CGSize)fitToSize:(CGSize)size originSize:(CGSize)origin{
	return [Global fitToSize:size originSize:origin fix:0];
}
+ (CGSize)fitToSize:(CGSize)size originSize:(CGSize)origin fix:(CGFloat)fix{
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat iw = origin.width;
	CGFloat ih = origin.height;
	CGFloat nw = iw;
	CGFloat nh = ih;
	if (iw>0 && ih>0) {
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
	}
	if (width>0) {
		if (width>nw) {
			size = CGSizeMake(nw, size.height);
		}
	} else {
		size = CGSizeMake(nw, size.height);
	}
	if (height>0) {
		if (height>nh) {
			size = CGSizeMake(size.width, nh);
		}
	} else {
		size = CGSizeMake(size.width, nh);
	}
	return size;
}

//拨打电话
+ (void)openCall:(NSString*)tel{
	if (!tel.length) {
		[ProgressHUD showError:@"电话号码为空"];
		return;
	}
	if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:"]]) return;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:FORMAT(@"tel:%@", tel)]];
}

//发短信
+ (void)openSms:(NSString*)tel{
	if (!tel.length) {
		[ProgressHUD showError:@"电话号码为空"];
		return;
	}
	if (![MFMessageComposeViewController canSendText]) {
		[ProgressHUD showWarning:@"设备不能发短信"];
		return;
	}
	MFMessageComposeViewController *msg = [[MFMessageComposeViewController alloc] init];
	msg.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)[Global sharedHelper];
	msg.recipients = @[tel];
	//msg.body = @"";
	[[Global currentController] presentViewController:msg animated:YES completion:nil];
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
	[controller dismissViewControllerAnimated:YES completion:nil];
}

//调用QQ客户端查看指定QQ号
+ (void)openQQ:(NSString*)uin{
	if (![ShareHelper isQQInstalled]) {
		[ProgressHUD showWarning:@"设备没有QQ客户端"];
		return;
	}
	NSString *link = [NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web", uin];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}

//调用微信客户端打开指定账号
+ (void)openWechat:(NSString*)uin{
	if (![ShareHelper isWXAppInstalled]) {
		[ProgressHUD showWarning:@"设备没有微信客户端"];
		return;
	}
	NSString *link = [NSString stringWithFormat:@"weixin://qr/%@", uin];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}

const double baidu_x_pi = 3.14159265358979324 * 3000.0 / 180.0;
//火星转百度坐标
void baidu_encrypt(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon){
	double x = gg_lon, y = gg_lat;
	double z = sqrt(x * x + y * y) + 0.00002 * sin(y * baidu_x_pi);
	double theta = atan2(y, x) + 0.000003 * cos(x * baidu_x_pi);
	*bd_lon = z * cos(theta) + 0.0065;
	*bd_lat = z * sin(theta) + 0.006;
}
//百度坐标转火星
void baidu_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon){
	double x = bd_lon - 0.0065, y = bd_lat - 0.006;
	double z = sqrt(x * x + y * y) - 0.00002 * sin(y * baidu_x_pi);
	double theta = atan2(y, x) - 0.000003 * cos(x * baidu_x_pi);
	*gg_lon = z * cos(theta);
	*gg_lat = z * sin(theta);
}

//打开地图列表
+ (void)openMap:(double)latitude longitude:(double)longitude{
	NSArray *maps = [Global mapApps];
	[UIAlertController action:nil buttons:maps block:^(NSInteger buttonIndex) {
		if (buttonIndex < maps.count) {
			[Global openMapApp:maps[buttonIndex] travelType:MapTravelTypeCar latitude:latitude longitude:longitude];
		}
	}];
}

//判断是否有指定地图
+ (NSArray*)mapApps{
	NSArray *schemeArr = @[@"comgooglemaps://", @"iosamap://", @"baidumap://", @"qqmap://"];
	NSMutableArray *listArr = [[NSMutableArray alloc] initWithObjects:@"苹果地图", nil];
	for (int i = 0; i < [schemeArr count]; i++) {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:schemeArr[i]]]) {
			switch (i) {
				case 0:{
					[listArr addObject:@"谷歌地图"];
					break;
				}
				case 1:{
					[listArr addObject:@"高德地图"];
					break;
				}
				case 2:{
					[listArr addObject:@"百度地图"];
					break;
				}
				case 3:{
					[listArr addObject:@"腾讯地图"];
					break;
				}
			}
		}
	}
	return listArr;
}

//调起指定地图,目的地必须为百度经纬度
+ (void)openMapApp:(NSString*)title travelType:(MapTravelTypes)travelType latitude:(double)latitude longitude:(double)longitude{
	double navLat, navLon;
	baidu_decrypt(latitude, longitude, &navLat, &navLon);
	[[CCLocationManager shareLocation] getBaiduAddressWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) completion:^(NSString *province, NSString *targetCity, NSString *district, NSString *targetAddress, NSString *addressDetail, NSDictionary *dictionary) {
		[[CCLocationManager shareLocation] getCoordinateAndAddress:^(CLLocationCoordinate2D locationCorrrdinate, NSString *province, NSString *city, NSString *district, NSString *address, NSString *addressDetail, NSDictionary *dictionary) {
			double nowLat, nowLon;
			baidu_decrypt(locationCorrrdinate.latitude, locationCorrrdinate.longitude, &nowLat, &nowLon);
			if ([title indexOf:@"苹果"]!=NSNotFound) {
				CLLocationCoordinate2D to;
				to.latitude = navLat;
				to.longitude = navLon;
				MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
				MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil]];
				toLocation.name = targetAddress;
				[MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
			} else if ([title indexOf:@"谷歌"]!=NSNotFound) {
				NSString *mode = @"driving";
				if (travelType == MapTravelTypeBus) {
					mode = @"transit";
				} else if (travelType == MapTravelTypeWalk) {
					mode = @"walking";
				}
				NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=%.8f,%.8f&daddr=%.8f,%.8f&directionsmode=%@", nowLat, nowLon, navLat, navLon, mode];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
			} else if ([title indexOf:@"高德"]!=NSNotFound) {
				NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&poiname=%@&poiid=BGVIS&lat=%.8f&lon=%.8f&dev=1&style=2", APP_SCHEME, APP_SCHEME, targetAddress, navLat, navLon] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				[[UIApplication sharedApplication] openURL:url];
			} else if ([title indexOf:@"百度"]!=NSNotFound) {
				NSString *mode = @"driving";
				if (travelType == MapTravelTypeBus) {
					mode = @"transit";
				} else if (travelType == MapTravelTypeWalk) {
					mode = @"walking";
				}
				NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"baidumap://map/direction?origin=%.8f,%.8f&destination=latlng:%f,%f|name=%@&mode=%@&coord_type=gcj02", nowLat, nowLon, navLat, navLon, targetCity, mode] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				[[UIApplication sharedApplication] openURL:url];
			} else if ([title indexOf:@"腾讯"]!=NSNotFound) {
				NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"qqmap://map/routeplan?from=%@&fromcoord=%f,%f&type=drive&tocoord=%f,%f&to=%@&coord_type=1&policy=0", address, nowLat, nowLon, navLat, navLon, targetAddress] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				[[UIApplication sharedApplication] openURL:url];
			}
		}];
	}];
}

//通过 APP STORE 检查新版本
+ (void)checkVersion{
	if (!APP_ID.length) {
		[ProgressHUD showError:@"APP_ID is empty!"];
		return;
	}
	[ProgressHUD show:nil];
	[Common postApiWithUrl:FORMAT(@"https://itunes.apple.com/lookup?id=%@", APP_ID) data:nil timeout:5 feedback:nil success:^(NSMutableDictionary *json) {
		NSArray *results = json[@"results"];
		if (results.isArray) {
			NSDictionary *releaseInfo = results[0];
			CGFloat lastVersion = [releaseInfo[@"version"] floatValue];
			if (lastVersion > [APP_VERSION floatValue]) {
				[UIAlertController alert:@"有新版本更新" message:releaseInfo[@"releaseNotes"] cancel:@"关闭" submit:@"更新" block:^(NSInteger buttonIndex) {
					if (buttonIndex==1) {
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:releaseInfo[@"trackVireUrl"]]];
					}
				}];
			} else {
				[ProgressHUD showSuccess:@"此版本为最新版本"];
			}
		}
	} fail:nil complete:nil];
}

//获取范围随机数
+ (NSInteger)randomFrom:(NSInteger)from to:(NSInteger)to{
	NSInteger t = to + 1 - from;
	NSInteger random = (arc4random() % t) + from;
	return random;
}

//获取范围随机小数
+ (double)randomFloatFrom:(double)from to:(double)to{
	//double t = to + 1 - from;
	double random = ((double)arc4random() / 0x100000000) + from;
	return random;
}

//获取指定位数的随机字符串
+ (NSString*)randomString:(NSInteger)length{
	NSString *sourceStr = @"9zML5pGCkBAJQ2Zh4de1RlqNPno8m3FKijbrc6SDEas7O0TUXYtwxuVHWvIfgy";
	NSMutableString *result = [[NSMutableString alloc]init];
	srand((unsigned int)time(0));
	for (int i=0; i<length; i++) {
		unsigned index = rand() % [sourceStr length];
		NSString *one = [sourceStr substringWithRange:NSMakeRange(index, 1)];
		[result appendString:one];
	}
	return result;
}

//获取滑动方向, 0:无,1:上,2:下,3:左,4:右
/*
 NSInteger _direction;
 - (void)handlePan:(UIPanGestureRecognizer *)recognizer{
	CGPoint translation = [recognizer translationInView:recognizer.view];
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		_direction = 0;
	} else if (recognizer.state == UIGestureRecognizerStateChanged && _direction==0) {
		_direction = [Global getMoveDirectionWithTranslation:translation direction:_direction];
	} else if (recognizer.state == UIGestureRecognizerStateEnded) {
		 switch (_direction) {
			 case 1:
				 //NSLog(@"moved up");
				 break;
			 case 2:
				 //NSLog(@"moved down");
				 break;
			 case 3:
				 //NSLog(@"moved left");
				 break;
			 case 4:
				 //NSLog(@"moved right");
				 break;
			 default:
				 //NSLog(@"no moved");
				 break;
		 }
	}
 }
 */
+ (NSInteger)getMoveDirectionWithTranslation:(CGPoint)translation direction:(NSInteger)direction{
	CGFloat gestureMinimumTranslation = 50.f;
	if (direction != 0) return direction;
	if (fabs(translation.x) > gestureMinimumTranslation) {
		BOOL gestureHorizontal = (translation.y==0.0) ? YES : (fabs(translation.x / translation.y) > 5.0);
		if (gestureHorizontal) {
			if (translation.x > 0.0) return 4;
			else return 3;
		}
	} else if (fabs(translation.y) > gestureMinimumTranslation) {
		BOOL gestureVertical = (translation.x==0.0) ? YES : (fabs(translation.y / translation.x) > 5.0);
		if (gestureVertical) {
			if (translation.y > 0.0) return 2;
			else return 1;
		}
	}
	return direction;
}

//相隔一定时间后重复执行
+ (void)repeatDo:(NSTimeInterval)delay function:(void (^)(void))function{
	if (function) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				function();
				[Global repeatDo:delay function:function];
			});
		});
	}
}

//通过 NSUserDefaults 检测当前网络
+ (BOOL)isNetwork:(BOOL)noNetShowMsg{
	BOOL isNetwork = NO;
	NSDictionary *network = [@"network" getUserDefaultsDictionary];
	if (network.isDictionary) {
		isNetwork = [CheckNetwork isNetworkFor:network[@"network"] noNetShowMsg:NO];
		if (!isNetwork && noNetShowMsg) {
			[ProgressHUD showTrouble:@"没有网络哦，请联网后再试吧"];
		}
	} else {
		isNetwork = [CheckNetwork isNetwork:NO];
		if (!isNetwork && noNetShowMsg) {
			[ProgressHUD showTrouble:@"没有网络哦，请联网后再试吧"];
		}
	}
	return isNetwork;
}

//列出指定目录下的文件列表
+ (void)GFileList:(NSString *)folderPath{
	GFileList *e = [[GFileList alloc]init];
	e.folderPath = folderPath;
	[APPCurrentController.navigationController pushViewController:e animated:YES];
}

//显示本地推送
+ (void)showLocalNotification:(NSString*)body{
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.fireDate = [NSDate date];
	notification.alertBody = body;
	notification.alertAction = @"打开";
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.soundName = UILocalNotificationDefaultSoundName;
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	notification.userInfo = userInfo;
	//发送通知
	UIApplication *application = [UIApplication sharedApplication];
	[application scheduleLocalNotification:notification];
	int badgeNumber = [@"badgeNumber" getUserDefaultsInt];
	badgeNumber += 1;
	[@"badgeNumber" setUserDefaultsWithData:@(badgeNumber)];
	application.applicationIconBadgeNumber = badgeNumber;
}

//注册通知
+ (void)notificationRegisterWithObserver:(id)observer selector:(SEL)selector name:(NSString*)name object:(id)object{
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:object];
}
//发送通知
+ (void)notificationPostWithName:(NSString*)name object:(id)object{
	NSNotification *notification = [NSNotification notificationWithName:name object:object];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}
//移除通知
+ (void)notificationRemoveObserver:(id)observer{
	[[NSNotificationCenter defaultCenter] removeObserver:observer];
}

//是否允许推送通知
+ (BOOL)isAllowedNotification{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
	return [[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone;
#else
	return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone;
#endif
}

//注册推送通知
+ (BOOL)registerNotification{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
	[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge) categories:nil]];
	[[UIApplication sharedApplication] registerForRemoteNotifications];
#else
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
#endif
	if (![Global isAllowedNotification]) {
		[UIAlertController alert:@"请在“设置->通知”中打开" submit:@"去设定" block:^(NSInteger buttonIndex) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
		}];
		return NO;
	}
	return YES;
}

//注销推送通知
+ (BOOL)unregisterNotification{
	[[UIApplication sharedApplication] unregisterForRemoteNotifications];
	if ([Global isAllowedNotification]) {
		[UIAlertController alert:@"请在“设置->通知”中关闭" submit:@"去设定" block:^(NSInteger buttonIndex) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
		}];
		return NO;
	}
	return YES;
}

//缓存大小
+ (NSInteger)getCachesSize{
	return [[SDWebImageManager sharedManager].imageCache getSize];
}
//清除缓存
+ (void)removeAllCache{
	[[SDWebImageManager sharedManager] cancelAll]; //取消正在下载的操作
	[Global removeDiskCache];
	[Global removeMemoryCache];
}
+ (void)removeDiskCache{
	[[SDWebImageManager sharedManager].imageCache clearDisk]; //清除文件缓存
}
+ (void)removeMemoryCache{
	[[SDWebImageManager sharedManager].imageCache clearMemory]; //清除内存缓存
}
+ (void)removeCacheForKey:(NSString*)key{
	[[SDWebImageManager sharedManager].imageCache removeImageForKey:key fromDisk:YES]; //清除指定key的内存与文件缓存
}

//播放声音文件, [[NSBundle mainBundle] pathForResource:@"EMReply.mp3" ofType:nil]
+ (void)playVoice:(NSString*)voicePath{
	NSURL *url = [NSURL fileURLWithPath:voicePath];
	SystemSoundID soundID = 0;
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
	//AudioServicesDisposeSystemSoundID(soundID);
	//AudioServicesPlayAlertSound(soundID); //声音带震动
	AudioServicesPlaySystemSound(soundID); //声音
	//AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //震动
}

//Touch ID, passwordTitle:nil即不显示输入密码按钮
+ (void)touchIDWithReason:(NSString*)reason passwordTitle:(NSString*)passwordTitle success:(void (^)(void))successBlock fail:(void (^)(NSError *error))fail nosupport:(void (^)(void))nosupport{
	LAContext *context = [[LAContext alloc]init];
	NSError *error = nil;
	if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
		context.localizedFallbackTitle = passwordTitle;
		[context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError *error) {
			if (success) {
				if (successBlock) {
					dispatch_async(dispatch_get_main_queue(), ^{
						successBlock();
					});
				}
			} else {
				//用户取消认证
				if (fail) {
					dispatch_async(dispatch_get_main_queue(), ^{
						fail(error);
					});
				}
			}
		}];
	} else {
		if (nosupport) {
			nosupport();
		} else {
			[ProgressHUD showError:@"设备不支持指纹认证"];
		}
	}
}

#pragma mark - 本类方法
+ (Global*)sharedHelper{
	static dispatch_once_t once = 0;
	static Global *global;
	dispatch_once(&once, ^{ global = [[Global alloc] init]; });
	return global;
}

@end
