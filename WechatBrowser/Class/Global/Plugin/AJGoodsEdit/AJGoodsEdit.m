//
//  AJGoodsEdit.m
//
//  Created by ajsong on 2017/3/14.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AJGoodsEdit.h"
#import "AJGoodsPicMemo.h"
#import "AJGoodsContent.h"

@interface AJGoodsEdit ()<UITextViewDelegate,AJSelectImageDelegate,AJPhotosDataSource,AJPhotosDelegate,AJPickerViewDelegate,MJPhotosBrowserDelegate,AJGoodsPicMemoDelegate,AJGoodsContentDelegate,DragSubviewsDelegate>{
	NSMutableArray *_images;
	NSMutableArray *_imageUrls;
	NSMutableArray *_imageMemos;
	UIITextView *_name;
	NSString *_type_id;
	UIITextField *_price;
	UIITextField *_promote_price;
	UIITextField *_stocks;
	UIITextField *_shipping_fee;
	UITextField *_description;
	NSString *_content;
	
	AJSelectImage *_selectImage;
	UIView *_view;
	UIActivityIndicatorView *_loading;
	NSMutableArray *_photos;
	AJPhotosView *_photosView;
	UILabel *_nameCount;
	AJPickerView *_typePicker;
	UILabel *_typeLabel;
	UILabel *_contentLabel;
	
	UIToolbar *_bottomView;
}
@property (nonatomic,strong) UIScrollView *scrollView;
@end

@implementation AJGoodsEdit

