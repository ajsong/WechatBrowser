//
//  Outlet.m
//
//  Created by ajsong on 2019/1/3.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import "Outlet.h"

#define kProgressHeight 1.5*SCREEN_SCALE

@interface Outlet ()<KKNavigationControllerDelegate,UIGestureRecognizerDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>{
	UIStatusBarStyle _originStatusBarStyle;
	BOOL _originStatusBarHidden;
	BOOL _navigationBarHidden;
	UIPanGestureRecognizer *_panGesture;
	UIView *_progressView;
	BOOL _isReloading;
	BOOL _isLoaded;
	id _param;
}
@end

@implementation Outlet

- (instancetype)init{
	self = [super init];
	if (self) {
		_originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
		_originStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
		_getHtml = @"";
		_defaultTitle = @"详情";
		_zoomImage = YES;
		_isWebGoBack = YES;
		_isProgressLoad = YES;
		_isProgressHUD = YES;
		_isVer = YES;
		_isSign = YES;
		_autoHideNav = -1;
		_cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
		_timeout = 10.0f;
		if (APPCurrentController.navigationController) {
			_navigationBarHidden = APPCurrentController.navigationController.navigationBarHidden;
		}
		
		_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerReload:)];
		_panGesture.minimumNumberOfTouches = 2;
		_panGesture.maximumNumberOfTouches = 2;
		_panGesture.delaysTouchesBegan = YES;
		_panGesture.delegate = self;
	}
	return self;
}

- (void)navigationWillPopViewController:(KKNavigationController *)navigationController isGesture:(BOOL)flag{
	[_webView loadHTMLString:@"" baseURL:nil];
	_webView.navigationDelegate = nil;
	_webView.UIDelegate = nil;
	[_webView removeFromSuperview];
	_webView = nil;
}

