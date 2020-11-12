//
//  ShoppingModel.h
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShoppingConfig.h"

UIKIT_EXTERN NSString * const ShoppingCartAllPrice; //设置总价
UIKIT_EXTERN NSString * const ShoppingCartData; //设置数据
UIKIT_EXTERN NSString * const ShoppingCartNonData; //购物车没有任何商品
UIKIT_EXTERN NSString * const ShoppingCartChange; //改变购物车中的商品
UIKIT_EXTERN NSString * const ShoppingCartDelete; //删除购物车中的商品

@interface ShoppingModel : NSObject
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,assign) BOOL showHeaderView; //强制显示头部
@property (nonatomic,assign) NSInteger headerState; //字段控制显示头部
@property (nonatomic,assign) NSInteger clickState; //选中状态
@property (nonatomic,strong) NSMutableArray *datas; //分组数据
@property (nonatomic,strong) NSString *discount; //折扣
@property (nonatomic,assign) NSInteger shopId; //店铺ID
@property (nonatomic,strong) NSString *shopName; //店铺名称,不为空即显示头部
@property (nonatomic,strong) NSString *shopAvatar; //店铺头像
@property (nonatomic,strong) NSMutableDictionary *infoDict;
@property (nonatomic,strong) NSString *discountText;

@property (nonatomic,strong) NSString *shopping_cart_discount; //优惠折扣
@property (nonatomic,strong) NSString *shopping_cart_shop_id; //店铺ID
@property (nonatomic,strong) NSString *shopping_cart_shop_name; //店铺头像
@property (nonatomic,strong) NSString *shopping_cart_shop_avatar; //店铺头像
@property (nonatomic,strong) NSString *shopping_cart_goods_list; //商品列表
@property (nonatomic,strong) NSString *shopping_cart_id; //购物车ID
@property (nonatomic,strong) NSString *shopping_cart_goods_id; //商品ID
@property (nonatomic,strong) NSString *shopping_cart_goods_name; //商品名称
@property (nonatomic,strong) NSString *shopping_cart_goods_pic; //商品图片
@property (nonatomic,strong) NSString *shopping_cart_goods_spec; //商品规格
@property (nonatomic,strong) NSString *shopping_cart_goods_specs; //商品规格组
@property (nonatomic,strong) NSString *shopping_cart_goods_price; //商品价格
@property (nonatomic,strong) NSString *shopping_cart_goods_quantity; //商品数量
@property (nonatomic,strong) NSString *shopping_cart_goods_stocks; //商品库存
@property (nonatomic,strong) NSString *shopping_cart_goods_required; //优惠必选商品
@end

@interface ShoppingCellModel : NSObject
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,strong) NSDictionary *origin; //原始数据
@property (nonatomic,assign) NSInteger ID; //购物车ID
@property (nonatomic,assign) NSInteger goodsId; //商品ID
@property (nonatomic,strong) NSString *name; //商品名称
@property (nonatomic,strong) NSString *imageUrl; //商品图片
@property (nonatomic,strong) NSString *spec; //商品规格
@property (nonatomic,strong) NSArray *specs; //商品规格组
@property (nonatomic,strong) NSString *price; //商品价格
@property (nonatomic,assign) NSInteger quantity; //商品数量
@property (nonatomic,assign) NSInteger stocks; //商品库存
@property (nonatomic,assign) NSInteger required; //必选商品,选择了该商品才会进行折扣结算
@property (nonatomic,assign) NSInteger editState; //编辑状态
@property (nonatomic,assign) NSInteger clickState; //选中状态
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,assign) NSInteger row;
@property (nonatomic,assign) NSInteger section;

@property (nonatomic,strong) NSString *shopping_cart_id;
@property (nonatomic,strong) NSString *shopping_cart_goods_id;
@property (nonatomic,strong) NSString *shopping_cart_goods_name;
@property (nonatomic,strong) NSString *shopping_cart_goods_pic;
@property (nonatomic,strong) NSString *shopping_cart_goods_spec;
@property (nonatomic,strong) NSString *shopping_cart_goods_specs;
@property (nonatomic,strong) NSString *shopping_cart_goods_price;
@property (nonatomic,strong) NSString *shopping_cart_goods_quantity;
@property (nonatomic,strong) NSString *shopping_cart_goods_stocks;
@property (nonatomic,strong) NSString *shopping_cart_goods_required;
@end