- (instancetype)init{
	self = [super init];
	if (self) {
		_imageMemo = GOODS_EDIT_IMAGE_MEMO ? YES : NO;
		_nameNums = GOODS_EDIT_NAME_NUMS;
		_specsNums = GOODS_EDIT_SPECS_NUMS;
		_textColor = GOODS_EDIT_TEXT_COLOR;
		_imagesColor = GOODS_EDIT_ADD_IMAGES_COLOR;
		_specsBtnColor = GOODS_EDIT_ADD_SPECS_COLOR;
		_btnColor = GOODS_EDIT_BTN_COLOR;
		_tips = GOODS_EDIT_TIPS;
		_imageUpyun = GOODS_EDIT_IMAGE_UPYUN_PATH;
		_contentUpyun = GOODS_EDIT_CONTENT_UPYUN_PATH;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"发布商品";
	self.view.backgroundColor = COLORBACK;
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithImage:[IMG(@"return") overlayWithColor:COLORNAVTEXT] size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
	[item addTarget:self action:^(id target, id sender) {
		BOOL checkField = _name.text.length && ![_name.text isEqualToString:_data[GOODS_EDIT_NAME]];
		checkField = checkField || (_type_id.length && _type_id.intValue!=[_data[GOODS_EDIT_CATE_ID]intValue]);
		checkField = checkField || (_description.text.length && ![_description.text isEqualToString:_data[GOODS_EDIT_DESCRIPTION]]);
		checkField = checkField || (_content.length && ![_content isEqualToString:_data[GOODS_EDIT_CONTENT]]);
		if (checkField) {
			[UIAlertController alert:@"真的不提交商品数据？" submit:@"不提交" block:^(NSInteger buttonIndex) {
				if (buttonIndex==1) {
					[[target navigationController] popViewControllerAnimated:YES];
				}
			}];
			return;
		}
		[[target navigationController] popViewControllerAnimated:YES];
	}];
	
	_images = [[NSMutableArray alloc]init];
	_imageUrls = [[NSMutableArray alloc]init];
	_imageMemos = [[NSMutableArray alloc]init];
	_photos = [[NSMutableArray alloc]init];
	_type_id = (_data.isDictionary && _data[GOODS_EDIT_CATE_ID]) ? _data[GOODS_EDIT_CATE_ID] : @"";
	_content = (_data.isDictionary && _data[GOODS_EDIT_CONTENT]) ? _data[GOODS_EDIT_CONTENT] : @"";
	_typePicker = [[AJPickerView alloc]init];
	_typePicker.delegate = self;
	_typePicker.nameKey = GOODS_EDIT_TYPE_NAME;
	_typePicker.subKey = GOODS_EDIT_SUBTYPE_KEY;
	
	_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_scrollView.contentInset = UIEdgeInsetsMake(0, 0, 42*SCREEN_SCALE, 0);
	_scrollView.scrollIndicatorInsets = _scrollView.contentInset;
	[self.view addSubview:_scrollView];
}

- (void)setCategories:(NSArray *)categories{
	//NSLog(@"%@", datas.descriptionASCII);
	_categories = categories;
	if (!_categories.isArray || ![_categories[0]isDictionary] || !_categories[0][GOODS_EDIT_TYPE_ID] || !_categories[0][GOODS_EDIT_TYPE_NAME]) {
		[ProgressHUD showError:@"缺少商品分类元数据"];
		return;
	}
	_typePicker.data = _categories;
	[self loadViews];
}

- (void)loadViews{
	[_scrollView removeAllSubviews];
	
	if (!_bottomView) {
		_bottomView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.height-42*SCREEN_SCALE, SCREEN_WIDTH, 42*SCREEN_SCALE)];
		_bottomView.barTintColor = _btnColor;
		_bottomView.clipsToBounds = YES;
		[self.view addSubview:_bottomView];
		UIButton *btn = [[UIButton alloc]initWithFrame:_bottomView.bounds];
		btn.titleLabel.font = FONTBOLD(15);
		btn.backgroundColor = [UIColor clearColor];
		[btn setTitle:@"立即发布" forState:UIControlStateNormal];
		[btn setTitleColor:COLORWHITE forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(AJGoodsEditSubmit) forControlEvents:UIControlEventTouchUpInside];
		[_bottomView addSubview:btn];
	}
	
	_selectImage = [[AJSelectImage alloc]init];
	_selectImage.maxCount = 9;
	_selectImage.showLoading = NO;
	_selectImage.delegate = self;
	if (_imageUpyun.length) _selectImage.upyunFolder = _imageUpyun;
	
	CGFloat width = SCREEN_WIDTH/3*2;
	UIFont *fontbold = GOODS_EDIT_FONTBOLD;
	UIFont *font = GOODS_EDIT_FONT;
	
	_view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120*SCREEN_SCALE)];
	_view.clipsToBounds = YES;
	[_scrollView addSubview:_view];
	_view.element[@"height"] = @(_view.height);
	UIImage *image = _image ? _image : [IMG(@"goods-edit-add") overlayWithColor:_imagesColor];
	CGFloat icoWidth = image.size.width;
	CGFloat icoHeight = image.size.height;
	UIImageView *ico = [[UIImageView alloc]initWithFrame:CGRectMake((_view.width-icoWidth)/2, (_view.height-icoHeight)/2, icoWidth, icoHeight)];
	ico.image = image;
	ico.layer.masksToBounds = YES;
	ico.layer.cornerRadius = ico.height/2;
	ico.clipsToBounds = YES;
	ico.contentMode = UIViewContentModeScaleAspectFill;
	ico.tag = 10;
	[_view addSubview:ico];
	ico.element[@"width"] = @(icoWidth);
	ico.element[@"height"] = @(icoHeight);
	_loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_loading.frame = ico.bounds;
	_loading.hidesWhenStopped = YES;
	[ico addSubview:_loading];
	[ico clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		[_selectImage selectImage];
	}];
	
	if (_data.isDictionary && [_data[GOODS_EDIT_PICS]isArray]) {
		NSArray *pics = _data[GOODS_EDIT_PICS];
		for (int i=0; i<pics.count; i++) {
			[_images addObject:pics[i][GOODS_EDIT_PIC]];
			[_imageUrls addObject:pics[i][GOODS_EDIT_PIC]];
			[_imageMemos addObject:pics[i][GOODS_EDIT_PIC_MEMO] ? pics[i][GOODS_EDIT_PIC_MEMO] : @""];
		}
		
		_photosView = [[AJPhotosView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
		_photosView.delegate = self;
		_photosView.dataSource = self;
		_photosView.loop = NO;
		_photosView.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.6];
		_photosView.currentPageIndicatorTintColor = _btnColor;
		[_view addSubview:_photosView];
		
		[_view bringSubviewToFront:ico];
		ico.frame = CGRectMake(10*SCREEN_SCALE, SCREEN_WIDTH-40*SCREEN_SCALE-10*SCREEN_SCALE, 40*SCREEN_SCALE, 40*SCREEN_SCALE);
		ico.layer.cornerRadius = ico.height/2;
		ico.backgroundColor = COLORWHITE;
		
		_view.height = SCREEN_WIDTH;
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				for (int i=0; i<_images.count; i++) {
					MJPhotos *photo = [[MJPhotos alloc] init];
					photo.url = _images[i];
					photo.srcImageView = [_photosView viewWithTag:i+5000];
					[_photos addObject:photo];
				}
			});
		});
	}
	
	UIView *view = [[UIView alloc]initWithFrame:_view.frameBottom];
	view.height = 60*SCREEN_SCALE;
	view.backgroundColor = COLORWHITE;
	[_scrollView addSubview:view];
	[view addGeWithType:GeLineTypeTop color:COLOR_GE_LIGHT];
	UIView *subview = [[UIView alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 0, view.width-10*SCREEN_SCALE, view.height)];
	[view addSubview:subview];
	[subview addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	_name = [[UIITextView alloc]initWithFrame:CGRectMake(0, (subview.height-32*SCREEN_SCALE)/2, subview.width-46*SCREEN_SCALE-10*SCREEN_SCALE, 32*SCREEN_SCALE)];
	if (_data.isDictionary) _name.text = _data[GOODS_EDIT_NAME];
	_name.placeholder = @"输入商品标题";
	_name.textColor = _textColor;
	_name.font = font;
	_name.backgroundColor = [UIColor clearColor];
	_name.delegate = self;
	[subview addSubview:_name];
	NSInteger nameLength = 0;
	if (_data.isDictionary) nameLength = [_data[GOODS_EDIT_NAME] length];
	NSString *string = FORMAT(@"%ld/%d", (long)nameLength, _nameNums);
	NSDictionary *style = @{@"body":@[FONT(12), COLORCCC]};
	_nameCount = [[UILabel alloc]initWithFrame:CGRectMake(_name.right, _name.bottom-12*SCREEN_SCALE, 46*SCREEN_SCALE, 12*SCREEN_SCALE)];
	_nameCount.attributedText = [string attributedStyle:style];
	_nameCount.textAlignment = NSTextAlignmentRight;
	_nameCount.backgroundColor = [UIColor clearColor];
	[subview addSubview:_nameCount];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.height = 44*SCREEN_SCALE;
	view.backgroundColor = COLORWHITE;
	[_scrollView addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 0, view.width-10*SCREEN_SCALE, view.height)];
	label.text = @"商品分类";
	label.textColor = _textColor;
	label.font = fontbold;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	UIImageView *push = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-44*SCREEN_SCALE+7*SCREEN_SCALE, 0, 44*SCREEN_SCALE, 44*SCREEN_SCALE)];
	push.image = IMG(@"push-small");
	[view addSubview:push];
	_typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(push.left-width+10*SCREEN_SCALE, 0, width, view.height)];
	if (_data.isDictionary){
		for (NSDictionary *data in _categories) {
			if ([data[GOODS_EDIT_TYPE_ID]intValue]==[_data[GOODS_EDIT_CATE_ID]intValue]) {
				_typeLabel.text = data[GOODS_EDIT_TYPE_NAME];
				break;
			}
		}
	}
	_typeLabel.textColor = _textColor;
	_typeLabel.textAlignment = NSTextAlignmentRight;
	_typeLabel.font = font;
	_typeLabel.lineBreakMode = NSLineBreakByTruncatingHead;
	_typeLabel.backgroundColor = [UIColor clearColor];
	[view addSubview:_typeLabel];
	[view clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		[target AJGoodsBackgroundTap];
		[_typePicker show];
	}];
	
	CGFloat specsHeight = 8*SCREEN_SCALE+44*SCREEN_SCALE*3;
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	if (_data.isDictionary && [_data[GOODS_EDIT_SPECS]isArray]) {
		view.height = 0;
	} else {
		view.height = specsHeight;
	}
	view.clipsToBounds = YES;
	[_scrollView addSubview:view];
	view.element[@"height"] = @(specsHeight);
	
	subview = [[UIView alloc]initWithFrame:CGRectMake(0, 8*SCREEN_SCALE, SCREEN_WIDTH, 44*SCREEN_SCALE)];
	subview.backgroundColor = COLORWHITE;
	[view addSubview:subview];
	[subview addGeWithType:GeLineTypeTop color:COLOR_GE_LIGHT];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"价格";
	label.textColor = _textColor;
	label.font = fontbold;
	label.backgroundColor = [UIColor clearColor];
	[subview addSubview:label];
	[label addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	_price = [[UIITextField alloc]initWithFrame:CGRectMake(subview.width-140*SCREEN_SCALE-10*SCREEN_SCALE, 0, 140*SCREEN_SCALE, subview.height)];
	if (_data.isDictionary) _price.text = _data[GOODS_EDIT_PRICE];
	_price.placeholder = @"￥";
	_price.textColor = _textColor;
	_price.textAlignment = NSTextAlignmentRight;
	_price.font = font;
	_price.backgroundColor = [UIColor clearColor];
	_price.keyboardType = UIKeyboardTypeDecimalPad;
	[subview addSubview:_price];
	
	subview = [[UIView alloc]initWithFrame:subview.frameBottom];
	subview.backgroundColor = COLORWHITE;
	[view addSubview:subview];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"促销价";
	label.textColor = _textColor;
	label.font = fontbold;
	label.backgroundColor = [UIColor clearColor];
	[subview addSubview:label];
	[label addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	_promote_price = [[UIITextField alloc]initWithFrame:_price.frame];
	if (_data.isDictionary) _promote_price.text = _data[GOODS_EDIT_PROMOTE_PRICE];
	_promote_price.placeholder = @"￥";
	_promote_price.textColor = _textColor;
	_promote_price.textAlignment = NSTextAlignmentRight;
	_promote_price.font = font;
	_promote_price.backgroundColor = [UIColor clearColor];
	_promote_price.keyboardType = UIKeyboardTypeDecimalPad;
	[subview addSubview:_promote_price];
	
	subview = [[UIView alloc]initWithFrame:subview.frameBottom];
	subview.backgroundColor = COLORWHITE;
	[view addSubview:subview];
	[subview addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"库存";
	label.textColor = _textColor;
	label.font = fontbold;
	label.backgroundColor = [UIColor clearColor];
	[subview addSubview:label];
	_stocks = [[UIITextField alloc]initWithFrame:_price.frame];
	if (_data.isDictionary) _stocks.text = _data[GOODS_EDIT_STOCKS];
	_stocks.placeholder = @"件数";
	_stocks.textColor = _textColor;
	_stocks.textAlignment = NSTextAlignmentRight;
	_stocks.font = font;
	_stocks.backgroundColor = [UIColor clearColor];
	_stocks.keyboardType = UIKeyboardTypeNumberPad;
	[subview addSubview:_stocks];
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, view.bottom, SCREEN_WIDTH, 0)];
	view.clipsToBounds = YES;
	view.tag = 100;
	view.element[@"disableScale"] = @YES;
	view.element[@"disableShake"] = @YES;
	[_scrollView addSubview:view];
	subview = [[UIView alloc]initWithFrame:CGRectMake(0, 8*SCREEN_SCALE, view.width, 44*SCREEN_SCALE)];
	subview.backgroundColor = COLORWHITE;
	[view addSubview:subview];
	[subview addGeWithType:GeLineTypeTopBottom color:COLOR_GE_LIGHT];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"商品规格";
	label.textColor = _textColor;
	label.font = fontbold;
	label.backgroundColor = [UIColor clearColor];
	[subview addSubview:label];
	UILabel *sublabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, subview.width-8*SCREEN_SCALE, subview.height)];
	sublabel.text = @"批量设定价格/库存";
	sublabel.textColor = COLORCCC;
	sublabel.textAlignment = NSTextAlignmentRight;
	sublabel.font = FONT(12);
	sublabel.backgroundColor = [UIColor clearColor];
	[subview addSubview:sublabel];
	[subview clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		[target setSpecsField];
	}];
	
	view = [[UIView alloc]initWithFrame:[view frameBottom:8*SCREEN_SCALE]];
	view.height = 44*SCREEN_SCALE;
	view.backgroundColor = COLORWHITE;
	[_scrollView addSubview:view];
	[view addGeWithType:GeLineTypeTopBottom color:COLOR_GE_LIGHT];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"+ 添加商品规格";
	label.textColor = _specsBtnColor;
	label.font = fontbold;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[view clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		[target addSpecsWithData:nil];
	}];
	
	view = [[UIView alloc]initWithFrame:[view frameBottom:8*SCREEN_SCALE]];
	view.backgroundColor = COLORWHITE;
	[_scrollView addSubview:view];
	[view addGeWithType:GeLineTypeTopBottom color:COLOR_GE_LIGHT];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"运费";
	label.textColor = _textColor;
	label.font = fontbold;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	_shipping_fee = [[UIITextField alloc]initWithFrame:_price.frame];
	if (_data.isDictionary) _shipping_fee.text = _data[GOODS_EDIT_SHIPPING_FEE];
	_shipping_fee.placeholder = @"￥";
	_shipping_fee.textColor = _textColor;
	_shipping_fee.textAlignment = NSTextAlignmentRight;
	_shipping_fee.font = font;
	_shipping_fee.backgroundColor = [UIColor clearColor];
	_shipping_fee.keyboardType = UIKeyboardTypeDecimalPad;
	[view addSubview:_shipping_fee];
	
	CGFloat top = view.bottom + 8*SCREEN_SCALE;
	NSArray *optionViews = [self AJGoodsEditOptionViews:self];
	if (optionViews.isArray) {
		for (UIView *optionView in optionViews) {
			view = optionView;
			view.top = top;
			view.backgroundColor = COLORWHITE;
			[_scrollView addSubview:view];
			[view addGeWithType:GeLineTypeTopBottom color:COLOR_GE_LIGHT];
			top = view.bottom + 8*SCREEN_SCALE;
		}
	}
	
	view = [[UIView alloc]initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, 44*SCREEN_SCALE)];
	view.backgroundColor = COLORWHITE;
	[_scrollView addSubview:view];
	[view addGeWithType:GeLineTypeTop color:COLOR_GE_LIGHT];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"商品描述";
	label.textColor = _textColor;
	label.font = fontbold;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	[label addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	_description = [[UITextField alloc]initWithFrame:_typeLabel.frame];
	_description.left = view.width-_description.width-10*SCREEN_SCALE;
	if (_data.isDictionary) _description.text = _data[GOODS_EDIT_DESCRIPTION];
	_description.placeholder = @"请输入简单的商品描述";
	_description.textColor = _textColor;
	_description.textAlignment = NSTextAlignmentRight;
	_description.font = font;
	_description.backgroundColor = [UIColor clearColor];
	[view addSubview:_description];
	
	view = [[UIView alloc]initWithFrame:view.frameBottom];
	view.backgroundColor = COLORWHITE;
	[_scrollView addSubview:view];
	[view addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	label = [[UILabel alloc]initWithFrame:label.frame];
	label.text = @"商品详情";
	label.textColor = _textColor;
	label.font = fontbold;
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	push = [[UIImageView alloc]initWithFrame:push.frame];
	push.image = IMG(@"push-small");
	[view addSubview:push];
	_contentLabel = [[UILabel alloc]initWithFrame:_typeLabel.frame];
	if (_content.length) _contentLabel.text = @"已编辑";
	_contentLabel.textColor = _textColor;
	_contentLabel.textAlignment = NSTextAlignmentRight;
	_contentLabel.font = font;
	_contentLabel.backgroundColor = [UIColor clearColor];
	[view addSubview:_contentLabel];
	[view clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		AJGoodsContent *e = [[AJGoodsContent alloc]init];
		e.title = @"商品详情";
		e.delegate = self;
		e.html = _content;
		e.textColor = _textColor;
		e.btnColor = _btnColor;
		e.upyunPath = _contentUpyun;
		e.placeholder = _contentPlaceholder;
		e.editorUrl = _editorUrl;
		[[target navigationController] pushViewController:e animated:YES];
	}];
	
	if (_tips.length) {
		label = [[UILabel alloc]initWithFrame:CGRectMake(8*SCREEN_SCALE, view.bottom+8*SCREEN_SCALE, SCREEN_WIDTH-8*SCREEN_SCALE*2, 0)];
		label.text = _tips;
		label.textColor = COLOR999;
		label.font = FONT(11);
		label.backgroundColor = [UIColor clearColor];
		[_scrollView addSubview:label];
		label.autoHeight = UIEdgeInsetsZero;
	}
	
	_scrollView.contentSize = CGSizeMake(_scrollView.width, _scrollView.lastSubview.bottom+8*SCREEN_SCALE);
	
	if (_data.isDictionary && [_data[GOODS_EDIT_SPECS]isArray]) {
		NSArray *specs = _data[GOODS_EDIT_SPECS];
		for (int i=0; i<specs.count; i++) {
			if (i >= _specsNums) break;
			[self addSpecsWithData:specs[i]];
		}
	}
}

