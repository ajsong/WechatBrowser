//
//  Alipay.h
//
//  Created by ajsong on 15/4/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alipay : NSObject

+ (void)payWithOrderString:(NSString*)orderString success:(void (^)(void))success fail:(void (^)(int statusCode))fail;
+ (void)payWithTradeNO:(NSString*)tradeNO productName:(NSString*)name description:(NSString*)description totalprice:(NSString*)totalprice notifyURL:(NSString*)notifyURL success:(void (^)(void))success fail:(void (^)(int statusCode))fail;

@end
