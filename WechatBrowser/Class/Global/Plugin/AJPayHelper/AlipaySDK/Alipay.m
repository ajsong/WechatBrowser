//
//  Alipay.m
//
//  Created by ajsong on 15/4/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AlipayOrder.h"
#import "DataSigner.h"

@implementation Alipay

+ (void)payWithOrderString:(NSString*)orderString success:(void (^)(void))success fail:(void (^)(int statusCode))fail{
	//应用注册scheme,在Info.plist定义URL types
	NSString *appScheme = ALIPAY_APPSCHEME;
	orderString = [orderString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
	
	[[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
		//NSLog(@"%@",resultDic);
		//结果处理
		AlipayResult *result = [AlipayResult itemWithDictory:resultDic];
		//用公钥验证签名 严格验证请使用result.resultString与result.signString验签
		if (result){
			if (result.statusCode == 9000) {
				//状态返回9000为成功
				if (success) success();
			} else {
				//失败
				if (fail) fail(result.statusCode);
			}
			/*
			 9000 订单支付成功
			 8000 正在处理中
			 4000 订单支付失败
			 6001 用户中途取消
			 6002 网络连接出错
			 */
		} else {
			NSLog(@"未知错误");
		}
	}];
}

+ (void)payWithTradeNO:(NSString*)tradeNO productName:(NSString*)name description:(NSString*)description totalprice:(NSString*)totalprice notifyURL:(NSString*)notifyURL success:(void (^)(void))success fail:(void (^)(int statusCode))fail{
	/*
	 *商户的唯一的parnter和seller。
	 *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
	 */
	NSString *partner = ALIPAY_PARTNER;
	NSString *seller = ALIPAY_SELLER;
	NSString *privateKey = ALIPAY_PRIVATEKEY;
	NSString *order_price = [NSString stringWithFormat:@"%.2f", [totalprice floatValue]];
	
	/*
	 *生成订单信息及签名
	 */
	//将商品信息赋予AlipayOrder的成员变量
	AlipayOrder *order = [[AlipayOrder alloc] init];
	order.partner = partner;
	order.seller = seller;
	order.tradeNO = tradeNO; //订单ID（由商家自行制定）
	order.productName = name; //商品标题
	order.productDescription = description.length ? description : name; //商品描述
	order.amount = order_price; //商品价格,单位元
	order.notifyURL = notifyURL; //回调URL
	
	order.service = @"mobile.securitypay.pay";
	order.paymentType = @"1";
	order.inputCharset = @"utf-8";
	order.itBPay = @"30m";
	order.showUrl = @"m.alipay.com";
	
	//应用注册scheme,在Info.plist定义URL types
	NSString *appScheme = ALIPAY_APPSCHEME;
	
	//将商品信息拼接成字符串
	NSString *orderSpec = [order description];
	//NSLog(@"orderSpec = %@",orderSpec);
	
	//获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
	id<DataSigner> signer = CreateRSADataSigner(privateKey);
	NSString *signedString = [signer signString:orderSpec];
	
	//将签名成功字符串格式化为订单字符串,请严格按照该格式
	NSString *orderString = nil;
	if (signedString != nil) {
		orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, @"RSA"];
		//下面是没有安装客户端而使用网页版支付的返回结果，客户端版需要在 AppDelegate 内设置
		[[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
			//NSLog(@"%@",resultDic);
			//结果处理
			AlipayResult *result = [AlipayResult itemWithDictory:resultDic];
			//用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			if (result){
				if (result.statusCode == 9000) {
					//状态返回9000为成功
					if (success) success();
				} else {
					//失败
					if (fail) fail(result.statusCode);
				}
				/*
				 9000 订单支付成功
				 8000 正在处理中
				 4000 订单支付失败
				 6001 用户中途取消
				 6002 网络连接出错
				 */
			} else {
				NSLog(@"未知错误");
			}
		}];
	}
}

@end
