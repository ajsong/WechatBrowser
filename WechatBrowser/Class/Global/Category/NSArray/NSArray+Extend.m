//
//  NSArray+Extend.m
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#pragma mark - NSMutableArray+Extend
@implementation NSArray (GlobalExtend)
- (void)each:(BOOL (^)(int index, id object))object{
	if (!self.count) return;
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr each:object];
}
- (NSArray*)reverse{
	NSMutableArray *newArr = [[NSMutableArray alloc]init];
	for (NSInteger i=self.count-1; i>=0; i--) {
		[newArr addObject:self[i]];
	}
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)merge:(NSArray*)array{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	for (NSInteger i=0; i<array.count; i++) {
		if ([array[i] inArray:newArr]!=NSNotFound) [newArr addObject:array[i]];
	}
	return [NSArray arrayWithArray:newArr];
}
- (NSInteger)hasChild:(id)object{
	return [object inArray:self];
}
- (id)minValue{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return [newArr minValue];
}
- (id)maxValue{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return [newArr maxValue];
}
- (NSInteger)minValueIndex{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return [newArr minValueIndex];
}
- (NSInteger)maxValueIndex{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return [newArr maxValueIndex];
}
- (NSString*)join:(NSString*)symbol{
	return [self implode:symbol];
}
- (NSString*)implode:(NSString*)symbol{
	if (!self.count) return @"";
	return [self componentsJoinedByString:symbol];
}
- (NSString*)descriptionASCII{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return newArr.descriptionASCII;
}
- (NSArray*)compatible{
	if (!self.isArray) return self;
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	return [NSArray arrayWithArray:newArr.compatible];
}
- (void)UploadToUpyun:(NSString*)upyunFolder each:(void (^)(NSMutableDictionary *json, NSString *imageUrl, NSInteger index))each completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion{
	[self UploadToUpyun:upyunFolder each:each progress:nil completion:completion];
}
- (void)UploadToUpyun:(NSString*)upyunFolder each:(void (^)(NSMutableDictionary *json, NSString *imageUrl, NSInteger index))each progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr UploadToUpyun:upyunFolder each:each progress:progress completion:completion];
}
- (void)UploadToQiniu:(NSString*)token each:(void (^)(NSString *imageUrl, NSInteger index))each completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion{
	[self UploadToQiniu:token each:each progress:nil completion:completion];
}
- (void)UploadToQiniu:(NSString*)token each:(void (^)(NSString *imageUrl, NSInteger index))each progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr UploadToQiniu:token each:each progress:progress completion:completion];
}
- (NSArray*)UpyunSuffix:(NSString*)suffix{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	newArr = [newArr UpyunSuffix:suffix];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	newArr = [newArr UpyunSuffix:suffix forKeys:keys];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	newArr = [newArr UpyunSuffixReplace:originSuffix to:suffix];
	return [NSArray arrayWithArray:newArr];
}
- (void)cacheImageAndCompletion:(void (^)(NSArray *images))completion{
	[self loadImageAndCompletion:completion];
}
- (void)loadImageAndCompletion:(void (^)(NSArray *images))completion{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr loadImageAndCompletion:completion];
}
- (NSArray*)addObject:(id)anObject{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr addObject:anObject];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)insertObject:(id)anObject atIndex:(NSUInteger)index{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr insertObject:anObject atIndex:index];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)removeLastObject{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr removeLastObject];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)removeObjectAtIndex:(NSUInteger)index{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr removeObjectAtIndex:index];
	return [NSArray arrayWithArray:newArr];
}
- (NSArray*)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
	NSMutableArray *newArr = [NSMutableArray arrayWithArray:self];
	[newArr replaceObjectAtIndex:index withObject:anObject];
	return [NSArray arrayWithArray:newArr];
}
@end

@implementation NSMutableArray (GlobalExtend)
//添加到第一个
- (void)unshift:(id)object{
	[self insertObject:object atIndex:0];
}
//删除第一个
- (void)shift{
	[self removeObjectAtIndex:0];
}
//删除最后一个
- (void)pop{
	[self removeLastObject];
}
//把指定索引移到特定索引
- (void)moveIndex:(NSUInteger)from toIndex:(NSUInteger)to{
	if (to != from) {
		id obj = [self objectAtIndex:from];
		[self removeObjectAtIndex:from];
		if (to >= self.count) {
			[self addObject:obj];
		} else {
			[self insertObject:obj atIndex:to];
		}
	}
}

