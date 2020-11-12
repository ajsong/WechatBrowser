//
//  ShoppingPost.h
//
//  Created by ajsong on 2016-5-18.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoppingPostModel.h"

@interface ShoppingPost : UIViewController
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,strong) ShoppingPostModel *model;
@property (nonatomic,assign) CGSize boxSize; //勾选按钮的大小
@property (nonatomic,strong) UIImage *image; //勾选按钮的默认图片
@property (nonatomic,strong) UIImage *selectedImage; //勾选按钮的选中图片
@property (nonatomic,strong) UILabel *addressNull; //没有地址
@property (nonatomic,strong) UIView *addressView; //地址容器
@property (nonatomic,strong) UIView *bottomView; //底部浮动栏
@property (nonatomic,strong) UIToolbar *bottomBg; //底部浮动栏背景
@property (nonatomic,assign) CGFloat bottomViewHeight; //底部浮动栏高度
@property (nonatomic,assign) CGFloat bottomPrice; //底部实付款价格
@property (nonatomic,strong) UIButton *checkoutBtn; //结算按钮
@property (nonatomic,strong) UIColor *btnColor; //按钮背景色
@property (nonatomic,strong) UIColor *textColor; //商品字体颜色
@property (nonatomic,strong) UIFont *font; //商品字体
@property (nonatomic,strong) UIColor *specTextColor; //规格字体颜色
@property (nonatomic,strong) UIFont *specFont; //规格字体
@property (nonatomic,strong) NSString *contactman;
@property (nonatomic,strong) NSString *mobile;
@property (nonatomic,strong) NSString *province;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *district;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *idcard;
@property (nonatomic,strong) NSString *payMethod;
@property (nonatomic,strong) NSMutableArray *payValues;
@property (nonatomic,assign) BOOL allPayMethod; //强制显示所有支付方式,一般测试用
@property (nonatomic,assign) BOOL selectCustom; //点击图片或商品名称使用自定义操作,而不是默认,然后调用 -ShoppingPost:selectedWithModel:
- (void)didLoadViews;
- (void)ShoppingPost:(ShoppingPost*)shoppingPost selectedWithModel:(ShoppingPostGoodsModel *)model;
- (void)ShoppingPostToggleShowAddressView;
- (void)ShoppingPostNewAddress:(ShoppingPost*)shoppingPost;
- (void)ShoppingPostSelectAddress:(ShoppingPost*)shoppingPost;
- (NSArray*)ShoppingPostOptionViews:(ShoppingPost*)shoppingPost data:(NSDictionary*)data;
- (void)ShoppingPostCheckout:(ShoppingPost*)shoppingPost payMethod:(NSString*)payMethod;

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
