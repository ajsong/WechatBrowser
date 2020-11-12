//
//  Group+Extend.m
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#pragma mark - UIWindow+Extend
@implementation UIWindow (GlobalExtend)
- (UIViewController*)currentController{
	UIViewController *controller = [self _currentController:[[UIApplication sharedApplication].keyWindow rootViewController]];
	while (controller.presentedViewController) {
		controller = [self _currentController:controller.presentedViewController];
	}
	return controller;
}
- (UIViewController*)_currentController:(UIViewController*)controller{
	if ([controller isKindOfClass:[UINavigationController class]]) {
		return [self _currentController:[(UINavigationController*)controller topViewController]];
	} else if ([controller isKindOfClass:[UITabBarController class]]) {
		return [self _currentController:[(UITabBarController*)controller selectedViewController]];
	} else if ([controller isKindOfClass:[KKTabBarController class]]) {
		return [self _currentController:[(KKTabBarController*)controller selectedViewController]];
	} else {
		return controller;
	}
	return nil;
}
- (UIView*)statusBar{
	UIView *statusBar = nil;
	NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
	NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	id object = [UIApplication sharedApplication];
	if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
	return statusBar;
}
- (CGFloat)statusBarHeight{
	return [UIApplication sharedApplication].statusBarFrame.size.height;
}
@end


#pragma mark - UINavigationController+UITabBarController+Extend
@implementation UINavigationController (GlobalExtend)
- (void)setBackgroundColor:(UIColor *)bgcolor textColor:(UIColor *)textcolor{
	if (!self.viewControllers.count) return;
	self.navigationBar.translucent = NO;
	if (!IOS6) {
		self.navigationBar.barTintColor = bgcolor;
		self.navigationBar.tintColor = textcolor; //按钮文字
		self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:textcolor}; //中间文字
		if (CGColorEqualToColor(bgcolor.CGColor, COLORWHITE.CGColor)) [self setUnderLineColor:COLOR_GE_LIGHT];
	} else {
		self.navigationBar.tintColor = bgcolor;
	}
	if (NAVBAR_HIDDEN_UNDERLINE) {
		BOOL isWhiteColor = NO;
		CGFloat r, g, b, a;
		if ([bgcolor getRed:&r green:&g blue:&b alpha:&a]) isWhiteColor = (r==1 && g==1 && b==1 && a==1);
		if (!isWhiteColor) {
			[self setHiddenUnderLine:YES];
		}
	}
}
- (void)setUnderLineColor:(UIColor *)color{
	UIImageView *line = [self getUnderLine:self.navigationBar];
	if (line) {
		UIView *view = [[UIView alloc]initWithFrame:line.bounds];
		view.backgroundColor = color;
		view.tag = 753829;
		[line addSubview:view];
	}
}
- (void)deleteUnderLine{
	UIImageView *line = [self getUnderLine:self.navigationBar];
	if (line) {
		[[line viewWithTag:753829] removeFromSuperview];
	}
}
- (void)setHiddenUnderLine:(BOOL)hiddenUnderLine{
	UIImageView *line = [self getUnderLine:self.navigationBar];
	if (line) line.hidden = hiddenUnderLine;
}
- (UIImageView*)getUnderLine:(UIView*)view{
	if ([view isKindOfClass:[UIImageView class]] && view.bounds.size.height<=1.0*SCREEN_SCALE) {
		return (UIImageView*)view;
	}
	for (UIView *subview in view.subviews) {
		UIImageView *imageView = [self getUnderLine:subview];
		if (imageView) {
			return imageView;
			break;
		}
	}
	return nil;
}
//滑动隐藏
- (void)autoHidden{
	self.hidesBarsOnSwipe = YES;
}
- (BOOL)shouldAutorotate {
	return [[self.viewControllers lastObject] shouldAutorotate];
}
- (NSUInteger)supportedInterfaceOrientations {
	return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion{
	if (!viewController) return;
	if ([self isKindOfClass:[KKNavigationController class]]) {
		[(KKNavigationController*)self pushViewController:viewController animated:animated completion:completion];
		return;
	}
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion();
			});
		});
	}
	[self pushViewController:viewController animated:animated];
}
- (UIViewController*)popViewControllerAnimated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion{
	if ([self isKindOfClass:[KKNavigationController class]]) {
		return [(KKNavigationController*)self popViewControllerAnimated:animated completion:completion];
	}
	UIViewController *viewController = [self popViewControllerAnimated:animated];
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(viewController);
			});
		});
	}
	return viewController;
}
- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion{
	if ([self isKindOfClass:[KKNavigationController class]]) {
		return [(KKNavigationController*)self popToRootViewControllerAnimated:animated completion:completion];
	}
	NSArray *viewControllers = [self popToRootViewControllerAnimated:animated];
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(viewControllers);
			});
		});
	}
	return viewControllers;
}
- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion{
	if (!viewController) return nil;
	if ([self isKindOfClass:[KKNavigationController class]]) {
		return [(KKNavigationController*)self popToViewController:viewController animated:animated completion:completion];
	}
	NSArray *viewControllers = [self popToViewController:viewController animated:animated];
	for (UIViewController *controller in viewControllers) {
		if (controller) {
			if ([controller respondsToSelector:NSSelectorFromString(@"deallocd")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[controller performSelector:NSSelectorFromString(@"deallocd")];
#pragma clang diagnostic pop
			}
		}
	}
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(viewControllers);
			});
		});
	}
	return viewControllers;
}
- (UIViewController*)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated{
	return [self popToViewControllerOfClass:cls animated:animated completion:nil];
}
- (UIViewController*)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion{
	if (!cls) return nil;
	if ([self isKindOfClass:[KKNavigationController class]]) {
		return [(KKNavigationController*)self popToViewControllerOfClass:cls animated:animated completion:completion];
	}
	UIViewController *viewController = nil;
	for (NSInteger i=self.viewControllers.count-2; i>=0; i--) {
		if ([self.viewControllers[i] isKindOfClass:cls]) {
			UIViewController *controller = self.viewControllers[i];
			viewController = controller;
			NSArray *viewControllers = [self popToViewController:controller animated:animated];
			for (UIViewController *controller in viewControllers) {
				if (controller) {
					if ([controller respondsToSelector:NSSelectorFromString(@"deallocd")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
						[controller performSelector:NSSelectorFromString(@"deallocd")];
#pragma clang diagnostic pop
					}
				}
			}
			break;
		}
	}
	if (!viewController) viewController = [[self popToRootViewControllerAnimated:animated] firstObject];
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(viewController);
			});
		});
	}
	return viewController;
}
- (void)setViewControllersArray:(NSArray *)controllersArray animated:(BOOL)animated{
	NSMutableArray *objs = [[NSMutableArray alloc]init];
	for (int i=0; i<controllersArray.count; i++) {
		if ([controllersArray[i] isKindOfClass:[NSString class]]) {
			id e = [[NSClassFromString(controllersArray[i]) alloc]init];
			[objs addObject:e];
		} else if ([controllersArray[i] isKindOfClass:[UIViewController class]]) {
			[objs addObject:controllersArray[i]];
		} else if ([controllersArray[i] isKindOfClass:[NSDictionary class]]) {
			NSMutableDictionary *obj = [NSMutableDictionary dictionaryWithDictionary:controllersArray[i]];
			id e = [[NSClassFromString(obj[@"class"]) alloc]init];
			[obj removeObjectForKey:@"class"];
			for (NSString *key in obj) {
				[e setValue:obj[key] forKey:key];
			}
			[objs addObject:e];
		}
	}
	[self setViewControllers:objs animated:animated];
}
- (BOOL)hasControllerOfClass:(Class)cls{
	BOOL had = NO;
	for (UIViewController *controller in self.viewControllers) {
		if ([controller isKindOfClass:cls]) {
			had = YES;
			break;
		}
	}
	return had;
}
@end
@implementation UITabBarController (GlobalExtend)
- (BOOL)shouldAutorotate {
	return [[self.viewControllers lastObject] shouldAutorotate];
}
- (NSUInteger)supportedInterfaceOrientations {
	return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
@end


#pragma mark - UIAlertController+Extend
@implementation UIAlertController (GlobalExtend)
+ (void)alert:(NSString*)message{
	[UIAlertController alert:message block:nil];
}
+ (void)alert:(NSString*)message block:(void(^)(NSInteger buttonIndex))block{
	[UIAlertController alert:message cancel:nil submit:@"确定" block:block];
}
+ (void)alert:(NSString*)message submit:(NSString*)submit block:(void(^)(NSInteger buttonIndex))block{
	[UIAlertController alert:message cancel:@"取消" submit:submit block:block];
}
+ (void)alert:(NSString*)message cancel:(NSString*)cancel submit:(NSString*)submit block:(void(^)(NSInteger buttonIndex))block{
	[UIAlertController alert:@"" message:message cancel:cancel submit:submit block:block];
}
+ (void)alert:(NSString*)title message:(NSString*)message cancel:(NSString*)cancel submit:(NSString*)submit block:(void(^)(NSInteger buttonIndex))block{
	NSString *cancelButtonTitle = nil;
	//if (block) cancelButtonTitle = cancel.length ? cancel : @"取消";
	if (cancel.length) cancelButtonTitle = cancel;
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *action = [UIAlertAction actionWithTitle:submit style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		if (block) block(1);
	}];
	[alertController addAction:action];
	if (cancelButtonTitle.length) {
		action = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
			if (block) block(0);
		}];
		[alertController addAction:action];
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		[APPCurrentController presentViewController:alertController animated:YES completion:nil];
	});
}
+ (void)action:(NSString*)message buttons:(NSArray*)buttons block:(void(^)(NSInteger buttonIndex))block{
	[UIAlertController action:message buttons:buttons cancel:@"取消" block:block];
}
+ (void)action:(NSString*)message buttons:(NSArray*)buttons cancel:(NSString*)cancel block:(void(^)(NSInteger buttonIndex))block{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
	for (NSInteger i=0; i<buttons.count; i++) {
		UIAlertAction *action = [UIAlertAction actionWithTitle:buttons[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			if (block) block(i);
		}];
		[alertController addAction:action];
	}
	UIAlertAction *action = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
		if (block) block(buttons.count);
	}];
	[alertController addAction:action];
	dispatch_async(dispatch_get_main_queue(), ^{
		[APPCurrentController presentViewController:alertController animated:YES completion:nil];
	});
}
@end


