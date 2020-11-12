//
//  AddNumView.m
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "ShoppingConfig.h"
#import "AddNumView.h"

@interface AddNumView (){
	UIButton *_minusBtn;
	UIButton *_addBtn;
	UITextField *_numField;
	NSInteger _num;
}
@end

@implementation AddNumView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
	if (self) {
		self.clipsToBounds = YES;
        self.layer.borderColor = SHOPPING_BUTTON_LINE_COLOR.CGColor;
		self.layer.borderWidth = 0.5;
		self.layer.masksToBounds = YES;
		self.layer.cornerRadius = 2*SCREEN_SCALE;
		
		_num = 1;
		_minInteger = -1;
		
		_minusBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 22*SCREEN_SCALE, frame.size.height)];
		_minusBtn.backgroundColor = SHOPPING_GRAY_COLOR;
		_minusBtn.titleLabel.font = FONT(16);
        [_minusBtn setTitle:@"-" forState:UIControlStateNormal];
        [_minusBtn setTitleColor:COLORRGB(@"575757") forState:UIControlStateNormal];
        [_minusBtn addTarget:self action:@selector(MinusBtn:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_minusBtn];
		
		_numField = [[UITextField alloc]initWithFrame:CGRectMake(_minusBtn.right, 0, 30*SCREEN_SCALE, frame.size.height)];
		_numField.element[@"minInteger"] = @(_minInteger);
		_numField.element[@"maxInteger"] = @(_maxInteger);
		_numField.placeholder = @"数量";
		_numField.textColor = COLOR666;
		_numField.textAlignment = NSTextAlignmentCenter;
		_numField.font = FONTPRICE(12);
		_numField.backgroundColor = [UIColor clearColor];
		_numField.keyboardType = UIKeyboardTypeNumberPad;
		[_numField addTarget:self action:@selector(changeBegin:) forControlEvents:UIControlEventEditingDidBegin];
		[_numField addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventEditingChanged];
		[_numField addTarget:self action:@selector(blur:) forControlEvents:UIControlEventEditingDidEnd];
		[self addSubview:_numField];
		[_numField addGeWithType:GeLineTypeLeftRight color:SHOPPING_BUTTON_LINE_COLOR];
		
		_addBtn = [[UIButton alloc]initWithFrame:CGRectMake(_numField.right, 0, 22*SCREEN_SCALE, frame.size.height)];
		_addBtn.backgroundColor = SHOPPING_GRAY_COLOR;
		_addBtn.titleLabel.font = FONT(16);
        [_addBtn setTitle:@"+" forState:UIControlStateNormal];
        [_addBtn setTitleColor:COLORRGB(@"575757") forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(AddBtn:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_addBtn];
    }
    return self;
}

- (void)changeBegin:(UITextField*)textField{
	[_delegate changeBegin:textField];
}

- (void)changeValue:(UITextField*)textField{
	[_delegate changeValue:textField];
}

- (void)blur:(UITextField*)textField{
	[_delegate blur:textField];
}

- (void)MinusBtn:(UIButton *)sender{
    if (_minInteger>-1 && _num<=_minInteger) {
		[ProgressHUD showWarning:[NSString stringWithFormat:@"该商品至少要购买%ld件", (long)_minInteger]];
		return;
    }
    _num  = _num - 1;
    _numField.text = [NSString stringWithFormat:@"%ld", (long)_num];
    [_delegate AddNumView:_num btnType:ShoppingCartBtnMinus];
}

- (void)AddBtn:(UIButton *)sender{
	if (_maxInteger && _num>=_maxInteger) {
		[ProgressHUD showWarning:[NSString stringWithFormat:@"该商品最多只能购买%ld件", (long)_maxInteger]];
		return;
	}
	if (_stocks && _num>=_stocks) {
		[ProgressHUD showWarning:[NSString stringWithFormat:@"该商品的库存只剩下%ld件", (long)_stocks]];
		return;
	}
    _num = _num + 1;
    _numField.text = [NSString stringWithFormat:@"%ld", (long)_num];
    [_delegate AddNumView:_num btnType:ShoppingCartBtnPlus];
}

- (void)setNumInteger:(NSInteger)numInteger{
	_numInteger = numInteger;
	_numField.text = [NSString stringWithFormat:@"%ld", (long)_numInteger];
	_num = _numInteger;
}

- (void)setMinInteger:(NSInteger)minInteger{
	_minInteger = minInteger;
	_numField.element[@"minInteger"] = @(_minInteger);
	if (_minInteger==0) {
		//[_delegate AddNumView:_minInteger btnType:ShoppingCartBtnMinus];
		_numField.text = @"0";
		_num = 0;
	} else if (_minInteger<=_numField.text.integerValue) {
		//[_delegate AddNumView:_minInteger btnType:ShoppingCartBtnMinus];
		_numField.text = [NSString stringWithFormat:@"%ld", (long)_minInteger];
		_num = _minInteger;
	}
}

- (void)setMaxInteger:(NSInteger)maxInteger{
	_maxInteger = maxInteger;
	_numField.element[@"maxInteger"] = @(_maxInteger);
}

@end
