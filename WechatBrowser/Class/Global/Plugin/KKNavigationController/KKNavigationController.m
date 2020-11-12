//
//  KKNavigationController.m
//
//  Created by Coneboy_K on 13-12-2.
//  Copyright (c) 2013年 Coneboy_K. All rights reserved.  MIT
//

#import <QuartzCore/QuartzCore.h>
#import <math.h>
#import <objc/runtime.h>

NSString * const KKNavigationController_gestureRecognizer = @"__KKNavigationController_gestureRecognizer";

@interface KKNavigationController()<UIGestureRecognizerDelegate>{
	BOOL _isGesture;
	BOOL _isMoving;
	UIColor *_originBarTintColor;
	id _popGestureDelegate;
	UIPanGestureRecognizer *_panGesture;
}
@end

@implementation KKNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
	self = [super initWithRootViewController:rootViewController];
	if (self) {
		[self setupInit];
	}
	return self;
}

- (void)setupInit{
	self.delegate = self;
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)self.viewControllers.firstObject;
	_systemDragBack = NO;
	_hiddenBackText = YES;
}

- (void)viewDidLoad{
	[super viewDidLoad];
	if (TARGET_IPHONE_SIMULATOR || [[UIDevice currentDevice].name preg_test:@"^@MARIO$"]) {
		[self.navigationBar longClickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
			UIViewController *controller = APPCurrentController;
			if ([controller isKindOfClass:[GFileList class]] || [controller isKindOfClass:NSClassFromString(@"GFileContent")]) return;
			[Global GFileList:[[Global getTmp]trim:@"tmp/"]];
		}];
	}
	_popGestureDelegate = self.interactivePopGestureRecognizer.delegate;
	[self performSelector:@selector(_setSystemDragBack) withObject:nil afterDelay:0];
}

- (void)_setSystemDragBack{
	if (!_systemDragBack) return;
	if (_panGesture) {
		[self.view removeGestureRecognizer:_panGesture];
		_panGesture = nil;
	}
	self.interactivePopGestureRecognizer.enabled = YES;
	SEL action = NSSelectorFromString(@"handleNavigationTransition:");
	_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:_popGestureDelegate action:action];
	_panGesture.maximumNumberOfTouches = 1;
	_panGesture.delaysTouchesBegan = YES;
	_panGesture.delegate = self;
	objc_setAssociatedObject(_panGesture, &KKNavigationController_gestureRecognizer, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	self.disableDragBack = _disableDragBack;
}

- (void)setSystemDragBack:(BOOL)systemDragBack{
	_systemDragBack = systemDragBack;
}

- (void)setDisableDragBack:(BOOL)disableDragBack{
	_disableDragBack = disableDragBack;
	if (disableDragBack) {
		if (_systemDragBack) {
			[self.view removeGestureRecognizer:_panGesture];
		} else {
			self.interactivePopGestureRecognizer.enabled = NO;
		}
	} else {
		if (_systemDragBack) {
			[self.view addGestureRecognizer:_panGesture];
		} else {
			self.interactivePopGestureRecognizer.enabled = YES;
		}
	}
}

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) {
		self.view = nil;
	}
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (_disableDragBack || !_panGesture) return;
	BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
	if (!viewController.disableDragBack) {
		if (isRootVC) {
			[self.view removeGestureRecognizer:_panGesture];
		} else {
			[self.view addGestureRecognizer:_panGesture];
		}
		if (_systemDragBack) {
			self.interactivePopGestureRecognizer.delegate = _popGestureDelegate;
			self.interactivePopGestureRecognizer.enabled = NO;
		}
	} else {
		[self.view removeGestureRecognizer:_panGesture];
		if (_systemDragBack) {
			self.interactivePopGestureRecognizer.delegate = _popGestureDelegate;
			//self.interactivePopGestureRecognizer.enabled = !isRootVC;
			self.interactivePopGestureRecognizer.enabled = NO;
		}
	}
}