- (void)navigationDidPopFromViewController:(KKNavigationController *)navigationController isGesture:(BOOL)flag{
	[ProgressHUD dismiss];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	if (_viewWillAppear) _viewWillAppear();
	if (_isFullscreen) {
		if (_statusBarBlack) {
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
		} else {
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
		}
		//[[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden withAnimation:UIStatusBarAnimationSlide];
		if (_statusBarHidden) {
			[UIView animateWithDuration:0.3 animations:^{
				[self statusBar].alpha = 0;
			}];
		}
		if (self.navigationController) [self.navigationController setNavigationBarHidden:YES animated:YES];
	}
	if (_isProgressLoad) {
		if (!_isFullscreen && self.navigationController) {
			_progressView.frame = CGRectMake(0, self.navigationController.navigationBar.bounds.size.height, self.view.frame.size.width, kProgressHeight);
			[self.navigationController.navigationBar addSubview:_progressView];
		} else {
			_progressView.frame = CGRectMake(0, 0, self.view.frame.size.width, kProgressHeight);
			[self.view addSubview:_progressView];
		}
		if (isX) {
			_progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		} else {
			_progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		}
		[_webView fm_addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
	}
	//解决WebView内点击视频全屏播放,退出后导致状态栏被隐藏
	//监听UIWindow显示
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginFullScreen) name:UIWindowDidBecomeVisibleNotification object:nil];
	//监听UIWindow隐藏
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullscreen) name:UIWindowDidBecomeHiddenNotification object:nil];
	if (!_webView.title.length) {
		[_webView reload];
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	if (_viewWillDisappear) _viewWillDisappear();
	if ([self.navigationController isKindOfClass:[KKNavigationController class]]) {
		if (self.navigationControllerKK.disableDragBack) self.navigationControllerKK.disableDragBack = NO;
	}
	if (_isFullscreen) {
		[[UIApplication sharedApplication] setStatusBarStyle:_originStatusBarStyle animated:YES];
		//[[UIApplication sharedApplication] setStatusBarHidden:_originStatusBarHidden withAnimation:UIStatusBarAnimationSlide];
		[UIView animateWithDuration:0.3 animations:^{
			[self statusBar].alpha = 1;
		}];
		if (self.navigationController) [self.navigationController setNavigationBarHidden:_navigationBarHidden animated:YES];
	}
	if (_isProgressLoad) {
		[_progressView removeFromSuperview];
		//[_webView removeObserver:self forKeyPath:@"estimatedProgress"];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeHiddenNotification object:nil];
}

- (void)endFullscreen{
	[[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden withAnimation:UIStatusBarAnimationSlide];
}

- (NSMutableDictionary*)params{
	return self.url.params;
}
- (NSMutableDictionary*)params:(NSString*)mark{
	return [self.url params:mark];
}

- (void)goBack{
	if (_isWebGoBack && _webView.canGoBack) {
		[_webView goBack];
	} else {
		if (self.navigationController && ![self.navigationController.viewControllers.firstObject isEqual:self]) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

- (void)viewDidLoad{
	[super viewDidLoad];
	self.view.backgroundColor = COLORWHITE;
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	if (_isProgressLoad) {
		_progressView = [[UIView alloc]init];
		_progressView.backgroundColor = COLORCLEAR;
		_progressLayer = [CALayer layer];
		_progressLayer.frame = CGRectMake(0, 0, 0, kProgressHeight);
		_progressLayer.backgroundColor = COLORGREEN.CGColor;
		[_progressView.layer addSublayer:_progressLayer];
	}
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":KEYWINDOW.element[@"userAgent"]}];
	CGFloat webViewHeight = self.height;
	WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
	configuration.allowsInlineMediaPlayback = YES;
	[configuration setValue:@YES forKey:@"_allowUniversalAccessFromFileURLs"];
	WKUserContentController *userController = [[WKUserContentController alloc] init];
	configuration.userContentController = userController;
	_webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, webViewHeight) configuration:configuration];
	_webView.backgroundColor = [UIColor clearColor];
	_webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	_webView.navigationDelegate = self;
	_webView.UIDelegate = self;
	[userController addScriptMessageHandler:self name:@"showConsole"];
	[self showConsole];
	
	UIImage *returnImage = _leftImage ? _leftImage : [IMG(@"return") overlayWithColor:COLORNAVTEXT];
	if (_isFullscreen) {
		if (@available(iOS 11.0, *)) {
			_webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
		} else if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
			self.automaticallyAdjustsScrollViewInsets = NO;
		}
		_webView.height = SCREEN_HEIGHT;
		if (isX) _webView.scrollView.contentInset = UIEdgeInsetsMake(self.navigationAndStatusBarHeight, 0, 0, 0);
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(6, STATUSBAR_HEIGHT, 44, 44)];
				btn.backgroundColor = [UIColor clearColor];
				[btn setBackgroundImage:returnImage forState:UIControlStateNormal];
				[btn addTarget:self action:^(id target, id sender) {
					if (_leftBlock) {
						_leftBlock(target);
						return;
					}
					[(Outlet*)target goBack];
				}];
				[self.view addSubview:btn];
			});
		});
		if (_rightImage) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width-44-6, STATUSBAR_HEIGHT, 44, 44)];
					btn.backgroundColor = [UIColor clearColor];
					[btn setBackgroundImage:_rightImage forState:UIControlStateNormal];
					if (_rightBlock) {
						[btn addTarget:self action:^(id target, id sender) {
							_rightBlock(target);
						}];
					}
					[self.view addSubview:btn];
				});
			});
		}
	} else {
		if (_leftBlock) {
			KKNavigationBarItem *item = [self.navigationItem setItemWithImage:returnImage size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
			[item addTarget:self action:^(id target, id sender) {
				_leftBlock(target);
			}];
		} else if (_isWebGoBack && self.navigationController.viewControllers.count>1) {
			KKNavigationBarItem *item = [self.navigationItem setItemWithImage:returnImage size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
			[item addTarget:self action:^(id target, id sender) {
				[(Outlet*)target goBack];
			}];
		}
		if (_rightText.length) {
			KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:_rightText textColor:COLORNAVTEXT fontSize:14 itemType:KKNavigationItemTypeRight];
			if (_rightBlock) {
				[item addTarget:self action:^(id target, id sender) {
					_rightBlock(target);
				}];
			}
		}
		if (_rightView) {
			KKNavigationBarItem *item = [self.navigationItem setItemWithCustomView:_rightView itemType:KKNavigationItemTypeRight];
			if (_rightBlock) {
				[item addTarget:self action:^(id target, id sender) {
					_rightBlock(target);
				}];
			}
		}
	}
	[self.view addSubview:_webView];
	
	if (_html.length) {
		[_webView loadHTMLString:_html baseURL:nil];
	} else {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				if (self.title.length) {
					_autoTitle = NO;
				} else {
					if (_defaultTitle.length) self.title = _defaultTitle;
				}
			});
		});
		
		[_webView.scrollView addGestureRecognizer:_panGesture];
		
		NSURL *URL = [NSURL URLWithString:_url];
		if (URL == nil) URL = [NSURL URLWithString:[_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		if (_param) {
			NSMutableArray *params = [[NSMutableArray alloc]init];
			if ([_param isKindOfClass:[NSString class]]) {
				[params addObject:_param];
			} else if ([_param isKindOfClass:[NSArray class]]) {
				params = _param;
			} else if ([_param isKindOfClass:[NSDictionary class]]) {
				for (NSString *key in _param) {
					[params addObject:FORMAT(@"%@=%@", key, [_param objectForKey:key])];
				}
			}
			NSData *postData = [[params implode:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
			NSString *contentLength = [NSString stringWithFormat:@"%ld", (long)postData.length];
			NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeout];
			[request setHTTPMethod:@"POST"];
			[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			[request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
			[request setHTTPBody:postData];
			[_webView loadRequest:request];
		} else {
			NSURLRequest *request = [[NSURLRequest alloc]initWithURL:URL cachePolicy:_cachePolicy timeoutInterval:_timeout];
			[_webView loadRequest:request];
		}
	}
	[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"estimatedProgress"]) {
		_progressLayer.opacity = 1;
		if ([change[@"new"] floatValue] < [change[@"old"] floatValue]) return;
		_progressLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width * [change[@"new"] floatValue], kProgressHeight);
		if ([change[@"new"] floatValue] == 1) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				_progressLayer.opacity = 0;
			});
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				_progressLayer.frame = CGRectMake(0, 0, 0, kProgressHeight);
			});
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)setAutoHideNav:(CGFloat)autoHideNav{
	_autoHideNav = autoHideNav;
	if (autoHideNav>-1) {
		[self wr_setNavBarBackgroundAlpha:autoHideNav];
	}
}

