//
//  JKNotifierBar.h
//
//  Created by Jakey on 15/5/21.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JKNotifier, JKNotifierBar;

typedef void(^JKNotifierBarClickBlock)(NSString *name, NSString *detail, JKNotifier *notifier);

@interface JKNotifierBar : UIView{
	JKNotifierBarClickBlock _notifierBarClickBlock;
}
- (void)show:(NSString*)note name:(NSString*)name icon:(UIImage*)icon dismiss:(NSTimeInterval)delay;
- (void)click:(JKNotifierBarClickBlock)notifierBarClickBlock;
@end
