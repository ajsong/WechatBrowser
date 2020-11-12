//
//  Global.h
//
//  Created by ajsong on 2014-9-1.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#ifndef Global_h
#define Global_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <WebKit/WebKit.h>
#import <objc/message.h>
//message.h 供 if ([target respondsToSelector:action]) objc_msgSend(target, action, arg1, arg2, ...);
#import <objc/runtime.h>
//runtime.h 供 objc_setAssociatedObject, objc_getAssociatedObject, objc_removeAssociatedObjects
//objc_setAssociatedObject(view, @"KEY", dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//NSDictionary *dictionary = objc_getAssociatedObject(view, @"KEY");
//objc_removeAssociatedObjects(view);

//忽略警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic ignored "-Wunused-variable" //含有没有被使用的变量
//#pragma clang diagnostic ignored "-Wincompatible-pointer-types" //指针类型不匹配

#import "GConfig.h"
#import "AFNetworking.h"
#import "AJPayHelper.h"
#import "CheckNetwork.h"
#import "Common.h"
#import "IQKeyboardManager.h"
#import "KKNavigationController.h"
#import "KKTabBarController.h"
#import "MJPhotosBrowser.h"
#import "MJRefresh.h"
#import "Outlet.h"
#import "ProgressHUD.h"
#import "QRCodeReaderController.h"
#import "RSAUtil.h"
#import "UIImageView+WebCache.h"
#import "ShareHelper.h"

#import "AJActionView.h"
#import "AJCheckbox.h"
#import "AJDateView.h"
#import "AJEditAction.h"
#import "AJPhotosView.h"
#import "AJPickerView.h"
#import "AJProgressView.h"
#import "AJRatingView.h"
#import "AJSelectImage.h"
#import "AJSelectImageView.h"
#import "AJSwitchView.h"
#import "AJTransitionController.h"
#import "AreaPickerView.h"
#import "CCPCalendarManager.h"
#import "DragView.h"
#import "GFileList.h"
#import "GIFImageView.h"
#import "JKNotifier.h"
#import "UITableViewRowAction+JZExtension.h"
#import "OYCountDownManager.h"
#import "QiniuHelper.h"
#import "SKPSMTPMessage.h"
#import "WRNavigationBar.h"
#import "YCMenuView.h"

#import "Group+Extend.h"
#import "NSArray+Extend.h"
#import "NSDictionary+Extend.h"
#import "NSObject+Extend.h"
#import "NSString+Extend.h"
#import "UIButton+Extend.h"
#import "UIImage+Extend.h"
#import "UILabel+Extend.h"
#import "UILabel+RichText.h"
#import "UITableView+Extend.h"
#import "UIView+Extend.h"
#import "UIViewController+Extend.h"

#import <UMCommon/UMCommon.h>
//安装统计、跟踪
#import <UMAnalytics/MobClick.h>
//消息推送
#import <UMPush/UMessage.h>
//快速登录、分享
#import <UMShare/UMShare.h>
#import "UMSocialTCWeiboHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSmsHandler.h"
#import "UMSocialEmailHandler.h"
//支付宝支付
#import <AlipaySDK/AlipaySDK.h>
#import "AlipayResult.h"
#import "Alipay.h"
//微信支付
#import "WechatPay.h"
//ApplePay
#import "ApplePay.h"

//腾讯Bugly
#import <Bugly/Bugly.h>

#pragma clang diagnostic pop

