//
//  WechatPay.m
//
//  Created by ajsong on 15/8/4.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import "WechatPay.h"
#import "WechatPayHelper.h"
#import "WXApi.h"

@interface WechatPay ()<WXApiDelegate>

@end

@implementation WechatPay

+ (void)payWithData:(NSDictionary*)data{
	if (data) {
		NSMutableString *stamp  = [data objectForKey:@"timestamp"];
		//调起微信支付
		PayReq *req             = [[PayReq alloc] init];
		req.partnerId           = [data objectForKey:@"partnerid"];
		req.prepayId            = [data objectForKey:@"prepayid"];
		req.nonceStr            = [data objectForKey:@"noncestr"];
		req.timeStamp           = stamp.intValue;
		req.package             = [data objectForKey:@"package"];
		req.sign                = [data objectForKey:@"sign"];
		
		[WXApi sendReq:req];
	}
}

+ (void)payWithTradeNO:(NSString*)tradeNO productName:(NSString*)name totalprice:(NSString*)totalprice notifyURL:(NSString*)notifyURL{
	//创建支付签名对象
	WechatPayHelper *helper = [[WechatPayHelper alloc]init];
	//初始化支付签名对象
	[helper init:WX_APPID mch_id:WX_MCHID];
	//设置密钥
	[helper setKey:WX_KEY];
	
	//获取到实际调起微信支付的参数后，在app端调起支付
	NSMutableDictionary *dict = [helper payWithTradeNO:tradeNO productName:name totalprice:totalprice notifyURL:notifyURL];
	if (!dict) {
		//错误提示
		NSLog(@"%@", [helper getDebugifo]);
	} else {
		NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
		
		//调起微信支付
		PayReq *req             = [[PayReq alloc] init];
		req.openID              = [dict objectForKey:@"appid"];
		req.partnerId           = [dict objectForKey:@"partnerid"];
		req.prepayId            = [dict objectForKey:@"prepayid"];
		req.nonceStr            = [dict objectForKey:@"noncestr"];
		req.timeStamp           = stamp.intValue;
		req.package             = [dict objectForKey:@"package"];
		req.sign                = [dict objectForKey:@"sign"];
		
		[WXApi sendReq:req];
	}
}

@end
