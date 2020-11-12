//
//  Group+Extend.h
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
@class AJProgressView;

#pragma mark - UIWindow+Extend
@interface UIWindow (GlobalExtend)
- (UIViewController*)currentController;
- (UIView*)statusBar;
- (CGFloat)statusBarHeight;
@end


#pragma mark - UINavigationController+UITabBarController+Extend
@interface UINavigationController (GlobalExtend)
- (void)setBackgroundColor:(UIColor *)bgcolor textColor:(UIColor *)textcolor;
- (void)setUnderLineColor:(UIColor *)color;
- (void)deleteUnderLine;
- (void)setHiddenUnderLine:(BOOL)hiddenUnderLine;
- (UIImageView*)getUnderLine:(UIView*)view;
- (void)autoHidden;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (UIViewController*)popViewControllerAnimated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion;
- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion;
- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion;
- (UIViewController*)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated;
- (UIViewController*)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion;
- (void)setViewControllersArray:(NSArray *)controllersArray animated:(BOOL)animated;
- (BOOL)hasControllerOfClass:(Class)cls;
@end
@interface UITabBarController (GlobalExtend)
@end


#pragma mark - UIAlertController+Extend
@interface UIAlertController (GlobalExtend)
+ (void)alert:(NSString*)message;
+ (void)alert:(NSString*)message block:(void(^)(NSInteger buttonIndex))block;
+ (void)alert:(NSString*)message submit:(NSString*)submit block:(void(^)(NSInteger buttonIndex))block;
+ (void)alert:(NSString*)message cancel:(NSString*)cancel submit:(NSString*)submit block:(void(^)(NSInteger buttonIndex))block;
+ (void)alert:(NSString*)title message:(NSString*)message cancel:(NSString*)cancel submit:(NSString*)submit block:(void(^)(NSInteger buttonIndex))block;
+ (void)action:(NSString*)message buttons:(NSArray*)buttons block:(void(^)(NSInteger buttonIndex))block;
+ (void)action:(NSString*)message buttons:(NSArray*)buttons cancel:(NSString*)cancel block:(void(^)(NSInteger buttonIndex))block;
@end


#pragma mark - UIITextField
@interface UIITextField : UITextField
@property (nonatomic,strong) UIColor *placeholderColor;
@property (nonatomic,strong) UIFont *placeholderFont;
@property (nonatomic,assign) UIEdgeInsets padding;
@property (nonatomic,assign) NSInteger separateLength; //用空格分隔字符
@property (nonatomic,assign) NSInteger maxLength; //限制字符长度
@property (nonatomic,assign) NSInteger decimalNum; //小数位数限制
@property (nonatomic,strong) NSString *allowContent; //允许输入的内容(正则),如正负整数@"^(-)?([1-9][0-9]*)?$"
@property (nonatomic,assign) BOOL disablePaste; //禁止粘贴
- (void)setSeparateLength:(NSInteger)separateLength separator:(NSString*)separator;
@end


#pragma mark - UIITextView
@protocol UIITextViewDelegate<UITextViewDelegate>
@optional
- (void)textView:(UITextView *)textView currentHeight:(CGFloat)height;
- (void)textView:(UITextView *)textView currentLength:(NSInteger)length;
@end
@interface IIAttachment : NSTextAttachment
@property(strong, nonatomic) NSString *imageTag;
@end
@interface NSAttributedString (InsetImage)
- (NSString*)code;
@end
@interface UIITextView : UITextView
@property (nonatomic,strong) NSString *placeholder;
@property (nonatomic,strong) UIColor *placeholderColor;
@property (nonatomic,strong) UIFont *placeholderFont;
@property (nonatomic,assign) BOOL placeholderHidden;
@property (nonatomic,assign) UIEdgeInsets padding;
@property (nonatomic,assign) CGFloat lineHeight;
@property (nonatomic,assign) NSInteger numberOfLines; //设置后自动高度
@property (nonatomic,assign) NSInteger maxlength; //最大字数
@property (nonatomic,assign) BOOL disablePaste; //禁止粘贴
- (void)insertImage:(UIImage*)image imageMark:(NSString*)imageMark;
- (void)insertImage:(UIImage*)image imageMark:(NSString*)imageMark imageWidth:(CGFloat)width imageHeight:(CGFloat)height;
- (NSString*)code;
- (void)placeholderCheckText;
- (void)textViewDidChangeText:(UITextView*)textView;
@end


