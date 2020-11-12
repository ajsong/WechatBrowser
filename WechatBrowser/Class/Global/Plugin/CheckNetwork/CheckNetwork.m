//
//  CheckNetwork.m
//
//  Created by wangjun on 10-12-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CheckNetwork.h"
#import "Reachability.h"
#import "ProgressHUD.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation CheckNetwork
+ (BOOL)isNetwork:(BOOL)noNetShowMsg{
	BOOL isNetwork = NO;
	Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
			isNetwork = NO;
            //NSLog(@"没有网络");
            break;
        case ReachableViaWWAN:
			isNetwork = YES;
            //NSLog(@"正在使用3G/GPRS网络");
            break;
        case ReachableViaWiFi:
			isNetwork = YES;
            //NSLog(@"正在使用wifi网络");
            break;
	}
	if (!isNetwork && noNetShowMsg) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[ProgressHUD showTrouble:@"当前没有网络，请检查你的网络设置"];
		});
	}
	return isNetwork;
}

+ (BOOL)isNetworkFor:(NSString*)Netname noNetShowMsg:(BOOL)noNetShowMsg{
	BOOL isNetwork = NO;
	Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
	NetworkStatus status = [r currentReachabilityStatus];
	Netname = [Netname lowercaseString];
	if ([Netname isEqualToString:@"wifi"]) {
		isNetwork = status == ReachableViaWiFi;
	} else if ([Netname isEqualToString:@"3g"]) {
		isNetwork = status == ReachableViaWWAN;
	} else {
		isNetwork = (status == ReachableViaWiFi || status == ReachableViaWWAN);
	}
	if (!isNetwork && noNetShowMsg) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[ProgressHUD showTrouble:@"当前没有网络，请检查你的网络设置"];
		});
	}
	return isNetwork;
}

//即时监听网络状态
/*
在 AppDelegate 的 application:didFinishLaunchingWithOptions: 增加
Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
[r startNotifier]; //开始监听,会启动一个run loop
且增加一个方法 reachabilityChanged:(NSNotification*)note
然后方法里调用 [CheckNetwork reachabilityChanged:note];
*/
+ (void)reachabilityChanged:(NSNotification*)note{
	Reachability *r = [note object];
	NSParameterAssert([r isKindOfClass:[Reachability class]]);
	NetworkStatus status = [r currentReachabilityStatus];
	if (status == NotReachable) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[ProgressHUD showTrouble:@"当前没有网络，请检查你的网络设置"];
		});
	}
}
@end


#pragma mark - 获取网络状态与运营商名称
NSString *const STTelephonyNetworkDidChangedNotificationName = @"com.steven.telNetDidChangedNotif";
static id _st_observer = nil;
@implementation STNetListen{
	CTTelephonyNetworkInfo *_networkInfo;
	STTelStatus _status;
}
+ (instancetype)share{
	static dispatch_once_t onceToken;
	static STNetListen *_st_shared_netlisten = nil;
	dispatch_once(&onceToken, ^{
		_st_shared_netlisten = [self new];
	});
	return _st_shared_netlisten;
}
- (instancetype)init{
	if (self = [super init]){
		_networkInfo = [CTTelephonyNetworkInfo new];
		[self updateStatus];
		[self registerNotification];
	}
	return self;
}
- (void)registerNotification{
	NSNotificationCenter *nitifC = [NSNotificationCenter defaultCenter];
	_st_observer = [nitifC addObserverForName:CTRadioAccessTechnologyDidChangeNotification
									   object:nil
										queue:[NSOperationQueue mainQueue]
								   usingBlock:^(NSNotification *note) {
									   [self updateStatus];
									   [[NSNotificationCenter defaultCenter] postNotificationName:STTelephonyNetworkDidChangedNotificationName object:self];
								   }];
}
- (void)updateStatus{
	NSString *info = _networkInfo.currentRadioAccessTechnology;
	if ([info isEqualToString:CTRadioAccessTechnologyGPRS]){
		_status = STTelStatusGPRS;
	} else if ([info isEqualToString:CTRadioAccessTechnologyEdge]){
		_status = STTelStatusEdge;
	} else if ([info isEqualToString:CTRadioAccessTechnologyCDMA1x]){
		_status = STTelStatus2G;
	} else if ([info isEqualToString:CTRadioAccessTechnologyWCDMA] ||
			 [info isEqualToString:CTRadioAccessTechnologyHSDPA] ||
			 [info isEqualToString:CTRadioAccessTechnologyHSUPA] ||
			 [info isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
			 [info isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
			 [info isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
			 [info isEqualToString:CTRadioAccessTechnologyeHRPD]){
		_status = STTelStatus3G;
	} else if ([info isEqualToString:CTRadioAccessTechnologyLTE]){
		_status = STTelStatus4G;
	} else{
		_status = STTelStatusNone;
	}
}
- (STTelStatus)status{
	return _status;
}
- (NSString *)statusDescripetion{
	switch (_status) {
		case STTelStatusGPRS:{
			return @"GPRS";
		}
		case STTelStatusEdge:{
			return @"E";
		}
		case STTelStatus2G:{
			return @"2G";
		}
		case STTelStatus3G:{
			return @"3G";
		}
		case STTelStatus4G:{
			return @"4G";
		}
		default:
			break;
	}
	return nil;
}
- (NSString *)carrierName{
	return _networkInfo.subscriberCellularProvider.carrierName;
}
- (NSString *)description{
	CTCarrier *c = _networkInfo.subscriberCellularProvider;
	return [NSString stringWithFormat:@"(%@)(%@-%@-%@-%@)", [self statusDescripetion], c.carrierName, c.mobileCountryCode, c.mobileNetworkCode, c.isoCountryCode];
}
- (void)dealloc{
	[_st_observer removeObserver:self];
}
@end
