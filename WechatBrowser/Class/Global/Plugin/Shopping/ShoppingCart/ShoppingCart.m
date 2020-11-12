//
//  ShoppingCart.m
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "ShoppingCart.h"

@interface ShoppingCart (){
	BOOL _isBool;
	BOOL _editBool;
	NSString *_numString;
	NSArray *_cellArray;
	
	UIView *_totalView;
	UILabel *_priceLabel;
	UILabel *_totalUnit;
	UILabel *_totalText;
}
@end

@implementation ShoppingCart

- (instancetype)init{
	self = [super init];
	if (self) {
        _isGrouped                    = YES;
        _discountTip                  = @"优惠购";
        _discountText                 = @"折扣商品";
        _discountBackgroundColor      = COLORRGB(@"ef226d");
        _separatorHeight              = 10.f*SCREEN_SCALE;
        _bottomViewHeight             = 42.f*SCREEN_SCALE;
        _boxSize                      = CGSizeMakeScale(@44, @44);

        _shopping_cart_discount       = SHOPPING_CART_DISCOUNT;
        _shopping_cart_shop_id        = SHOPPING_CART_SHOP_ID;
        _shopping_cart_shop_name      = SHOPPING_CART_SHOP_NAME;
        _shopping_cart_shop_avatar    = SHOPPING_CART_SHOP_AVATAR;
        _shopping_cart_goods_list     = SHOPPING_CART_GOODS_LIST;
        _shopping_cart_id             = SHOPPING_CART_ID;
        _shopping_cart_goods_id       = SHOPPING_CART_GOODS_ID;
        _shopping_cart_goods_name     = SHOPPING_CART_GOODS_NAME;
        _shopping_cart_goods_pic      = SHOPPING_CART_GOODS_PIC;
        _shopping_cart_goods_spec     = SHOPPING_CART_GOODS_SPEC;
        _shopping_cart_goods_specs    = SHOPPING_CART_GOODS_SPECS;
        _shopping_cart_goods_price    = SHOPPING_CART_GOODS_PRICE;
        _shopping_cart_goods_quantity = SHOPPING_CART_GOODS_QUANTITY;
        _shopping_cart_goods_stocks   = SHOPPING_CART_GOODS_STOCKS;
        _shopping_cart_goods_required = SHOPPING_CART_GOODS_REQUIRED;
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
	self.title = @"购物车";
	self.view.backgroundColor = COLORBACK;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	_editBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
	_editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
	_editBtn.backgroundColor = [UIColor clearColor];
	[_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
	[_editBtn setTitleColor:COLORNAVTEXT forState:UIControlStateNormal];
	[_editBtn addTarget:self action:@selector(editBtn:) forControlEvents:UIControlEventTouchUpInside];
	_editBtn.hidden = YES;
	[self.navigationItem setItemWithCustomView:_editBtn itemType:KKNavigationItemTypeRight];
	
	_numString = @"0";
	
	UITableViewStyle tableViewStyle = UITableViewStylePlain;
	if (_isGrouped) tableViewStyle = UITableViewStyleGrouped;
	_tableView = [[ShoppingTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height) style:tableViewStyle];
	if (@available(iOS 11.0, *)) _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
	_tableView.scrollEnabled = NO;
	_tableView.emptyView = _emptyView;
	_tableView.hiddenEdit = _hiddenEdit;
	_tableView.hiddenSubtotal = _hiddenSubtotal;
	_tableView.boxSize = _boxSize;
	_tableView.image = _image;
	_tableView.selectedImage = _selectedImage;
	_tableView.discountTip = _discountTip;
	_tableView.discountText = _discountText;
	_tableView.discountBackgroundColor = _discountBackgroundColor;
	_tableView.btnColor = _btnColor;
	_tableView.textColor = _textColor;
	_tableView.font = _font;
	_tableView.specTextColor = _specTextColor;
	_tableView.specFont = _specFont;
	_tableView.separatorHeight = _separatorHeight;
	_tableView.shoppingCartDelegate = self;
	[self.view addSubview:_tableView];
	
	_bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height, SCREEN_WIDTH, _bottomViewHeight)];
	[self.view addSubview:_bottomView];
	
	_bottomBg = [[UIToolbar alloc]initWithFrame:_bottomView.bounds];
	[_bottomView addSubview:_bottomBg];
	
	_checkoutBtn = [[UIButton alloc]initWithFrame:CGRectMake(_bottomView.width-100*SCREEN_SCALE, 0, 100*SCREEN_SCALE, _bottomView.height)];
	_checkoutBtn.titleLabel.font = FONTBOLD(12);
	_checkoutBtn.backgroundColor = _btnColor ? _btnColor : SHOPPING_BUTTON_COLOR;
	[_checkoutBtn setTitle:@"去结算(0)" forState:UIControlStateNormal];
	[_checkoutBtn setTitleColor:COLORWHITE forState:UIControlStateNormal];
	[_checkoutBtn addTarget:self action:@selector(SettlementBtn:) forControlEvents:UIControlEventTouchUpInside];
	[_bottomView addSubview:_checkoutBtn];
	
	_totalView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _checkoutBtn.left-10*SCREEN_SCALE, _bottomView.height)];
	_totalView.clipsToBounds = YES;
	[_bottomView addSubview:_totalView];
	
	_priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -1*SCREEN_SCALE, 0, _totalView.height)];
	_priceLabel.text = @"0.00";
	_priceLabel.textColor = SHOPPING_PRICE_COLOR;
	_priceLabel.font = FONTPRICE(14);
	_priceLabel.backgroundColor = [UIColor clearColor];
	[_totalView addSubview:_priceLabel];
	_priceLabel.priceFont = FONTPRICE(18);
	_priceLabel.autoWidth = UIEdgeInsetsZero;
	_priceLabel.left = _totalView.width - _priceLabel.width;
	
	NSString *string = @"总计: <p>￥</p>";
	NSDictionary *style = @{@"body":@[FONTBOLD(12), COLOR333], @"p":SHOPPING_PRICE_COLOR};
	_totalText = [[UILabel alloc]initWithFrame:CGRectMake(_priceLabel.left-44*SCREEN_SCALE, 0, 44*SCREEN_SCALE, _totalView.height)];
	_totalText.attributedText = [string attributedStyle:style];
	_totalText.backgroundColor = [UIColor clearColor];
	_totalText.element[@"text"] = string;
	[_totalView addSubview:_totalText];
	
	_allBtn = [[ShoppingCheckbox alloc]initWithFrame:CGRectMake(0, (_bottomView.height-_boxSize.height)/2, _boxSize.width+26*SCREEN_SCALE, _boxSize.height)];
	_allBtn.titleLabel.font = FONTBOLD(12);
	_allBtn.backgroundColor = [UIColor clearColor];
	[_allBtn setImage:_image?_image:IMG(@"checkbox") forState:UIControlStateNormal];
	[_allBtn setImage:_selectedImage?_selectedImage:IMG(@"checkbox-x") forState:UIControlStateSelected];
	[_allBtn setTitle:@"全选" forState:UIControlStateNormal];
	[_allBtn setTitleColor:COLOR333 forState:UIControlStateNormal];
	[_allBtn addTarget:self action:^(id target, id sender) {
		[(ShoppingCart*)target allBtn:sender];
	}];
	[_bottomView addSubview:_allBtn];
	
	_bottomView.matchX = UIViewMatchXBottom;
	_bottomView.top = self.height;
	_bottomBg.frame = _bottomView.bounds;
	_bottomViewHeight = _bottomView.height;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShoppingAllPrice:) name:ShoppingCartAllPrice object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShoppingData:) name:ShoppingCartData object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShoppingNonData:) name:ShoppingCartNonData object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShoppingChange:) name:ShoppingCartChange object:nil];
	
	[self performSelector:@selector(setBottomTextColor) withObject:nil afterDelay:0];
}

