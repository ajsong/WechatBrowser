//
//  ShareHelper.h
//
//  Created by ajsong on 15/4/14.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SHARE_TYPE_ARRAY @[@"sina", @"wxsession", @"wxtimeline", @"wxfavorite", @"qq", @"qzone", @"tencent", @"sms", @"email", @"link", @"qrcode"]
#define SHARE_NAME_ARRAY @[@"新浪微博", @"微信好友", @"微信朋友圈", @"微信收藏", @"腾讯QQ", @"QQ空间", @"腾讯微博", @"短信", @"邮件", @"链接", @"二维码"]

typedef enum : NSInteger {
	ShareHelperTypeSina = 0,
	ShareHelperTypeWXSession,
	ShareHelperTypeWXTimeLine,
	ShareHelperTypeWXFavorite,
	ShareHelperTypeQQ,
	ShareHelperTypeQZone,
	ShareHelperTypeTencent,
	ShareHelperTypeSms,
	ShareHelperTypeEmail,
	ShareHelperTypeLink,
	ShareHelperTypeQrcode,
	ShareHelperTypeCopy, //11
	ShareHelperTypeTaobao, //12
} ShareHelperType;

typedef enum : NSInteger {
	ShareHelperResultSuccess = 0,
	ShareHelperResultFail,
} ShareHelperResult;

@interface ShareHelperModel : NSObject
@property (nonatomic,assign) ShareHelperType type;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) id image;
@end

@interface ShareHelper : UIView
@property (nonatomic,strong) NSArray<ShareHelperModel*> *models; //独立设定各分享类型的标题、内容、链接、图片
@property (nonatomic,strong) NSString *title; //标题
@property (nonatomic,strong) NSString *content; //内容
@property (nonatomic,strong) NSString *url; //链接
@property (nonatomic,strong) id image; //图片, NSString|UIImage|NSData
@property (nonatomic,strong) NSArray *types; //sina, wxsession, wxtimeline, wxfavorite, qq, qzone, tencent, sms, email, link, qrcode
@property (nonatomic,assign) BOOL isToolbar; //使用UIToolbar作为背景色
@property (nonatomic,assign) BOOL debug; //调试模式, 没有分享客户端也继续显示
@property (nonatomic,copy) void (^completion)(ShareHelperResult result);

+ (ShareHelper*)sharedHelper;
//share
- (void)show;
- (void)show:(void (^)(ShareHelperResult result))completion;
- (void)close;
- (void)close:(void (^)(void))completion;
+ (void)shareWithType:(NSString*)type url:(NSString*)url title:(NSString*)title content:(NSString*)content image:(id)image completion:(void (^)(ShareHelperResult result))completion;
+ (void)shareWithUrl:(NSString*)url title:(NSString*)title content:(NSString*)content image:(id)image completion:(void (^)(ShareHelperResult result))completion;
+ (void)shareWithSchemeUrl:(NSString*)schemeUrl completion:(void (^)(ShareHelperResult result))completion;
+ (void)shareWithSchemeUrl:(NSString*)schemeUrl url:(NSString*)url completion:(void (^)(ShareHelperResult result))completion;
// xxx://share?url=xxxxxx&image=xxxxx&title=xxxx&content=xxxxx&type=x, url:不使用链接的url参数,使用方法的url参数作为分享的链接
+ (BOOL)isWXAppInstalled;
+ (BOOL)isQQInstalled;
+ (BOOL)isSinaInstalled;
+ (BOOL)hasClient;
+ (BOOL)isAlipayInstalled;
+ (void)registerAppWithType:(ShareHelperType)type;

//login, type:sina, wxsession, qq, tencent, taobao
+ (NSArray*)loginWithType:(NSArray*)type completion:(void (^)(NSMutableDictionary *postData))completion;
+ (void)loginWithSina:(void (^)(NSMutableDictionary *postData))completion;
+ (void)loginWithWechat:(void (^)(NSMutableDictionary *postData))completion;
+ (void)loginWithWechatAuth:(void (^)(NSMutableDictionary *postData))completion;
+ (void)loginWithWechatCode:(void (^)(NSString *code))completion;
+ (void)loginWithWechatCodeToInterface:(NSDictionary*)params completion:(void (^)(NSMutableDictionary *json))completion;
+ (void)loginWithQQ:(void (^)(NSMutableDictionary *postData))completion;
+ (void)loginWithTencentWb:(void (^)(NSMutableDictionary *postData))completion;
+ (void)loginWithTaobao:(void (^)(NSMutableDictionary *postData))completion;
+ (void)logoutWithSina;
+ (void)logoutWithWechat;
+ (void)logoutWithQQ;
+ (void)logoutWithTencentWb;
@end

@interface TaobaoOauth : UIViewController<WKNavigationDelegate>
@property (nonatomic,copy) void (^completionOauth)(NSMutableDictionary *postData);
@end
