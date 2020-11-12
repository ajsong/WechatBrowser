//
//  AJRatingView.h
//
//  Created by ajsong on 15/11/6.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AJRatingView;

@protocol AJRatingDelegate<NSObject>
@optional
- (void)AJRatingView:(AJRatingView*)ratingView score:(CGFloat)score;
@end

typedef enum : NSInteger {
	AJRatingViewTypeInteger = 0,
	AJRatingViewTypeFloat,
} AJRatingViewType;

@interface AJRatingView : UIView
@property (nonatomic,retain) id<AJRatingDelegate> delegate;
@property (nonatomic,assign) AJRatingViewType type; //类型, 整颗星或半颗星
@property (nonatomic,assign) CGFloat min; //最小数值
@property (nonatomic,assign) CGFloat max; //最大数值
@property (nonatomic,assign) CGFloat score; //当前分数
@property (nonatomic,assign) CGFloat distance; //星星间隙
@property (nonatomic,assign) NSInteger count; //星星数量
@property (nonatomic,assign) CGSize size; //星星大小
@property (nonatomic,retain) UIImage *image; //星星默认图
@property (nonatomic,retain) UIImage *selectedImage; //星星已选图
@property (nonatomic,assign) BOOL change; //可否改变星星
@end