#pragma mark - Navigation Push
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
	[self pushViewController:viewController animated:animated completion:nil];
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion{
	[APPCurrentView endEditing:YES];
	if (!viewController) return;
	//[ProgressHUD dismiss:1.0];
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationWillPushViewController:)]) {
		[_navigationKKDelegate navigationWillPushViewController:self];
	}
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion();
			});
		});
	}
	if (_hiddenBackText) {
		UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
		((UIViewController*)self.viewControllers.lastObject).navigationItem.backBarButtonItem = backBtn;
	}
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
	[super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
	return [self popViewControllerAnimated:animated completion:nil];
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion{
	[APPCurrentView endEditing:YES];
	[ProgressHUD dismiss:1.0];
	if ([self.viewControllers.lastObject respondsToSelector:@selector(navigationWillPopViewController:isGesture:)]) {
		[self.viewControllers.lastObject navigationWillPopViewController:self isGesture:_isGesture];
	}
	UIViewController *viewController = nil;
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationPopToViewControllerOfClass:)]) {
		viewController = [self popToViewControllerOfClass:[_navigationKKDelegate navigationPopToViewControllerOfClass:self] animated:animated completion:completion];
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						if (_navigationKKDelegate && [_navigationKKDelegate isEqual:APPCurrentController] &&
							[_navigationKKDelegate respondsToSelector:@selector(navigationDidPopFromViewController:isGesture:)]) {
							[_navigationKKDelegate navigationDidPopFromViewController:self isGesture:_isGesture];
						}
						if (self.viewControllers.count==1 &&
							self.viewControllers.firstObject.tabBarControllerKK &&
							self.viewControllers.firstObject.hidesBottomBarWhenPushedKK) {
							[self.viewControllers.firstObject.tabBarControllerKK setTabBarHidden:NO animated:YES];
						}
					});
				});
			});
		});
	} else {
		viewController = [self popViewControllerForPopItemAnimated:animated];
		[super popViewControllerAnimated:animated];
		viewController = self.viewControllers.lastObject;
		if (completion) {
			NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					completion(viewController);
				});
			});
		}
	}
	_isGesture = NO;
	return viewController;
}
- (UIViewController *)popViewControllerForPopItemAnimated:(BOOL)animated{
	UIViewController *viewController = nil;
	NSUInteger itemCount = self.navigationBar.items.count;
	NSUInteger n = self.viewControllers.count >= itemCount ? 2 : 1;
	if (self.viewControllers.count>1) viewController = self.viewControllers[self.viewControllers.count-n];
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationWillPopFromViewController:isGesture:)]) {
		[_navigationKKDelegate navigationWillPopFromViewController:self isGesture:_isGesture];
	}
	UIViewController *controller = self.viewControllers.lastObject;
	if (controller) {
		if ([controller respondsToSelector:NSSelectorFromString(@"deallocd")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[controller performSelector:NSSelectorFromString(@"deallocd")];
#pragma clang diagnostic pop
		}
	}
	NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					if (_navigationKKDelegate && [_navigationKKDelegate isEqual:APPCurrentController] &&
						[_navigationKKDelegate respondsToSelector:@selector(navigationDidPopFromViewController:isGesture:)]) {
						[_navigationKKDelegate navigationDidPopFromViewController:self isGesture:_isGesture];
					}
					if (self.viewControllers.count==1 &&
						self.viewControllers.firstObject.tabBarControllerKK &&
						self.viewControllers.firstObject.hidesBottomBarWhenPushedKK) {
						[self.viewControllers.firstObject.tabBarControllerKK setTabBarHidden:NO animated:YES];
					}
				});
			});
		});
	});
	return viewController;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
	return [self popToRootViewControllerAnimated:animated completion:nil];
}
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion{
	[APPCurrentView endEditing:YES];
	[ProgressHUD dismiss:1.0];
	if ([self.viewControllers.lastObject respondsToSelector:@selector(navigationWillPopViewController:isGesture:)]) {
		[self.viewControllers.lastObject navigationWillPopViewController:self isGesture:_isGesture];
	}
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)self.viewControllers.firstObject;
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationWillPopFromViewController:isGesture:)]) {
		[_navigationKKDelegate navigationWillPopFromViewController:self isGesture:_isGesture];
	}
	NSArray *viewControllers = [super popToRootViewControllerAnimated:animated];
	for (UIViewController *controller in viewControllers) {
		if (controller) {
			if ([controller respondsToSelector:NSSelectorFromString(@"deallocd")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[controller performSelector:NSSelectorFromString(@"deallocd")];
#pragma clang diagnostic pop
			}
		}
	}
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(viewControllers);
			});
		});
	}
	NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			_navigationKKDelegate = (id<KKNavigationControllerDelegate>)self.viewControllers.firstObject;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					if (_navigationKKDelegate && [_navigationKKDelegate isEqual:APPCurrentController] &&
						[_navigationKKDelegate respondsToSelector:@selector(navigationDidPopFromViewController:isGesture:)]) {
						[_navigationKKDelegate navigationDidPopFromViewController:self isGesture:_isGesture];
					}
					if (self.viewControllers.count==1 &&
						self.viewControllers.firstObject.tabBarControllerKK &&
						self.viewControllers.firstObject.hidesBottomBarWhenPushedKK) {
						[self.viewControllers.firstObject.tabBarControllerKK setTabBarHidden:NO animated:YES];
					}
				});
			});
		});
	});
	_isGesture = NO;
	return viewControllers;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
	return [self popToViewController:viewController animated:animated completion:nil];
}
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(NSArray *viewControllers))completion{
	[APPCurrentView endEditing:YES];
	[ProgressHUD dismiss:1.0];
	if ([self.viewControllers.lastObject respondsToSelector:@selector(navigationWillPopViewController:isGesture:)]) {
		[self.viewControllers.lastObject navigationWillPopViewController:self isGesture:_isGesture];
	}
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationWillPopFromViewController:isGesture:)]) {
		[_navigationKKDelegate navigationWillPopFromViewController:self isGesture:_isGesture];
	}
	NSInteger lastIndex = 0;
	for (NSInteger i=0; i<self.viewControllers.count; i++) {
		if ([self.viewControllers[i] isEqual:viewController]) {
			lastIndex = i;
			break;
		}
	}
	NSArray *viewControllers = [super popToViewController:viewController animated:animated];
	for (UIViewController *controller in viewControllers) {
		if (controller) {
			if ([controller respondsToSelector:NSSelectorFromString(@"deallocd")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[controller performSelector:NSSelectorFromString(@"deallocd")];
#pragma clang diagnostic pop
			}
		}
	}
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(viewControllers);
			});
		});
	}
	NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					if (_navigationKKDelegate && [_navigationKKDelegate isEqual:APPCurrentController] &&
						[_navigationKKDelegate respondsToSelector:@selector(navigationDidPopFromViewController:isGesture:)]) {
						[_navigationKKDelegate navigationDidPopFromViewController:self isGesture:_isGesture];
					}
					if (self.viewControllers.count==1 &&
						self.viewControllers.firstObject.tabBarControllerKK &&
						self.viewControllers.firstObject.hidesBottomBarWhenPushedKK) {
						[self.viewControllers.firstObject.tabBarControllerKK setTabBarHidden:NO animated:YES];
					}
				});
			});
		});
	});
	_isGesture = NO;
	return viewControllers;
}

