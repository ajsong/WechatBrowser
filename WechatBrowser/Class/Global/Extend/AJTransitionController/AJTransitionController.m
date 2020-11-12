//
//  ASFSharedViewTransition.m
//  ASFTransitionTest
//
//  Created by Asif Mujteba on 09/08/2014.
//  Copyright (c) 2014 Asif Mujteba. All rights reserved.
//

#import "AJTransitionController.h"
#import <objc/runtime.h>

@interface ParamsHolder : NSObject
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) Class fromClass;
@property (nonatomic, weak) Class toClass;
@property (nonatomic, assign) NSTimeInterval duration;
@end
@implementation ParamsHolder
@end

@interface AJTransitionController ()
@property (nonatomic, retain) NSMutableArray *paramHolders;
@end

@implementation AJTransitionController
#pragma mark - Setup & Initializers
+ (instancetype)shared{
    static AJTransitionController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AJTransitionController alloc] init];
    });
    return instance;
}

- (NSMutableArray *)paramHolders{
    if (!_paramHolders) {
        _paramHolders = [[NSMutableArray alloc] init];
    }
    return _paramHolders;
}

#pragma mark - Private Methods
- (ParamsHolder *)paramHolderForFromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC reversed:(BOOL *)reversed{
    ParamsHolder *pHolder = nil;
    for (ParamsHolder *holder in [[AJTransitionController shared] paramHolders]) {
        if (holder.fromClass == [fromVC class] && holder.toClass == [toVC class]) {
            pHolder = holder;
        } else if (holder.fromClass == [toVC class] && holder.toClass == [fromVC class]) {
            pHolder = holder;
            if (reversed) {
                *reversed = true;
            }
        }
    }
    return pHolder;
}

- (UIImage *)getImageFromView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

#pragma mark - Public Methods
+ (void)addTransitionWithFromController:(UIViewController<AJTransitionDataSource>*)fromVC toController:(UIViewController<AJTransitionDataSource>*)toVC duration:(NSTimeInterval)duration{
	Class<AJTransitionDataSource> fromClass = [fromVC class];
	Class<AJTransitionDataSource> toClass = [toVC class];
	UINavigationController *navigationController = fromVC.navigationController;
	
	if (!navigationController) return;
	NSArray *fromViews = [[NSArray alloc]init];
	NSArray *toViews = [[NSArray alloc]init];
	if ([fromVC respondsToSelector:@selector(AJTransitionViewsToController:)]) {
		fromViews = [fromVC AJTransitionViewsToController:toVC];
	} else if ([fromVC respondsToSelector:@selector(AJTransitionViewToController:)]) {
		UIView *fromView = [fromVC AJTransitionViewToController:toVC];
		if (!fromView) return;
		fromViews = @[fromView];
	}
	if ([toVC respondsToSelector:@selector(AJTransitionViewsToController:)]) {
		toViews = [toVC AJTransitionViewsToController:fromVC];
	} else if ([toVC respondsToSelector:@selector(AJTransitionViewToController:)]) {
		UIView *toView = [toVC AJTransitionViewToController:fromVC];
		if (!toView) toView = [UIView new];
		toViews = @[toView];
	}
	if (!fromViews.count || !toViews.count || fromViews.count!=toViews.count) {
		return;
	}
	fromViews = nil;
	toViews = nil;
	
    BOOL found = false;
    for (ParamsHolder *holder in [[AJTransitionController shared] paramHolders]) {
        if (holder.fromClass == fromClass && holder.toClass == toClass) {
            holder.duration = duration;
            holder.navigationController = navigationController;
            holder.navigationController.delegate = [AJTransitionController shared];
            found = true;
            break;
        }
    }
    if (!found) {
        ParamsHolder *holder = [[ParamsHolder alloc] init];
        holder.fromClass = fromClass;
        holder.toClass = toClass;
        holder.duration = duration;
        holder.navigationController = navigationController;
        holder.navigationController.delegate = [AJTransitionController shared];
        [[[AJTransitionController shared] paramHolders] addObject:holder];
    }
}

#pragma mark UINavigationControllerDelegate methods
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC{
    ParamsHolder *holder = [self paramHolderForFromVC:fromVC toVC:toVC reversed:nil];
    if (holder) {
        return [AJTransitionController shared];
    } else {
        return nil;
    }
}