#pragma mark - UIITextField
@implementation UIITextField
- (void)setPlaceholderColor:(UIColor *)placeholderColor{
	_placeholderColor = placeholderColor;
	[self setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont{
	_placeholderFont = placeholderFont;
	[self setValue:placeholderFont forKeyPath:@"_placeholderLabel.font"];
}

- (void)setPadding:(UIEdgeInsets)padding{
	self.element[@"isPadding"] = @YES;
	_padding = padding;
	[self setNeedsDisplay];
}

//根据设定的键盘类型来自动设置相关限制
- (void)setKeyboardType:(UIKeyboardType)keyboardType{
	[super setKeyboardType:keyboardType];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			switch (keyboardType) {
				case UIKeyboardTypePhonePad:{
					//禁止空格
					[self addTarget:self action:@selector(textFieldDidChangeForPhone:) forControlEvents:UIControlEventEditingChanged];
					if (_maxLength>0) return;
					[self setMaxLength:11];
					break;
				}
				case UIKeyboardTypeDecimalPad:{
					if (_decimalNum>0) return;
					[self setDecimalNum:2]; //默认限制两位小数
					break;
				}
				case UIKeyboardTypeNumberPad:{
					[self addTarget:self action:@selector(textFieldDidChangeForNumberPad:) forControlEvents:UIControlEventEditingChanged];
					break;
				}
				default:{
					break;
				}
			}
		});
	});
}

- (void)textFieldDidChangeForPhone:(UITextField *)textField{
	if (!textField.text.length) return;
	NSString *string = [[textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
	textField.text = string;
}

- (void)setSeparateLength:(NSInteger)separateLength{
	[self setSeparateLength:separateLength separator:@" "];
}
- (void)setSeparateLength:(NSInteger)separateLength separator:(NSString*)separator{
	_separateLength = separateLength;
	self.element[@"separator"] = separator;
	if (!separateLength) return;
	[self addTarget:self action:@selector(textFieldDidChangeForSeparateLength:) forControlEvents:UIControlEventEditingChanged];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			[self textFieldDidChangeForSeparateLength:self];
		});
	});
}
- (void)textFieldDidChangeForSeparateLength:(UITextField *)textField{
	if (!textField.text.length) return;
	NSString *separator = textField.element[@"separator"];
	NSString *string = [textField.text stringByReplacingOccurrencesOfString:separator withString:@""];
	NSInteger size = (string.length / _separateLength);
	NSMutableArray *arr = [[NSMutableArray alloc]init];
	for (int n=0; n<size; n++) {
		[arr addObject:[string substringWithRange:NSMakeRange(n*_separateLength, _separateLength)]];
	}
	[arr addObject:[string substringWithRange:NSMakeRange(size*_separateLength, (string.length % _separateLength))]];
	string = [arr componentsJoinedByString:separator];
	string = [string trim:separator];
	textField.text = string;
}

//限制字符长度
- (void)setMaxLength:(NSInteger)maxLength{
	_maxLength = maxLength;
	[self addTarget:self action:@selector(textFieldDidChangeForMaxLength:) forControlEvents:UIControlEventEditingChanged];
}
- (void)textFieldDidChangeForMaxLength:(UITextField *)textField{
	if (!textField.text.length) return;
	NSString *string = textField.text;
	if (string.length > _maxLength) textField.text = [string substringToIndex:_maxLength];
}

//小数位数限制
- (void)setDecimalNum:(NSInteger)decimalNum{
	_decimalNum = decimalNum;
	[self addTarget:self action:@selector(textFieldDidChangeForDecimalNum:) forControlEvents:UIControlEventEditingChanged];
}
- (void)textFieldDidChangeForDecimalNum:(UITextField *)textField{
	if (!textField.text.length) return;
	NSString *string = textField.text;
	if (![string preg_test:@"^[0-9\\.]+$"]) {
		textField.text = [string substringToIndex:string.length-1];
		return;
	}
	if (string.length) {
		//首字符
		if ([[string substringToIndex:1] isEqualToString:@"."]) {
			textField.text = @"";
			return;
		}
		//只能一个小数点
		if ([string countStrings:@"."]>1) {
			textField.text = [string substringToIndex:string.length-1];
			return;
		}
		//判断当前输入的字符与之前的小数点相隔的位数
		NSInteger index = [string indexOf:@"."];
		if (index!=NSNotFound) {
			if (string.length-1-index > _decimalNum) textField.text = [string substringToIndex:index+1+_decimalNum];
		}
	}
}

- (void)textFieldDidChangeForNumberPad:(UITextField *)textField{
	if (!textField.text.length) return;
	NSString *string = textField.text;
	if (![string preg_test:@"^[0-9]+$"]) textField.text = [string substringToIndex:string.length-1];
}

//允许输入的内容
- (void)setAllowContent:(NSString *)allowContent{
	_allowContent = allowContent;
	[self addTarget:self action:@selector(textFieldDidChangeForAllowContent:) forControlEvents:UIControlEventEditingChanged];
}
- (void)textFieldDidChangeForAllowContent:(UITextField *)textField{
	if (!textField.text.length) return;
	NSString *string = textField.text;
	if (![string preg_test:_allowContent]) {
		textField.text = [string substringToIndex:string.length-1];
		[self textFieldDidChangeForAllowContent:textField];
	}
}

//禁止粘贴
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
	if (action == @selector(paste:) && _disablePaste) return NO; //粘贴
	//if (action == @selector(select:)) return NO; //选择
	//if (action == @selector(selectAll:)) return NO; //全选
	return [super canPerformAction:action withSender:sender];
	//设置长按菜单不显示
	//UIMenuController *menuController = [UIMenuController sharedMenuController];
	//if (menuController) [UIMenuController sharedMenuController].menuVisible = NO;
}

- (CGRect)textForBounds:(CGRect)rect{
	if ([self.element[@"isPadding"] boolValue]) {
		return CGRectMake(rect.origin.x + _padding.left,
						  rect.origin.y + _padding.top,
						  rect.size.width - _padding.right,
						  rect.size.height - _padding.bottom);
	}
	return rect;
}

- (CGRect)textRectForBounds:(CGRect)rect{
	rect = [super textRectForBounds:rect];
	return [self textForBounds:rect];
}

- (CGRect)editingRectForBounds:(CGRect)rect{
	rect = [super editingRectForBounds:rect];
	return [self textForBounds:rect];
}

//- (void)_drawRect:(CGRect)rect{
//	[self _drawRect:rect];
//}

- (void)setSecureTextEntry:(BOOL)secureTextEntry{
	self.element[@"isSecureTextEntry"] = @YES;
	self.element[@"secureTextEntry"] = @(secureTextEntry);
	[self performSelector:@selector(NotificationSecureTextEntry) withObject:nil afterDelay:0];
}

- (void)NotificationSecureTextEntry{
	__weak UITextField *_self = self;
	self.element[@"beginEditingObserver"] = [[NSNotificationCenter defaultCenter]
											 addObserverForName:UITextFieldTextDidBeginEditingNotification
											 object:nil
											 queue:nil
											 usingBlock:^(NSNotification *note) {
												 if (_self == note.object && _self.isSecureTextEntry) {
													 if (_self.clearsOnBeginEditing) {
														 _self.text = @"";
													 } else {
														 _self.text = _self.element[@"string"];
													 }
												 }
											 }];
	self.element[@"endEditingObserver"] = [[NSNotificationCenter defaultCenter]
										   addObserverForName:UITextFieldTextDidEndEditingNotification
										   object:nil
										   queue:nil
										   usingBlock:^(NSNotification *note) {
											   if (_self == note.object) {
												   _self.element[@"string"] = _self.text;
											   }
										   }];
	BOOL isFirstResponder = self.isFirstResponder;
	[self resignFirstResponder];
	[super setSecureTextEntry:[self.element[@"secureTextEntry"] boolValue]];
	if (isFirstResponder) {
		[self becomeFirstResponder];
	}
}

- (void)dealloc{
	self.delegate = nil;
	if (!self.element[@"isSecureTextEntry"]) return;
	[[NSNotificationCenter defaultCenter] removeObserver:self.element[@"beginEditingObserver"]];
	[[NSNotificationCenter defaultCenter] removeObserver:self.element[@"endEditingObserver"]];
	self.removeElement = @"beginEditingObserver";
	self.removeElement = @"endEditingObserver";
}
@end


#pragma mark - UIITextView
//插入图片用
@implementation IIAttachment
@end
@implementation NSAttributedString (InsetImage)
- (NSString*)code{
	NSMutableString *plainString = [NSMutableString stringWithString:self.string];
	__block NSUInteger base = 0;
	[self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
		if (value && [value isKindOfClass:[IIAttachment class]]) {
			[plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withString:((IIAttachment*)value).imageTag];
			base += ((IIAttachment*)value).imageTag.length - 1;
		}
	}];
	return plainString;
}
@end
@implementation UIITextView
- (void)setText:(NSString*)text{
	[super setText:text];
	[self performSelector:@selector(placeholderCheckText) withObject:nil afterDelay:0];
}
- (void)setFont:(UIFont*)font{
	[super setFont:font];
	if (!self.element[@"originFont"]) self.element[@"originFont"] = font;
}

- (NSString *)placeholder{
	return self.element[@"placeholder"];
}
- (void)setPlaceholder:(NSString *)placeholder{
	if (!placeholder.length) return;
	self.element[@"placeholder"] = placeholder;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			self.label.text = placeholder;
			[self setPlaceholderFrame];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeValue:) name:UITextViewTextDidChangeNotification object:nil];
		});
	});
}