//执行for循环, BOOL为YES即退出循环
- (void)each:(BOOL (^)(int index, id object))object{
	if (!self.count) return;
	for (int i=0; i<self.count; i++) {
		if (object(i, self[i])) break;
	}
}

//反转数组
- (NSMutableArray*)reverse{
	NSMutableArray *newArr = [[NSMutableArray alloc]init];
	for (NSInteger i=self.count-1; i>=0; i--) {
		[newArr addObject:self[i]];
	}
	return newArr;
}

//合并数组
- (NSMutableArray*)merge:(NSArray*)array{
	for (NSInteger i=0; i<array.count; i++) {
		if ([array[i] inArray:self]!=NSNotFound) [self addObject:array[i]];
	}
	return self;
}

//判断数组是否包含,包含即返回所在索引,否则返回-1
- (NSInteger)hasChild:(id)object{
	return [object inArray:self];
}

//获取最小的子元素(所有子元素类型必须一致，对比大小规则:NSNumber大或小、NSString或NSData的字节数多或少、NSDate前或后、NSArray或NSDictionary的子元素多或少)
- (id)minValue{
	id obj = nil;
	for (NSInteger i=0; i<self.count; i++) {
		if (!obj) {
			obj = self[i];
		} else {
			if ( [self[i] isKindOfClass:[NSNumber class]] ) {
				if ([obj doubleValue] > [self[i] doubleValue]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSString class]] || [self[i] isKindOfClass:[NSData class]] ) {
				if ([obj length] > [self[i] length]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSDate class]] ) {
				if ([obj isEqualToDate:[obj laterDate:self[i]]]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSArray class]] || [self[i] isKindOfClass:[NSDictionary class]] ) {
				if ([obj count] > [self[i] count]) obj = self[i];
			}
		}
	}
	return obj;
}
//获取最大的子元素
- (id)maxValue{
	id obj = nil;
	for (NSInteger i=0; i<self.count; i++) {
		if (!obj) {
			obj = self[i];
		} else {
			if ( [self[i] isKindOfClass:[NSNumber class]] ) {
				if ([obj doubleValue] < [self[i] doubleValue]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSString class]] || [self[i] isKindOfClass:[NSData class]] ) {
				if ([obj length] < [self[i] length]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSDate class]] ) {
				if ([obj isEqualToDate:[obj earlierDate:self[i]]]) obj = self[i];
			} else if ( [self[i] isKindOfClass:[NSArray class]] || [self[i] isKindOfClass:[NSDictionary class]] ) {
				if ([obj count] < [self[i] count]) obj = self[i];
			}
		}
	}
	return obj;
}

//获取最小的子元素的索引(元素只能是数字类型)
- (NSInteger)minValueIndex{
	id obj = nil;
	NSInteger index = -1;
	for (NSInteger i=0; i<self.count; i++) {
		if (!obj) {
			obj = self[i];
			index = i;
		} else {
			if ( [self[i] isKindOfClass:[NSNumber class]] ) {
				if ([obj doubleValue] > [self[i] doubleValue]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSString class]] || [self[i] isKindOfClass:[NSData class]] ) {
				if ([obj length] > [self[i] length]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSDate class]] ) {
				if ([obj isEqualToDate:[obj laterDate:self[i]]]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSArray class]] || [self[i] isKindOfClass:[NSDictionary class]] ) {
				if ([obj count] > [self[i] count]) {
					obj = self[i];
					index = i;
				}
			}
		}
	}
	return index;
}
//获取最大的子元素的索引
- (NSInteger)maxValueIndex{
	id obj = nil;
	NSInteger index = -1;
	for (NSInteger i=0; i<self.count; i++) {
		if (!obj) {
			obj = self[i];
			index = i;
		} else {
			if ( [self[i] isKindOfClass:[NSNumber class]] ) {
				if ([obj doubleValue] < [self[i] doubleValue]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSString class]] || [self[i] isKindOfClass:[NSData class]] ) {
				if ([obj length] < [self[i] length]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSDate class]] ) {
				if ([obj isEqualToDate:[obj earlierDate:self[i]]]) {
					obj = self[i];
					index = i;
				}
			} else if ( [self[i] isKindOfClass:[NSArray class]] || [self[i] isKindOfClass:[NSDictionary class]] ) {
				if ([obj count] < [self[i] count]) {
					obj = self[i];
					index = i;
				}
			}
		}
	}
	return index;
}

