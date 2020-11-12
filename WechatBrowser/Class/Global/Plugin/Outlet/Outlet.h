//
//  Outlet.h
//
//  Created by ajsong on 2019/1/3.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Outlet;

@protocol OutletDelegate<NSObject>
@optional
- (void)OutletDidStartLoad:(Outlet*)controller; //开始加载
- (void)OutletLoadViewWith:(Outlet*)controller; //可后期修改界面
- (void)OutletDidFinishLoadWith:(Outlet*)controller url:(NSString*)url html:(NSString*)html; //载入完页面后操作
- (BOOL)OutletStartLoadUrlWith:(Outlet*)controller url:(NSString*)url; //每次载入执行判断操作, 返回NO:不跳转
- (void)OutletLinkActWith:(Outlet*)controller act:(NSString*)act; //网址调用app-act://
- (void)OutletLinkJavascriptWith:(Outlet*)controller javascript:(NSString*)javascript; //点击的链接为javascript:
@end

@interface Outlet : UIViewController
@property (nonatomic,copy) void(^viewWillAppear)(); //视图将载入时执行
@property (nonatomic,copy) void(^viewWillDisappear)(); //视图将退出时执行
@property (nonatomic,weak) id<OutletDelegate> delegate;
@property (nonatomic,assign) NSInteger tag;
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) NSString *url; //载入网址
@property (nonatomic,strong) NSString *html; //载入HTML代码
@property (nonatomic,strong) NSString *getHtml; //当前HTML代码
@property (nonatomic,strong) NSString *userAgentMark; //浏览器标识,为空即默认为ruandao
@property (nonatomic,assign) NSURLRequestCachePolicy cachePolicy; //网页缓存策略
@property (nonatomic,assign) NSTimeInterval timeout; //加载超时,默认10秒
@property (nonatomic,strong) NSString *defaultTitle; //默认标题,默认"详情"
@property (nonatomic,assign) BOOL autoTitle; //自动根据网页设置title,默认NO
@property (nonatomic,assign) BOOL isWebGoBack; //是否使用网页后退,默认YES
@property (nonatomic,assign) BOOL isFullscreen; //是否全屏,默认NO
@property (nonatomic,assign) BOOL isTwoFingerReload; //双指下拖重载页面,默认YES
@property (nonatomic,assign) BOOL zoomImage; //自动缩放图片,默认YES
@property (nonatomic,strong) UIImage *leftImage; //全屏时的左按钮图片
@property (nonatomic,copy) void(^leftBlock)(Outlet *sender); //导航左按钮操作
@property (nonatomic,strong) NSString *rightText; //导航右按钮文字, !isFullscreen 有效
@property (nonatomic,strong) UIImage *rightImage; //导航右按钮图片
@property (nonatomic,strong) UIView *rightView; //导航右按钮自定义, !isFullscreen 有效
@property (nonatomic,copy) void(^rightBlock)(Outlet *sender); //导航右按钮操作
@property (nonatomic,copy) void(^startLoadUrl)(Outlet *vc, NSString *url); //每次载入执行
@property (nonatomic,assign) BOOL statusBarBlack; //设置状态栏为黑色,默认NO
@property (nonatomic,assign) BOOL statusBarHidden; //隐藏状态栏,默认NO
@property (nonatomic,strong) CALayer *progressLayer;
@property (nonatomic,assign) BOOL isProgressLoad; //是否使用进度加载指示器
@property (nonatomic,assign) BOOL isProgressHUD; //是否使用加载指示器
@property (nonatomic,assign) BOOL isVer; //网址增加SDK版本参数,默认YES
@property (nonatomic,assign) BOOL isParameter; //网址增加接口参数,默认NO
@property (nonatomic,assign) BOOL isSign; //网址增加sign参数,默认YES
@property (nonatomic,assign) CGFloat autoHideNav; //自动隐藏导航栏距离(类似商品详情界面)(使用自定义导航栏)
- (NSMutableDictionary*)params;
- (NSMutableDictionary*)params:(NSString*)mark;
- (void)goBack;
- (void)setUrlNonLoad:(NSString *)url;
- (void)setUrl:(NSString *)url nonLoad:(BOOL)nonLoad;
- (void)setUrl:(NSString *)url nonLoad:(BOOL)nonLoad param:(id)param;
- (void)setHtml:(NSString *)html baseURL:(NSURL *)baseURL;
- (void)reload;
- (void)removeCache;
- (void)javascript:(NSString *)js completion:(void (^)(id obj, NSError *error))completion;
- (void)OutletDidStartLoad;
- (void)OutletViewDidLoad;
- (void)OutletDidFinishLoad:(NSString*)url html:(NSString*)html;
- (BOOL)OutletStartLoadUrl:(NSString*)url;
- (void)OutletLinkAct:(NSString*)act;
- (void)OutletLinkJavascript:(NSString*)javascript;
@end
