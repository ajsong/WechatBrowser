//
//  NSDictionary+Extend.h
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - NSMutableDictionary+Extend
@interface NSDictionary (GlobalExtend)
- (NSDictionary*)merge:(NSDictionary*)dictionary;
- (NSString*)hasChild:(id)object;
- (NSString*)descriptionASCII;
- (NSDictionary*)replaceNull;
- (NSDictionary*)UpyunSuffix:(NSString*)suffix;
- (NSDictionary*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys;
- (NSDictionary*)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix;
@end
@interface NSMutableDictionary (GlobalExtend)
- (NSMutableDictionary*)merge:(NSDictionary*)dictionary;
- (NSString*)hasChild:(id)object;
- (NSString*)descriptionASCII;
- (NSMutableDictionary*)replaceNull;
- (NSMutableDictionary*)UpyunSuffix:(NSString*)suffix;
- (NSMutableDictionary*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys;
- (NSMutableDictionary*)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix;
@end


#if !TARGET_IPHONE_SIMULATOR
#pragma mark - NSMutableDictionary+Swizzling
@interface NSDictionary (Swizzling)
@end
@interface NSMutableDictionary (Swizzling)
@end
#endif
