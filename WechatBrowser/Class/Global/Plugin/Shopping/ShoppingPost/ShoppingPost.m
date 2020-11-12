//
//  ShoppingPost.m
//
//  Created by ajsong on 2016-5-18.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "ShoppingPost.h"

@interface ShoppingPost ()<AJCheckboxDelegate>{
	UIScrollView *_scrollView;
	NSMutableArray *_payNames;
	
	UILabel *_addressName;
	UILabel *_addressValue;
	CGFloat _productPrice;
	UILabel *_totalText;
	UILabel *_priceLabel;
}
@end

@implementation ShoppingPost

- (instancetype)init{
	self = [super init];
	if (self) {
        _bottomViewHeight               = 42.f*SCREEN_SCALE;
        _boxSize                        = CGSizeMakeScale(@44, @44);
        _contactman                     = @"";
        _mobile                         = @"";
        _province                       = @"";
        _city                           = @"";
        _district                       = @"";
        _address                        = @"";
        _idcard                         = @"";
        _payMethod                      = @"";

        _shopping_post_totalprice       = SHOPPING_POST_TOTALPRICE;
        _shopping_post_goods_totalprice = SHOPPING_POST_GOODS_TOTALPRICE;
        _shopping_post_shippingfee      = SHOPPING_POST_SHIPPINGFEE;
        _shopping_post_integral_order   = SHOPPING_POST_INTEGRAL_ORDER;
        _shopping_post_member_money     = SHOPPING_POST_MEMBER_MONEY;
        _shopping_post_member_integral  = SHOPPING_POST_MEMBER_INTEGRAL;
        _shopping_post_addressdict      = SHOPPING_POST_ADDRESSDICT;
		_shopping_post_addressid        = SHOPPING_POST_ADDRESSID;
		_shopping_post_memberid         = SHOPPING_POST_MEMBERID;
        _shopping_post_contactman       = SHOPPING_POST_CONTACTMAN;
        _shopping_post_mobile           = SHOPPING_POST_MOBILE;
        _shopping_post_province         = SHOPPING_POST_PROVINCE;
        _shopping_post_city             = SHOPPING_POST_CITY;
        _shopping_post_district         = SHOPPING_POST_DISTRICT;
        _shopping_post_address          = SHOPPING_POST_ADDRESS;
        _shopping_post_idcard           = SHOPPING_POST_IDCARD;
        _shopping_post_shops            = SHOPPING_POST_SHOPS;
        _shopping_post_shop_id          = SHOPPING_POST_SHOP_ID;
        _shopping_post_shop_name        = SHOPPING_POST_SHOP_NAME;
        _shopping_post_shop_avatar      = SHOPPING_POST_SHOP_AVATAR;
        _shopping_post_goods            = SHOPPING_POST_GOODS;
        _shopping_post_goods_id         = SHOPPING_POST_GOODS_ID;
        _shopping_post_goods_name       = SHOPPING_POST_GOODS_NAME;
        _shopping_post_goods_pic        = SHOPPING_POST_GOODS_PIC;
        _shopping_post_goods_spec       = SHOPPING_POST_GOODS_SPEC;
        _shopping_post_goods_price      = SHOPPING_POST_GOODS_PRICE;
        _shopping_post_goods_integral   = SHOPPING_POST_GOODS_INTEGRAL;
        _shopping_post_goods_quantity   = SHOPPING_POST_GOODS_QUANTITY;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"确认订单";
	self.view.backgroundColor = COLORBACK;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	if (@available(iOS 11.0, *)) _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
	[self.view addSubview:_scrollView];
	
	[self performSelector:@selector(loadViews) withObject:nil afterDelay:0];
}

#pragma mark - 设置数据
- (void)setData:(NSDictionary *)data{
	if (!data.isDictionary) return;
    _data       = [data UpyunSuffix:@"!small"];
    _contactman = @"";
    _mobile     = @"";
    _province   = @"";
    _city       = @"";
    _district   = @"";
    _address    = @"";
    _idcard     = @"";
    _payMethod  = @"";
    _model      = [[ShoppingPostModel alloc]init];
    _model.shopping_post_totalprice       = _shopping_post_totalprice;
    _model.shopping_post_goods_totalprice = _shopping_post_goods_totalprice;
    _model.shopping_post_shippingfee      = _shopping_post_shippingfee;
    _model.shopping_post_integral_order   = _shopping_post_integral_order;
    _model.shopping_post_member_money     = _shopping_post_member_money;
    _model.shopping_post_member_integral  = _shopping_post_member_integral;
    _model.shopping_post_addressdict      = _shopping_post_addressdict;
	_model.shopping_post_addressid        = _shopping_post_addressid;
	_model.shopping_post_memberid         = _shopping_post_memberid;
    _model.shopping_post_contactman       = _shopping_post_contactman;
    _model.shopping_post_mobile           = _shopping_post_mobile;
    _model.shopping_post_province         = _shopping_post_province;
    _model.shopping_post_city             = _shopping_post_city;
    _model.shopping_post_district         = _shopping_post_district;
    _model.shopping_post_address          = _shopping_post_address;
    _model.shopping_post_idcard           = _shopping_post_idcard;
    _model.shopping_post_shops            = _shopping_post_shops;
    _model.shopping_post_shop_id          = _shopping_post_shop_id;
    _model.shopping_post_shop_name        = _shopping_post_shop_name;
    _model.shopping_post_shop_avatar      = _shopping_post_shop_avatar;
    _model.shopping_post_goods            = _shopping_post_goods;
    _model.shopping_post_goods_id         = _shopping_post_goods_id;
    _model.shopping_post_goods_name       = _shopping_post_goods_name;
    _model.shopping_post_goods_pic        = _shopping_post_goods_pic;
    _model.shopping_post_goods_spec       = _shopping_post_goods_spec;
    _model.shopping_post_goods_price      = _shopping_post_goods_price;
    _model.shopping_post_goods_integral   = _shopping_post_goods_integral;
    _model.shopping_post_goods_quantity   = _shopping_post_goods_quantity;
	_model.data = _data;
}

- (void)setImage:(UIImage *)image{
	_image = image;
	if (!image) {
		_image = IMG(@"checkbox");
	}
}

- (void)setSelectedImage:(UIImage *)selectedImage{
	_selectedImage = selectedImage;
	if (!selectedImage) {
		_selectedImage = IMG(@"checkbox-x");
	}
}

- (void)loadViews{
	[_scrollView removeAllSubviews];
	if (!_data.isDictionary) return;
	
	_bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.height, SCREEN_WIDTH, _bottomViewHeight)];
	[self.view addSubview:_bottomView];
	
	_bottomBg = [[UIToolbar alloc]initWithFrame:_bottomView.bounds];
	[_bottomView addSubview:_bottomBg];
	
	_checkoutBtn = [[UIButton alloc]initWithFrame:CGRectMake(_bottomView.width-100*SCREEN_SCALE, 0, 100*SCREEN_SCALE, _bottomView.height)];
	_checkoutBtn.titleLabel.font = FONT(12);
	_checkoutBtn.backgroundColor = _btnColor ? _btnColor : SHOPPING_BUTTON_COLOR;
	[_checkoutBtn setTitle:@"提交订单" forState:UIControlStateNormal];
	[_checkoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_checkoutBtn addTarget:self action:@selector(postData) forControlEvents:UIControlEventTouchUpInside];
	[_bottomView addSubview:_checkoutBtn];
	
	UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _checkoutBtn.left, _bottomView.height)];
	[_bottomView addSubview:leftView];
	
	NSString *string = FORMAT(@"%@<p>%@</p>", !_model.integral_order?@"实付款: ":@"总积分: ", !_model.integral_order?@"￥":@"");
	NSDictionary *style = @{@"body":@[FONTBOLD(12), COLOR333], @"p":SHOPPING_PRICE_COLOR};
	_totalText = [[UILabel alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 0, 56*SCREEN_SCALE, leftView.height)];
	_totalText.attributedText = [string attributedStyle:style];
	_totalText.backgroundColor = [UIColor clearColor];
	_totalText.element[@"text"] = string;
	[leftView addSubview:_totalText];
	
	_priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(_totalText.right, -1*SCREEN_SCALE, leftView.width-_totalText.right, leftView.height)];
	if (!_model.integral_order) {
		_priceLabel.text = FORMAT(@"%.2f", _model.totalprice);
	} else {
		_priceLabel.text = FORMAT(@"%.f", _model.totalprice);
	}
	_priceLabel.textColor = SHOPPING_PRICE_COLOR;
	_priceLabel.font = FONTPRICE(14);
	_priceLabel.backgroundColor = [UIColor clearColor];
	[leftView addSubview:_priceLabel];
	_priceLabel.priceFont = FONTPRICE(18);
	
	_bottomView.matchX = UIViewMatchXBottom;
	_bottomView.top = self.view.height;
	_bottomBg.frame = _bottomView.bounds;
	
	_bottomViewHeight = _bottomView.height;
	_scrollView.contentInset = UIEdgeInsetsMake(0, 0, _bottomViewHeight, 0);
	
	[self performSelector:@selector(setBottomTextColor) withObject:nil afterDelay:0];
	
	_payNames = [[NSMutableArray alloc]init];
	_payValues = [[NSMutableArray alloc]init];
	for (int i=0; i<SHOPPING_PAY_VALUES.count; i++) {
		if (_allPayMethod) {
			[_payNames addObject:SHOPPING_PAY_NAMES[i]];
			[_payValues addObject:SHOPPING_PAY_VALUES[i]];
		} else {
			if ([SHOPPING_PAY_VALUES[i] isEqualToString:@"yue"] && _model.money>0) {
				[_payNames addObject:SHOPPING_PAY_NAMES[i]];
				[_payValues addObject:SHOPPING_PAY_VALUES[i]];
			}
			if ([SHOPPING_PAY_VALUES[i] isEqualToString:@"wxpay"] && [ShareHelper isWXAppInstalled] && ![Common isAuditKey]) {
				[_payNames addObject:SHOPPING_PAY_NAMES[i]];
				[_payValues addObject:SHOPPING_PAY_VALUES[i]];
			}
			if ([SHOPPING_PAY_VALUES[i] isEqualToString:@"alipay"] && [ShareHelper isAlipayInstalled] && ![Common isAuditKey]) {
				[_payNames addObject:SHOPPING_PAY_NAMES[i]];
				[_payValues addObject:SHOPPING_PAY_VALUES[i]];
			}
		}
	}
	
	UIFont *font11 = FONT(11);
	UIFont *font12 = FONT(12);
	UIFont *fontbold12 = FONTBOLD(12);
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMakeScale(0, 0, SCREEN_WIDTH, @74)];
	view.backgroundColor = COLORWHITE;
	[_scrollView addSubview:view];
	UIImageView *addressBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, view.height-4*SCREEN_SCALE, SCREEN_WIDTH, 4*SCREEN_SCALE)];
	addressBg.image = IMG(@"shopping-address-bg");
	[view addSubview:addressBg];
	
	_addressNull = [[UILabel alloc]initWithFrame:view.bounds];
	_addressNull.text = @"+ 完善收货地址";
	_addressNull.textColor = _textColor ? _textColor : COLOR999;
	_addressNull.textAlignment = NSTextAlignmentCenter;
	_addressNull.font = font12;
	_addressNull.backgroundColor = [UIColor clearColor];
	_addressNull.hidden = _model.memberid!=0;
	[view addSubview:_addressNull];
	[_addressNull clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		[target ShoppingPostNewAddress:target];
	}];
	
	_addressView = [[UIView alloc]initWithFrame:view.bounds];
	_addressView.hidden = _model.memberid==0;
	[view addSubview:_addressView];
	[_addressView clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		[target ShoppingPostSelectAddress:target];
	}];
	
	UIImageView *push = [[UIImageView alloc]initWithFrame:CGRectMake(_addressView.width-44*SCREEN_SCALE, (_addressView.height-44*SCREEN_SCALE)/2, 44*SCREEN_SCALE, 44*SCREEN_SCALE)];
	push.image = IMG(@"push");
	[_addressView addSubview:push];
	
	UIImageView *ico = [[UIImageView alloc]initWithFrame:CGRectMake(0, (_addressView.height-37*SCREEN_SCALE)/2, 37*SCREEN_SCALE, 37*SCREEN_SCALE)];
	ico.image = IMG(@"shopping-location");
	[_addressView addSubview:ico];
	
	_addressName = [[UILabel alloc]initWithFrame:CGRectMake(ico.right, 13*SCREEN_SCALE, _addressView.width-ico.right-push.width, 24*SCREEN_SCALE)];
	_addressName.text = FORMAT(@"收货人：%@　%@", _model.contactman, _model.mobile);
	_addressName.textColor = _textColor ? _textColor : COLOR333;
	_addressName.font = font11;
	_addressName.backgroundColor = [UIColor clearColor];
	[_addressView addSubview:_addressName];
	
	_addressValue = [[UILabel alloc]initWithFrame:_addressName.frameBottom];
	_addressValue.text = [AreaPickerView comboWithProvince:_model.province city:_model.city district:_model.district address:_model.address apart:@" "];
	_addressValue.textColor = _textColor ? _textColor : COLOR333;
	_addressValue.font = font11;
	_addressValue.backgroundColor = [UIColor clearColor];
	_addressValue.lineBreakMode = NSLineBreakByTruncatingMiddle;
	_addressValue.minimumScaleFactor = 0.8;
	_addressValue.adjustsFontSizeToFitWidth = YES;
	[_addressView addSubview:_addressValue];
	
    _contactman = _model.contactman;
    _mobile     = _model.mobile;
    _province   = _model.province;
    _city       = _model.city;
    _district   = _model.district;
    _address    = _model.address;
    _idcard     = _model.idcard;
	
	CGFloat top = view.bottom + 8*SCREEN_SCALE;
	for (ShoppingPostShopModel *shopModel in _model.shops) {
		view = [[UIView alloc]initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, 0)];
		view.backgroundColor = COLORWHITE;
		[_scrollView addSubview:view];
		
		CGFloat listTop = 0;
		if (shopModel.goods.isArray) {
			UIView *line = [[UIView alloc]initWithFrame:CGRectMakeScale(0, 0, SCREEN_WIDTH, @0.5)];
			line.backgroundColor = SHOPPING_SEPARATOR_COLOR;
			[view addSubview:line];
			listTop = line.bottom;
		}
		if (shopModel.ID>0) {
			UIView *listView = [[UIView alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, listTop, view.width-10*SCREEN_SCALE, 40*SCREEN_SCALE)];
			[view addSubview:listView];
			[listView addGeWithType:GeLineTypeBottom color:SHOPPING_SEPARATOR_COLOR];
			
			UIImageView *ico = [[UIImageView alloc]initWithFrame:CGRectMake(0, (40-20)/2*SCREEN_SCALE, 20*SCREEN_SCALE, 20*SCREEN_SCALE)];
			ico.image = IMG(@"shopping-shop-ico");
			ico.url = shopModel.imageUrl;
			[listView addSubview:ico];
			
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(ico.right+7*SCREEN_SCALE, 0, listView.width-(ico.right+7*SCREEN_SCALE)-26*SCREEN_SCALE, listView.height)];
			label.text = shopModel.name;
			label.textColor = COLOR333;
			label.font = font12;
			label.backgroundColor = [UIColor clearColor];
			[listView addSubview:label];
			
			listTop = listView.bottom;
		}
		
		for (ShoppingPostGoodsModel *goodsModel in shopModel.goods) {
			UIView *listView = [[UIView alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, listTop, view.width-10*SCREEN_SCALE, (10+53+10)*SCREEN_SCALE)];
			[view addSubview:listView];
			[listView addGeWithType:GeLineTypeBottom color:SHOPPING_SEPARATOR_COLOR];
			
			UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMakeScale(0, @10, @53, @53)];
			pic.image = IMG(@"%@%@", @"no", @"pic");
			pic.url = goodsModel.imageUrl;
			pic.layer.borderColor = SHOPPING_SEPARATOR_COLOR.CGColor;
			pic.layer.borderWidth = 0.5*SCREEN_SCALE;
			[listView addSubview:pic];
			
			UIILabel *name = [[UIILabel alloc]initWithFrame:CGRectMake(pic.right+10*SCREEN_SCALE, pic.top, listView.width-(pic.right+10*SCREEN_SCALE)-(60+10)*SCREEN_SCALE, 27*SCREEN_SCALE)];
			name.text = goodsModel.name;
			name.textColor = _textColor ? _textColor : COLOR333;
			name.font = _font ? _font : font11;
			name.backgroundColor = [UIColor clearColor];
			name.numberOfLines = 2;
			name.textAlignmentVertical = NSTextAlignmentTop;
			[listView addSubview:name];
			
			if (!_model.integral_order && goodsModel.spec.length) {
				UILabel *model = [[UILabel alloc]initWithFrame:name.frameBottom];
				model.height = 28*SCREEN_SCALE;
				model.text = FORMAT(@"规格: %@", goodsModel.spec);
				model.textColor = _specTextColor ? _specTextColor : COLOR999;
				model.font = _specFont ? _specFont : font11;
				model.backgroundColor = [UIColor clearColor];
				[listView addSubview:model];
			}
			
			UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(listView.width-(60+10)*SCREEN_SCALE, pic.top, 60*SCREEN_SCALE, 0)];
			if (!_model.integral_order) {
				price.text = FORMAT(@"￥%.2f", goodsModel.price.floatValue);
			} else {
				price.text = FORMAT(@"%@积分", goodsModel.integral);
			}
			price.textColor = SHOPPING_PRICE_COLOR;
			price.textAlignment = NSTextAlignmentRight;
			price.font = FONTPRICE(11);
			price.backgroundColor = [UIColor clearColor];
			[listView addSubview:price];
			price.priceFont = FONTPRICE(13);
			price.autoHeight = UIEdgeInsetsZero;
			
			if (!_model.integral_order) {
				UILabel *num = [[UILabel alloc]initWithFrame:price.frameBottom];
				num.text = FORMAT(@"× %ld", (long)goodsModel.quantity);
				num.textColor = COLOR999;
				num.textAlignment = NSTextAlignmentRight;
				num.font = font11;
				num.backgroundColor = [UIColor clearColor];
				[listView addSubview:num];
				num.height = 12*SCREEN_SCALE;
			}
			
			if (_selectCustom) {
				[listView clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
					[target ShoppingPost:target selectedWithModel:goodsModel];
				}];
			}
			
			if (!_model.integral_order) {
				_productPrice += goodsModel.price.floatValue * goodsModel.quantity;
			} else {
				_productPrice += goodsModel.integral.intValue * goodsModel.quantity;
			}
			
			listTop = listView.bottom;
		}
		
		view.height = listTop;
		[view addGeWithType:GeLineTypeBottom color:SHOPPING_SEPARATOR_COLOR];
		top = view.bottom + 8*SCREEN_SCALE;
	}
	
	NSArray *optionViews = [self ShoppingPostOptionViews:self data:_data];
	if (optionViews.isArray) {
		for (UIView *optionView in optionViews) {
			view = optionView;
			view.top = top;
			[_scrollView addSubview:view];
			top = view.bottom;
		}
		top += 8*SCREEN_SCALE;
	}
	
	if (!_model.integral_order) {
		view = [[UIView alloc]initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, 44*SCREEN_SCALE)];
		view.backgroundColor = COLORWHITE;
		[_scrollView addSubview:view];
		[view addGeWithType:GeLineTypeTopBottom color:SHOPPING_SEPARATOR_COLOR];
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 0, SCREEN_WIDTH-10*SCREEN_SCALE, view.height)];
		label.text = @"支付方式";
		label.textColor = COLOR333;
		label.font = fontbold12;
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		if (_payNames.isArray) {
			AJCheckbox *box = [[AJCheckbox alloc]init];
			box.delegate = self;
			box.orderType = CheckboxOrderTypeRight;
			box.image = _image ? _image : IMG(@"checkbox");
			box.selectedImage = _selectedImage ? _selectedImage : IMG(@"checkbox-x");
			box.size = _boxSize;
			box.textWidth = SCREEN_WIDTH - _boxSize.width;
			box.textHeight = 44*SCREEN_SCALE;
			box.hiddenLabel = YES;
			box.animateBox = NO;
			for (int i=0; i<_payNames.count; i++) {
				[box addObject:_payNames[i]];
			}
			for (int i=0; i<box.views.count; i++) {
				CGFloat bottom = view.bottom;
				view = box.views[i];
				view.top = bottom;
				view.clipsToBounds = YES;
				view.backgroundColor = COLORWHITE;
				[_scrollView addSubview:view];
				if (i==box.views.count-1) {
					[view addGeWithType:GeLineTypeBottom color:SHOPPING_SEPARATOR_COLOR];
				} else {
					[view addGeWithType:GeLineTypeBottom color:SHOPPING_SEPARATOR_COLOR margin:UIEdgeInsetsMakeScale(0, @10, 0, 0)];
				}
				
				ico = [[UIImageView alloc]initWithFrame:CGRectMake(0, (view.height-44*SCREEN_SCALE)/2, 44*SCREEN_SCALE, 44*SCREEN_SCALE)];
				ico.image = IMG(@"shopping-pay-%@", _payValues[i]);
				[view addSubview:ico];
				
				label = [[UILabel alloc]initWithFrame:CGRectMake(ico.right, 0, SCREEN_WIDTH-ico.right-_boxSize.width, view.height)];
				label.text = _payNames[i];
				label.textColor = COLOR333;
				label.font = font12;
				label.backgroundColor = [UIColor clearColor];
				[view addSubview:label];
			}
		} else {
			view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 44*SCREEN_SCALE)];
			view.backgroundColor = COLORWHITE;
			[_scrollView addSubview:view];
			[view addGeWithType:GeLineTypeBottom color:SHOPPING_SEPARATOR_COLOR];
			label = [[UILabel alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 0, SCREEN_WIDTH-10*SCREEN_SCALE, view.height)];
			label.text = @"当前没有任何支付方式";
			label.textColor = COLOR999;
			label.font = font12;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
		}
		
		top = view.bottom+8*SCREEN_SCALE;
	}
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, 44*SCREEN_SCALE)];
	view.backgroundColor = COLORWHITE;
	[_scrollView addSubview:view];
	[view addGeWithType:GeLineTypeTopBottom color:SHOPPING_SEPARATOR_COLOR];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 0, SCREEN_WIDTH-10*2*SCREEN_SCALE, view.height)];
	label.text = !_model.integral_order ? @"商品金额" : @"商品积分";
	label.textColor = COLOR333;
	label.font = fontbold12;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	label = [[UILabel alloc]initWithFrame:label.frame];
	//_productPrice = _model.goods_totalprice;
	if (!_model.integral_order) {
		label.text = FORMAT(@"￥%.2f", _productPrice);
	} else {
		label.text = FORMAT(@"%.f积分", _productPrice);
	}
	label.textColor = SHOPPING_PRICE_COLOR;
	label.textAlignment = NSTextAlignmentRight;
	label.font = FONTPRICE(12);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	label.priceFont = FONTPRICE(16);
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = COLORWHITE;
	[_scrollView addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:SHOPPING_SEPARATOR_COLOR];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"运费";
	label.textColor = COLOR333;
	label.font = fontbold12;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = _model.shippingfee==0 ? @"免邮" : FORMAT(@"￥%.2f", _model.shippingfee);
	label.textColor = _model.shippingfee==0 ? COLOR999 : SHOPPING_PRICE_COLOR;
	label.textAlignment = NSTextAlignmentRight;
	label.font = FONTPRICE(12);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	label.priceFont = FONTPRICE(16);
	
	_scrollView.contentSize = CGSizeMake(_scrollView.width, view.bottom+8*SCREEN_SCALE);
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			_bottomView.topAnimate = self.view.height - _bottomView.height;
		});
	});
	
	[self didLoadViews];
}