- (UILabel *)label{
	UILabel *label = self.element[@"placeholderLabel"];
	if (!label) {
		BOOL _isPadding = [self.element[@"isPadding"] boolValue];
		if (!_isPadding) self.textContainerInset = UIEdgeInsetsMake(0, -5*SCREEN_SCALE, 0, 0);
		label = [[UILabel alloc]init];
		label.textColor = [UIColor colorWithRed:199/255.f green:199/255.f blue:199/255.f alpha:1.f];
		label.font = self.font ? self.font : FONT(12);
		label.numberOfLines = 0;
		[self addSubview:label];
		self.element[@"placeholderLabel"] = label;
	}
	return label;
}
- (void)setPlaceholderFrame{
	UIEdgeInsets edgeInsets = self.textContainerInset;
	NSDictionary *attributes = @{NSFontAttributeName:self.label.font};
	NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
	CGRect rect = [self.placeholder boundingRectWithSize:CGSizeMake(self.frame.size.width-edgeInsets.left-5*SCREEN_SCALE-edgeInsets.right, MAXFLOAT) options:options attributes:attributes context:NULL];
	CGRect frame = CGRectMake(edgeInsets.left+5*SCREEN_SCALE, edgeInsets.top, rect.size.width, rect.size.height);
	self.label.frame = frame;
}

- (UIColor *)placeholderColor{
	return self.element[@"placeholderColor"];
}
- (void)setPlaceholderColor:(UIColor *)placeholderColor{
	self.element[@"placeholderColor"] = placeholderColor;
	self.label.textColor = placeholderColor;
}

- (UIFont *)placeholderFont{
	return self.element[@"placeholderFont"];
}
- (void)setPlaceholderFont:(UIFont *)placeholderFont{
	self.element[@"placeholderFont"] = placeholderFont;
	self.label.font = placeholderFont;
}

- (BOOL)placeholderHidden{
	return [self.element[@"placeholderHidden"] boolValue];
}
- (void)setPlaceholderHidden:(BOOL)placeholderHidden{
	self.element[@"placeholderHidden"] = @(placeholderHidden);
	self.label.hidden = placeholderHidden;
}

- (UIEdgeInsets)padding{
	return self.textContainerInset;
}
- (void)setPadding:(UIEdgeInsets)padding{
	self.element[@"isPadding"] = @YES;
	self.textContainerInset = padding;
}

- (void)placeholderCheckText{
	if (!self.placeholder.length) return;
	NSString *text = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([self.element[@"insertImage"] boolValue]) text = self.code;
	if (text.length) {
		self.label.hidden = YES;
	} else {
		self.label.hidden = NO;
	}
}

- (CGFloat)lineHeight{
	return [self.element[@"lineHeight"] floatValue];
}
- (void)setLineHeight:(CGFloat)lineHeight{
	self.element[@"lineHeight"] = @(lineHeight);
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
	style.lineSpacing = lineHeight;
	NSDictionary *attributes = @{NSFontAttributeName:self.font, NSParagraphStyleAttributeName:style};
	self.attributedText = [[NSAttributedString alloc]initWithString:self.text attributes:attributes];
}

- (NSInteger)numberOfLines{
	return [self.element[@"numberOfLines"] integerValue];
}
- (void)setNumberOfLines:(NSInteger)numberOfLines{
	self.element[@"isNumberOfLines"] = @YES;
	self.element[@"numberOfLines"] = @(numberOfLines);
	if (![self.element[@"isChangeNotification"] boolValue]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeText:) name:UITextViewTextDidChangeNotification object:self];
	}
	self.element[@"isChangeNotification"] = @YES;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			self.layoutManager.allowsNonContiguousLayout = NO;
			CGRect frame = self.frame;
			UIEdgeInsets textContainerInset = self.textContainerInset;
			textContainerInset.top = (frame.size.height - self.font.lineHeight) / 2;
			textContainerInset.bottom = textContainerInset.top;
			self.padding = textContainerInset;
			self.element[@"minHeight"] = @(frame.size.height);
			self.element[@"maxHeight"] = @(self.font.lineHeight * numberOfLines);
		});
	});
}

- (NSInteger)maxlength{
	return [self.element[@"maxlength"] integerValue];
}
- (void)setMaxlength:(NSInteger)maxlength{
	self.element[@"isMaxlength"] = @YES;
	self.element[@"maxlength"] = @(maxlength);
	if (![self.element[@"isChangeNotification"] boolValue]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeText:) name:UITextViewTextDidChangeNotification object:self];
	}
	self.element[@"isChangeNotification"] = @YES;
}

- (void)didChangeValue:(NSNotification *)notification{
	if (!self.placeholder.length) {
		self.label.hidden = YES;
	} else {
		self.label.hidden = (self.text.length!=0);
		self.element[@"placeholderHidden"] = @(self.label.hidden);
	}
}

//禁止粘贴
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
	if (action == @selector(paste:) && _disablePaste) return NO; //粘贴
	return [super canPerformAction:action withSender:sender];
}

//textView参数为空即不调用delegate
- (void)textViewDidChangeText:(UITextView*)textView{
	[self placeholderCheckText];
	if (self.numberOfLines) {
		//UIEdgeInsets textContainerInset = textView.textContainerInset;
		CGFloat minHeight = [self.element[@"minHeight"] floatValue];
		CGFloat maxHeight = [self.element[@"maxHeight"] floatValue];
		CGRect frame = self.frame;
		CGSize size = [self sizeThatFits:CGSizeMake(frame.size.width, MAXFLOAT)];
		if (size.height>minHeight) {
			if (size.height>=maxHeight){
				size.height = maxHeight;
				self.scrollEnabled = YES;
			} else {
				self.scrollEnabled = NO;
			}
		}
		frame.size.height = size.height;
		self.frame = frame;
		[self scrollRangeToVisible:NSMakeRange(self.text.length, 1)];
		/*//
		CGRect r = [textView caretRectForPosition:textView.selectedTextRange.end];
		CGFloat caretY =  MAX(r.origin.y - textView.frame.size.height + r.size.height + 8, 0);
		if (textView.contentOffset.y < caretY && r.origin.y != INFINITY) {
			textView.contentOffset = CGPointMake(0, caretY);
		}
		//*/

		if (self.delegate && [self.delegate respondsToSelector:@selector(textView:currentHeight:)]) {
			[(id<UIITextViewDelegate>)self.delegate textView:self currentHeight:frame.size.height];
		}

		/*//
		NSString *text = textView.text;
		if (_insertImage) text = [self.code preg_replace:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]" to:@"　"];
		NSDictionary *attributes = @{NSFontAttributeName:self.font};
		NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		CGRect rect = [text boundingRectWithSize:CGSizeMake(frame.size.width-textContainerInset.left-textContainerInset.right, MAXFLOAT) options:options attributes:attributes context:NULL];
		if (rect.size.height <= _minHeight - textContainerInset.top - textContainerInset.bottom) {
			frame.size.height = _minHeight;
		} else {
			if (rect.size.height < _maxHeight) {
				frame.size.height = rect.size.height + textContainerInset.top + textContainerInset.bottom;
			} else {
				frame.size.height = _maxHeight + textContainerInset.top + textContainerInset.bottom;
			}
		}
		if (frame.size.height != self.frame.size.height) {
			self.frame = frame;
			if (textView && self.delegate && [self.delegate respondsToSelector:@selector(textView:currentHeight:)]) {
				[(id<UIITextViewDelegate>)self.delegate textView:self currentHeight:frame.size.height];
			}
		}
		[self scrollRangeToVisible:NSMakeRange(text.length, 1)];
		//*/
	}
	if (self.maxlength) {
		if (self.text.length > self.maxlength) {
			self.text = [self.text substringToIndex:self.maxlength];
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(textView:currentLength:)]) {
			[(id<UIITextViewDelegate>)self.delegate textView:self currentLength:self.text.length];
		}
	}
}

