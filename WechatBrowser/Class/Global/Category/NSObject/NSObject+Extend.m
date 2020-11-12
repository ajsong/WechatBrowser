//
//  NSObject+Extend.m
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#pragma mark - NSObject+Extend
@implementation NSObject (GlobalExtend)
- (NSMutableDictionary*)element{
	NSMutableDictionary *ele = objc_getAssociatedObject(self, kElementKey);
	if (!ele) {
		ele = [[NSMutableDictionary alloc]init];
		objc_setAssociatedObject(self, kElementKey, ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return ele;
}

- (void)removeElement:(NSString*)key{
	NSMutableDictionary *ele = objc_getAssociatedObject(self, kElementKey);
	if (!ele.isDictionary || ![ele[key]isset]) return;
	[ele removeObjectForKey:key];
	objc_setAssociatedObject(self, kElementKey, ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString*)removeElement{
	return nil;
}
- (void)setRemoveElement:(NSString*)key{
	[self removeElement:key];
}
- (void)removeAllElement{
	NSMutableDictionary *ele = [[NSMutableDictionary alloc]init];
	objc_setAssociatedObject(self, kElementKey, ele, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//是否为整型
- (BOOL)isInt{
	NSString *string = [NSString stringWithFormat:@"%@", self];
	if (!string.length) return NO;
	NSScanner *scan = [NSScanner scannerWithString:string];
	int val;
	return [scan scanInt:&val] && [scan isAtEnd];
}

//是否为浮点型
- (BOOL)isFloat{
	NSString *string = [NSString stringWithFormat:@"%@", self];
	if (!string.length) return NO;
	NSScanner *scan = [NSScanner scannerWithString:string];
	float val;
	return [scan scanFloat:&val] && [scan isAtEnd];
}

//是否数组
- (BOOL)isArray{
	if (!self.isset || ![self isKindOfClass:[NSArray class]]) return NO;
	return [((NSArray*)self) count]>0;
}

//是否字典
- (BOOL)isDictionary{
	if (!self.isset || ![self isKindOfClass:[NSDictionary class]]) return NO;
	return [((NSDictionary*)self) count]>0;
}

//是否为日期字符串
- (BOOL)isDate{
	if (!self.isset) return NO;
	if ([self isKindOfClass:[NSDate class]]) return YES;
	if ([self isKindOfClass:[NSString class]]) {
		return [(NSString*)self preg_test:@"^\\d{4}-\\d{1,2}-\\d{1,2}( \\d{1,2}:\\d{1,2}:\\d{1,2})?$"];
	}
	return NO;
}

//对象是否有内容
- (BOOL)isset{
	if (!self || self==nil || [self isKindOfClass:[NSNull class]]) return NO;
	if ([self isKindOfClass:[NSString class]]) {
		//return [(NSString*)self length]>0;
	} else if ([self isKindOfClass:[NSData class]]) {
		return [(NSData*)self length]>0;
	} else if ([self isKindOfClass:[NSArray class]]) {
		return [((NSArray*)self) count]>0;
	} else if ([self isKindOfClass:[NSDictionary class]]) {
		return [((NSDictionary*)self) count]>0;
	}
	return YES;
}

//字符串是否Json规则
- (BOOL)isJsonString{
	id json = [(NSString*)self formatJson];
	return json!=nil;
}

//数组是否包含, 包含即返回所在索引, 否则返回NSNotFound
- (NSInteger)inArray:(NSArray*)array{
	if (!array.isArray) return NSNotFound;
	NSInteger index = NSNotFound;
	if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSDictionary class]]) {
		NSString *own = self.jsonString;
		for (int i=0; i<array.count; i++) {
			NSString *item = [array[i] jsonString];
			if ([own isEqualToString:item]) {
				index = i;
				break;
			}
		}
	} else {
		index = [array indexOfObject:self];
	}
	return index;
}

//字典是否包含, 包含即返回所在key, 否则返回nil
- (NSString*)inDictionary:(NSDictionary*)dictionary{
	if (!dictionary.isDictionary) return nil;
	NSString *keyName = @"";
	if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSDictionary class]]) {
		NSString *own = self.jsonString;
		for (NSString *key in dictionary) {
			NSString *item = [dictionary[key] jsonString];
			if ([own isEqualToString:item]) {
				keyName = key;
				break;
			}
		}
	} else {
		for (NSString *key in dictionary) {
			if ([self isEqual:dictionary[key]]) {
				keyName = key;
				break;
			}
		}
	}
	return keyName;
}

//数组是否包含元素, 使用模糊查找, 包含即返回所在索引, 否则返回NSNotFound
- (NSInteger)inArraySearch:(NSArray*)array{
	if (!array.isArray) return NSNotFound;
	NSInteger index = NSNotFound;
	NSString *own = self.jsonString.lowercaseString;
	for (int i=0; i<array.count; i++) {
		NSString *item = [[array[i] jsonString] lowercaseString];
		if ([item indexOf:own]!=NSNotFound) {
			index = i;
			break;
		}
	}
	return index;
}

