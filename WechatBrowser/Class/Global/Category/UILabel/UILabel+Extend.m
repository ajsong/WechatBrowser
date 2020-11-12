//
//  UILabel+Extend.m
//
//  Created by ajsong on 2019/2/11.
//  Copyright © 2019 @MARIO. All rights reserved.
//

#import "UILabel+Extend.h"

#pragma mark - UILabel+Extend
@implementation UILabel (GlobalExtend)
- (UIEdgeInsets)autoWidth{
	return UIEdgeInsetsFromString(self.element[@"autoWidth"]);
}
- (void)setAutoWidth:(UIEdgeInsets)padding{
	self.element[@"autoWidth"] = NSStringFromUIEdgeInsets(padding);
	//if (self.numberOfLines==1) self.numberOfLines = 0;
	CGFloat height = self.height;
	[self sizeToFit];
	self.height = height;
	CGFloat width = self.width;
	if ([self.element[@"padding"]isset]) {
		UIEdgeInsets pad = UIEdgeInsetsFromString(self.element[@"padding"]);
		width += pad.left + pad.right;
	}
	if (!UIEdgeInsetsEqualToEdgeInsets(padding, UIEdgeInsetsZero)) {
		width += padding.left + padding.right;
	}
	self.width = width;
}

- (UIEdgeInsets)autoHeight{
	return UIEdgeInsetsFromString(self.element[@"autoHeight"]);
}
- (void)setAutoHeight:(UIEdgeInsets)padding{
	self.element[@"autoHeight"] = NSStringFromUIEdgeInsets(padding);
	if (self.numberOfLines==1) self.numberOfLines = 0;
	CGFloat width = self.width;
	[self sizeToFit];
	self.width = width;
	CGFloat height = self.height;
	if ([self.element[@"padding"]isset]) {
		UIEdgeInsets pad = UIEdgeInsetsFromString(self.element[@"padding"]);
		height += pad.top + pad.bottom;
	}
	if (!UIEdgeInsetsEqualToEdgeInsets(padding, UIEdgeInsetsZero)) {
		height += padding.top + padding.bottom;
	}
	self.height = height;
}

- (UIEdgeInsets)autoWidthAndHeight{
	return UIEdgeInsetsFromString(self.element[@"autoWidthAndHeight"]);
}
- (void)setAutoWidthAndHeight:(UIEdgeInsets)padding{
	self.element[@"autoWidthAndHeight"] = NSStringFromUIEdgeInsets(padding);
	if (self.numberOfLines==1) self.numberOfLines = 0;
	[self sizeToFit];
	CGRect frame = self.frame;
	if ([self.element[@"padding"] isset]) {
		UIEdgeInsets pad = UIEdgeInsetsFromString(self.element[@"padding"]);
		frame.size.width += pad.left + pad.right;
		frame.size.height += pad.top + pad.bottom;
	}
	if (!UIEdgeInsetsEqualToEdgeInsets(padding, UIEdgeInsetsZero)) {
		frame.size.width += padding.left + padding.right;
		frame.size.height += padding.top + padding.bottom;
	}
	self.frame = frame;
}

- (NSDictionary *)attributed{
	return self.element[@"attributed"];
}
- (void)setAttributed:(NSDictionary *)attributed{
	self.element[@"attributed"] = attributed;
	self.attributedText = [self.text attributedStyle:attributed];
}

- (UIFont*)priceFont{
	return self.element[@"priceFont"];
}
- (void)setPriceFont:(UIFont*)priceFont{
	[self setPriceFont:priceFont color:nil];
}
- (void)setPriceFont:(UIFont*)priceFont color:(UIColor*)color{
	self.element[@"priceFont"] = priceFont;
	NSString *text = self.text;
	if (!text.length || ![text preg_test:@"\\d"]) return;
	if (!color) color = self.textColor;
	NSArray *matches = [text preg_match:@"^(.*?)(￥)?(([0-9]+)(\\.[0-9]+)?)([^\\d]*)$"];
	//NSLog(@"%@", matches.descriptionASCII);
	text = FORMAT(@"%@<d>%@<p>%@</p>%@</d>%@", matches[0][@"group"][0], matches[0][@"group"][1], matches[0][@"group"][3], matches[0][@"group"][4], matches[0][@"group"][5]);
	NSDictionary *style = @{@"body":@[self.font, self.textColor], @"d":color, @"p":priceFont};
	self.attributedText = [text attributedStyle:style];
}
@end


#pragma mark - UIILabel
@interface UIILabel (){
	UIColor *_textColor;
	NSArray *_textAlignArray;
	BOOL _hasTextAlignTop;
	BOOL _hasTextAlignLeft;
	BOOL _hasTextAlignBottom;
	BOOL _hasTextAlignRight;
}
@end
@implementation UIILabel
- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		_placeholderColor = COLOR_PLACEHOLDER;
	}
	return self;
}

