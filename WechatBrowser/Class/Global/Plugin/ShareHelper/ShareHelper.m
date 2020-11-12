//
//  ShareHelper.m
//
//  Created by ajsong on 15/4/14.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "ShareHelper.h"
#import <MessageUI/MessageUI.h>

#define NO_CLINET_GOON 0 //没有分享客户端也继续显示
#define SHOW_QRCODE 1 //显示二维码选项

@implementation ShareHelperModel
@end

@interface ShareHelper ()<MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,WXApiDelegate>

@end

@implementation ShareHelper

+ (ShareHelper*)sharedHelper{
	static dispatch_once_t once = 0;
	static ShareHelper *shareView;
	dispatch_once(&once, ^{ shareView = [[ShareHelper alloc] init]; });
	return shareView;
}

- (instancetype)init{
	self = [super init];
	if (self) {
		self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
		_types = @[@"wxsession", @"wxtimeline", @"sina", @"qq", @"qzone"];
		_isToolbar = YES;
		_debug = NO_CLINET_GOON;
	}
	return self;
}

- (void)show{
	if (!_title.length || !_url.length) {
		[ProgressHUD showError:@"缺少需分享的标题、网址"];
		return;
	}
	if (!_content.length) _content = [_title copy];
	if (!_image) _image = IMGAPPICON;
	
	NSInteger tag = 29865363;
	[[self viewWithTag:tag] removeFromSuperview];
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
	view.tag = tag;
	[self addSubview:view];
	
	NSArray *nameArray = SHARE_NAME_ARRAY;
	NSArray *typeArray = SHARE_TYPE_ARRAY;
	
	UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10*SCREEN_SCALE, SCREEN_WIDTH, 14*SCREEN_SCALE)];
	title.text = @"分享到";
	title.textColor = COLOR999;
	title.textAlignment = NSTextAlignmentCenter;
	title.font = FONT(11);
	title.backgroundColor = COLORCLEAR;
	[view addSubview:title];
	
	NSMutableArray *array = [[NSMutableArray alloc]init];
	if (_types.isArray) {
		for (NSString *type in _types) {
			NSInteger tag = [typeArray indexOfObject:type];
			switch (tag) {
				case ShareHelperTypeSina:{
					if (([ShareHelper isSinaInstalled] || _debug) && [SINA_APPKEY length]) [array addObject:type];
					break;
				}
				case ShareHelperTypeWXSession:
				case ShareHelperTypeWXTimeLine:
				case ShareHelperTypeWXFavorite:{
					if (([ShareHelper isWXAppInstalled] || _debug) && [WX_APPID length]) [array addObject:type];
					break;
				}
				case ShareHelperTypeQQ:
				case ShareHelperTypeQZone:
				case ShareHelperTypeTencent:{
					if (([ShareHelper isQQInstalled] || _debug) && [QQ_APPID length]) [array addObject:type];
					break;
				}
				case ShareHelperTypeSms:
				case ShareHelperTypeEmail:
				case ShareHelperTypeLink:{
					[array addObject:type];
					break;
				}
				case ShareHelperTypeQrcode:{
					if (SHOW_QRCODE) [array addObject:type];
					break;
				}
			}
		}
	} else {
		if (([ShareHelper isSinaInstalled] || _debug) && [SINA_APPKEY length]) {
			[array addObject:typeArray[0]];
		}
		if (([ShareHelper isWXAppInstalled] || _debug) && [WX_APPID length]) {
			[array addObject:typeArray[1]];
			[array addObject:typeArray[2]];
			[array addObject:typeArray[3]];
		}
		if (([ShareHelper isQQInstalled] || _debug) && [QQ_APPID length]) {
			[array addObject:typeArray[4]];
			[array addObject:typeArray[5]];
			[array addObject:typeArray[6]];
		}
		[array addObject:typeArray[7]];
		[array addObject:typeArray[8]];
		[array addObject:typeArray[9]];
		if (SHOW_QRCODE) {
			[array addObject:typeArray[10]];
		}
	}
	if (!array.count) {
		[ProgressHUD showError:@"设备没有可分享的客户端"];
		return;
	}
	
	CGFloat blank = 0;
	CGFloat width = 55*SCREEN_SCALE;
	
	if (array.count<=3) {
		blank = (SCREEN_WIDTH - array.count*width) / (array.count+1);
	} else {
		blank = (SCREEN_WIDTH - 4*width) / (4+1)*SCREEN_SCALE - 5*SCREEN_SCALE;
	}
	UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, title.bottom+10*SCREEN_SCALE, SCREEN_WIDTH, width+(5+12)*SCREEN_SCALE)];
	scrollView.showsHorizontalScrollIndicator = NO;
	[view addSubview:scrollView];
	for (int i=0; i<array.count; i++) {
		UIView *item = [[UIView alloc]initWithFrame:CGRectMake(blank+(width+blank)*i, 0, width, scrollView.height)];
		item.element[@"type"] = array[i];
		[scrollView addSubview:item];
		
		UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
		image.image = IMG(@"share_%@", array[i]);
		[item addSubview:image];
		
		UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(0, image.bottom+5*SCREEN_SCALE, width, 12*SCREEN_SCALE)];
		text.text = nameArray[[typeArray indexOfObject:array[i]]];
		text.textColor = COLOR666;
		text.textAlignment = NSTextAlignmentCenter;
		text.font = FONT(10);
		text.backgroundColor = COLORCLEAR;
		[item addSubview:text];
		
		[item clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
			[target selectShare:sender];
		}];
	}
	if (array.count>3) scrollView.contentSize = CGSizeMake(scrollView.lastSubview.right+blank, scrollView.height);
	CGFloat bottom = scrollView.bottom + 10*SCREEN_SCALE;
	
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, bottom, SCREEN_WIDTH-10*2*SCREEN_SCALE, 40*SCREEN_SCALE)];
	btn.titleLabel.font = FONT(14);
	btn.backgroundColor = [UIColor clearColor];
	[btn setTitle:@"取消" forState:UIControlStateNormal];
	[btn setTitleColor:COLOR666 forState:UIControlStateNormal];
	btn.layer.borderColor = COLOR666.CGColor;
	btn.layer.borderWidth = 0.5*SCREEN_SCALE;
	btn.layer.masksToBounds = YES;
	btn.layer.cornerRadius = 3*SCREEN_SCALE;
	[btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:btn];
	
	view.height = btn.bottom + 10*SCREEN_SCALE;
	self.height = view.bottom;
	if (_isToolbar) [self addToolbar];
	
	[APPCurrentController presentActionView:self];
}

