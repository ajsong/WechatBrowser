//
//  ShoppingConfig.h
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

typedef enum : NSInteger {
	ShoppingCartBtnNone = -1,
	ShoppingCartBtnMinus,
	ShoppingCartBtnPlus,
} ShoppingCartBtnType;

#define SHOPPING_PRICE_COLOR COLORRGB(@"d3100f") //价格颜色
#define SHOPPING_BUTTON_COLOR COLORRGB(@"e24e17") //按钮背景色
#define SHOPPING_BUTTON_LINE_COLOR COLORRGB(@"ddd") //按钮线条色
#define SHOPPING_SEPARATOR_COLOR COLORRGB(@"eaeaea") //相隔线颜色
#define SHOPPING_GRAY_COLOR COLORRGB(@"fbfbfb") //灰背景色
#define SHOPPING_PAY_NAMES @[@"余额支付", @"微信支付", @"支付宝支付"]
#define SHOPPING_PAY_VALUES @[@"yue", @"wxpay", @"alipay"]

#pragma mark - 购物车
#define SHOPPING_CART_DISCOUNT @"discount" //优惠折扣
#define SHOPPING_CART_SHOP_ID @"shop_id" //店铺ID
#define SHOPPING_CART_SHOP_NAME @"shop_name" //店铺头像
#define SHOPPING_CART_SHOP_AVATAR @"shop_avatar" //店铺头像
#define SHOPPING_CART_GOODS_LIST @"goods" //商品列表

#define SHOPPING_CART_ID @"id" //购物车ID
#define SHOPPING_CART_GOODS_ID @"id" //商品ID
#define SHOPPING_CART_GOODS_NAME @"name" //商品名称
#define SHOPPING_CART_GOODS_PIC @"pic" //商品图片
#define SHOPPING_CART_GOODS_SPEC @"spec" //商品规格
#define SHOPPING_CART_GOODS_SPECS @"specs" //商品规格组
#define SHOPPING_CART_GOODS_PRICE @"price" //商品价格
#define SHOPPING_CART_GOODS_QUANTITY @"num" //商品数量
#define SHOPPING_CART_GOODS_STOCKS @"stocks" //商品库存
#define SHOPPING_CART_GOODS_REQUIRED @"required" //优惠必选商品

#pragma mark - 确认订单
#define SHOPPING_POST_TOTALPRICE @"total_price" //总价格/积分
#define SHOPPING_POST_GOODS_TOTALPRICE @"goods_total_price" //商品总价格/商品积分
#define SHOPPING_POST_SHIPPINGFEE @"shipping_fee" //运费
#define SHOPPING_POST_INTEGRAL_ORDER @"integral_order" //积分商城订单
#define SHOPPING_POST_MEMBER_MONEY @"money" //用户余额
#define SHOPPING_POST_MEMBER_INTEGRAL @"integral" //用户积分
#define SHOPPING_POST_ADDRESSDICT @"address" //收货地址对象
#define SHOPPING_POST_ADDRESSID @"id" //收货地址-id
#define SHOPPING_POST_MEMBERID @"uid" //收货地址-会员ID
#define SHOPPING_POST_CONTACTMAN @"username" //收货地址-联系人
#define SHOPPING_POST_MOBILE @"mobile" //收货地址-手机号码
#define SHOPPING_POST_PROVINCE @"province" //收货地址-省
#define SHOPPING_POST_CITY @"city" //收货地址-市
#define SHOPPING_POST_DISTRICT @"area" //收货地址-区
#define SHOPPING_POST_ADDRESS @"street" //收货地址-街道门牌
#define SHOPPING_POST_IDCARD @"idcard" //收货地址-身份证
#define SHOPPING_POST_SHOPS @"shops" //店铺组
#define SHOPPING_POST_SHOP_ID @"shop_id" //店铺组-店铺ID
#define SHOPPING_POST_SHOP_NAME @"shop_name" //店铺组-店铺名
#define SHOPPING_POST_SHOP_AVATAR @"shop_avatar" //店铺组-店铺头像
#define SHOPPING_POST_GOODS @"goods" //店铺组-商品组

#define SHOPPING_POST_GOODS_ID @"id" //商品ID
#define SHOPPING_POST_GOODS_NAME @"name" //商品名称
#define SHOPPING_POST_GOODS_PIC @"pic" //商品图片
#define SHOPPING_POST_GOODS_SPEC @"spec" //商品规格
#define SHOPPING_POST_GOODS_PRICE @"price" //商品价格
#define SHOPPING_POST_GOODS_INTEGRAL @"integral" //商品积分
#define SHOPPING_POST_GOODS_QUANTITY @"num" //商品数量
