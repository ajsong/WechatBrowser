//
//  Common.m
//
//  Created by ajsong on 15/4/23.
//  Copyright (c) 2015 @jsong. All rights reserved.
//

#import "AppDelegate.h"

#define API_CACHE_FOLDER @"CacheDatas"
#define API_ECHO_DATA 0

NSString * const ApiAlwaysShowMessage = @"ApiAlwaysShowMessage";
NSString * const ApiKeyMessage = @"ApiKeyMessage";
NSString * const ApiNonMessage = @"ApiNonMessage";
NSString * const ApiNonSuccessMessage = @"ApiNonSuccessMessage";
NSString * const ApiPostSuccessMessage = @"提交成功";
NSString * const ApiPostFailureMessage = @"提交失败";

@implementation Common

+ (Common*)shared{
	static dispatch_once_t once = 0;
	static Common *shared;
	dispatch_once(&once, ^{ shared = [[Common alloc] init]; shared.queues = [[NSMutableArray alloc] init]; });
	return shared;
}

+ (void)setUrlData:(id (^)(id data))urlData{
	[Common shared].urlData = urlData;
}

+ (void)setPostData:(id (^)(NSString *url, id data))postData{
	[Common shared].postData = postData;
}

+ (void)setOptionsData:(id (^)(NSString *, id))optionsData{
	[Common shared].optionsData = optionsData;
}

+ (void)setFeedbackType:(CommonFeedbackType)feedbackType{
	[Common shared].feedbackType = feedbackType;
}

- (Common *(^)(NSString *url))url{
	return ^Common*(NSString *url){
		self.element[@"url"] = url;
		return self;
	};
}
- (Common *(^)(id params))params{
	return ^Common*(id params){
		self.element[@"params"] = params;
		return self;
	};
}
- (Common *(^)(id data))data{
	return ^Common*(id data){
		self.element[@"data"] = data;
		return self;
	};
}
- (Common *(^)(NSString *type))type{
	return ^Common*(NSString *type){
		self.element[@"type"] = type;
		return self;
	};
}
- (Common *(^)(NSString *feedback))feedback{
	return ^Common*(NSString *feedback){
		self.element[@"feedback"] = feedback;
		return self;
	};
}
- (Common *(^)(NSTimeInterval timeout))timeout{
	return ^Common*(NSTimeInterval timeout){
		self.element[@"timeout"] = @(timeout);
		return self;
	};
}
- (Common *(^)(NSTimeInterval cachetime))cachetime{
	return ^Common*(NSTimeInterval cachetime){
		self.element[@"cachetime"] = @(cachetime);
		return self;
	};
}
- (Common *(^)(void (^progress)(NSProgress *progress)))progress{
	return ^Common*(void (^progress)(NSProgress *progress)){
		self.element[@"progress"] = progress;
		return self;
	};
}
- (Common *(^)(void (^success)(NSMutableDictionary *json)))success{
	return ^Common*(void (^success)(NSMutableDictionary *json)){
		self.element[@"success"] = success;
		return self;
	};
}
- (Common *(^)(void (^fail)(NSMutableDictionary *json, NSInteger code)))fail{
	return ^Common*(void (^fail)(NSMutableDictionary *json, NSInteger code)){
		self.element[@"fail"] = fail;
		return self;
	};
}
- (Common *(^)(void (^complete)(NSMutableDictionary *json)))complete{
	return ^Common*(void (^complete)(NSMutableDictionary *json)){
		self.element[@"complete"] = complete;
		return self;
	};
}
- (NSString *(^)(void))get{
	return ^NSString *(){
		id params = self.element[@"params"];
		//id data = self.element[@"data"];
		NSString *type = self.element[@"type"] ? self.element[@"type"] : @"json";
		NSString *feedback = self.element[@"feedback"];
		NSTimeInterval cachetime = [self.element[@"cachetime"]doubleValue];
		//NSTimeInterval timeout = self.element[@"timeout"] ? [self.element[@"timeout"]doubleValue] : 0;
		//void(^progress)(NSProgress *progress) = self.element[@"progress"];
		void(^success)(NSMutableDictionary *json) = self.element[@"success"];
		void(^fail)(NSMutableDictionary *json, NSInteger code) = self.element[@"fail"];
		void(^complete)(NSMutableDictionary *json) = self.element[@"complete"];
		NSString *url = self.element[@"url"] ? self.element[@"url"] : [Common apiUrlWithFile:API_FILE params:params];
		return [Common getApiWithUrl:url options:@{@"type":type} feedback:feedback cachetime:cachetime success:success fail:fail complete:complete];
	};
}
- (NSString *(^)(void))post{
	return ^NSString *(){
		id params = self.element[@"params"];
		id data = self.element[@"data"];
		NSString *type = self.element[@"type"] ? self.element[@"type"] : @"json";
		NSString *feedback = self.element[@"feedback"];
		//NSTimeInterval cachetime = [self.element[@"cachetime"]doubleValue];
		NSTimeInterval timeout = self.element[@"timeout"] ? [self.element[@"timeout"]doubleValue] : 5;
		//void(^progress)(NSProgress *progress) = self.element[@"progress"];
		void(^success)(NSMutableDictionary *json) = self.element[@"success"];
		void(^fail)(NSMutableDictionary *json, NSInteger code) = self.element[@"fail"];
		void(^complete)(NSMutableDictionary *json) = self.element[@"complete"];
		NSString *url = self.element[@"url"] ? self.element[@"url"] : [Common apiUrlWithFile:API_FILE params:params];
		return [Common postApiWithUrl:url data:data options:@{@"type":type} timeout:timeout feedback:feedback success:success fail:fail complete:complete];
	};
}
- (NSString *(^)(void))upload{
	return ^NSString *(){
		id params = self.element[@"params"];
		id data = self.element[@"data"];
		//NSString *type = self.element[@"type"] ? self.element[@"type"] : @"json";
		NSString *feedback = self.element[@"feedback"];
		//NSTimeInterval cachetime = [self.element[@"cachetime"]doubleValue];
		NSTimeInterval timeout = self.element[@"timeout"] ? [self.element[@"timeout"]doubleValue] : 20;
		void(^progress)(NSProgress *progress) = self.element[@"progress"];
		void(^success)(NSMutableDictionary *json) = self.element[@"success"];
		void(^fail)(NSMutableDictionary *json, NSInteger code) = self.element[@"fail"];
		void(^complete)(NSMutableDictionary *json) = self.element[@"complete"];
		NSString *url = self.element[@"url"] ? self.element[@"url"] : [Common apiUrlWithFile:API_FILE params:params];
		return [Common uploadApiWithUrl:url data:data options:nil timeout:timeout feedback:feedback progress:progress success:success fail:fail complete:complete];
	};
}

