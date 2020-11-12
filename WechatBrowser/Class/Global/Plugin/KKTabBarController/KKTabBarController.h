// KKTabBarController.h
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
#import "KKTabBar.h"
#import "KKTabBarItem.h"

@protocol KKTabBarControllerDelegate;

@interface KKTabBarController : UIViewController <KKTabBarDelegate>

/**
 * The tab bar controller’s delegate object.
 */
@property (nonatomic, weak) id<KKTabBarControllerDelegate> delegate;

/**
 * An array of the root view controllers displayed by the tab bar interface.
 */
@property (nonatomic, copy) IBOutletCollection(UIViewController) NSArray *viewControllers;

/**
 * The tab bar view associated with this controller. (read-only)
 */
@property (nonatomic, readonly) KKTabBar *tabBar;

/**
 * The height of the tab bar view.
 */
@property (nonatomic) CGFloat tabBarHeight;

/**
 * The view controller associated with the currently selected tab item.
 */
@property (nonatomic, weak) UIViewController *selectedViewController;

/**
 * The index of the view controller associated with the currently selected tab item.
 */
@property (nonatomic) NSUInteger selectedIndex;

/**
 * A Boolean value that determines whether the tab bar is hidden.
 */
@property (nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;

/**
 * Changes the visibility of the tab bar.
 */
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

- (CGFloat)tabBarHeight:(BOOL)real;

@end

@protocol KKTabBarControllerDelegate <NSObject>
@optional
/**
 * Asks the delegate whether the specified view controller should be made active.
 */
- (BOOL)tabBarController:(KKTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)index;

/**
 * Tells the delegate that the user selected an item in the tab bar.
 */
- (void)tabBarController:(KKTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)index;

@end

@interface UIViewController (KKTabBarControllerItem)

/**
 * The tab bar item that represents the view controller when added to a tab bar controller.
 */
@property(nonatomic, setter = setTabBarItemKK:) KKTabBarItem *tabBarItemKK;

/**
 * The nearest ancestor in the view controller hierarchy that is a tab bar controller. (read-only)
 */
@property(nonatomic, readonly) KKTabBarController *tabBarControllerKK;

/**
 * The tab bar height. (read-only)
 */
@property(nonatomic, readonly) CGFloat tabBarHeight;
- (CGFloat)tabBarHeight:(BOOL)real;

/**
 * Then when this view controller is pushed into a controller hierarchy with a bottom bar (like a tab bar), the bottom bar will slide out. Default is NO.
 */
@property(nonatomic, assign) BOOL hidesBottomBarWhenPushedKK;

@end