//数组转字符串
- (NSString*)join:(NSString*)symbol{
	return [self implode:symbol];
}
- (NSString*)implode:(NSString*)symbol{
	if (![self isArray]) return @"";
	return [self componentsJoinedByString:symbol];
}

- (NSString*)descriptionASCII{
	NSMutableString *str = [NSMutableString stringWithString:@"(\n"];
	for (int i=0; i<self.count; i++) {
		id obj = self[i];
		[str appendFormat:@"%@%@\n", (([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) ? [obj descriptionASCII] : obj), (i==self.count-1 ? @"" : @",")];
	}
	[str appendString:@")"];
	return str;
}

//转换null为空字符串
- (NSMutableArray*)compatible{
	if (!self.isArray) return self;
	NSMutableArray *newArr = [[NSMutableArray alloc]init];
	for (int i=0; i<self.count; i++) {
		if (self[i]==nil || [self[i] isKindOfClass:[NSNull class]]) {
			[newArr addObject:@""];
		} else if ([self[i] isKindOfClass:[NSDictionary class]] || [self[i] isKindOfClass:[NSArray class]]) {
			[newArr addObject:[self[i]compatible]];
		} else {
			[newArr addObject:self[i]];
		}
	}
	return newArr;
}

//又拍云上传图片组
- (void)UploadToUpyun:(NSString*)upyunFolder each:(void (^)(NSMutableDictionary *json, NSString *imageUrl, NSInteger index))each completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion{
	[self UploadToUpyun:upyunFolder each:each progress:nil completion:completion];
}
- (void)UploadToUpyun:(NSString*)upyunFolder each:(void (^)(NSMutableDictionary *json, NSString *imageUrl, NSInteger index))each progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion{
	NSMutableArray *images = [[NSMutableArray alloc]init];
	NSMutableArray *imageUrls = [[NSMutableArray alloc]init];
	NSMutableArray *imageNames = [[NSMutableArray alloc]init];
	NSMutableArray *imageArr = [[NSMutableArray alloc]init];
	for (NSInteger i=0; i<self.count; i++) {
		if (![self[i] isKindOfClass:[UIImage class]] && ![self[i] isKindOfClass:[NSData class]]) continue;
		[imageArr addObject:self[i]];
		[images addObject:[NSNull null]];
		[imageUrls addObject:[NSNull null]];
		[imageNames addObject:[NSNull null]];
	}
	for (NSInteger i=0; i<imageArr.count; i++) {
		[imageArr[i] UploadToUpyun:upyunFolder progress:progress completion:^(NSMutableDictionary *json, UIImage *image, NSString *imageUrl, NSString *imageName) {
			if (each) each(json, imageUrl, i);
			[images replaceObjectAtIndex:i withObject:image];
			[imageUrls replaceObjectAtIndex:i withObject:imageUrl];
			[imageNames replaceObjectAtIndex:i withObject:imageName];
			if (completion) {
				BOOL finish = YES;
				for (int j=0; j<images.count; j++) {
					if ([images[j] isKindOfClass:[NSNull class]]) {
						finish = NO;
						break;
					}
				}
				if (finish) completion(images, imageUrls, imageNames);
			}
		}];
	}
}

//七牛上传图片组
- (void)UploadToQiniu:(NSString*)token each:(void (^)(NSString *imageUrl, NSInteger index))each completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion{
	[self UploadToQiniu:token each:each progress:nil completion:completion];
}
- (void)UploadToQiniu:(NSString*)token each:(void (^)(NSString *imageUrl, NSInteger index))each progress:(void (^)(NSProgress *progress))progress completion:(void (^)(NSArray *images, NSArray *imageUrls, NSArray *imageNames))completion{
	NSMutableArray *images = [[NSMutableArray alloc]init];
	NSMutableArray *imageUrls = [[NSMutableArray alloc]init];
	NSMutableArray *imageNames = [[NSMutableArray alloc]init];
	NSMutableArray *imageArr = [[NSMutableArray alloc]init];
	for (NSInteger i=0; i<self.count; i++) {
		if (![self[i] isKindOfClass:[UIImage class]] && ![self[i] isKindOfClass:[NSData class]]) continue;
		[imageArr addObject:self[i]];
		[images addObject:[NSNull null]];
		[imageUrls addObject:[NSNull null]];
		[imageNames addObject:[NSNull null]];
	}
	for (NSInteger i=0; i<imageArr.count; i++) {
		[imageArr[i] UploadToQiniu:token progress:progress completion:^(UIImage *image, NSString *imageUrl, NSString *imageName) {
			if (each) each(imageUrl, i);
			[images replaceObjectAtIndex:i withObject:image];
			[imageUrls replaceObjectAtIndex:i withObject:imageUrl];
			[imageNames replaceObjectAtIndex:i withObject:imageName];
			if (completion) {
				BOOL finish = YES;
				for (int j=0; j<images.count; j++) {
					if ([images[j] isKindOfClass:[NSNull class]]) {
						finish = NO;
						break;
					}
				}
				if (finish) completion(images, imageUrls, imageNames);
			}
		}];
	}
}

//为又拍云图片路径增加后缀,即转换为缩略图路径
- (NSMutableArray*)UpyunSuffix:(NSString*)suffix{
	NSMutableArray *newArr = [[NSMutableArray alloc]init];
	for (int i=0; i<self.count; i++) {
		[newArr addObject:[self[i] UpyunSuffix:suffix]];
	}
	return newArr;
}
//为指定的key的值增加又拍云后缀
- (NSMutableArray*)UpyunSuffix:(NSString*)suffix forKeys:(NSArray*)keys{
	NSMutableArray *newArr = [[NSMutableArray alloc]init];
	for (int i=0; i<self.count; i++) {
		if ([self[i] isKindOfClass:[NSDictionary class]]) {
			[newArr addObject:[self[i] UpyunSuffix:suffix forKeys:keys]];
		} else {
			[newArr addObject:self[i]];
		}
	}
	return newArr;
}
//把又拍云图片指定后缀替换为其他指定后缀
- (NSMutableArray*)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix{
	NSMutableArray *newArr = [[NSMutableArray alloc]init];
	for (int i=0; i<self.count; i++) {
		[newArr addObject:[self[i] UpyunSuffixReplace:originSuffix to:suffix]];
	}
	return [newArr UpyunSuffix:suffix];
}

- (void)cacheImageAndCompletion:(void (^)(NSArray *images))completion{
	[self loadImageAndCompletion:completion];
}
- (void)loadImageAndCompletion:(void (^)(NSArray *images))completion{
	[Global cacheImageWithUrls:self completion:completion];
}

#pragma mark - 模拟数据库操作
- (NSMutableArray*)objectsForFilter:(NSDictionary*)filter{
	if (!self.isArray) return nil;
	NSMutableArray *objects = [[NSMutableArray alloc]init];
	if (filter.isDictionary) {
		for (NSDictionary *d in self) {
			BOOL isMatch = YES;
			for (NSString *key in filter) {
				if ( ![d[key]isset] || ![STRING(d[key]) isEqualToString:STRING(filter[key])] ) {
					isMatch = NO;
					break;
				}
			}
			if (isMatch) [objects addObject:d];
		}
	} else {
		objects = [NSMutableArray arrayWithArray:self];
	}
	return objects.isArray ? objects : nil;
}

- (NSMutableDictionary*)objectForFilter:(NSDictionary*)filter{
	if (!self.isArray) return nil;
	NSMutableDictionary *object = [[NSMutableDictionary alloc]init];
	if (filter.isDictionary) {
		for (NSDictionary *d in self) {
			BOOL isMatch = YES;
			for (NSString *key in filter) {
				if ( ![d[key]isset] || ![STRING(d[key]) isEqualToString:STRING(filter[key])] ) {
					isMatch = NO;
					break;
				}
			}
			if (isMatch) {
				object = [NSMutableDictionary dictionaryWithDictionary:d];
				break;
			}
		}
	} else {
		object = [NSMutableDictionary dictionaryWithDictionary:self[0]];
	}
	return object.isDictionary ? object : nil;
}

- (NSInteger)objectsCount:(NSDictionary*)filter{
	NSMutableArray *objects = [self objectsForFilter:filter];
	if (!objects.isArray) return 0;
	return objects.count;
}

- (void)insertObject:(NSDictionary*)object{
	[self insertObject:object keepRow:0];
}
- (void)insertObject:(NSDictionary*)object keepRow:(NSInteger)num{
	[self addObject:object];
	if (num>0 && self.count>num) [self removeObjectsInRange:NSMakeRange(0, self.count - num)];
}
- (void)insertObject:(NSDictionary*)object userDefaults:(NSString*)key{
	[self insertObject:object keepRow:0 userDefaults:key];
}
- (void)insertObject:(NSDictionary*)object keepRow:(NSInteger)num userDefaults:(NSString*)key{
	[self insertObject:object keepRow:num];
	[key setUserDefaultsWithData:self];
}

- (void)updateObject:(NSDictionary*)object filter:(NSDictionary*)filter{
	if (!self.isArray) return;
	if (filter.isDictionary) {
		for (int i=0; i<self.count; i++) {
			BOOL isMatch = YES;
			NSDictionary *d = [NSDictionary dictionaryWithDictionary:self[i]];
			for (NSString *key in filter) {
				if ( ![d[key] isset] || ![d[key] isEqual:filter[key]] ) {
					isMatch = NO;
					break;
				}
			}
			if (isMatch) {
				d = [d merge:object];
				[self replaceObjectAtIndex:i withObject:d];
			}
		}
	} else {
		for (int i=0; i<self.count; i++) {
			NSDictionary *d = [NSDictionary dictionaryWithDictionary:self[i]];
			d = [d merge:object];
			[self replaceObjectAtIndex:i withObject:d];
		}
	}
}
- (void)updateObject:(NSDictionary*)object filter:(NSDictionary*)filter userDefaults:(NSString*)key{
	[self updateObject:object filter:filter];
	[key setUserDefaultsWithData:self];
}

- (void)deleteObject:(NSDictionary*)filter{
	if (!self.isArray) return;
	if (filter.isDictionary) {
		for (int i=0; i<self.count; i++) {
			BOOL isMatch = YES;
			NSDictionary *d = [NSDictionary dictionaryWithDictionary:self[i]];
			for (NSString *key in filter) {
				if ( ![d[key] isset] || ![d[key] isEqual:filter[key]] ) {
					isMatch = NO;
					break;
				}
			}
			if (isMatch) [self removeObjectAtIndex:i];
		}
	} else {
		[self removeAllObjects];
	}
}
- (void)deleteObject:(NSDictionary*)filter userDefaults:(NSString*)key{
	[self deleteObject:filter];
	[key setUserDefaultsWithData:self];
}

- (id)field:(NSString*)key filter:(NSDictionary*)filter{
	if (!self.isArray) return nil;
	NSDictionary *object = [self objectForFilter:filter];
	if ( ![object[key] isset] ) return object[key];
	return nil;
}
- (int)fieldInt:(NSString*)key filter:(NSDictionary*)filter{
	id object = [self field:key filter:filter];
	if (object) return [object intValue];
	return 0;
}
- (NSUInteger)fieldInteger:(NSString*)key filter:(NSDictionary*)filter{
	id object = [self field:key filter:filter];
	if (object) return [object integerValue];
	return 0;
}
- (CGFloat)fieldFloat:(NSString*)key filter:(NSDictionary*)filter{
	id object = [self field:key filter:filter];
	if (object) return [object floatValue];
	return 0;
}
- (NSString*)fieldString:(NSString*)key filter:(NSDictionary*)filter{
	id object = [self field:key filter:filter];
	if (object) return [NSString stringWithFormat:@"%@", object];
	return nil;
}
/*
将一个字符串数组按照拼音首字母规则进行重组排序,返回重组后的数组,格式和规则为:
@[
	@{
		@"firstLetter": @"A",
		@"content": @[@"啊", @"阿狸"]
	},
	@{
		@"firstLetter": @"B",
		@"content": @[@"部落", @"帮派"]
	}
]
只会出现有对应元素的字母字典, 例如: 如果没有对应@"C"的字符串出现, 则数组内也不会出现@"C"的字典.
数组内字典的顺序按照26个字母的顺序排序
@"#"对应的字典永远出现在数组最后一位
*/
- (NSMutableArray*)arrayWithPinYinFirstLetterFormat{
	return [self arrayWithPinYinFirstLetterFormatWithKey:nil];
}
- (NSMutableArray*)arrayWithPinYinFirstLetterFormatWithKey:(NSString*)key{
	if (![self count]) return [NSMutableArray array];
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSMutableArray array] forKey:@"#"];
	for (int i='A'; i<='Z'; i++) {
		[dict setObject:[NSMutableArray array] forKey:[NSString stringWithUTF8String:(const char *)&i]];
	}
	for (int i=0; i<self.count; i++) {
		NSString *word = key.length ? self[i][key] : self[i];
		NSString *firstLetter = [word getFirstLetter];
		NSMutableArray *array = dict[firstLetter];
		[array addObject:self[i]];
	}
	NSMutableArray *resultArray = [NSMutableArray array];
	for (int i='A'; i<='Z'; i++) {
		NSString *firstLetter = [NSString stringWithUTF8String:(const char *)&i];
		NSMutableArray *array = dict[firstLetter];
		if ([array count]) {
			[array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				if (key.length) {
					NSString *word1 = [obj1 objectForKey:key];
					NSString *word2 = [obj2 objectForKey:key];
					return [word1 localizedCompare:word2];
				} else {
					NSString *word1 = obj1;
					NSString *word2 = obj2;
					return [word1 localizedCompare:word2];
				}
			}];
			NSDictionary *resultDict = @{@"firstLetter":firstLetter, @"content":array};
			[resultArray addObject:resultDict];
		}
	}
	if ([dict[@"#"] count]) {
		NSMutableArray *array = dict[@"#"];
		[array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			if (key.length) {
				NSString *word1 = [obj1 objectForKey:key];
				NSString *word2 = [obj2 objectForKey:key];
				return [word1 localizedCompare:word2];
			} else {
				NSString *word1 = obj1;
				NSString *word2 = obj2;
				return [word1 localizedCompare:word2];
			}
		}];
		NSDictionary *resultDict = @{@"firstLetter":@"#", @"content":array};
		[resultArray addObject:resultDict];
	}
	return resultArray;
}
@end