- (void)loadViews{
	if (_delegate && [_delegate respondsToSelector:@selector(OutletLoadViewWith:)]) {
		[_delegate OutletLoadViewWith:self];
	}
	if ([self respondsToSelector:@selector(OutletViewDidLoad)]) {
		[self OutletViewDidLoad];
	}
}

- (void)setIsTwoFingerReload:(BOOL)isTwoFingerReload{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			[_webView.scrollView removeGestureRecognizer:_panGesture];
			if (isTwoFingerReload) {
				[_webView.scrollView addGestureRecognizer:_panGesture];
			}
		});
	});
}

- (void)twoFingerReload:(UIPanGestureRecognizer*)recognizer{
	static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan: {
			if (direction == UIPanGestureRecognizerDirectionUndefined) {
				CGPoint velocity = [recognizer velocityInView:recognizer.view];
				BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
				if (isVerticalGesture) {
					if (velocity.y > 0) {
						direction = UIPanGestureRecognizerDirectionDown;
					} else {
						direction = UIPanGestureRecognizerDirectionUp;
					}
				} else {
					if (velocity.x > 0) {
						direction = UIPanGestureRecognizerDirectionRight;
					} else {
						direction = UIPanGestureRecognizerDirectionLeft;
					}
				}
			}
			break;
		}
		case UIGestureRecognizerStateEnded: {
			if (direction == UIPanGestureRecognizerDirectionDown) {
				[self removeCache];
				[self reload];
			}
			direction = UIPanGestureRecognizerDirectionUndefined;
			break;
		}
		default:
			break;
	}
}