#pragma mark - 图片
- (void)AJSelectImageUploadingImage:(AJSelectImage *)selectImage{
	[_loading startAnimating];
}
- (void)AJSelectImageDidSelectedImage:(AJSelectImage *)selectImage{
	[_loading stopAnimating];
	_images = selectImage.images;
	_imageUrls = selectImage.imageUrls;
	_imageMemos = [[NSMutableArray alloc]init];
	_photos = [[NSMutableArray alloc]init];
	
	if (_photosView) {
		[_photosView reloadData];
	} else {
		_photosView = [[AJPhotosView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
		_photosView.delegate = self;
		_photosView.dataSource = self;
		_photosView.loop = NO;
		_photosView.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.6];
		_photosView.currentPageIndicatorTintColor = _btnColor;
		[_view addSubview:_photosView];
		
		UIView *ico = [_view viewWithTag:10];
		[_view bringSubviewToFront:ico];
		CGFloat icoWidth = [ico.element[@"width"] floatValue];
		CGFloat icoHeight = [ico.element[@"height"] floatValue];
		[UIView animateWithDuration:0.3 animations:^{
			if (icoWidth>40*SCREEN_SCALE || icoHeight>40*SCREEN_SCALE) {
				CGSize size = [Global fitToSize:CGSizeMakeScale(@40, @40) originSize:CGSizeMake(icoWidth, icoHeight)];
				ico.frame = CGRectMake(10*SCREEN_SCALE, SCREEN_WIDTH-size.height-10*SCREEN_SCALE, size.width, size.height);
				ico.layer.cornerRadius = ico.height/2;
				_loading.frame = ico.bounds;
			}
		} completion:^(BOOL finished) {
			ico.backgroundColor = COLORWHITE;
		}];
		
		UIView *view = _view;
		[view setHeightAndChangeNextTop:SCREEN_WIDTH completion:^(UIView *view) {
			[UIView animateWithDuration:0.3 animations:^{
				self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.scrollView.lastSubview.bottom+8*SCREEN_SCALE);
			}];
		}];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			for (int i=0; i<_images.count; i++) {
				MJPhotos *photo = [[MJPhotos alloc] init];
				photo.url = _images[i];
				photo.srcImageView = [_photosView viewWithTag:i+5000];
				[_photos addObject:photo];
				[_imageMemos addObject:@""];
			}
		});
	});
}