//系统信息
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue] //系统版本
#define IOS6 (IOS_VERSION<7.0) //系统iOS6及以下
#define IOS7 ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch]!=NSOrderedAscending) //系统iOS7及以上
#define IOS8 ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch]!=NSOrderedAscending) //系统iOS8及以上
#define IOS9 ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch]!=NSOrderedAscending) //系统iOS8及以上
#define IOS10 ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch]!=NSOrderedAscending) //系统iOS10及以上
#define IOS11 ([[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch]!=NSOrderedAscending) //系统iOS11及以上
#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)
#define isX \
({\
	BOOL isPhoneX = NO;\
	if (@available(iOS 11.0, *)) {\
		isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
	}\
	isPhoneX;\
})
#define APP_NAME ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] length] ? [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] : [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey]) //应用名称
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] //应用版本
#define APP_BUILD_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] //应用build版本
#define APP_BUNDLE_ID [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] //应用Bundle Id
#define KEYWINDOWS [UIApplication sharedApplication].windows
#define KEYWINDOW ((UIWindow*)KEYWINDOWS[0]) //当前窗口
#define STATUSBAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height //状态栏高度
#define SCREEN_BOUNDS [UIScreen mainScreen].bounds //屏幕宽高
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width //屏幕宽度
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height //屏幕高度,不包含状态栏高度
#define SCREEN_SCALE (SCREEN_HEIGHT>568.0f ? (SCREEN_HEIGHT>736.0f ? SCREEN_WIDTH/320.0f : SCREEN_HEIGHT/568.0f) : 1.0f) //屏幕高度比例(适配用)
#define SCREEN_SCALE_FLOOR(float) floorf(float*SCREEN_SCALE) //按比例后取最大整数(小数清零)
#define APPDELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])
#define APPCurrentController KEYWINDOW.currentController //当前显示的控制器
#define APPCurrentView KEYWINDOW.currentController.view //当前显示的页面
#define APPRootViewController [[[UIApplication sharedApplication].windows firstObject] rootViewController] //当前的根控制器(不包括模态视图)

#define INT(str) [(str) intValue]
#define INTEGER(str) [(str) integerValue]
#define FLOAT(str) [(str) floatValue]
#define DOUBLE(str) [(str) doubleValue]
#define ARRAY(obj) [NSMutableArray arrayWithArray:obj]
#define DICTIONARY(obj) [NSMutableDictionary dictionaryWithDictionary:obj]
#define ROUND(str, num) [Global decimalFormat:(str) scale:(num)]
#define FILEPATH(name) [[NSBundle mainBundle] pathForResource:name ofType:nil]
#define FONT(float) [UIFont systemFontOfSize:float*SCREEN_SCALE]
#define FONTBOLD(float) [UIFont boldSystemFontOfSize:float*SCREEN_SCALE]
#define FONTPRICE(float) [UIFont fontWithName:@"STHeitiSC-Light" size:float*SCREEN_SCALE] //价格字体
#define FONTNUMEQUAL(float) [UIFont fontWithName:@"ArialMT" size:float*SCREEN_SCALE] //数字等宽字体
#define IMGAPPICON IMG(@"AppIcon60x60")
#define IMG(string, ...) [UIImage imageNamed:[NSString stringWithFormat:string, ##__VA_ARGS__]]
#define IMGFILE(string, ...) [UIImage imageFile:[NSString stringWithFormat:string, ##__VA_ARGS__]]
#define STRING(object) [NSString stringWithFormat:@"%@", object?object:@""]
#define FORMAT(string, ...) [NSString stringWithFormat:string, ##__VA_ARGS__]

#define COLORCLEAR [UIColor clearColor]
#define COLORWHITE COLORRGB(@"fff")
#define COLORBLACK COLORRGB(@"000")
#define COLORRED COLORRGB(@"f75353")
#define COLORORANGE COLORRGB(@"eb5e00")
#define COLORGREEN COLORRGB(@"008500")
#define COLORBLUE COLORRGB(@"0095d9")
#define COLORYELLOW COLORRGB(@"ffc700")
#define COLORPINK COLORRGB(@"f060a5")
#define COLORPURPLE COLORRGB(@"a35db5")
#define COLOR_SYSTEM_BLUE COLORRGB(@"007aff")
#define COLOR_GE COLORRGB(@"c7c7c7")
#define COLOR_GE_LIGHT COLORRGB(@"e5e5e5")
#define COLOR_PLACEHOLDER COLORRGB(@"c7c7c7")
#define COLOREEE COLORRGB(@"eee")
#define COLORDDD COLORRGB(@"ddd")
#define COLORCCC COLORRGB(@"ccc")
#define COLORBBB COLORRGB(@"bbb")
#define COLORAAA COLORRGB(@"aaa")
#define COLOR999 COLORRGB(@"999")
#define COLOR888 COLORRGB(@"888")
#define COLOR777 COLORRGB(@"777")
#define COLOR666 COLORRGB(@"666")
#define COLOR444 COLORRGB(@"444")
#define COLOR333 COLORRGB(@"333")
#define COLORRGB(string) [Global colorFromHexRGB:string]
#define COLORRGBA(string, opacity) [Global colorFromHexRGB:string alpha:opacity]

