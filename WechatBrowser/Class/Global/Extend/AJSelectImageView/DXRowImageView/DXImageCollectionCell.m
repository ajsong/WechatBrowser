//
//  DXImageCollectionCell.m
//  DXImagePickController
//
//  Created by simon on 16/7/1.
//  Copyright © 2016年 DINGXU. All rights reserved.
//

#import "DXImageCollectionCell.h"
#import "DXImagePickModel.h"

#define KCountLabelWidth 27
#define kIndicatorViewWidth 28

@interface DXImageCollectionCell ()
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *seletedButton;
@end

@implementation DXImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
	
    self.imageView = [[UIImageView alloc]init];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.imageView];
	[self.imageView clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
		[target seletedButtonDidSelected:[target seletedButton]];
	}];
	
    self.seletedButton = [[UIButton alloc]init];
    self.seletedButton.bounds = CGRectMake(0, 0, KCountLabelWidth, KCountLabelWidth);
    self.seletedButton.layer.masksToBounds = YES;
    self.seletedButton.titleLabel.font = FONT(12);
    [self.seletedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[self.seletedButton setBackgroundImage:[UIImage imageNamed:@"seleteimage-unselected"] forState:UIControlStateNormal];
	[self.seletedButton setBackgroundImage:[UIImage imageNamed:@"seleteimage-selected"] forState:UIControlStateSelected];
	self.seletedButton.backgroundColor = [UIColor clearColor];
    [self addSubview:self.seletedButton];
    [self.seletedButton addTarget:self action:@selector(seletedButtonDidSelected:) forControlEvents:UIControlEventTouchDown];
	
    return self;
}

- (void)pointSeleteButton:(CGPoint)offset{
    CGPoint rightPoint = CGPointMake(offset.x + [UIScreen mainScreen].bounds.size.width, KCountLabelWidth);
    CGFloat rightPoint_x = offset.x + [UIScreen mainScreen].bounds.size.width;
    if (CGRectContainsPoint(self.frame, rightPoint)) {
        CGPoint newCenter = CGPointMake(rightPoint_x-self.frame.origin.x-KCountLabelWidth*0.5-3*SCREEN_SCALE, KCountLabelWidth*0.5+3*SCREEN_SCALE);
        if (newCenter.x < KCountLabelWidth*0.5+3*SCREEN_SCALE) {
            newCenter = CGPointMake( KCountLabelWidth*0.5+3*SCREEN_SCALE, KCountLabelWidth*0.5+3*SCREEN_SCALE);
        }
        self.seletedButton.center = newCenter;
    } else {
        self.seletedButton.center = CGPointMake(self.frame.size.width-KCountLabelWidth*0.5-3*SCREEN_SCALE, KCountLabelWidth*0.5+3*SCREEN_SCALE);
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

- (void)setModel:(DXImagePickModel *)model{
    _model = model;
    self.imageView.image = model.image;
    [self pointSeleteButton:model.offset];
    if (model.count > 0) {
        self.seletedButton.selected = YES;
        [self.seletedButton setTitle:[NSString stringWithFormat:@"%ld", (long)model.count] forState:UIControlStateSelected];
    } else {
        self.seletedButton.selected = NO;
        [self.seletedButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)seletedButtonDidSelected:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(imageCollectionCell:selectedButtonDidSelected:)]) {
        [self.delegate imageCollectionCell:self selectedButtonDidSelected:button];
    }
}

@end
