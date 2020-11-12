//
//  CheckNetwork.h
//
//  Created by wangjun on 10-12-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//  检查网络是否存在

#import <Foundation/Foundation.h>

@interface CheckNetwork : NSObject
+ (BOOL)isNetwork:(BOOL)noNetShowMsg;
+ (BOOL)isNetworkFor:(NSString*)Netname noNetShowMsg:(BOOL)noNetShowMsg;
+ (void)reachabilityChanged:(NSNotification*)note;
@end

//获取网络状态与运营商名称
//STNetListen *nl = [STNetListen share];
//[NSString stringWithFormat:@"%@\n%@", [nl carrierName], [nl statusDescripetion]];
extern NSString *const STTelephonyNetworkDidChangedNotificationName; //网络状态改变时通知
typedef NS_ENUM(NSUInteger, STTelStatus) {
	STTelStatusNone,
	STTelStatusGPRS, //GPRS
	STTelStatusEdge, //E
	STTelStatus2G,
	STTelStatus3G,
	STTelStatus4G
};
@interface STNetListen : NSObject
+ (instancetype)share;
@property (nonatomic, readonly) STTelStatus status; //蜂窝网络状态
@property (nonatomic, readonly) NSString *statusDescripetion; //蜂窝网络状态描述
@property (nonatomic, readonly) NSString *carrierName; //运营商名称
@end