#define WeakObj(obj) autoreleasepool{} __weak typeof(obj) _##obj = obj;
#define StrongObj(obj) autoreleasepool{} __strong typeof(obj) strong##obj = _##obj;
#define LocalString(x, ...) NSLocalizedString(x, nil) //引用国际化的文件
#define degreesToRadian(x) (M_PI * (x) / 180.0) //角度获取弧度
#define radianToDegrees(radian) ((radian*180.0)/(M_PI)) //弧度获取角度
#define NLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d]\n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#define DLog(fmt, ...) fprintf(stderr, "\n%s [Line %d]\n%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]);

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaPremultipliedLast (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
#define kCGImageAlphaPremultipliedLast kCGImageAlphaPremultipliedLast
#endif
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
//#if TARGET_OS_IPHONE
//#if TARGET_IPHONE_SIMULATOR

#define DOWNLOAD_TIMEOUT 7 //下载超时
#define NAVBAR_HIDDEN_UNDERLINE YES //隐藏导航底部线条

static const char *kElementKey = "kElementKey";

#define TRBoxValue(value) _trBoxValue(@encode(__typeof__((value))), (value))
static inline id _getValue(const char *type, va_list v);
static inline id _trBoxValue(const char *type, ...) {
	va_list v;
	va_start(v, type);
	id obj = _getValue(type, v);
	va_end(v);
	return obj;
}
static inline id _getValue(const char *type, va_list v){
	id obj = nil;
	if (strcmp(type, @encode(id)) == 0) {
		id actual = va_arg(v, id);
		obj = actual;
	} else if (strcmp(type, @encode(int)) == 0) {
		int actual = (int)va_arg(v, int);
		obj = [NSString stringWithFormat:@"%d", actual];
	} else if (strcmp(type, @encode(float)) == 0) {
		float actual = (float)va_arg(v, double);
		obj = [NSString stringWithFormat:@"%f", actual];
	} else if (strcmp(type, @encode(double)) == 0) {
		double actual = (double)va_arg(v, double);
		obj = [NSString stringWithFormat:@"%f", actual];
	} else if (strcmp(type, @encode(long)) == 0) {
		long actual = (long)va_arg(v, long);
		obj = [NSString stringWithFormat:@"%ld", actual];
	} else if (strcmp(type, @encode(long long)) == 0) {
		long long actual = (long long)va_arg(v, long long);
		obj = [NSString stringWithFormat:@"%lld", actual];
	}
	return obj;
}

#define CGRectMakeScale(left, top, width, height) _CGRectMakeScale(TRBoxValue(left), TRBoxValue(top), TRBoxValue(width), TRBoxValue(height))
#define _CGRectMakeScale(_left, _top, _width, _height)\
({\
	CGRect rect;\
	CGFloat x = [_left floatValue];\
	CGFloat y = [_top floatValue];\
	CGFloat width = [_width floatValue];\
	CGFloat height = [_height floatValue];\
	if (SCREEN_HEIGHT <= 568.0f) rect = CGRectMake(x, y, width, height);\
	else {\
		rect.origin.x = x * ([_left isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1);\
		rect.origin.y = y * ([_top isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1);\
		rect.size.width = width * (width==SCREEN_WIDTH ? 1 : ([_width isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1));\
		rect.size.height = height * (height==SCREEN_HEIGHT ? 1 : ([_height isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1));\
	}\
	rect;\
})

#define CGSizeMakeScale(width, height) _CGSizeMakeScale(TRBoxValue(width), TRBoxValue(height))
#define _CGSizeMakeScale(_width, _height)\
({\
	CGSize size;\
	CGFloat width = [_width floatValue];\
	CGFloat height = [_height floatValue];\
	if (SCREEN_HEIGHT <= 568.0f) size = CGSizeMake(width, height);\
	else {\
		size.width = width * (width==SCREEN_WIDTH ? 1 : ([_width isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1));\
		size.height = height * (height==SCREEN_HEIGHT ? 1 : ([_height isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1));\
	}\
	size;\
})

#define CGPointMakeScale(left, top) _CGPointMakeScale(TRBoxValue(left), TRBoxValue(top))
#define _CGPointMakeScale(_left, _top)\
({\
	CGPoint point;\
	CGFloat left = [_left floatValue];\
	CGFloat top = [_top floatValue];\
	if (SCREEN_HEIGHT <= 568.0f) point = CGPointMake(left, top);\
	else {\
		point.x = left * ([_left isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1);\
		point.y = top * ([_top isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1);\
	}\
	point;\
})

#define UIEdgeInsetsMakeScale(top, left, bottom, right) _UIEdgeInsetsMakeScale(TRBoxValue(top), TRBoxValue(left), TRBoxValue(bottom), TRBoxValue(right))
#define _UIEdgeInsetsMakeScale(_top, _left, _bottom, _right)\
({\
	UIEdgeInsets insets;\
	CGFloat top = [_top floatValue];\
	CGFloat left = [_left floatValue];\
	CGFloat bottom = [_bottom floatValue];\
	CGFloat right = [_right floatValue];\
	if (SCREEN_HEIGHT <= 568.0f) insets = UIEdgeInsetsMake(top, left, bottom, right);\
	else {\
		insets.top = top * ([_top isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1);\
		insets.left = left * ([_left isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1);\
		insets.bottom = bottom * ([_bottom isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1);\
		insets.right = right *  ([_right isKindOfClass:[NSNumber class]]?SCREEN_SCALE:1);\
	}\
	insets;\
})

typedef enum : NSInteger {
	MapTravelTypeCar = 0,	// 驾车方式
	MapTravelTypeBus,		// 公交方式
	MapTravelTypeWalk,		// 步行方式
} MapTravelTypes;

#endif


#pragma mark - AFNetWorking单例
@interface AFNetwork : NSObject
+ (AFNetwork *)shared;
@end


@interface Global : NSObject

#pragma mark - 系统
+ (UIViewController*)currentController;
+ (BOOL)verticalScreen:(UIViewController*)view;
+ (BOOL)isNewVersion;
+ (NSString*)deviceString;
+ (NSString*)device;
+ (NSString*)getTelephonyNumber;
+ (void)copyString:(NSString*)string;
+ (id)getUserDefaults:(NSString*)key;
+ (NSString*)getUserDefaultsString:(NSString*)key;
+ (NSInteger)getUserDefaultsInteger:(NSString*)key;
+ (CGFloat)getUserDefaultsFloat:(NSString*)key;
+ (BOOL)getUserDefaultsBool:(NSString*)key;
+ (NSMutableArray*)getUserDefaultsArray:(NSString*)key;
+ (NSMutableDictionary*)getUserDefaultsDictionary:(NSString*)key;
+ (void)setUserDefaults:(NSString*)key data:(id)data;
+ (void)deleteUserDefaults:(NSString*)key;
+ (BOOL)isJailbroken;

#pragma mark - 导航
+ (UIView*)statusBar;
+ (CGFloat)statusBarHeight;
+ (void)statusBarHidden:(BOOL)hidden animated:(BOOL)animated;
+ (void)statusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated;
+ (CGFloat)navigationAndStatusBarHeight;
+ (CGFloat)navigationHeight;
+ (void)navigationBackgroundImage:(UIImage*)image;
+ (void)navigationTranslucent;

#pragma mark - 颜色
+ (UIColor*)colorFromHexRGB:(NSString*)colorString;
+ (UIColor*)colorFromHexRGB:(NSString*)colorString alpha:(CGFloat)alpha;
+ (UIColor*)colorFromImage:(UIImage*)img;
+ (UIColor*)colorFromImage:(UIImage*)img size:(CGSize)size;
+ (UIColor*)colorBetweenColor1:(UIColor*)color1 color2:(UIColor*)color2 percent:(CGFloat)percent;
+ (UIImage*)gradientColors:(NSArray*)colors gradientType:(NSInteger)gradientType size:(CGSize)size;

#pragma mark - 图片
+ (UIImage*)decodeImage:(UIImage*)image;
+ (UIImage*)maskingImage:(UIImage*)image colorArray:(NSArray*)color;
+ (void)saveImageToPhotos:(UIImage*)image;
+ (void)saveToAlbumWithImage:(UIImage*)image completion:(void (^)(BOOL success))completion;
+ (void)saveImageToDocument:(UIImage*)image withName:(NSString*)imageName;
+ (void)saveImageToTmp:(UIImage*)image withName:(NSString*)imageName;
+ (UIImage*)imageFile:(NSString*)imageName;
+ (UIImage*)imageFileFromDocument:(NSString*)imageName;
+ (UIImage*)imageFileFromTmp:(NSString*)imageName;
+ (UIImage*)blurImageWith:(UIImage*)image radius:(CGFloat)radius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor;
+ (UIImage*)rotatedImage:(UIImage*)image degrees:(CGFloat)degrees;
+ (UIImage*)rotatedImage:(UIImage*)image rotate:(CGFloat)rotate;
+ (UIImage*)grayImage:(UIImage*)image;
+ (void)animateImage:(UIImageView*)imageView duration:(NSTimeInterval)time repeat:(NSInteger)repeat images:(UIImage*)image,...;

#pragma mark - FSO
+ (NSString*)getFileFullname:(NSString*)filePath;
+ (NSString*)getFilename:(NSString*)filePath;
+ (NSString*)getSuffix:(NSString*)filePath;
+ (NSString*)getDocument;
+ (NSString*)getTmp;
+ (NSString*)getCaches;
+ (NSString*)getFilePathFromDocument:(NSString*)filename;
+ (NSString*)getFilePathFromTmp:(NSString*)filename;
+ (NSString*)getFilePathFromCaches:(NSString*)filename;
+ (NSString*)getFilePathFromAPP:(NSString*)filename;
+ (NSData*)getFileData:(NSString*)filePath;
+ (NSData*)getFileDataFromDocument:(NSString*)filename;
+ (NSData*)getFileDataFromTmp:(NSString*)filename;
+ (NSData*)getFileDataFromCaches:(NSString*)filename;
+ (NSString*)getFileText:(NSString*)filePath;
+ (NSString*)getFileTextFromDocument:(NSString*)filename;
+ (NSString*)getFileTextFromTmp:(NSString*)filename;
+ (NSString*)getFileTextFromCaches:(NSString*)filename;
+ (NSArray*)getFileList:(NSString*)folderPath;
+ (NSArray*)getFileListFromDocument;
+ (NSArray*)getFileListFromTmp;
+ (NSArray*)getFileListFromCaches;
+ (BOOL)fileExist:(NSString*)filePath;
+ (BOOL)fileExistFromDocument:(NSString*)filename;
+ (BOOL)fileExistFromTmp:(NSString*)filename;
+ (BOOL)fileExistFromCaches:(NSString*)filename;
+ (BOOL)fileExistFromAPP:(NSString*)filename;
+ (BOOL)folderExist:(NSString*)folderPath;
+ (BOOL)makeDir:(NSString*)folderPath;
+ (BOOL)makeDirFromDocument:(NSString*)foldername;
+ (BOOL)makeDirFromTmp:(NSString*)foldername;
+ (BOOL)makeDirFromCaches:(NSString*)foldername;
+ (void)deleteDir:(NSString*)folderPath killme:(BOOL)kill;
+ (void)deleteDirFromDocument:(NSString*)foldername killme:(BOOL)kill;
+ (void)deleteDirFromTmp:(NSString*)foldername killme:(BOOL)kill;
+ (void)deleteDirFromCaches:(NSString*)foldername killme:(BOOL)kill;
+ (BOOL)saveFile:(NSString*)filePath data:(NSData*)fileData;
+ (BOOL)saveFileToDocument:(NSString*)filename data:(NSData*)fileData;
+ (BOOL)saveFileToTmp:(NSString*)filename data:(NSData*)fileData;
+ (BOOL)saveFileToCaches:(NSString*)filename data:(NSData*)fileData;
+ (BOOL)saveFile:(NSString*)filePath content:(NSString*)content new:(BOOL)flag;
+ (BOOL)saveFileToDocument:(NSString*)filename content:(NSString*)content new:(BOOL)flag;
+ (BOOL)saveFileToTmp:(NSString*)filename content:(NSString*)content new:(BOOL)flag;
+ (BOOL)saveFileToCaches:(NSString*)filename content:(NSString*)content new:(BOOL)flag;
+ (void)renameFolder:(NSString*)folderPath to:(NSString*)newName;
+ (void)renameFile:(NSString*)filePath to:(NSString*)newName;
+ (BOOL)deleteFile:(NSString*)filePath;
+ (BOOL)deleteFileFromDocument:(NSString*)filename;
+ (BOOL)deleteFileFromTmp:(NSString*)filename;
+ (BOOL)deleteFileFromCaches:(NSString*)filename;
+ (long long)fileSize:(NSString*)filePath;
+ (long long)folderSize:(NSString*)folderPath;
+ (NSString*)formatSize:(long long)size unit:(NSString*)unit;
+ (NSMutableDictionary*)fileAttributes:(NSString*)filePath;
+ (NSMutableArray*)getPlistArray:(NSString*)filePath;
+ (NSMutableDictionary*)getPlistDictionary:(NSString*)filePath;
+ (NSMutableArray*)getPlistArrayFromTmp:(NSString*)filename;
+ (NSMutableDictionary*)getPlistDictionaryFromTmp:(NSString*)filename;
+ (BOOL)savePlist:(NSString*)filePath data:(id)data;
+ (BOOL)savePlistToDocument:(NSString*)filename data:(id)data;
+ (BOOL)savePlistToTmp:(NSString*)filename data:(id)data;
+ (BOOL)savePlistToCaches:(NSString*)filename data:(id)data;

#pragma mark - NETWORK
+ (void)get:(NSString*)url;
+ (void)get:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)get:(NSString*)url data:(NSDictionary*)data options:(NSDictionary*)options completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)post:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)upload:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)upload:(NSString*)url data:(NSDictionary*)data progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)postAuto:(NSString*)url data:(NSDictionary*)data completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)postAuto:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)get:(NSString*)url data:(NSDictionary*)data options:(NSDictionary*)options timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)post:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)postJSON:(NSString*)url data:(id)data timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)postJSON:(NSString*)url data:(id)data options:(NSDictionary*)options completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)post:(NSString*)url data:(id)data options:(NSDictionary*)options timeout:(NSTimeInterval)timeout completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)upload:(NSString*)url data:(NSDictionary*)data options:(NSDictionary*)options timeout:(NSTimeInterval)timeout progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSString *result))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (void)downloadImage:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion;
+ (void)downloadImage:(NSString*)url size:(CGSize)size completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion;
+ (void)downloadImageToPath:(NSString*)savePath url:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData, BOOL exist))completion;
+ (void)cacheImageWithUrl:(NSString*)url completion:(void (^)(UIImage *image, NSData *imageData))completion;
+ (void)cacheImageWithUrls:(NSArray*)urls completion:(void (^)(NSArray *images))completion;
+ (void)cacheToImageView:(UIImageView*)imageView url:(NSString*)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion;
+ (void)cacheToImageView:(UIImageView*)imageView url:(NSString*)url placeholder:(id)placeholder completion:(void (^)(UIImageView *imageView, UIImage *image, NSData *imageData, BOOL exist, BOOL isCache))completion animate:(void (^)(UIImageView *imageView, BOOL isCache))animate;
+ (void)download:(NSString*)url completion:(void (^)(NSString *fileName, NSData *fileData, BOOL exist))completion;

