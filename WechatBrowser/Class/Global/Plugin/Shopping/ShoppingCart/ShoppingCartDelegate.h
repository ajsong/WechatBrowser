//
//  ShoppingCartDelegate.h
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ShoppingCart, ShoppingCellModel;

@protocol ShoppingCartDelegate<NSObject>
@optional
- (void)ShoppingCart:(ShoppingCart*)shoppingCart deleteWithModel:(ShoppingCellModel *)model shoppingItems:(NSArray *)shoppingItems; //逐行删除
- (void)ShoppingCart:(ShoppingCart*)shoppingCart selectedShopWithModel:(ShoppingModel *)model; //选中店铺(执行自定义操作,不是选中)
- (void)ShoppingCart:(ShoppingCart*)shoppingCart selectedWithModel:(ShoppingCellModel *)model; //选中商品
@end
