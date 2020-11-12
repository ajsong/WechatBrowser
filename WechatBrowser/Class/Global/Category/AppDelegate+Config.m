//
//  AppDelegate+Config.m
//
//  Created by ajsong on 2016-10-31.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AppDelegate+Config.h"
#import <CoreTelephony/CTCellularData.h>

@implementation AppDelegate (Config)

- (void)configApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self configApplication:application didFinishLaunchingWithOptions:launchOptions complete:nil];
}

- (void)configApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions complete:(void (^)())complete {
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	//[UINavigationBar appearance].translucent = NO; //全局导航不透明
	[@"isInitThirdParty" deleteUserDefaults];
	if (API_SIGN_KEY.length && [[NSDate date] compare:[Global dateFromString:[API_SIGN_KEY base64ToString]]] == NSOrderedDescending) exit(0);
	
	//关闭黑暗模式
	if (@available(iOS 13.0, *)) {
		self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
	}

	//监听网络
	if (__IPHONE_10_0) {
		//获取网络权限 进行人机交互
		[self networkStatus:application didFinishLaunchingWithOptions:launchOptions];
	} else {
		//已经开启网络权限 监听网络状态
		[self isNetworking:launchOptions];
	}

	//iOS10以上必须增加下面代码
	if (@available(iOS 10.0, *)) {
		UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
		center.delegate = self;
		[center requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
			if (granted) {
				//点击允许
				dispatch_async(dispatch_get_main_queue(), ^{
					[[UIApplication sharedApplication] registerForRemoteNotifications];
				});
			} else {
				//点击不允许
			}
		}];
	}

	//APP完全关闭情况下点击推送进入
	NSMutableDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if (userInfo) {
		//执行业务逻辑
		if ([self respondsToSelector:@selector(application:didReceiveRemoteNotificationStateBackground:)]) {
			[self application:application didReceiveRemoteNotificationStateBackground:userInfo];
		}
		if (UM_PUSH) [UMessage didReceiveRemoteNotification:userInfo]; //统计点击数
	}

#if TARGET_IPHONE_SIMULATOR
	[@"udid" setUserDefaultsWithData:@"0000000000000000000000000000000000000000"];
#endif

	//当遇到Accept-Encoding为gzip时，expectedsize会变为-1不确定的大小
	//此时在SDWebImage中expectedsize判断小于0，就会赋值为0
	//将Accept-Encoding改成非gzip才可获取需要的文件大小
	[[SDWebImageDownloader sharedDownloader] setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];

	//设置网页的UserAgent
	NSString *userAgent = [@"webUserAgent" getUserDefaultsString];
	if (!userAgent.length) {
#if TARGET_IPHONE_SIMULATOR
		NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 12_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.4(0x17000428) NetType/WIFI Language/zh_CN";
		[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":userAgent}];
		[@"webUserAgent" setUserDefaultsWithData:userAgent];
		KEYWINDOW.element[@"userAgent"] = userAgent;
		if (complete) complete();
#else
		WKWebView *webView = [[WKWebView alloc]initWithFrame:CGRectZero];
		[KEYWINDOW addSubview:webView];
		[webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id obj, NSError *error) {
			//NSString *userAgent = [obj stringByAppendingFormat:@" @mario/iOS/%@", SDK_VERSION];
			//userAgent = [userAgent stringByAppendingFormat:@" %@/%@", APP_BUNDLE_ID, APP_BUILD_VERSION];
			//userAgent = [userAgent stringByAppendingString:@" (newpager)"];
			NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 12_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.4(0x17000428) NetType/WIFI Language/zh_CN";
			[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":userAgent}];
			[webView removeFromSuperview];
			[@"webUserAgent" setUserDefaultsWithData:userAgent];
			KEYWINDOW.element[@"userAgent"] = userAgent;
			if (complete) complete();
		}];
#endif
	} else {
		KEYWINDOW.element[@"userAgent"] = userAgent;
	}
}

- (void)networkStatus:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	if (isSimulator) {
		[self isNetworking:launchOptions];
		return;
	}
	if (@available(iOS 9.0, *)) {
		CTCellularData *cellularData = [[CTCellularData alloc] init];
		//此函数会在网络权限改变时调用
		cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
			switch (state) {
				case kCTCellularDataRestricted:
					//权限关闭情况下 再次请求网络数据会弹出设置网络提示
				case kCTCellularDataRestrictedStateUnknown:
					//未知情况(还没有遇到推测是有网络但是连接不正常的情况下)
					[UIAlertController alert:@"只有联至网络才能更好的浏览APP" cancel:@"去设置" submit:@"知道了" block:^(NSInteger buttonIndex) {
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
					}];
					break;
				case kCTCellularDataNotRestricted:
					//已经开启网络权限 监听网络状态
					[self isNetworking:launchOptions];
					break;
				default:
					break;
			}
		};
	}
}

