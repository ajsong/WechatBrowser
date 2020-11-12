//
//  DragView.h
//
//  Created by ajsong on 15/4/21.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DragViewDelegate<NSObject>
@optional
- (UIEdgeInsets)dragViewInArea:(UIView*)view;
- (void)dragViewDidMove:(UIView*)view;
@end

@interface DragView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic,weak) id<DragViewDelegate> delegate;

- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (void)addLongPressGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (void)addPanGestureRecognizerWithCompletion:(void (^)(NSInteger direction))completion;
- (void)addRotationGestureRecognizerWithCompletion:(void (^)(NSInteger rotate))completion;
- (void)addPinchGestureRecognizerWithCompletion:(void (^)(NSInteger scale))completion;
- (void)addDragGestureRecognizerWithOutParent:(BOOL)outParent completion:(void (^)(CGPoint center))completion;

@end