- (void)setBottomTextColor{
	if (self.bottomBg.barStyle == UIBarStyleBlackTranslucent) {
		_priceLabel.textColor = COLORWHITE;
		NSDictionary *style = @{@"body":@[FONTBOLD(12), COLORWHITE], @"p":COLORWHITE};
		_totalText.attributedText = [_totalText.element[@"text"] attributedStyle:style];
	} else {
		_priceLabel.textColor = SHOPPING_PRICE_COLOR;
		NSDictionary *style = @{@"body":@[FONTBOLD(12), COLOR333], @"p":SHOPPING_PRICE_COLOR};
		_totalText.attributedText = [_totalText.element[@"text"] attributedStyle:style];
	}
}

- (void)didLoadViews{
	/* Subclasses should override */
}

- (void)setBottomPrice:(CGFloat)bottomPrice{
	if (bottomPrice<0) bottomPrice = 0;
	_bottomPrice = bottomPrice;
	if (!_model.integral_order) {
		_priceLabel.text = FORMAT(@"%.2f", bottomPrice);
	} else {
		_priceLabel.text = FORMAT(@"%.f", bottomPrice);
	}
	_priceLabel.priceFont = FONTPRICE(18);
}

- (void)AJCheckbox:(AJCheckbox *)checkbox didSelectedView:(AJCheckboxSubview *)view status:(CheckboxStatus)status atIndex:(NSInteger)index{
	[self backgroundTap];
	_payMethod = _payValues[index];
}