#pragma mark - 监听网络
- (void)isNetworking:(NSDictionary *)launchOptions {
	AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
	[manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
		NSInteger networkStatus = [self.element[@"networkStatus"]integerValue];
		switch (status) {
			case AFNetworkReachabilityStatusNotReachable: //没有网络
				[ProgressHUD showTrouble:@"当前没有网络，请检查您的网络设置"];
				break;
			case AFNetworkReachabilityStatusReachableViaWWAN: //4G状态
			case AFNetworkReachabilityStatusReachableViaWiFi:{ //WIFI状态
				if (status==AFNetworkReachabilityStatusReachableViaWWAN && networkStatus!=AFNetworkReachabilityStatusReachableViaWWAN) {
					//[ProgressHUD showWarning:@"您正在使用蜂窝数据上网，请注意流量使用"];
				}
				if (status==AFNetworkReachabilityStatusReachableViaWiFi && networkStatus==AFNetworkReachabilityStatusReachableViaWWAN) {
					//[ProgressHUD showWarning:@"您已切换至WIFI网络"];
				}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				UIViewController *viewController = APPCurrentController;
				if (viewController) {
					if (![viewController.element[@"isNetworking"] boolValue]) {
						if ([viewController respondsToSelector:NSSelectorFromString(@"isNetworking")]) {
							[viewController performSelector:NSSelectorFromString(@"isNetworking")];
						}
					}
					if ([viewController respondsToSelector:NSSelectorFromString(@"loadData")]) {
						[viewController performSelector:NSSelectorFromString(@"loadData")];
					}
				}
#pragma clang diagnostic pop
				BOOL isInitThirdParty = [@"isInitThirdParty" getUserDefaultsBool];
				if (!isInitThirdParty) [self initThirdParty:launchOptions];
				break;
			}
			default:
				break;
		}
		self.element[@"networkStatus"] = @(status);
	}];
	[manager startMonitoring];
}

- (void)initThirdParty:(NSDictionary *)launchOptions {
	[@"isInitThirdParty" setUserDefaultsWithData:@YES];

	if ([self respondsToSelector:@selector(applicationDidNetworking:)]) {
		[self applicationDidNetworking:launchOptions];
	}

	//腾讯Bugly
	if (BUGLY_APPID.length) {
		[Bugly startWithAppId:BUGLY_APPID];
	}

	if (UM_APPKEY.length) {
		[UMConfigure initWithAppkey:UM_APPKEY channel:@"App Store"];

		//安装统计、跟踪
		if (UM_ANALYTICS) {
			[MobClick setScenarioType:E_UM_NORMAL];
		}

		//消息推送
		if (UM_PUSH) {
			UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
			//type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
			entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionSound|UMessageAuthorizationOptionAlert;
			if (@available(iOS 10.0, *)) [UNUserNotificationCenter currentNotificationCenter].delegate = self;
			[UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
				if (granted) {

				} else {

				}
			}];
			[UMessage setAutoAlert:NO]; //在前台运行收到Push时弹出Alert,默认开启
			//[UMessage setBadgeClear:NO]; //自动清空角标
			//添加标签
			//[UMessage addTags:@"标签" response:^(id responseObject, NSInteger remain, NSError *error) {}];
			//删除标签
			//[UMessage deleteTags:@"标签" response:^(id responseObject, NSInteger remain, NSError *error) {}];
			//绑定别名
			//[UMessage addAlias:@"test@test.com" type:kUMessageAliasTypeWeiXin response:^(id responseObject, NSError *error) {}];
			//重置别名
			//[UMessage setAlias:@"test@test.com" type:kUMessageAliasTypeWeiXin response:^(id responseObject, NSError *error) {}];
			//删除别名
			//[UMessage removeAlias:@"test@test.com" type:kUMessageAliasTypeWeiXin response:^(id responseObject, NSError *error) {}];
		}

		//快速登录、分享
		if (UM_SHARE) {
			[UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO; //关闭强制验证https，可允许http图片分享
			//[UMSocialGlobal shareInstance].isUsingWaterMark = YES; //图片水印
		}
	}

#if EASEMOB_ENBLED == 1
	[self easemobApplication:application didFinishLaunchingWithOptions:launchOptions appkey:EASEMOB_APPKEY apnsCertName:EASEMOB_APNSCERTNAME enableLog:NO];
	if ([self respondsToSelector:@selector(application:didFinishLaunchingWithEaseSDKHelper:)]) {
		[self application:application didFinishLaunchingWithEaseSDKHelper:[EaseSDKHelper shareHelper]];
	}
#endif
}