#pragma mark - UIITableView
@interface UIITableView : UITableView
@property (nonatomic,assign) UITableViewCellStyle cellStyle;
@property (nonatomic,copy) NSInteger(^numberOfSectionsInTableView)(UITableView *tableView);
@property (nonatomic,copy) NSInteger(^numberOfRowsInSection)(UITableView *tableView, NSInteger section);
@property (nonatomic,copy) CGFloat(^heightForRowAtIndexPath)(UITableView *tableView, NSIndexPath *indexPath);
@property (nonatomic,copy) void(^cellForRowAtIndexPath)(UITableView *tableView, NSIndexPath *indexPath, UITableViewCell *cell);
@property (nonatomic,copy) void(^didSelectRowAtIndexPath)(UITableView *tableView, NSIndexPath *indexPath);
@end


#pragma mark - UISearchBar+Extend
@interface UISearchBar (GlobalExtend)
- (UITextField*)textField;
- (UIColor*)textColor;
- (void)setTextColor:(UIColor*)textColor;
- (UIFont*)font;
- (void)setFont:(UIFont*)font;
- (UIColor*)placeholderColor;
- (void)setPlaceholderColor:(UIColor*)placeholderColor;
@end


#pragma mark - UIScrollView+Extend
@interface UIScrollView (GlobalExtend)
- (void)doubleZoomWithView:(UIView*)zoomView dataHeight:(CGFloat)dataHeight maxHeight:(CGFloat)maxHeight scrollViewDidZoom:(void (^)(UIScrollView *scrollView, CGFloat scale))scrollViewDidZoom;
@end


#pragma mark - AJLaunchImage
typedef enum : NSInteger {
	AJLaunchImageTypeFullscreen = 0, //全屏
	AJLaunchImageTypeSquare, //正方形
} AJLaunchImageType;
@interface AJLaunchImage : UIView
@property (nonatomic,strong) UIImageView *imageView; //广告图片
@property (nonatomic,assign) AJLaunchImageType type; //图片类型
@property (nonatomic,assign) int timeout; //倒计时长,默认5秒
@property (nonatomic,strong) UIImage *ico; //LOGO图片,默认LOGO
@property (nonatomic,strong) NSString *name; //标题
@property (nonatomic,strong) NSString *slogan; //标语
@property (nonatomic,strong) AJProgressView *progress; //进度圈
@property (nonatomic,strong) NSString *progressText; //进度圈中间的文字,默认数字
@property (nonatomic,strong) NSString *onlyText; //只显示文字,进度圈会变成长方形且没有了进度条,%s替换成数字
@property (nonatomic,copy) void(^completion)(); //将要隐藏时执行
- (void)show;
- (void)dismiss;
@end


#pragma mark - UIBadger
@interface UIBadger : UILabel
@end


#pragma mark - AJCutoverView
//上下UIView切换(摩擦效果切换)
@protocol AJCutoverViewDelegate;
typedef enum : NSInteger {
	AJCutoverViewTypeBottom = 0,
	AJCutoverViewTypeTop,
} AJCutoverViewType;
@interface AJCutoverView : UITableView<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (nonatomic,weak) id<AJCutoverViewDelegate> changeDelegate;
@property (nonatomic,strong) UIView *topView; //上部分
@property (nonatomic,strong) UIView *bottomView; //下部分(一般为列表)
@property (nonatomic,strong) UIScrollView *panScrollView; //绑定下拉拖动主表的滚动view
@property (nonatomic,assign) CGFloat distance; //切换临界点,默认60
@property (nonatomic,assign) AJCutoverViewType type; //显示类型
@end
@protocol AJCutoverViewDelegate<NSObject>
@optional
- (void)AJCutoverView:(AJCutoverView*)cutoverView changeType:(AJCutoverViewType)type;
@end


#pragma mark - AJWebView
@interface AJWebView : WKWebView
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) UIFont *font;
@property (nonatomic,assign) UIEdgeInsets padding;
@property (nonatomic,strong) NSString *style;
@property (nonatomic,strong) NSString *script;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *html;
- (void)autoHeightWithHtml:(NSString *)html finishLoad:(void (^)(AJWebView *webView))finishLoad;
- (void)didFinishLoad:(void (^)(NSString *html))finishLoad; //网页载入后执行
@end


#pragma mark - NSDate+Extend
@interface NSDate (GlobalExtend)
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)week;
- (NSInteger)day;
- (NSInteger)hour;
- (NSInteger)minute;
- (NSInteger)second;
@end


