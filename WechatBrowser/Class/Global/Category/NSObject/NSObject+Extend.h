//
//  NSObject+Extend.h
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#pragma mark - NSObject+Extend
@interface NSObject (GlobalExtend)
- (NSMutableDictionary*)element;
- (void)removeElement:(NSString*)key;
- (NSString*)removeElement;
- (void)setRemoveElement:(NSString*)key;
- (void)removeAllElement;
- (BOOL)isInt;
- (BOOL)isFloat;
- (BOOL)isArray;
- (BOOL)isDictionary;
- (BOOL)isDate;
- (BOOL)isset;
- (BOOL)isJsonString;
- (NSInteger)inArray:(NSArray*)array;
- (NSString*)inDictionary:(NSDictionary*)dictionary;
- (NSInteger)inArraySearch:(NSArray*)array;
- (id)changeType:(NSString*)className;
- (NSString*)stringValue;
- (NSNumber*)numberValue;
- (NSData*)dataValue;
- (NSDate*)dateValue;
- (NSArray*)arrayValue;
- (NSDictionary*)dictionaryValue;
- (id)jsonValue;
- (NSString*)jsonString;
- (NSString*)jsonString:(NSJSONWritingOptions)options;
- (id)UpyunSuffix:(NSString*)suffix;
- (id)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys;
- (id)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix;
- (NSDictionary*)getPropertiesAndVaules;
- (NSArray*)getProperties;
- (void)getMethods;
@end

#define EXCHANGE_METHOD(a, b) [[self class] exchangeMethod:@selector(a) withNewMethod:@selector(b)]
@interface NSObject (MethodExchange)
+ (void)SwizzlingMethod:(NSString *)systemMethod systemClass:(NSString *)systemClass toSafeMethod:(NSString *)safeMethod targetClass:(NSString *)targetClass;
+(void)exchangeMethod:(SEL)origSel withNewMethod:(SEL)newSel;
@end

//安全KVO,不需要removeObserver
@interface NSObject (FMObserverHelper)
- (void)fm_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
@end
NS_ASSUME_NONNULL_END
