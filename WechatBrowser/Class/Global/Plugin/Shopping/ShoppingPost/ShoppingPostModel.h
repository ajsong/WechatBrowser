//
//  ShoppingPostModel.h
//
//  Created by ajsong on 2016-5-18.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShoppingConfig.h"

@interface ShoppingPostModel : NSObject
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,strong) NSDictionary *origin; //原始数据
@property (nonatomic,assign) CGFloat totalprice; //总价格(包括运费)
@property (nonatomic,assign) CGFloat goods_totalprice; //商品总价格
@property (nonatomic,assign) CGFloat shippingfee; //运费
@property (nonatomic,assign) BOOL integral_order; //积分商城订单
@property (nonatomic,assign) CGFloat money; //用户余额
@property (nonatomic,assign) NSInteger integral; //用户积分
@property (nonatomic,assign) NSInteger addressid; //收货地址-地址ID
@property (nonatomic,assign) NSInteger memberid; //收货地址-会员ID
@property (nonatomic,strong) NSString *contactman; //收货地址-联系人
@property (nonatomic,strong) NSString *mobile; //收货地址-手机号码
@property (nonatomic,strong) NSString *province; //收货地址-省
@property (nonatomic,strong) NSString *city; //收货地址-市
@property (nonatomic,strong) NSString *district; //收货地址-区
@property (nonatomic,strong) NSString *address; //收货地址-街道门牌
@property (nonatomic,strong) NSString *idcard; //收货地址-身份证
@property (nonatomic,strong) NSArray *shops; //店铺组

@property (nonatomic,strong) NSString *shopping_post_totalprice; //总价格/积分
@property (nonatomic,strong) NSString *shopping_post_goods_totalprice; //商品总价格/商品积分
@property (nonatomic,strong) NSString *shopping_post_shippingfee; //运费
@property (nonatomic,strong) NSString *shopping_post_integral_order; //积分商城订单
@property (nonatomic,strong) NSString *shopping_post_member_money; //用户余额
@property (nonatomic,strong) NSString *shopping_post_member_integral; //用户积分
@property (nonatomic,strong) NSString *shopping_post_addressdict; //收货地址对象
@property (nonatomic,strong) NSString *shopping_post_addressid; //收货地址-地址ID
@property (nonatomic,strong) NSString *shopping_post_memberid; //收货地址-会员ID
@property (nonatomic,strong) NSString *shopping_post_contactman; //收货地址-联系人
@property (nonatomic,strong) NSString *shopping_post_mobile; //收货地址-手机号码
@property (nonatomic,strong) NSString *shopping_post_province; //收货地址-省
@property (nonatomic,strong) NSString *shopping_post_city; //收货地址-市
@property (nonatomic,strong) NSString *shopping_post_district; //收货地址-区
@property (nonatomic,strong) NSString *shopping_post_address; //收货地址-街道门牌
@property (nonatomic,strong) NSString *shopping_post_idcard; //收货地址-身份证
@property (nonatomic,strong) NSString *shopping_post_shops; //店铺组
@property (nonatomic,strong) NSString *shopping_post_shop_id; //店铺组-店铺ID
@property (nonatomic,strong) NSString *shopping_post_shop_name; //店铺组-店铺名
@property (nonatomic,strong) NSString *shopping_post_shop_avatar; //店铺组-店铺头像
@property (nonatomic,strong) NSString *shopping_post_goods; //店铺组-商品组
@property (nonatomic,strong) NSString *shopping_post_goods_id; //商品ID
@property (nonatomic,strong) NSString *shopping_post_goods_name; //商品名称
@property (nonatomic,strong) NSString *shopping_post_goods_pic; //商品图片
@property (nonatomic,strong) NSString *shopping_post_goods_spec; //商品规格
@property (nonatomic,strong) NSString *shopping_post_goods_price; //商品价格
@property (nonatomic,strong) NSString *shopping_post_goods_integral; //商品积分
@property (nonatomic,strong) NSString *shopping_post_goods_quantity; //商品数量
@end

@interface ShoppingPostShopModel : NSObject
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,assign) NSInteger ID; //店铺ID
@property (nonatomic,strong) NSString *name; //店铺名称
@property (nonatomic,strong) NSString *imageUrl; //店铺头像
@property (nonatomic,strong) NSArray *goods; //商品组

@property (nonatomic,strong) NSString *shopping_post_shop_id;
@property (nonatomic,strong) NSString *shopping_post_shop_name;
@property (nonatomic,strong) NSString *shopping_post_shop_avatar;
@property (nonatomic,strong) NSString *shopping_post_goods;
@property (nonatomic,strong) NSString *shopping_post_goods_id;
@property (nonatomic,strong) NSString *shopping_post_goods_name;
@property (nonatomic,strong) NSString *shopping_post_goods_pic;
@property (nonatomic,strong) NSString *shopping_post_goods_spec;
@property (nonatomic,strong) NSString *shopping_post_goods_price;
@property (nonatomic,strong) NSString *shopping_post_goods_integral;
@property (nonatomic,strong) NSString *shopping_post_goods_quantity;
@end

@interface ShoppingPostGoodsModel : NSObject
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,assign) NSInteger ID; //商品ID
@property (nonatomic,strong) NSString *name; //商品名称
@property (nonatomic,strong) NSString *imageUrl; //商品图片
@property (nonatomic,strong) NSString *spec; //商品规格
@property (nonatomic,strong) NSString *price; //商品价格
@property (nonatomic,strong) NSString *integral; //商品积分
@property (nonatomic,assign) NSInteger quantity; //商品数量

@property (nonatomic,strong) NSString *shopping_post_goods_id;
@property (nonatomic,strong) NSString *shopping_post_goods_name;
@property (nonatomic,strong) NSString *shopping_post_goods_pic;
@property (nonatomic,strong) NSString *shopping_post_goods_spec;
@property (nonatomic,strong) NSString *shopping_post_goods_price;
@property (nonatomic,strong) NSString *shopping_post_goods_integral;
@property (nonatomic,strong) NSString *shopping_post_goods_quantity;
@end
