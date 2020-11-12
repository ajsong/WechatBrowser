//
//  QiniuHelper.m
//
//  Created by ajsong on 2017/7/11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "QiniuHelper.h"

@implementation QiniuHelper

+ (QiniuHelper*)sharedHelper{
	static dispatch_once_t once = 0;
	static QiniuHelper *helper;
	dispatch_once(&once, ^{
		helper = [[QiniuHelper alloc] init];
		/*
		//国内https上传
		BOOL isHttps = TRUE;
		QNZone * httpsZone = [[QNAutoZone alloc] initWithHttps:isHttps dns:nil];
		QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
			builder.zone = httpsZone;
		}];
		//华东
		QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
			builder.zone = [QNZone zone0];
		}];
		//华北
		QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
			builder.zone = [QNZone zone1];
		}];
		//华南
		QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
			builder.zone = [QNZone zone2];
		}];
		//北美
		QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
			builder.zone = [QNZone zoneNa0];
		}];
		//海外https上传
		NSArray * upIps = [NSArray arrayWithObject:@"115.231.97.46"];
		QNServiceAddress *up = [[QNServiceAddress alloc] init:@"https://upload.qbox.me" ips:upIps];
		QNZone *zone0 = [[QNFixedZone alloc] initWithUp:up upBackup:nil];
		QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
			builder.zone = zone0;
		}];
		*/
		QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
			builder.zone = [QNZone zone0];
		}];
		helper.manager = [[QNUploadManager alloc] initWithConfiguration:config];
	});
	return helper;
}

+ (void)UploadToQiniu:(NSData*)imageData imageName:(NSString*)imageName token:(NSString*)token completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	[QiniuHelper UploadToQiniu:imageData imageName:imageName token:token progress:nil completion:completion];
}

+ (void)UploadToQiniu:(NSData*)imageData imageName:(NSString*)imageName token:(NSString*)token progress:(void (^)(NSString *key, float percent))progress completion:(void (^)(UIImage *image, NSString *imageUrl, NSString *imageName))completion{
	NSString *tokenString = token;
	if (!tokenString.length) {
		[[GCQiniuUploadManager sharedInstance] registerWithScope:QINIU_BUCKET accessKey:QINIU_ACCESSKey secretKey:QINIU_SECRETKey];
		[[GCQiniuUploadManager sharedInstance] createToken];
		tokenString = [GCQiniuUploadManager sharedInstance].uploadToken;
	}
	//NSLog(@"%@", tokenString);
	QNUploadOption *option = [[QNUploadOption alloc] initWithMime:nil progressHandler:progress params:nil checkCrc:NO cancellationSignal:nil];
	[[QiniuHelper sharedHelper].manager putData:imageData key:imageName token:tokenString complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
		NSDictionary *d = [info getPropertiesAndVaules];
		//NSLog(@"%@", resp);
		if (info.ok) {
			//NSLog(@"请求成功");
			NSString *url = [NSString stringWithFormat:@"%@/%@", QINIU_IMGURL, key];
			if (completion) completion([UIImage imageWithData:imageData], url, imageName);
		} else {
			//NSLog(@"失败");
			NSLog(@"QINIU UPLOAD ERROR ===== %@", info);
		}
	} option:option];
}

@end