//插入图片, image:图片, imageMark:图片标识
- (void)insertImage:(UIImage*)image imageMark:(NSString*)imageMark{
	[self insertImage:image imageMark:imageMark imageWidth:0 imageHeight:0];
}
- (void)insertImage:(UIImage*)image imageMark:(NSString*)imageMark imageWidth:(CGFloat)width imageHeight:(CGFloat)height{
	self.element[@"insertImage"] = @YES;
	self.font = self.element[@"originFont"];
	if (!width || !height) {
		width = self.font.lineHeight + 2*SCREEN_SCALE;
		height = width;
	}
	UIImage *newImage = [self imageChangeSize:image size:CGSizeMake(width, height)];
	IIAttachment *attachment = [[IIAttachment alloc]init];
	attachment.imageTag = imageMark;
	attachment.image = newImage;
	attachment.bounds = CGRectMake(0, -4*SCREEN_SCALE, newImage.size.width, newImage.size.height);
	//Insert image
	//[self.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment] atIndex:self.selectedRange.location];
	//Replace image
	[self.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
	self.selectedRange = NSMakeRange(self.selectedRange.location+1, 0);
	self.font = self.element[@"originFont"];
	NSRange range = NSMakeRange(0, self.textStorage.length);
	[self.textStorage removeAttribute:NSFontAttributeName range:range];
	[self.textStorage addAttribute:NSFontAttributeName value:self.font range:range];
	[self textViewDidChangeText:self];
}
- (UIImage*)imageChangeSize:(UIImage*)image size:(CGSize)size{
	if (!image) return nil;
	//UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, [UIScreen mainScreen].scale);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

//获取文字, 包括图片标识
- (NSString*)code{
	return [self.textStorage code];
}

- (void)dealloc{
	self.delegate = nil;
	if (![self.element[@"placeholder"] length] && ![self.element[@"isNumberOfLines"] boolValue]) return;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
	if ([self.element[@"placeholder"] length]) [self.label removeFromSuperview];
}
@end


#pragma mark - UIITableView
@interface UIITableView ()<UITableViewDelegate,UITableViewDataSource>
@end
@implementation UIITableView
- (instancetype)init{
	self = [super init];
	if (self) {
		_cellStyle = UITableViewCellStyleDefault;
		[self performSelector:@selector(setDelegate:) withObject:self afterDelay:0];
		[self performSelector:@selector(setDataSource:) withObject:self afterDelay:0];
	}
	return self;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return _numberOfSectionsInTableView(tableView);
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return _numberOfRowsInSection(tableView, section);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return _heightForRowAtIndexPath(tableView, indexPath);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	//NSInteger section = indexPath.section;
	//NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:_cellStyle reuseIdentifier:CellIdentifier];
	}
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	if (_cellForRowAtIndexPath) _cellForRowAtIndexPath(tableView, indexPath, cell);
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (_didSelectRowAtIndexPath) _didSelectRowAtIndexPath(tableView, indexPath);
}
@end


#pragma mark - UISearchBar+Extend
@implementation UISearchBar (GlobalExtend)
- (UITextField*)textField{
	return [self valueForKey:@"_searchField"];
}
- (UIColor*)textColor{
	return self.textField.textColor;
}
- (void)setTextColor:(UIColor *)textColor{
	self.textField.textColor = textColor;
}
- (UIFont*)font{
	return self.textField.font;
}
- (void)setFont:(UIFont *)font{
	self.textField.font = font;
}
- (UIColor*)placeholderColor{
	return [self.textField valueForKeyPath:@"_placeholderLabel.textColor"];
}
- (void)setPlaceholderColor:(UIColor *)placeholderColor{
	[self.textField setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
}
@end


#pragma mark - UIScrollView+Extend
@implementation UIView (FitXTabBarRegion)
- (void)fitX_willMoveToSuperview:(UIView *)newSuperview{
	[self fitX_willMoveToSuperview:newSuperview];
	if (![self isKindOfClass:[UIScrollView class]]) return;
	if ([NSStringFromClass([self class]) isEqualToString: @"WKScrollView"]) return;
	UIScrollView *scrollView = (UIScrollView*)self;
	if (!scrollView || [scrollView.element[@"contentInsetFitX"]boolValue]) return;
	if (scrollView.frame.size.height>630 || scrollView.bottom>=SCREEN_HEIGHT) {
		if (@available(iOS 11.0, *)) {
			UIEdgeInsets contentInset = scrollView.contentInset;
			CGFloat fit = scrollView.contentInsetAdjustmentBehavior == UIScrollViewContentInsetAdjustmentNever ? 0 : -34;
			contentInset.bottom += fit;
			scrollView.element[@"contentInsetFitX"] = @YES;
			scrollView.contentInset = contentInset;
		}
	}
}
@end
@implementation UIScrollView (FitXTabBarRegion)
+ (void)load{
	if (!isX) return;
	[self exchangeMethod:@selector(setContentInset:) withNewMethod:@selector(fitX_setContentInset:)];
	[self exchangeMethod:@selector(willMoveToSuperview:) withNewMethod:@selector(fitX_willMoveToSuperview:)];
}
- (void)fitX_setContentInset:(UIEdgeInsets)contentInset{
	if (self.frame.size.height>630 || self.bottom>=SCREEN_HEIGHT) {
		if (@available(iOS 11.0, *)) {
			if (![self.element[@"contentInsetFitX"]boolValue]) {
				CGFloat fit = self.contentInsetAdjustmentBehavior == UIScrollViewContentInsetAdjustmentNever ? 0 : -34;
				contentInset.bottom += fit;
			}
		}
		self.element[@"contentInsetFitX"] = @YES;
		self.scrollIndicatorInsets = contentInset;
	}
	[self fitX_setContentInset:contentInset];
}
@end
@interface UIScrollView ()<UIScrollViewDelegate>
@end
@implementation UIScrollView (GlobalExtend)
- (void)doubleZoomWithView:(UIView*)zoomView dataHeight:(CGFloat)dataHeight maxHeight:(CGFloat)maxHeight scrollViewDidZoom:(void (^)(UIScrollView *scrollView, CGFloat scale))scrollViewDidZoom{
	if (!zoomView) return;
	self.element[@"zoomView"] = zoomView;
	self.element[@"zoomViewHeight"] = @(zoomView.height);
	self.element[@"dataHeight"] = @(dataHeight);
	self.element[@"scrollViewDidZoom"] = scrollViewDidZoom;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
	self.decelerationRate = UIScrollViewDecelerationRateFast;
	self.bouncesZoom = NO;
	self.delegate = self;
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTap.numberOfTapsRequired = 2;
	[self addGestureRecognizer:doubleTap];
	CGFloat height = zoomView.height;
	CGFloat minScale = 1.0;
	CGFloat maxScale = maxHeight / height;
	self.minimumZoomScale = minScale;
	self.maximumZoomScale = maxScale;
	self.zoomScale = minScale;
	self.contentSize = self.frame.size;
}
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer{
	CGPoint touchPoint = [recognizer locationInView:self];
	if (self.zoomScale == self.maximumZoomScale) {
		[self setZoomScale:self.minimumZoomScale animated:YES];
	} else {
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
	}
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return self.element[@"zoomView"];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
	UIView *zoomView = self.element[@"zoomView"];
	CGFloat zoomViewHeight = [self.element[@"zoomViewHeight"] floatValue];
	CGFloat dataHeight = [self.element[@"dataHeight"] floatValue];
	void (^scrollViewDidZoom)(UIScrollView *scrollView, CGFloat scale) = self.element[@"scrollViewDidZoom"];
	CGPoint centerPoint = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
	if (zoomView.frame.size.width <= self.frame.size.width) centerPoint.x = self.frame.size.width / 2; //水平居中
	if (zoomView.frame.size.height <= self.frame.size.height) centerPoint.y = self.frame.size.height / 2; //垂直居中
	zoomView.center = centerPoint;
	if (self.zoomScale < 1) return;
	CGFloat scale = zoomViewHeight / dataHeight * self.zoomScale;
	if (scrollViewDidZoom) scrollViewDidZoom(self, scale);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	if ([self.viewController respondsToSelector:NSSelectorFromString(@"scrollViewDidZoom:")]) {
		[self.viewController performSelector:NSSelectorFromString(@"scrollViewDidZoom:") withObject:self];
	}
#pragma clang diagnostic pop
}
@end


#pragma mark - AJLaunchImage
#define LAUNCHIMAGE_SHOWTIME 5 //倒数时间
@interface AJLaunchImage (){
	UIView *_bottomView;
	UIImageView *_icoView;
	UILabel *_nameLabel;
	UILabel *_sloganLabel;
	NSTimer *_countTimer;
	int _time;
	int _count;
}
@end
@implementation AJLaunchImage
- (instancetype)init{
	self = [super init];
	if (self) {
		self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
		[self setup];
	}
	return self;
}
- (void)setup{
	self.backgroundColor = [UIColor whiteColor];

	//广告图片
	_imageView = [[UIImageView alloc]initWithFrame:self.bounds];
	_imageView.clipsToBounds = YES;
	_imageView.contentMode = UIViewContentModeScaleAspectFill;
	[self addSubview:_imageView];

	//跳过按钮
	CGFloat btnW = 30*SCREEN_SCALE;
	CGFloat btnH = 30*SCREEN_SCALE;
	_progress = [[AJProgressView alloc]initWithFrame:CGRectMake(self.width-btnW-24*SCREEN_SCALE, btnH, btnW, btnH)];
	_progress.progressColor = COLORMAIN;
	_progress.trackColor = [COLORMAIN setAlpha:0.1];
	_progress.autoText = NO;
	_progress.label.text = [NSString stringWithFormat:@"%d", LAUNCHIMAGE_SHOWTIME];
	_progress.label.textColor = [UIColor blackColor];
	[self addSubview:_progress];
	[_progress clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		[target dismiss];
	}];

	//标语区域
	_bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-80*SCREEN_SCALE, SCREEN_WIDTH, 80*SCREEN_SCALE)];
	_bottomView.hidden = YES;
	[self addSubview:_bottomView];

	CGFloat h = 60*SCREEN_SCALE;
	_icoView = [[UIImageView alloc]initWithFrame:CGRectMake(15*SCREEN_SCALE, (_bottomView.height-h)/2, h, h)];
	_icoView.image = IMGAPPICON;
	_icoView.layer.masksToBounds = YES;
	_icoView.layer.cornerRadius = 10*SCREEN_SCALE;
	[_bottomView addSubview:_icoView];

	_nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_icoView.right+20*SCREEN_SCALE, _icoView.top+5*SCREEN_SCALE, SCREEN_WIDTH-(_icoView.right+20*SCREEN_SCALE), 0)];
	_nameLabel.text = APP_NAME;
	_nameLabel.textColor = [UIColor blackColor];
	_nameLabel.font = FONTBOLD(14);
	_nameLabel.backgroundColor = [UIColor clearColor];
	[_bottomView addSubview:_nameLabel];
	CGSize s = [APP_NAME autoHeight:_nameLabel.font width:_nameLabel.width];
	_nameLabel.height = s.height;

	_sloganLabel = [[UILabel alloc]initWithFrame:CGRectMake(_nameLabel.left, _nameLabel.bottom+3*SCREEN_SCALE, _nameLabel.width, 0)];
	_sloganLabel.textColor = [UIColor grayColor];
	_sloganLabel.font = FONT(12);
	_sloganLabel.backgroundColor = [UIColor clearColor];
	_sloganLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
	_sloganLabel.minimumScaleFactor = 0.8;
	_sloganLabel.adjustsFontSizeToFitWidth = YES;
	[_bottomView addSubview:_sloganLabel];
}
- (void)setType:(AJLaunchImageType)type{
	_type = type;
	if (type == AJLaunchImageTypeFullscreen) {
		_imageView.frame = self.bounds;
		_bottomView.hidden = YES;
	} else {
		_imageView.frame = CGRectMake(0, 0, self.width, self.height-_bottomView.height);
		_bottomView.hidden = NO;
	}
}
- (void)setIco:(UIImage *)ico{
	_icoView.image = ico;
}
- (void)setName:(NSString *)name{
	_nameLabel.text = name;
}
- (void)setSlogan:(NSString *)slogan{
	_sloganLabel.text = slogan;
	CGSize s = [slogan autoHeight:_sloganLabel.font width:_sloganLabel.width];
	_sloganLabel.height = s.height;
}
- (void)setProgressText:(NSString *)progressText{
	_progressText = progressText;
	_progress.label.text = _progressText;
}
- (void)setOnlyText:(NSString *)onlyText{
	_onlyText = onlyText;
	CGFloat btnW = 55*SCREEN_SCALE;
	CGFloat btnH = 30*SCREEN_SCALE;
	_progress.frame = CGRectMake(self.width-btnW-24*SCREEN_SCALE, btnH, btnW, btnH);
	_progress.label.text = [_onlyText replace:@"%s" to:[NSString stringWithFormat:@"%d", LAUNCHIMAGE_SHOWTIME]];
	_progress.layer.cornerRadius = 2*SCREEN_SCALE;
	_progress.progressColor = COLORCLEAR;
	_progress.trackColor = COLORCLEAR;
	_progress.autoFont = NO;
}
- (void)didMoveToSuperview{
	if (!self.superview) return;
	//定时器
	_countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
	_time = _timeout ? _timeout : LAUNCHIMAGE_SHOWTIME;
	[self startTimer];
}
- (void)show{
	//UIWindow *window = [UIApplication sharedApplication].keyWindow;
	[KEYWINDOW addSubview:self];
}
- (void)startTimer{
	_count = _time;
	[[NSRunLoop mainRunLoop] addTimer:_countTimer forMode:NSRunLoopCommonModes];
}
- (void)countDown{
	_count--;
	_progress.progress = (float)(_time-_count) / _time;
	if (_onlyText.length) {
		_progress.label.text = [_onlyText replace:@"%s" to:[NSString stringWithFormat:@"%d", _count]];
	} else {
		_progress.label.text = _progressText.length ? _progressText : [NSString stringWithFormat:@"%d", _count];
	}
	if (_count<=0) [self dismiss];
}
- (void)dismiss{
	[_countTimer invalidate];
	_countTimer = nil;
	if (_completion) _completion();
	[UIView animateWithDuration:0.3f animations:^{
		self.alpha = 0.f;
		self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
	}];
}
@end


