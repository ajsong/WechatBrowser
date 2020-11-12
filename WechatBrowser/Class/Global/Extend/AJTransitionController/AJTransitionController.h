//
//  ASFSharedViewTransition.h
//  ASFTransitionTest
//
//  Created by Asif Mujteba on 09/08/2014.
//  Copyright (c) 2014 Asif Mujteba. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AJTransitionDataSource <NSObject>
@optional
- (UIView *)AJTransitionViewToController:(UIViewController*)toController;
- (NSArray *)AJTransitionViewsToController:(UIViewController*)toController;
- (void)AJTransitionViewAnimation:(UIView*)snapshotView toController:(UIViewController*)toController toFrame:(CGRect)toFrame;
@end

@interface AJTransitionController : NSObject<UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate>
@property (nonatomic,weak) Class fromClass;
@property (nonatomic,weak) Class toClass;
+ (void)addTransitionWithFromController:(UIViewController<AJTransitionDataSource>*)fromVC
						   toController:(UIViewController<AJTransitionDataSource>*)toVC
							   duration:(NSTimeInterval)duration;
@end

@interface UIViewController (AJTransitionController)
- (void)pushViewController:(UIViewController*)controller duration:(NSTimeInterval)duration;
@end