- (void)setUrl:(NSString *)url{
	[self setUrl:url nonLoad:NO param:nil];
}

- (void)setUrlNonLoad:(NSString *)url{
	[self setUrl:url nonLoad:YES param:nil];
}

- (void)setUrl:(NSString *)url nonLoad:(BOOL)nonLoad{
	[self setUrl:url nonLoad:nonLoad param:nil];
}

- (void)setUrl:(NSString *)url nonLoad:(BOOL)nonLoad param:(id)param{
	NSArray *urls = [url explode:@"#"];
	url = urls[0];
	if (![url hasPrefix:@"http"]) {
		url = [url replace:API_URL to:@""];
		if ([url hasPrefix:@"/"]) url = [url substringFromIndex:1];
		url = FORMAT(@"%@/%@", API_URL, url);
	}
	if ([url hasPrefix:API_URL]) {
		if (_isVer) url = [NSString stringWithFormat:@"%@%@sdk=%@", url, ([url indexOf:@"?"]!=NSNotFound?@"&":@"?"), SDK_VERSION];
		if (_isParameter) url = [NSString stringWithFormat:@"%@%@%@", url, ([url indexOf:@"?"]!=NSNotFound?@"&":@"?"), [[API_PARAMETER replace:FORMAT(@"&sign=%@", SIGN) to:@""] trim:@"&"]];
		if (_isSign) url = [NSString stringWithFormat:@"%@%@sign=%@", [url replace:FORMAT(@"&sign=%@", SIGN) to:@""], ([url indexOf:@"?"]!=NSNotFound?@"&":@"?"), SIGN];
	}
	if (urls.count>1) url = [NSString stringWithFormat:@"%@#%@", url, urls[1]];
	_url = [url replace:@"&amp;" to:@"&"];
	_param = param;
	if (_webView && !nonLoad) {
		NSURL *URL = [NSURL URLWithString:_url];
		if (URL == nil) URL = [NSURL URLWithString:[_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSURLRequest *request = [[NSURLRequest alloc]initWithURL:URL cachePolicy:_cachePolicy timeoutInterval:_timeout];
		[_webView loadRequest:request];
	}
}

- (void)setHtml:(NSString *)html{
	[self setHtml:html baseURL:nil];
}

- (void)setHtml:(NSString *)html baseURL:(NSURL *)baseURL{
	_html = html;
	if (_webView) {
		[_webView loadHTMLString:html baseURL:baseURL];
	}
}

- (void)reload{
	if (!_isReloading && _webView && _webView.URL.absoluteString.length && _url.length) {
		_isReloading = YES;
		self.url = _webView.URL.absoluteString;
	}
}

- (void)removeCache{
	if (@available(iOS 9.0, *)) {
		//NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes]; //All of data
		NSSet *websiteDataTypes = [NSSet setWithArray:@[
														WKWebsiteDataTypeDiskCache,
														WKWebsiteDataTypeMemoryCache,
														WKWebsiteDataTypeOfflineWebApplicationCache,
														WKWebsiteDataTypeLocalStorage,
														WKWebsiteDataTypeCookies,
														WKWebsiteDataTypeSessionStorage,
														WKWebsiteDataTypeIndexedDBDatabases,
														WKWebsiteDataTypeWebSQLDatabases
														]];
		NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
		[[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{}];
	} else {
		NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
		NSString *cookiesFolderPath = [NSString stringWithFormat:@"%@/Cookies", libraryPath];
		[[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:nil];
	}
}

- (void)javascript:(NSString *)js completion:(void (^)(id obj, NSError *error))completion{
	[_webView evaluateJavaScript:js completionHandler:^(id obj, NSError *error) {
		if (completion) completion(obj, error);
	}];
}

- (void)showConsole{
	NSString *jsCode = @"console.log = (function(oriLogFunc){\
		return function(str){\
			window.webkit.messageHandlers.showConsole.postMessage(str);\
			oriLogFunc.call(console, str);\
		}\
	})(console.log);";
	//在h5开始创建DOM树的时候注入
	[_webView.configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
	if ([message.name isEqualToString:@"showConsole"]) {
		NSLog(@"%@", message.body);
	}
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
	if (!_isProgressLoad && _isProgressHUD) [ProgressHUD show:nil];
	if (_delegate && [_delegate respondsToSelector:@selector(OutletDidStartLoad:)]) {
		[_delegate OutletDidStartLoad:self];
	}
	if ([self respondsToSelector:@selector(OutletDidStartLoad)]) {
		[self OutletDidStartLoad];
	}
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
	[self webView:webView didFinishNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
	if (!_isProgressLoad) [ProgressHUD dismiss];
	NSString *url = webView.URL.absoluteString; //当前网址
	if (_autoTitle) {
		[webView evaluateJavaScript:@"document.title" completionHandler:^(id obj, NSError *error) {
			if ([obj length]) self.title = obj;
		}];
	}
	[webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id obj, NSError *error) {
		NSString *html = obj;
		_getHtml = html;
		if (_delegate && [_delegate respondsToSelector:@selector(OutletDidFinishLoadWith:url:html:)]) {
			[_delegate OutletDidFinishLoadWith:self url:url html:html];
		}
		if ([self respondsToSelector:@selector(OutletDidFinishLoad:html:)]) {
			[self OutletDidFinishLoad:url html:html];
		}
		_isLoaded = YES;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				_isReloading = NO;
			});
		});
	}];
	if (_zoomImage) {
		NSString *js = @"var img = document.getElementsByTagName('img');\
		for(var i=0;i<img.length;i++){if(img[i].offsetWidth<=300)continue;\
		img[i].style.width='';img[i].style.height='';img[i].style.verticalAlign='bottom';\
		img[i].setAttribute('width','100%%');if(img[i].getAttribute('height'))img[i].removeAttribute('height');}";
		[webView evaluateJavaScript:js completionHandler:nil];
	}
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
	if (_html.length) {
		decisionHandler(WKNavigationActionPolicyAllow);
		return;
	}
	NSURL *URL = navigationAction.request.URL;
	NSString *url = URL.absoluteString;
	if ([url hasPrefix:@"https://itunes.apple.com"] || [url hasPrefix:@"http://itunes.apple.com"]) {
		decisionHandler(WKNavigationActionPolicyCancel);
		dispatch_async(dispatch_get_global_queue(0, 0), ^{
			[[UIApplication sharedApplication] openURL:URL];
		});
		return;
	}
	if ([[URL scheme] isEqualToString:@"tel"]) {
		decisionHandler(WKNavigationActionPolicyCancel);
		NSString *callPhone = [NSString stringWithFormat:@"tel://%@", [URL resourceSpecifier]];
		dispatch_async(dispatch_get_global_queue(0, 0), ^{ //防止iOS10及其之后，拨打电话系统弹出框延迟出现
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
		});
		return;
	}
	if ([url hasPrefix:@"app-log://"]) {
		decisionHandler(WKNavigationActionPolicyCancel);
		NSString *log = [url explode:@"app-log://"][1];
		NSLog(@"%@", log);
		return;
	}
	if ([url hasPrefix:@"app-act://"]) {
		decisionHandler(WKNavigationActionPolicyCancel);
		NSArray *acts = [url explode:@"app-act://"];
		NSString *act = acts.lastObject;
		if (_delegate && [_delegate respondsToSelector:@selector(OutletLinkActWith:act:)]) {
			[_delegate OutletLinkActWith:self act:act];
		}
		if ([self respondsToSelector:@selector(OutletLinkAct:)]) {
			[self OutletLinkAct:act];
		}
		return;
	}
	if ([url hasPrefix:@"javascript:"]) {
		decisionHandler(WKNavigationActionPolicyCancel);
		if (_delegate && [_delegate respondsToSelector:@selector(OutletLinkJavascriptWith:javascript:)]) {
			[_delegate OutletLinkJavascriptWith:self javascript:url];
		}
		if ([self respondsToSelector:@selector(OutletLinkJavascript:)]) {
			[self OutletLinkJavascript:url];
		}
		return;
	}
	if ([url hasPrefix:@"app-back://"]) {
		decisionHandler(WKNavigationActionPolicyCancel);
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}
	if (![url hasPrefix:@"http"] && ![url hasPrefix:@"app-act://"]) {
		decisionHandler(WKNavigationActionPolicyCancel);
		return;
	}
	if (_isReloading) {
		decisionHandler(WKNavigationActionPolicyAllow);
		return;
	}
	if (_isLoaded) {
		if (_startLoadUrl) _startLoadUrl(self, url);
		if (_delegate && [_delegate respondsToSelector:@selector(OutletStartLoadUrlWith:url:)]) {
			BOOL flag = [_delegate OutletStartLoadUrlWith:self url:url];
			if (flag) {
				decisionHandler(WKNavigationActionPolicyAllow);
			} else {
				decisionHandler(WKNavigationActionPolicyCancel);
			}
			return;
		}
		if ([self respondsToSelector:@selector(OutletStartLoadUrl:)]) {
			BOOL flag = [self OutletStartLoadUrl:url];
			if (flag) {
				decisionHandler(WKNavigationActionPolicyAllow);
			} else {
				decisionHandler(WKNavigationActionPolicyCancel);
			}
			return;
		}
	}
	if (navigationAction.targetFrame == nil) {
		[webView loadRequest:navigationAction.request];
	}
	decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
	NSLog(@"WKWebView didFailNavigation: %@", error.userInfo);
	if (!_isProgressLoad) [ProgressHUD dismiss];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
	NSLog(@"WKWebView didFailProvisionalNavigation: %@", error.userInfo);
	if (!_isProgressLoad) [ProgressHUD dismiss];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		if ([message.lowercaseString indexOf:@"missing "]!=NSNotFound || [message.lowercaseString indexOf:@"wrong file"]!=NSNotFound) {
			[APPCurrentController.navigationController popViewControllerAnimated:YES];
		}
		completionHandler();
	}]];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(NO);
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(YES);
	}]];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.text = defaultText;
	}];
	[alertController addAction:[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(alertController.textFields[0].text?:@"");
	}]];
	[self presentViewController:alertController animated:YES completion:nil];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
	[webView reload];
}
#endif

- (void)OutletDidFinishLoad:(NSString*)url html:(NSString*)html{
	/* Subclasses should override */
}

- (BOOL)OutletStartLoadUrl:(NSString*)url{
	/* Subclasses should override */
	return YES;
}

- (void)OutletLinkAct:(NSString *)act{
	/* Subclasses should override */
}

- (void)OutletLinkJavascript:(NSString *)javascript{
	/* Subclasses should override */
}

- (void)OutletDidStartLoad{
	/* Subclasses should override */
}

- (void)OutletViewDidLoad{
	/* Subclasses should override */
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	return YES;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	[_webView loadHTMLString:@"" baseURL:nil];
	if (self.view.window==nil) {
		self.view = nil;
	}
}

@end
