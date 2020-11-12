//
//  GlobalDelegate.h
//
//  Created by ajsong on 15/11/23.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GlobalDelegate<NSObject>
@optional
- (void)GlobalDelegateWithString:(NSString*)string;
- (void)GlobalDelegateWithData:(NSDictionary*)data;
- (void)GlobalDelegateWithData:(NSDictionary*)data caller:(UIViewController*)caller;
- (void)GlobalDelegateWithData:(NSDictionary*)data tag:(NSInteger)tag;
- (void)GlobalDelegateWithDatas:(NSArray*)datas;
- (NSString*)GlobalDelegateReturnStringWithData:(NSDictionary*)data;
@end

/*
@property (nonatomic,weak) id<GlobalDelegate> delegate;
*/