- (void)show:(void (^)(ShareHelperResult result))completion{
	_completion = completion;
	[self show];
}

- (void)close{
	[APPCurrentController dismissActionView];
}

- (void)close:(void (^)(void))completion{
	[APPCurrentController dismissActionView:completion];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"\ntitle: %@\ncontent: %@\nurl: %@", _title, _content, _url];
}

- (void)selectShare:(UIView*)sender{
	if ([sender.element[@"type"] isEqualToString:@"sms"]) {
		Class class = NSClassFromString(@"MFMessageComposeViewController");
		if (!class || ![class canSendSubject]) {
			[ProgressHUD showError:@"系统不支持应用内发短信"];
			return;
		}
		MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
		picker.messageComposeDelegate = self;
		picker.subject = _title;
		picker.body = FORMAT(@"%@\n\n%@", _content, _url);
		void(^execute)(NSData *imageData) = ^(NSData *imageData){
			NSString *suffix = imageData.suffix;
			[picker addAttachmentData:imageData typeIdentifier:@"public.data" filename:FORMAT(@"attachment.%@", suffix)];
			[APPCurrentController presentViewController:picker animated:YES completion:nil];
			[self close];
		};
		if ([_image isKindOfClass:[UIImage class]]) {
			UIImage *image = (UIImage*)_image;
			execute(image.data);
		} else if ([_image isKindOfClass:[NSData class]]) {
			execute((NSData*)_image);
		} else if ([_image isKindOfClass:[NSString class]]) {
			[(NSString*)_image cacheImageAndCompletion:^(UIImage *image, NSData *imageData) {
				execute(imageData);
			}];
		}
		return;
	}
	if ([sender.element[@"type"] isEqualToString:@"email"]) {
		Class class = NSClassFromString(@"MFMailComposeViewController");
		if (!class || ![class canSendMail]) {
			[ProgressHUD showError:@"请设置邮件账户来发送电子邮件"];
			return;
		}
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		picker.subject = _title;
		void(^execute)(NSData *imageData) = ^(NSData *imageData){
			NSString *mimeType = imageData.mimeType;
			NSString *suffix = imageData.suffix;
			[picker addAttachmentData:imageData mimeType:mimeType fileName:FORMAT(@"attachment.%@", suffix)];
			NSString *emailBody = [NSString stringWithFormat:@"<h3 style=\"margin:0;\">%@</h3><font color=gray>%@</font><br /><br /><a href=\"%@\" target=\"_blank\">前往%@查看</a>", _title, _content, _url, APP_NAME];
			[picker setMessageBody:emailBody isHTML:YES];
			[APPCurrentController presentViewController:picker animated:YES completion:nil];
			[self close];
		};
		if ([_image isKindOfClass:[UIImage class]]) {
			UIImage *image = (UIImage*)_image;
			execute(image.data);
		} else if ([_image isKindOfClass:[NSData class]]) {
			execute((NSData*)_image);
		} else if ([_image isKindOfClass:[NSString class]]) {
			[(NSString*)_image cacheImageAndCompletion:^(UIImage *image, NSData *imageData) {
				execute(imageData);
			}];
		}
		return;
	}
	if ([sender.element[@"type"] isEqualToString:@"link"]) {
		[Global copyString:[NSString stringWithFormat:@"%@\n%@", _title, _url]];
		[ProgressHUD showSuccess:@"已复制链接"];
		[self close];
		return;
	}
	if (SHOW_QRCODE && [sender.element[@"type"] isEqualToString:@"qrcode"]) {
		UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 240*SCREEN_SCALE, 0)];
		view.backgroundColor = [UIColor whiteColor];
		view.layer.masksToBounds = YES;
		view.layer.cornerRadius = 5*SCREEN_SCALE;
		
		UIImageView *qrcode = [[UIImageView alloc]initWithFrame:CGRectMake((view.width-200*SCREEN_SCALE)/2, 25*SCREEN_SCALE, 200*SCREEN_SCALE, 200*SCREEN_SCALE)];
		qrcode.image = [QRCodeGenerator createQRCode:[NSString stringWithFormat:@"%@\n%@", _title, _url] size:qrcode.size];
		[qrcode addLongPressGestureRecognizerWithTarget:self action:@selector(saveQrcode:)];
		[view addSubview:qrcode];
		
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, qrcode.bottom, view.width, 48*SCREEN_SCALE)];
		label.text = @"（长按二维码保存到相册）";
		label.textColor = COLOR999;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(12);
		label.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		
		UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(qrcode.left, label.bottom, qrcode.width, 38*SCREEN_SCALE)];
		btn.titleLabel.font = FONT(14);
		btn.backgroundColor = [UIColor clearColor];
		[btn setTitle:@"取消" forState:UIControlStateNormal];
		[btn setTitleColor:COLOR666 forState:UIControlStateNormal];
		btn.layer.borderColor = COLOR666.CGColor;
		btn.layer.borderWidth = 0.5*SCREEN_SCALE;
		btn.layer.masksToBounds = YES;
		btn.layer.cornerRadius = 3*SCREEN_SCALE;
		[btn addTarget:self action:^(id target, id sender) {
			[APPCurrentController dismissAlertView:DYAlertViewDown];
		}];
		[view addSubview:btn];
		
		view.height = btn.bottom + 20*SCREEN_SCALE;
		
		[self close:^{
			[APPCurrentController presentAlertView:view animation:DYAlertViewDown];
		}];
		return;
	}
	[self close];
	
	NSArray *array = SHARE_TYPE_ARRAY;
	NSString *type = sender.element[@"type"];
	NSString *title = _title;
	NSString *content = _content;
	NSString *url = _url;
	id image = _image;
	if (_models.isArray) {
		for (ShareHelperModel *model in _models) {
			if ([array[model.type] isEqualToString:type]) {
				if (model.title.length) title = model.title;
				if (model.content.length) content = model.content;
				if (model.url.length) url = model.url;
				if (model.image) image = model.image;
				break;
			}
		}
	}
	[ShareHelper shareWithType:type url:url title:title content:content image:image completion:_completion];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
	switch (result) {
		case MessageComposeResultSent:
			[ProgressHUD showError:@"发送成功"];
			break;
		case MessageComposeResultFailed:
			[ProgressHUD showError:@"短信发送失败"];
			break;
		default:
			break;
	}
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
	switch (result) {
		case MFMailComposeResultSent:
			[ProgressHUD showError:@"发送成功"];
			break;
		case MFMailComposeResultFailed:
			[ProgressHUD showError:@"邮件发送失败"];
			break;
		default:
			break;
	}
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveQrcode:(UIGestureRecognizer*)sender{
	if (sender.state == UIGestureRecognizerStateBegan) {
		UIImageView *qrcode = (UIImageView*)sender.view;
		UIImageWriteToSavedPhotosAlbum(qrcode.image, nil, nil, nil);
		[ProgressHUD showSuccess:@"成功保存"];
	}
}

