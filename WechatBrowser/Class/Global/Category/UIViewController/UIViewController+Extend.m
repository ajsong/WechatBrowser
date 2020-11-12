//
//  UIViewController+Extend.m
//
//  Created by ajsong on 15/12/10.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#pragma mark - UIViewController+Extend
@implementation UIViewController (GlobalExtend)
- (void)isNetworking{
	//重新连接网络
	/* Subclasses should override */
}
- (void)CommonSuccess:(NSDictionary *)json{
	/* Subclasses should override */
}
- (void)CommonError:(NSDictionary *)json{
	/* Subclasses should override */
}
- (BOOL)isLogin{
	return [self isLogin:YES];
}
- (BOOL)isLogin:(BOOL)showLogin{
	if (!PERSON.isDictionary) {
		if (showLogin) {
			[self performSelector:@selector(showLogin) withObject:nil afterDelay:0];
		}
		return NO;
	}
	return YES;
}
- (void)pushLogin{
	[self showLogin:ShowLoginTypePush];
}
- (void)presentLogin{
	[self showLogin];
}
- (void)showLogin{
	[self showLogin:ShowLoginTypePresent];
}
- (void)showLogin:(ShowLoginType)type{
	[self showLogin:type selector:nil];
}
- (void)showLogin:(ShowLoginType)type selector:(SEL)selector{
	if (NSClassFromString(@"login")) {
		if (selector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:SHOWLOGIN_DIDLOGINED object:nil];
#pragma clang diagnostic pop
		}
		id e = [[NSClassFromString(@"login") alloc]init];
		if (type == ShowLoginTypePresent) {
			KKNavigationController *navigation = [[KKNavigationController alloc]initWithRootViewController:e];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
				dispatch_async(dispatch_get_main_queue(), ^{
					[self presentViewController:navigation animated:YES completion:nil];
				});
			});
		} else {
			[self.navigationController pushViewController:e animated:YES];
		}
	}
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (NSInteger)performSelectorInteger:(SEL)aSelector withObjects:(id)arguments{
	id returnValue = [self performSelector:aSelector withObjects:arguments];
	return [returnValue integerValue];
}
- (int)performSelectorInt:(SEL)aSelector withObjects:(id)arguments{
	id returnValue = [self performSelector:aSelector withObjects:arguments];
	return [returnValue intValue];
}
- (CGFloat)performSelectorFloat:(SEL)aSelector withObjects:(id)arguments{
	id returnValue = [self performSelector:aSelector withObjects:arguments];
	return [returnValue floatValue];
}
- (BOOL)performSelectorBool:(SEL)aSelector withObjects:(id)arguments{
	id returnValue = [self performSelector:aSelector withObjects:arguments];
	return [returnValue boolValue];
}
#pragma clang diagnostic pop
//id returnValue = [self performSelector:@selector(collectionView:layout:insetForSectionAtIndex:) withObjects:@[_collectionView, self, @{@"integer":@(attributes.indexPath.section)}]];
//inset = [returnValue UIEdgeInsetsValue];
- (id)performSelector:(SEL)aSelector withObjects:(id)arguments{
	id returnValue = nil;
	NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
	if (signature) {
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
		[invocation setTarget:self];
		[invocation setSelector:aSelector];
		if ([arguments isKindOfClass:[NSArray class]]) {
			for (int i=0; i<[arguments count]; i++) {
				id argument = [arguments objectAtIndex:i];
				if ([argument isKindOfClass:[NSDictionary class]]) {
					for (NSString *key in argument) {
						if ([key isEqualToString:@"int"]) {
							int arg = [[argument objectForKey:key] intValue];
							[invocation setArgument:&arg atIndex:i+2];
						} else if ([key isEqualToString:@"integer"]) {
							NSInteger arg = [[argument objectForKey:key] integerValue];
							[invocation setArgument:&arg atIndex:i+2];
						} else if ([key isEqualToString:@"float"]) {
							float arg = [[argument objectForKey:key] floatValue];
							[invocation setArgument:&arg atIndex:i+2];
						} else if ([key isEqualToString:@"bool"]) {
							BOOL arg = [[argument objectForKey:key] boolValue];
							[invocation setArgument:&arg atIndex:i+2];
						} else {
							id arg = [argument objectForKey:key];
							[invocation setArgument:&arg atIndex:i+2];
						}
						break;
					}
				} else if ([argument isKindOfClass:[NSNull class]]) {
					argument = nil;
					[invocation setArgument:&argument atIndex:i+2];
				} else {
					[invocation setArgument:&argument atIndex:i+2];
				}
			}
		} else if ([arguments isKindOfClass:[NSString class]]) {
			[invocation setArgument:&arguments atIndex:2];
		} else {
			NSString *info = [NSString stringWithFormat:@"%@", NSStringFromSelector(_cmd)];
			[NSException raise:@"参数类型出错，仅支持NSArray、NSString" format:info, nil];
			return nil;
		}
		[invocation invoke];
		const char *type = signature.methodReturnType;
		if( !strcmp(type, @encode(void)) ){
			return nil;
		} else if( !strcmp(type, @encode(id)) ){
			[invocation getReturnValue:&returnValue];
		} else {
			NSUInteger length = signature.methodReturnLength;
			void *buffer = (void *)malloc(length);
			[invocation getReturnValue:buffer];
			if( !strcmp(type, @encode(int)) ) {
				returnValue = [NSNumber numberWithInt:*((int*)buffer)];
			} else if( !strcmp(type, @encode(NSInteger)) ){
				returnValue = [NSNumber numberWithInteger:*((NSInteger*)buffer)];
			} else if( !strcmp(type, @encode(float)) ){
				returnValue = [NSNumber numberWithFloat:*((float*)buffer)];
			} else if( !strcmp(type, @encode(BOOL)) ){
				returnValue = [NSNumber numberWithBool:*((BOOL*)buffer)];
			} else {
				returnValue = [NSValue valueWithBytes:buffer objCType:type];
			}
		}
	}
	return returnValue;
}