- (NSInteger)AJPhotosViewNumberOfPages:(AJPhotosView *)photosView{
	return _images.count;
}
- (UIView*)AJPhotosView:(AJPhotosView *)photosView viewAtIndex:(NSInteger)index{
	UIImageView *pic = [[UIImageView alloc]initWithFrame:photosView.bounds];
	pic.url = _images[index];
	pic.tag = index + 5000;
	pic.clipsToBounds = YES;
	pic.contentMode = UIViewContentModeScaleAspectFill;
	[pic clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		if (_photos.count) {
			MJPhotosBrowser *browser = [[MJPhotosBrowser alloc]init];
			browser.currentPhotoIndex = index;
			browser.photos = _photos;
			if (_imageMemo) {
				browser.showInfo = YES;
				UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44*SCREEN_SCALE, 44*SCREEN_SCALE)];
				UIButton *btn = [[UIButton alloc]initWithFrame:btnView.bounds];
				btn.titleLabel.font = FONT(15);
				btn.backgroundColor = [UIColor clearColor];
				[btn setTitle:@"描述" forState:UIControlStateNormal];
				[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
				[btn addTarget:target action:^(id target, id sender) {
					MJPhotos *photo = _photos[index];
					AJGoodsPicMemo *e = [[AJGoodsPicMemo alloc]init];
					e.data = @{GOODS_EDIT_PIC_MEMO:photo.content};
					e.delegate = target;
					e.browser = browser;
					e.textColor = _textColor;
					[[target navigationController] pushViewController:e animated:YES];
				}];
				[btnView addSubview:btn];
				browser.btnView = btnView;
				browser.delegate = self;
				[[target navigationController] pushViewController:browser animated:YES];
			} else {
				[browser show];
			}
		}
	}];
	[pic longClickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		[UIAlertController action:@"操作" buttons:@[@"保存到相册", @"删除"] block:^(NSInteger buttonIndex) {
			if (buttonIndex==0) {
				[Global saveImageToPhotos:_images[index]];
			} else if (buttonIndex==1) {
				[_images removeObjectAtIndex:index];
				[_imageMemos removeObjectAtIndex:index];
				[photosView reloadData];
			}
		}];
	}];
	return pic;
}
- (void)AJPhotosViewNullPages:(AJPhotosView *)photosView{
	CGFloat height = [_view.element[@"height"] floatValue];
	UIView *ico = [_view viewWithTag:10];
	ico.backgroundColor = [UIColor clearColor];
	CGFloat icoWidth = [ico.element[@"width"] floatValue];
	CGFloat icoHeight = [ico.element[@"height"] floatValue];
	[UIView animateWithDuration:0.3 animations:^{
		ico.frame = CGRectMake((_view.width-icoWidth)/2, (height-icoHeight)/2, icoWidth, icoHeight);
		ico.layer.cornerRadius = ico.height/2;
	}];
	
	UIView *view = _view;
	[view setHeightAndChangeNextTop:height completion:^(UIView *view) {
		[UIView animateWithDuration:0.3 animations:^{
			self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.scrollView.lastSubview.bottom+8*SCREEN_SCALE);
		}];
	}];
}