#if !TARGET_IPHONE_SIMULATOR
#pragma mark - NSMutableArray+Swizzling
@implementation NSArray (Swizzling)
+ (void)load{
	static dispatch_once_t onceDispatch;
	dispatch_once(&onceDispatch, ^{
		[self SwizzlingMethod:@"objectAtIndex:" systemClass:@"__NSArrayI" toSafeMethod:@"st_objectAtIndex:" targetClass:@"NSArray"];
		[self SwizzlingMethod:@"initWithObjects:count:" systemClass:@"__NSPlaceholderArray" toSafeMethod:@"initWithObjects_st:count:" targetClass:@"NSArray"];
		[self SwizzlingMethod:@"arrayByAddingObject:" systemClass:@"__NSArrayI" toSafeMethod:@"st_arrayByAddingObject:" targetClass:@"NSArray"];
	});
}
- (id)st_objectAtIndex:(NSUInteger)index{
	if (index >= [self count]) {
		NLog(@"METADATA INDEX ERROR\n");
		return nil;
	}
	return [self st_objectAtIndex:index];
}

- (NSArray *)st_arrayByAddingObject:(id)anObject {
	if (!anObject) {
		NLog(@"METADATA OBJECT ERROR\n");
		return self;
	}
	return [self st_arrayByAddingObject:anObject];
}
- (instancetype)initWithObjects_st:(id *)objects count:(NSUInteger)count {
	NSUInteger newCount = 0;
	for (NSUInteger i = 0; i < count; i++) {
		if (!objects[i]) {
			NLog(@"METADATA OBJECTS ERROR\n");
			break;
		}
		newCount++;
	}
	self = [self initWithObjects_st:objects count:newCount];
	return self;
}
@end
@implementation NSMutableArray (Swizzling)
+ (void)load{
	static dispatch_once_t onceDispatch;
	dispatch_once(&onceDispatch, ^{
		[self SwizzlingMethod:@"addObject:" systemClass:@"__NSArrayM" toSafeMethod:@"st_addObject:" targetClass:@"NSMutableArray"];
		[self SwizzlingMethod:@"insertObject:atIndex:" systemClass:@"__NSArrayM" toSafeMethod:@"st_insertObject:atIndex:" targetClass:@"NSMutableArray"];
		[self SwizzlingMethod:@"removeObjectAtIndex:" systemClass:@"__NSArrayM" toSafeMethod:@"st_removeObjectAtIndex:" targetClass:@"NSMutableArray"];
		[self SwizzlingMethod:@"replaceObjectAtIndex:withObject:" systemClass:@"__NSArrayM" toSafeMethod:@"st_replaceObjectAtIndex:withObject:" targetClass:@"NSMutableArray"];
		[self SwizzlingMethod:@"removeObjectsAtIndexes:" systemClass:@"NSMutableArray" toSafeMethod:@"st_removeObjectsAtIndexes:" targetClass:@"NSMutableArray"];
		[self SwizzlingMethod:@"removeObjectsInRange:" systemClass:@"NSMutableArray" toSafeMethod:@"st_removeObjectsInRange:" targetClass:@"NSMutableArray"];
		[self SwizzlingMethod:@"objectAtIndex:" systemClass:@"__NSArrayM" toSafeMethod:@"st_objectAtIndex:" targetClass:@"NSMutableArray"];
	});
}
- (void)st_addObject:(id)anObject{
	if (!anObject) {
		NLog(@"METADATA OBJECT ERROR\n");
		return;
	}
	[self st_addObject:anObject];
}
- (void)st_insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (index > [self count]) {
		NLog(@"METADATA INDEX ERROR\n");
		return;
	}
	if (!anObject) {
		NLog(@"METADATA OBJECT ERROR\n");
		return;
	}
	[self st_insertObject:anObject atIndex:index];
}
- (void)st_removeObjectAtIndex:(NSUInteger)index {
	if (index >= [self count]) {
		NLog(@"METADATA INDEX ERROR\n");
		return;
	}
	return [self st_removeObjectAtIndex:index];
}
- (void)st_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	if (index >= [self count]) {
		NLog(@"METADATA INDEX ERROR\n");
		return;
	}
	if (!anObject) {
		NLog(@"METADATA OBJECT ERROR\n");
		return;
	}
	[self st_replaceObjectAtIndex:index withObject:anObject];
}
- (void)st_removeObjectsAtIndexes:(NSIndexSet *)indexes{
	NSMutableIndexSet * mutableSet = [NSMutableIndexSet indexSet];
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
		if (idx < [self count]) {
			[mutableSet addIndex:idx];
		}
	}];
	[self st_removeObjectsAtIndexes:mutableSet];
}
- (void)st_removeObjectsInRange:(NSRange)range{
	if (range.location + range.length - 1 < [self count]) {
		[self st_removeObjectsInRange:range];
		return;
	}
	if (range.location >= [self count]) {
		NLog(@"METADATA RANGE ERROR\n");
		return;
	}
	NSInteger tempInteger = range.location + range.length - 1;
	while (tempInteger >= [self count]) {
		tempInteger -= 1;
	}
	NSRange tempRange = NSMakeRange(range.location, tempInteger + 1 -range.location);
	[self st_removeObjectsInRange:tempRange];
}
- (id)st_objectAtIndex:(NSUInteger)index{
	if (index >= [self count]) {
		NLog(@"METADATA INDEX ERROR\n");
		return nil;
	}
	return [self st_objectAtIndex:index];
}
@end
#endif