//组合接口与参数
+ (NSString*)apiUrlWithFile:(NSString*)file params:(id)params{
	if ([params isKindOfClass:[NSDictionary class]]) {
		NSMutableDictionary *datas = [[NSMutableDictionary alloc]init];
		if (API_PARAMETER.length) {
			NSMutableArray *array = [API_PARAMETER explode:@"&"];
			for (int i=0; i<array.count; i++) {
				if (![array[i] length]) continue;
				NSMutableArray *arr = [array[i] explode:@"="];
				[datas setObject:arr[1] forKey:arr[0]];
			}
		}
		if ([params isDictionary]) {
			for (NSString *key in params) {
				if (key.length) [datas setObject:[STRING(params[key])URLEncode] forKey:key];
			}
		}
		if ([Common shared].urlData) datas = [NSMutableDictionary dictionaryWithDictionary:(id)[Common shared].urlData(datas)];
		NSMutableString *strings = [[NSMutableString alloc]init];
		if (datas.isDictionary) {
			for (NSString *key in datas) {
				if (key.length) [strings appendFormat:@"&%@=%@", key, datas[key]];
			}
		}
		NSString *string = [NSString stringWithFormat:@"%@", strings];
		if (string.length) string = [NSString stringWithFormat:@"?%@", [string trim:@"&"]];
		return [NSString stringWithFormat:@"%@/%@%@", API_URL, file, string];
	} else if ([params isKindOfClass:[NSArray class]]) {
		NSMutableArray *p = [NSMutableArray arrayWithArray:params];
		NSMutableArray *param = [[NSMutableArray alloc]init];
		if (file.length) [p unshift:file];
		for (id node in p) {
			if ([node isKindOfClass:[NSString class]]) {
				if ([node length]) [param addObject:node];
			} else if ([node isKindOfClass:[NSDictionary class]]) {
				if ([node isDictionary] && param.count>0) {
					NSMutableString *strings = [[NSMutableString alloc]init];
					for (NSString *key in node) {
						if (key.length) [strings appendFormat:@"&%@=%@", key, [STRING([node valueForKey:key])URLEncode]];
					}
					NSString *string = [[NSString stringWithFormat:@"%@", strings] trim:@"&"];
					string = [NSString stringWithFormat:@"%@?%@", param.lastObject, string];
					[param replaceObjectAtIndex:param.count-1 withObject:string];
				}
			}
		}
		if ([Common shared].urlData) param = [NSMutableArray arrayWithArray:(id)[Common shared].urlData(param)];
		NSMutableDictionary *datas = [[NSMutableDictionary alloc]init];
		if (API_PARAMETER.length) {
			NSMutableArray *array = [API_PARAMETER explode:@"&"];
			for (int i=0; i<array.count; i++) {
				if (![array[i] length]) continue;
				NSMutableArray *arr = [array[i] explode:@"="];
				[datas setObject:arr[1] forKey:arr[0]];
			}
		}
		NSMutableString *strings = [[NSMutableString alloc]init];
		if (datas.isDictionary) {
			for (NSString *key in datas) {
				if (key.length) [strings appendFormat:@"&%@=%@", key, datas[key]];
			}
		}
		NSString *string = [NSString stringWithFormat:@"%@", strings];
		if (string.length) {
			string = [string trim:@"&"];
			if ([[param implode:@"/"] indexOf:@"?"]==NSNotFound) {
				string = [NSString stringWithFormat:@"?%@", string];
			} else {
				string = [NSString stringWithFormat:@"&%@", string];
			}
		}
		return [NSString stringWithFormat:@"%@/%@%@", API_URL, [param implode:@"/"], string];
	} else {
		return [NSString stringWithFormat:@"%@/%@", API_URL, file];
	}
}

#pragma mark - GET
+ (NSString*)getApiWithParams:(id)params complete:(void (^)(NSMutableDictionary *))complete{
	return [Common getApiWithParams:params feedback:nil complete:complete];
}

+ (NSString*)getApiWithParams:(id)params feedback:(NSString*)feedback complete:(void (^)(NSMutableDictionary *))complete{
	NSString *url = [Common apiUrlWithFile:API_FILE params:params];
	return [Common getApiWithUrl:url options:@{@"type":@"json"} feedback:feedback cachetime:0 success:nil fail:nil complete:complete];
}

+ (NSString*)getApiWithParams:(id)params success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common getApiWithParams:params feedback:nil cachetime:0 success:success fail:fail];
}

+ (NSString*)getApiWithParams:(id)params options:(NSDictionary*)options success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	NSString *url = [Common apiUrlWithFile:API_FILE params:params];
	return [Common getApiWithUrl:url options:options feedback:nil cachetime:0 success:success fail:fail complete:nil];
}

+ (NSString*)getApiWithParams:(id)params cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common getApiWithParams:params feedback:nil cachetime:cachetime success:success fail:fail];
}

+ (NSString*)getApiWithParams:(id)params feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common getApiWithParams:params feedback:feedback cachetime:0 success:success fail:fail];
}

+ (NSString*)getApiWithParams:(id)params feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	NSString *url = [Common apiUrlWithFile:API_FILE params:params];
	return [Common getApiWithUrl:url feedback:feedback cachetime:cachetime success:success fail:fail];
}

+ (NSString*)getApiWithFile:(NSString*)file params:(id)params feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	NSString *url = [Common apiUrlWithFile:file params:params];
	return [Common getApiWithUrl:url feedback:feedback cachetime:cachetime success:success fail:fail];
}

+ (NSString*)getApiWithUrl:(NSString*)url success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common getApiWithUrl:url feedback:nil cachetime:0 success:success fail:fail];
}

+ (NSString*)getApiWithUrl:(NSString*)url options:(NSDictionary*)options success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common getApiWithUrl:url options:options feedback:nil cachetime:0 success:success fail:fail complete:nil];
}

+ (NSString*)getApiWithUrl:(NSString*)url cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common getApiWithUrl:url feedback:nil cachetime:cachetime success:success fail:fail];
}

+ (NSString*)getApiWithUrl:(NSString*)url feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common getApiWithUrl:url feedback:feedback cachetime:0 success:success fail:fail];
}

+ (NSString*)getApiWithUrl:(NSString*)url feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{ //cachetime:单位秒
	return [Common getApiWithUrl:url options:@{@"type":@"json"} feedback:feedback cachetime:cachetime success:success fail:fail complete:nil];
}

