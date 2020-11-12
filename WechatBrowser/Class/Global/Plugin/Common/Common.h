//
//  Common.h
//
//  Created by ajsong on 15/4/23.
//  Copyright (c) 2015 @jsong. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString * const ApiAlwaysShowMessage; //接口一直显示加载标识,直到手动关闭
UIKIT_EXTERN NSString * const ApiKeyMessage; //使用接口提示标识
UIKIT_EXTERN NSString * const ApiNonMessage; //接口不显示任何返回提示标识
UIKIT_EXTERN NSString * const ApiNonSuccessMessage; //接口不显示成功返回提示标识
UIKIT_EXTERN NSString * const ApiPostSuccessMessage; //提交接口成功的默认提示标识
UIKIT_EXTERN NSString * const ApiPostFailureMessage; //提交接口失败的默认提示标识

typedef enum : NSInteger {
	CommonFeedbackTypeAuto = 0, //根据情况自动显示返回提示
	CommonFeedbackTypeNonSuccess, //不显示成功返回提示
	CommonFeedbackTypeNon, //完全不显示任何返回提示
} CommonFeedbackType;

@interface Common : NSObject
//以下为全局参数
@property (nonatomic,strong) NSMutableArray *queues; //提交队列
@property (nonatomic,copy) id(^urlData)(id data); //请求前组装链接数据, [Common shared].urlData = ^id(id data){return data;};
@property (nonatomic,copy) id(^postData)(NSString *url, id data); //请求前组装提交数据,例如需要加密参数等, [Common shared].postData = ^id(NSString *url, id data){return data;};
@property (nonatomic,copy) id(^optionsData)(NSString *url, id data); //请求前组装选项数据,例如需要设置头部参数等, [Common shared].optionsData = ^id(NSString *url, id data){[data setObject:@"raw" forKey:@"type"];[data setObject:@{@"aa":@"bb"} forKey:@"header"];return data;};
@property (nonatomic,assign) CommonFeedbackType feedbackType; //全局feedback类型, [Common shared].feedbackType = CommonFeedbackTypeNonSuccess;

+ (Common*)shared;
+ (void)setUrlData:(id (^)(id data))urlData;
+ (void)setPostData:(id (^)(NSString *url, id data))postData;
+ (void)setOptionsData:(id (^)(NSString *url, id data))optionsData;
+ (void)setFeedbackType:(CommonFeedbackType)feedbackType;

- (Common *(^)(NSString *url))url;
- (Common *(^)(id params))params;
- (Common *(^)(id data))data;
- (Common *(^)(NSString *type))type;
- (Common *(^)(NSString *feedback))feedback;
- (Common *(^)(NSTimeInterval cachetime))cachetime;
- (Common *(^)(NSTimeInterval timeout))timeout;
- (Common *(^)(void(^progress)(NSProgress *progress)))progress;
- (Common *(^)(void(^success)(NSMutableDictionary *json)))success;
- (Common *(^)(void(^fail)(NSMutableDictionary *json, NSInteger code)))fail;
- (Common *(^)(void(^complete)(NSMutableDictionary *json)))complete;
- (NSString *(^)(void))get;
- (NSString *(^)(void))post;
- (NSString *(^)(void))upload;

+ (NSString*)apiUrlWithFile:(NSString*)file params:(id)params;

+ (NSString*)getApiWithParams:(id)params complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)getApiWithParams:(id)params feedback:(NSString*)feedback complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)getApiWithParams:(id)params success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithParams:(id)params options:(NSDictionary*)options success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithParams:(id)params cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithParams:(id)params feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithParams:(id)params feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithFile:(NSString*)file params:(id)params feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithUrl:(NSString*)url success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithUrl:(NSString*)url options:(NSDictionary*)options success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithUrl:(NSString*)url cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithUrl:(NSString*)url feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithUrl:(NSString*)url feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)getApiWithUrl:(NSString*)url options:(NSDictionary*)options feedback:(NSString*)feedback cachetime:(NSTimeInterval)cachetime success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete;

+ (NSString*)postAutoApiWithParams:(id)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)postAutoApiWithParams:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;

+ (NSString*)postApiWithParams:(id)params success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data options:(NSDictionary*)options success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)postApiWithParams:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)postApiWithFile:(NSString*)file params:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)postApiWithFile:(NSString*)file params:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)postApiWithUrl:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)postJSONWithUrl:(NSString*)url data:(id)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)postApiWithUrl:(NSString*)url data:(NSDictionary*)data options:(NSDictionary*)options timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete;

+ (NSString*)uploadApiWithParams:(id)params data:(NSDictionary*)data success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)uploadApiWithParams:(id)params data:(NSDictionary*)data options:(NSDictionary*)options success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)uploadApiWithParams:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)uploadApiWithParams:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)uploadApiWithParams:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)uploadApiWithFile:(NSString*)file params:(id)params data:(NSDictionary*)data feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail;
+ (NSString*)uploadApiWithFile:(NSString*)file params:(id)params data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)uploadApiWithUrl:(NSString*)url data:(NSDictionary*)data timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete;
+ (NSString*)uploadApiWithUrl:(NSString*)url data:(NSDictionary*)data options:(NSDictionary*)options timeout:(NSTimeInterval)timeout feedback:(NSString*)feedback progress:(void (^)(NSProgress *progress))progress success:(void (^)(NSMutableDictionary *json))success fail:(void (^)(NSMutableDictionary *json, NSInteger code))fail complete:(void (^)(NSMutableDictionary *json))complete;

+ (BOOL)removeUrlCache:(NSString*)url;
+ (void)removeAllCache;

+ (void)successExecute:(NSDictionary*)json;
+ (void)errorExecute:(NSDictionary*)json;

+ (NSString*)formatPublicKey:(NSString*)publicKey;
+ (NSString*)RsaPublicEncode:(NSString*)string;
+ (NSString*)RsaPublicDecode:(NSString*)string;
+ (void)getKuaidiWithExpCode:(NSString*)expCode expNo:(NSString*)expNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail;
+ (void)getKD100WithExpCode:(NSString*)expCode expNo:(NSString*)expNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail;
+ (void)getICKDWithExpCode:(NSString*)expCode expNo:(NSString*)expNo success:(void (^)(NSArray *data, NSMutableDictionary *json))success fail:(void (^)(NSString *msg))fail;
+ (void)apiConfigsWithAuditKey:(NSString*)auditKey completion:(void (^)(NSDictionary *configs))completion;
+ (BOOL)isAuditKey;
+ (BOOL)isAuditKey:(NSString*)auditKey;

@end
