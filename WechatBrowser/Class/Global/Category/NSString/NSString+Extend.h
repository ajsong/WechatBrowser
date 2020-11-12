//
//  NSString+Extend.h
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - NSString+Extend
@interface NSString (GlobalExtend)
- (id)getUserDefaults;
- (NSString*)getUserDefaultsString;
- (int)getUserDefaultsInt;
- (NSInteger)getUserDefaultsInteger;
- (CGFloat)getUserDefaultsFloat;
- (BOOL)getUserDefaultsBool;
- (NSMutableArray*)getUserDefaultsArray;
- (NSMutableDictionary*)getUserDefaultsDictionary;
- (void)setUserDefaultsWithData:(id)data;
- (void)replaceUserDefaultsWithData:(NSDictionary*)data;
- (void)deleteUserDefaults;
- (CGSize)autoWidth:(UIFont*)font height:(CGFloat)height;
- (CGSize)autoHeight:(UIFont*)font width:(CGFloat)width;
- (NSString*)strtolower;
- (NSString*)strtoupper;
- (NSString*)strtoupperFirst;
- (NSString*)trim;
- (NSString*)trim:(NSString*)assign;
- (NSString*)trimNewline;
- (NSInteger)indexOf:(NSString*)str;
- (NSInteger (^)(NSString*))indexOf;
- (NSString*)replace:(NSString*)r1 to:(NSString*)r2;
- (NSString*)substr:(NSInteger)start length:(NSInteger)length;
- (NSString*)substr:(NSInteger)start;
- (NSString*)left:(NSInteger)length;
- (NSString*)right:(NSInteger)length;
- (NSInteger)countStrings:(NSString*)string;
- (NSInteger)fontLength;
- (NSMutableArray*)splitString;
- (NSMutableArray*)split:(NSString*)symbol;
- (NSMutableArray*)explode:(NSString*)symbol;
- (NSMutableArray *(^)(NSString*))split;
- (NSMutableArray *(^)(NSString*))explode;
- (NSMutableArray*)str_split:(NSInteger)length;
- (NSString*)markMobile;
- (NSMutableDictionary*)params;
- (NSMutableDictionary*)params:(NSString*)mark;
- (NSString*)cropHtml:(NSString*)startStr overStr:(NSString*)overStr;
- (NSString*)deleteStringPart:(NSString*)prefix suffix:(NSString*)suffix;
- (BOOL)preg_test:(NSString*)patton;
- (NSString*)preg_replace:(NSString*)patton to:(NSString*)templateStr;
- (NSString*)preg_replace:(NSString*)patton replacement:(NSString *(^)(NSDictionary *matcher, NSInteger index))replacement;
- (NSMutableArray*)preg_match:(NSString*)patton;
- (NSString*)UpyunSuffix:(NSString*)suffix;
- (NSString*)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix;
- (id)jsonValue;
- (id)formatJson;
- (BOOL)isInt;
- (BOOL)isInt:(NSInteger)length;
- (BOOL)isFloat;
- (BOOL)isFloat:(NSInteger)length;
- (BOOL)isUsername;
- (BOOL)isPassword;
- (BOOL)hasChinese;
- (BOOL)isChinese;
- (BOOL)isEmail;
- (BOOL)isMobile;
- (BOOL)isDate;
- (BOOL)isUrl;
- (BOOL)isIDCard;
- (BOOL)isEmoji;
- (double)calculateFormula;
- (NSString*)getFullFilename;
- (NSString*)getFilename;
- (NSString*)getSuffix;
- (NSString*)encode;
- (NSString*)decode;
- (NSString*)ASCII;
- (NSString*)Unicode;
- (NSString*)URLEncode;
- (NSString*)URLEncode:(NSStringEncoding)encoding;
- (NSString*)URLEncodeSpace;
- (NSString*)URLDecode;
- (NSString*)URLDecode:(NSStringEncoding)encoding;
- (NSString*)base64;
- (NSString*)base64Encode;
- (NSString*)base64Decode;
- (NSString*)base64ToString;
- (NSData*)base64ToData;
- (UIImage*)base64ToImage;
- (NSString*)md5;
- (NSString*)sha1;
- (NSAttributedString*)simpleHtml;
- (void)cacheImageAndCompletion:(void (^)(UIImage *image, NSData *imageData))completion;
- (void)loadImageAndCompletion:(void (^)(UIImage *image, NSData *imageData))completion;
- (NSAttributedString*)attributedStyle:(NSDictionary*)styleBook;
- (NSAttributedString*)attributedStyle:(NSDictionary*)styleBook withLabel:(UILabel*)label linkAction:(void (^) (NSString *string, NSRange range, NSInteger index, NSString *href))linkAction;
- (NSMutableAttributedString *)exchangeString:(NSString *)string imageName:(NSString *)imageName imageSize:(CGSize)imageSize;
- (NSString*)getFirstLetter;
@end
