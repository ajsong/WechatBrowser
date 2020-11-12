//
//  NSArray+Extend.h
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - NSMutableArray+Extend
@interface NSArray (GlobalExtend)
- (void)each:(BOOL (^)(int index, id object))object;
- (NSArray*)reverse;
- (NSArray*)merge:(NSArray*)array;
- (NSInteger)hasChild:(id)object;
- (id)minValue;
- (id)maxValue;
- (NSInteger)minValueIndex;
- (NSInteger)maxValueIndex;
- (NSString*)join:(NSString*)symbol;
- (NSString*)implode:(NSString*)symbol;
- (NSString*)descriptionASCII;
- (NSArray*)compatible;
- (void)UploadToUpyun:(NSString*)upyunFolder each:(void (^)(NSMutableDictionary *json, NSString *imageUrl, NSInteger index))each completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion;
- (void)UploadToUpyun:(NSString*)upyunFolder each:(void (^)(NSMutableDictionary *json, NSString *imageUrl, NSInteger index))each progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion;
- (void)UploadToQiniu:(NSString*)token each:(void (^)(NSString *imageUrl, NSInteger index))each completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion;
- (void)UploadToQiniu:(NSString*)token each:(void (^)(NSString *imageUrl, NSInteger index))each progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion;
- (NSArray*)UpyunSuffix:(NSString*)suffix;
- (NSArray*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys;
- (NSArray*)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix;
- (void)cacheImageAndCompletion:(void (^)(NSArray *images))completion;
- (void)loadImageAndCompletion:(void (^)(NSArray *images))completion;
- (NSArray*)addObject:(id)anObject;
- (NSArray*)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (NSArray*)removeLastObject;
- (NSArray*)removeObjectAtIndex:(NSUInteger)index;
- (NSArray*)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
@end

@interface NSMutableArray (GlobalExtend)
- (void)unshift:(id)object;
- (void)shift;
- (void)pop;
- (void)moveIndex:(NSUInteger)from toIndex:(NSUInteger)to;
- (void)each:(BOOL (^)(int index, id object))object;
- (NSMutableArray*)reverse;
- (NSMutableArray*)merge:(NSArray*)array;
- (NSInteger)hasChild:(id)object;
- (id)minValue;
- (id)maxValue;
- (NSInteger)minValueIndex;
- (NSInteger)maxValueIndex;
- (NSString*)join:(NSString*)symbol;
- (NSString*)implode:(NSString*)symbol;
- (NSString*)descriptionASCII;
- (NSMutableArray*)compatible;
- (void)UploadToUpyun:(NSString*)upyunFolder each:(void (^)(NSMutableDictionary *json, NSString *imageUrl, NSInteger index))each completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion;
- (void)UploadToUpyun:(NSString*)upyunFolder each:(void (^)(NSMutableDictionary *json, NSString *imageUrl, NSInteger index))each progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion;
- (void)UploadToQiniu:(NSString*)token each:(void (^)(NSString *imageUrl, NSInteger index))each completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion;
- (void)UploadToQiniu:(NSString*)token each:(void (^)(NSString *imageUrl, NSInteger index))each progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion;
- (NSMutableArray*)UpyunSuffix:(NSString*)suffix;
- (NSMutableArray*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys;
- (NSMutableArray*)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix;
- (void)cacheImageAndCompletion:(void (^)(NSArray *images))completion;
- (void)loadImageAndCompletion:(void (^)(NSArray *images))completion;
- (NSMutableArray*)objectsForFilter:(NSDictionary*)filter;
- (NSMutableDictionary*)objectForFilter:(NSDictionary*)filter;
- (NSInteger)objectsCount:(NSDictionary*)filter;
- (void)insertObject:(NSDictionary*)object;
- (void)insertObject:(NSDictionary*)object keepRow:(NSInteger)num;
- (void)insertObject:(NSDictionary*)object userDefaults:(NSString*)key;
- (void)insertObject:(NSDictionary*)object keepRow:(NSInteger)num userDefaults:(NSString*)key;
- (void)updateObject:(NSDictionary*)object filter:(NSDictionary*)filter;
- (void)updateObject:(NSDictionary*)object filter:(NSDictionary*)filter userDefaults:(NSString*)key;
- (void)deleteObject:(NSDictionary*)filter;
- (void)deleteObject:(NSDictionary*)filter userDefaults:(NSString*)key;
- (id)field:(NSString*)key filter:(NSDictionary*)filter;
- (int)fieldInt:(NSString*)key filter:(NSDictionary*)filter;
- (NSUInteger)fieldInteger:(NSString*)key filter:(NSDictionary*)filter;
- (CGFloat)fieldFloat:(NSString*)key filter:(NSDictionary*)filter;
- (NSString*)fieldString:(NSString*)key filter:(NSDictionary*)filter;
- (NSMutableArray*)arrayWithPinYinFirstLetterFormat;
- (NSMutableArray*)arrayWithPinYinFirstLetterFormatWithKey:(NSString*)key;
@end


#if !TARGET_IPHONE_SIMULATOR
#pragma mark - NSMutableArray+Swizzling
@interface NSArray (Swizzling)
@end
@interface NSMutableArray (Swizzling)
@end
#endif
