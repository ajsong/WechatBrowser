//
//  AJGoodsContent.m
//
//  Created by ajsong on 2017/3/16.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "AJGoodsConfig.h"
#import "AJGoodsContent.h"

//获取内容: window.getHtml()
//设置内容: window.setHtml('我是内容')
//插入图片: window.insertImage(['又拍云网址1', '又拍云网址2'])
//修改图片: window.updateImage('图片ID', '图片网址', '宽(单位像素)', '高(单位像素)')
//获取指定XY位置的控件的TAG标签: window.getTagsAt(x轴, y轴)
//获取指定XY位置的控件: window.getElementAt(x轴, y轴)

@interface AJGoodsContent ()<WKNavigationDelegate,UIGestureRecognizerDelegate,AJSelectImageDelegate>{
	NSString *_content;
	WKWebView *_webView;
	UIView *_bottomView;
	UITapGestureRecognizer *_tapGesture;
	UILongPressGestureRecognizer *_longPress;
}
@end

@implementation AJGoodsContent

- (instancetype)init{
	self = [super init];
	if (self) {
		_textColor = GOODS_EDIT_TEXT_COLOR;
		_btnColor = GOODS_EDIT_BTN_COLOR;
		_insertImage = YES;
		//_upyunPath = GOODS_EDIT_CONTENT_UPYUN_PATH;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = COLORBACK;
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithImage:[IMG(@"return") overlayWithColor:COLORNAVTEXT] size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeLeft];
	[item addTarget:self action:^(id target, id sender) {
		[_webView evaluateJavaScript:@"window.getHtml()" completionHandler:^(id obj, NSError *error) {
			if (!obj) obj = @"";
			_content = [target changeHtml:obj];
			if (_content.length && ![_content isEqualToString:_html]) {
				[UIAlertController alert:@"是否保存已编辑的内容？" cancel:@"不保存" submit:@"保存" block:^(NSInteger buttonIndex) {
					if (buttonIndex==1) {
						if (_delegate && [_delegate respondsToSelector:@selector(AJGoodsContentWithData:)]) {
							[_delegate AJGoodsContentWithData:@{@"content":_content}];
						}
					}
					[[target navigationController] popViewControllerAnimated:YES];
				}];
			} else {
				[[target navigationController] popViewControllerAnimated:YES];
			}
		}];
	}];
	
	item = [self.navigationItem setItemWithTitle:@"源码" textColor:COLORNAVTEXT fontSize:14 itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:^(id target, id sender) {
		[_webView evaluateJavaScript:@"window.changeDisplay()" completionHandler:^(id obj, NSError *error) {}];
		UIButton *contentBarItem = (UIButton*)sender;
		contentBarItem.selected = !contentBarItem.selected;
	}];
	[item.contentBarItem setTitle:@"图文" forState:UIControlStateSelected];
	
	CGFloat height = 42*SCREEN_SCALE;
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"goods-editor" withExtension:@"html"];
	if (_editorUrl.length) fileURL = [NSURL URLWithString:_editorUrl];
	
	_webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height-height)];
	_webView.backgroundColor = [UIColor clearColor];
	_webView.opaque = NO;
	_webView.scrollView.backgroundColor = [UIColor clearColor];
	_webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	_webView.scrollView.scrollEnabled = NO;
	_webView.navigationDelegate = self;
	[self.view addSubview:_webView];
	//[_webView setKeyboardDisplayRequiresUserAction:NO];
	[_webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
	
	_longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
	_longPress.delegate = self;
	[_webView addGestureRecognizer:_longPress];
	[_tapGesture requireGestureRecognizerToFail:_longPress];
	
	_bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-height, SCREEN_WIDTH, height)];
	[self.view addSubview:_bottomView];
	
	UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:_bottomView.bounds];
	[_bottomView addSubview:toolBar];
	
	CGFloat width = SCREEN_WIDTH;
	CGFloat left = 0;
	
	if (_insertImage) {
		width = SCREEN_WIDTH/2;
		left = width;
		
		AJSelectImage *selectImage = [[AJSelectImage alloc]init];
		selectImage.delegate = self;
		if (_upyunPath.length) selectImage.upyunFolder = _upyunPath;
		if (_qiniuToken.length) selectImage.qiniuToken = _qiniuToken;
		selectImage.maxCount = 9;
		selectImage.progress = ^(NSProgress *progress){
			[ProgressHUD showProgress:progress.totalUnitCount completed:progress.completedUnitCount];
		};
		
		UIImage *ico = IMG(@"goods-edit-content-add");
		ico = [ico fitToSize:CGSizeMake(15*SCREEN_SCALE, 15*SCREEN_SCALE)];
		ico = [ico overlayWithColor:_textColor];
		UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, _bottomView.height)];
		btn.titleLabel.font = FONTBOLD(14);
		btn.backgroundColor = [UIColor clearColor];
		btn.adjustsImageWhenHighlighted = NO;
		[btn setImage:ico forState:UIControlStateNormal];
		[btn setTitle:@"添加图片" forState:UIControlStateNormal];
		[btn setTitleColor:_textColor forState:UIControlStateNormal];
		[btn setStyle:UIButtonStyleLeft offset:3*SCREEN_SCALE];
		[btn addTarget:self action:^(id target, id sender) {
			[selectImage selectImage];
		}];
		[_bottomView addSubview:btn];
		
		UIToolbar *view = [[UIToolbar alloc]initWithFrame:CGRectMake(50*SCREEN_SCALE, _bottomView.top-30*SCREEN_SCALE-10*SCREEN_SCALE, SCREEN_WIDTH-50*SCREEN_SCALE*2, 30*SCREEN_SCALE)];
		view.barStyle = UIBarStyleBlackTranslucent;
		view.layer.masksToBounds = YES;
		view.layer.cornerRadius = 5*SCREEN_SCALE;
		view.alpha = 0;
		[self.view addSubview:view];
		UILabel *label = [[UILabel alloc]initWithFrame:view.bounds];
		label.text = @"长按图片可修改属性";
		label.textColor = COLORWHITE;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(12);
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[UIView animateWithDuration:0.3 animations:^{
					view.alpha = 1;
				} completion:^(BOOL finished) {
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
						dispatch_async(dispatch_get_main_queue(), ^{
							[UIView animateWithDuration:0.3 animations:^{
								view.alpha = 0;
							} completion:^(BOOL finished) {
								[view removeFromSuperview];
							}];
						});
					});
				}];
			});
		});
	}
	
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(left, 0, width, _bottomView.height)];
	btn.titleLabel.font = FONTBOLD(14);
	btn.backgroundColor = _btnColor;
	[btn setTitle:@"完成" forState:UIControlStateNormal];
	[btn setTitleColor:COLORWHITE forState:UIControlStateNormal];
	[btn addTarget:self action:^(id target, id sender) {
		[target saveHtml];
	}];
	[_bottomView addSubview:btn];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
	if (_html.length) {
		NSString *script = [NSString stringWithFormat:@"window.setHtml('%@')", _html];
		[webView evaluateJavaScript:script completionHandler:^(id obj, NSError *error) {}];
	}
	if (_placeholder.length) {
		NSString *script = [NSString stringWithFormat:@"window.setPlaceholder('%@')", _placeholder];
		[webView evaluateJavaScript:script completionHandler:^(id obj, NSError *error) {}];
	}
}