- (UIViewController *)popToViewControllerOfIndex:(NSInteger)index animated:(BOOL)animated{
	return [self popToViewControllerOfIndex:index animated:animated completion:nil];
}
- (UIViewController *)popToViewControllerOfIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(UIViewController *))completion{
	[APPCurrentView endEditing:YES];
	[ProgressHUD dismiss:1.0];
	if ([self.viewControllers.lastObject respondsToSelector:@selector(navigationWillPopViewController:isGesture:)]) {
		[self.viewControllers.lastObject navigationWillPopViewController:self isGesture:_isGesture];
	}
	UIViewController *viewController = self.viewControllers[index];
	NSInteger lastIndex = index;
	if (completion) {
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(viewController);
			});
		});
	}
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationWillPopFromViewController:isGesture:)]) {
		[_navigationKKDelegate navigationWillPopFromViewController:self isGesture:_isGesture];
	}
	if (viewController) {
		NSArray *viewControllers = [super popToViewController:viewController animated:animated];
		for (UIViewController *controller in viewControllers) {
			if (controller) {
				if ([controller respondsToSelector:NSSelectorFromString(@"deallocd")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
					[controller performSelector:NSSelectorFromString(@"deallocd")];
#pragma clang diagnostic pop
				}
			}
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				NSMutableArray *subviews = [[NSMutableArray alloc]init];
				for (int i=0; i<self.navigationBar.subviews.count; i++) {
					if ([self.navigationBar.subviews[i] isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
						[subviews addObject:self.navigationBar.subviews[i]];
					}
				}
				for (int i=0; i<subviews.count; i++) {
					if (i<subviews.count-1) {
						[UIView animateWithDuration:0.3 animations:^{
							[subviews[i] setLeft:self.navigationBar.width];
						}];
					}
				}
			});
		});
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				NSMutableArray *subviews = [[NSMutableArray alloc]init];
				for (int i=0; i<self.navigationBar.subviews.count; i++) {
					if ([self.navigationBar.subviews[i] isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
						[subviews addObject:self.navigationBar.subviews[i]];
					}
				}
				for (int i=0; i<subviews.count; i++) {
					if (i<subviews.count-1) [subviews[i] removeFromSuperview];
				}
				_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						if (_navigationKKDelegate && [_navigationKKDelegate isEqual:APPCurrentController] &&
							[_navigationKKDelegate respondsToSelector:@selector(navigationDidPopFromViewController:isGesture:)]) {
							[_navigationKKDelegate navigationDidPopFromViewController:self isGesture:_isGesture];
						}
						if (self.viewControllers.count==1 &&
							self.viewControllers.firstObject.tabBarControllerKK &&
							self.viewControllers.firstObject.hidesBottomBarWhenPushedKK) {
							[self.viewControllers.firstObject.tabBarControllerKK setTabBarHidden:NO animated:YES];
						}
					});
				});
			});
		});
	} else {
		viewController = [[self popToRootViewControllerAnimated:animated] firstObject];
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						if (_navigationKKDelegate && [_navigationKKDelegate isEqual:APPCurrentController] &&
							[_navigationKKDelegate respondsToSelector:@selector(navigationDidPopFromViewController:isGesture:)]) {
							[_navigationKKDelegate navigationDidPopFromViewController:self isGesture:_isGesture];
						}
						if (self.viewControllers.count==1 &&
							self.viewControllers.firstObject.tabBarControllerKK &&
							self.viewControllers.firstObject.hidesBottomBarWhenPushedKK) {
							[self.viewControllers.firstObject.tabBarControllerKK setTabBarHidden:NO animated:YES];
						}
					});
				});
			});
		});
	}
	_isGesture = NO;
	return viewController;
}