+ (void)shareWithUrl:(NSString*)url title:(NSString*)title content:(NSString*)content image:(id)image completion:(void (^)(ShareHelperResult result))completion{
	ShareHelper *shareView = [ShareHelper sharedHelper];
	shareView.title = title;
	shareView.content = content;
	shareView.url = url;
	shareView.image = image;
	shareView.completion = completion;
	[shareView show];
}

+ (void)shareWithType:(NSString*)type url:(NSString*)url title:(NSString*)title content:(NSString*)content image:(id)image completion:(void (^)(ShareHelperResult result))completion{
	if (!title.length || !url.length) {
		[ProgressHUD showError:@"缺少需分享的标题、网址"];
		return;
	}
	NSInteger tag = [SHARE_TYPE_ARRAY indexOfObject:type];
	BOOL hasClinet = NO;
	switch (tag) {
		case ShareHelperTypeSina:hasClinet = (([ShareHelper isSinaInstalled] || NO_CLINET_GOON) && [SINA_APPKEY length]);break;
		case ShareHelperTypeWXSession:
		case ShareHelperTypeWXTimeLine:
		case ShareHelperTypeWXFavorite:hasClinet = (([ShareHelper isWXAppInstalled] || NO_CLINET_GOON) && [WX_APPID length]);break;
		case ShareHelperTypeQQ:
		case ShareHelperTypeQZone:
		case ShareHelperTypeTencent:hasClinet = (([ShareHelper isQQInstalled] || NO_CLINET_GOON) && [QQ_APPID length]);break;
		default:hasClinet = YES;break;
	}
	if (!hasClinet) {
		[ProgressHUD showError:@"设备没有可分享的客户端"];
		return;
	}
	[ShareHelper registerAppWithType:tag];
	[ProgressHUD show:nil];
	[ProgressHUD dismiss:3];
	UMSocialPlatformType platformType;
	switch (tag) {
		case ShareHelperTypeSina:{platformType = UMSocialPlatformType_Sina;break;}
		case ShareHelperTypeWXSession:{platformType = UMSocialPlatformType_WechatSession;break;}
		case ShareHelperTypeWXTimeLine:{platformType = UMSocialPlatformType_WechatTimeLine;break;}
		case ShareHelperTypeWXFavorite:{platformType = UMSocialPlatformType_WechatFavorite;break;}
		case ShareHelperTypeQQ:{platformType = UMSocialPlatformType_QQ;break;}
		case ShareHelperTypeQZone:{platformType = UMSocialPlatformType_Qzone;break;}
		case ShareHelperTypeTencent:{platformType = UMSocialPlatformType_TencentWb;break;}
		case ShareHelperTypeCopy:{
			UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
			pasteBoard.string = [NSString stringWithFormat:@"%@\n%@", title, url];
			[ProgressHUD showSuccess:@"已复制"];
			return;
			break;
		}
		default:{
			return;
			break;
		}
	}
	void (^postShare)(UMSocialPlatformType type, NSString *title, NSString *content, id image, NSString *url, void (^completion)(ShareHelperResult result)) = ^(UMSocialPlatformType type, NSString *title, NSString *content, id image, NSString *url, void (^completion)(ShareHelperResult result)){
		UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
		//创建网页内容对象
		UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:image];
		shareObject.webpageUrl = url;
		messageObject.shareObject = shareObject;
		id currentViewController = nil;
		if (type==UMSocialPlatformType_Sms || type==UMSocialPlatformType_Email) currentViewController = APPCurrentController;
		[[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:currentViewController completion:^(id data, NSError *error) {
			if (error) {
				NSLog(@"Share Failed: %@", error);
				switch (tag) {
					case ShareHelperTypeSina:[ShareHelper logoutWithSina];break;
					case ShareHelperTypeWXSession:
					case ShareHelperTypeWXTimeLine:
					case ShareHelperTypeWXFavorite:[ShareHelper logoutWithWechat];break;
					case ShareHelperTypeQQ:
					case ShareHelperTypeQZone:
					case ShareHelperTypeTencent:[ShareHelper logoutWithQQ];break;
				}
				if (completion) {
					completion(ShareHelperResultFail);
				} else {
					[ProgressHUD showError:@"分享失败"];
				}
			}else{
				//NSLog(@"response data is %@", data);
				if (completion) {
					completion(ShareHelperResultSuccess);
				} else {
					[ProgressHUD showSuccess:@"分享成功"];
				}
			}
		}];
	};
	if (!image) image = IMGAPPICON;
	if ([image isKindOfClass:[NSString class]]) {
		[ProgressHUD show:nil];
		[image cacheImageAndCompletion:^(UIImage *image, NSData *imageData) {
			[ProgressHUD dismiss];
			if (image) {
				postShare(platformType, title, content, image, url, completion);
			} else {
				postShare(platformType, title, content, IMGAPPICON, url, completion);
			}
		}];
	} else {
		postShare(platformType, title, content, image, url, completion);
	}
}