+ (NSString*)getApiWithUrl:(NSString*)url options:(NSDictionary*)options feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete{
	for (NSDictionary *obj in [Common shared].queues) {
		if ([obj[@"type"] isEqualToString:@"get"] && [obj[@"url"] isEqualToString:url]) {
			return url;
			break;
		}
	}
	NSString *feedbackMessage = feedback;
	if ([Common shared].feedbackType==CommonFeedbackTypeNonSuccess && (!feedbackMessage.length || [feedbackMessage isEqualToString:ApiPostSuccessMessage])) feedbackMessage = ApiNonSuccessMessage;
	if ([Common shared].feedbackType==CommonFeedbackTypeNon && (!feedbackMessage.length || [feedbackMessage isEqualToString:ApiPostSuccessMessage])) feedbackMessage = ApiNonMessage;
	NSString *cacheFilename = [url.URLEncode replace:@"." to:@"%2E"];
	NSString *cachePath = [NSString stringWithFormat:@"%@/%@", API_CACHE_FOLDER, cacheFilename];
	if (cachetime>0) {
		if ([Global fileExistFromTmp:cachePath]) {
			NSMutableDictionary *attributes = [Global fileAttributes:[Global getFilePathFromTmp:cachePath]];
			if ([Global dateDiff:@"s" earlyDate:attributes[@"createdate"] lateDate:[NSDate date]] <= cachetime) {
				NSString *cacheString = [Global getFileTextFromTmp:cachePath];
				if (options.isDictionary && [options[@"type"] isEqualToString:@"json"]) {
					NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:cacheString.formatJson];
					if (json.isDictionary) {
						dispatch_async(dispatch_get_main_queue(), ^{
							if (![feedbackMessage isEqualToString:ApiAlwaysShowMessage]) [ProgressHUD dismiss];
							if (success) success(json);
							if (complete) complete(json);
							[Common successExecute:json];
						});
						return url;
					}
				} else {
					dispatch_async(dispatch_get_main_queue(), ^{
						if (![feedbackMessage isEqualToString:ApiAlwaysShowMessage]) [ProgressHUD dismiss];
						if (success) success((NSMutableDictionary*)cacheString);
						if (complete) complete((NSMutableDictionary*)cacheString);
						[Common successExecute:(NSMutableDictionary*)cacheString];
					});
					return url;
				}
			}
		}
	}
	if (![Global isNetwork:![feedbackMessage isEqualToString:ApiNonMessage]]) {
		NSMutableDictionary *json = [NSMutableDictionary dictionaryWithObjectsAndKeys:@0, API_KEY_MSG_TYPE, @"NO NETWORK", API_KEY_MSG, nil];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (fail) fail(json, -504);
			if (complete) complete(json);
		});
		[ProgressHUD dismiss];
		return url;
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			APPCurrentController.element[@"isNetwork"] = @YES;
		});
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSDictionary *processData = @{@"type":@"get", @"url":url};
		if (processData.isDictionary) [[Common shared].queues addObject:processData];
		NSString *type = @"html";
		if (options.isDictionary && options[@"type"]) type = options[@"type"];
		NSMutableDictionary *opt = [NSMutableDictionary dictionaryWithDictionary:options];
		if ([Common shared].optionsData) opt = [Common shared].optionsData(url, opt);
		[Global get:url data:nil options:opt completion:^(NSString *result) {
			if (processData.isDictionary && [[Common shared].queues containsObject:processData]) {
				[[Common shared].queues removeObject:processData];
			}
			if (![type isEqualToString:@"json"]) {
				if (![feedbackMessage isEqualToString:ApiAlwaysShowMessage]) [ProgressHUD dismiss];
				if (success) success((NSMutableDictionary*)result);
				[Common successExecute:(NSMutableDictionary*)result];
				if (cachetime>0) {
					[Global makeDirFromTmp:API_CACHE_FOLDER];
					[Global saveFileToTmp:cachePath content:result new:YES];
				}
				if (complete) complete((NSMutableDictionary*)result);
				return;
			}
			if (API_PUBLIC_KEY.length && [result isKindOfClass:[NSString class]] && result.length && [result indexOf:@"&"]==NSNotFound) {
				NSMutableArray *arr = [result.base64ToString str_split:128];
				NSMutableArray *datas = [[NSMutableArray alloc]init];
				for (int i=0; i<arr.count; i++) {
					NSString *rsa = [Common RsaPublicDecode:arr[i]];
					[datas addObject:rsa.length?rsa:@""];
				}
				result = [datas implode:@""];
			}
			NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
			if ([result isKindOfClass:[NSDictionary class]]) {
				json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)result];
			} else if (result.isJsonString) {
				json = [NSMutableDictionary dictionaryWithDictionary:result.formatJson];
			}
#if API_ECHO_DATA
			NSLog(@"\n%@\n", url);
			NSLog(@"%@\n\n", json.descriptionASCII);
#endif
			if (json.isDictionary) {
				if (json[API_KEY_ERROR] && json[API_KEY_MSG] && json[API_KEY_MSG_TYPE]) {
					if ([json[API_KEY_ERROR] intValue]==API_KEY_ERROR_CODE) {
						if (feedbackMessage.length && ![feedbackMessage isEqualToString:ApiNonMessage] && ![feedbackMessage isEqualToString:ApiNonSuccessMessage]) {
							if (![feedbackMessage isEqualToString:ApiAlwaysShowMessage]) {
								if ([feedbackMessage isEqualToString:ApiKeyMessage] && json[API_KEY_MSG]) {
									if ([json[API_KEY_MSG]length]) [ProgressHUD showSuccess:json[API_KEY_MSG]];
									else [ProgressHUD dismiss];
								} else {
									[ProgressHUD showSuccess:feedbackMessage];
								}
							}
						} else {
							[ProgressHUD dismiss];
						}
						if (success) success(json);
						[Common successExecute:json];
						if (cachetime>0) {
							[Global makeDirFromTmp:API_CACHE_FOLDER];
							//以网址作为文件名缓存数据
							[Global saveFileToTmp:cachePath content:result new:YES];
						}
					} else {
						if (![feedbackMessage isEqualToString:ApiNonMessage]) {
							if ([json[API_KEY_MSG_TYPE]intValue]!=-100 &&
								[json[API_KEY_MSG_TYPE]intValue]!=-10 &&
								[json[API_KEY_MSG_TYPE]intValue]!=-9) {
								if (json[API_KEY_MSG]) {
									if ([json[API_KEY_MSG]length]) [ProgressHUD showError:json[API_KEY_MSG]];
									else [ProgressHUD dismiss];
								} else {
									[ProgressHUD showError:@"获取数据失败"];
								}
							} else {
								if ([json[API_KEY_MSG_TYPE]intValue]==-10 || [json[API_KEY_MSG_TYPE]intValue]==-9) {
									if ([json[API_KEY_MSG]length]) [ProgressHUD showError:json[API_KEY_MSG]];
									else [ProgressHUD dismiss];
								}
								[@"person" deleteUserDefaults];
								[APPCurrentController showLogin];
							}
						} else {
							[ProgressHUD dismiss];
						}
						if (fail) fail(json, [json[API_KEY_MSG_TYPE]integerValue]);
						[Common errorExecute:json];
					}
				} else {
					if (![feedbackMessage isEqualToString:ApiAlwaysShowMessage]) [ProgressHUD dismiss];
					if (success) success(json);
				}
			} else {
				[ProgressHUD dismiss];
				NSLog(@"%@", url);
				if ([API_ERROR_SENDEMAIL length]) {
					NSString *description = FORMAT(@"\n%@\n%@", url, result);
					UIImage *attachment = [KEYWINDOW toImageWithRect:[UIScreen mainScreen].bounds];
					attachment = [attachment fitToSize:CGSizeMake(640, 0)];
					[SKPSMTPMessage sendEmailTo:API_ERROR_SENDEMAIL title:FORMAT(@"%@(APP)接口出错", APP_NAME) content:description attachment:attachment.data];
				}
				NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
				if ([result indexOf:@"Undefined index: member in"]!=NSNotFound) [json setObject:@(-100) forKey:API_KEY_MSG_TYPE];
				if (fail) fail(json, -999);
				[Common errorExecute:json];
			}
			if (complete) complete(json);
		} fail:^(NSString *description, NSInteger code) {
			[[Common shared].queues removeObject:processData];
			[ProgressHUD dismiss];
			NSMutableDictionary *json = [NSMutableDictionary dictionaryWithObjectsAndKeys:@0, API_KEY_MSG_TYPE, @"DATA ERROR", API_KEY_MSG, nil];
			if (fail) fail(json, code);
			if (complete) complete(json);
			[Common errorExecute:json];
		}];
	});
	return url;
}