//数组是否包含, 使用内存地址查找, 包含即返回所在索引, 否则返回NSNotFound
- (NSInteger)inArrayRam:(NSArray*)array{
	if (!array.isArray) return NSNotFound;
	return [array indexOfObject:self];
}

//强制转换类型
- (id)changeType:(NSString*)className{
	id obj = nil;
	if (className.length) {
		Class cls = NSClassFromString(className);
		if (cls) {
			if ([self isKindOfClass:cls]) obj = self;
		}
	}
	return obj;
}
- (NSString*)stringValue{
	return (NSString*)[self changeType:@"NSString"];
}
- (NSNumber*)numberValue{
	return (NSNumber*)[self changeType:@"NSNumber"];
}
- (NSData*)dataValue{
	return (NSData*)[self changeType:@"NSData"];
}
- (NSDate*)dateValue{
	return (NSDate*)[self changeType:@"NSDate"];
}
- (NSArray*)arrayValue{
	return (NSArray*)[self changeType:@"NSArray"];
}
- (NSDictionary*)dictionaryValue{
	return (NSDictionary*)[self changeType:@"NSDictionary"];
}

//Json字符串转Dictionary、Array
- (id)jsonValue{
	return [((NSString*)self) formatJson];
}

//Dictionary、Array转Json字符串
- (NSString*)jsonString{
	return [self jsonString:0];
}
- (NSString*)jsonString:(NSJSONWritingOptions)options{
	if (!self || self==nil) return @"";
	if (![self isKindOfClass:[NSArray class]] && ![self isKindOfClass:[NSDictionary class]]) return [NSString stringWithFormat:@"%@", self];
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self jsonStringWash] options:options error:&error]; //NSJSONWritingPrettyPrinted
	if (!jsonData || error!=nil) {
		NSLog(@"%@",error);
		return @"";
	} else {
		NSString *str = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
		str = [str preg_replace:@"\\s*:\\s*null" to:@":\"\""];
		str = [str preg_replace:@"\\s*:\\s*\\[\\]" to:@":\"\""];
		str = [str preg_replace:@"\\s*:\\s*\\{\\}" to:@":\"\""];
		return str;
	}
}
- (id)jsonStringWash{
	id object = nil;
	if ([self isKindOfClass:[NSArray class]]) {
		object = [NSMutableArray array];
		[(NSArray*)self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			id value = nil;
			if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSNull class]]) {
				value = obj;
			} else if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
				value = [obj jsonStringWash];
			} else {
				value = [NSString stringWithFormat:@"%@", obj];
			}
			[(NSMutableArray*)object addObject:value];
		}];
	} else {
		object = [NSMutableDictionary dictionary];
		[(NSDictionary*)self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
			NSString *keyString = nil;
			id value = nil;
			if ([key isKindOfClass:[NSString class]]) {
				keyString = key;
			} else {
				keyString = [NSString stringWithFormat:@"%@", key];
			}
			if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSNull class]]) {
				value = obj;
			} else if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
				value = [obj jsonStringWash];
			} else {
				value = [NSString stringWithFormat:@"%@", obj];
			}
			[object setObject:value forKey:keyString];
		}];
	}
	return object;
}

//为又拍云图片路径增加后缀,即转换为缩略图路径
- (id)UpyunSuffix:(NSString*)suffix{
	id result = self;
	if ([self isKindOfClass:[NSArray class]]) {
		result = [(NSArray*)result UpyunSuffix:suffix];
	} else if ([self isKindOfClass:[NSDictionary class]]) {
		result = [(NSDictionary*)result UpyunSuffix:suffix];
	} else if ([self isKindOfClass:[NSString class]]) {
		result = [(NSString*)result UpyunSuffix:suffix];
	}
	return result;
}
//为指定的key的值增加又拍云后缀
- (id)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys{
	id result = self;
	if ([result isKindOfClass:[NSArray class]] || [result isKindOfClass:[NSDictionary class]]) {
		result = [result UpyunSuffix:suffix forKeys:keys];
	}
	return result;
}
//把又拍云图片指定后缀替换为其他指定后缀
- (id)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix{
	id result = self;
	if ([self isKindOfClass:[NSArray class]]) {
		result = [(NSArray*)result UpyunSuffixReplace:originSuffix to:suffix];
	} else if ([self isKindOfClass:[NSDictionary class]]) {
		result = [(NSDictionary*)result UpyunSuffixReplace:originSuffix to:suffix];
	} else if ([self isKindOfClass:[NSString class]]) {
		result = [(NSString*)result UpyunSuffixReplace:originSuffix to:suffix];
	}
	return result;
}