#pragma mark - 日期
+ (NSString*)now;
+ (NSTimeInterval)unix;
+ (NSTimeInterval)unixFromDate:(id)dt;
+ (NSDate*)dateFromUnix:(NSTimeInterval)unix;
+ (NSDate*)dateFromString:(NSString*)str;
+ (NSString*)formatDate:(id)dt;
+ (NSString*)formatDate:(id)dt format:(NSString*)str;
+ (NSString*)formatDateTime:(id)dt;
+ (NSString*)formatTime:(id)dt;
+ (NSInteger)getYear:(NSDate*)date;
+ (NSInteger)getMonth:(NSDate*)date;
+ (NSInteger)getWeek:(NSDate*)date;
+ (NSInteger)getDay:(NSDate*)date;
+ (NSInteger)getHour:(NSDate*)date;
+ (NSInteger)getMinute:(NSDate*)date;
+ (NSInteger)getSecond:(NSDate*)date;
+ (NSCalendar*)calendar;
+ (NSDateComponents*)compts:(NSDate*)date;
+ (NSTimeInterval)oneDay;
+ (NSTimeInterval)oneWeek;
+ (NSTimeInterval)oneMonth;
+ (NSTimeInterval)oneMonth:(NSInteger)days;
+ (NSTimeInterval)oneYear;
+ (NSInteger)getDateOffset:(NSInteger)delay range:(NSString*)range;
+ (NSDate*)dateAdd:(NSString*)range interval:(NSInteger)number date:(id)dt;
+ (NSInteger)dateDiff:(NSString*)range earlyDate:(id)earlyDate lateDate:(id)lateDate;
+ (NSArray*)getWeeksBeginAndEnd:(id)dt;
+ (NSString*)datetimeAndRandom;
+ (NSString*)getChineseYearWithDate:(NSDate*)date;
+ (NSString*)getChineseCalendarWithDate:(NSDate*)date;
+ (NSInteger)getWeekInYearOrMouth:(BOOL)inYear date:(NSDate*)date;

