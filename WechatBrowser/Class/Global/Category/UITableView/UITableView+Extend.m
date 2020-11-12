//
//  UITableView+Extend.m
//
//  Created by ajsong on 2018/11/28.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "UITableView+Extend.h"

#pragma mark - UITableView+Extend
@implementation UITableView (GlobalExtend)

- (UITableViewCell*)cellForKey:(NSString*)key{
	return self.element[key];
}
- (void)setCell:(UITableViewCell*)cacheCell forKey:(NSString*)key{
	self.element[key] = cacheCell;
}

- (void)setEmptyView:(UIView *)emptyView{
	objc_setAssociatedObject(self, @selector(emptyView), emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	if (objc_getAssociatedObject(self, @selector(emptyView))) {
		//防止手动调用load出现多次调用的情况：
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			[UITableView swizzleOriginMethod:@selector(reloadData)  Method:@selector(newReloadData)];
		});
	}
}

- (UIView *)emptyView{
	return objc_getAssociatedObject(self, @selector(emptyView));
}

- (void)newReloadData{
	[self checkIsEmpty];
	[self newReloadData];
}

+ (void)swizzleOriginMethod:(SEL)oriSel Method:(SEL)newSel{
	Method oldMethod = class_getInstanceMethod(self, oriSel); //旧方法
	Method newMethod = class_getInstanceMethod(self, newSel); //新方法
	BOOL methodIsAdd = class_addMethod(self, oriSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
	if (methodIsAdd) {
		class_replaceMethod(self, newSel, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
	} else {
		method_exchangeImplementations(oldMethod, newMethod);
	}
}

- (void)checkIsEmpty{
	BOOL isEmpty = YES;
	if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
		NSInteger sections = [self.dataSource numberOfSectionsInTableView:self];
		if (sections > 0) {
			isEmpty = NO;
		}
	} else {
		NSInteger rows = [self.dataSource tableView:self numberOfRowsInSection:0];
		if (rows > 0) {
			isEmpty = NO;
		}
	}
	if (isEmpty) {
		[self.emptyView removeFromSuperview];
		[self addSubview:self.emptyView];
	} else {
		[self.emptyView removeFromSuperview];
	}
}

@end


@implementation UICollectionView (GlobalExtend)
- (UICollectionViewCell*)cellForKey:(NSString*)key{
	return self.element[key];
}
- (void)setCell:(UICollectionViewCell*)cacheCell forKey:(NSString*)key{
	self.element[key] = cacheCell;
}
@end

@interface UICollectionViewIndex (){
	BOOL _isLayedOut;
}
@end
@implementation UICollectionViewIndex
- (instancetype)initWithFrame:(CGRect)frame withCollectionView:(UICollectionView*)collectionView{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		_collectionView = collectionView;
		_textWidth = frame.size.width;
		_textHeight = 16*SCREEN_SCALE;
		_textColor = COLORTEXT;
		_selectedTextColor = COLORTEXT;
		_bgColor = [UIColor clearColor];
		_selectedBgColor = [UIColor clearColor];
		_fontSize = 12*SCREEN_SCALE;
	}
	return self;
}
- (void)setDelegate:(id<UICollectionViewIndexDelegate>)delegate{
	_delegate = delegate;
	[self layoutSubviews];
}
- (void)layoutSubviews{
	[super layoutSubviews];
	if (!_isLayedOut) {
		//[self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
		[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[_titleIndexes enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
			/*
			CATextLayer *ctl = [self textLayerWithSize:_fontSize
												string:obj
											  andFrame:CGRectMake(0, idx*_textHeight, self.frame.size.width, _textHeight)];
			
			[self.layer addSublayer:ctl];
			*/
			UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((self.width-_textWidth)/2, idx*_textHeight, _textWidth, _textHeight)];
			button.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:_fontSize];
			button.adjustsImageWhenHighlighted = NO;
			button.userInteractionEnabled = NO;
			[button setTitle:obj forState:UIControlStateNormal];
			[button setTitleColor:_textColor forState:UIControlStateNormal];
			[button setTitleColor:_selectedTextColor forState:UIControlStateSelected];
			if (idx==0) {
				button.selected = YES;
				button.backgroundColor = _selectedBgColor;
			} else {
				button.backgroundColor = _bgColor;
			}
			[self addSubview:button];
		}];
		if (_delegate && [_delegate respondsToSelector:@selector(collectionViewIndex:didSelectAtIndex:withButton:)]) {
			[_delegate collectionViewIndex:self didSelectAtIndex:0 withButton:(UIButton*)self.subviews[0]];
		}
		_isLayedOut = YES;
	}
}
//绘制文字
- (CATextLayer*)textLayerWithSize:(CGFloat)size string:(NSString*)string andFrame:(CGRect)frame{
	CATextLayer *tl = [CATextLayer layer];
	[tl setFont:@"ArialMT"];
	[tl setFontSize:size];
	[tl setFrame:frame];
	[tl setAlignmentMode:kCAAlignmentCenter];
	[tl setContentsScale:[[UIScreen mainScreen] scale]];
	[tl setForegroundColor:_textColor.CGColor];
	[tl setString:string];
	return tl;
}
//根据触摸事件的触摸点来算出点击的是第几个section
- (void)sendEventToDelegate:(UIEvent*)event{
	UITouch *touch = [[event allTouches] anyObject]; //获取触摸对象
	CGPoint point = [touch locationInView:self]; //获取当前触摸点位置
	NSInteger index = ((NSInteger)floorf(point.y) / _textHeight); //触摸位置对应的行数
	if (index<0 || index>_titleIndexes.count-1) return;
	for (UIButton *subview in self.subviews) {
		subview.selected = NO;
		subview.backgroundColor = _bgColor;
	}
	UIButton *button = (UIButton*)self.subviews[index];
	button.selected = YES;
	button.backgroundColor = _selectedBgColor;
	if (_delegate && [_delegate respondsToSelector:@selector(collectionViewIndex:didSelectAtIndex:withTitle:)]) {
		[_delegate collectionViewIndex:self didSelectAtIndex:index withTitle:_titleIndexes[index]];
	}
	if (_delegate && [_delegate respondsToSelector:@selector(collectionViewIndex:didSelectAtIndex:withButton:)]) {
		[_delegate collectionViewIndex:self didSelectAtIndex:index withButton:button];
	}
	[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}
//手指触碰屏幕，触摸开始
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesBegan:touches withEvent:event];
	[self sendEventToDelegate:event];
	if (_delegate && [_delegate respondsToSelector:@selector(collectionViewIndexTouchesBegan:)]) {
		[_delegate collectionViewIndexTouchesBegan:self];
	}
}
//手指在屏幕上移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesMoved:touches withEvent:event];
	[self sendEventToDelegate:event];
}
//手指离开屏幕，触摸结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if (_delegate && [_delegate respondsToSelector:@selector(collectionViewIndexTouchesEnd:)]) {
		[_delegate collectionViewIndexTouchesEnd:self];
	}
}
@end