- (void)AJSelectImage:(AJSelectImage *)selectImage didSelectedWithImage:(UIImage *)image uploadComplete:(void (^)(NSString *))complete{
	if (_delegate && [_delegate respondsToSelector:@selector(AJGoodsContentWithImage:uploadComplete:)]) {
		[_delegate AJGoodsContentWithImage:image uploadComplete:^(NSString *url) {
			if (complete) complete(url);
		}];
	}
}

- (void)AJSelectImageDidSelectedImage:(AJSelectImage *)selectImage{
	NSString *imageUrls = FORMAT(@"['%@']", [selectImage.imageUrls implode:@"','"]);
	NSString *script = [NSString stringWithFormat:@"window.insertImage(%@)", imageUrls];
	[_webView evaluateJavaScript:script completionHandler:^(id obj, NSError *error) {}];
}

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer{
	if (recognizer.state != UIGestureRecognizerStateBegan) return;
	CGPoint point = [recognizer locationInView:_webView];
	[self openMenuAt:point];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	return YES;
}

- (void)setPlaceholder:(NSString *)placeholder{
	_placeholder = placeholder;
	NSString *script = [NSString stringWithFormat:@"window.setPlaceholder(%@)", placeholder];
	[_webView evaluateJavaScript:script completionHandler:^(id obj, NSError *error) {}];
}

- (void)openMenuAt:(CGPoint)point{
	NSString *script = [NSString stringWithFormat:@"window.getTagsAt(%f, %f)", point.x, point.y];
	NSLog(@"%@", script);
	[_webView evaluateJavaScript:script completionHandler:^(id obj, NSError *error) {
		if (!obj) obj = @"";
		NSString *tag = obj;
		//图片
		if ([tag indexOf:@",IMG,"] != NSNotFound) {
			[self changeImageAt:point];
		}
		//链接
		if ([tag indexOf:@",A,"] != NSNotFound) {
			/*
			NSString *script = [NSString stringWithFormat:@"window.getElementAtPoint(%f, %f).href", point.x, point.y];
			[_webView evaluateJavaScript:script completionHandler:^(id obj, NSError *error) {
				if (!obj) obj = @"";
				NSString *href = obj;
			}];
			*/
		}
	}];
	
}