+ (void)shareWithSchemeUrl:(NSString*)schemeUrl completion:(void (^)(ShareHelperResult result))completion{
	[ShareHelper shareWithSchemeUrl:schemeUrl url:nil completion:completion];
}

+ (void)shareWithSchemeUrl:(NSString*)schemeUrl url:(NSString*)url completion:(void (^)(ShareHelperResult result))completion{
	if (![schemeUrl hasPrefix:[NSString stringWithFormat:@"%@://share?", APP_SCHEME]]) return;
	NSDictionary *params = schemeUrl.params;
	NSString *title = params[@"title"];
	NSString *shareurl = params[@"url"];
	NSString *content = params[@"content"];
	NSString *image = params[@"image"];
	NSString *type = params[@"type"];
	if (url.length) shareurl = [url copy];
	if (!type.length) type = @"2";
	if (!content.length) content = title;
	if (!title.length || !shareurl.length) {
		[ProgressHUD showError:@"缺少需分享的标题、网址"];
		return;
	}
	BOOL hasClinet = NO;
	switch (type.integerValue) {
		case ShareHelperTypeSina:hasClinet = ([ShareHelper isSinaInstalled] || NO_CLINET_GOON);break;
		case ShareHelperTypeWXSession:
		case ShareHelperTypeWXTimeLine:
		case ShareHelperTypeWXFavorite:hasClinet = ([ShareHelper isWXAppInstalled] || NO_CLINET_GOON);break;
		case ShareHelperTypeQQ:
		case ShareHelperTypeQZone:
		case ShareHelperTypeTencent:hasClinet = ([ShareHelper isQQInstalled] || NO_CLINET_GOON);break;
	}
	if (!hasClinet) {
		[ProgressHUD showError:@"设备没有可分享的客户端"];
		return;
	}
	type = [SHARE_TYPE_ARRAY objectAtIndex:type.integerValue];
	if (image.length) {
		[ProgressHUD show:nil];
		[image cacheImageAndCompletion:^(UIImage *image, NSData *imageData) {
			[ProgressHUD dismiss];
			if (image) {
				[ShareHelper shareWithType:type url:shareurl title:title content:content image:image completion:completion];
			} else {
				[ShareHelper shareWithType:type url:shareurl title:title content:content image:IMGAPPICON completion:completion];
			}
		}];
	} else {
		[ShareHelper shareWithType:type url:shareurl title:title content:content image:IMGAPPICON completion:completion];
	}
}

#define mark - helper
+ (BOOL)isSinaInstalled{
	//return [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_Sina] && [[UMSocialManager defaultManager] isSupport:UMSocialPlatformType_Sina];
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sinaweibo://"]];
}

+ (BOOL)isWXAppInstalled{
	//return [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatTimeLine] && [[UMSocialManager defaultManager] isSupport:UMSocialPlatformType_WechatTimeLine];
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
	//return [WXApi isWXAppInstalled];
}

+ (BOOL)isQQInstalled{
	//return [[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ] && [[UMSocialManager defaultManager] isSupport:UMSocialPlatformType_QQ];
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]];
	//return [QQApiInterface isQQInstalled];
}

+ (BOOL)hasClient{
	return [ShareHelper isWXAppInstalled] || [ShareHelper isQQInstalled] || [ShareHelper isSinaInstalled];
}

+ (BOOL)isAlipayInstalled{
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]];
}

