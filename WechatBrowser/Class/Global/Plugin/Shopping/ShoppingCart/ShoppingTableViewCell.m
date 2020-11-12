//
//  ShoppingTableViewCell.m
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "ShoppingCart.h"
#import "AddNumView.h"
#import "EditCartView.h"

#define IMAGEVIEW_WIDTH 70*SCREEN_SCALE

@implementation ShoppingCheckbox
- (instancetype)init{
	self = [super init];
	if (self) {
		self.adjustsImageWhenHighlighted = NO;
		self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	}
	return self;
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect{
	return CGRectMake(0.0, 0.0, self.size.height, self.size.height);
}
@end

@interface ShoppingTableViewCell ()<AddNumViewDelegate,EditCartViewDelegate>{
	UIView *_cartIntoView;
	UIButton *_okBtn; //确定
	UIImageView *_imageView; //图片
	UILabel *_mustLabel; //必选单品
	UIILabel *_titleLabel; //标题
	UILabel *_priceLabel; //价格
	UILabel *_numLabel; //数量
	UILabel *_styleLabel; //规格
	AddNumView *_addNumView;
	EditCartView *_editCartView;
	BOOL _isBool;
	NSString *_originValue;
}
@end

@implementation ShoppingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.backgroundColor = COLORWHITE;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		_boxSize = CGSizeMakeScale(@44, @44);
		
		UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IMAGEVIEW_WIDTH+15*SCREEN_SCALE*2)];
		[self.contentView addSubview:view];
		
		//勾选按钮
		_okBtn = [[ShoppingCheckbox alloc] initWithFrame:CGRectMake(0, ((IMAGEVIEW_WIDTH+15*SCREEN_SCALE*2)-_boxSize.height)/2, _boxSize.width, _boxSize.height)];
		_okBtn.backgroundColor = [UIColor clearColor];
		[_okBtn setImage:IMG(@"checkbox") forState:UIControlStateNormal];
		[_okBtn setImage:IMG(@"checkbox-x") forState:UIControlStateSelected];
		[_okBtn addTarget:self action:^(id target, id sender) {
			[target OKBtn:sender];
		}];
		[view addSubview:_okBtn];
		
		//图片
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_okBtn.right, 15*SCREEN_SCALE, IMAGEVIEW_WIDTH, IMAGEVIEW_WIDTH)];
		_imageView.image = IMG(@"%@%@", @"no", @"pic");
		_imageView.backgroundColor = [UIColor whiteColor];
		_imageView.layer.borderColor = SHOPPING_SEPARATOR_COLOR.CGColor;
		_imageView.layer.borderWidth = 0.5*SCREEN_SCALE;
		[view addSubview:_imageView];
		
		_mustLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView.left, _imageView.bottom-15*SCREEN_SCALE, _imageView.width, 15*SCREEN_SCALE)];
		_mustLabel.textColor = [UIColor whiteColor];
		_mustLabel.textAlignment = NSTextAlignmentCenter;
		_mustLabel.font = FONT(9);
		_mustLabel.backgroundColor = COLORRGBA(@"ef226d", 0.6);
		_mustLabel.hidden = YES;
		[view addSubview:_mustLabel];
		
		_cartIntoView = [[UIView alloc] initWithFrame:CGRectMake(_imageView.right+10*SCREEN_SCALE, _imageView.top, view.width-(_imageView.right+10*SCREEN_SCALE)-10*SCREEN_SCALE, _imageView.height)];
		[view addSubview:_cartIntoView];
		
		//名称
		_titleLabel = [[UIILabel alloc] initWithFrame:CGRectMake(0, 0, _cartIntoView.width-57*SCREEN_SCALE, 30*SCREEN_SCALE)];
		_titleLabel.textColor = COLOR333;
		_titleLabel.font = FONT(12);
		_titleLabel.numberOfLines = 2;
		_titleLabel.textAlignmentVertical = NSTextAlignmentTop;
		[_cartIntoView addSubview:_titleLabel];
		
		//价格
		_priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.right, 1*SCREEN_SCALE, 57*SCREEN_SCALE, 12*SCREEN_SCALE)];
		_priceLabel.textColor = SHOPPING_PRICE_COLOR;
		_priceLabel.textAlignment = NSTextAlignmentRight;
		_priceLabel.font = FONTPRICE(11);
		[_cartIntoView addSubview:_priceLabel];
		
		//数量
		_numLabel = [[UILabel alloc] initWithFrame:[_priceLabel frameBottom:1*SCREEN_SCALE]];
		_numLabel.textColor = COLOR999;
		_numLabel.textAlignment = NSTextAlignmentRight;
		_numLabel.font = FONT(11);
		[_cartIntoView addSubview:_numLabel];
		
		//规格
		_styleLabel = [[UILabel alloc] initWithFrame:_titleLabel.frameBottom];
		_styleLabel.textColor = COLOR999;
		_styleLabel.font = FONT(11);
		_styleLabel.hidden = YES;
		[_cartIntoView addSubview:_styleLabel];
		_styleLabel.height = 18*SCREEN_SCALE;
		
		_addNumView = [[AddNumView alloc] initWithFrame:CGRectMake(0, _styleLabel.bottom, (22+30+22)*SCREEN_SCALE, 22*SCREEN_SCALE)];
		_addNumView.minInteger = 1;
		_addNumView.delegate = self;
		[_cartIntoView addSubview:_addNumView];
		
		_editCartView = [[EditCartView alloc] initWithFrame:_cartIntoView.frame];
		_editCartView.minInteger = 1;
		_editCartView.delegate = self;
		_editCartView.hidden = YES;
		[view addSubview:_editCartView];
		
		[view clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
			if (_shoppingCartDelegate && [_shoppingCartDelegate respondsToSelector:@selector(ShoppingCart:selectedWithModel:)]) {
				[_shoppingCartDelegate ShoppingCart:(ShoppingCart*)_shoppingCartDelegate selectedWithModel:_model];
			} else {
				[target OKBtn:_okBtn];
			}
		}];
	}
	return self;
}