#pragma mark - POST
+ (NSString*)postAutoApiWithParams:(id)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common postAutoApiWithParams:params data:data feedback:ApiPostSuccessMessage success:success fail:fail];
}

+ (NSString*)postAutoApiWithParams:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	BOOL formData = NO;
	if (data.count) {
		for (NSString *key in data) {
			if ([data[key] isKindOfClass:[UIImage class]] || [data[key] isKindOfClass:[NSData class]]) {
				formData = YES;
				break;
			}
		}
	}
	if (!formData) {
		return [Common postApiWithParams:params data:data feedback:feedback success:success fail:fail];
	} else {
		return [Common uploadApiWithParams:params data:data feedback:feedback success:success fail:fail];
	}
}

+ (NSString*)postApiWithParams:(id)params success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common postApiWithParams:params data:nil success:success fail:fail];
}

+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common postApiWithParams:params data:data feedback:ApiPostSuccessMessage success:success fail:fail];
}

+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data options:(NSDictionary*)options success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	NSString *url = [Common apiUrlWithFile:API_FILE params:params];
	return [Common postApiWithUrl:url data:data options:options timeout:5 feedback:ApiPostSuccessMessage success:success fail:fail complete:nil];
}

+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common postApiWithFile:API_FILE params:params data:data feedback:feedback success:success fail:fail];
}

+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete{
	return [Common postApiWithFile:API_FILE params:params data:data timeout:5 feedback:feedback success:success fail:fail complete:complete];
}

+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common postApiWithFile:API_FILE params:params data:data timeout:timeout feedback:ApiNonMessage success:success fail:fail complete:nil];
}

+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common postApiWithFile:API_FILE params:params data:data timeout:timeout feedback:feedback success:success fail:fail complete:nil];
}

+ (NSString*)postApiWithFile:(NSString*)file params:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common postApiWithFile:file params:params data:data timeout:5 feedback:feedback success:success fail:fail complete:nil];
}

+ (NSString*)postApiWithFile:(NSString*)file params:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete{
	NSString *url = [Common apiUrlWithFile:file params:params];
	return [Common postApiWithUrl:url data:data timeout:timeout feedback:feedback success:success fail:fail complete:complete];
}

+ (NSString*)postApiWithUrl:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete{
	return [Common postApiWithUrl:url data:data options:nil timeout:timeout feedback:feedback success:success fail:fail complete:complete];
}

+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common postJSONWithUrl:url data:data timeout:5 feedback:ApiKeyMessage success:success fail:fail complete:nil];
}

+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common postJSONWithUrl:url data:data timeout:5 feedback:feedback success:success fail:fail complete:nil];
}

+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete{
	return [Common postApiWithUrl:url data:data options:@{@"type":@"json"} timeout:timeout feedback:feedback success:success fail:fail complete:complete];
}

+ (NSString*)postApiWithUrl:(NSString*)url data:(id)data options:(NSDictionary*)options timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete{
	for (NSDictionary *obj in [Common shared].queues) {
		if ([obj[@"type"] isEqualToString:@"post"] && [obj[@"url"] isEqualToString:url] && [[[obj[@"data"]jsonString]md5] isEqualToString:[[data jsonString]md5]]) {
			return url;
			break;
		}
	}
	NSString *feedbackMessage = feedback;
	if ([Common shared].feedbackType==CommonFeedbackTypeNonSuccess && (!feedbackMessage.length || [feedbackMessage isEqualToString:ApiPostSuccessMessage])) feedbackMessage = ApiNonSuccessMessage;
	if ([Common shared].feedbackType==CommonFeedbackTypeNon && (!feedbackMessage.length || [feedbackMessage isEqualToString:ApiPostSuccessMessage])) feedbackMessage = ApiNonMessage;
	if (![Global isNetwork:![feedbackMessage isEqualToString:ApiNonMessage]]) {
		NSMutableDictionary *json = [NSMutableDictionary dictionaryWithObjectsAndKeys:@0, API_KEY_MSG_TYPE, @"NO NETWORK", API_KEY_MSG, nil];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (fail) fail(json, -504);
			if (complete) complete(json);
		});
		[ProgressHUD dismiss];
		return url;
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			APPCurrentController.element[@"isNetwork"] = @YES;
		});
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSDictionary *processData = @{@"type":@"post", @"url":url, @"data":data?data:@""};
		if (processData.isDictionary) [[Common shared].queues addObject:processData];
		NSMutableDictionary *opt = [NSMutableDictionary dictionaryWithDictionary:options];
		if (API_PUBLIC_KEY.length) [opt setObject:@"raw" forKey:@"type"];
		if ([Common shared].optionsData) opt = [Common shared].optionsData(url, opt);
		id postData = data;
		if ([Common shared].postData) postData = [Common shared].postData(url, data);
		[Global post:url data:postData options:opt timeout:timeout completion:^(NSString *result) {
			if (processData.isDictionary && [[Common shared].queues containsObject:processData]) {
				[[Common shared].queues removeObject:processData];
			}
			if (API_PUBLIC_KEY.length && [result isKindOfClass:[NSString class]] && result.length && [result indexOf:@"&"]==NSNotFound) {
				NSMutableArray *arr = [result.base64ToString str_split:128];
				NSMutableArray *datas = [[NSMutableArray alloc]init];
				for (int i=0; i<arr.count; i++) {
					NSString *rsa = [Common RsaPublicDecode:arr[i]];
					[datas addObject:rsa.length?rsa:@""];
				}
				result = [datas implode:@""];
			}
			NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
			if ([result isKindOfClass:[NSDictionary class]]) {
				json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)result];
			} else if (result.isJsonString) {
				json = [NSMutableDictionary dictionaryWithDictionary:result.formatJson];
			}