//判断当前视图是否Push进来的
- (BOOL)isPushController{
	if (!self.navigationController) return NO;
	if (self.presentingViewController) return NO;
	NSArray *viewControllers = self.navigationController.viewControllers;
	if (viewControllers.count>1 && [viewControllers[viewControllers.count-1] isEqual:self]) {
		return YES;
	}
	return NO;
}

- (void)presentController:(UIViewController *)viewController{
	[self presentController:viewController animated:YES completion:nil];
}
- (void)presentController:(UIViewController *)viewController animated:(BOOL)flag completion:(void (^)(void))completion{
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		[self presentViewController:viewController animated:flag completion:completion];
	} else {
		KKNavigationController *navigation = [[KKNavigationController alloc]initWithRootViewController:viewController];
		[self presentViewController:navigation animated:flag completion:completion];
	}
}

- (void)pushControllerWithClass:(NSString*)classString{
	if (NSClassFromString(classString)) {
		id e = [[NSClassFromString(classString) alloc]init];
		[self.navigationController pushViewController:e animated:YES];
	}
}
- (void)presentControllerWithClass:(NSString*)classString{
	if (NSClassFromString(classString)) {
		id e = [[NSClassFromString(classString) alloc]init];
		KKNavigationController *navigation = [[KKNavigationController alloc]initWithRootViewController:e];
		[self presentViewController:navigation animated:YES completion:nil];
	}
}