- (void)setText:(NSString *)text{
	if (_placeholder.length) {
		if (!text.length) {
			text = _placeholder;
			if (_placeholderColor) {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						[self setTextColor:_placeholderColor isPlaceholderColor:YES];
					});
				});
			}
		} else {
			[super setTextColor:_textColor];
		}
	}
	[super setText:text];
	if ([text indexOf:@"\n"]!=NSNotFound) self.numberOfLines = 0;
}

- (void)setTextColor:(UIColor *)textColor{
	[self setTextColor:textColor isPlaceholderColor:NO];
}

- (void)setTextColor:(UIColor *)textColor isPlaceholderColor:(BOOL)isPlaceholderColor{
	[super setTextColor:textColor];
	if (!isPlaceholderColor) _textColor = textColor;
}

- (void)setPlaceholder:(NSString *)placeholder{
	_placeholder = placeholder;
	if (placeholder.length) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				if (!self.text.length) {
					self.text = placeholder;
					if (_placeholderColor) {
						[self setTextColor:_placeholderColor isPlaceholderColor:YES];
					}
				}
			});
		});
	}
}

- (void)setLineType:(NSLineType)lineType{
	_lineType = lineType;
	[self setNeedsDisplay];
}

- (void)setLineColor:(UIColor *)lineColor{
	_lineColor = lineColor;
	[self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth{
	_lineWidth = lineWidth;
	[self setNeedsDisplay];
}

- (void)setPadding:(UIEdgeInsets)padding{
	self.element[@"isPadding"] = @YES;
	self.element[@"padding"] = NSStringFromUIEdgeInsets(padding);
	_padding = padding;
	[self setNeedsDisplay];
}

- (void)setLineHeight:(CGFloat)lineHeight{
	_lineHeight = lineHeight;
	self.numberOfLines = 0;
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
	style.lineSpacing = lineHeight - (self.font.lineHeight - self.font.pointSize);
	NSDictionary *attributes = @{NSParagraphStyleAttributeName:style};
	self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
	[self setNeedsDisplay];
}

- (void)setTextAlignmentVertical:(NSTextAlignmentVertical)textAlignmentVertical{
	self.element[@"isVertical"] = @YES;
	_textAlignmentVertical = textAlignmentVertical;
	[self setNeedsDisplay];
}

- (void)setSeparateLength:(NSInteger)separateLength{
	[self setSeparateLength:separateLength separator:@" "];
}
- (void)setSeparateLength:(NSInteger)separateLength separator:(NSString*)separator{
	_separateLength = separateLength;
	if (!self.text.length) return;
	NSString *string = [self.text stringByReplacingOccurrencesOfString:separator withString:@""];
	NSInteger size = (string.length / separateLength);
	NSMutableArray *arr = [[NSMutableArray alloc]init];
	for (int n=0; n<size; n++) {
		[arr addObject:[string substringWithRange:NSMakeRange(n*separateLength, separateLength)]];
	}
	[arr addObject:[string substringWithRange:NSMakeRange(size*separateLength, (string.length % separateLength))]];
	string = [arr componentsJoinedByString:separator];
	string = [string trim:separator];
	self.text = string;
}

- (void)setGradientColors:(NSArray *)gradientColors{
	_gradientColors = gradientColors;
	[self setNeedsDisplay];
}

- (void)textAlign:(void(^)(UIIMaker *make))alignType{
	self.element[@"isTextAlign"] = @YES;
	UIIMaker *make = [[UIIMaker alloc]init];
	alignType(make);
	_textAlignArray = make.typeArray;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines{
	CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
	if (_textAlignArray.isArray){
		for (int i=0; i<_textAlignArray.count; i++) {
			NSTextAlignType type = [_textAlignArray[i] integerValue];
			switch (type) {
				case NSTextAlignTypeTop:  //顶部对齐
					_hasTextAlignTop = YES;
					textRect.origin.y = bounds.origin.y;
					break;
				case NSTextAlignTypeLeft: //左部对齐
					_hasTextAlignLeft = YES;
					textRect.origin.x = bounds.origin.x;
					break;
				case NSTextAlignTypeBottom: //底部对齐
					_hasTextAlignBottom = YES;
					textRect.origin.y = bounds.size.height - textRect.size.height;
					break;
				case NSTextAlignTypeRight: //右部对齐
					_hasTextAlignRight = YES;
					textRect.origin.x = bounds.size.width - textRect.size.width;
					break;
				case NSTextAlignTypeCenter:
					if (_hasTextAlignTop) {  //上中
						textRect.origin.x = (bounds.size.width - textRect.size.width)*0.5;
					} else if (_hasTextAlignLeft) { //左中
						textRect.origin.y = (bounds.size.height - textRect.size.height)*0.5;
					} else if (_hasTextAlignBottom) { //下中
						textRect.origin.x = (bounds.size.width - textRect.size.width)*0.5;
					} else if (_hasTextAlignRight) { //右中
						textRect.origin.y = (bounds.size.height - textRect.size.height)*0.5;
					} else { //上下左右居中
						textRect.origin.x = (bounds.size.width - textRect.size.width)*0.5;
						textRect.origin.y = (bounds.size.height - textRect.size.height)*0.5;
					}
					break;
				default:
					break;
			}
		}
	} else {
		switch (_textAlignmentVertical) {
			case NSTextAlignmentTop:
				textRect.origin.y = bounds.origin.y;
				break;
			case NSTextAlignmentBottom:
				textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
				break;
			case NSTextAlignmentMiddle:
				// Fall through.
			default:
				textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
		}
	}
	return textRect;
}

- (void)drawRect:(CGRect)rect{
	NSArray *gradientColors = _gradientColors;
	if (gradientColors.isArray) {
		NSMutableArray *cs = [[NSMutableArray alloc]init];
		for (NSInteger i=gradientColors.count-1; i>=0; i--) {
			[cs addObject:gradientColors[i]];
		}
		CGContextRef context = UIGraphicsGetCurrentContext();
		NSMutableArray *colors = [[NSMutableArray alloc]init];
		[cs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isKindOfClass:[UIColor class]]) {
				[colors addObject:(__bridge id)[obj CGColor]];
			} else if (CFGetTypeID((__bridge void *)obj) == CGColorGetTypeID()) {
				[colors addObject:obj];
			} else {
				@throw [NSException exceptionWithName:@"CRGradientLabelError"
											   reason:@"Object in gradientColors array is not a UIColor or CGColorRef"
											 userInfo:NULL];
			}
		}];
		CGContextSaveGState(context);
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextTranslateCTM(context, 0, -rect.size.height);
		CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, NULL);
		CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
		CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint,
									kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);
		CGGradientRelease(gradient);
		CGContextRestoreGState(context);
	}
	[super drawRect:rect];
}