#if API_ECHO_DATA
			NSLog(@"\n%@\n%@\n", url, [data jsonString]);
			NSLog(@"%@\n\n", json.descriptionASCII);
#endif
			if (json.isDictionary) {
				if (json[API_KEY_ERROR] && json[API_KEY_MSG] && json[API_KEY_MSG_TYPE]) {
					if ([json[API_KEY_ERROR] intValue]==API_KEY_ERROR_CODE) {
						if (feedbackMessage.length && ![feedbackMessage isEqualToString:ApiNonMessage] && ![feedbackMessage isEqualToString:ApiNonSuccessMessage]) {
							if (![feedbackMessage isEqualToString:ApiAlwaysShowMessage]) {
								if ([feedbackMessage isEqualToString:ApiKeyMessage] && json[API_KEY_MSG]) {
									if ([json[API_KEY_MSG]length]) [ProgressHUD showSuccess:json[API_KEY_MSG]];
									else [ProgressHUD dismiss];
								} else {
									[ProgressHUD showSuccess:feedbackMessage];
								}
							}
						} else {
							[ProgressHUD dismiss];
						}
						if (success) success(json);
						[Common successExecute:json];
					} else {
						if (![feedbackMessage isEqualToString:ApiNonMessage]) {
							if ([json[API_KEY_MSG_TYPE]intValue]!=-100 &&
								[json[API_KEY_MSG_TYPE]intValue]!=-10 &&
								[json[API_KEY_MSG_TYPE]intValue]!=-9) {
								if (json[API_KEY_MSG]) {
									if ([json[API_KEY_MSG]length]) [ProgressHUD showError:json[API_KEY_MSG]];
									else [ProgressHUD dismiss];
								} else {
									[ProgressHUD showError:ApiPostFailureMessage];
								}
							} else {
								if ([json[API_KEY_MSG_TYPE]intValue]==-10 || [json[API_KEY_MSG_TYPE]intValue]==-9) {
									if ([json[API_KEY_MSG]length]) [ProgressHUD showError:json[API_KEY_MSG]];
									else [ProgressHUD dismiss];
								}
								[@"person" deleteUserDefaults];
								[APPCurrentController showLogin];
							}
						} else {
							[ProgressHUD dismiss];
						}
						if (fail) fail(json, [json[API_KEY_MSG_TYPE]integerValue]);
						[Common errorExecute:json];
					}
				} else {
					if (![feedbackMessage isEqualToString:ApiAlwaysShowMessage]) [ProgressHUD dismiss];
					if (success) success(json);
				}
			} else {
				[ProgressHUD dismiss];
				NSLog(@"%@", url);
				if ([API_ERROR_SENDEMAIL length]) {
					NSString *description = FORMAT(@"\n%@\n%@", url, result);
					UIImage *attachment = [KEYWINDOW toImageWithRect:[UIScreen mainScreen].bounds];
					attachment = [attachment fitToSize:CGSizeMake(640, 0)];
					[SKPSMTPMessage sendEmailTo:API_ERROR_SENDEMAIL title:FORMAT(@"%@(APP)接口出错", APP_NAME) content:description attachment:attachment.data];
				}
				NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
				if ([result indexOf:@"Undefined index: member in"]!=NSNotFound) [json setObject:@(-100) forKey:API_KEY_MSG_TYPE];
				if (fail) fail(json, -999);
				[Common errorExecute:json];
			}
			if (complete) complete(json);
		} fail:^(NSString *description, NSInteger code) {
			[[Common shared].queues removeObject:processData];
			[ProgressHUD dismiss];
			NSMutableDictionary *json = [NSMutableDictionary dictionaryWithObjectsAndKeys:@0, API_KEY_MSG_TYPE, @"DATA ERROR", API_KEY_MSG, nil];
			if (fail) fail(json, code);
			if (complete) complete(json);
			[Common errorExecute:json];
		}];
	});
	return url;
}

#pragma mark - UPLOAD
+ (NSString*)uploadApiWithParams:(id)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [self uploadApiWithParams:params data:data feedback:ApiPostSuccessMessage success:success fail:fail];
}

+ (NSString*)uploadApiWithParams:(id)params data:(NSDictionary*)data options:(NSDictionary*)options success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	NSString *url = [Common apiUrlWithFile:API_FILE params:params];
	return [Common uploadApiWithUrl:url data:data options:options timeout:30 feedback:ApiPostSuccessMessage progress:nil success:success fail:fail complete:nil];
}

+ (NSString*)uploadApiWithParams:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common uploadApiWithFile:API_FILE params:params data:data feedback:feedback success:success fail:fail];
}

+ (NSString*)uploadApiWithParams:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common uploadApiWithFile:API_FILE params:params data:data timeout:timeout feedback:ApiNonMessage success:success fail:fail complete:nil];
}

+ (NSString*)uploadApiWithParams:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common uploadApiWithFile:API_FILE params:params data:data timeout:timeout feedback:feedback success:success fail:fail complete:nil];
}

+ (NSString*)uploadApiWithFile:(NSString*)file params:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail{
	return [Common uploadApiWithFile:API_FILE params:params data:data timeout:30 feedback:feedback success:success fail:fail complete:nil];
}

+ (NSString*)uploadApiWithFile:(NSString*)file params:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete{
	NSString *url = [Common apiUrlWithFile:file params:params];
	return [Common uploadApiWithUrl:url data:data timeout:timeout feedback:feedback success:success fail:fail complete:complete];
}

+ (NSString*)uploadApiWithUrl:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete{
	return [Common uploadApiWithUrl:url data:data options:nil timeout:timeout feedback:feedback progress:nil success:success fail:fail complete:complete];
}