#pragma mark - 图片描述
- (void)AJGoodsPicMemoWithData:(NSDictionary *)data{
	MJPhotosBrowser *browser = data[@"photobrowser"];
	NSInteger index = browser.currentPhotoIndex;
	if (_imageMemos.count-1<index) return;
	[_imageMemos replaceObjectAtIndex:index withObject:data[GOODS_EDIT_PIC_MEMO]];
	MJPhotos *photo = _photos[index];
	photo.content = data[GOODS_EDIT_PIC_MEMO];
	[browser reloadData];
}

#pragma mark - 标题字数
- (void)textViewDidChange:(UITextView *)textView{
	UITextRange *selectedRange = [textView markedTextRange];
	UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0]; //获取高亮部分
	if (selectedRange && pos) return; //如果在变化中是高亮部分在变，就不要计算字符了
	NSInteger existTextNum = textView.text.length;
	NSString *string = FORMAT(@"<p>%ld</p>/%d", (long)MAX(0, existTextNum), _nameNums); //MAX为了不让显示负数
	NSDictionary *style = @{@"body":@[FONT(12), COLORCCC], @"p":existTextNum>_nameNums?COLORORANGE:COLORCCC};
	_nameCount.attributedText = [string attributedStyle:style];
}

#pragma mark - 分类
- (void)AJPickerView:(AJPickerView *)pickerView didSubmitItems:(NSArray *)items{
	_type_id = items[1][GOODS_EDIT_TYPE_ID];
	_typeLabel.text = FORMAT(@"%@ - %@", items[0][GOODS_EDIT_TYPE_NAME], items[1][GOODS_EDIT_TYPE_NAME]);
}