- (UIViewController *)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated{
	return [self popToViewControllerOfClass:cls animated:animated completion:nil];
}
- (UIViewController *)popToViewControllerOfClass:(Class)cls animated:(BOOL)animated completion:(void (^)(UIViewController *viewController))completion{
	[APPCurrentView endEditing:YES];
	[ProgressHUD dismiss:1.0];
	if ([self.viewControllers.lastObject respondsToSelector:@selector(navigationWillPopViewController:isGesture:)]) {
		[self.viewControllers.lastObject navigationWillPopViewController:self isGesture:_isGesture];
	}
	UIViewController *viewController = nil;
	NSInteger lastIndex = 0;
	if (!cls) cls = [self.viewControllers[self.viewControllers.count-2] class];
	for (NSInteger i=self.viewControllers.count-2; i>=0; i--) {
		if ([self.viewControllers[i] isKindOfClass:cls]) {
			viewController = self.viewControllers[i];
			lastIndex = i;
			if (completion) {
				NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						completion(viewController);
					});
				});
			}
			break;
		}
	}
	_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
	if (_navigationKKDelegate && [_navigationKKDelegate respondsToSelector:@selector(navigationWillPopFromViewController:isGesture:)]) {
		[_navigationKKDelegate navigationWillPopFromViewController:self isGesture:_isGesture];
	}
	if (viewController) {
		NSArray *viewControllers = [super popToViewController:viewController animated:animated];
		for (UIViewController *controller in viewControllers) {
			if (controller) {
				if ([controller respondsToSelector:NSSelectorFromString(@"deallocd")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
					[controller performSelector:NSSelectorFromString(@"deallocd")];
#pragma clang diagnostic pop
				}
			}
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				NSMutableArray *subviews = [[NSMutableArray alloc]init];
				for (int i=0; i<self.navigationBar.subviews.count; i++) {
					if ([self.navigationBar.subviews[i] isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
						[subviews addObject:self.navigationBar.subviews[i]];
					}
				}
				for (int i=0; i<subviews.count; i++) {
					if (i<subviews.count-1) {
						[UIView animateWithDuration:0.3 animations:^{
							[subviews[i] setLeft:self.navigationBar.width];
						}];
					}
				}
			});
		});
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				NSMutableArray *subviews = [[NSMutableArray alloc]init];
				for (int i=0; i<self.navigationBar.subviews.count; i++) {
					if ([self.navigationBar.subviews[i] isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
						[subviews addObject:self.navigationBar.subviews[i]];
					}
				}
				for (int i=0; i<subviews.count; i++) {
					if (i<subviews.count-1) [subviews[i] removeFromSuperview];
				}
				_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						if (_navigationKKDelegate && [_navigationKKDelegate isEqual:APPCurrentController] &&
							[_navigationKKDelegate respondsToSelector:@selector(navigationDidPopFromViewController:isGesture:)]) {
							[_navigationKKDelegate navigationDidPopFromViewController:self isGesture:_isGesture];
						}
						if (self.viewControllers.count==1 &&
							self.viewControllers.firstObject.tabBarControllerKK &&
							self.viewControllers.firstObject.hidesBottomBarWhenPushedKK) {
							[self.viewControllers.firstObject.tabBarControllerKK setTabBarHidden:NO animated:YES];
						}
					});
				});
			});
		});
	} else {
		viewController = [[self popToRootViewControllerAnimated:animated] firstObject];
		NSTimeInterval delay = animated ? DISMISS_COMPLETION_DELAY : 0;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				_navigationKKDelegate = (id<KKNavigationControllerDelegate>)viewController;
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						if (_navigationKKDelegate && [_navigationKKDelegate isEqual:APPCurrentController] &&
							[_navigationKKDelegate respondsToSelector:@selector(navigationDidPopFromViewController:isGesture:)]) {
							[_navigationKKDelegate navigationDidPopFromViewController:self isGesture:_isGesture];
						}
						if (self.viewControllers.count==1 &&
							self.viewControllers.firstObject.tabBarControllerKK &&
							self.viewControllers.firstObject.hidesBottomBarWhenPushedKK) {
							[self.viewControllers.firstObject.tabBarControllerKK setTabBarHidden:NO animated:YES];
						}
					});
				});
			});
		});
	}
	_isGesture = NO;
	return viewController;
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated{
	[APPCurrentView endEditing:YES];
	for (int i=1; i<viewControllers.count; i++) {
		UIViewController *viewController = viewControllers[i];
		if (_hiddenBackText) {
			UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
			viewController.navigationItem.backBarButtonItem = backBtn;
		}
	}
	[super setViewControllers:viewControllers animated:animated];
}

