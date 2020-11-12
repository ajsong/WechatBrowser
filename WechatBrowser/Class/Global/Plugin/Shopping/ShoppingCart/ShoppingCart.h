//
//  ShoppingCart.h
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoppingTableView.h"

@interface ShoppingCart : UIViewController<ShoppingCartDelegate>
@property (nonatomic,strong) NSArray *data; //数据
@property (nonatomic,assign) BOOL hiddenEdit; //隐藏编辑按钮
@property (nonatomic,assign) BOOL hiddenSubtotal; //隐藏小计
@property (nonatomic,strong) ShoppingTableView *tableView; //表格
@property (nonatomic,assign) BOOL isGrouped; //tableView使用Grouped
@property (nonatomic,assign) CGFloat contentInsetBottom; //叠加到tableView的contentInset.bottom
@property (nonatomic,strong) UIView *emptyView; //购物车为空时显示的View,会替换内置的
@property (nonatomic,assign) CGSize boxSize; //勾选按钮的大小
@property (nonatomic,strong) UIImage *image; //勾选按钮的默认图片
@property (nonatomic,strong) UIImage *selectedImage; //勾选按钮的选中图片
@property (nonatomic,strong) NSString *discountTip; //搭配购文字, 设为空即不显示
@property (nonatomic,strong) NSString *discountText; //优惠商品文字, 设为空即不显示
@property (nonatomic,strong) UIColor *discountBackgroundColor; //搭配购、优惠商品背景色
@property (nonatomic,strong) UIView *bottomView; //底部浮动栏
@property (nonatomic,strong) UIToolbar *bottomBg; //底部浮动栏背景
@property (nonatomic,assign) CGFloat bottomViewHeight; //底部浮动栏高度
@property (nonatomic,strong) UIButton *editBtn; //编辑按钮
@property (nonatomic,strong) UIButton *allBtn; //全选按钮
@property (nonatomic,strong) UIButton *checkoutBtn; //结算按钮
@property (nonatomic,strong) UIColor *btnColor; //按钮背景色
@property (nonatomic,strong) UIColor *textColor; //商品字体颜色
@property (nonatomic,strong) UIFont *font; //商品字体
@property (nonatomic,strong) UIColor *specTextColor; //规格字体颜色
@property (nonatomic,strong) UIFont *specFont; //规格字体
@property (nonatomic,assign) CGFloat separatorHeight; //Section相隔高度

- (void)ShoppingCart:(ShoppingCart*)shoppingCart changeWithModel:(ShoppingCellModel *)model btnType:(ShoppingCartBtnType)btnType isTextField:(BOOL)isTextField isSpec:(BOOL)isSpec; //修改数量与规格
- (void)ShoppingCart:(ShoppingCart*)shoppingCart checkoutWithModels:(NSArray *)models isSubmit:(BOOL)isSubmit; //结算/批量删除
- (void)ShoppingCartWithNonData:(ShoppingCart*)shoppingCart; //没有数据

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