- (void)setBottomTextColor{
	if (self.bottomBg.barStyle == UIBarStyleBlackTranslucent) {
		_priceLabel.textColor = COLORWHITE;
		NSDictionary *style = @{@"body":@[FONTBOLD(12), COLORWHITE], @"p":COLORWHITE};
		_totalText.attributedText = [_totalText.element[@"text"] attributedStyle:style];
		[_allBtn setTitleColor:COLORWHITE forState:UIControlStateNormal];
	} else {
		_priceLabel.textColor = SHOPPING_PRICE_COLOR;
		NSDictionary *style = @{@"body":@[FONTBOLD(12), COLOR333], @"p":SHOPPING_PRICE_COLOR};
		_totalText.attributedText = [_totalText.element[@"text"] attributedStyle:style];
		[_allBtn setTitleColor:COLOR333 forState:UIControlStateNormal];
	}
}

#pragma mark - 设置总价
- (void)ShoppingAllPrice:(NSNotification *)notification{
	[self setAllPriceLabel:FORMAT(@"%.2f", [notification.userInfo[@"allPrice"] floatValue])];
	_numString = notification.userInfo[@"num"];
	[self setCheckoutText];
	[self setAllBtnState:![notification.userInfo[@"allState"] isEqual:@"YES"]];
	_cellArray = notification.userInfo[@"cellModel"];
}

- (void)setAllPriceLabel:(NSString*)allPrice{
	_priceLabel.text = allPrice;
	_priceLabel.priceFont = FONTPRICE(18);
	_priceLabel.autoWidth = UIEdgeInsetsZero;
	[UIView animateWithDuration:0.25 animations:^{
		_priceLabel.left = _totalView.width - _priceLabel.width;
		for (UILabel *nextLabel in _priceLabel.nextViews) {
			nextLabel.left = nextLabel.prevView.left - nextLabel.width;
		}
	}];
}

#pragma mark - 设置结算按钮状态
- (void)setCheckoutText{
	NSString *string = _editBool ? @"删除" : @"去结算";
	[_checkoutBtn setTitle:[NSString stringWithFormat:@"%@(%@)", string, _numString] forState:UIControlStateNormal];
}