#pragma mark - UIBadger
@implementation UIBadger
- (instancetype)initWithFrame:(CGRect)frame{
	[self config:frame];
	return [super initWithFrame:frame];
}
- (void)setFrame:(CGRect)frame{
	[self config:frame];
	[super setFrame:frame];
}
- (void)config:(CGRect)frame{
	self.element[@"badgeHeight"] = @(frame.size.height);
	self.textAlignment = NSTextAlignmentCenter;
	self.hidden = YES;
}
- (void)setText:(NSString *)text{
	[self performSelector:@selector(setTextAnimation:) withObject:text afterDelay:0];
}
- (void)setTextAnimation:(NSString *)text{
	NSString *lastText = self.text;
	[super setText:text];
	if (!self.superview || [lastText isEqualToString:text]) return;
	if (!text.length || (text.isInt && text.integerValue==0)) {
		[UIView animateWithDuration:0.25 animations:^{
			self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
		} completion:^(BOOL finished) {
			self.hidden = YES;
			self.transform = CGAffineTransformIdentity;
		}];
		return;
	}
	if (!self.element[@"badgeCenter"]) self.element[@"badgeCenter"] = NSStringFromCGPoint(self.center);
	CGPoint center = CGPointFromString(self.element[@"badgeCenter"]);
	CGFloat height = [self.element[@"badgeHeight"] floatValue];
	CGFloat p = [self.element[@"badgePadding"] floatValue];
	if (!p) {
		CGSize s = [@"8" autoWidth:self.font height:height];
		p = height - s.width;
		self.element[@"badgePadding"] = @(p);
	}
	CGSize s = [text autoWidth:self.font height:height];
	if (s.width+p<height) s.width = height;
	else s.width += p;
	CGRect frame = self.frame;
	frame.size.width = s.width;
	frame.size.height = height;
	self.frame = frame;
	self.center = center;
	if (self.hidden) self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
	self.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^{
		self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^{
			self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
		} completion:^(BOOL finished) {
			self.transform = CGAffineTransformIdentity;
		}];
	}];
	/*
	 [self.layer removeAllAnimations];
	 CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	 animation.duration = 0.25;
	 animation.values = @[@1.0, @1.2, @1.0];
	 animation.fillMode = kCAFillModeForwards;
	 [self.layer addAnimation:animation forKey:@"transform.rotate"];
	 */
}
@end


#pragma mark - AJCutoverView
@interface AJCutoverView ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
	BOOL _addedBottomView;
	BOOL _isShowHeader;
	CGFloat _topViewHeight;
}
@end
@implementation AJCutoverView
- (instancetype)init{
	self = [super init];
	if (self) {
		[self initialize];
	}
	return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		[self initialize];
	}
	return self;
}
- (void)initialize{
	_distance = 60*SCREEN_SCALE;
	self.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	self.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.backgroundColor = [UIColor clearColor];
	self.showsVerticalScrollIndicator = NO;
	self.estimatedRowHeight = 0;
	self.estimatedSectionHeaderHeight = 0;
	self.estimatedSectionFooterHeight = 0;
	self.rowHeight = 0;
	self.sectionHeaderHeight = 0;
	self.sectionFooterHeight = 0;
	self.delegate = self;
	self.dataSource = self;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			_topViewHeight = _topView.height;
			[self reloadData];
			if (_changeDelegate && [_changeDelegate respondsToSelector:@selector(AJCutoverView:changeType:)]) {
				[_changeDelegate AJCutoverView:self changeType:_type];
			}
		});
	});
}
- (void)setDistance:(CGFloat)distance{
	_distance = fabs(distance);
}
- (void)setTopView:(UIView *)topView{
	_topView = topView;
	self.tableHeaderView = topView;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (_type == AJCutoverViewTypeBottom) {
				self.contentInset = UIEdgeInsetsMake(-topView.height, 0, 0, 0);
			}
		});
	});
}
- (void)setPanScrollView:(UIScrollView *)panScrollView{
	_panScrollView = panScrollView;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (_type == AJCutoverViewTypeTop) {
				_panScrollView.bounces = NO;
				_panScrollView.scrollEnabled = NO;
			}
		});
	});
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return tableView.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	//NSInteger section = indexPath.section;
	//NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	for (UIView *subview in cell.contentView.subviews) {
		[subview removeFromSuperview];
	}
	if (_bottomView && !_addedBottomView) {
		_addedBottomView = YES;
		_bottomView.top = 0;
		[cell.contentView addSubview:_bottomView];
	}
	return cell;
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	CGFloat offsetY = scrollView.contentOffset.y;
	if (_isShowHeader) {
		if (offsetY > _distance) {
			_isShowHeader = NO;
			self.contentInset = UIEdgeInsetsMake(-_topViewHeight, 0, 0, 0);
			if (_panScrollView) {
				_panScrollView.bounces = YES;
				_panScrollView.scrollEnabled = YES;
			}
			if (_changeDelegate && [_changeDelegate respondsToSelector:@selector(AJCutoverView:changeType:)]) {
				[_changeDelegate AJCutoverView:self changeType:AJCutoverViewTypeBottom];
			}
		} else {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					[self setContentOffset:CGPointMake(0, 0) animated:YES];
				});
			});
		}
	} else {
		if (offsetY < _topViewHeight-_distance) {
			_isShowHeader = YES;
			self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
			if (_panScrollView) {
				_panScrollView.bounces = NO;
				_panScrollView.scrollEnabled = NO;
			}
			if (_changeDelegate && [_changeDelegate respondsToSelector:@selector(AJCutoverView:changeType:)]) {
				[_changeDelegate AJCutoverView:self changeType:AJCutoverViewTypeTop];
			}
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					[self setContentOffset:CGPointMake(0, 0) animated:YES];
				});
			});
		}
	}
}
@end


