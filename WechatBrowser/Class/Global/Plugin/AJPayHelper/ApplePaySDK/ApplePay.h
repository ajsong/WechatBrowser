//
//  ApplePay.h
//
//  Created by ajsong on 2016-10-08.
//  Copyright (c) 2016 @jsong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplePay : NSObject

+ (void)payWithTradeNO:(NSString*)tradeNO productName:(NSString*)name totalprice:(NSString*)totalprice notifyURL:(NSString*)notifyURL success:(void (^)(void))success fail:(void (^)(void))fail;

@end