#pragma mark - UI操作
+ (UILabel*)multiLine:(CGRect)frame string:(NSString*)string font:(UIFont*)font;
+ (UILabel*)multiLine:(CGRect)frame string:(NSString*)string font:(UIFont*)font lineheight:(CGFloat)linespace;
+ (void)zoomView:(UIView*)view;
+ (void)zoomView:(UIView*)view duration:(CGFloat)duration percent:(CGFloat)percent;
+ (void)moveView:(UIView*)view to:(CGRect)frame time:(CGFloat)time;
+ (void)throwView:(UIView*)view endpoint:(CGPoint)endpoint completion:(void (^)(void))completion;
+ (void)transformScreen:(UIViewController*)view;
+ (void)transformScreen:(UIViewController*)view orientation:(NSString*)orientation;
+ (void)scaleView:(UIView*)view percent:(CGFloat)percent;
+ (void)scaleAnimate:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)(void))completion;
+ (void)scaleAnimateBounces:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent completion:(void (^)(void))completion;
+ (void)scaleAnimateBounces:(UIView*)view time:(NSTimeInterval)time percent:(CGFloat)percent bounce:(CGFloat)bounce completion:(void (^)(void))completion;
+ (void)rotatedView:(UIView*)view degrees:(CGFloat)degrees;
+ (void)rotatedView:(UIView*)view degrees:(CGFloat)degrees center:(CGPoint)center;
+ (void)rotateAnimate:(UIView*)view time:(NSTimeInterval)time degrees:(CGFloat)degrees completion:(void (^)(void))completion;
+ (void)rotateAnimate:(UIView*)view time:(NSTimeInterval)time degrees:(CGFloat)degrees center:(CGPoint)center completion:(void (^)(void))completion;
+ (void)rotate3DAnimate:(UIView*)view delegate:(id)delegate;
+ (CAAnimation*)rotate3DAnimate;
+ (void)pageCurlAnimation:(UIView*)view time:(NSTimeInterval)time delegate:(id)delegate;
+ (CGRect)autoXYWithCellCount:(NSInteger)count width:(CGFloat)w height:(CGFloat)h blank:(CGFloat)b marginTop:(CGFloat)t marginLeft:(CGFloat)l uIndex:(NSNumber**)u vIndex:(NSNumber**)v;
+ (CGRect)autoXYInWidth:(CGFloat)width subview:(UIView*)subview marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb;
+ (CGRect)autoXYInWidth:(CGFloat)width subview:(UIView*)subview frame:(CGRect)subviewFrame marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r prevRight:(NSNumber**)pr prevBottom:(NSNumber**)pb;
+ (void)autoLayoutWithView:(UIView*)view subviews:(NSMutableArray*)subviews marginPT:(CGFloat)t marginPL:(CGFloat)l marginPR:(CGFloat)r;
+ (void)showMenuControllerWithTarget:(UIView*)target titles:(NSArray*)titles actions:(NSArray*)actions;