- (void)setBoxSize:(CGSize)boxSize{
	CGSize size = _boxSize;
	_boxSize = boxSize;
	if (size.height!=boxSize.height) {
		_okBtn.frame = CGRectMake(0, ((IMAGEVIEW_WIDTH+15*SCREEN_SCALE*2)-boxSize.height)/2, boxSize.width, boxSize.height);
	}
	if (size.width==boxSize.width) return;
	_imageView.left = _okBtn.right;
	_mustLabel.left = _imageView.left;
	_cartIntoView.left = _imageView.right+10*SCREEN_SCALE;
	_cartIntoView.width = _cartIntoView.superview.width-(_imageView.right+10*SCREEN_SCALE)-10*SCREEN_SCALE;
	_titleLabel.width = _cartIntoView.width-_priceLabel.width;
	_priceLabel.left = _titleLabel.right;
	_numLabel.frame = [_priceLabel frameBottom:1*SCREEN_SCALE];
	CGFloat styleLabelHeight = _styleLabel.height;
	_styleLabel.frame = _titleLabel.frameBottom;
	_styleLabel.height = styleLabelHeight;
	_addNumView.top = _styleLabel.bottom;
	_editCartView.frame = _cartIntoView.frame;
}

- (void)setImage:(UIImage *)image{
	if (!image) return;
	[_okBtn setImage:image forState:UIControlStateNormal];
}

- (void)setSelectedImage:(UIImage *)selectedImage{
	if (!selectedImage) return;
	[_okBtn setImage:selectedImage forState:UIControlStateSelected];
}

- (void)setDiscountText:(NSString *)discountText{
	if (!discountText) return;
	_mustLabel.text = discountText;
}

- (void)setDiscountBackgroundColor:(UIColor *)discountBackgroundColor{
	if (!discountBackgroundColor) return;
	_mustLabel.backgroundColor = [discountBackgroundColor setAlpha:0.6];
}

- (void)setTextColor:(UIColor *)textColor{
	if (!textColor) return;
	_titleLabel.textColor = textColor;
}

- (void)setFont:(UIFont *)font{
	if (!font) return;
	_titleLabel.font = font;
}

- (void)setSpecTextColor:(UIColor *)specTextColor{
	if (!specTextColor) return;
	_styleLabel.textColor = specTextColor;
}

- (void)setSpecFont:(UIFont *)specFont{
	if (!specFont) return;
	_styleLabel.font = specFont;
}