#pragma mark - 规格
- (void)addSpecsWithData:(NSDictionary*)data{
	[self AJGoodsBackgroundTap];
	UIView *specsView = [_scrollView viewWithTag:100];
	if (specsView.subviews.count-1 >= _specsNums) {
		[ProgressHUD showError:FORMAT(@"最多只能添加%d组规格", _specsNums)];
		return;
	}
	
	[specsView.prevView setHeightAndChangeNextTop:0 completion:^(UIView *view) {
		CGFloat width = 140*SCREEN_SCALE;
		UIFont *fontbold = GOODS_EDIT_FONTBOLD;
		UIFont *font = GOODS_EDIT_FONT;
		
		view = [[UIView alloc]initWithFrame:CGRectMake(-SCREEN_WIDTH, specsView.lastSubview.bottom, SCREEN_WIDTH, 8*SCREEN_SCALE+44*SCREEN_SCALE*4)];
		view.clipsToBounds = YES;
		[specsView addSubview:view];
		
		UIView *subview = [[UIView alloc]initWithFrame:CGRectMake(0, 8*SCREEN_SCALE, view.width-32*SCREEN_SCALE/2, 44*SCREEN_SCALE)];
		subview.backgroundColor = COLORWHITE;
		[view addSubview:subview];
		[subview addGeWithType:GeLineTypeTop color:COLOR_GE_LIGHT];
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 0, subview.width-10*SCREEN_SCALE, subview.height)];
		label.text = @"规格名称";
		label.textColor = _textColor;
		label.font = fontbold;
		label.backgroundColor = [UIColor clearColor];
		[subview addSubview:label];
		[label addGeWithType:GeLineTypeRightBottom color:COLOR_GE_LIGHT];
		UIITextField *spec = [[UIITextField alloc]initWithFrame:CGRectMake(subview.width-width-10*SCREEN_SCALE, 0, width, subview.height)];
		if (data.isDictionary) spec.text = data[GOODS_EDIT_SPEC];
		spec.placeholder = @"输入名称";
		spec.textColor = _textColor;
		spec.textAlignment = NSTextAlignmentRight;
		spec.font = font;
		spec.backgroundColor = [UIColor clearColor];
		spec.tag = 101;
		[subview addSubview:spec];
		
		subview = [[UIView alloc]initWithFrame:subview.frameBottom];
		subview.backgroundColor = COLORWHITE;
		[view addSubview:subview];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"价格";
		label.textColor = _textColor;
		label.font = fontbold;
		label.backgroundColor = [UIColor clearColor];
		[subview addSubview:label];
		[label addGeWithType:GeLineTypeRightBottom color:COLOR_GE_LIGHT];
		UIITextField *price = [[UIITextField alloc]initWithFrame:spec.frame];
		if (data.isDictionary) price.text = data[GOODS_EDIT_PRICE];
		price.placeholder = @"￥";
		price.textColor = _textColor;
		price.textAlignment = NSTextAlignmentRight;
		price.font = font;
		price.backgroundColor = [UIColor clearColor];
		price.keyboardType = UIKeyboardTypeDecimalPad;
		price.tag = 102;
		[subview addSubview:price];
		
		subview = [[UIView alloc]initWithFrame:subview.frameBottom];
		subview.backgroundColor = COLORWHITE;
		[view addSubview:subview];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"促销价";
		label.textColor = _textColor;
		label.font = fontbold;
		label.backgroundColor = [UIColor clearColor];
		[subview addSubview:label];
		[label addGeWithType:GeLineTypeRightBottom color:COLOR_GE_LIGHT];
		UIITextField *promote_price = [[UIITextField alloc]initWithFrame:spec.frame];
		if (data.isDictionary) promote_price.text = data[GOODS_EDIT_PROMOTE_PRICE];
		promote_price.placeholder = @"￥";
		promote_price.textColor = _textColor;
		promote_price.textAlignment = NSTextAlignmentRight;
		promote_price.font = font;
		promote_price.backgroundColor = [UIColor clearColor];
		promote_price.keyboardType = UIKeyboardTypeDecimalPad;
		promote_price.tag = 103;
		[subview addSubview:promote_price];
		
		subview = [[UIView alloc]initWithFrame:subview.frameBottom];
		subview.backgroundColor = COLORWHITE;
		[view addSubview:subview];
		[subview addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
		label = [[UILabel alloc]initWithFrame:label.frame];
		label.text = @"库存";
		label.textColor = _textColor;
		label.font = fontbold;
		label.backgroundColor = [UIColor clearColor];
		[subview addSubview:label];
		[label addGeWithType:GeLineTypeRight color:COLOR_GE_LIGHT];
		UIITextField *stocks = [[UIITextField alloc]initWithFrame:spec.frame];
		if (data.isDictionary) stocks.text = data[GOODS_EDIT_STOCKS];
		stocks.placeholder = @"件数";
		stocks.textColor = _textColor;
		stocks.textAlignment = NSTextAlignmentRight;
		stocks.font = font;
		stocks.backgroundColor = [UIColor clearColor];
		stocks.keyboardType = UIKeyboardTypeNumberPad;
		stocks.tag = 104;
		[subview addSubview:stocks];
		
		UIView *btn = [[UIView alloc]initWithFrame:CGRectMake(view.width-32*SCREEN_SCALE, 8*SCREEN_SCALE+(view.height-8*SCREEN_SCALE-32*SCREEN_SCALE)/2, 32*SCREEN_SCALE, 32*SCREEN_SCALE)];
		btn.backgroundColor = COLORBACK;
		btn.layer.masksToBounds = YES;
		btn.layer.cornerRadius = btn.height/2;
		[view addSubview:btn];
		label = [[UILabel alloc]initWithFrame:CGRectMake(3*SCREEN_SCALE, 3*SCREEN_SCALE, btn.width-3*SCREEN_SCALE*2, btn.height-3*SCREEN_SCALE*2)];
		label.text = @"－";
		label.textColor = COLORWHITE;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(16);
		label.backgroundColor = COLORRED;
		label.layer.masksToBounds = YES;
		label.layer.cornerRadius = label.height/2;
		label.tag = 110;
		[btn addSubview:label];
		[btn clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
			[target deleteSpecs:sender.superview];
		}];
		
		view.leftAnimate = 0;
		
		__weak typeof(specsView) _specsView = specsView;
		[specsView setHeightAndChangeNextTop:view.bottom completion:^(UIView *view) {
			[UIView animateWithDuration:0.3 animations:^{
				self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.scrollView.lastSubview.bottom+8*SCREEN_SCALE);
			} completion:^(BOOL finished) {
				[_specsView dragSubviewsWithTarget:self lockRect:CGRectMake(0, MAXFLOAT, _specsView.width, MAXFLOAT) skipViews:@[_specsView.firstSubview]];
			}];
		}];
	}];
}