#pragma mark - 其他
+ (float)decimalFormat:(float)num scale:(int)scale;
+ (NSString*)getIP;
+ (NSMutableDictionary*)countdown:(NSInteger)seconds;
+ (CGSize)fitToSize:(CGSize)size originSize:(CGSize)origin;
+ (CGSize)fitToSize:(CGSize)size originSize:(CGSize)origin fix:(CGFloat)fix;
+ (void)openCall:(NSString*)tel;
+ (void)openSms:(NSString*)tel;
+ (void)openQQ:(NSString*)uin;
+ (void)openWechat:(NSString*)uin;
+ (void)openMap:(double)latitude longitude:(double)longitude;
+ (NSArray*)mapApps;
+ (void)openMapApp:(NSString*)title travelType:(MapTravelTypes)travelType latitude:(double)latitude longitude:(double)longitude;
+ (void)checkVersion;
+ (NSInteger)randomFrom:(NSInteger)from to:(NSInteger)to;
+ (double)randomFloatFrom:(double)from to:(double)to;
+ (NSString*)randomString:(NSInteger)length;
+ (NSInteger)getMoveDirectionWithTranslation:(CGPoint)translation direction:(NSInteger)direction;
+ (void)repeatDo:(NSTimeInterval)delay function:(void (^)(void))function;
+ (BOOL)isNetwork:(BOOL)showMsg;
+ (void)GFileList:(NSString*)folderPath;
+ (void)showLocalNotification:(NSString*)body;
+ (void)notificationRegisterWithObserver:(id)observer selector:(SEL)selector name:(NSString*)name object:(id)object;
+ (void)notificationPostWithName:(NSString*)name object:(id)object;
+ (void)notificationRemoveObserver:(id)observer;
+ (BOOL)isAllowedNotification;
+ (BOOL)registerNotification;
+ (BOOL)unregisterNotification;
+ (NSInteger)getCachesSize;
+ (void)removeAllCache;
+ (void)removeDiskCache;
+ (void)removeMemoryCache;
+ (void)removeCacheForKey:(NSString*)key;
+ (void)playVoice:(NSString*)voicePath;
+ (void)touchIDWithReason:(NSString*)reason passwordTitle:(NSString*)passwordTitle success:(void (^)(void))successBlock fail:(void (^)(NSError *error))fail nosupport:(void (^)(void))nosupport;

#pragma mark - 本类
+ (Global*)sharedHelper;

@end