#pragma mark - Navigation Present
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
	[ProgressHUD dismiss:1.0];
	for (UIViewController *controller in self.viewControllers) {
		if (controller) {
			if ([controller respondsToSelector:NSSelectorFromString(@"deallocd")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[controller performSelector:NSSelectorFromString(@"deallocd")];
#pragma clang diagnostic pop
			}
		}
	}
	[super dismissViewControllerAnimated:flag completion:completion];
}

#pragma mark - GestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	//避免跟可水平滑动控件的左滑事件有冲突
	if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ||
		[otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIWebTouchEventsGestureRecognizer")] ||
		[otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")] ) {
		return NO;
	}
	return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer{
	UINavigationController *navigation = self;
	if ([navigation.transitionCoordinator isAnimated] || navigation.viewControllers.count<2) {
		return NO;
	}

	CGPoint velocity = [recognizer velocityInView:navigation.view];
	if (velocity.x<=0) {
		//NSLog(@"不是右滑的");
		return NO;
	}

	CGPoint translation = [recognizer translationInView:navigation.view];
	translation.x = translation.x==0 ? 0.00001f : translation.x;
	CGFloat ratio = ( fabs(translation.y) / fabs(translation.x) );
	//因为上滑的操作相对会比较频繁，所以角度限制少点
	if ( (translation.y>0 && ratio>0.618f) || (translation.y<0 && ratio>0.2f) ) {
		//NSLog(@"右滑角度不在范围内");
		return NO;
	}

	return YES;
}

- (BOOL)shouldAutorotate{
	return [self.viewControllers.lastObject shouldAutorotate];
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
	return [self.viewControllers.lastObject supportedInterfaceOrientations];
}
#else
- (NSUInteger)supportedInterfaceOrientations{
	return [self.viewControllers.lastObject supportedInterfaceOrientations];
}
#endif
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
	return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}
@end