#pragma mark - AJWebView
@interface AJWebView ()<WKNavigationDelegate,WKUIDelegate>{
	BOOL _autoHeight;
	BOOL _removeObservered;
	UIActivityIndicatorView *_loading;
	void(^_finishLoad)(NSString *html);
}
@end
@implementation AJWebView
- (instancetype)initWithFrame:(CGRect)frame{
	if (frame.size.height<=0) frame.size.height = 0.00001;
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
		self.scrollView.bounces = NO;
		if (@available(iOS 11.0, *)) {
			self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
			self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
			self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
		}
		_textColor = COLOR333;
		_font = FONT(12);
		_padding = UIEdgeInsetsMakeScale(@8, @8, @8, @8);
		_style = @"";
		_script = @"";
	}
	return self;
}
- (void)setHtml:(NSString *)html{
	self.navigationDelegate = self;
	html = [[html replace:@"\\n" to:@""] preg_replace:@"</?a[^>]*>" to:@""];
	html = [html preg_replace:@"width:\\s*(\\d+)px;\\s*height:\\s*(\\d+)px;" replacement:^NSString *(NSDictionary *matcher, NSInteger index) {
		if ([matcher[@"group"][0]intValue]>600) return @"width:600px;";
		return matcher[@"value"];
	}];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString *bodyCss = @"";
			[self loadHTMLString:FORMAT(@"<!doctype html><html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width,minimum-scale=1.0,maximum-scale=1.0,initial-scale=1.0,user-scalable=no\"><style>html,body{background-color:transparent;-webkit-touch-callout:none;-webkit-user-select:none;-webkit-overflow-scrolling:touch;color:#%@;font-size:%.fpx;font-family:arial;margin:0;padding:0;text-align:left;}body>div{width:100%%;height:auto;overflow:hidden;box-sizing:border-box;float:left;padding:%.fpx %.fpx %.fpx %.fpx;}body>div>p:first-child{margin-top:0;}body>div>p:last-child{margin-bottom:0;}p{margin:0;padding:0;width:auto;word-break:break-all;white-space:pre-wrap;}p img{float:left;}%@</style></head><body><div>%@</div></body></html>", _textColor.string, _font.pointSize, _padding.top, _padding.right, _padding.bottom, _padding.left, _style, html) baseURL:nil];
		});
	});
}
- (void)autoHeightWithHtml:(NSString *)html finishLoad:(void (^)(AJWebView *webView))finishLoad{
	_autoHeight = YES;
	if (finishLoad) self.element[@"finishLoad"] = finishLoad;
	self.scrollView.scrollEnabled = NO;
	[self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
	self.html = html;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			_removeObservered = YES;
			[self.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
		});
	});
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if (_autoHeight && !_removeObservered && [keyPath isEqualToString:@"contentSize"]) {
		[self evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
			_html = obj;
			NSString *js = @"document.getElementsByTagName('body')[0].children[0].offsetHeight";
			[self evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
				CGFloat divHeight = [obj floatValue];
				CGFloat height = self.scrollView.contentSize.height;
				if (height > divHeight) height = divHeight;
				if (self.height != height) {
					dispatch_async(dispatch_get_main_queue(), ^{
						self.height = height;
						void (^finishLoad)(AJWebView *webView) = self.element[@"finishLoad"];
						if (finishLoad) finishLoad(self);
					});
				}
			}];
		}];
	}
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
	[_loading startAnimating];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
	[_loading stopAnimating];
	if (_autoHeight) {
		NSString *js = FORMAT(@"var img = document.getElementsByTagName('img');\
							  for(var i=0;i<img.length;i++){if(img[i].offsetWidth<=300)continue;\
							  img[i].style.width='';img[i].style.height='';img[i].style.verticalAlign='bottom';\
							  img[i].setAttribute('width','100%%');if(img[i].getAttribute('height'))img[i].removeAttribute('height');}\
							  %@", _script);
		[webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
			[webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
				_html = obj;
				if (_finishLoad) _finishLoad(_html);
			}];
		}];
	} else {
		[webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
			_html = obj;
			if (_finishLoad) _finishLoad(_html);
		}];
	}
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
	if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
		decisionHandler(WKNavigationActionPolicyCancel);
		return;
	}
	decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
	NSLog(@"%@", error.userInfo);
	[_loading stopAnimating];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
	NSLog(@"%@", error.userInfo);
	[_loading stopAnimating];
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler();
	}]];
	[APPCurrentController presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(NO);
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(YES);
	}]];
	[APPCurrentController presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.text = defaultText;
	}];
	[alertController addAction:[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		completionHandler(alertController.textFields[0].text?:@"");
	}]];
	[APPCurrentController presentViewController:alertController animated:YES completion:nil];
}
- (void)setUrl:(NSString *)url{
	self.navigationDelegate = self;
	self.UIDelegate = self;
	if (!_loading) {
		_loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_loading.frame = CGRectMake(0, 0, 20*SCREEN_SCALE, 20*SCREEN_SCALE);
		_loading.hidesWhenStopped = YES;
		[self addSubview:_loading];
		[_loading setCenterXY];
	}
	[self performSelector:@selector(setUrlDelay:) withObject:url afterDelay:0];
}
- (void)setUrlDelay:(NSString *)url{
	_url = url;
	[self loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:_url]]];
}
- (void)didFinishLoad:(void (^)(NSString *html))finishLoad{
	_finishLoad = finishLoad;
}
- (void)dealloc{
	[self loadHTMLString:@"" baseURL:nil];
}
@end


#pragma mark - NSDate+Extend
@implementation NSDate (GlobalExtend)
- (NSInteger)year{
	return [Global getYear:self];
}
- (NSInteger)month{
	return [Global getMonth:self];
}
- (NSInteger)week{
	return [Global getWeek:self];
}
- (NSInteger)day{
	return [Global getDay:self];
}
- (NSInteger)hour{
	return [Global getHour:self];
}
- (NSInteger)minute{
	return [Global getMinute:self];
}
- (NSInteger)second{
	return [Global getSecond:self];
}
@end


#pragma mark - UIColor+Extend
@implementation UIColor (GlobalExtend)
//随机颜色
+ (UIColor*)randomColor{
	//return [UIColor colorWithRed:arc4random_uniform(100)/100. green:arc4random_uniform(100)/100. blue:arc4random_uniform(100)/100. alpha:1];
	CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
	CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
	CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
//设置透明度
- (CGFloat)alpha{
	CGFloat r, g, b, a;
	if ([self getRed:&r green:&g blue:&b alpha:&a]){
		return a;
	}
	return 1.f;
}
- (UIColor*)setAlpha:(CGFloat)alpha{
	CGFloat r, g, b, a;
	if ([self getRed:&r green:&g blue:&b alpha:&a]){
		return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
	}
	return nil;
}
//UIColor转网页颜色
- (NSString*)string{
	const CGFloat *cs = CGColorGetComponents(self.CGColor);
	NSString *hex = [NSString stringWithFormat:@"%02X%02X%02X", (int)(cs[0]*255.f), (int)(cs[1]*255.f), (int)(cs[2]*255.f)];
	return hex;
}
//UIColor转UIImage
- (UIImage*)imageWithSize:(CGSize)size{
	@autoreleasepool {
		CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
		UIGraphicsBeginImageContext(rect.size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, self.CGColor);
		CGContextFillRect(context, rect);
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return newImage;
	}
}
//减浅颜色
- (UIColor*)lighter{
	CGFloat r, g, b, a;
	if ([self getRed:&r green:&g blue:&b alpha:&a])
		return [UIColor colorWithRed:MIN(r + 0.2, 1.0) green:MIN(g + 0.2, 1.0) blue:MIN(b + 0.2, 1.0) alpha:a];
	return nil;
}
//加深颜色
- (UIColor*)darker{
	CGFloat r, g, b, a;
	if ([self getRed:&r green:&g blue:&b alpha:&a])
		return [UIColor colorWithRed:MAX(r - 0.2, 0.0) green:MAX(g - 0.2, 0.0) blue:MAX(b - 0.2, 0.0) alpha:a];
	return nil;
}
//渐变颜色
+ (UIColor*)gradientColors:(NSArray*)colors bounds:(CGRect)bounds startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
	if (!colors.isArray) return nil;
	NSMutableArray *cs = [[NSMutableArray alloc]init];
	NSMutableArray *ls = [[NSMutableArray alloc]init];
	NSInteger count = colors.count;
	CGFloat step = 100.f / count;
	for (int i=0; i<count; i++) {
		[cs addObject:(__bridge id)[colors[i] CGColor]];
		if (i==count-1) {
			[ls addObject:@1.0];
		} else {
			[ls addObject:@(step*i)];
		}
	}
	CAGradientLayer *layer = [CAGradientLayer layer];
	layer.frame = bounds;
	layer.colors = cs;
	layer.locations = ls;
	layer.startPoint = startPoint;
	layer.endPoint = endPoint;
	UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0.0);
	[layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return [UIColor colorWithPatternImage:image];
}
@end


#pragma mark - NSData+Extend
@implementation NSData (GlobalExtend)
//是否图片
- (BOOL)isImage{
	UIImage *image = [[UIImage alloc]initWithData:self];
	return image!=nil;
}
//是否GIF
- (BOOL)isGIF{
	return [self.suffix isEqualToString:@"gif"];
}
//GIF数据转为GIF图片
- (UIImage*)gif{
	if (!self.length) return nil;
	if (!self.isGIF) return [[UIImage alloc]initWithData:self];
	return [GIFImage imageWithData:self];
}
//转base64
- (NSString*)base64{
	if (!self.length) return nil;
	return [self base64EncodedStringWithOptions:0];
}
//转base64,带标识
- (NSString*)base64WithMark{
	UIImage *image = [UIImage imageWithData:self];
	NSString *mimeType = @"image/jpeg";
	if (image.isPNG) mimeType = @"image/png";
	return [NSString stringWithFormat:@"data:%@;base64,%@", mimeType, self.base64];
}
//后缀名(图片)
- (NSString*)suffix{
	UIImage *image = [[UIImage alloc]initWithData:self];
	if (image==nil) return @"";
	if (image.hasAlpha) return @"png";
	NSString *format = @"";
	uint8_t c;
	[self getBytes:&c length:1];
	switch (c) {
		case 0xFF:
			format = @"jpg";
			break;
		case 0x89:
			format = @"png";
			break;
		case 0x47:
			format = @"gif";
			break;
		case 0x49:
		case 0x4D:
			format = @"tiff";
			break;
		case 0x42:
			format = @"bmp";
			break;
	}
	return format;
}
//MimeType(图片)
- (NSString*)mimeType{
	NSString *format = @"application/octet-stream";
	uint8_t c;
	[self getBytes:&c length:1];
	switch (c) {
		case 0xFF:
			format = @"image/jpeg";
			break;
		case 0x89:
			format = @"image/png";
			break;
		case 0x47:
			format = @"image/gif";
			break;
		case 0x49:
		case 0x4D:
			format = @"image/tiff";
			break;
		case 0x42:
			format = @"application/x-bmp";
			break;
	}
	return format;
}
//又拍云上传图片
- (void)UploadToUpyun:(NSString*)upyunFolder completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToUpyun:upyunFolder imageName:nil completion:completion];
}
//又拍云上传图片, 指定文件名(不包含后缀)
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToUpyun:upyunFolder imageName:imageName progress:nil completion:completion];
}
- (void)UploadToUpyun:(NSString*)upyunFolder imageName:(NSString*)imageName progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	if (self.length<=0) {
		[ProgressHUD showError:@"图片无效"];
		return;
	}
	if (!imageName.length) imageName = [Global datetimeAndRandom];
	NSString *suffix = self.suffix;
	NSString *name = [NSString stringWithFormat:@"%@.%@", imageName, suffix];
	NSDictionary *options = @{
							  @"bucket" : UPYUN_BUCKET,
							  @"expiration" : [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]+600],
							  @"save-key" : [NSString stringWithFormat:@"/%@/{year}/{mon}/{day}/%@", upyunFolder, name],
							  @"allow-file-type" : @"jpg,jpeg,gif,png,bmp",
							  @"content-length-range" : @"0,10240000",
							  @"image-width-range" : @"0,1024000",
							  @"image-height-range" : @"0,1024000"
							  };
	NSString *json = options.jsonString;
	NSString *policy = json.base64;
	NSString *sign = [[NSString stringWithFormat:@"%@&%@", policy, UPYUN_SECRET] md5];
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setValue:policy forKey:@"policy"];
	[postData setValue:sign forKey:@"signature"];
	[postData setValue:self forKey:[NSString stringWithFormat:@"file.%@", suffix]];
	[Global upload:[NSString stringWithFormat:@"http://v0.api.upyun.com/%@", UPYUN_BUCKET] data:postData progress:progress completion:^(NSString *result) {
		NSMutableDictionary *json = result.formatJson;
		if (json.isDictionary) {
			if ([json[@"code"]integerValue]==200) {
				if (completion) {
					NSString *imageUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
					completion(json, [UIImage imageWithData:self], imageUrl, imageName);
				} else {
					[ProgressHUD dismiss];
				}
			} else {
				[ProgressHUD showError:json[@"message"]];
			}
		} else {
			NSLog(@"%@", result);
			[ProgressHUD showError:@"图片上传失败"];
		}
	} fail:nil];
}
//七牛上传图片
- (void)UploadToQiniu:(NSString*)token completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToQiniu:token imageName:nil completion:completion];
}
//七牛上传图片, 指定文件名(不包含后缀)
- (void)UploadToQiniu:(NSString*)token imageName:(NSString*)imageName completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[self UploadToQiniu:token imageName:imageName progress:nil completion:completion];
}
- (void)UploadToQiniu:(NSString*)token imageName:(NSString*)imageName progress:(void (^)(NSProgress *progress))progress completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	if (self.length<=0) {
		[ProgressHUD showError:@"图片无效"];
		return;
	}
	NSString *imageNamed = imageName;
	if (!imageNamed.length) imageNamed = [Global datetimeAndRandom];
	NSString *suffix = self.suffix;
	NSString *name = [NSString stringWithFormat:@"%@.%@", imageNamed, suffix];
	NSProgress *progressManager = [NSProgress progressWithTotalUnitCount:self.length];
	[QiniuHelper UploadToQiniu:self imageName:name token:token progress:^(NSString *key, float percent) {
		if (progress) {
			progressManager.completedUnitCount = self.length * percent;
			progress(progressManager);
		}
	} completion:^(UIImage *image, NSString *imageUrl, NSString *imageName) {
		if (completion) completion(image, imageUrl, imageNamed);
	}];
}
@end