+ (NSString*)uploadApiWithUrl:(NSString*)url data:(NSDictionary*)data options:(NSDictionary*)options timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback progress:(void (^)(NSProgress *progress))progress success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete{
	for (NSDictionary *obj in [Common shared].queues) {
		if ([obj[@"type"] isEqualToString:@"upload"] && [obj[@"url"] isEqualToString:url] && [[[obj[@"data"]jsonString]md5] isEqualToString:[[data jsonString]md5]]) {
			return url;
			break;
		}
	}
	NSString *feedbackMessage = feedback;
	if ([Common shared].feedbackType==CommonFeedbackTypeNonSuccess && (!feedbackMessage.length || [feedbackMessage isEqualToString:ApiPostSuccessMessage])) feedbackMessage = ApiNonSuccessMessage;
	if ([Common shared].feedbackType==CommonFeedbackTypeNon && (!feedbackMessage.length || [feedbackMessage isEqualToString:ApiPostSuccessMessage])) feedbackMessage = ApiNonMessage;
	if (![Global isNetwork:![feedbackMessage isEqualToString:ApiNonMessage]]) {
		NSMutableDictionary *json = [NSMutableDictionary dictionaryWithObjectsAndKeys:@0, API_KEY_MSG_TYPE, @"NO NETWORK", API_KEY_MSG, nil];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (fail) fail(json, -504);
			if (complete) complete(json);
		});
		[ProgressHUD dismiss];
		return url;
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			APPCurrentController.element[@"isNetwork"] = @YES;
		});
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSDictionary *processData = @{@"type":@"upload", @"url":url, @"data":data?data:@""};
		if (processData.isDictionary) [[Common shared].queues addObject:processData];
		NSMutableDictionary *opt = [NSMutableDictionary dictionaryWithDictionary:options];
		if ([Common shared].optionsData) opt = [Common shared].optionsData(url, opt);
		id postData = data;
		if ([Common shared].postData) postData = [Common shared].postData(url, data);
		[Global upload:url data:postData options:opt timeout:timeout progress:progress completion:^(NSString *result) {
			if (processData.isDictionary && [[Common shared].queues containsObject:processData]) {
				[[Common shared].queues removeObject:processData];
			}
			NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
			if ([result isKindOfClass:[NSDictionary class]]) {
				json = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)result];
			} else if (result.isJsonString) {
				json = [NSMutableDictionary dictionaryWithDictionary:result.formatJson];
			}
#if API_ECHO_DATA
			NSLog(@"\n%@\n%@\n", url, [data jsonString]);
			NSLog(@"%@\n\n", json.descriptionASCII);
#endif
			if (json.isDictionary) {
				if (json[API_KEY_ERROR] && json[API_KEY_MSG] && json[API_KEY_MSG_TYPE]) {
					if ([json[API_KEY_ERROR] intValue]==API_KEY_ERROR_CODE) {
						if (feedbackMessage.length && ![feedbackMessage isEqualToString:ApiNonMessage] && ![feedbackMessage isEqualToString:ApiNonSuccessMessage]) {
							if (![feedbackMessage isEqualToString:ApiAlwaysShowMessage]) {
								if ([feedbackMessage isEqualToString:ApiKeyMessage] && json[API_KEY_MSG]) {
									if ([json[API_KEY_MSG]length]) [ProgressHUD showSuccess:json[API_KEY_MSG]];
									else [ProgressHUD dismiss];
								} else {
									[ProgressHUD showSuccess:feedbackMessage];
								}
							}
						} else {
							[ProgressHUD dismiss];
						}
						if (success) success(json);
						[Common successExecute:json];
					} else {
						if (![feedbackMessage isEqualToString:ApiNonMessage]) {
							if ([json[API_KEY_MSG_TYPE]intValue]!=-100 &&
								[json[API_KEY_MSG_TYPE]intValue]!=-10 &&
								[json[API_KEY_MSG_TYPE]intValue]!=-9) {
								if (json[API_KEY_MSG]) {
									if ([json[API_KEY_MSG]length]) [ProgressHUD showError:json[API_KEY_MSG]];
									else [ProgressHUD dismiss];
								} else {
									[ProgressHUD showError:ApiPostFailureMessage];
								}
							} else {
								if ([json[API_KEY_MSG_TYPE]intValue]==-10 || [json[API_KEY_MSG_TYPE]intValue]==-9) {
									if ([json[API_KEY_MSG]length]) [ProgressHUD showError:json[API_KEY_MSG]];
									else [ProgressHUD dismiss];
								}
								[@"person" deleteUserDefaults];
								[APPCurrentController showLogin];
							}
						} else {
							[ProgressHUD dismiss];
						}
						if (fail) fail(json, [json[API_KEY_MSG_TYPE]integerValue]);
						[Common errorExecute:json];
					}
				} else {
					if (![feedbackMessage isEqualToString:ApiAlwaysShowMessage]) [ProgressHUD dismiss];
					if (success) success(json);
				}
			} else {
				[ProgressHUD dismiss];
				NSLog(@"%@", url);
				if ([API_ERROR_SENDEMAIL length]) {
					NSString *description = FORMAT(@"\n%@\n%@", url, result);
					UIImage *attachment = [KEYWINDOW toImageWithRect:[UIScreen mainScreen].bounds];
					attachment = [attachment fitToSize:CGSizeMake(640, 0)];
					[SKPSMTPMessage sendEmailTo:API_ERROR_SENDEMAIL title:FORMAT(@"%@(APP)接口出错", APP_NAME) content:description attachment:attachment.data];
				}
				NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
				if ([result indexOf:@"Undefined index: member in"]!=NSNotFound) [json setObject:@(-100) forKey:API_KEY_MSG_TYPE];
				if (fail) fail(json, -999);
				[Common errorExecute:json];
			}
			if (complete) complete(json);
		} fail:^(NSString *description, NSInteger code) {
			[[Common shared].queues removeObject:processData];
			[ProgressHUD dismiss];
			NSMutableDictionary *json = [NSMutableDictionary dictionaryWithObjectsAndKeys:@0, API_KEY_MSG_TYPE, @"DATA ERROR", API_KEY_MSG, nil];
			if (fail) fail(json, code);
			if (complete) complete(json);
			[Common errorExecute:json];
		}];
	});
	return url;
}
#pragma mark -

+ (BOOL)removeUrlCache:(NSString*)url{
	NSString *cacheFilename = [url.URLEncode replace:@"." to:@"%2E"];
	NSString *cachePath = [NSString stringWithFormat:@"%@/%@", API_CACHE_FOLDER, cacheFilename];
	return [Global deleteFileFromTmp:cachePath];
}

+ (void)removeAllCache{
	NSString *cachePath = [NSString stringWithFormat:@"%@/%@", [Global getTmp], API_CACHE_FOLDER];
	[Global deleteDir:cachePath killme:NO];
}

#pragma mark - OTHER
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+ (void)successExecute:(NSDictionary *)json{
	if (!json.isDictionary) return;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([APPCurrentController respondsToSelector:@selector(CommonSuccess:)]) {
				[APPCurrentController CommonSuccess:json];
			}
			if ([APPDELEGATE respondsToSelector:@selector(CommonSuccess:)]) {
				[APPDELEGATE CommonSuccess:json];
			}
		});
	});
}

/*
 AppDelegate 的方法
 - (void)CommonSuccess:(NSMutableDictionary*)json{
	 if (json[@"notify"]) {
		 int notify = [json[@"notify"]intValue];
		 [@"notify" setUserDefaultsWithData:@(notify)];
		 KKTabBarItem *item = _tabBarController.tabBar.items[4];
		 item.badgeValue = notify>0 ? FORMAT(@"%d", notify) : @"";
	 }
 }
 */

