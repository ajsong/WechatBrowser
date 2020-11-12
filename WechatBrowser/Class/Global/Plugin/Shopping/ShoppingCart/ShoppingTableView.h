//
//  ShoppingTableView.h
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoppingTableViewCell.h"

@interface ShoppingTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray *shoppingArray;
@property (nonatomic,strong) UIView *emptyView;
@property (nonatomic,assign) BOOL hiddenEdit;
@property (nonatomic,assign) BOOL hiddenSubtotal;
@property (nonatomic,assign) CGSize boxSize;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIImage *selectedImage;
@property (nonatomic,strong) NSString *discountTip;
@property (nonatomic,strong) NSString *discountText;
@property (nonatomic,strong) UIColor *discountBackgroundColor;
@property (nonatomic,strong) UIColor *btnColor;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) UIFont *font;
@property (nonatomic,strong) UIColor *specTextColor;
@property (nonatomic,strong) UIFont *specFont;
@property (nonatomic,assign) CGFloat separatorHeight;
@property (nonatomic,weak) id<ShoppingCartDelegate> shoppingCartDelegate;
- (void)allBtn:(BOOL)isbool;
- (void)editBtn:(BOOL)isbool;
- (void)deleteBtn:(BOOL)isbool;
@end