- (void)changeImageAt:(CGPoint)point{
	NSString *script = @"(function(point){\
		var imageId = window.getElementAt(point.x, point.y).id,\
		src = window.getElementAt(point.x, point.y).src,\
		width = window.getElementAt(point.x, point.y).width,\
		height = window.getElementAt(point.x, point.y).height;\
		return {imageId:imageId, src:src, width:width, height:height};\
	})({x:%f, y:%f});";
	script = FORMAT(script, point.x, point.y);
	[_webView evaluateJavaScript:script completionHandler:^(id obj, NSError *error) {
		if (!obj) return;
		NSString *imageId = [obj valueForKey:@"imageId"];
		NSString *src = [obj valueForKey:@"src"];
		CGFloat width = [[obj valueForKey:@"width"] floatValue];
		CGFloat height = [[obj valueForKey:@"height"] floatValue];
		
		UIFont *font = FONT(13);
		UIColor *textColor = _textColor;
		
		UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-25*SCREEN_SCALE*2, 0)];
		view.layer.masksToBounds = YES;
		view.layer.cornerRadius = 4*SCREEN_SCALE;
		
		UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:view.bounds];
		toolBar.tag = 10;
		[view addSubview:toolBar];
		
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width, 44*SCREEN_SCALE)];
		label.text = @"修改图片大小";
		label.textColor = textColor;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONTBOLD(14);
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		
		UIView *inputView = [[UIView alloc]initWithFrame:CGRectMake(20*SCREEN_SCALE, label.bottom, view.width-20*SCREEN_SCALE*2, 40*SCREEN_SCALE*2)];
		inputView.backgroundColor = COLORWHITE;
		inputView.clipsToBounds = YES;
		inputView.layer.masksToBounds = YES;
		inputView.layer.cornerRadius = 4*SCREEN_SCALE;
		[view addSubview:inputView];
		
		UIITextField *widthInput = [[UIITextField alloc]initWithFrame:CGRectMake(0, 0, inputView.width, 40*SCREEN_SCALE)];
		widthInput.text = FORMAT(@"%.f", width);
		widthInput.placeholder = @"宽，单位：像素(px)";
		widthInput.textColor = textColor;
		widthInput.textAlignment = NSTextAlignmentCenter;
		widthInput.font = font;
		widthInput.backgroundColor = [UIColor clearColor];
		widthInput.keyboardType = UIKeyboardTypeNumberPad;
		[inputView addSubview:widthInput];
		[widthInput addGeWithType:GeLineTypeBottom color:COLOR_GE_LIGHT];
		
		UIITextField *heightInput = [[UIITextField alloc]initWithFrame:widthInput.frameBottom];
		heightInput.text = FORMAT(@"%.f", height);
		heightInput.placeholder = @"高，单位：像素(px)";
		heightInput.textColor = textColor;
		heightInput.textAlignment = NSTextAlignmentCenter;
		heightInput.font = font;
		heightInput.backgroundColor = [UIColor clearColor];
		heightInput.keyboardType = UIKeyboardTypeNumberPad;
		[inputView addSubview:heightInput];
		
		UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, inputView.bottom+15*SCREEN_SCALE, view.width, 40*SCREEN_SCALE)];
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
			NSString *script = [NSString stringWithFormat:@"window.updateImage('%@', '%@', '%@', '%@')", imageId, src, widthInput.text, heightInput.text];
			[_webView evaluateJavaScript:script completionHandler:^(id obj, NSError *error) {}];
			[KEYWINDOW endEditing:YES];
			[target dismissAlertView];
		}];
		[btnView addSubview:btn];
		
		view.height = btnView.bottom;
		[view viewWithTag:10].frame = view.bounds;
		
		[self presentAlertView:view animation:DYAlertViewDown];
	}];
}

- (void)saveHtml{
	[_webView evaluateJavaScript:@"window.getHtml()" completionHandler:^(id obj, NSError *error) {
		if (!obj) obj = @"";
		NSString *html = obj;
		if (!html.length) {
			[ProgressHUD showError:@"请输入内容"];
			return;
		}
		_content = [self changeHtml:html];
		//NSLog(@"%@", _content);
		
		if (_delegate && [_delegate respondsToSelector:@selector(AJGoodsContentWithData:)]) {
			[_delegate AJGoodsContentWithData:@{@"content":_content}];
		}
		[self.navigationController popViewControllerAnimated:YES];
	}];
}

//对提交内容进行后期处理
- (NSString *)changeHtml:(NSString *)html{
	if ([html isEqualToString:@"<br>"]) html = @"";
	return html;
}

- (void)deallocd{
	_tapGesture.delegate = nil;
	_longPress.delegate = nil;
	_webView.navigationDelegate = nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) {
		self.view = nil;
	}
}

@end
