//
//  AJPayHelper.m
//
//  Created by ajsong on 2016-8-31.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "Global.h"

@interface AJPayHelper ()<WXApiDelegate>{
	AJPayStatus _payStatus;
}
@end

@implementation AJPayHelper

+ (AJPayHelper*)sharedHelper {
	static dispatch_once_t once = 0;
	static AJPayHelper *payHelper;
	dispatch_once(&once, ^{ payHelper = [[AJPayHelper alloc] init]; });
	return payHelper;
}

+ (BOOL)checkPayMethod:(NSString *)method{
	return [[AJPayHelper sharedHelper] checkPayMethod:method];
}

+ (void)payWithPayMethod:(NSString*)method totalprice:(NSString *)totalprice data:(NSDictionary *)data success:(void (^)(AJPayType))success fail:(void (^)(AJPayType, int))fail{
	[[AJPayHelper sharedHelper] payWithPayMethod:method.lowercaseString totalprice:totalprice data:data success:success fail:fail];
}

+ (void)payWithPayMethod:(NSString*)method tradeNO:(NSString *)tradeNO productName:(NSString *)name description:(NSString *)description totalprice:(NSString *)totalprice success:(void (^)(AJPayType type))success fail:(void (^)(AJPayType type, int statusCode))fail{
	[[AJPayHelper sharedHelper] payWithPayMethod:method.lowercaseString tradeNO:tradeNO productName:name description:description totalprice:totalprice success:success fail:fail];
}

/*
在 -application:openURL:sourceApplication:annotation: 的 return 前调用
AJPayStatus status = [[AJPayHelper sharedHelper]payStatusWithUrl:url];
if (status != AJPayStatusInvalid) {
	//支付返回结果，实际支付结果需要查询
	UINavigationController *nav = APPCurrentController.navigationController;
	NSDictionary *data = [@"order" getUserDefaultsDictionary];
	[@"order" deleteUserDefaults];
	BOOL shopping = [@"shopping" getUserDefaultsBool];
	[@"shopping" deleteUserDefaults];
	switch (status) {
		case AJPayStatusSuccess:{
			NSLog(@"支付成功");
			if (shopping) {
				//cartComplete *e = [[cartComplete alloc]init];
				//e.data = data;
				//[nav pushViewController:e animated:YES];
			}
			break;
		}
		default:{
			NSLog(@"支付失败");
			[ProgressHUD showError:@"支付失败"];
			if (!shopping) [nav popToRootViewControllerAnimated:YES];
			break;
		}
	}
}
*/
- (AJPayStatus)payStatusWithUrl:(NSURL *)url{
	if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://safepay/", APP_SCHEME]]) {
		//支付宝钱包支付结果
		_payStatus = AJPayStatusFail;
		[[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
			//NSLog(@"%@",resultDic);
			//结果处理
			AlipayResult *result = [AlipayResult itemWithDictory:resultDic];
			//用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			if (result && result.statusCode == 9000) { //状态返回9000为成功
				_payStatus = AJPayStatusSuccess;
			} else { //失败
				_payStatus = AJPayStatusFail;
			}
		}];
		return _payStatus;
	} else if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://pay/", WX_APPID]]) {
		//微信支付结果
		_payStatus = AJPayStatusFail;
		[WXApi handleOpenURL:url delegate:self];
		return _payStatus;
	} else if ([url.host isEqualToString:@"platformapi"]) {
		//支付宝钱包快登授权
		[[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
			//NSLog(@"platformapi-result: %@", resultDic);
		}];
	}
	return AJPayStatusInvalid;
}

//微信相关
- (void)onResp:(BaseResp*)resp{
	if ([resp isKindOfClass:[PayResp class]]) {
		//支付结果
		//实际支付结果需要去微信服务器端查询
		switch (resp.errCode) {
			case WXSuccess:{
				NSLog(@"支付成功！");
				_payStatus = AJPayStatusSuccess;
				break;
			}
			default:{
				NSLog(@"支付失败！retcode:%d, retstr:%@", resp.errCode, resp.errStr);
				_payStatus = AJPayStatusFail;
				break;
			}
		}
	} else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
		//发送媒体消息结果
	}
}

- (BOOL)checkPayMethod:(NSString*)method{
	if (method.length) {
		if ([method indexOf:@"支付宝"]!=NSNotFound || [method indexOf:@"alipay"]!=NSNotFound) return [ShareHelper isAlipayInstalled];
		if ([method indexOf:@"微信"]!=NSNotFound || [method indexOf:@"wxpay"]!=NSNotFound) return [ShareHelper isWXAppInstalled];
	}
	return YES;
}