#pragma mark - 设置数据
- (void)ShoppingData:(NSNotification *)notification{
	NSArray *data = notification.userInfo[@"data"];
	[self setData:data];
}
- (void)ShoppingNonData:(NSNotification *)notification{
	[self ShoppingCartWithNonData:self];
	[self setData:nil];
}
- (void)setData:(NSArray *)data{
	_data = [data UpyunSuffix:@"!small"];
	NSMutableArray *datas = [[NSMutableArray alloc] init];
	if (_data.isArray) {
		for (NSDictionary *d in _data) {
            ShoppingModel *model               = [[ShoppingModel alloc]init];
            model.discountText                 = _discountText;
            model.shopping_cart_discount       = _shopping_cart_discount;
            model.shopping_cart_shop_id        = _shopping_cart_shop_id;
            model.shopping_cart_shop_name      = _shopping_cart_shop_name;
            model.shopping_cart_shop_avatar    = _shopping_cart_shop_avatar;
            model.shopping_cart_goods_list     = _shopping_cart_goods_list;
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
			model.data = d;
			[datas addObject:model];
		}
	}
	if (datas.isArray) {
		_tableView.contentInset = UIEdgeInsetsMake(0, 0, _bottomView.height+_contentInsetBottom, 0);
		_tableView.scrollEnabled = YES;
		if (!_hiddenEdit) _editBtn.hidden = NO;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				_bottomView.topAnimate = self.view.height - _bottomView.height - _contentInsetBottom;
			});
		});
	} else {
		_tableView.contentInset = UIEdgeInsetsZero;
		_tableView.scrollEnabled = NO;
		if (!_hiddenEdit) _editBtn.hidden = YES;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				_bottomView.topAnimate = self.view.height;
			});
		});
	}
	_tableView.shoppingArray = datas;
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

- (void)setContentInsetBottom:(CGFloat)contentInsetBottom{
	_contentInsetBottom = contentInsetBottom;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (_tableView.shoppingArray.isArray) {
				_tableView.contentInset = UIEdgeInsetsMake(0, 0, _bottomView.height+_contentInsetBottom, 0);
				_bottomView.topAnimate = self.view.height - _bottomView.height - _contentInsetBottom;
			}
		});
	});
}

#pragma mark -  编辑
- (void)editBtn:(UIButton *)sender{
	if (_editBool) {
		[_tableView editBtn:_editBool];
		_editBool = NO;
	} else {
		[_tableView editBtn:_editBool];
		_editBool = YES;
	}
	[_editBtn setTitle:_editBool?@"完成":@"编辑" forState:UIControlStateNormal];
	[self setCheckoutText];
	_totalView.hidden = _editBool;
}

- (void)allBtn:(UIButton *)sender{
	[_tableView allBtn:!_isBool];
	_allBtn.selected = _isBool;
}

#pragma mark - 全选
- (void)setAllBtnState:(BOOL)boolState{
	if (boolState) {
		_isBool = NO;
		_allBtn.selected = NO;
	} else {
		_isBool = YES;
		_allBtn.selected = YES;
	}
}

#pragma mark - 修改数量与规格
- (void)ShoppingChange:(NSNotification *)notification{
	ShoppingCellModel *model = notification.userInfo[@"model"];
	NSInteger btnType = [notification.userInfo[@"btnType"] integerValue];
	BOOL isTextField = [notification.userInfo[@"isTextField"] boolValue];
	BOOL isSpec = [notification.userInfo[@"isSpec"] boolValue];
	[self ShoppingCart:self changeWithModel:model btnType:btnType isTextField:isTextField isSpec:isSpec];
}
- (void)ShoppingCart:(ShoppingCart *)shoppingCart changeWithModel:(ShoppingCellModel *)model btnType:(ShoppingCartBtnType)btnType isTextField:(BOOL)isTextField isSpec:(BOOL)isSpec{
	/* Subclasses should override */
}

#pragma mark - 结算/批量删除
- (void)SettlementBtn:(UIButton *)sender{
	BOOL isSubmit = NO;
	if (!_editBool) isSubmit = YES;
	NSMutableArray *datas = [[NSMutableArray alloc]init];
	for (int i=0; i<_cellArray.count; i++) {
		[datas addObject:_cellArray[i]];
	}
	[self ShoppingCart:self checkoutWithModels:datas isSubmit:isSubmit];
	if (_editBool) {
		[_tableView deleteBtn:_editBool];
	}
}

- (void)ShoppingCart:(ShoppingCart*)shoppingCart checkoutWithModels:(NSArray *)models isSubmit:(BOOL)isSubmit{
	/* Subclasses should override */
}

- (void)ShoppingCartWithNonData:(ShoppingCart *)shoppingCart{
	/* Subclasses should override */
}

- (void)deallocd{
	_data = nil;
	_tableView.shoppingCartDelegate = nil;
	_tableView.delegate = nil;
	_tableView.dataSource = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) {
		[self deallocd];
		self.view = nil;
	}
}

@end
