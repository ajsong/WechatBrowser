//
//  NSDictionary+Extend.m
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#pragma mark - NSMutableDictionary+Extend
@implementation NSDictionary (GlobalExtend)
- (NSDictionary*)merge:(NSDictionary*)dictionary{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self];
	for (NSString *key in dictionary) {
		[newDict setObject:dictionary[key] forKey:key];
	}
	return newDict;
}
- (NSString*)hasChild:(id)object{
	return [object inDictionary:self];
}
- (NSString*)descriptionASCII{
	NSString *description = [NSString stringWithCString:[self.description cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
	if (!description.length) description = [self description];
	return description;
}
- (NSDictionary*)replaceNull{
	if (!self.isDictionary) return self;
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self];
	newDict = newDict.replaceNull;
	return newDict;
}
- (NSDictionary*)UpyunSuffix:(NSString*)suffix{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self];
	newDict = [newDict UpyunSuffix:suffix];
	return newDict;
}
- (NSDictionary*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self];
	newDict = [newDict UpyunSuffix:suffix forKeys:keys];
	return newDict;
}
- (NSDictionary*)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self];
	newDict = [newDict UpyunSuffixReplace:originSuffix to:suffix];
	return newDict;
}
@end
@implementation NSMutableDictionary (GlobalExtend)
- (NSMutableDictionary*)merge:(NSDictionary*)dictionary{
	NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self];
	for (NSString *key in dictionary) {
		[newDict setObject:dictionary[key] forKey:key];
	}
	return newDict;
}
- (NSString*)hasChild:(id)object{
	return [object inDictionary:self];
}
- (NSString*)descriptionASCII{
	NSString *description = [NSString stringWithCString:[[self description] cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
	if (!description.length) description = [self description];
	return description;
}
//转换null为空字符串
- (NSMutableDictionary*)replaceNull{
	if (!self.isDictionary) return self;
	NSMutableDictionary *newDict = [[NSMutableDictionary alloc]init];
	for (NSString *key in self) {
		if (!self[key] || self[key]==nil || [self[key] isKindOfClass:[NSNull class]]) {
			[newDict setObject:@"" forKey:key];
		} else {
			[newDict setObject:self[key] forKey:key];
		}
	}
	return newDict;
}
//为又拍云图片路径增加后缀,即转换为缩略图路径
- (NSMutableDictionary*)UpyunSuffix:(NSString*)suffix{
	NSMutableDictionary *newDict = [[NSMutableDictionary alloc]init];
	for (NSString *key in self) {
		[newDict setObject:[self[key] UpyunSuffix:suffix] forKey:key];
	}
	return newDict;
}
//为指定的key的值增加又拍云后缀
- (NSMutableDictionary*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys{
	NSMutableDictionary *newDict = [[NSMutableDictionary alloc]init];
	for (NSString *key in self) {
		if ([key inArray:keys]!=NSNotFound) {
			[newDict setObject:[self[key] UpyunSuffix:suffix] forKey:key];
		} else {
			[newDict setObject:self[key] forKey:key];
		}
	}
	return newDict;
}
//把又拍云图片指定后缀替换为其他指定后缀
- (NSMutableDictionary*)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix{
	NSMutableDictionary *newDict = [[NSMutableDictionary alloc]init];
	for (NSString *key in self) {
		[newDict setObject:[self[key] UpyunSuffixReplace:originSuffix to:suffix] forKey:key];
	}
	return [newDict UpyunSuffix:suffix];
}
@end


#if !TARGET_IPHONE_SIMULATOR
#pragma mark - NSMutableDictionary+Swizzling
@implementation NSDictionary (Swizzling)
+ (void)load{
	static dispatch_once_t onceDispatch;
	dispatch_once(&onceDispatch, ^{
		[self SwizzlingMethod:@"initWithObjects:forKeys:count:" systemClass:@"__NSPlaceholderDictionary" toSafeMethod:@"initWithObjects_st:forKeys:count:" targetClass:@"NSDictionary"];
	});
}
- (instancetype)initWithObjects_st:(id *)objects forKeys:(id<NSCopying> *)keys count:(NSUInteger)count {
	NSUInteger rightCount = 0;
	for (NSUInteger i=0; i<count; i++) {
		if (!(keys[i] && objects[i])) {
			NLog(@"METADATA ERROR\n%@\n", keys[i]);
			break;
		} else {
			rightCount++;
		}
	}
	self = [self initWithObjects_st:objects forKeys:keys count:rightCount];
	return self;
}
@end
@implementation NSMutableDictionary (Swizzling)
+ (void)load{
	static dispatch_once_t onceDispatch;
	dispatch_once(&onceDispatch, ^{
		[self SwizzlingMethod:@"removeObjectForKey:" systemClass:@"__NSDictionaryM" toSafeMethod:@"st_removeObjectForKey:" targetClass:@""];
		[self SwizzlingMethod:@"setObject:forKey:" systemClass:@"__NSDictionaryM" toSafeMethod:@"st_setObject:forKey:" targetClass:@"NSMutableDictionary"];
	});
}
- (void)st_removeObjectForKey:(id)key {
	if (!key) {
		NLog(@"METADATA KEY ERROR\n");
		return;
	}
	[self st_removeObjectForKey:key];
}
- (void)st_setObject:(id)obj forKey:(id <NSCopying>)key {
	if (!obj) {
		NLog(@"METADATA OBJECT ERROR\n%@\n", key);
		obj = @"";
	}
	if (!key) {
		NLog(@"METADATA KEY ERROR\n");
		return;
	}
	[self st_setObject:obj forKey:key];
}
@end
#endif
