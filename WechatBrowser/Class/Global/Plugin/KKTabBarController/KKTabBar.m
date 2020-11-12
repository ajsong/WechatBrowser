// KKTabBar.m
// KKTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "KKTabBar.h"
#import "KKTabBarItem.h"

@interface KKTabBar ()
@property (nonatomic) CGFloat itemWidth;
@end

@implementation KKTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)commonInitialization {
	CGSize frameSize = self.frame.size;
	CGFloat minimumContentHeight = [self minimumContentHeight];
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, frameSize.height - minimumContentHeight, frameSize.width, frameSize.height)];
	_backgroundView.backgroundColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:0.98];
    [self addSubview:_backgroundView];
	
	_bigItemIndexs = [[NSArray alloc] init];
}

- (void)layoutSubviews {
    CGSize frameSize = self.frame.size;
    CGFloat minimumContentHeight = [self minimumContentHeight];
    
	[_backgroundView setFrame:CGRectMake(0, frameSize.height - minimumContentHeight, frameSize.width, frameSize.height)];
	if (!_hiddenTopLine) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				[_backgroundView addGeWithType:GeLineTypeTop];
			});
		});
	}
	
    [self setItemWidth:roundf((frameSize.width - [self contentEdgeInsets].left - [self contentEdgeInsets].right) / [[self items] count])];
    
    NSInteger index = 0;
    
    // Layout items
    
    for (KKTabBarItem *item in [self items]) {
        CGFloat itemHeight = [item itemHeight];
        
		if (!itemHeight) itemHeight = frameSize.height - (isX?34:0);
        
        [item setFrame:CGRectMake(self.contentEdgeInsets.left + (index * self.itemWidth),
                                  self.contentEdgeInsets.top, //roundf(frameSize.height - itemHeight) - self.contentEdgeInsets.top,
                                  self.itemWidth, itemHeight - self.contentEdgeInsets.bottom)];
        [item setNeedsDisplay];
        
        index++;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (!_bigItemIndexs.count) return [super hitTest:point withEvent:event];
	for (int i=0; i<_bigItemIndexs.count; i++) {
		if ([_bigItemIndexs[i]integerValue] >= self.items.count) {
			return [super hitTest:point withEvent:event];
			break;
		}
	}
	//这一个判断是关键，不判断的话push到其他页面，点击发布按钮的位置也是会有反应的，这样就不好了
	//self.isHidden == NO 说明当前页面是有tabBar的，那么肯定是在导航控制器的根控制器页面
	//在导航控制器根控制器页面，那么我们就需要判断手指点击的位置是否在发布按钮身上
	//是的话让发布按钮自己处理点击事件，不是的话让系统去处理点击事件就可以了
	if (self.isHidden == NO) {
		KKTabBarItem *bigItem = nil;
		for (int i=0; i<_bigItemIndexs.count; i++) {
			KKTabBarItem *item = self.items[[_bigItemIndexs[i]integerValue]];
			//将当前tabBar的触摸点转换坐标系，转换到大按钮的身上，生成一个新的点
			CGPoint newPoint = [self convertPoint:point toView:bigItem];
			//判断如果这个新的点是在大按钮身上，那么处理点击事件最合适的view就是发布按钮
			if ([item pointInside:newPoint withEvent:event]) {
				bigItem = item;
				break;
			}
		}
		if (bigItem) {
			return bigItem;
		} else { //如果点不在大按钮身上，直接让系统处理就可以了
			return [super hitTest:point withEvent:event];
		}
	} else { //tabBar隐藏了，那么说明已经push到其他的页面了，这个时候还是让系统去判断最合适的view处理就好了
		return [super hitTest:point withEvent:event];
	}
}

#pragma mark - Configuration

- (void)setItemWidth:(CGFloat)itemWidth {
    if (itemWidth > 0) {
        _itemWidth = itemWidth;
    }
}

- (void)setItems:(NSArray *)items {
    for (KKTabBarItem *item in items) {
        [item removeFromSuperview];
    }
    
    _items = [items copy];
    for (KKTabBarItem *item in items) {
        [item addTarget:self action:@selector(tabBarItemWasSelected:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:item];
    }
}

- (void)setHeight:(CGFloat)height {
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame),
                              CGRectGetWidth(self.frame), height)];
}

- (CGFloat)minimumContentHeight {
    CGFloat minimumTabBarContentHeight = CGRectGetHeight([self frame]);
    
    for (KKTabBarItem *item in [self items]) {
        CGFloat itemHeight = [item itemHeight];
        if (itemHeight && (itemHeight < minimumTabBarContentHeight)) {
            minimumTabBarContentHeight = itemHeight;
        }
    }
    
    return minimumTabBarContentHeight;
}

#pragma mark - Item selection

- (void)tabBarItemWasSelected:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(tabBar:shouldSelectItemAtIndex:)]) {
        NSInteger index = [self.items indexOfObject:sender];
        if (![[self delegate] tabBar:self shouldSelectItemAtIndex:index]) {
            return;
        }
    }
    
    [self setSelectedItem:sender];
    
    if ([[self delegate] respondsToSelector:@selector(tabBar:didSelectItemAtIndex:)]) {
        NSInteger index = [self.items indexOfObject:self.selectedItem];
        [[self delegate] tabBar:self didSelectItemAtIndex:index];
    }
}

- (void)setSelectedItem:(KKTabBarItem *)selectedItem {
    if (selectedItem == _selectedItem || !selectedItem.hasController) {
        return;
    }
    [_selectedItem setSelected:NO];
    
    _selectedItem = selectedItem;
    [_selectedItem setSelected:YES];
}

@end