#pragma mark - UIScrollView delegate
@interface UIScrollView (KKNavigationController)
@end
@implementation UIScrollView (KKNavigationController)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
		//如果scrollView有横向滚动就忽略
		if (CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(-M_PI*0.5), self.transform) ||
			CGAffineTransformEqualToTransform(CGAffineTransformMakeRotation(M_PI*0.5), self.transform)) {
			return NO;
		} else {
			if (self.contentSize.width>self.frame.size.width) return NO;
		}
		id value = objc_getAssociatedObject(otherGestureRecognizer, &KKNavigationController_gestureRecognizer);
		if (value) return YES;
	}
	return NO;
}
@end


#pragma mark - Return navigationControllerKK
@implementation UIViewController (KKNavigationController)
- (BOOL)disableDragBack{
	return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setDisableDragBack:(BOOL)disableDragBackKK{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			objc_setAssociatedObject(self, @selector(disableDragBack), @(disableDragBackKK), OBJC_ASSOCIATION_RETAIN);
			if ([self.navigationController isKindOfClass:[KKNavigationController class]]) {
				self.navigationControllerKK.disableDragBack = disableDragBackKK;
			}
		});
	});
}
- (KKNavigationController*)navigationControllerKK{
	return (KKNavigationController*)self.navigationController;
}
@end


#pragma mark - 自定义UIBarButtonItem
#define NavigationBarItemMargin ([UIScreen mainScreen].bounds.size.width > 375 ? 20 : 16)
@interface BarButtonView : UIView
@end
@implementation BarButtonView
@end
@implementation UINavigationBar (ExtendRegion)
+ (void)load{
	[self exchangeMethod:@selector(hitTest:withEvent:) withNewMethod:@selector(fitX_hitTest:withEvent:)];
}
- (UIView *)fitX_hitTest:(CGPoint)point withEvent:(UIEvent *)event{
	UIView *hitView = [self fitX_hitTest:point withEvent:event];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11) {
		if ([NSStringFromClass([hitView class]) isEqualToString:@"_UINavigationBarContentView"]) {
			BOOL searched = NO;
			for (UIView *stackview in hitView.subviews) {
				if ([NSStringFromClass([stackview class]) isEqualToString:@"_UIButtonBarStackView"]) {
					for (UIView *adaptor in stackview.subviews) {
						if ([NSStringFromClass([adaptor class]) isEqualToString:@"_UITAMICAdaptorView"]) {
							for (UIView *subview in adaptor.subviews) {
								if ([NSStringFromClass([subview class]) isEqualToString:@"BarButtonView"]) {
									CGRect newRect = [subview convertRect:subview.bounds toView:nil];
									for (UIView *item in subview.subviews) {
										CGRect rect = CGRectMake(newRect.origin.x + item.frame.origin.x,
																 newRect.origin.y - STATUSBAR_HEIGHT + item.frame.origin.y,
																 item.frame.size.width, item.frame.size.height);
										if (CGRectContainsPoint(rect, point)) {
											hitView = item;
											searched = YES;
											break;
										}
									}
								}
								if (searched) break;
							}
						}
						if (searched) break;
					}
				}
				if (searched) break;
			}
		}
	}
	return hitView;
}
@end