#pragma mark - NSTimer+Extend
@implementation NSTimer (GlobalExtend)
//action返回YES即停止重复
+ (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats action:(BOOL (^)(NSTimer *timer))action{
	return [self scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(executeAction:) userInfo:[action copy] repeats:repeats];
}
+ (NSTimer*)timerWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats action:(BOOL (^)(NSTimer *timer))action{
	return [self timerWithTimeInterval:timeInterval target:self selector:@selector(executeAction:) userInfo:[action copy] repeats:repeats];
}
+ (void)executeAction:(NSTimer*)timer{
	if (timer.userInfo) {
		BOOL (^action)(NSTimer *timer) = (BOOL (^)(NSTimer *timer))timer.userInfo;
		BOOL stop = action(timer);
		if (stop) [timer stop];
	}
}
- (void)pause{
	if (![self isValid]) return;
	[self setFireDate:[NSDate distantFuture]];
}
- (void)resume{
	if (![self isValid]) return;
	[self setFireDate:[NSDate date]];
}
- (void)stop{
	[self pause];
	[self invalidate];
}
@end


#pragma mark - AdModel
@interface AdModel ()<OutletDelegate>
@end
@implementation AdModel
+ (void)selectType:(NSString*)type content:(NSString*)content{
	AdModel *model = [[AdModel alloc]init];
	[model selectType:type content:content];
}
- (void)selectType:(NSString*)type content:(NSString*)content{
	NSInteger index = [ADMODEL_TYPES indexOfObject:type];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	switch (index) {
		case 0:{
			Outlet *e = [[Outlet alloc]init];
			e.delegate = self;
			e.url = content;
			//e.isFullscreen = YES;
			//e.leftImage = IMG(@"d-return");
			//e.statusBarBlack = YES;
			[APPCurrentController.navigationController pushViewController:e animated:YES];
			break;
		}
		case 1:{
			if (NSClassFromString(@"goodsDetail")) {
				id e = [[NSClassFromString(@"goodsDetail") alloc]init];
				if (e && [e respondsToSelector:NSSelectorFromString(@"setData:")]) {
					[e performSelector:NSSelectorFromString(@"setData:") withObject:@{@"id":content}];
				}
				[APPCurrentController.navigationController pushViewController:e animated:YES];
			}
			break;
		}
		case 2:{
			if (NSClassFromString(@"shopDetail")) {
				id e = [[NSClassFromString(@"shopDetail") alloc]init];
				if (e && [e respondsToSelector:NSSelectorFromString(@"setData:")]) {
					[e performSelector:NSSelectorFromString(@"setData:") withObject:@{@"id":content}];
				}
				[APPCurrentController.navigationController pushViewController:e animated:YES];
			}
			break;
		}
		case 3:{
			if (NSClassFromString(@"articleDetail")) {
				id e = [[NSClassFromString(@"articleDetail") alloc]init];
				if (e && [e respondsToSelector:NSSelectorFromString(@"setData:")]) {
					[e performSelector:NSSelectorFromString(@"setData:") withObject:@{@"id":content}];
				}
				[APPCurrentController.navigationController pushViewController:e animated:YES];
			}
			break;
		}
		case 4:
		case 5:{
			if (NSClassFromString(@"goods")) {
				id e = [[NSClassFromString(@"goods") alloc]init];
				if (e && [e respondsToSelector:NSSelectorFromString(@"setData:")]) {
					[e performSelector:NSSelectorFromString(@"setData:") withObject:@{@"category_id":content}];
				}
				[APPCurrentController.navigationController pushViewController:e animated:YES];
			}
			break;
		}
		case 6:{
			if (NSClassFromString(@"goods")) {
				id e = [[NSClassFromString(@"goods") alloc]init];
				if (e && [e respondsToSelector:NSSelectorFromString(@"setData:")]) {
					[e performSelector:NSSelectorFromString(@"setData:") withObject:@{@"brand_id":content}];
				}
				[APPCurrentController.navigationController pushViewController:e animated:YES];
			}
			break;
		}
		case 7:{
			if (![APPCurrentController isLogin:YES]) return;
			[ProgressHUD show:nil];
			[Common getApiWithParams:@{@"app":@"coupon", @"act":@"ling", @"id":content} success:^(NSMutableDictionary *json) {
				[ProgressHUD showSuccess:@"优惠券领取成功"];
			} fail:nil];
			break;
		}
		case 8:{
			if (![APPCurrentController isLogin:YES]) return;
			if (NSClassFromString(@"rechargePost")) {
				id e = [[NSClassFromString(@"rechargePost") alloc]init];
				if (e && [e respondsToSelector:NSSelectorFromString(@"setData:")]) {
					[e performSelector:NSSelectorFromString(@"setData:") withObject:@{@"id":content}];
				}
				[APPCurrentController.navigationController pushViewController:e animated:YES];
			}
			break;
		}
		case 9:{
			if (NSClassFromString(@"country")) {
				id e = [[NSClassFromString(@"country") alloc]init];
				if (e && [e respondsToSelector:NSSelectorFromString(@"setData:")]) {
					[e performSelector:NSSelectorFromString(@"setData:") withObject:@{@"id":content}];
				}
				[APPCurrentController.navigationController pushViewController:e animated:YES];
			}
			break;
		}
		case 10:{
			if ([APPCurrentController isLogin:NO]) {
				APPCurrentController.tabBarControllerKK.selectedIndex = 4;
				return;
			}
			if (NSClassFromString(@"regist")) {
				id e = [[NSClassFromString(@"regist") alloc]init];
				//e.isFirst = YES;
				KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:e];
				[APPCurrentController presentViewController:nav animated:YES completion:nil];
			}
			break;
		}
	}
#pragma clang diagnostic pop
}
- (BOOL)OutletStartLoadUrlWith:(Outlet *)controller url:(NSString *)url html:(NSString *)html{
	if ([url hasPrefix:FORMAT(@"%@/wap.php?app=", API_URL)]) {
		NSMutableArray *matcher = [url preg_match:@"\\?app=(\\w+)&act=(\\w+)(&\\w*id=(\\d+))?"];
		if (matcher.count) {
			[self selectType:matcher[0][@"group"][0] content:matcher[0][@"group"][3]];
			return NO;
		}
	} else if ([url hasPrefix:FORMAT(@"%@://share?", APP_SCHEME)]) {
		//if (![APPCurrentController isLogin:YES]) return NO;
		[ShareHelper shareWithSchemeUrl:url completion:nil];
		return NO;
	}
	return YES;
}
@end


