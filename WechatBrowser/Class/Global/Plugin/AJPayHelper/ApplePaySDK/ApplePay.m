//
//  ApplePay.m
//
//  Created by ajsong on 2016-10-08.
//  Copyright (c) 2016 @jsong. All rights reserved.
//

#import "ApplePay.h"
#import <PassKit/PassKit.h>

@interface ApplePay ()<PKPaymentAuthorizationViewControllerDelegate>{
	NSString *_tradeNO;
	NSString *_productName;
	NSString *_totalprice;
	NSString *_notifyURL;
	void (^_success)();
	void (^_fail)();
}
@end

@implementation ApplePay

+ (void)payWithTradeNO:(NSString *)tradeNO productName:(NSString *)name totalprice:(NSString *)totalprice notifyURL:(NSString *)notifyURL success:(void (^)(void))success fail:(void (^)(void))fail{
	[[[ApplePay alloc]init] payWithTradeNO:tradeNO productName:name totalprice:totalprice notifyURL:notifyURL success:success fail:fail];
}

- (void)payWithTradeNO:(NSString *)tradeNO productName:(NSString *)name totalprice:(NSString *)totalprice notifyURL:(NSString *)notifyURL success:(void (^)(void))success fail:(void (^)(void))fail{
	NSMutableArray *supportedNetworks = [NSMutableArray arrayWithObjects:PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, nil];
	if (@available(iOS 9.2, *)) {
		[supportedNetworks addObject:PKPaymentNetworkChinaUnionPay];
	}
	if (![PKPaymentAuthorizationViewController canMakePayments]) {
		//不支持Apple Pay
		[ProgressHUD showTrouble:@"当前系统版本不支持Apple Pay"];
	} else if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportedNetworks]){
		//没有绑定VISA或MasterCard或银联卡即去绑定银行卡
		[self addPay];
	} else {
		//去支付
		_tradeNO = tradeNO;
		_productName = name;
		_totalprice = totalprice;
		_notifyURL = notifyURL;
		_success = success;
		_fail = fail;
		[self buy];
	}
}

//添加银行卡
- (void)addPay{
	if (@available(iOS 8.3, *)) {
		PKPassLibrary *library = [[PKPassLibrary alloc]init];
		[library openPaymentSetup];
	} else {
		[ProgressHUD showTrouble:@"当前系统版本不支持添加支付卡"];
	}
}

//支付
- (void)buy{
	// 创建支付请求
	PKPaymentRequest *request = [[PKPaymentRequest alloc]init];
	// 商户号
	request.merchantIdentifier = APPLEPAY_MERCHANTID;
	// 货币代码和国家代码
	request.countryCode = @"CN";
	request.currencyCode = @"CNY";
	// 请求支付的网络（和之前判断的网络保持一致）
	NSMutableArray *supportedNetworks = [NSMutableArray arrayWithObjects:PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, nil];
	if (@available(iOS 9.2, *)) {
		[supportedNetworks addObject:PKPaymentNetworkChinaUnionPay];
	}
	request.supportedNetworks = supportedNetworks;
	// 商户处理方式
	request.merchantCapabilities = PKMerchantCapability3DS;
	// 商品
	NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:_totalprice];
	PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:_productName amount:price];
	request.paymentSummaryItems = @[item];
	// 账单或者发票接收地址
	request.requiredBillingAddressFields = PKAddressFieldAll;
	// 快递地址
	request.requiredShippingAddressFields = PKAddressFieldAll;
	
	//NSDecimalNumber *kuaidi = [NSDecimalNumber decimalNumberWithString:@"0.00"];
	//PKShippingMethod *method = [PKShippingMethod summaryItemWithLabel:@"顺丰" amount:kuaidi];
	//method.identifier = @"shangmen";
	//method.detail = @"72小时内送货上门";
	//request.shippingMethods = @[method];
	
	// 验证支付
	PKPaymentAuthorizationViewController *avc = [[PKPaymentAuthorizationViewController alloc]initWithPaymentRequest:request];
	avc.delegate = self;
	[APPCurrentController presentViewController:avc animated:YES completion:nil];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion{
	// 拿到支付信息发送给服务器，服务器处理完成后返回支付状态
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:_tradeNO forKey:@"out_trade_no"];
	[postData setValue:_tradeNO forKey:@"trade_no"];
	[postData setValue:@"TRADE_SUCCESS" forKey:@"trade_status"];
	[Common postApiWithUrl:_notifyURL data:postData timeout:5 feedback:ApiNonSuccessMessage success:^(NSMutableDictionary *json) {
		if ([json[@"error"]intValue]==0) {
			if (_success) _success();
			completion(PKPaymentAuthorizationStatusSuccess);
		} else {
			if (_fail) _fail();
			completion(PKPaymentAuthorizationStatusFailure);
		}
	} fail:^(NSMutableDictionary *json, NSInteger code) {
		if (_fail) _fail();
		completion(PKPaymentAuthorizationStatusFailure);
	} complete:nil];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
	[controller dismissViewControllerAnimated:YES completion:nil];
}

@end
