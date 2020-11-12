//
//  ShoppingModel.m
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "ShoppingModel.h"

NSString * const ShoppingCartAllPrice = @"ShoppingCartAllPrice";
NSString * const ShoppingCartData = @"ShoppingCartData";
NSString * const ShoppingCartNonData = @"ShoppingCartNonData";
NSString * const ShoppingCartChange = @"ShoppingCartChange";

@implementation ShoppingModel
- (void)setData:(NSDictionary *)data{
    self.discountText = @"折扣商品";
    self.discount     = data[_shopping_cart_discount];
    self.shopId       = [data[_shopping_cart_shop_id]integerValue];
    self.shopName     = data[_shopping_cart_shop_name];
    self.shopAvatar   = data[_shopping_cart_shop_avatar];
    self.headerState  = self.shopName.length ? 1 : [data[@"headerState"]integerValue];
    self.clickState   = 0;
    self.infoDict     = [[NSMutableDictionary alloc]init];
	[self.infoDict setObject:[NSString stringWithFormat:@"选择所有%@，即可享受%@折优惠", self.discountText, self.discount] forKey:@"headerTitle"];
	[self.infoDict setObject:@"小计 ¥0.00" forKey:@"footerTitle"];
	[self.infoDict setObject:@"" forKey:@"footerMinus"];
	if (data[_shopping_cart_goods_list] && [data[_shopping_cart_goods_list] isKindOfClass:[NSArray class]]) {
		self.datas = [self returnData:data[_shopping_cart_goods_list]];
	} else {
		self.datas = [self returnData:@[data]];
	}
}
- (void)setDiscountText:(NSString *)discountText{
	[self.infoDict setObject:[NSString stringWithFormat:@"选择所有%@，即可享受%@折优惠", discountText, self.discount] forKey:@"headerTitle"];
}
- (void)setShowHeaderView:(BOOL)showHeaderView{
	self.headerState = showHeaderView ? 1 : 0;
}
- (NSMutableArray *)returnData:(NSArray *)array{
	NSMutableArray *datas = [[NSMutableArray alloc]init];
	if (array && [array isKindOfClass:[NSArray class]]) {
		for (NSDictionary *dict in array) {
            ShoppingCellModel *model           = [[ShoppingCellModel alloc]init];
            model.shopping_cart_id             = _shopping_cart_id;
            model.shopping_cart_goods_id       = _shopping_cart_goods_id;
            model.shopping_cart_goods_name     = _shopping_cart_goods_name;
            model.shopping_cart_goods_pic      = _shopping_cart_goods_pic;
            model.shopping_cart_goods_spec     = _shopping_cart_goods_spec;
            model.shopping_cart_goods_specs    = _shopping_cart_goods_specs;
            model.shopping_cart_goods_price    = _shopping_cart_goods_price;
            model.shopping_cart_goods_quantity = _shopping_cart_goods_quantity;
            model.shopping_cart_goods_stocks   = _shopping_cart_goods_stocks;
            model.shopping_cart_goods_required = _shopping_cart_goods_required;
			model.data = dict;
			[datas addObject:model];
		}
	}
	return datas;
}
@end

@implementation ShoppingCellModel
- (void)setData:(NSDictionary *)data{
    self.origin     = data;
    self.ID         = [data[_shopping_cart_id]integerValue];
    self.goodsId    = [data[_shopping_cart_goods_id]integerValue];
    self.name       = data[_shopping_cart_goods_name];
    self.imageUrl   = data[_shopping_cart_goods_pic];
    self.spec       = data[_shopping_cart_goods_spec];
    self.specs      = data[_shopping_cart_goods_specs];
    self.price      = data[_shopping_cart_goods_price];
    self.quantity   = [data[_shopping_cart_goods_quantity]integerValue];
    self.stocks     = [data[_shopping_cart_goods_stocks]integerValue];
    self.required   = [data[_shopping_cart_goods_required]integerValue];
    self.indexPath  = nil;
    self.row        = 0;
    self.section    = 0;
    self.clickState = 0;
    self.editState  = 0;
}
@end
