//
//  ShoppingPostModel.m
//
//  Created by ajsong on 2016-5-18.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "ShoppingPostModel.h"

@implementation ShoppingPostModel
- (void)setData:(NSDictionary *)data{
    self.origin           = data;
    self.totalprice       = [data[_shopping_post_totalprice]floatValue];
    self.goods_totalprice = [data[_shopping_post_goods_totalprice]floatValue];
    self.shippingfee      = [data[_shopping_post_shippingfee]floatValue];
    self.integral_order   = [data[_shopping_post_integral_order]boolValue];
    self.money            = [data[_shopping_post_member_money]floatValue];
    self.integral         = [data[_shopping_post_member_integral]integerValue];
	if ([data[_shopping_post_addressdict] isDictionary]) {
		self.addressid   = [data[_shopping_post_addressdict][_shopping_post_addressid]integerValue];
		self.memberid   = [data[_shopping_post_addressdict][_shopping_post_memberid]integerValue];
		self.contactman = data[_shopping_post_addressdict][_shopping_post_contactman];
		self.mobile     = data[_shopping_post_addressdict][_shopping_post_mobile];
		self.province   = data[_shopping_post_addressdict][_shopping_post_province];
		self.city       = data[_shopping_post_addressdict][_shopping_post_city];
		self.district   = data[_shopping_post_addressdict][_shopping_post_district];
		self.address    = data[_shopping_post_addressdict][_shopping_post_address];
		self.idcard     = data[_shopping_post_addressdict][_shopping_post_idcard];
	}
	self.shops = [[NSMutableArray alloc]init];
	if ([data[_shopping_post_shops] isArray]) {
		for (NSDictionary *dict in data[_shopping_post_shops]) {
            ShoppingPostShopModel *model       = [[ShoppingPostShopModel alloc]init];
            model.shopping_post_shop_id        = _shopping_post_shop_id;
            model.shopping_post_shop_name      = _shopping_post_shop_name;
            model.shopping_post_shop_avatar    = _shopping_post_shop_avatar;
            model.shopping_post_goods          = _shopping_post_goods;
            model.shopping_post_goods_id       = _shopping_post_goods_id;
            model.shopping_post_goods_name     = _shopping_post_goods_name;
            model.shopping_post_goods_pic      = _shopping_post_goods_pic;
            model.shopping_post_goods_spec     = _shopping_post_goods_spec;
            model.shopping_post_goods_price    = _shopping_post_goods_price;
            model.shopping_post_goods_integral = _shopping_post_goods_integral;
            model.shopping_post_goods_quantity = _shopping_post_goods_quantity;
			model.data = dict;
			[self.shops addObject:model];
		}
	} else if ([data[_shopping_post_goods] isArray]) {
        ShoppingPostShopModel *model       = [[ShoppingPostShopModel alloc]init];
        model.shopping_post_shop_id        = _shopping_post_shop_id;
        model.shopping_post_shop_name      = _shopping_post_shop_name;
        model.shopping_post_shop_avatar    = _shopping_post_shop_avatar;
        model.shopping_post_goods          = _shopping_post_goods;
        model.shopping_post_goods_id       = _shopping_post_goods_id;
        model.shopping_post_goods_name     = _shopping_post_goods_name;
        model.shopping_post_goods_pic      = _shopping_post_goods_pic;
        model.shopping_post_goods_spec     = _shopping_post_goods_spec;
        model.shopping_post_goods_price    = _shopping_post_goods_price;
        model.shopping_post_goods_integral = _shopping_post_goods_integral;
        model.shopping_post_goods_quantity = _shopping_post_goods_quantity;
		model.data = @{_shopping_post_goods:data[_shopping_post_goods]};
		[self.shops addObject:model];
	}
}
@end

@implementation ShoppingPostShopModel
- (void)setData:(NSDictionary *)data{
	self.ID       = [data[_shopping_post_shop_id] integerValue];
	self.name     = data[_shopping_post_shop_name];
	self.imageUrl = data[_shopping_post_shop_avatar];
	NSMutableArray *datas = [[NSMutableArray alloc]init];
	if ([data[_shopping_post_goods] isArray]) {
		for (NSDictionary *dict in data[_shopping_post_goods]) {
            ShoppingPostGoodsModel *model      = [[ShoppingPostGoodsModel alloc]init];
            model.shopping_post_goods_id       = _shopping_post_goods_id;
            model.shopping_post_goods_name     = _shopping_post_goods_name;
            model.shopping_post_goods_pic      = _shopping_post_goods_pic;
            model.shopping_post_goods_spec     = _shopping_post_goods_spec;
            model.shopping_post_goods_price    = _shopping_post_goods_price;
            model.shopping_post_goods_integral = _shopping_post_goods_integral;
            model.shopping_post_goods_quantity = _shopping_post_goods_quantity;
			model.data = dict;
			[datas addObject:model];
		}
	}
	self.goods = datas;
}
@end

@implementation ShoppingPostGoodsModel
- (void)setData:(NSDictionary *)data{
    self.ID       = [data[_shopping_post_goods_id] integerValue];
    self.name     = data[_shopping_post_goods_name];
    self.imageUrl = data[_shopping_post_goods_pic];
    self.spec     = data[_shopping_post_goods_spec];
    self.price    = data[_shopping_post_goods_price];
    self.integral = data[_shopping_post_goods_integral];
    self.quantity = [data[_shopping_post_goods_quantity] integerValue];
}
@end