#pragma mark - UIColor+Extend
@interface UIColor (GlobalExtend)
+ (UIColor*)randomColor;
- (CGFloat)alpha;
- (UIColor*)setAlpha:(CGFloat)alpha;
- (NSString*)string;
- (UIImage*)imageWithSize:(CGSize)size;
- (UIColor*)lighter;
- (UIColor*)darker;
+ (UIColor*)gradientColors:(NSArray*)colors bounds:(CGRect)bounds startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
@end


#pragma mark - NSData+Extend
@interface NSData (GlobalExtend)
- (BOOL)isImage;
- (BOOL)isGIF;
- (UIImage*)gif;
- (NSString*)base64;
- (NSString*)base64WithMark;
- (NSString*)suffix;
- (NSString*)mimeType;
- (void)UploadToUpyun:(NSString*)upyunFolder completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToQiniu:(NSString*)token completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToQiniu:(NSString*)token imageName:(NSString*)imageName completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion;
- (void)UploadToQiniu:(NSString*)token imageName:(NSString*)imageName progress:(void (^)(NSProgress *progress))progress completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion;
@end


#pragma mark - NSTimer+Extend
@interface NSTimer (GlobalExtend)
//action返回YES即停止重复
+ (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats action:(BOOL (^)(NSTimer *timer))action;
+ (NSTimer*)timerWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats action:(BOOL (^)(NSTimer *timer))action;
+ (void)executeAction:(NSTimer*)timer;
- (void)pause;
- (void)resume;
- (void)stop;
@end


#pragma mark - AdModel
#define ADMODEL_TYPES @[@"html5", @"goods", @"shop", @"article", @"type", @"subtype", @"brand", @"coupon", @"recharge", @"country", @"register"]
@interface AdModel : NSObject
- (void)selectType:(NSString*)type content:(NSString*)content;
+ (void)selectType:(NSString*)type content:(NSString*)content;
@end


#pragma mark - FileDownloader
@interface FileDownloader : NSObject
@property (nonatomic,retain) NSString *url;
@property (nonatomic,assign) NSTimeInterval timeout;
@property (nonatomic,copy) void (^progress)(double progress, long dataSize, long long currentSize, long long totalSize);
@property (nonatomic,copy) void (^completion)(NSData *data, BOOL exist);
@property (nonatomic,copy) void (^fail)(NSString *description, NSInteger code);
+ (FileDownloader*)downloadWithUrl:(NSString*)url completion:(void(^)(NSData *data, BOOL exist))completion fail:(void (^)(NSString *description, NSInteger code))fail;
+ (FileDownloader*)downloadWithUrl:(NSString*)url timeout:(NSTimeInterval)timeout progress:(void(^)(double progress, long dataSize, long long currentSize, long long totalSize))progress completion:(void(^)(NSData *data, BOOL exist))completion fail:(void (^)(NSString *description, NSInteger code))fail;
- (void)start;
- (void)pause;
- (void)stop;
@end


#pragma mark - One Finger Rotation
@interface OneFingerRotationGestureRecognizer : UIGestureRecognizer
@property (nonatomic,assign) CGFloat rotation;
@end


#pragma mark - QueueHandle
/*
 QueueHandle *queue = [[QueueHandle alloc]init];
 for (int i=0; i<5; i++) {
	[queue queueHandleBlock:^{
		 CGRect frame = _btn.frame;
		 frame.origin.y -= 30;
		 [UIView animateWithDuration:1.0 animations:^{
			_btn.frame = frame;
		 } completion:^(BOOL finished) {
			[queue completionBlock:nil];
		 }];
	}];
 }
 */
@interface QueueHandle : NSObject
- (void)queueHandleBlock:(void (^)(void))operate;
- (void)completionBlock:(void (^)(void))completion;
@end


#pragma mark - Simulation Data
@interface NSDictionary (SimulationData)
+ (NSMutableDictionary*)simulationDetail;
+ (NSMutableDictionary*)simulationDetail:(int)day;
@end
@interface NSArray (SimulationData)
+ (NSMutableArray*)simulationAD;
+ (NSMutableArray*)simulationAD:(int)count;
+ (NSMutableArray*)simulationType;
+ (NSMutableArray*)simulationType:(int)count;
+ (NSMutableArray*)simulationList;
+ (NSMutableArray*)simulationList:(int)count;
+ (NSMutableArray*)simulationList:(int)count apartDay:(int)day;
@end