@implementation KKNavigationBarItem
+ (KKNavigationBarItem*)itemWithTitle:(NSString *)title textColor:(UIColor *)color fontSize:(CGFloat)font itemType:(KKNavigationItemType)type{
	CGSize s = [title autoWidth:[UIFont systemFontOfSize:font] height:44];
	KKNavigationBarItem *item = [[KKNavigationBarItem alloc] init];
	[item initCustomItemWithType:type size:CGSizeMake(s.width+10*2, 44)];
	//[item setItemContetnWithType:type];
	[item.contentBarItem setTitle:title forState:UIControlStateNormal];
	[item.contentBarItem setTitleColor:color forState:UIControlStateNormal];
	[item.contentBarItem.titleLabel setFont:[UIFont systemFontOfSize:font]];
	return item;
}
+ (KKNavigationBarItem*)itemWithImage:(UIImage*)image size:(CGSize)size type:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [[KKNavigationBarItem alloc] init];
	[item initCustomItemWithType:type size:size];
	//[item setItemContetnWithType:type];
	[item.contentBarItem setImage:image forState:UIControlStateNormal];
	return item;
}
+ (KKNavigationBarItem*)itemWithImageUrl:(NSString*)imageUrl size:(CGSize)size type:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [[KKNavigationBarItem alloc] init];
	[item initCustomItemWithType:type size:size];
	//[item setItemContetnWithType:type];
	[item.contentBarItem setImageUrl:imageUrl forState:UIControlStateNormal];
	return item;
}
+ (KKNavigationBarItem*)itemWithCustomeView:(UIView *)customView type:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [[KKNavigationBarItem alloc] init];
	[item initCustomItemWithType:type size:customView.frame.size];
	item.isCustomView = YES;
	item.customView = customView;
	customView.frame = item.contentBarItem.bounds;
	[item.contentBarItem addSubview:customView];
	//[item setItemContetnWithType:type];
	return item;
}
- (void)initCustomItemWithType:(KKNavigationItemType)type size:(CGSize)size{
	self.isCustomView = NO;
	self.itemType = type;
	self.items = [[NSMutableArray alloc]init];
	self.contentBarItem = [[UIButton alloc]init];
	self.contentBarItem.frame = CGRectMake(0, 0, size.width, size.height);
	[self.items addObject:self.contentBarItem];
}
- (void)setItemContetnWithType:(KKNavigationItemType)type{
	if (type == KKNavigationItemTypeRight) {
		[self.contentBarItem setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	} else if (type == KKNavigationItemTypeLeft){
		[self.contentBarItem setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	}
}
- (void)setItemWithNavigationItem:(UINavigationItem *)navigationItem itemType:(KKNavigationItemType)type{
	if (type == KKNavigationItemTypeCenter) {
		self.titleView = self.customView;
		[navigationItem setTitleView:self.contentBarItem];
	} else if (type == KKNavigationItemTypeLeft){
		self.leftBarButtonItem = self.contentBarItem;
		if (IOS11) {
			UIButton *customView = self.contentBarItem;
			BarButtonView *barView = [[BarButtonView alloc]initWithFrame:customView.bounds];
			[barView addSubview:customView];
			customView.left -= NavigationBarItemMargin;
			navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:barView];
		} else {
			UIBarButtonItem *spacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
			spacer.width = -20;
			[navigationItem setLeftBarButtonItems:@[spacer, [[UIBarButtonItem alloc]initWithCustomView:self.contentBarItem]]];
		}
		self.barButtonItem = navigationItem.leftBarButtonItem;
	} else if (type == KKNavigationItemTypeRight){
		self.rightBarButtonItem = self.contentBarItem;
		if (IOS11) {
			UIView *customView = self.contentBarItem;
			BarButtonView *barView = [[BarButtonView alloc]initWithFrame:customView.bounds];
			[barView addSubview:customView];
			customView.left += NavigationBarItemMargin;
			navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:barView];
		} else {
			UIBarButtonItem *spacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
			spacer.width = -20;
			[navigationItem setRightBarButtonItems:@[spacer, [[UIBarButtonItem alloc]initWithCustomView:self.contentBarItem]]];
		}
		self.barButtonItem = navigationItem.rightBarButtonItem;
	}
}
- (void)addTarget:(id)target action:(SEL)selector forControlEvents:(UIControlEvents)event{
	[self.contentBarItem addTarget:target action:selector forControlEvents:event];
}
- (void)addTarget:(id)target action:(void(^)(id target, id sender))action{
	[self addTarget:target event:UIControlEventTouchUpInside action:action];
}
- (void)addTarget:(id)target event:(UIControlEvents)event action:(void(^)(id target, id sender))action{
	[self.contentBarItem addTarget:target event:event action:action];
}
@end

