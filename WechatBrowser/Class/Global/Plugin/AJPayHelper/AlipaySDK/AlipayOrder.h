//
//  AlipayOrder.h
//
//  Created by 方彬 on 11/2/13.
//

#import <Foundation/Foundation.h>

@interface AlipayOrder : NSObject

@property(nonatomic, copy) NSString * partner;
@property(nonatomic, copy) NSString * seller;
@property(nonatomic, copy) NSString * tradeNO; //订单ID（由商家自行制定）
@property(nonatomic, copy) NSString * productName; //商品标题
@property(nonatomic, copy) NSString * productDescription; //商品描述
@property(nonatomic, copy) NSString * amount; //商品价格
@property(nonatomic, copy) NSString * notifyURL; //回调URL

@property(nonatomic, copy) NSString * service; //@"mobile.securitypay.pay"
@property(nonatomic, copy) NSString * paymentType; //@"1"
@property(nonatomic, copy) NSString * inputCharset; //@"utf-8"
@property(nonatomic, copy) NSString * itBPay; //@"30m"
@property(nonatomic, copy) NSString * showUrl; //@"m.alipay.com"

@property(nonatomic, copy) NSString * rsaDate; //可选
@property(nonatomic, copy) NSString * appID; //可选

@property(nonatomic, readonly) NSMutableDictionary * extraParams;

@end
