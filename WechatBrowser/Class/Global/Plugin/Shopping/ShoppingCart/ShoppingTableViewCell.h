//
//  ShoppingTableViewCell.h
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoppingModel.h"
#import "ShoppingCartDelegate.h"

@protocol ShoppingTableViewCellDelegate <NSObject>
- (void)ShoppingTableViewCell:(ShoppingCellModel *)model;
@end

@interface ShoppingTableViewCell : UITableViewCell
@property (nonatomic,weak) id<ShoppingTableViewCellDelegate> delegate;
@property (nonatomic,strong) ShoppingCellModel *model;
@property (nonatomic,assign) CGSize boxSize;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIImage *selectedImage;
@property (nonatomic,strong) NSString *discountText;
@property (nonatomic,strong) UIColor *discountBackgroundColor;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) UIFont *font;
@property (nonatomic,strong) UIColor *specTextColor;
@property (nonatomic,strong) UIFont *specFont;
@property (nonatomic,weak) id<ShoppingCartDelegate> shoppingCartDelegate;
@end

@interface ShoppingCheckbox : UIButton
@end
