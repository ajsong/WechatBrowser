//
//  GConfig.h
//
//  Created by ajsong on 2015-4-21.
//  Copyright (c) 2014 @jsong. All rights reserved.
//

#define SDK_VERSION @"9.4.20190520"
#define API_PRODUCTION 0 //生产环境

//API接口
#if API_PRODUCTION==0
#define API_URL @"http://yezhan.softstao.com" //API接口服务器地址
#else
#define API_URL @"http://yezhan.softstao.com"
#endif
#define API_FILE @"api.php" //API接口文件
#define API_PARAMETER [NSString stringWithFormat:@"&sign=%@", SIGN] //API接口追加参数, 格式: &field1=value1&field2=value2
#define API_AUTH @"" //API接口Authorization验证, 一般格式为base64(username:password), 可用 [SIGN base64] 代替
#define API_ERROR_SENDEMAIL @"" //API接口出错发送到指定邮箱, 留空不发送
#define API_PUBLIC_KEY @"" //API接口公钥, 留空即不加密数据传输
#define API_SIGN_KEY @"" //验证KEY
#define API_REQUEST_RETRY 3 //API请求超时重试次数
#define API_CLEAR_BADGE 0 //APP切换为前台即调用clear_badge接口同步清除角标

#define API_KEY_ERROR @"error" //API接口返回成功key
#define API_KEY_ERROR_CODE 0 //API接口返回成功key的值
#define API_KEY_MSG @"msg" //API接口返回信息key
#define API_KEY_MSG_TYPE @"msg_type" //API接口返回信息值key

#define PERSON ([[@"person" getUserDefaultsDictionary]isDictionary] ? [@"person" getUserDefaultsDictionary] : nil)
#define SIGN ((PERSON.isDictionary && [PERSON[@"sign"]isset]) ? PERSON[@"sign"] : @"")
#define UDID [@"udid" getUserDefaultsString]

#define MJREFRESH_WRITE_TEXT APP_SCHEME
#define MJREFRESH_WRITE_FONT [UIFont fontWithName:@"Euphemia UCAS" size:30*SCREEN_SCALE]

#define COLORBACK COLORRGB(@"f3f3f3")
#define COLORNAVBG COLORRGB(@"fff")
#define COLORNAVTEXT COLORRGB(@"444")
#define COLORMAIN COLORRGB(@"00591b")
#define COLORSUB COLORRGB(@"f8486e")
#define COLORTEXT COLORRGB(@"404040")
#define COLORSUBTEXT COLORRGB(@"a8a8a8")
#define COLORPRICE COLORRGB(@"ce0000")

//应用信息
#define APP_SCHEME @"wcb" //应用Scheme
#define APP_ID @"" //APP STORE的应用ID,一般为检查新版本用

//友盟
#define UM_APPKEY @"" //AppKey
#define UM_ANALYTICS 1 //使用友盟安装统计、跟踪
#define UM_SHARE 1 //使用友盟快速登录、分享
#define UM_PUSH 1 //使用友盟消息推送

//新浪微博分享(需在友盟后台设置)
#define SINA_APPKEY @"" //AppKey
#define SINA_SECRET @"" //AppSecret
#define SINA_SSOURL @"http://sns.whalecloud.com/sina2/callback" //新浪微博回调地址,必须跟新浪微博后台设置的回调地址一致

//QQ分享
#define QQ_APPID @"" //AppID
#define QQ_APPKEY @"" //AppKey
#define QQ_SSOURL @"http://mobile.umeng.com/social" //QQ回调地址,必须跟QQ互联后台设置的回调地址一致
//终端输入echo 'ibase=10;obase=16;801312852'|bc

//微信分享(支付)
#define WX_APPID @"" //AppID
#define WX_APPSECRET @"" //AppSecret
#define WX_MCHID @"" //商户号
#define WX_KEY @"" //商户API密钥
#define WX_NOTIFY_URL [NSString stringWithFormat:@"%@/notify_url.php", API_URL] //支付结果回调页面

//支付宝
#define ALIPAY_PARTNER @"" //合作身份者PID
#define ALIPAY_SELLER @"" //卖家支付宝帐户
#define ALIPAY_PRIVATEKEY @"" //商户私钥
#define ALIPAY_NOTIFY_URL [NSString stringWithFormat:@"%@/notify_url.php", API_URL] //支付结果回调页面
#define ALIPAY_APPSCHEME APP_SCHEME //应用注册Scheme,同时需要在Info.plist定义URL types

//ApplePay
#define APPLEPAY_MERCHANTID @""
#define APPLEPAY_NOTIFY_URL [NSString stringWithFormat:@"%@/notify_url.php", API_URL] //支付结果回调页面

//腾讯Bugly
#define BUGLY_APPID @""

//环信
#define EASEMOB_ENBLED 0 //启用环信
#define EASEMOB_USE_CALL 0 //启用环信视频通话模块
#define EASEMOB_APPKEY @""
#define EASEMOB_APNSCERTNAME @""

//又拍云
#define UPYUN_IMGURL @""
#define UPYUN_BUCKET @""
#define UPYUN_SECRET @""

//七牛
#define QINIU_IMGURL @""
#define QINIU_BUCKET @""
#define QINIU_ACCESSKey @""
#define QINIU_SECRETKey @""

//百度接口
//城市范围内的关键字地点
#define BAIDU_PLACE(keyword, city) [NSString stringWithFormat:@"http://api.map.baidu.com/place/v2/search?q=%@&region=%@&output=json&ak=bwaWdfBatpKYvBGxOdne78Ij", keyword, city]
//经纬度转地点
#define BAIDU_GEOCODER(lat, lng) [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder/v2/?location=%@,%@&output=json&ak=bwaWdfBatpKYvBGxOdne78Ij", lat, lng]
//GPS坐标转百度坐标
#define BAIDU_GEOCONV(lat, lng) [NSString stringWithFormat:@"http://api.map.baidu.com/geoconv/v1/?coords=%@,%@&ak=8dCDnV31Xg1QBbrWyrHmquR3", lng, lat]
//获取当前位置天气
#define BAIDU_WEATHER @"http://www.baidu.com/home/xman/data/superload?type=weather"

/*
[[IQKeyboardManager sharedManager] setEnable:NO]; //关闭智能键盘
[[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:0]; //键盘距离UITextField
[[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:NO]; //关闭点击外部关闭键盘
[[IQKeyboardManager sharedManager] considerToolbarPreviousNextInViewClass:[UIScrollView class]]; //在UIScrollView内所有UITextField都使用Toolbar
textField.inputAccessoryView = [[UIView alloc]init]; //不使用UIToolbar

两个数字比较大小, 取平均值法
大的为 (a+b + abs(a-b)) / 2
小的为 (a+b - abs(a-b)) / 2
如果取 a/b 余数不为0, 则说明a>b
(a / b) ? a : b

链式语法
- (UIView *(^)(CGFloat))Width{
	return ^id(CGFloat width){
		self.width = width;
		return self;
	};
}
view.Width(100).other2();

定义block
typedef void(^MyBlock)(NSString *text);

有返回值的自定义宏
#define MyMacro(param)\
({\
	NSString *name = @"";\
	if (param==1) name = @"YES";\
	name;\
})
*/