- (void)deleteSpecs:(UIView*)view{
	UIView *specsView = [_scrollView viewWithTag:100];
	view.leftAnimate = SCREEN_WIDTH;
	[view setHeightAndChangeNextTop:0 completion:^(UIView *view) {
		[view removeFromSuperview];
		if (specsView.subviews.count==1) {
			[specsView.prevView setHeightAndChangeNextTop:[specsView.prevView.element[@"height"]floatValue] completion:^(UIView *view) {
				[UIView animateWithDuration:0.3 animations:^{
					self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.scrollView.lastSubview.bottom+8*SCREEN_SCALE);
				}];
			}];
		}
	}];
	
	CGFloat height = 0;
	if (specsView.subviews.count>2) height = specsView.lastSubview.bottom;
	[specsView setHeightAndChangeNextTop:height completion:^(UIView *view) {
		[UIView animateWithDuration:0.3 animations:^{
			self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.scrollView.lastSubview.bottom+8*SCREEN_SCALE);
		}];
	}];
}

- (void)setSpecsField{
	UIFont *font = GOODS_EDIT_FONT;
	
	UIToolbar *view = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-25*SCREEN_SCALE*2, 0)];
	view.layer.masksToBounds = YES;
	view.layer.cornerRadius = 4*SCREEN_SCALE;
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width, 44*SCREEN_SCALE)];
	label.text = @"批量设定价格/库存";
	label.textColor = _textColor;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONTBOLD(14);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	UIView *inputView = [[UIView alloc]initWithFrame:CGRectMake(20*SCREEN_SCALE, label.bottom, view.width-20*SCREEN_SCALE*2, 40*SCREEN_SCALE*3)];
	inputView.backgroundColor = COLORWHITE;
	inputView.clipsToBounds = YES;
	inputView.layer.masksToBounds = YES;
	inputView.layer.cornerRadius = 4*SCREEN_SCALE;
	[view addSubview:inputView];
	
	UIITextField *price = [[UIITextField alloc]initWithFrame:CGRectMake(0, 0, inputView.width, 40*SCREEN_SCALE)];
	price.placeholder = @"统一价格";
	price.textColor = _textColor;
	price.textAlignment = NSTextAlignmentCenter;
	price.font = font;
	price.backgroundColor = [UIColor clearColor];
	price.keyboardType = UIKeyboardTypeDecimalPad;
	[inputView addSubview:price];
	[price addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	
	UIITextField *special_price = [[UIITextField alloc]initWithFrame:price.frameBottom];
	special_price.placeholder = @"统一促销价";
	special_price.textColor = _textColor;
	special_price.textAlignment = NSTextAlignmentCenter;
	special_price.font = font;
	special_price.backgroundColor = [UIColor clearColor];
	special_price.keyboardType = UIKeyboardTypeDecimalPad;
	[inputView addSubview:special_price];
	[special_price addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
	
	UIITextField *stocks = [[UIITextField alloc]initWithFrame:special_price.frameBottom];
	stocks.placeholder = @"统一库存";
	stocks.textColor = _textColor;
	stocks.textAlignment = NSTextAlignmentCenter;
	stocks.font = font;
	stocks.backgroundColor = [UIColor clearColor];
	stocks.keyboardType = UIKeyboardTypeNumberPad;
	[inputView addSubview:stocks];
	
	label = [[UILabel alloc]initWithFrame:CGRectMake(0, inputView.bottom, view.width, 40*SCREEN_SCALE)];
	label.text = @"您可以只设定其中一项或全部设定";
	label.textColor = COLOR999;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = FONT(11);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom, view.width, 40*SCREEN_SCALE)];
	[view addSubview:btnView];
	[btnView addGeWithType:GeLineTypeTop color:COLORBBB];
	
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnView.width/2, btnView.height)];
	btn.titleLabel.font = FONT(14);
	btn.backgroundColor = [UIColor clearColor];
	[btn setTitle:@"取消" forState:UIControlStateNormal];
	[btn setTitleColor:COLOR_SYSTEM_BLUE forState:UIControlStateNormal];
	[btn addTarget:self action:^(id target, id sender) {
		[KEYWINDOW endEditing:YES];
		[target dismissAlertView];
	}];
	[btnView addSubview:btn];
	[btn addGeWithType:GeLineTypeRight color:COLORBBB];
	
	btn = [[UIButton alloc]initWithFrame:btn.frameRight];
	btn.titleLabel.font = FONTBOLD(14);
	btn.backgroundColor = [UIColor clearColor];
	[btn setTitle:@"确定" forState:UIControlStateNormal];
	[btn setTitleColor:COLOR_SYSTEM_BLUE forState:UIControlStateNormal];
	[btn addTarget:self action:^(id target, id sender) {
		UIView *specsView = [_scrollView viewWithTag:100];
		for (UIView *subview in specsView.subviews) {
			if (price.text.length) {
				UITextField *priceField = (UITextField*)[subview viewWithTag:102];
				priceField.text = price.text;
			}
			if (special_price.text.length) {
				UITextField *special_priceField = (UITextField*)[subview viewWithTag:103];
				special_priceField.text = special_price.text;
			}
			if (stocks.text.length) {
				UITextField *stocksField = (UITextField*)[subview viewWithTag:104];
				stocksField.text = stocks.text;
			}
		}
		[KEYWINDOW endEditing:YES];
		[target dismissAlertView];
	}];
	[btnView addSubview:btn];
	
	view.height = btnView.bottom;
	
	[self presentAlertView:view animation:DYAlertViewDown];
}

- (void)dragSubviewsSortBegan:(UIView *)subview{
	UIView *label = [subview viewWithTag:110];
	label.backgroundColor = COLOR999;
}
- (void)dragSubviewsSortEnded:(UIView *)subview{
	UIView *label = [subview viewWithTag:110];
	label.backgroundColor = COLORRED;
}

#pragma mark - 商品描述
- (void)AJGoodsContentWithData:(NSDictionary *)data{
	_content = data[@"content"];
	_contentLabel.text = @"已编辑";
}

#pragma mark -
- (void)AJGoodsBackgroundTap{
	[self.view endEditing:YES];
}