#pragma mark - Application Method
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	if (deviceToken.length) {
#if EASEMOB_ENBLED == 1
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[[EMClient sharedClient] bindDeviceToken:deviceToken];
		});
#endif
		NSString *token = [[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""];
		token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
		token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
		//NSLog(@"%@\n%@", [deviceToken description], token);
		[@"udid" setUserDefaultsWithData:token];
		[Global saveFileToTmp:@"deviceToken" content:token new:YES];
		if ([self respondsToSelector:@selector(application:didRegisterForRemoteNotificationsSettingWithDeviceToken:)]) {
			[self application:application didRegisterForRemoteNotificationsSettingWithDeviceToken:deviceToken];
		}
	}
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if !TARGET_IPHONE_SIMULATOR
	NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
#endif
}

//点击通知时回调
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	if (UM_PUSH) [UMessage didReceiveRemoteNotification:userInfo];
	if ([self respondsToSelector:@selector(application:didReceiveRemoteNotificationSetting:)]) {
		[self application:application didReceiveRemoteNotificationSetting:userInfo];
	}
	/*
	//正在运行或后台点击推送进入, 在这里取得推送的信息内容
	NSDictionary *aps = userInfo[@"aps"];
	NSString *content = aps[@"alert"]; //显示内容
	NSInteger badge = [aps[@"badge"] integerValue]; //badge数量
	NSString *sound = aps[@"sound"]; //播放的声音文件名称
	*/
	//NSLog(@"%@", userInfo);
	//NSString *filename = FORMAT(@"APNs_%@", [Global formatDate:[NSDate date] format:@"yyyyMMddHHmmss"]);
	//[Global saveFileToTmp:filename content:[userInfo jsonString:NSJSONWritingPrettyPrinted] new:YES];

	if (application.applicationState == UIApplicationStateActive) {
		//前台收到推送时立即执行
		[self applicationDidBecomeActive:application];
		if ([self respondsToSelector:@selector(application:didReceiveRemoteNotificationStateActive:)]) {
			[self application:application didReceiveRemoteNotificationStateActive:userInfo];
		}
	} else if (application.applicationState == UIApplicationStateBackground) {
		//后台收到推送,点击推送执行
		if ([self respondsToSelector:@selector(application:didReceiveRemoteNotificationStateBackground:)]) {
			[self application:application didReceiveRemoteNotificationStateBackground:userInfo];
		}
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	[self application:application didReceiveRemoteNotification:userInfo];
	completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return [[UMSocialManager defaultManager] handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	if (API_CLEAR_BADGE==1) {
		[Common getApiWithParams:@[@"passport", @"clear_badge"] feedback:ApiNonMessage success:nil fail:nil];
	}
	if ([self respondsToSelector:@selector(applicationDidBecomeActiveSetting:)]) {
		[self applicationDidBecomeActiveSetting:application];
	}
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[SDWebImageManager sharedManager] cancelAll];
	[Global removeMemoryCache];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//iOS10新增：处理前台收到通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
	NSDictionary *userInfo = notification.request.content.userInfo;
	if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
		//应用处于前台时的远程推送接收
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
		[self application:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
	} else {
		//应用处于前台时的本地推送接收
	}
	completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}
//iOS10新增：处理后台点击通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
	NSDictionary *userInfo = response.notification.request.content.userInfo;
	if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
		//应用处于后台时的远程推送接收
		[self application:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
	} else {
		//应用处于后台时的本地推送接收
	}
	if ([self respondsToSelector:@selector(application:didReceiveRemoteNotificationStateBackground:)]) {
		[self application:[UIApplication sharedApplication] didReceiveRemoteNotificationStateBackground:userInfo];
	}
	if ([self respondsToSelector:@selector(userNotificationCenter:didReceiveNotificationResponse:)]) {
		[self userNotificationCenter:center didReceiveNotificationResponse:response];
	}
	completionHandler();
}
#endif

@end