+ (void)errorExecute:(NSDictionary *)json{
	if (!json.isDictionary) return;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([json[API_KEY_MSG_TYPE]intValue]==-100) {
				if ([APPCurrentController respondsToSelector:@selector(CommonError:)]) {
					[APPCurrentController CommonError:json];
				}
				[ProgressHUD dismiss];
				if (![Common isAuditKey]) {
					if (NSClassFromString(@"login")) {
						id e = [[NSClassFromString(@"login") alloc]init];
						KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:e];
						[APPCurrentController presentViewController:nav animated:YES completion:nil];
					}
				} else {
					if (NSClassFromString(@"loginAudit")) {
						id e = [[NSClassFromString(@"loginAudit") alloc]init];
						KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:e];
						[APPCurrentController presentViewController:nav animated:YES completion:nil];
					}
				}
				return;
			}
			if ([APPDELEGATE respondsToSelector:@selector(CommonError:)]) {
				[APPDELEGATE CommonError:json];
			}
		});
	});
}
#pragma clang diagnostic pop

//公钥格式化
+ (NSString*)formatPublicKey:(NSString*)publicKey{
	const char *pstr = [publicKey UTF8String];
	int len = (int)[publicKey length];
	NSMutableString *result = [NSMutableString string];
	[result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
	int index = 0;
	int count = 0;
	while (index < len) {
		char ch = pstr[index];
		if (ch == '\r' || ch == '\n') {
			++index;
			continue;
		}
		[result appendFormat:@"%c", ch];
		if (++count == 64) {
			[result appendString:@"\n"];
			count = 0;
		}
		index++;
	}
	[result appendString:@"\n-----END PUBLIC KEY-----"];
	return result;
}

//RSA公钥加密
+ (NSString*)RsaPublicEncode:(NSString*)string{
	return [RSAUtil encryptString:string publicKey:[Common formatPublicKey:API_PUBLIC_KEY]];
}

//RSA公钥解密
+ (NSString*)RsaPublicDecode:(NSString*)string{
	return [RSAUtil decryptString:string publicKey:[Common formatPublicKey:API_PUBLIC_KEY]];
}

//查询物流情况
//快递鸟
//www.kdniao.com/YundanChaxunAPI.aspx
#define KDN_EN @[@"EMS", @"SF", @"STO", @"YTO", @"YD", @"HTKY", @"HHTT", @"ZTO", @"ZJS", @"YZPY", @"QFKD", @"GTO", @"JD", @"LB", @"DBL", @"RFD", @"QRT", @"JJKY", @"DHL"]
#define KDN_CN @[@"EMS快递", @"顺丰快递", @"申通快递", @"圆通快递", @"韵达快递", @"百世汇通", @"天天快递", @"中通快递", @"宅急送快递", @"中国邮政", @"全峰快递", @"国通快递", @"京东快递", @"龙邦快递", @"德邦物流", @"如风达快递", @"全日通快递", @"佳吉快运", @"DHL快递"]
+ (void)getKuaidiWithExpCode:(NSString*)expCode expNo:(NSString*)expNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail{
	NSLog(@"使用快递鸟查询物流");
	NSInteger index = NSNotFound;
	NSArray *matches = [expCode preg_match:@"[\\u4e00-\\u9fa5]+"];
	if (matches.isArray) {
		NSString *companyName = [[[[expCode replace:@"快递" to:@""] replace:@"物流" to:@""] replace:@"快运" to:@""] replace:@"速递" to:@""];
		companyName = [companyName replace:@"速运" to:@""];
		index = [companyName inArraySearch:KDN_CN];
	} else {
		index = [expCode.uppercaseString inArray:KDN_EN];
	}
	if (index == NSNotFound) {
		NSLog(@"没有该物流公司代号: %@", expCode);
		if (fail) fail([NSString stringWithFormat:@"没有该物流公司代号: %@", expCode]);
		return;
	}
	NSString *companyName = KDN_EN[index];
	NSString *EBusinessID = @"1256920"; //电商ID
	NSString *AppKey = @"e7bbede8-6d12-439f-9ebf-d835613b638f"; //电商加密私钥
	NSString *requestData = FORMAT(@"{\"OrderCode\":\"\", \"ShipperCode\":\"%@\", \"LogisticCode\":\"%@\"}", companyName, expNo);
	NSString *dataSign = FORMAT(@"%@%@", requestData, AppKey);
	dataSign = dataSign.md5.base64.URLEncode;
	NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
	[postData setObject:EBusinessID forKey:@"EBusinessID"];
	[postData setObject:@"1002" forKey:@"RequestType"];
	[postData setObject:requestData.URLEncode forKey:@"RequestData"];
	[postData setObject:@"2" forKey:@"DataType"];
	[postData setObject:dataSign forKey:@"DataSign"];
	[Common postApiWithUrl:@"http://api.kdniao.com/Ebusiness/EbusinessOrderHandle.aspx" data:postData timeout:5 feedback:ApiNonMessage success:^(NSMutableDictionary *json) {
		if ([json[@"Success"]intValue]==1) {
			if (success) {
				//json[@"State"] 2:在途中, 3:签收, 4:问题件
				NSString *result = json.jsonString;
				result = [result replace:@"\"AcceptTime\":" to:@"\"time\":"];
				result = [result replace:@"\"AcceptStation\":" to:@"\"context\":"];
				result = [result replace:@"\"Traces\":" to:@"\"data\":"];
				json = [NSMutableDictionary dictionaryWithDictionary:result.formatJson];
				NSArray *data = json[@"data"];
				if (data.isArray) {
					success(data, json);
				} else {
					NSLog(@"KDNIAO NO DATA, CHANGE API");
					if ([ProgressHUD isShowing]) [ProgressHUD show:nil];
					[Common getKD100WithExpCode:expCode expNo:expNo success:success fail:fail];
				}
			}
		} else {
			NSLog(@"%@", json[@"Reason"]);
			if (fail) fail(json[@"Reason"]);
		}
	} fail:^(NSMutableDictionary *json, NSInteger code) {
		if (code==-1001) {
			NSLog(@"KDNIAO TIMEOUT, CHANGE API");
			if ([ProgressHUD isShowing]) [ProgressHUD show:nil];
			[Common getKD100WithExpCode:expCode expNo:expNo success:success fail:fail];
		} else {
			NSLog(@"快递鸟接口发生异常");
			if (fail) fail(@"快递鸟接口发生异常");
		}
	} complete:nil];
}

//快递100
#define KD100_EN @[@"ems", @"shunfeng", @"shentong", @"yuantong", @"yunda", @"huitongkuaidi", @"tiantian", @"zhongtong", @"zhaijisong", @"youzhengguonei", @"quanfengkuaidi", @"guotongkuaidi", @"longbanwuliu", @"debangwuliu", @"rufengda", @"quanritongkuaidi", @"jiajiwuliu", @"dhl"]
#define KD100_CN @[@"EMS快递", @"顺丰快递", @"申通快递", @"圆通快递", @"韵达快递", @"汇通快递", @"天天快递", @"中通快递", @"宅急送快递", @"中国邮政", @"全峰快递", @"国通快递", @"龙邦快递", @"德邦物流", @"如风达快递", @"全日通快递", @"佳吉快运", @"DHL快递"]
+ (void)getKD100WithExpCode:(NSString*)expCode expNo:(NSString*)expNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail{
	NSLog(@"使用快递100查询物流");
	NSInteger index = NSNotFound;
	NSArray *matches = [expCode preg_match:@"[\\u4e00-\\u9fa5]+"];
	if (matches.isArray) {
		NSString *companyName = [[[[expCode replace:@"快递" to:@""] replace:@"物流" to:@""] replace:@"快运" to:@""] replace:@"速递" to:@""];
		index = [companyName inArraySearch:KD100_CN];
	} else {
		index = [expCode inArray:KD100_EN];
	}
	if (index == NSNotFound) {
		NSLog(@"没有该物流公司代号: %@", expCode);
		if (fail) fail([NSString stringWithFormat:@"没有该物流公司代号: %@", expCode]);
		return;
	}
	NSString *companyName = KD100_EN[index];
	NSString *url = [NSString stringWithFormat:@"http://www.kuaidi100.com/query?type=%@&postid=%@", companyName, expNo];
	[Common getApiWithUrl:url success:^(NSMutableDictionary *json){
		if ([json[@"status"]intValue]==200) {
			if (success) {
				NSArray *data = json[@"data"];
				if (data.isArray) {
					data = data.reverse;
					success(data, json);
				} else {
					NSLog(@"KD100 NO DATA, CHANGE API");
					if ([ProgressHUD isShowing]) [ProgressHUD show:nil];
					[Common getICKDWithExpCode:expCode expNo:expNo success:success fail:fail];
				}
			}
		} else {
			NSLog(@"%@\n%@", url, json[@"message"]);
			if (fail) fail(json[@"message"]);
		}
	} fail:^(NSMutableDictionary *json, NSInteger code) {
		if (code==-1001) {
			NSLog(@"%@\n%@", url, @"KD100 TIMEOUT, CHANGE API");
			if ([ProgressHUD isShowing]) [ProgressHUD show:nil];
			[Common getICKDWithExpCode:expCode expNo:expNo success:success fail:fail];
		} else {
			NSLog(@"%@\n%@", url, @"快递100接口错误");
			if (fail) fail(@"快递100接口错误");
		}
	}];
}

//爱查快递
#define ICKD_EN @[@"ems", @"shunfeng", @"shentong", @"yuantong", @"yunda", @"huitong", @"tiantian", @"zhongtong", @"zhaijisong", @"pingyou", @"quanfeng", @"guotong", @"jingdong", @"ririshun", @"longbang", @"debang", @"rufeng", @"quanritong", @"jiaji", @"dhl"]
#define ICKD_CN @[@"EMS快递", @"顺丰快递", @"申通快递", @"圆通快递", @"韵达快递", @"汇通快递", @"天天快递", @"中通快递", @"宅急送快递", @"中国邮政", @"全峰快递", @"国通快递", @"京东快递", @"日日顺物流", @"龙邦快递", @"德邦物流", @"如风达快递", @"全日通快递", @"佳吉快运", @"DHL快递"]
+ (void)getICKDWithExpCode:(NSString*)expCode expNo:(NSString*)expNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail{
	NSLog(@"使用爱查快递查询物流");
	NSInteger index = NSNotFound;
	NSArray *matches = [expCode preg_match:@"[\\u4e00-\\u9fa5]+"];
	if (matches.isArray) {
		NSString *companyName = [[[[expCode replace:@"快递" to:@""] replace:@"物流" to:@""] replace:@"快运" to:@""] replace:@"速递" to:@""];
		companyName = [companyName replace:@"速运" to:@""];
		index = [companyName inArraySearch:ICKD_CN];
	} else {
		index = [expCode inArray:ICKD_EN];
	}
	if (index == NSNotFound) {
		NSLog(@"没有该物流公司代号: %@", expCode);
		if (fail) fail([NSString stringWithFormat:@"没有该物流公司代号: %@", expCode]);
		return;
	}
	NSString *companyName = ICKD_EN[index];
	NSString *url = [NSString stringWithFormat:@"http://biz.trace.ickd.cn/%@/%@?callback=callback", companyName, expNo];
	[Common getApiWithUrl:url options:nil success:^(NSMutableDictionary *json){
		NSString *data = [(NSString*)json replace:@"/**/callback&&callback(" to:@""];
		NSString *result = [data preg_replace:@"<span[^>]+?>" to:@""];
		result = [result replace:@"<\\/span>" to:@""];
		result = [result substringToIndex:result.length-1];
		json = result.formatJson;
		if (json.isDictionary) {
			if ([json[@"errCode"]intValue]==0) {
				if (success) {
					NSArray *data = json[@"data"];
					if (data.isArray) {
						success(data, json);
					} else {
						NSLog(@"ICKD NO DATA");
					}
				}
			} else {
				NSLog(@"%@\n%@", url, json[@"message"]);
				if (fail) fail(json[@"message"]);
			}
		} else {
			NSLog(@"%@\n%@", url, data);
			if (fail) fail(@"爱查快递接口错误");
		}
	} fail:^(NSMutableDictionary *json, NSInteger code) {
		if (code==-1001) {
			NSLog(@"%@\n%@", url, @"ICKD TIMEOUT, CHANGE API");
			if ([ProgressHUD isShowing]) [ProgressHUD show:nil];
			[Common getKuaidiWithExpCode:expCode expNo:expNo success:success fail:fail];
		} else {
			NSLog(@"%@\n%@", url, @"爱查快递接口错误");
			if (fail) fail(@"爱查快递接口错误");
		}
	}];
}

//获取后端配置参数
+ (void)apiConfigsWithAuditKey:(NSString*)auditKey completion:(void (^)(NSDictionary *configs))completion{
	if (auditKey.length) [@"auditKey" setUserDefaultsWithData:auditKey];
	[@"configs" deleteUserDefaults];
	[Common getApiWithParams:@[@"other", @"c"] feedback:ApiNonMessage success:^(NSMutableDictionary *json) {
		//NSLog(@"%@", json.descriptionASCII);
		NSDictionary *configs = json[@"data"];
		[@"configs" setUserDefaultsWithData:configs];
		if (completion) completion(configs);
	} fail:^(NSMutableDictionary *json, NSInteger code) {
		if (completion) completion(nil);
	}];
}

//后端有设置审核开关且为打开状态
+ (BOOL)isAuditKey{
	return [Common isAuditKey:nil];
}
+ (BOOL)isAuditKey:(NSString*)auditKey{
	NSDictionary *configs = [@"configs" getUserDefaultsDictionary];
	if (!auditKey.length) auditKey = [@"auditKey" getUserDefaultsString];
	if (!auditKey.length) auditKey = @"on1216";
	return !( !configs.isDictionary || !configs[auditKey] || [configs[auditKey]intValue]==0 );
}

@end