//获取对象的所有属性
- (NSArray*)getProperties{
	u_int count;
	objc_property_t *properties = class_copyPropertyList([self class], &count);
	NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
	for (int i=0; i<count ; i++) {
		const char *propertyName = property_getName(properties[i]);
		[propertiesArray addObject:[NSString stringWithUTF8String:propertyName]];
	}
	free(properties);
	return propertiesArray;
}
//获取对象的所有属性和值, NSObject转NSDictionary
- (NSDictionary*)getPropertiesAndVaules{
	NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
	unsigned int count;
	Ivar *vars = class_copyIvarList([self class], &count);
	for (int i=0; i<count; i++) {
		Ivar thisIvar = vars[i];
		NSString *key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		NSString *propertyName = [key substringFromIndex:1];
		id value = [self valueForKey:propertyName];
		if (!value) {
			value = [NSNull null];
		} else {
			value = [self getPropertiesInternal:value];
		}
		[dic setObject:value forKey:propertyName];
	}
	free(vars);
	return dic;
}
- (NSDictionary*)getPropertiesAndVaules1{
	NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
	unsigned int count;
	objc_property_t *properties = class_copyPropertyList([self class], &count);
	for (int i=0; i<count; i++) {
		objc_property_t property = properties[i];
		NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
		//NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
		id value = [self valueForKey:propertyName];
		if (!value) {
			value = [NSNull null];
		} else {
			value = [self getPropertiesInternal:value];
		}
		[dic setObject:value forKey:propertyName];
	}
	free(properties);
	return dic;
}
//自定义处理数组，字典，其他类
- (id)getPropertiesInternal:(id)value{
	if ([value isKindOfClass:[NSArray class]]) {
		NSArray *objArr = value;
		NSMutableArray *arr = [NSMutableArray array];
		for (int i=0; i<objArr.count; i++) {
			[arr addObject:[self getPropertiesInternal:objArr[i]]];
		}
		return arr;
	}
	if ([value isKindOfClass:[NSDictionary class]]) {
		NSDictionary *objDic = value;
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		for (NSString *key in objDic.allKeys) {
			[dic setObject:[self getPropertiesInternal:objDic[key]] forKey:key];
		}
		return dic;
	}
	return value;
}
//获取对象的所有方法
- (void)getMethods{
	unsigned int mothCout =0;
	Method* mothList = class_copyMethodList([self class], &mothCout);
	for (int i=0; i<mothCout; i++) {
		Method temp_f = mothList[i];
		//IMP imp_f = method_getImplementation(temp_f);
		//SEL name_f = method_getName(temp_f);
		const char *name_s = sel_getName(method_getName(temp_f));
		int arguments = method_getNumberOfArguments(temp_f);
		const char *encoding = method_getTypeEncoding(temp_f);
		NSLog(@"方法名:%@, 参数个数:%d, 编码方式:%@", [NSString stringWithUTF8String:name_s], arguments, [NSString stringWithUTF8String:encoding]);
	}
	free(mothList);
}
@end

@implementation NSObject (MethodExchange)
//交换两个函数实现指针
+ (void)SwizzlingMethod:(NSString *)systemMethod systemClass:(NSString *)systemClass toSafeMethod:(NSString *)safeMethod targetClass:(NSString *)targetClass{
	//获取系统方法IMP
	Method sysMethod = class_getInstanceMethod(NSClassFromString(systemClass), NSSelectorFromString(systemMethod));
	//自定义方法IMP
	Method safMethod = class_getInstanceMethod(NSClassFromString(targetClass), NSSelectorFromString(safeMethod));
	//IMP互相交换,方法的实现也就互相交换了
	method_exchangeImplementations(safMethod, sysMethod);
}

+ (void)exchangeMethod:(SEL)origSel withNewMethod:(SEL)newSel{
	Class class = [self class];
	Method origMethod = class_getInstanceMethod(class, origSel);
	if (!origMethod) {
		origMethod = class_getClassMethod(class, origSel);
	}
	if (!origMethod)
		@throw [NSException exceptionWithName:@"Original method not found" reason:nil userInfo:nil];
	Method newMethod = class_getInstanceMethod(class, newSel);
	if (!newMethod) {
		newMethod = class_getClassMethod(class, newSel);
	}
	if (!newMethod)
		@throw [NSException exceptionWithName:@"New method not found" reason:nil userInfo:nil];
	if (origMethod==newMethod)
		@throw [NSException exceptionWithName:@"Methods are the same" reason:nil userInfo:nil];
	method_exchangeImplementations(origMethod, newMethod);
}
@end

@interface FMObserverHelper : NSObject
@property (nonatomic,unsafe_unretained) id target;
@property (nonatomic,unsafe_unretained) id observer;
@property (nonatomic,strong) NSString *keyPath;
@property (nonatomic,weak) FMObserverHelper *factor;
@end
@implementation FMObserverHelper
- (void)dealloc {
	if (_factor) {
		[_target removeObserver:_observer forKeyPath:_keyPath];
	}
}
@end
@implementation NSObject (FMObserverHelper)
- (void)fm_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
	[self addObserver:observer forKeyPath:keyPath options:options context:context];
	FMObserverHelper *helper = [FMObserverHelper new];
	FMObserverHelper *sub = [FMObserverHelper new];
	sub.target = helper.target = self;
	sub.observer = helper.observer = observer;
	sub.keyPath = helper.keyPath = keyPath;
	helper.factor = sub;
	sub.factor = helper;
	const char * helpeKey = [NSString stringWithFormat:@"%zd", [observer hash]].UTF8String;
	objc_setAssociatedObject(self, helpeKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(observer, helpeKey, sub, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
