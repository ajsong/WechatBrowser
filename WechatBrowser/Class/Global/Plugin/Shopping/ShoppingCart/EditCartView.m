//
//  EditCartView.m
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "ShoppingConfig.h"
#import "EditCartView.h"

@interface EditCartView (){
	NSInteger _num;
	UIView *_topView;
	UIButton *_minusBtn;
	UIITextField *_numField;
	UIButton *_addBtn;
	UIView *_bottomView;
	UILabel *_styleLabel;
}
@end

@implementation EditCartView

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
		
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height/2)];
        _topView.backgroundColor = SHOPPING_GRAY_COLOR;
        [self addSubview:_topView];
        
        _minusBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _topView.height+5*SCREEN_SCALE, _topView.height)];
        [_minusBtn setTitle:@"-" forState:UIControlStateNormal];
        [_minusBtn setTitleColor:COLORRGB(@"575757") forState:UIControlStateNormal];
        _minusBtn.titleLabel.font = FONT(20);
        [_minusBtn addTarget:self action:@selector(MinusBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_minusBtn];
		
		_numField = [[UIITextField alloc]initWithFrame:CGRectMake(_topView.height+5*SCREEN_SCALE, (_topView.height-18*SCREEN_SCALE)/2, _topView.width-(_topView.height+5*SCREEN_SCALE)*2, 18*SCREEN_SCALE)];
		_numField.element[@"minInteger"] = @(_minInteger);
		_numField.element[@"maxInteger"] = @(_maxInteger);
		_numField.placeholder = @"数量";
		_numField.textColor = COLORRGB(@"575757");
		_numField.textAlignment = NSTextAlignmentCenter;
		_numField.font = FONTPRICE(14);
		_numField.backgroundColor = [UIColor clearColor];
		_numField.keyboardType = UIKeyboardTypeNumberPad;
		[_numField addTarget:self action:@selector(changeBegin:) forControlEvents:UIControlEventEditingDidBegin];
		[_numField addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventEditingChanged];
		[_numField addTarget:self action:@selector(blur:) forControlEvents:UIControlEventEditingDidEnd];
		[_topView addSubview:_numField];
		[_numField addGeWithType:GeLineTypeLeftRight color:SHOPPING_BUTTON_LINE_COLOR];
		
        _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(_numField.right, 0, _topView.height+5*SCREEN_SCALE, _topView.height)];
        [_addBtn setTitle:@"+" forState:UIControlStateNormal];
        [_addBtn setTitleColor:COLORRGB(@"575757") forState:UIControlStateNormal];
        _addBtn.titleLabel.font = FONT(20);
        [_addBtn addTarget:self action:@selector(AddBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_addBtn];
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height/2, frame.size.width, frame.size.height/2)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        [_bottomView addGeWithType:GeLineTypeTop color:SHOPPING_BUTTON_LINE_COLOR];
        [self addSubview:_bottomView];
        [_bottomView clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
			[target clickBottom];
		}];
        
        _styleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*SCREEN_SCALE, 0, _bottomView.width-15*2*SCREEN_SCALE, frame.size.height/2)];
        _styleLabel.textColor = COLOR666;
        _styleLabel.font = FONT(12);
        [_bottomView addSubview:_styleLabel];
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
    [_delegate EditCartView:_num btnType:ShoppingCartBtnMinus];
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
    [_delegate EditCartView:_num btnType:ShoppingCartBtnPlus];
}

- (void)clickBottom{
    [_delegate EditCartViewSpec];
}

- (void)setStyleString:(NSString *)styleString{
	_styleLabel.text = styleString;
}

- (void)setNumInteger:(NSInteger)numInteger{
    _numInteger = numInteger;
    _numField.text = [NSString stringWithFormat:@"%ld", (long)_numInteger];
    _num = _numInteger;
}

- (void)setMinInteger:(NSInteger)minInteger{
	_minInteger = minInteger;
	_numField.element[@"minInteger"] = @(_minInteger);
    if (_minInteger == 0) {
        //[_delegate EditCartView:_minInteger btnType:ShoppingCartBtnMinus];
        _numField.text = @"0";
        _num = 0;
    } else if (_minInteger<=_numField.text.integerValue) {
        //[_delegate EditCartView:_minInteger btnType:ShoppingCartBtnMinus];
        _numField.text = [NSString stringWithFormat:@"%ld", (long)_minInteger];
        _num = _minInteger;
    }
}

- (void)setMaxInteger:(NSInteger)maxInteger{
	_maxInteger = maxInteger;
	_numField.element[@"maxInteger"] = @(_maxInteger);
}

@end
