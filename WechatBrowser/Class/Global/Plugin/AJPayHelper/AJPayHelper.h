//
//  AJPayHelper.h
//
//  Created by ajsong on 2016-8-31.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
	AJPayStatusFail = 0,
	AJPayStatusSuccess,
	AJPayStatusInvalid,
} AJPayStatus;

typedef enum : NSInteger {
	AJPayTypeNormal = 0,
	AJPayTypeAlipay,
	AJPayTypeWechat,
	AJPayTypeApplePay,
} AJPayType;

@interface AJPayHelper : NSObject

+ (AJPayHelper*)sharedHelper;
+ (BOOL)checkPayMethod:(NSString*)method;
+ (void)payWithPayMethod:(NSString*)method totalprice:(NSString *)totalprice data:(id)data success:(void (^)(AJPayType type))success fail:(void (^)(AJPayType type, int statusCode))fail;
+ (void)payWithPayMethod:(NSString*)method tradeNO:(NSString *)tradeNO productName:(NSString *)name description:(NSString *)description totalprice:(NSString *)totalprice success:(void (^)(AJPayType type))success fail:(void (^)(AJPayType type, int statusCode))fail;

- (AJPayStatus)payStatusWithUrl:(NSURL *)url; //AppDelegate用
- (BOOL)checkPayMethod:(NSString*)method;
//由后端生成签名
- (void)payWithPayMethod:(NSString*)method totalprice:(NSString *)totalprice data:(id)data success:(void (^)(AJPayType type))success fail:(void (^)(AJPayType type, int statusCode))fail;
//由APP生成签名
- (void)payWithPayMethod:(NSString*)method tradeNO:(NSString *)tradeNO productName:(NSString *)name description:(NSString *)description totalprice:(NSString *)totalprice success:(void (^)(AJPayType type))success fail:(void (^)(AJPayType type, int statusCode))fail;

@end