#pragma mark - FileDownloader
@interface FileDownloader ()<NSURLConnectionDataDelegate>{
	NSURLConnection *_conn;
	NSMutableData *_data;
	unsigned long long _currentLength; //已获取的数据长度
	unsigned long long _totalLength; //总数据长度
}
@end
@implementation FileDownloader
+ (FileDownloader*)downloadWithUrl:(NSString*)url completion:(void(^)(NSData *data, BOOL exist))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	FileDownloader *fileDownloader = [[FileDownloader alloc]init];
	fileDownloader.url = url;
	fileDownloader.completion = completion;
	fileDownloader.fail = fail;
	dispatch_async(dispatch_get_main_queue(), ^{
		[fileDownloader start];
	});
	return fileDownloader;
}
+ (FileDownloader*)downloadWithUrl:(NSString*)url timeout:(NSTimeInterval)timeout progress:(void (^)(double progress, long dataSize, long long currentSize, long long totalSize))progress completion:(void (^)(NSData *data, BOOL exist))completion fail:(void (^)(NSString *description, NSInteger code))fail{
	FileDownloader *fileDownloader = [[FileDownloader alloc]init];
	fileDownloader.url = url;
	fileDownloader.timeout = timeout;
	fileDownloader.progress = progress;
	fileDownloader.completion = completion;
	fileDownloader.fail = fail;
	dispatch_async(dispatch_get_main_queue(), ^{
		[fileDownloader start];
	});
	return fileDownloader;
}
- (instancetype)init{
	self = [super init];
	if (self) {
		_timeout = DOWNLOAD_TIMEOUT;
	}
	return self;
}
//开始下载
- (void)start{
	if (!_url.length) return;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeout];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	NSString *rangeValue = [NSString stringWithFormat:@"bytes=%llu-", _currentLength];
	[request setValue:rangeValue forHTTPHeaderField:@"Range"];
	_conn = [NSURLConnection connectionWithRequest:request delegate:self];
	dispatch_async(dispatch_queue_create("downloadConnection", DISPATCH_QUEUE_CONCURRENT), ^{
		[_conn start];
	});
}
//暂停下载
- (void)pause{
	[_conn cancel];
	_conn = nil;
}
//取消下载
- (void)stop{
	[self pause];
	_currentLength = 0;
	_totalLength = 0;
	_data = [NSMutableData data];
}
//当接收到响应(连通了服务器)时调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
	if ( !(responseCode>=200 && responseCode<300) ) {
		NSLog(@"%@\nFileDownloader Receive Error:%ld", _url, (long)responseCode);
		if (_fail) {
			dispatch_async(dispatch_get_main_queue(), ^{
				_fail(@"Receive Error", responseCode);
			});
		}
		return;
	}
	if (_totalLength) return;
	_totalLength = response.expectedContentLength;
	_data = [NSMutableData data];
}
//当接收到数据时调用(如果数据量大,例如视频可能会被调用多次,每次只传递部分数据)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if (!data.length) {
		dispatch_async(dispatch_get_main_queue(), ^{
			//if (_completion) _completion(nil, NO);
		});
		return;
	}
	_currentLength += data.length;
	double progress = (double)_currentLength / _totalLength;
	if (_progress) {
		dispatch_async(dispatch_get_main_queue(), ^{
			_progress(progress, data.length, _currentLength, _totalLength);
		});
		//NSLog(@"%f%%", progress);
	}
	[_data appendData:data];
}
//当数据加载完毕时调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_data.length) {
			if (_completion) _completion(_data, YES);
		}
	});
}
//请求错误(失败)时调用(请求超时\断网\没有网,一般指客户端网络出错)
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	//NSString *result = [[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
	NSLog(@"FileDownloder Httperror:%@ Errorcode:%ld", error.localizedDescription, (long)error.code);
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_fail) _fail(error.localizedDescription, (long)error.code);
	});
	[self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}
@end


#pragma mark - One Finger Rotation
#import <UIKit/UIGestureRecognizerSubclass.h>
@implementation OneFingerRotationGestureRecognizer
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([[event touchesForGestureRecognizer:self] count] > 1) {
		[self setState:UIGestureRecognizerStateFailed];
	}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([self state] == UIGestureRecognizerStatePossible) {
		[self setState:UIGestureRecognizerStateBegan];
	} else {
		[self setState:UIGestureRecognizerStateChanged];
	}
	UITouch *touch = [touches anyObject];
	UIView *view = [self view];
	CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
	CGPoint currentTouchPoint = [touch locationInView:view];
	CGPoint previousTouchPoint = [touch previousLocationInView:view];
	CGFloat angleInRadians = atan2f(currentTouchPoint.y - center.y, currentTouchPoint.x - center.x) - atan2f(previousTouchPoint.y - center.y, previousTouchPoint.x - center.x);
	_rotation = angleInRadians;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([self state] == UIGestureRecognizerStateChanged) {
		[self setState:UIGestureRecognizerStateEnded];
	} else {
		[self setState:UIGestureRecognizerStateFailed];
	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[self setState:UIGestureRecognizerStateFailed];
}
@end


#pragma mark - QueueHandle
@interface QueueHandle ()
@property(nonatomic) dispatch_queue_t queue;
@property(nonatomic) dispatch_semaphore_t semaphore;
@end
@implementation QueueHandle
- (id)init{
	if (self = [super init]) {
		_queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
	}
	return self;
}
- (void)queueHandleBlock:(void (^)(void))operate{
	dispatch_async(_queue, ^{
		_semaphore = dispatch_semaphore_create(0);
		dispatch_async(dispatch_get_main_queue(), operate);
		dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
	});
}
- (void)completionBlock:(void (^)(void))completion{
	if (completion) completion();
	dispatch_semaphore_signal(_semaphore);
}
@end


#pragma mark - Simulation Data
@implementation NSDictionary (SimulationData)
//商品详情
+ (NSMutableDictionary*)simulationDetail{
	return [NSDictionary simulationDetail:0];
}
+ (NSMutableDictionary*)simulationDetail:(int)day{
	NSDictionary *data = @{
						   @"id":@"315",
						   @"name":@"本年最新款海贼王LOGO夏装上衣",
						   @"pic":@"http://yidian2015.b0.upaiyun.com/uploadfiles/avatar/2016/08/25/1682522561229178.gif",
						   @"market_price":@"10",
						   @"price":@"0.01",
						   @"quantity":@"1",
						   @"sales":@"10",
						   @"clicks":@"19",
						   @"stocks":@"100",
						   @"likes":@"19",
						   @"comments":@"10",
						   @"add_time":FORMAT(@"%@", [Global formatDateTime:[Global dateFromUnix:[Global unix]-60*60*24*day]]),
						   @"description":@"这是本年最新款的海贼王LOGO夏装上衣，现在大特价￥0.01/件，欢迎各位识货的海贼王FANS购买回家哦~",
						   @"shop_id":@"10138",
						   @"shop_name":@"劳务费",
						   @"shop_avatar":@"http://yidian2015.b0.upaiyun.com/uploadfiles/avatar/20160515/165150043981351.gif!logo",
						   @"shop_poster":@"http://yidian2015.b0.upaiyun.com/uploadfiles/shop/avatar/2016/05/13/201605131520255668.jpg",
						   @"province":@"广东省",
						   @"city":@"广州市",
						   @"district":@"天河区",
						   @"address":@"黄村达维商务3320",
						   @"content":@"这是本年最新款的海贼王LOGO夏装上衣，现在大特价￥0.01/件，欢迎各位识货的海贼王FANS购买回家哦~<br /><img src=\"http://yidian2015.b0.upaiyun.com/uploadfiles/shop/avatar/2016/05/13/201605131520255668.jpg\" /><br /><img src=\"http://yidian2015.b0.upaiyun.com/1460187545503.jpg\" /><br /><img src=\"http://yidian2015.b0.upaiyun.com/uploadfiles/shop/product/2016/03/17/75688809.png\" />",
						   @"member_id":@"157",
						   @"member_name":@"ajsong",
						   @"member_avatar":@"http://yidian2015.b0.upaiyun.com/uploadfiles/avatar/2016/05/15/165150094783425.jpg!logo",
						   @"mobile":@"13800138000",
						   @"pics":@[
								   @{@"pic":@"http://yidian2015.b0.upaiyun.com/uploadfiles/shop/product/2016/03/17/75688809.png"},
								   @{@"pic":@"http://yidian2015.b0.upaiyun.com/uploadfiles/shop/product/2016/03/17/74949073.png"},
								   @{@"pic":@"http://yidian2015.b0.upaiyun.com/uploadfiles/shop/product/2016/03/17/75615713.png"},
								   @{@"pic":@"http://yidian2015.b0.upaiyun.com/uploadfiles/shop/product/2016/03/17/46199315.png"},
								   @{@"pic":@"http://yidian2015.b0.upaiyun.com/uploadfiles/shop/product/2016/03/17/92519053.png"}
								   ],
						   @"specs":@[
								   @{@"id":@"10654", @"spec":@"默认规格", @"stocks":@"100", @"goods_id":@"318",
									 @"market_price":@"10", @"price":@"0.01"}
								   ]
						   };
	return [NSMutableDictionary dictionaryWithDictionary:data];
}
@end
@implementation NSArray (SimulationData)
//幻灯图
+ (NSMutableArray*)simulationAD{
	return [NSArray simulationAD:5];
}
+ (NSMutableArray*)simulationAD:(int)count{
	NSMutableArray *datas = [[NSMutableArray alloc]init];
	for (int i=0; i<count; i++) {
		[datas addObject:@{
						   @"id":@"1", @"name":@"背部矿石疗法", @"ad_type":@"html5",
						   @"ad_content":@"http://www.baidu.com",
						   @"pic":@"http://imeitouyi.b0.upaiyun.com/uploadfiles/ad/20160511/1651110052093521.jpg"
						   }];
	}
	return datas;
}
//分类列表
+ (NSMutableArray*)simulationType{
	return [self simulationType:5];
}
+ (NSMutableArray*)simulationType:(int)count{
	NSMutableArray *datas = [[NSMutableArray alloc]init];
	for (int i=0; i<count; i++) {
		[datas addObject:@{@"id":@"1", @"name":@"面部护理", @"pic":@"http://yidian2015.b0.upaiyun.com/uploadfiles/avatar/20160514/1651423450166530.png"}];
	}
	return datas;
}
//商品列表
+ (NSMutableArray*)simulationList{
	return [NSArray simulationList:8];
}
+ (NSMutableArray*)simulationList:(int)count{
	NSMutableArray *datas = [[NSMutableArray alloc]init];
	for (int i=0; i<count; i++) {
		[datas addObject:[NSDictionary simulationDetail]];
	}
	return datas;
}
+ (NSMutableArray*)simulationList:(int)count apartDay:(int)day{
	NSMutableArray *datas = [[NSMutableArray alloc]init];
	for (int i=0; i<count; i++) {
		[datas addObject:[NSDictionary simulationDetail:i*day]];
	}
	return datas;
}
@end