//由后端生成签名
- (void)payWithPayMethod:(NSString*)method totalprice:(NSString *)totalprice data:(id)data success:(void (^)(AJPayType type))success fail:(void (^)(AJPayType type, int statusCode))fail{
	if (totalprice.floatValue <= 0) {
		if (success) success(AJPayTypeNormal);
	} else if ([method indexOf:@"支付宝"]!=NSNotFound || [method indexOf:@"alipay"]!=NSNotFound) {
		if (![self checkPayMethod:method]) {
			[ProgressHUD showError:@"设备没有可支付的客户端"];
			return;
		}
		_payStatus = AJPayStatusFail;
		[Alipay payWithOrderString:data success:^{
			_payStatus = AJPayStatusSuccess;
			if (success) success(AJPayTypeAlipay);
		} fail:^(int statusCode) {
			_payStatus = AJPayStatusFail;
			if (fail) fail(AJPayTypeAlipay, statusCode);
		}];
	} else if ([method indexOf:@"微信"]!=NSNotFound || [method indexOf:@"wxpay"]!=NSNotFound || [method indexOf:@"weixin"]!=NSNotFound) {
		if (![self checkPayMethod:method]) {
			[ProgressHUD showError:@"设备没有可支付的客户端"];
			return;
		}
		//向微信终端程序注册第三方应用
		[WXApi registerApp:WX_APPID];
		if ([data isKindOfClass:[NSString class]]) {
			data = [data jsonValue];
		}
		[WechatPay payWithData:data];
	} else if ([method indexOf:@"余额"]!=NSNotFound || [method indexOf:@"yue"]!=NSNotFound) {
		if (success) success(AJPayTypeNormal);
	} else {
		if (fail) fail(AJPayTypeNormal, -1);
	}
}

//由APP生成签名
- (void)payWithPayMethod:(NSString*)method tradeNO:(NSString *)tradeNO productName:(NSString *)name description:(NSString *)description totalprice:(NSString *)totalprice success:(void (^)(AJPayType type))success fail:(void (^)(AJPayType type, int statusCode))fail{
	if (totalprice.floatValue <= 0) {
		if (success) success(AJPayTypeNormal);
	} else if ([method indexOf:@"支付宝"]!=NSNotFound || [method indexOf:@"alipay"]!=NSNotFound) {
		if (![self checkPayMethod:method]) {
			[ProgressHUD showError:@"设备没有可支付的客户端"];
			return;
		}
		_payStatus = AJPayStatusFail;
		[Alipay payWithTradeNO:tradeNO productName:name description:description totalprice:totalprice notifyURL:ALIPAY_NOTIFY_URL success:^{
			_payStatus = AJPayStatusSuccess;
			if (success) success(AJPayTypeAlipay);
		} fail:^(int statusCode) {
			_payStatus = AJPayStatusFail;
			if (fail) fail(AJPayTypeAlipay, statusCode);
		}];
	} else if ([method indexOf:@"微信"]!=NSNotFound || [method indexOf:@"wxpay"]!=NSNotFound || [method indexOf:@"weixin"]!=NSNotFound) {
		if (![self checkPayMethod:method]) {
			[ProgressHUD showError:@"设备没有可支付的客户端"];
			return;
		}
		//向微信终端程序注册第三方应用
		[WXApi registerApp:WX_APPID];
		[WechatPay payWithTradeNO:tradeNO productName:name totalprice:totalprice notifyURL:WX_NOTIFY_URL];
	} else if ([method indexOf:@"苹果"]!=NSNotFound || [method indexOf:@"apple"]!=NSNotFound) {
		[ApplePay payWithTradeNO:tradeNO productName:name totalprice:totalprice notifyURL:APPLEPAY_NOTIFY_URL success:^{
			_payStatus = AJPayStatusSuccess;
			if (success) success(AJPayTypeApplePay);
		} fail:^{
			_payStatus = AJPayStatusFail;
			if (fail) fail(AJPayTypeApplePay, -1);
		}];
	} else if ([method indexOf:@"余额"]!=NSNotFound || [method indexOf:@"yue"]!=NSNotFound) {
		if (success) success(AJPayTypeNormal);
	} else {
		if (fail) fail(AJPayTypeNormal, -1);
	}
}

@end
