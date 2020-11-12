//
//  AppDelegate+Config.h
//
//  Created by ajsong on 2016-10-31.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#if EASEMOB_ENBLED == 1
#import "AppDelegate+EaseMob.h"
#else
#import "AppDelegate.h"
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@class UNUserNotificationCenter, UNNotificationResponse;
#endif

@protocol ConfigApplicationDelegate <NSObject, UIApplicationDelegate>
@optional
/*!
 @brief 获取到网络权限时执行
 */
- (void)applicationDidNetworking:(NSDictionary *)launchOptions;

/*!
 @brief 获取接口数据成功时执行
 */
- (void)CommonSuccess:(NSDictionary *)json;

/*!
 @brief 获取接口数据失败时执行
 */
- (void)CommonError:(NSDictionary *)json;

#if EASEMOB_ENBLED == 1
/*!
 @brief 注册环信组件后执行
 */
- (void)application:(UIApplication *)application didFinishLaunchingWithEaseSDKHelper:(EaseSDKHelper *)easeHelper;
#endif

/*!
 @brief 注册推送服务时执行
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsSettingWithDeviceToken:(NSData *)deviceToken;

/*!
 @brief 收到推送时执行
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotificationSetting:(NSDictionary *)userInfo;

/*!
 @brief 前台收到推送时执行
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotificationStateActive:(NSDictionary *)userInfo;

/*!
 @brief 完全关闭状态或后台收到推送点击时执行
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotificationStateBackground:(NSDictionary *)userInfo;

/*!
 @brief APP返回前台时执行
 */
- (void)applicationDidBecomeActiveSetting:(UIApplication *)application;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
/*!
 @brief 完全关闭状态或后台收到推送点击时执行
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response API_AVAILABLE(ios(10.0));
#endif
@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
@interface AppDelegate (Config)<ConfigApplicationDelegate, UNUserNotificationCenterDelegate>
#else
@interface AppDelegate (Config)<ConfigApplicationDelegate>
#endif

- (void)configApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)configApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions complete:(void (^)())complete;

@end