- (void)AJGoodsEditSubmit{
	[self AJGoodsBackgroundTap];
	if (!_name.text.length) {
		[ProgressHUD showError:@"请输入商品标题"];
		return;
	}
	if (!_type_id.length) {
		[ProgressHUD showError:@"请选择商品分类"];
		return;
	}
	UIView *specsView = [_scrollView viewWithTag:100];
	if (specsView.subviews.count>1) {
		NSArray *subviews = [specsView.firstSubview subviewsOfFind:[UIITextField class]];
		for (UIITextField *textField in subviews) {
			if (!textField.text.length && textField.tag!=103) {
				switch (textField.tag) {
					case 101:[ProgressHUD showError:@"请输入规格名称"];break;
					case 102:[ProgressHUD showError:@"请输入价格"];break;
					//case 103:[ProgressHUD showError:@"请输入促销价"];break;
					case 104:[ProgressHUD showError:@"请输入库存"];break;
				}
				return;
				break;
			}
			switch (textField.tag) {
				case 102:{
					if (textField.text.floatValue <= 0) {
						[ProgressHUD showError:@"请输入正确的价格"];
						return;
					}
					break;
				}
				case 103:{
					if (textField.text.length) {
						if (textField.text.floatValue <= 0) {
							[ProgressHUD showError:@"请输入正确的促销价"];
							return;
						}
						if (textField.text.floatValue >= [[[textField.superview.prevView viewWithTag:102] text] floatValue]) {
							[ProgressHUD showError:@"促销价必须小于价格"];
							return;
						}
					}
					break;
				}
				case 104:{
					if (textField.text.floatValue <= 0) {
						[ProgressHUD showError:@"请输入正确的库存"];
						return;
					}
					break;
				}
			}
		}
	} else {
		if (_price.text.floatValue <= 0) {
			[ProgressHUD showError:@"请输入正确的价格"];
			return;
		}
		if (_promote_price.text.length) {
			if (_promote_price.text.floatValue <= 0) {
				[ProgressHUD showError:@"请输入正确的促销价"];
				return;
			}
			if (_promote_price.text.floatValue >= _price.text.floatValue) {
				[ProgressHUD showError:@"促销价必须小于价格"];
				return;
			}
		}
		if (!_stocks.text.length) {
			[ProgressHUD showError:@"请输入库存"];
			return;
		}
	}
	if (!_content.length) {
		[ProgressHUD showError:@"请输入商品描述"];
		return;
	}
	
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	if (_data.isDictionary) [postData setValue:_data[GOODS_EDIT_ID] forKey:GOODS_EDIT_ID];
	[postData setValue:_name.text forKey:GOODS_EDIT_NAME];
	[postData setValue:_type_id forKey:GOODS_EDIT_CATE_ID];
	[postData setValue:_shipping_fee.text forKey:GOODS_EDIT_SHIPPING_FEE];
	[postData setValue:_description.text forKey:GOODS_EDIT_DESCRIPTION];
	[postData setValue:_content forKey:GOODS_EDIT_CONTENT];
	
	NSMutableArray *specs = [[NSMutableArray alloc]init];
	if (specsView.subviews.count>1) {
		for (UIView *subview in specsView.subviews) {
			BOOL isFull = YES;
			for (int i=101; i<=104; i++) {
				UIITextField *textField = (UIITextField*)[subview viewWithTag:i];
				if (!textField.text.length && textField.tag!=103) {
					isFull = NO;
					break;
				}
			}
			if (isFull) {
				NSMutableDictionary *specsDict = [[NSMutableDictionary alloc]init];
				for (int i=101; i<=104; i++) {
					UIITextField *textField = (UIITextField*)[subview viewWithTag:i];
					NSString *key = @"";
					switch (i) {
						case 101:key = GOODS_EDIT_SPEC;break;
						case 102:key = GOODS_EDIT_PRICE;break;
						case 103:key = GOODS_EDIT_PROMOTE_PRICE;break;
						case 104:key = GOODS_EDIT_STOCKS;break;
					}
					[specsDict setObject:textField.text forKey:key];
				}
				[specs addObject:specsDict];
			}
		}
	} else {
		NSMutableDictionary *specsDict = [[NSMutableDictionary alloc]init];
		[specsDict setObject:GOODS_EDIT_DEFAULT_SPEC forKey:GOODS_EDIT_SPEC];
		[specsDict setObject:_price.text forKey:GOODS_EDIT_PRICE];
		[specsDict setObject:_promote_price.text forKey:GOODS_EDIT_PROMOTE_PRICE];
		[specsDict setObject:_stocks.text forKey:GOODS_EDIT_STOCKS];
		[specs addObject:specsDict];
	}
	if (specs.count) [postData setValue:specs.jsonString forKey:GOODS_EDIT_SPECS];
	
	[ProgressHUD show:@"正在提交，请稍后"];
	[self AJGoodsEditSubmit:postData];
}

- (void)AJGoodsEditSubmit:(NSMutableDictionary*)postData{
	if (_selectImage.uploadComplete) {
		NSMutableArray *images = [[NSMutableArray alloc]init];
		if (_imageUpyun.length) {
			for (int i=0; i<_imageUrls.count; i++) {
				[images addObject:@{GOODS_EDIT_PIC:_imageUrls[i], GOODS_EDIT_PIC_MEMO:_imageMemos[i]}];
			}
			[postData setValue:images.jsonString forKey:GOODS_EDIT_PICS];
			[images removeAllObjects];
			//images 格式 @[@{@"pic":图片网址, @"memo":描述}]
		} else {
			for (int i=0; i<_images.count; i++) {
				[images addObject:@{GOODS_EDIT_PIC:_images[i], GOODS_EDIT_PIC_MEMO:_imageMemos[i]}];
			}
			//images 格式 @[@{@"pic":图片UIImage, @"memo":描述}]
		}
		
		[self AJGoodsEditSubmit:self postData:postData images:images];
		return;
	}
	[self performSelector:@selector(AJGoodsEditSubmit:) withObject:postData afterDelay:1.0];
}

- (NSArray*)AJGoodsEditOptionViews:(AJGoodsEdit *)goodsEdit{
	/* Subclasses should override */
	return nil;
}

- (void)AJGoodsEditSubmit:(AJGoodsEdit *)goodsEdit postData:(NSMutableDictionary*)postData images:(NSArray*)images{
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
