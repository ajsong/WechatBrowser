//
//  JKNotifierBar.m
//
//  Created by Jakey on 15/5/21.
//  Copyright (c) 2015年 Jakey. All rights reserved.
//

#import "JKNotifier.h"

@interface JKNotifierBar ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation JKNotifierBar

- (instancetype)init{
	self = [super init];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)setup{
	self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
	self.clipsToBounds = YES;
	self.userInteractionEnabled = YES;
	[self addSubview:self.iconView];
	[self addSubview:self.nameLabel];
	[self addSubview:self.detailLabel];
}

- (UIImageView *)iconView{
	if (!_iconView) {
		_iconView = [[UIImageView alloc] initWithFrame:CGRectMakeScale(@15, @7, @20, @20)];
		_iconView.clipsToBounds = YES;
		_iconView.layer.masksToBounds = YES;
		_iconView.layer.cornerRadius = 4*SCREEN_SCALE;
	}
	return _iconView;
}

- (UILabel *)nameLabel{
	if (!_nameLabel) {
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((15+20+15)*SCREEN_SCALE, 7*SCREEN_SCALE, self.width-(15+20+15)*SCREEN_SCALE-15*SCREEN_SCALE, 20*SCREEN_SCALE)];
		_nameLabel.textColor = COLORWHITE;
		_nameLabel.font = FONT(14);
		_nameLabel.backgroundColor = [UIColor clearColor];
	}
	return _nameLabel;
}

- (UILabel *)detailLabel{
	if (!_detailLabel) {
		_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake((15+20+15)*SCREEN_SCALE, (7+20)*SCREEN_SCALE, self.width-(15+20+15)*SCREEN_SCALE-15*SCREEN_SCALE, 0)];
		_detailLabel.textColor = COLORWHITE;
		_detailLabel.backgroundColor = [UIColor clearColor];
		_detailLabel.font = FONT(12);
	}
	return _detailLabel;
}

#pragma mark - getter
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if (_notifierBarClickBlock) {
		_notifierBarClickBlock(self.nameLabel.text?:@"", self.detailLabel.text?:@"", [JKNotifier shareInstance]);
	}
}

- (void)click:(JKNotifierBarClickBlock)notifierBarClickBlock{
	_notifierBarClickBlock = [notifierBarClickBlock copy];
}

- (void)show:(NSString*)note name:(NSString*)name icon:(UIImage*)icon dismiss:(NSTimeInterval)delay{
	self.nameLabel.text = name;
	self.detailLabel.text = note;
	self.iconView.image = icon;
	self.detailLabel.autoHeight = UIEdgeInsetsZero;
	self.height = self.detailLabel.bottom + 7*SCREEN_SCALE;
	if (delay<0) delay = JKN_DISMISS_TIME;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
		dispatch_async(dispatch_get_main_queue(), ^{
			NSNotification *notification = [NSNotification notificationWithName:JKNotifierBarDismiss object:nil userInfo:@{@"notifierBar":self}];
			[[NSNotificationCenter defaultCenter] postNotification:notification];
		});
	});
}

@end
