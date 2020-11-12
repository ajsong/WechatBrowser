//
//  MJPhoto.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "MJPhotos.h"

@implementation MJPhotos

- (instancetype)init{
	self = [super init];
	if (self) {
		self.url = @"";
		self.title = @"";
		self.content = @"";
		self.save = YES;
	}
	return self;
}

@end