- (void)drawTextInRect:(CGRect)rect{
	//CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
	if ([self.element[@"isVertical"]boolValue] || [self.element[@"isTextAlign"]boolValue]) {
		rect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
	}
	if ([self.element[@"isPadding"]boolValue]) rect = UIEdgeInsetsInsetRect(rect, _padding);
	[super drawTextInRect:rect];
	NSLineType lineType = _lineType;
	if (lineType != NSLineTypeNone) {
		UIColor *lineColor = _lineColor;
		CGFloat lineWidth = _lineWidth;
		CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
		CGFloat strikeWidth = textSize.width;
		CGRect lineRect;
		CGFloat originX = 0.0;
		CGFloat originY = 0.0;
		if (self.textAlignment == NSTextAlignmentRight) {
			originX = rect.size.width - strikeWidth;
		} else if (self.textAlignment == NSTextAlignmentCenter) {
			originX = (rect.size.width - strikeWidth)/2 ;
		} else {
			originX = 0;
		}
		if (lineType == NSLineTypeTop) originY = 2;
		if (lineType == NSLineTypeMiddle) originY = rect.size.height/2;
		if (lineType == NSLineTypeBottom) originY = rect.size.height - 2;
		lineRect = CGRectMake(originX , originY, strikeWidth, lineWidth>0 ? lineWidth : 0.5);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGFloat R, G, B, A;
		UIColor *lc = lineColor ? lineColor : self.textColor;
		CGColorRef color = lc.CGColor;
		int numComponents = (int)CGColorGetNumberOfComponents(color);
		if (numComponents == 4) {
			const CGFloat *components = CGColorGetComponents(color);
			R = components[0];
			G = components[1];
			B = components[2];
			//A = components[3];
			CGContextSetRGBFillColor(context, R, G, B, 1.0);
		}
		CGContextFillRect(context, lineRect);
	}
}
@end

@implementation UIIMaker
- (instancetype)init {
	self = [super init];
	if (self) {
		self.typeArray = [[NSMutableArray alloc]init];
	}
	return self;
}
- (UIIMaker *(^)(NSTextAlignType type))alignType{
	__weak typeof(self) weakSelf = self;
	return ^(NSTextAlignType type) {
		[weakSelf.typeArray addObject:@(type)];
		return weakSelf;
	};
}
@end