- (void)ShoppingPost:(ShoppingPost *)shoppingPost selectedWithModel:(ShoppingPostGoodsModel *)model{
	/* Subclasses should override */
}

- (void)ShoppingPostToggleShowAddressView{
	if (_contactman.length) {
		_addressName.text = FORMAT(@"收货人：%@　%@", _contactman, _mobile);
		_addressValue.text = [AreaPickerView comboWithProvince:_province city:_city district:_district address:_address];
		_addressView.hidden = NO;
		_addressNull.hidden = YES;
	} else {
		_addressView.hidden = YES;
		_addressNull.hidden = NO;
	}
}

- (void)ShoppingPostNewAddress:(ShoppingPost *)shoppingPost{
	/* Subclasses should override */
}

- (void)ShoppingPostSelectAddress:(ShoppingPost *)shoppingPost{
	/* Subclasses should override */
}

- (NSArray*)ShoppingPostOptionViews:(ShoppingPost *)shoppingPost data:(NSDictionary*)data{
	/* Subclasses should override */
	return nil;
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)postData{
	[self backgroundTap];
	if (_model.integral_order) {
		if (_model.integral<=0) {
			[ProgressHUD showError:@"您的积分不足以支付"];
			return;
		}
		_payMethod = @"integral";
	} else {
		if (!_payMethod.length) {
			[ProgressHUD showError:@"请选择支付方式"];
			return;
		}
	}
	[self ShoppingPostCheckout:self payMethod:_payMethod];
}

- (void)ShoppingPostCheckout:(ShoppingPost *)shoppingPost payMethod:(NSString*)payMethod{
	/* Subclasses should override */
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) {
		self.view = nil;
	}
}

@end
