// KKTabBar.h
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

#import <UIKit/UIKit.h>

@class KKTabBar, KKTabBarItem;

@protocol KKTabBarDelegate <NSObject>

/**
 * Asks the delegate if the specified tab bar item should be selected.
 */
- (BOOL)tabBar:(KKTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index;

/**
 * Tells the delegate that the specified tab bar item is now selected.
 */
- (void)tabBar:(KKTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index;

@end

@interface KKTabBar : UIView

/**
 * The tab bar’s delegate object.
 */
@property (nonatomic, weak) id <KKTabBarDelegate> delegate;

/**
 * The items displayed on the tab bar.
 */
@property (nonatomic, copy) NSArray *items;

/**
 * The currently selected item on the tab bar.
 */
@property (nonatomic, weak) KKTabBarItem *selectedItem;

/**
 * backgroundView stays behind tabBar's items. If you want to add additional views, 
 * add them as subviews of backgroundView.
 */
@property (nonatomic, readonly) UIView *backgroundView;

/**
 * hidden the top line.
 */
@property (nonatomic, assign) BOOL hiddenTopLine;

/*
 * contentEdgeInsets can be used to center the items in the middle of the tabBar.
 */
@property UIEdgeInsets contentEdgeInsets;

/**
 * The indexs of the tabBarItem for prominent. ex: @[@0, @1, @2]
 */
@property (nonatomic, copy) NSArray *bigItemIndexs;

/**
 * Sets the height of tab bar.
 */
- (void)setHeight:(CGFloat)height;

/**
 * Returns the minimum height of tab bar's items.
 */
- (CGFloat)minimumContentHeight;

@end
