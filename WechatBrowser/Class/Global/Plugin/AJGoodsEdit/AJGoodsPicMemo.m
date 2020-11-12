//
//  AJGoodsPicMemo.m
//
//  Created by ajsong on 2017/3/15.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AJGoodsConfig.h"
#import "AJGoodsPicMemo.h"

@interface AJGoodsPicMemo (){
	UIITextView *_content;
}
@end

@implementation AJGoodsPicMemo

- (instancetype)init{
	self = [super init];
	if (self) {
		_textColor = GOODS_EDIT_TEXT_COLOR;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"图片描述";
	self.view.backgroundColor = COLORBACK;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"确定" textColor:COLORNAVTEXT fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
	
	UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
	[self.view addSubview:scrollView];
	
	_content = [[UIITextView alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 10*SCREEN_SCALE, SCREEN_WIDTH-10*SCREEN_SCALE*2, scrollView.height-10*SCREEN_SCALE*2)];
	if (_data.isDictionary) _content.text = _data[GOODS_EDIT_PIC_MEMO];
	_content.placeholder = @"请输入图片的描述";
	_content.textColor = _textColor;
	_content.font = FONT(14);
	_content.backgroundColor = [UIColor clearColor];
	[scrollView addSubview:_content];
}

- (void)backgroundTap{
	[self.view endEditing:YES];
}

- (void)submit{
	[self backgroundTap];
	if (_delegate && [_delegate respondsToSelector:@selector(AJGoodsPicMemoWithData:)]) {
		[_delegate AJGoodsPicMemoWithData:@{GOODS_EDIT_PIC_MEMO:_content.text, @"photobrowser":_browser}];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) {
		self.view = nil;
	}
}

@end