- (void)setModel:(ShoppingCellModel *)model{
	_model = model;
	_imageView.url = model.imageUrl;
	_titleLabel.text = model.name;
	_priceLabel.text = [NSString stringWithFormat:@"￥%.2f", model.price.floatValue];
	_priceLabel.priceFont = FONTPRICE(13);
	_numLabel.text = [NSString stringWithFormat:@"× %ld", (long)model.quantity];
	_styleLabel.text = [NSString stringWithFormat:@"规格: %@", model.spec];
	_styleLabel.hidden = !model.spec.length;
	_mustLabel.hidden = model.required==0;
	_addNumView.numInteger = model.quantity;
	_addNumView.stocks = model.stocks;
	_editCartView.numInteger = model.quantity;
	_editCartView.stocks = model.stocks;
	_editCartView.styleString = model.spec;
	
	if (model.clickState==1) {
		_isBool = YES;
	} else {
		_isBool = NO;
	}
	_okBtn.selected = _isBool;
	
	if (model.spec.length) {
		_editCartView.frame = _cartIntoView.frame;
	} else {
		_editCartView.height = _cartIntoView.height / 2;
		_editCartView.top = _cartIntoView.top + _editCartView.height / 2;
	}
	
	if (model.editState==1) {
		_cartIntoView.hidden = YES;
		_editCartView.hidden = NO;
	} else {
		_cartIntoView.hidden = NO;
		_editCartView.hidden = YES;
	}
}

- (void)AddNumView:(NSInteger)quantity btnType:(NSInteger)btnType{
	_model.quantity = quantity;
	[self postNotificationWithBtnType:btnType isTextField:NO isSpec:NO];
	[_delegate ShoppingTableViewCell:_model];
}

- (void)EditCartView:(NSInteger)quantity btnType:(NSInteger)btnType{
	_model.quantity = quantity;
	[self postNotificationWithBtnType:btnType isTextField:NO isSpec:NO];
	[_delegate ShoppingTableViewCell:_model];
}

- (void)EditCartViewSpec{
	if (_model.specs.count) {
		[UIAlertController action:@"选择规格" buttons:_model.specs block:^(NSInteger buttonIndex) {
			if (buttonIndex >= _model.specs.count) return;
			NSString *spec = _model.specs[buttonIndex];
			_model.spec = spec;
			_styleLabel.text = spec;
			_editCartView.styleString = spec;
			[self postNotificationWithBtnType:ShoppingCartBtnNone isTextField:NO isSpec:YES];
		}];
	}
}

- (void)postNotificationWithBtnType:(NSInteger)btnType isTextField:(BOOL)isTextField isSpec:(BOOL)isSpec{
	NSDictionary *userInfo = @{@"model":_model, @"btnType":@(btnType), @"isTextField":@(isTextField), @"isSpec":@(isSpec)};
	NSNotification *notification = [NSNotification notificationWithName:ShoppingCartChange object:nil userInfo:userInfo];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)changeBegin:(UITextField*)textField{
	_originValue = textField.text;
}

- (void)changeValue:(UITextField*)textField{
	if (!textField.text.length) return;
	NSInteger c = textField.text.integerValue;
	NSInteger minInteger = [textField.element[@"minInteger"] integerValue];
	NSInteger maxInteger = [textField.element[@"maxInteger"] integerValue];
	if (minInteger>-1 && c<minInteger) {
		[ProgressHUD showWarning:[NSString stringWithFormat:@"该商品至少要购买%ld件", (long)minInteger]];
		textField.text = _originValue;
		return;
	}
	if (maxInteger && c>maxInteger) {
		[ProgressHUD showWarning:[NSString stringWithFormat:@"该商品最多只能购买%ld件", (long)maxInteger]];
		textField.text = _originValue;
		return;
	}
	if (_model.stocks && c>_model.stocks) {
		[ProgressHUD showWarning:[NSString stringWithFormat:@"该商品的库存只剩下%ld件", (long)_model.stocks]];
		textField.text = _originValue;
		return;
	}
	_originValue = textField.text;
	_model.quantity = c;
	[self postNotificationWithBtnType:ShoppingCartBtnNone isTextField:YES isSpec:NO];
	[_delegate ShoppingTableViewCell:_model];
}

- (void)blur:(UITextField*)textField{
	if (!textField.text.length) {
		[ProgressHUD showError:@"请输入数量"];
		[textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
	}
}

- (void)OKBtn:(UIView *)sender{
	if (_isBool) {
		_model.clickState = 0;
		_isBool = NO;
	} else {
		_model.clickState = 1;
		_isBool = YES;
	}
	[_delegate ShoppingTableViewCell:_model];
	_okBtn.selected = _isBool;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