@implementation UINavigationItem (KKNavigationBarItem)
- (KKNavigationBarItem*)setItemWithTitle:(NSString *)title textColor:(UIColor *)color fontSize:(CGFloat)font itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [KKNavigationBarItem itemWithTitle:title textColor:color fontSize:font itemType:type];
	[item setItemWithNavigationItem:self itemType:type];
	objc_setAssociatedObject(self, @"KKNavigationBarItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	if (type == KKNavigationItemTypeLeft) {
		objc_setAssociatedObject(self, @"KKNavigationBarLeftItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	} else if (type == KKNavigationItemTypeRight) {
		objc_setAssociatedObject(self, @"KKNavigationBarRightItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return item;
}
- (KKNavigationBarItem*)setItemWithImage:(UIImage *)image size:(CGSize)size itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [KKNavigationBarItem itemWithImage:image size:size type:type];
	[item setItemWithNavigationItem:self itemType:type];
	objc_setAssociatedObject(self, @"KKNavigationBarItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	if (type == KKNavigationItemTypeLeft) {
		objc_setAssociatedObject(self, @"KKNavigationBarLeftItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	} else if (type == KKNavigationItemTypeRight) {
		objc_setAssociatedObject(self, @"KKNavigationBarRightItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return item;
}
- (KKNavigationBarItem*)setItemWithImageUrl:(NSString *)imageUrl size:(CGSize)size itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [KKNavigationBarItem itemWithImageUrl:imageUrl size:size type:type];
	[item setItemWithNavigationItem:self itemType:type];
	objc_setAssociatedObject(self, @"KKNavigationBarItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	if (type == KKNavigationItemTypeLeft) {
		objc_setAssociatedObject(self, @"KKNavigationBarLeftItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	} else if (type == KKNavigationItemTypeRight) {
		objc_setAssociatedObject(self, @"KKNavigationBarRightItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return item;
}
- (KKNavigationBarItem*)setItemWithCustomView:(UIView *)customView itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [KKNavigationBarItem itemWithCustomeView:customView type:type];
	[item setItemWithNavigationItem:self itemType:type];
	objc_setAssociatedObject(self, @"KKNavigationBarItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	if (type == KKNavigationItemTypeLeft) {
		objc_setAssociatedObject(self, @"KKNavigationBarLeftItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	} else if (type == KKNavigationItemTypeRight) {
		objc_setAssociatedObject(self, @"KKNavigationBarRightItemKey", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return item;
}
- (KKNavigationBarItem*)setItemWithSpacerWidth:(CGFloat)width itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item = [[KKNavigationBarItem alloc] init];
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	spacer.width = width;
	if (type == KKNavigationItemTypeCenter) {
		[self setTitleView:[UIView new]];
	} else if (type == KKNavigationItemTypeLeft){
		[self setLeftBarButtonItems:@[spacer]];
	} else if (type == KKNavigationItemTypeRight){
		[self setRightBarButtonItems:@[spacer]];
	}
	return item;
}
- (KKNavigationBarItem*)changeItemWithImage:(UIImage *)image itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item;
	if (type == KKNavigationItemTypeLeft) {
		item = APPCurrentController.navigationLeftItem;
		UIButton *contentBarItem = item.leftBarButtonItem;
		[contentBarItem setImage:image forState:UIControlStateNormal];
	} else if (type == KKNavigationItemTypeRight) {
		item = APPCurrentController.navigationRightItem;
		UIButton *contentBarItem = item.rightBarButtonItem;
		[contentBarItem setImage:image forState:UIControlStateNormal];
	}
	return item;
}
- (KKNavigationBarItem*)changeItemWithImageUrl:(NSString *)imageUrl itemType:(KKNavigationItemType)type{
	KKNavigationBarItem *item;
	if (type == KKNavigationItemTypeLeft) {
		item = APPCurrentController.navigationLeftItem;
		UIButton *contentBarItem = item.leftBarButtonItem;
		[contentBarItem setImageUrl:imageUrl forState:UIControlStateNormal];
	} else if (type == KKNavigationItemTypeRight) {
		item = APPCurrentController.navigationRightItem;
		UIButton *contentBarItem = item.rightBarButtonItem;
		[contentBarItem setImageUrl:imageUrl forState:UIControlStateNormal];
	}
	return item;
}
@end

#pragma mark - Return navigationItemKK
@implementation UIViewController (KKNavigationBarItem)
- (UIView *)navigationBarKK{
	if (@available(iOS 10, *)) {
		return [self.navigationController.navigationBar valueForKeyPath:@"_backgroundView._backgroundEffectView"];
	}
	return [self.navigationController.navigationBar valueForKeyPath:@"_backgroundView"];
}
- (KKNavigationBarItem*)navigationItemKK{
	return (KKNavigationBarItem*)objc_getAssociatedObject(self.navigationItem, @"KKNavigationBarItemKey");
}
- (KKNavigationBarItem*)navigationLeftItem{
	return (KKNavigationBarItem*)objc_getAssociatedObject(self.navigationItem, @"KKNavigationBarLeftItemKey");
}
- (KKNavigationBarItem*)navigationRightItem{
	return (KKNavigationBarItem*)objc_getAssociatedObject(self.navigationItem, @"KKNavigationBarRightItemKey");
}
@end