#pragma mark - UIViewControllerContextTransitioning
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController<AJTransitionDataSource> *fromVC = (UIViewController<AJTransitionDataSource> *) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController<AJTransitionDataSource> *toVC   = (UIViewController<AJTransitionDataSource> *) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    BOOL reversed = false;
    ParamsHolder *holder = [self paramHolderForFromVC:fromVC toVC:toVC reversed:&reversed];
    if (!holder) return;
	
	NSArray *fromViews = [[NSArray alloc]init];
	NSArray *toViews = [[NSArray alloc]init];
	if ([fromVC respondsToSelector:@selector(AJTransitionViewsToController:)]) {
		fromViews = [fromVC AJTransitionViewsToController:toVC];
	} else if ([fromVC respondsToSelector:@selector(AJTransitionViewToController:)]) {
		fromViews = @[[fromVC AJTransitionViewToController:toVC]];
	}
	if ([toVC respondsToSelector:@selector(AJTransitionViewsToController:)]) {
		toViews = [toVC AJTransitionViewsToController:fromVC];
	} else if ([toVC respondsToSelector:@selector(AJTransitionViewToController:)]) {
		toViews = @[[toVC AJTransitionViewToController:fromVC]];
	}
	
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval dur = [self transitionDuration:transitionContext];
    
    // Take Snapshot of fromView
	NSMutableArray *snapshotViewArray = [[NSMutableArray alloc]init];
	for (UIView *fromView in fromViews) {
		UIImageView *snapshotView = [[UIImageView alloc] init];
		snapshotView.frame = [containerView convertRect:fromView.frame fromView:fromView.superview];
		if ([fromView isKindOfClass:[UIImageView class]]) {
			UIImageView *fromImageView = (UIImageView*)fromView;
			snapshotView.contentMode = fromImageView.contentMode;
			snapshotView.image = fromImageView.image;
			snapshotView.clipsToBounds = YES;
			snapshotView.layer.masksToBounds = fromImageView.layer.masksToBounds;
			snapshotView.layer.cornerRadius = fromImageView.layer.cornerRadius;
		} else {
			snapshotView.image = [self getImageFromView:fromView];
		}
		fromView.hidden = YES;
		[snapshotViewArray addObject:snapshotView];
	}
	
    // Setup the initial view states
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
	
	for (UIView *toView in toViews) {
		toView.hidden = YES;
	}
    if (!reversed) {
        toVC.view.alpha = 0.0;
        [containerView addSubview:toVC.view];
    } else {
        [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    }
	
	for (UIView *snapshotView in snapshotViewArray) {
		[containerView addSubview:snapshotView];
	}
	
	[UIView animateWithDuration:dur animations:^{
		if (!reversed) {
			toVC.view.alpha = 1.0; // Fade in
		} else {
			fromVC.view.alpha = 0.0; // Fade out
		}
	} completion:^(BOOL finished) {
		// Declare that we've finished
		[transitionContext completeTransition:!transitionContext.transitionWasCancelled];
	}];
	
	// Move the SnapshotView
	for (int i=0; i<snapshotViewArray.count; i++) {
		UIImageView *snapshotView = (UIImageView*)snapshotViewArray[i];
		UIView *fromView = fromViews[i];
		UIView *toView = toViews[i];
		CGRect frame = [containerView convertRect:toView.frame fromView:toView.superview];
		[UIView animateWithDuration:dur animations:^{
			if ([fromVC respondsToSelector:@selector(AJTransitionViewAnimation:toController:toFrame:)]) {
				[fromVC AJTransitionViewAnimation:snapshotView toController:toVC toFrame:frame];
			} else {
				snapshotView.frame = frame;
			}
		} completion:^(BOOL finished) {
			toView.hidden = NO;
			fromView.hidden = NO;
			[snapshotView removeFromSuperview];
		}];
	}
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    ParamsHolder *holder = [self paramHolderForFromVC:fromVC toVC:toVC reversed:nil];
    if (holder) {
        return holder.duration;
    } else {
        return 0;
    }
}

@end

@implementation UIViewController (ASFTransitionController)
- (void)pushViewController:(UIViewController*)controller duration:(NSTimeInterval)duration{
	[AJTransitionController addTransitionWithFromController:(UIViewController<AJTransitionDataSource>*)self toController:(UIViewController<AJTransitionDataSource>*)controller duration:duration];
	[self.navigationController pushViewController:controller animated:YES];
}
@end
