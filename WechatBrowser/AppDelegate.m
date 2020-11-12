//
//  AppDelegate.m
//  WechatBrowser
//
//  Created by ajsong on 2019/7/2.
//  Copyright © 2019 @MARIO. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	//配置
	[self configApplication:application didFinishLaunchingWithOptions:launchOptions];
	
	[WRNavigationBar wr_widely];
	[WRNavigationBar wr_setBlacklist:@[@"TZAlbumPickerController", @"TZPhotoPickerController"]];
	[WRNavigationBar wr_setDefaultNavBarBarTintColor:COLORNAVBG]; //导航栏默认背景色
	[WRNavigationBar wr_setDefaultNavBarTintColor:COLORNAVTEXT]; //导航栏按钮默认色
	[WRNavigationBar wr_setDefaultNavBarTitleColor:COLORNAVTEXT]; //导航栏标题默认色
	[WRNavigationBar wr_setDefaultStatusBarStyle:UIStatusBarStyleDefault]; //状态栏样式
	//[WRNavigationBar wr_setDefaultNavBarShadowImageHidden:YES]; //导航栏分割线隐藏
	//[WRNavigationBar wr_setDefaultNavBarShadowImageColor:COLOR_GE_LIGHT]; //导航栏分割线颜色
	
	KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
	self.window.backgroundColor = COLORWHITE;
	self.window.rootViewController = nav;
	
	//[NSThread sleepForTimeInterval:3.0];
	[self.window makeKeyAndVisible];
	return YES;
}

@end