#pragma mark - DYActionSheet
- (void)presentActionViewController:(UIViewController*)vc{
	[self presentActionView:vc.view];
}
- (void)presentActionViewController:(UIViewController*)vc direction:(DYActionViewDirection)direction{
	[self presentActionView:vc.view direction:direction];
}
- (void)presentActionView:(UIView*)view{
	[self presentActionView:view direction:DYActionViewDown];
}
- (void)presentActionView:(UIView*)view direction:(DYActionViewDirection)direction{
	[self presentActionView:view always:NO inView:KEYWINDOW direction:direction closing:nil closeCompletion:nil];
}
- (void)presentActionViewAlways:(UIView*)view{
	[self presentActionView:view always:YES inView:KEYWINDOW];
}
- (void)presentActionViewAlways:(UIView*)view direction:(DYActionViewDirection)direction{
	[self presentActionView:view always:YES inView:KEYWINDOW direction:direction closing:nil closeCompletion:nil];
}
- (void)presentActionView:(UIView*)view inView:(UIView*)target{
	[self presentActionView:view always:NO inView:target];
}
- (void)presentActionView:(UIView*)view inView:(UIView*)target direction:(DYActionViewDirection)direction{
	[self presentActionView:view always:NO inView:target direction:direction closing:nil closeCompletion:nil];
}
- (void)presentActionView:(UIView*)view always:(BOOL)always inView:(UIView*)target{
	[self presentActionView:view always:always inView:target direction:DYActionViewDown closing:nil closeCompletion:nil];
}
- (void)presentActionView:(UIView*)view closeCompletion:(void (^)(void))closeCompletion{
	[self presentActionView:view always:YES inView:KEYWINDOW direction:DYActionViewDown closing:nil closeCompletion:closeCompletion];
}
- (void)presentActionView:(UIView*)view always:(BOOL)always inView:(UIView*)target direction:(DYActionViewDirection)direction closing:(void (^)(void))closing closeCompletion:(void (^)(void))closeCompletion{
	if ([target viewWithTag:PRESENT_ACTION_TAG]) {
		if (!always) return;
		view = [target viewWithTag:PRESENT_ACTION_TAG];
	}
	self.element[@"actionTarget"] = target;
	self.element[@"actionAlways"] = @(always);
	self.element[@"actionDirection"] = @(direction);
	if (closing) self.element[@"actionClosing"] = closing;
	if (closeCompletion) self.element[@"actionCloseCompletion"] = closeCompletion;
	//UIToolbar *overlay = [[UIToolbar alloc]initWithFrame:target.bounds];
	//overlay.barStyle = UIBarStyleBlackTranslucent; //UIBarStyleDefault:白色
	UIView *overlay = [target viewWithTag:PRESENT_OVERLAY_TAG];
	if (!overlay) {
		CGFloat alpha = [view.element[@"backgroundAlpha"]isset] ? [view.element[@"backgroundAlpha"]floatValue] : 0.6;
		overlay = [[UIView alloc]initWithFrame:target.bounds];
		overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
		overlay.userInteractionEnabled = YES;
		overlay.tag = PRESENT_OVERLAY_TAG;
		overlay.alpha = 0;
		[target addSubview:overlay];
		//UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
		//visualEfView.frame = overlay.bounds;
		//[overlay addSubview:visualEfView];
	}
	UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	dismissBtn.frame = overlay.bounds;
	dismissBtn.backgroundColor = [UIColor clearColor];
	if (![view.element[@"disableClose"]isset]) [dismissBtn addTarget:self action:@selector(dismissActionView) forControlEvents:UIControlEventTouchUpInside];
	[overlay addSubview:dismissBtn];
	BOOL hasOtherView = [target viewWithTag:PRESENT_ALERT_TAG]!=nil;
	if (hasOtherView) [target bringSubviewToFront:overlay];
	view.tag = PRESENT_ACTION_TAG;
	view.element[@"actionType"] = @YES;
	switch (direction) {
		case DYActionViewDown:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, target.frame.size.height, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYActionViewUp:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYActionViewLeft:{
			view.frame = CGRectMake(-view.frame.size.width, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYActionViewRight:{
			view.frame = CGRectMake(target.frame.size.width, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			break;
		}
		default:
			break;
	}
	view.hidden = NO;
	if (![target viewWithTag:PRESENT_ACTION_TAG]) [target addSubview:view];
	[target bringSubviewToFront:view];
	[UIView animateWithDuration:0.3 animations:^{
		overlay.alpha = 1;
		switch (direction) {
			case DYActionViewDown:{
				view.frame = CGRectMake(view.frame.origin.x, target.frame.size.height-view.frame.size.height, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYActionViewUp:{
				view.frame = CGRectMake(view.frame.origin.x, 0, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYActionViewLeft:{
				view.frame = CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYActionViewRight:{
				view.frame = CGRectMake(target.frame.size.width-view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
				break;
			}
			default:
				break;
		}
	}];
}
- (void)dismissActionView{
	[self dismissActionView:self.element[@"actionCloseCompletion"]];
}
- (void)dismissActionView:(void (^)(void))closeCompletion{
	[self dismissActionView:nil closeCompletion:closeCompletion];
}
- (void)dismissActionView:(void (^)(void))closing closeCompletion:(void (^)(void))closeCompletion{
	[ProgressHUD dismiss];
	UIView *target = self.element[@"actionTarget"];
	BOOL always = [self.element[@"actionAlways"] boolValue];
	DYActionViewDirection direction = [self.element[@"actionDirection"] integerValue];
	if (!target) return;
	BOOL hasOtherView = [target viewWithTag:PRESENT_ALERT_TAG]!=nil;
	UIView *overlay = [target viewWithTag:PRESENT_OVERLAY_TAG];
	UIView *view = [target viewWithTag:PRESENT_ACTION_TAG];
	if (![view.element[@"actionType"] isset]) return;
	view.removeElement = @"actionType";
	[UIView animateWithDuration:0.3 animations:^{
		if (!hasOtherView) overlay.alpha = 0;
		switch (direction) {
			case DYActionViewDown:{
				view.frame = CGRectMake(view.frame.origin.x, target.frame.size.height, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYActionViewUp:{
				view.frame = CGRectMake(view.frame.origin.x, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYActionViewLeft:{
				view.frame = CGRectMake(-view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYActionViewRight:{
				view.frame = CGRectMake(target.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
				break;
			}
			default:
				break;
		}
		if (closing) closing();
	} completion:^(BOOL finished) {
		if (!hasOtherView) {
			[overlay removeFromSuperview];
		} else {
			[overlay.subviews.lastObject removeFromSuperview];
			[target bringSubviewToFront:[target viewWithTag:PRESENT_ALERT_TAG]];
		}
		if (!always) {
			[view removeFromSuperview];
		} else {
			view.hidden = YES;
		}
		if (closeCompletion) closeCompletion();
	}];
}

#pragma mark - DYAlertView
- (void)presentAlertViewController:(UIViewController*)vc{
	[self presentAlertView:vc.view];
}
- (void)presentAlertView:(UIView*)view{
	[self presentAlertView:view animation:DYAlertViewNoAnimation];
}
- (void)presentAlertView:(UIView*)view animation:(DYAlertViewAnimation)animation{
	[self presentAlertView:view animation:animation closeCompletion:nil];
}
- (void)presentAlertView:(UIView*)view animation:(DYAlertViewAnimation)animation closeCompletion:(void (^)(void))closeCompletion{
	[self presentAlertView:view always:NO inView:KEYWINDOW animation:animation closeCompletion:closeCompletion];
}
- (void)presentAlertViewAlways:(UIView*)view animation:(DYAlertViewAnimation)animation{
	[self presentAlertViewAlways:view animation:animation closeCompletion:nil];
}
- (void)presentAlertViewAlways:(UIView*)view animation:(DYAlertViewAnimation)animation closeCompletion:(void (^)(void))closeCompletion{
	[self presentAlertView:view always:YES inView:KEYWINDOW animation:animation closeCompletion:closeCompletion];
}
- (void)presentAlertView:(UIView*)view always:(BOOL)always inView:(UIView*)target animation:(DYAlertViewAnimation)animation{
	[self presentAlertView:view always:always inView:target animation:animation closeCompletion:nil];
}
- (void)presentAlertView:(UIView*)view always:(BOOL)always inView:(UIView*)target animation:(DYAlertViewAnimation)animation closeCompletion:(void (^)(void))closeCompletion{
	if ([target viewWithTag:PRESENT_ALERT_TAG]) {
		if (!always) return;
		view = [target viewWithTag:PRESENT_ALERT_TAG];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAlertKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAlertKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	self.element[@"alertTarget"] = target;
	self.element[@"alertAlways"] = @(always);
	if (closeCompletion) self.element[@"alertCloseCompletion"] = closeCompletion;
	//UIToolbar *overlay = [[UIToolbar alloc]initWithFrame:target.bounds];
	//overlay.barStyle = UIBarStyleBlackTranslucent;
	UIView *overlay = [target viewWithTag:PRESENT_OVERLAY_TAG];
	if (!overlay) {
		CGFloat alpha = [view.element[@"backgroundAlpha"]isset] ? [view.element[@"backgroundAlpha"]floatValue] : 0.6;
		overlay = [[UIView alloc]initWithFrame:target.bounds];
		overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
		overlay.userInteractionEnabled = YES;
		overlay.tag = PRESENT_OVERLAY_TAG;
		overlay.alpha = 0;
		[target addSubview:overlay];
	}
	UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	dismissBtn.tag = 777 + animation;
	dismissBtn.frame = overlay.bounds;
	dismissBtn.backgroundColor = [UIColor clearColor];
	if (![view.element[@"disableClose"]isset]) [dismissBtn addTarget:self action:@selector(dismissAlertViewWithBtn:) forControlEvents:UIControlEventTouchUpInside];
	[overlay addSubview:dismissBtn];
	BOOL hasOtherView = [target viewWithTag:PRESENT_ACTION_TAG]!=nil;
	if (hasOtherView) [target bringSubviewToFront:overlay];
	view.tag = PRESENT_ALERT_TAG;
	view.element[@"alertType"] = @YES;
	view.element[@"animationClose"] = @(animation);
	switch (animation) {
		case DYAlertViewNoAnimation:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYAlertViewUp:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYAlertViewDown:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, target.frame.size.height, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYAlertViewLeft:{
			view.frame = CGRectMake(-view.frame.size.width, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYAlertViewRight:{
			view.frame = CGRectMake(target.frame.size.width, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			break;
		}
		case DYAlertViewFade:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			view.alpha = 0;
			break;
		}
		case DYAlertViewScale:{
			view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
			view.alpha = 0.5f;
			view.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0f);
			break;
		}
		default:
			break;
	}
	view.hidden = NO;
	if (![target viewWithTag:PRESENT_ALERT_TAG]) [target addSubview:view];
	[target bringSubviewToFront:view];
	[view setMotionEffect:10.0f];
	if (animation == DYAlertViewNoAnimation) {
		overlay.alpha = 1;
		return;
	}
	[UIView animateWithDuration:0.3 animations:^{
		overlay.alpha = 1;
		view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
		view.alpha = 1;
		if (animation == DYAlertViewScale) {
			view.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
		}
	}];
}
- (void)dismissAlertViewWithBtn:(UIButton*)sender{
	NSInteger animation = sender.tag - 777;
	[self dismissAlertView:animation];
}
- (void)dismissAlertView{
	UIView *target = self.element[@"alertTarget"];
	if (!target) return;
	UIView *view = [target viewWithTag:PRESENT_ALERT_TAG];
	DYAlertViewAnimation animation = [view.element[@"animationClose"]integerValue];
	[self dismissAlertView:animation];
}
- (void)dismissAlertView:(DYAlertViewAnimation)animation{
	[self dismissAlertView:animation closeCompletion:self.element[@"alertCloseCompletion"]];
}
- (void)dismissAlertView:(DYAlertViewAnimation)animation closeCompletion:(void (^)(void))closeCompletion{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[ProgressHUD dismiss];
	UIView *target = self.element[@"alertTarget"];
	BOOL always = [self.element[@"alertAlways"] boolValue];
	if (!target) return;
	BOOL hasOtherView = [target viewWithTag:PRESENT_ACTION_TAG]!=nil;
	UIView *overlay = [target viewWithTag:PRESENT_OVERLAY_TAG];
	UIView *view = [target viewWithTag:PRESENT_ALERT_TAG];
	if (![view.element[@"alertType"] isset]) return;
	view.removeElement = @"alertType";
	if (animation == DYAlertViewNoAnimation) {
		if (!hasOtherView) {
			[overlay removeFromSuperview];
		} else {
			[overlay.subviews.lastObject removeFromSuperview];
			[target bringSubviewToFront:[target viewWithTag:PRESENT_ACTION_TAG]];
		}
		if (!always) {
			[view removeFromSuperview];
		} else {
			view.hidden = YES;
		}
		if (closeCompletion) closeCompletion();
		return;
	}
	if (!hasOtherView) {
		[UIView animateWithDuration:0.3 animations:^{
			overlay.alpha = 0;
		} completion:^(BOOL finished) {
			[overlay removeFromSuperview];
		}];
	}
	CATransform3D currentTransform = view.layer.transform;
	if (animation == DYAlertViewScale) {
		CGFloat startRotation = [[view valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
		CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
		view.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
	}
	[UIView animateWithDuration:0.3 animations:^{
		switch (animation) {
			case DYAlertViewUp:{
				view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYAlertViewDown:{
				view.frame = CGRectMake((target.frame.size.width-view.frame.size.width)/2, target.frame.size.height, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYAlertViewLeft:{
				view.frame = CGRectMake(-view.frame.size.width, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYAlertViewRight:{
				view.frame = CGRectMake(target.frame.size.width, (target.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
				break;
			}
			case DYAlertViewFade:{
				view.alpha = 0;
				break;
			}
			case DYAlertViewScale:{
				view.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
				view.layer.opacity = 0.0f;
				break;
			}
			default:
				break;
		}
	} completion:^(BOOL finished) {
		if (hasOtherView) {
			[overlay.subviews.lastObject removeFromSuperview];
			[target bringSubviewToFront:[target viewWithTag:PRESENT_ACTION_TAG]];
		}
		if (!always) {
			[view removeFromSuperview];
		} else {
			view.hidden = YES;
		}
		if (closeCompletion) closeCompletion();
	}];
}
- (void)presentAlertKeyboardWillShow:(NSNotification *)notification{
	NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
	self.element[@"keyboardBoundsValue"] = keyboardBoundsValue;
	[self presentAlertAdjustViewForKeyboardReveal];
}
- (void)presentAlertKeyboardWillHide:(NSNotification *)notification{
	if (!self.element[@"alertTarget"]) return;
	UIView *target = self.element[@"alertTarget"];
	UIView *view = [target viewWithTag:PRESENT_ALERT_TAG];
	CGRect frame = view.frame;
	frame.origin.y = (target.frame.size.height - frame.size.height) / 2;
	[UIView animateWithDuration:0.3 animations:^{
		view.frame = frame;
	}];
}
- (void)presentAlertAdjustViewForKeyboardReveal{
	if (!self.element[@"alertTarget"] || !self.element[@"keyboardBoundsValue"]) return;
	UIView *target = self.element[@"alertTarget"];
	UIView *view = [target viewWithTag:PRESENT_ALERT_TAG];
	CGRect frame = view.frame;
	CGRect keyboardbound = [self.element[@"keyboardBoundsValue"] CGRectValue];
	if (frame.origin.y+frame.size.height < target.frame.size.height-keyboardbound.size.height) return;
	CGFloat offsetTop = 0;
	if (target.frame.size.height-keyboardbound.size.height < frame.size.height) {
		offsetTop = target.frame.size.height - keyboardbound.size.height - frame.size.height;
	} else {
		offsetTop = (target.frame.size.height - keyboardbound.size.height - frame.size.height) / 2;
	}
	frame.origin.y = offsetTop;
	[UIView animateWithDuration:0.3 animations:^{
		view.frame = frame;
	}];
}

#pragma mark - PositionView
- (void)positionWithTitle:(NSString*)title text:(NSString*)text placeholder:(NSString*)placeholder submit:(void(^)(NSString *text))submit{
	[self positionWithTitle:title text:text placeholder:placeholder keyboardType:UIKeyboardTypeDefault btnTitle:@"确定" btnTitleColor:COLORWHITE btnBgColor:COLORMAIN animation:DYAlertViewDown subview:nil submit:submit];
}
- (void)positionWithTitle:(NSString*)title text:(NSString*)text placeholder:(NSString*)placeholder keyboardType:(UIKeyboardType)keyboardType btnTitle:(NSString*)btnTitle btnTitleColor:(UIColor*)btnTitleColor btnBgColor:(UIColor*)btnBgColor animation:(DYAlertViewAnimation)animation subview:(UIView *(^)(UIView *view))subviewBlock submit:(void(^)(NSString *text))submit{
	UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-25*SCREEN_SCALE*2, 0)];
	container.backgroundColor = COLORWHITE;
	container.layer.masksToBounds = YES;
	container.layer.cornerRadius = 10*SCREEN_SCALE;

	CGFloat top = 0;
	if (title.length) {
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, container.width, 30*SCREEN_SCALE)];
		label.text = title;
		label.textColor = COLORBBB;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(10);
		label.backgroundColor = [UIColor clearColor];
		[container addSubview:label];
		top = label.bottom;
	}

	if (subviewBlock) {
		UIView *subview = subviewBlock(container);
		subview.top = top;
		[container addSubview:subview];
		top = subview.bottom;
	}

	UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(25*SCREEN_SCALE, top+20*SCREEN_SCALE, container.width-25*SCREEN_SCALE*2, 44*SCREEN_SCALE)];
	textField.text = text;
	textField.placeholder = placeholder;
	textField.textColor = COLORTEXT;
	textField.textAlignment = NSTextAlignmentCenter;
	textField.font = FONT(12);
	textField.backgroundColor = [UIColor clearColor];
	textField.keyboardType = keyboardType;
	[container addSubview:textField];

	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, textField.bottom+15*SCREEN_SCALE, container.width, 44*SCREEN_SCALE)];
	btn.titleLabel.font = FONT(14);
	btn.backgroundColor = btnBgColor;
	[btn setTitle:btnTitle forState:UIControlStateNormal];
	[btn setTitleColor:btnTitleColor forState:UIControlStateNormal];
	[btn addTarget:nil action:^(id target, id sender) {
		if (submit) submit(textField.text);
	}];
	[container addSubview:btn];
	container.height = btn.bottom;

	[self presentAlertView:container animation:animation closeCompletion:^{
		[self.view endEditing:YES];
	}];
}
- (void)positionWithTitle:(NSString*)title view:(UIView*)view submit:(void(^)())submit{
	[self positionWithTitle:title view:view btnTitle:@"确定" btnTitleColor:COLORWHITE btnBgColor:COLORMAIN animation:DYAlertViewDown subview:nil submit:submit];
}
- (void)positionWithTitle:(NSString*)title view:(UIView*)view btnTitle:(NSString*)btnTitle btnTitleColor:(UIColor*)btnTitleColor btnBgColor:(UIColor*)btnBgColor animation:(DYAlertViewAnimation)animation subview:(UIView *(^)(UIView *view))subviewBlock submit:(void(^)())submit{
	UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view.width, 0)];
	container.backgroundColor = COLORWHITE;
	container.layer.masksToBounds = YES;
	container.layer.cornerRadius = 10*SCREEN_SCALE;

	CGFloat top = 0;
	if (title.length) {
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, container.width, 30*SCREEN_SCALE)];
		label.text = title;
		label.textColor = COLORBBB;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(10);
		label.backgroundColor = [UIColor clearColor];
		[container addSubview:label];
		top = label.bottom;
	}

	if (subviewBlock) {
		UIView *subview = subviewBlock(container);
		subview.top = top;
		[container addSubview:subview];
		top = subview.bottom;
	}

	view.origin = CGPointMake(0, top);
	[container addSubview:view];

	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, view.bottom+15*SCREEN_SCALE, container.width, 44*SCREEN_SCALE)];
	btn.titleLabel.font = FONT(14);
	btn.backgroundColor = btnBgColor;
	[btn setTitle:btnTitle forState:UIControlStateNormal];
	[btn setTitleColor:btnTitleColor forState:UIControlStateNormal];
	[btn addTarget:nil action:^(id target, id sender) {
		if (submit) submit();
	}];
	[container addSubview:btn];
	container.height = btn.bottom;

	[self presentAlertView:container animation:animation closeCompletion:^{
		[self.view endEditing:YES];
	}];
}

- (UIViewController*)parentTarget{
	//To make it work with UINav & UITabbar as well
	UIViewController *target = self;
	while (target.parentViewController != nil) {
		target = target.parentViewController;
	}
	return target;
}

//摇动
//viewDidLoad 增加
//[UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
//[self becomeFirstResponder];
//摇动开始
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
	//NSLog(@"摇动开始");
	if ([self respondsToSelector:NSSelectorFromString(@"shakeBegin")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:NSSelectorFromString(@"shakeBegin")];
#pragma clang diagnostic pop
	}
}
//摇动结束
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
	if (event.subtype == UIEventSubtypeMotionShake) { //判断是否摇动结束
		//NSLog(@"摇动结束");
		if ([self respondsToSelector:NSSelectorFromString(@"shakeEnd")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[self performSelector:NSSelectorFromString(@"shakeEnd")];
#pragma clang diagnostic pop
		}
	}
}
//摇动取消
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
	//NSLog(@"摇动取消");
	if ([self respondsToSelector:NSSelectorFromString(@"shakeCancel")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:NSSelectorFromString(@"shakeCancel")];
#pragma clang diagnostic pop
	}
}

//获取状态栏
- (UIView*)statusBar{
	UIView *statusBar = nil;
	NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
	NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	id object = [UIApplication sharedApplication];
	if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
	return statusBar;
}

//获取状态栏高度
- (CGFloat)statusBarHeight{
	return [UIApplication sharedApplication].statusBarFrame.size.height;
}

//导航与状态栏高度
- (CGFloat)navigationAndStatusBarHeight{
	//CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height;
	CGFloat navigationHeight = 44;
	CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
	if (self.navigationController.navigationBarHidden) navigationHeight = 0;
	if ([UIApplication sharedApplication].statusBarHidden) statusHeight = 0;
	return navigationHeight + statusHeight;
}

//self.view高度(根据导航透明自动判断是否去除导航高度)
- (CGFloat)height{
	CGFloat height = SCREEN_HEIGHT;
	if (self.navigationController && !self.navigationController.navigationBarHidden &&
		(self.edgesForExtendedLayout==UIRectEdgeNone || !self.navigationController.navigationBar.translucent)) {
		height -= self.navigationAndStatusBarHeight;
	}
	return height;
}

//滚动显示/隐藏导航
- (void)navigationHiddenFollowScrollView:(UIScrollView*)scrollView{
	if (!self.navigationController) return;
	if (!self.navigationController.navigationBar.barTintColor) NSLog(@"[%s]: %@", __func__, @"Warning: no bar tint color set");

	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
	recognizer.maximumNumberOfTouches = 1;
	recognizer.delegate = self;
	[scrollView addGestureRecognizer:recognizer];

	CGRect frame = self.navigationController.navigationBar.frame;
	frame.origin = CGPointZero;
	UIView *overlay = [[UIView alloc]initWithFrame:frame];
	overlay.backgroundColor = self.navigationController.navigationBar.barTintColor;
	overlay.userInteractionEnabled = NO;
	overlay.alpha = 0;
	[self.navigationController.navigationBar addSubview:overlay];

	self.element[@"scrollView"] = scrollView;
	self.element[@"overlay"] = overlay;
	self.element[@"lastContentOffset"] = @0;
	self.element[@"isCollapsed"] = @NO;
	self.element[@"isExpanded"] = @NO;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	return YES;
}
- (void)handlePan:(UIPanGestureRecognizer*)recognizer{
	UIScrollView *scrollView = self.element[@"scrollView"];
	CGPoint translation = [recognizer translationInView:scrollView.superview];

	CGFloat lastContentOffset = [self.element[@"lastContentOffset"]floatValue];
	CGFloat delta = lastContentOffset - translation.y;
	lastContentOffset = translation.y;
	self.element[@"lastContentOffset"] = @(lastContentOffset);

	BOOL isCollapsed = [self.element[@"isCollapsed"]boolValue];
	BOOL isExpanded = [self.element[@"isExpanded"]boolValue];

	CGRect frame;
	if (delta > 0) {
		if (isCollapsed) return;
		frame = self.navigationController.navigationBar.frame;
		if (frame.origin.y - delta < -24) {
			delta = frame.origin.y + 24;
		}
		frame.origin.y = MAX(-24, frame.origin.y - delta);
		self.navigationController.navigationBar.frame = frame;
		if (frame.origin.y == -24) {
			isCollapsed = YES;
			isExpanded = NO;
		}
		self.element[@"isCollapsed"] = @(isCollapsed);
		self.element[@"isExpanded"] = @(isExpanded);
		[self updateSizingWithDelta:delta];
		if ([scrollView isKindOfClass:[UIScrollView class]]) {
			[scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - delta)];
		}
	}
	if (delta < 0) {
		if (isExpanded) return;
		frame = self.navigationController.navigationBar.frame;
		if (frame.origin.y - delta > 20) {
			delta = frame.origin.y - 20;
		}
		frame.origin.y = MIN(20, frame.origin.y - delta);
		self.navigationController.navigationBar.frame = frame;
		if (frame.origin.y == 20) {
			isExpanded = YES;
			isCollapsed = NO;
		}
		self.element[@"isCollapsed"] = @(isCollapsed);
		self.element[@"isExpanded"] = @(isExpanded);
		[self updateSizingWithDelta:delta];
	}
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		lastContentOffset = 0;
		self.element[@"lastContentOffset"] = @(lastContentOffset);
		[self checkForPartialScroll];
	}
}
- (void)checkForPartialScroll{
	__block BOOL isCollapsed = [self.element[@"isCollapsed"]boolValue];
	__block BOOL isExpanded = [self.element[@"isExpanded"]boolValue];
	CGFloat pos = self.navigationController.navigationBar.frame.origin.y;
	if (pos >= -2) {
		[UIView animateWithDuration:0.2 animations:^{
			CGRect frame;
			frame = self.navigationController.navigationBar.frame;
			CGFloat delta = frame.origin.y - 20;
			frame.origin.y = MIN(20, frame.origin.y - delta);
			self.navigationController.navigationBar.frame = frame;
			isExpanded = YES;
			isCollapsed = NO;
			self.element[@"isCollapsed"] = @(isCollapsed);
			self.element[@"isExpanded"] = @(isExpanded);
			[self updateSizingWithDelta:delta];
		}];
	} else {
		[UIView animateWithDuration:0.2 animations:^{
			CGRect frame;
			frame = self.navigationController.navigationBar.frame;
			CGFloat delta = frame.origin.y + 24;
			frame.origin.y = MAX(-24, frame.origin.y - delta);
			self.navigationController.navigationBar.frame = frame;
			isExpanded = NO;
			isCollapsed = YES;
			self.element[@"isCollapsed"] = @(isCollapsed);
			self.element[@"isExpanded"] = @(isExpanded);
			[self updateSizingWithDelta:delta];
		}];
	}
}
- (void)updateSizingWithDelta:(CGFloat)delta{
	UIScrollView *scrollableView = self.element[@"scrollableView"];
	UIView *overlay = self.element[@"overlay"];

	CGRect frame = self.navigationController.navigationBar.frame;
	CGFloat alpha = (frame.origin.y + 24) / frame.size.height;
	overlay.alpha = 1 - alpha;
	self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];

	frame = scrollableView.superview.frame;
	frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
	frame.size.height = frame.size.height + delta;
	scrollableView.superview.frame = frame;

	frame = scrollableView.layer.frame;
	frame.size.height += delta;
	scrollableView.layer.frame = frame;
}
//UIMenuController Delegate
- (BOOL)canBecomeFirstResponder{
	return YES;
}
@end