//向对应的客户端注册APP
+ (void)registerAppWithType:(ShareHelperType)type{
	switch (type) {
		case ShareHelperTypeSina:{
			[[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:SINA_APPKEY  appSecret:SINA_SECRET redirectURL:SINA_SSOURL];
			break;
		}
		case ShareHelperTypeWXSession:{
			[[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WX_APPID appSecret:WX_APPSECRET redirectURL:nil];
			break;
		}
		case ShareHelperTypeWXTimeLine:{
			[[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatTimeLine appKey:WX_APPID appSecret:WX_APPSECRET redirectURL:nil];
			break;
		}
		case ShareHelperTypeWXFavorite:{
			[[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatFavorite appKey:WX_APPID appSecret:WX_APPSECRET redirectURL:nil];
			break;
		}
		case ShareHelperTypeQQ:{
			[[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQ_APPID appSecret:QQ_APPKEY redirectURL:QQ_SSOURL];
			break;
		}
		case ShareHelperTypeQZone:{
			[[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Qzone appKey:QQ_APPID appSecret:QQ_APPKEY redirectURL:QQ_SSOURL];
			break;
		}
		case ShareHelperTypeTencent:{
			[[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_TencentWb appKey:QQ_APPID appSecret:QQ_APPKEY redirectURL:QQ_SSOURL];
			break;
		}
		default:break;
	}
}

#pragma mark - 第三方登录
+ (NSArray*)loginWithType:(NSArray*)type completion:(void (^)(NSMutableDictionary* postData))completion{
	if (!type.isArray) type = @[@"sina", @"wxsession", @"qq"];
	NSMutableArray *array = [NSMutableArray arrayWithArray:SHARE_TYPE_ARRAY];
	[array addObject:@"taobao"];
	NSMutableArray *btns = [[NSMutableArray alloc]init];
	CGFloat width = 54*SCREEN_SCALE;
	for (int i=0; i<type.count; i++) {
		NSInteger tag = [array indexOfObject:type[i]];
		switch (tag) {
			case ShareHelperTypeSina:{
				if (![ShareHelper isSinaInstalled] || !SINA_APPKEY.length) continue;
				break;
			}
			case ShareHelperTypeWXSession:
			case ShareHelperTypeWXTimeLine:
			case ShareHelperTypeWXFavorite:{
				if (![ShareHelper isWXAppInstalled] || !WX_APPID.length) continue;
				break;
			}
			case ShareHelperTypeQQ:
			case ShareHelperTypeQZone:
			case ShareHelperTypeTencent:{
				if (![ShareHelper isQQInstalled] || !QQ_APPID.length) continue;
				break;
			}
			case ShareHelperTypeTaobao:
				break;
			default:{
				continue;
				break;
			}
		}
		UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, width)];
		btn.backgroundColor = [UIColor clearColor];
		btn.adjustsImageWhenHighlighted = NO;
		[btn setBackgroundImage:[UIImage imageNamed:type[i]] forState:UIControlStateNormal];
		[btn addTarget:self action:^(id target, id sender) {
			switch (tag) {
				case ShareHelperTypeSina:{
					[ShareHelper loginWithSina:completion];
					break;
				}
				case ShareHelperTypeWXSession:
				case ShareHelperTypeWXTimeLine:
				case ShareHelperTypeWXFavorite:{
					[ShareHelper loginWithWechat:completion];
					break;
				}
				case ShareHelperTypeQQ:
				case ShareHelperTypeQZone:
				case ShareHelperTypeTencent:{
					[ShareHelper loginWithQQ:completion];
					break;
				}
				case ShareHelperTypeTaobao:{
					[ShareHelper loginWithTaobao:completion];
					break;
				}
				default:{
					break;
				}
			}
		}];
		[btns addObject:btn];
	}
	return btns;
}

#pragma mark - 微博登录
+ (void)loginWithSina:(void (^)(NSMutableDictionary *postData))completion{
	[ShareHelper logoutWithSina];
	[ShareHelper registerAppWithType:ShareHelperTypeSina];
	[[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_Sina currentViewController:APPCurrentController completion:^(id result, NSError *error) {
		if (error) {
			[ProgressHUD showError:error.localizedDescription];
		} else {
			UMSocialUserInfoResponse *resp = result;
			[ProgressHUD show:nil];
			NSDictionary *sourceData = [NSDictionary dictionaryWithDictionary:resp.originalResponse];
			[Global downloadImage:resp.iconurl completion:^(UIImage *image, NSData *imageData, BOOL exist) {
				[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
					if ([json[@"code"]integerValue]==200) {
						if (completion) {
							NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
							NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
							[postData setObject:resp.name forKey:@"name"];
							[postData setObject:avatarUrl forKey:@"avatar"];
							[postData setObject:resp.unionGender forKey:@"sex"];
							[postData setObject:[sourceData[@"location"] replace:@" " to:@""] forKey:@"address"];
							[postData setObject:sourceData[@"uid"] forKey:@"hash"];
							[postData setObject:@"weibo" forKey:@"source"];
							[postData setObject:@"sina" forKey:@"type"];
							[postData setObject:sourceData[@"description"] forKey:@"description"];
							[postData setObject:sourceData[@"favourites_count"] forKey:@"favourites_count"];
							[postData setObject:sourceData[@"followers_count"] forKey:@"followers_count"];
							[postData setObject:sourceData[@"friends_count"] forKey:@"friends_count"];
							[postData setObject:sourceData[@"statuses_count"] forKey:@"statuses_count"];
							[postData setObject:resp.uid forKey:@"uid"];
							[postData setObject:resp.accessToken forKey:@"access_token"];
							completion(postData);
						}
					} else {
						[ProgressHUD showError:json[@"message"]];
					}
				}];
			}];
		}
	}];
}

#pragma mark - 微信登录
+ (void)loginWithWechat:(void (^)(NSMutableDictionary *postData))completion{
	[ShareHelper logoutWithWechat];
	[ShareHelper registerAppWithType:ShareHelperTypeWXSession];
	[[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:APPCurrentController completion:^(id result, NSError *error) {
		if (error) {
			[ProgressHUD showError:error.localizedDescription];
		} else {
			UMSocialUserInfoResponse *resp = result;
			[ProgressHUD show:nil];
			NSDictionary *sourceData = [NSDictionary dictionaryWithDictionary:resp.originalResponse];
			[Global downloadImage:resp.iconurl completion:^(UIImage *image, NSData *imageData, BOOL exist) {
				[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
					if ([json[@"code"]integerValue]==200) {
						if (completion) {
							NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
							NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
							[postData setObject:resp.name forKey:@"name"];
							[postData setObject:avatarUrl forKey:@"avatar"];
							[postData setObject:resp.unionGender forKey:@"sex"];
							[postData setObject:FORMAT(@"%@%@%@", sourceData[@"country"], sourceData[@"province"], sourceData[@"city"]) forKey:@"address"];
							[postData setObject:resp.openid forKey:@"hash"];
							[postData setObject:@"wechat" forKey:@"source"];
							[postData setObject:@"wxsession" forKey:@"type"];
							[postData setObject:sourceData[@"country"] forKey:@"country"];
							[postData setObject:sourceData[@"province"] forKey:@"province"];
							[postData setObject:sourceData[@"city"] forKey:@"city"];
							[postData setObject:sourceData[@"language"] forKey:@"language"];
							[postData setObject:resp.openid forKey:@"openid"];
							[postData setObject:resp.accessToken forKey:@"access_token"];
							[postData setObject:resp.uid forKey:@"unionid"];
							completion(postData);
						}
					} else {
						[ProgressHUD showError:json[@"message"]];
					}
				}];
			}];
		}
	}];
}

#pragma mark - 原生微信登录
/*
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
	if ([@"wxauth" getUserDefaultsBool]) {
		return [WXApi handleOpenURL:url delegate:(id<WXApiDelegate>)[ShareHelper sharedHelper]];
	}
	return YES;
}
*/
+ (void)loginWithWechatAuth:(void (^)(NSMutableDictionary *postData))completion{
	if (!completion) return;
	[ShareHelper logoutWithWechat];
	[ShareHelper registerAppWithType:ShareHelperTypeWXSession];
	[WXApi registerApp:WX_APPID];
	[@"wxauth" setUserDefaultsWithData:@YES];
	KEYWINDOW.element[@"wxauthCompletion"] = completion;
	SendAuthReq *req = [[SendAuthReq alloc]init];
	req.scope = @"snsapi_userinfo";
	req.state = @"STATE";
	[WXApi sendReq:req];
}
//只获取code
+ (void)loginWithWechatCode:(void (^)(NSString *code))completion{
	if (!completion) return;
	[ShareHelper logoutWithWechat];
	[ShareHelper registerAppWithType:ShareHelperTypeWXSession];
	[WXApi registerApp:WX_APPID];
	[@"wxauth" setUserDefaultsWithData:@YES];
	KEYWINDOW.element[@"wxauthCompletion"] = completion;
	KEYWINDOW.element[@"wxauthOnlyCode"] = @YES;
	SendAuthReq *req = [[SendAuthReq alloc]init];
	req.scope = @"snsapi_userinfo";
	req.state = @"STATE";
	[WXApi sendReq:req];
}
//只获取code,然后把code传到api的interface去换取access_token与获取用户资料(为防止返回的用户资料不一致,例如地区)
+ (void)loginWithWechatCodeToInterface:(NSDictionary*)params completion:(void (^)(NSMutableDictionary *json))completion{
	if (!completion) return;
	[ShareHelper logoutWithWechat];
	[ShareHelper registerAppWithType:ShareHelperTypeWXSession];
	[WXApi registerApp:WX_APPID];
	[@"wxauth" setUserDefaultsWithData:@YES];
	KEYWINDOW.element[@"wxauthCompletion"] = completion;
	KEYWINDOW.element[@"wxauthInterfaceParams"] = params;
	KEYWINDOW.element[@"wxauthInterface"] = @YES;
	SendAuthReq *req = [[SendAuthReq alloc]init];
	req.scope = @"snsapi_userinfo";
	req.state = @"STATE";
	[WXApi sendReq:req];
}
- (void)onResp:(BaseResp *)resp{
	if ([resp isKindOfClass:[SendAuthResp class]]) {
		[@"wxauth" deleteUserDefaults];
		if ([(SendAuthResp*)resp code]) {
			BOOL wxauthOnlyCode = [KEYWINDOW.element[@"wxauthOnlyCode"] boolValue];
			KEYWINDOW.removeElement = @"wxauthOnlyCode";
			if (wxauthOnlyCode) {
				void (^completion)(NSString *code) = KEYWINDOW.element[@"wxauthCompletion"];
				KEYWINDOW.removeElement = @"wxauthCompletion";
				if (completion) completion([(SendAuthResp*)resp code]);
				return;
			}
			void (^completion)(NSMutableDictionary *json) = KEYWINDOW.element[@"wxauthCompletion"];
			KEYWINDOW.removeElement = @"wxauthCompletion";
			BOOL wxauthInterface = [KEYWINDOW.element[@"wxauthInterface"] boolValue];
			KEYWINDOW.removeElement = @"wxauthInterface";
			if (wxauthInterface) {
				NSDictionary *params = KEYWINDOW.element[@"wxauthInterfaceParams"];
				KEYWINDOW.removeElement = @"wxauthInterfaceParams";
				NSMutableString *strings = [[NSMutableString alloc]init];
				if (params.isDictionary) {
					for (NSString *key in params) {
						[strings appendFormat:@"&%@=%@", key, [STRING(params[key])URLEncode]];
					}
				}
				NSString *url = FORMAT(@"%@/wx_interface.php?getcode=getcode&code=%@%@", API_URL, [(SendAuthResp*)resp code], strings);
				[Common getApiWithUrl:url success:^(NSMutableDictionary *json) {
					//NSLog(@"%@", json.descriptionASCII);
					if ([json[@"errcode"]isset]) {
						NSLog(@"api userinfo: %@\n%@", json[@"errcode"], json[@"errmsg"]);
						[ProgressHUD showError:FORMAT(@"获取数据错误，错误码: %@", json[@"errcode"])];
						return;
					}
					if (![json[@"openid"]isset]) {completion(json);return;}
					NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
					[postData setObject:json[@"nickname"] forKey:@"name"];
					[postData setObject:([json[@"sex"]intValue]==1?@"男":@"女") forKey:@"sex"];
					[postData setObject:FORMAT(@"%@%@%@", json[@"country"], json[@"province"], json[@"city"]) forKey:@"address"];
					[postData setObject:json[@"openid"] forKey:@"hash"];
					[postData setObject:@"wechat" forKey:@"source"];
					[postData setObject:@"wxsession" forKey:@"type"];
					[postData setObject:json[@"country"] forKey:@"country"];
					[postData setObject:json[@"province"] forKey:@"province"];
					[postData setObject:json[@"city"] forKey:@"city"];
					[postData setObject:json[@"language"] forKey:@"language"];
					[postData setObject:json[@"openid"] forKey:@"openid"];
					if (json[@"headimgurl"]) {
						[json[@"headimgurl"] cacheImageAndCompletion:^(UIImage *image, NSData *imageData) {
							[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
								if ([json[@"code"]integerValue]==200) {
									NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
									[postData setObject:avatarUrl forKey:@"avatar"];
									completion(postData);
								} else {
									[ProgressHUD showError:json[@"message"]];
								}
							}];
						}];
					} else {
						completion(postData);
					}
				} fail:nil];
				return;
			}
			[Common getApiWithUrl:FORMAT(@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WX_APPID, WX_APPSECRET, [(SendAuthResp*)resp code]) success:^(NSMutableDictionary *json) {
				if ([json[@"errcode"]isset]) {
					NSLog(@"access_token: %@\n%@", json[@"errcode"], json[@"errmsg"]);
					[ProgressHUD showError:FORMAT(@"获取数据错误，错误码: %@", json[@"errcode"])];
					return;
				}
				NSString *access_token = json[@"access_token"];
				NSString *openid = json[@"openid"];
				[Common getApiWithUrl:FORMAT(@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@&lang=zh_CN", access_token, openid) success:^(NSMutableDictionary *json) {
					//NSLog(@"%@", json.descriptionASCII);
					if ([json[@"errcode"]isset]) {
						NSLog(@"userinfo: %@\n%@", json[@"errcode"], json[@"errmsg"]);
						[ProgressHUD showError:FORMAT(@"获取数据错误，错误码: %@", json[@"errcode"])];
						return;
					}
					NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
					[postData setObject:json[@"nickname"] forKey:@"name"];
					[postData setObject:([json[@"sex"]intValue]==1?@"男":@"女") forKey:@"sex"];
					[postData setObject:FORMAT(@"%@%@%@", json[@"country"], json[@"province"], json[@"city"]) forKey:@"address"];
					[postData setObject:json[@"openid"] forKey:@"hash"];
					[postData setObject:@"wechat" forKey:@"source"];
					[postData setObject:@"wxsession" forKey:@"type"];
					[postData setObject:json[@"country"] forKey:@"country"];
					[postData setObject:json[@"province"] forKey:@"province"];
					[postData setObject:json[@"city"] forKey:@"city"];
					[postData setObject:json[@"language"] forKey:@"language"];
					[postData setObject:json[@"openid"] forKey:@"openid"];
					if (json[@"headimgurl"]) {
						[json[@"headimgurl"] cacheImageAndCompletion:^(UIImage *image, NSData *imageData) {
							[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
								if ([json[@"code"]integerValue]==200) {
									NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
									[postData setObject:avatarUrl forKey:@"avatar"];
									completion(postData);
								} else {
									[ProgressHUD showError:json[@"message"]];
								}
							}];
						}];
					} else {
						completion(postData);
					}
				} fail:nil];
			} fail:nil];
		}
	}
}

#pragma mark - QQ登录
+ (void)loginWithQQ:(void (^)(NSMutableDictionary *postData))completion{
	[ShareHelper logoutWithQQ];
	[ShareHelper registerAppWithType:ShareHelperTypeQQ];
	[[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_QQ currentViewController:APPCurrentController completion:^(id result, NSError *error) {
		if (error) {
			[ProgressHUD showError:error.localizedDescription];
		} else {
			UMSocialUserInfoResponse *resp = result;
			[ProgressHUD show:nil];
			//NSDictionary *sourceData = [NSDictionary dictionaryWithDictionary:resp.originalResponse];
			[Global downloadImage:resp.iconurl completion:^(UIImage *image, NSData *imageData, BOOL exist) {
				[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
					if ([json[@"code"]integerValue]==200) {
						if (completion) {
							NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
							NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
							[postData setObject:resp.name forKey:@"name"];
							[postData setObject:avatarUrl forKey:@"avatar"];
							[postData setObject:resp.unionGender forKey:@"sex"];
							[postData setObject:resp.usid forKey:@"hash"];
							[postData setObject:@"qq" forKey:@"source"];
							[postData setObject:@"qq" forKey:@"type"];
							[postData setObject:resp.usid forKey:@"uid"];
							[postData setObject:resp.accessToken forKey:@"access_token"];
							completion(postData);
						}
					} else {
						[ProgressHUD showError:json[@"message"]];
					}
				}];
			}];
		}
	}];
}

#pragma mark - 腾讯微博登录
+ (void)loginWithTencentWb:(void (^)(NSMutableDictionary *postData))completion{
	[ShareHelper logoutWithTencentWb];
	[ShareHelper registerAppWithType:ShareHelperTypeTencent];
	[[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_TencentWb currentViewController:APPCurrentController completion:^(id result, NSError *error) {
		if (error) {
			[ProgressHUD showError:error.localizedDescription];
		} else {
			UMSocialUserInfoResponse *resp = result;
			[ProgressHUD show:nil];
			//NSDictionary *sourceData = [NSDictionary dictionaryWithDictionary:resp.originalResponse];
			[Global downloadImage:resp.iconurl completion:^(UIImage *image, NSData *imageData, BOOL exist) {
				[imageData UploadToUpyun:@"uploadfiles/avatar" completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
					if ([json[@"code"]integerValue]==200) {
						if (completion) {
							NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", UPYUN_IMGURL, json[@"url"]];
							NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
							[postData setObject:resp.name forKey:@"name"];
							[postData setObject:avatarUrl forKey:@"avatar"];
							[postData setObject:resp.uid forKey:@"hash"];
							[postData setObject:@"tencentwb" forKey:@"source"];
							[postData setObject:@"tencentwb" forKey:@"type"];
							[postData setObject:resp.uid forKey:@"uid"];
							[postData setObject:resp.accessToken forKey:@"access_token"];
							completion(postData);
						}
					} else {
						[ProgressHUD showError:json[@"message"]];
					}
				}];
			}];
		}
	}];
}

#pragma mark - 淘宝登录
+ (void)loginWithTaobao:(void (^)(NSMutableDictionary *postData))completion{
	TaobaoOauth *g = [[TaobaoOauth alloc]init];
	g.completionOauth = ^(NSMutableDictionary *postData){
		if (completion) completion(postData);
	};
	UIViewController *viewController = APPCurrentController;
	UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	viewController.navigationItem.backBarButtonItem = backBtn;
	[viewController.navigationController pushViewController:g animated:YES];
}

#pragma mark - 微博退出
+ (void)logoutWithSina{
	[[UMSocialManager defaultManager] cancelAuthWithPlatform:UMSocialPlatformType_Sina completion:nil];
}

#pragma mark - 微信退出
+ (void)logoutWithWechat{
	[[UMSocialManager defaultManager] cancelAuthWithPlatform:UMSocialPlatformType_WechatSession completion:nil];
}

#pragma mark - QQ退出
+ (void)logoutWithQQ{
	[[UMSocialManager defaultManager] cancelAuthWithPlatform:UMSocialPlatformType_QQ completion:nil];
}

#pragma mark - 腾讯微博退出
+ (void)logoutWithTencentWb{
	[[UMSocialManager defaultManager] cancelAuthWithPlatform:UMSocialPlatformType_TencentWb completion:nil];
}

@end

#pragma mark - 淘宝授权登录
@implementation TaobaoOauth
- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"淘宝授权登录";
	self.view.backgroundColor = [UIColor whiteColor];
	WKWebView *webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	webView.scrollView.bounces = NO;
	webView.navigationDelegate = self;
	[self.view addSubview:webView];
	//需与服务器协助, 具体代码查看 TaobaoOauth.php 文件
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api.php?app=oauth&act=taobao", API_URL]];
	[webView loadRequest:[[NSURLRequest alloc]initWithURL:url]];
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
	[ProgressHUD show:nil];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
	NSLog(@"%@", error.userInfo);
	[ProgressHUD dismiss];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
	[ProgressHUD dismiss];
}
//JS与OC交互
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
	[ProgressHUD dismiss];
	if (_completionOauth) {
		NSString *url = navigationAction.request.URL.absoluteString;
		if ([url hasPrefix:[NSString stringWithFormat:@"%@/api.php?app=oauth&act=taobao_complete", API_URL]]) {
			NSArray *arr = [url split:@"taobao_user_id="];
			NSString *p = arr[1];
			arr = [p split:@"&taobao_user_nick="];
			NSString *taobao_user_id = arr[0];
			NSString *taobao_user_nick = arr[1];
			NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
			[postData setObject:taobao_user_nick forKey:@"name"];
			[postData setObject:taobao_user_id forKey:@"hash"];
			[postData setObject:@"taobao" forKey:@"source"];
			[postData setObject:@"taobao" forKey:@"type"];
			_completionOauth(postData);
		}
	}
	decisionHandler(WKNavigationActionPolicyAllow);
}
@end
