//
//  ShoppingTableView.h
//
//  Created by ajsong on 2016-5-11.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import "ShoppingCart.h"

@interface ShoppingTableView ()<ShoppingTableViewCellDelegate>{
	NSMutableArray *_dataArray;
}
@end

@implementation ShoppingTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
	self = [super initWithFrame:frame style:style];
	if (self) {
		if (style!=UITableViewStyleGrouped) self.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
		self.backgroundColor = [UIColor clearColor];
		self.separatorColor = SHOPPING_SEPARATOR_COLOR;
		self.delegate = self;
		self.dataSource = self;
		_dataArray = [[NSMutableArray alloc]init];
		_boxSize = CGSizeMakeScale(@44, @44);
	}
	return self;
}

- (void)setFrame:(CGRect)frame{
	[super setFrame:frame];
	UIView *view = [self viewWithTag:511];
	if (view) {
		UIFont *font = FONT(13);
		CGFloat height = 150*SCREEN_SCALE + font.lineHeight;
		view.top = (frame.size.height-height)/2-50*SCREEN_SCALE;
	}
}

- (void)setShoppingArray:(NSMutableArray *)shoppingArray{
	_shoppingArray = shoppingArray;
	_dataArray = [_shoppingArray copy];
	[self reloadData];
	
	NSDictionary *d = @{
						@"cellModel":[NSArray array],
						@"allPrice":@"0",
						@"num":@"0",
						@"allState":@"NO"
						};
	NSNotification *notification = [NSNotification notificationWithName:ShoppingCartAllPrice object:nil userInfo:d];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return !_shoppingArray.isArray ? 1 : _shoppingArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (!_shoppingArray.isArray) return 1;
	ShoppingModel *model = _shoppingArray[section];
	return model.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_shoppingArray.isArray) {
		if (_emptyView) return _emptyView.height<tableView.frame.size.height ? tableView.frame.size.height : _emptyView.height;
		return tableView.frame.size.height;
	}
	return (15+70+15)*SCREEN_SCALE;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
		[cell setSeparatorInset:UIEdgeInsetsZero];
	}
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
	if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
		[cell setPreservesSuperviewLayoutMargins:NO];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (!_shoppingArray.isArray) return 0.00001;
	ShoppingModel *model = _shoppingArray[section];
	if (model.headerState==1) {
		return 44*SCREEN_SCALE;
	} else {
		return 0.00001;
	}
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (!_shoppingArray.isArray) return nil;
	ShoppingModel *model = _shoppingArray[section];
	if (model.headerState==1) {
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44*SCREEN_SCALE)];
		view.backgroundColor = [UIColor whiteColor];
		view.clipsToBounds = YES;
		view.tag = section;
		[view addGeWithType:GeLineTypeTop color:SHOPPING_SEPARATOR_COLOR];
		
		ShoppingCheckbox *collocationBtn = [[ShoppingCheckbox alloc] initWithFrame:CGRectMake(0, (view.frame.size.height-_boxSize.height)/2, _boxSize.width, _boxSize.height)];
		collocationBtn.selected = model.clickState==1;
		collocationBtn.tag = section;
		collocationBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
		[collocationBtn setImage:_image?_image:IMG(@"checkbox") forState:UIControlStateNormal];
		[collocationBtn setImage:_selectedImage?_selectedImage:IMG(@"checkbox-x") forState:UIControlStateSelected];
		[collocationBtn addTarget:self action:@selector(collocationBtn:) forControlEvents:UIControlEventTouchUpInside];
		[view addSubview:collocationBtn];
		
		if (model.shopName.length) {
			NSString *key = model.shopAvatar;
			UIImageView *avatar = self.element[key];
			if (!avatar) {
				avatar = [[UIImageView alloc]initWithFrame:CGRectMake(_boxSize.width, (view.height-24*SCREEN_SCALE)/2, 24*SCREEN_SCALE, 24*SCREEN_SCALE)];
				avatar.image = IMG(@"avatar");
				avatar.url = model.shopAvatar;
				avatar.layer.borderColor = SHOPPING_SEPARATOR_COLOR.CGColor;
				avatar.layer.borderWidth = 0.5;
				avatar.layer.masksToBounds = YES;
				avatar.layer.cornerRadius = avatar.height/2;
				self.element[key] = avatar;
			}
			[view addSubview:avatar];
			
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(avatar.right+10*SCREEN_SCALE, 0, view.width-(avatar.right+10*SCREEN_SCALE), view.height)];
			label.text = model.shopName;
			label.textColor = [UIColor blackColor];
			label.font = FONT(12);
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
			
			[view clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
				if (_shoppingCartDelegate && [_shoppingCartDelegate respondsToSelector:@selector(ShoppingCart:selectedShopWithModel:)]) {
					[_shoppingCartDelegate ShoppingCart:(ShoppingCart*)_shoppingCartDelegate selectedShopWithModel:model];
				} else {
					collocationBtn.selected = !collocationBtn.selected;
					[target collocationBtn:view];
				}
			}];
		} else {
			CGSize s = [_discountTip autoWidth:FONT(12) height:20*SCREEN_SCALE];
			s.width += 10*SCREEN_SCALE*2;
			if (!_discountTip.length) s.width = 0;
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(44*SCREEN_SCALE, (view.height-20*SCREEN_SCALE)/2, s.width, 20*SCREEN_SCALE)];
			label.backgroundColor = _discountBackgroundColor;
			label.text = _discountTip;
			label.textColor = [UIColor whiteColor];
			label.textAlignment = NSTextAlignmentCenter;
			label.font = FONT(12);
			label.layer.masksToBounds = YES;
			label.layer.cornerRadius = 3;
			label.hidden = _discountTip.length==0;
			[view addSubview:label];
			
			UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.right+6*SCREEN_SCALE, 0, tableView.frame.size.width-(label.right+6*SCREEN_SCALE) , view.height)];
			if (model.infoDict) subLabel.text = model.infoDict[@"headerTitle"]; //优惠说明
			subLabel.textColor = [UIColor grayColor];
			subLabel.font = FONT(11);
			subLabel.hidden = _discountText.length==0;
			[view addSubview:subLabel];
			
			[view clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
				collocationBtn.selected = !collocationBtn.selected;
				[target collocationBtn:view];
			}];
		}
		
		return view;
	}
	
	return nil ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	if (_hiddenSubtotal || !_shoppingArray.isArray) return 0.00001;
	ShoppingModel *model = _shoppingArray[section];
	if (model.headerState==1) {
		return 30*SCREEN_SCALE+_separatorHeight;
	}
	return _separatorHeight>0 ? _separatorHeight : 0.00001;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	if (_hiddenSubtotal || !_shoppingArray.isArray) return nil;
	ShoppingModel *model = _shoppingArray[section];
	if (model.headerState==1) {
		UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30*SCREEN_SCALE+_separatorHeight)];
		
		UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30*SCREEN_SCALE)];
		view.backgroundColor = SHOPPING_GRAY_COLOR;
		[footerView addSubview:view];
		[view addGeWithType:GeLineTypeBottom color:SHOPPING_SEPARATOR_COLOR];
		
		UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_boxSize.width, 0, tableView.frame.size.width-_boxSize.width, view.frame.size.height)];
		if (model.infoDict) {
			priceLabel.text = FORMAT(@"%@%@", model.infoDict[@"footerTitle"], model.infoDict[@"footerMinus"]);
		} else {
			priceLabel.text = @"小计 ￥0.00";
		}
		priceLabel.textColor = SHOPPING_PRICE_COLOR;
		priceLabel.font = FONT(11);
		[view addSubview:priceLabel];
		
		return footerView;
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = !_shoppingArray.isArray ? @"CellNull" : @"Cell";
	ShoppingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[ShoppingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.delegate = self;
		cell.boxSize = _boxSize;
		cell.image = _image;
		cell.selectedImage = _selectedImage;
		cell.discountText = _discountText;
		cell.discountBackgroundColor = _discountBackgroundColor;
		cell.textColor = _textColor;
		cell.font = _font;
		cell.specTextColor = _specTextColor;
		cell.specFont = _specFont;
		cell.shoppingCartDelegate = _shoppingCartDelegate;
	}
	if (_shoppingArray==nil) {
		tableView.contentInset = UIEdgeInsetsZero;
		tableView.scrollEnabled = NO;
		for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		cell.backgroundColor = [UIColor clearColor];
		return cell;
	}
	if (!_shoppingArray.count) {
		tableView.contentInset = UIEdgeInsetsZero;
		tableView.scrollEnabled = NO;
		for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		cell.backgroundColor = [UIColor clearColor];
		
		if (_emptyView) {
			[cell.contentView addSubview:_emptyView];
		} else {
			CGRect frame = (CGRect){.size = tableView.frame.size};
			UIFont *font = FONT(13);
			CGFloat height = 150*SCREEN_SCALE + font.lineHeight;
			
			UIView *view = [[UIView alloc]initWithFrame:CGRectMake((frame.size.width-150*SCREEN_SCALE)/2, (frame.size.height-height)/2-50*SCREEN_SCALE, 150*SCREEN_SCALE, height)];
			view.tag = 511;
			[cell.contentView addSubview:view];
			
			UIImageView *pic = [[UIImageView alloc]initWithFrame:CGRectMakeScale(0, 0, @150, @150)];
			pic.image = IMG(@"shopping-null");
			[view addSubview:pic];
			
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, pic.height, view.width, font.lineHeight)];
			label.text = @"购物车还是空的哦~";
			label.textColor = COLOR333;
			label.textAlignment = NSTextAlignmentCenter;
			label.font = font;
			label.backgroundColor = [UIColor clearColor];
			[view addSubview:label];
		}
		
		return cell;
	}
	
	tableView.scrollEnabled = YES;
	ShoppingModel *model = _shoppingArray[section];
	ShoppingCellModel *cellModel = model.datas[row];
	cellModel.indexPath = indexPath;
	cellModel.section = section;
	cellModel.row = row;
	cell.model = cellModel;
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	return;
}

#pragma mark - TableView Cell Delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_shoppingArray.isArray || !_hiddenEdit) return NO;
	return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView setEditing:NO animated:YES];
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault image:IMG(@"delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
		ShoppingModel *model = _shoppingArray[indexPath.section];
		ShoppingCellModel *cellModel = model.datas[indexPath.row];
		[model.datas removeObjectAtIndex:indexPath.row];
		[self calculationPrice];
		if (!model.datas.isArray) {
			[_shoppingArray removeObjectAtIndex:indexPath.section];
			if (!_shoppingArray.count) {
				NSNotification *notification = [NSNotification notificationWithName:ShoppingCartNonData object:nil userInfo:nil];
				[[NSNotificationCenter defaultCenter] postNotification:notification];
			} else {
				[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
			}
		} else {
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
		}
		if (_shoppingCartDelegate && [_shoppingCartDelegate respondsToSelector:@selector(ShoppingCart:deleteWithModel:shoppingItems:)]) {
			[_shoppingCartDelegate ShoppingCart:(ShoppingCart*)_shoppingCartDelegate deleteWithModel:cellModel shoppingItems:_shoppingArray];
		}
	}];
	deleteAction.backgroundColor = _btnColor ? _btnColor : SHOPPING_BUTTON_COLOR;
	return @[deleteAction];
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
	UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
		ShoppingModel *model = _shoppingArray[indexPath.section];
		ShoppingCellModel *cellModel = model.datas[indexPath.row];
		[model.datas removeObjectAtIndex:indexPath.row];
		[self calculationPrice];
		if (!model.datas.isArray) {
			[_shoppingArray removeObjectAtIndex:indexPath.section];
			if (!_shoppingArray.count) {
				NSNotification *notification = [NSNotification notificationWithName:ShoppingCartNonData object:nil userInfo:nil];
				[[NSNotificationCenter defaultCenter] postNotification:notification];
			} else {
				[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
			}
		} else {
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
		}
		if (_shoppingCartDelegate && [_shoppingCartDelegate respondsToSelector:@selector(ShoppingCart:deleteWithModel:shoppingItems:)]) {
			[_shoppingCartDelegate ShoppingCart:(ShoppingCart*)_shoppingCartDelegate deleteWithModel:cellModel shoppingItems:_shoppingArray];
		}
		completionHandler (YES);
	}];
	deleteAction.image = IMG(@"delete");
	deleteAction.backgroundColor = _btnColor ? _btnColor : SHOPPING_BUTTON_COLOR;
	UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
	return config;
}
#endif

#pragma mark - 单选
- (void)ShoppingTableViewCell:(ShoppingCellModel *)model{
	ShoppingModel *headerModel = _dataArray[model.section];
	int i = 0;
	for (ShoppingCellModel *cellModel in headerModel.datas) {
		if (cellModel.clickState==1) i++;
	}
	if (i == headerModel.datas.count) {
		headerModel.clickState = 1;
	} else {
		headerModel.clickState = 0;
	}
	[self calculationPrice];
	_dataArray = [_shoppingArray copy];
	[self reloadData];
}

#pragma mark - 分组全选
- (void)collocationBtn:(UIView *)sender{
	ShoppingModel *model = _dataArray[sender.tag];
	[self refreshAllCellState:model];
	[self calculationPrice];
	_dataArray = [_shoppingArray copy];
	[self reloadData];
}

#pragma mark - 刷新Cell状态
- (void)refreshAllCellState:(ShoppingModel *)model{
	if (model.clickState == 1) {
		model.clickState = 0;
		for (ShoppingCellModel *cellModel in model.datas) {
			cellModel.clickState = 0;
		}
	} else {
		model.clickState = 1;
		for (ShoppingCellModel *cellModel in model.datas) {
			cellModel.clickState = 1;
		}
	}
}

#pragma mark - 计算价格
- (void)calculationPrice{
	CGFloat totalprice = 0.0; //所有商品的总价
	NSInteger numInteger = 0; //结算处的个数
	NSMutableArray *allClickArray = [[NSMutableArray alloc]init]; //用于判断是否全选
	NSMutableArray *cellModelArray = [[NSMutableArray alloc]init]; //纪录选中的cellModel;
	for (ShoppingModel *model in _shoppingArray) {
		//用于判断是否全选，当该数组个数和_shoppingArray个数一样时，说明选中了全部产品
		if (model.clickState==1) {
			[allClickArray addObject:[NSString stringWithFormat:@"%ld", (long)model.clickState]];
		}
		//纪录每个分组下面的 头部 和 尾部 数据的变化
		NSMutableDictionary *d = [[NSMutableDictionary alloc]init];
		//纪录搭配下面选中的必选Cell，用来和当前该条数据中必选单品做比较，是否讲必选单品都选中，如果都选中了，就会享受搭配折扣，反之不享受，按原价计算
		NSMutableArray *array = [[NSMutableArray alloc]init];
		//每条数据下面的总价
		CGFloat allprice = 0.0;
		for (ShoppingCellModel *cellModel in model.datas) {
			//计算每个cell的总价
			if (cellModel.clickState==1) {
				[cellModelArray addObject:cellModel];
				numInteger += cellModel.quantity;
				allprice += cellModel.quantity * cellModel.price.floatValue;
			}
			//纪录选中的必选单品
			if (cellModel.clickState==1 && cellModel.required==1){
				[array addObject:@(cellModel.goodsId)];
			}
		}
		// “搭配购” 下面必选单品的id 和 当前选中的必选单品 做比较，如果该搭配下面的必选单品都选中后，则享受搭配折扣，同时头部视图和页尾相应的改变状态
		if ([[self rutrnCellModel:model] isEqualToArray:array] && array.count>0) {
			CGFloat oldprice = allprice;
			CGFloat newprice = allprice;
			if (model.discount.floatValue>0) newprice = newprice * model.discount.floatValue * 0.1;
			[d setObject:[NSString stringWithFormat:@"已享受%@折优惠，立减￥%.2f", model.discount, oldprice-newprice] forKey:@"headerTitle"];
			[d setObject:[NSString stringWithFormat:@"小计 ¥%.2f", newprice] forKey:@"footerTitle"];
			if (oldprice-newprice>0) [d setObject:[NSString stringWithFormat:@"　立减 ¥%.2f", oldprice-newprice] forKey:@"footerMinus"];
			allprice = newprice;
		} else {
			//说明单品没有被选中或者没有完全选中
			[d setObject:[NSString stringWithFormat:@"选择所有%@，即可享受%@折优惠", _discountText, model.discount] forKey:@"headerTitle"];
			[d setObject:[NSString stringWithFormat:@"小计 ¥%.2f", allprice] forKey:@"footerTitle"];
			[d setObject:@"" forKey:@"footerMinus"];
		}
		totalprice += allprice;
		model.infoDict = d;
	}
	NSDictionary *d = @{
						@"cellModel":cellModelArray,
						@"allPrice":[NSString stringWithFormat:@"%.2f", totalprice],
						@"num":[NSString stringWithFormat:@"%ld", (long)numInteger],
						@"allState":(allClickArray.count==_shoppingArray.count && _shoppingArray.count>0) ? @"YES" : @"NO"
						};
	NSNotification *notification = [NSNotification notificationWithName:ShoppingCartAllPrice object:nil userInfo:d];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - 返回 “搭配购” 下面必选单品的id，用于和当前选中的必选单品做比较
- (NSArray *)rutrnCellModel:(ShoppingModel *)model{
	NSMutableArray *array = [[NSMutableArray alloc]init];
	for (ShoppingCellModel *cellModel in model.datas) {
		if (cellModel.required == 1) {
			[array addObject:@(cellModel.goodsId)];
		}
	}
	return array;
}

#pragma mark - 全选
- (void)allBtn:(BOOL)isBool{
	if (isBool) {
		for (ShoppingModel *model in _shoppingArray) {
			//选中状态时 model.headClickState = 0; 然后调用 [self refreshAllCellState:model] 改为1
			model.clickState = 0;
			[self refreshAllCellState:model];
		}
	} else {
		for (ShoppingModel *model in _shoppingArray) {
			model.clickState = 1;
			[self refreshAllCellState:model];
		}
	}
	[self calculationPrice];
	_dataArray = [_shoppingArray copy];
	[self reloadData];
}

#pragma mark - 编辑
- (void)editBtn:(BOOL)isBool{
	for (ShoppingModel *model in _shoppingArray) {
		if (!isBool) {
			for (ShoppingCellModel *cellModel in model.datas) {
				cellModel.editState = 1;
			}
		} else {
			for (ShoppingCellModel *cellModel in model.datas) {
				cellModel.editState = 0;
			}
		}
	}
	_dataArray = [_shoppingArray copy];
	[self reloadData];
}

#pragma mark - 删除
- (void)deleteBtn:(BOOL)isBool{
	NSMutableArray *headDeleteArray = [[NSMutableArray alloc]init];
	for (ShoppingModel *model in _shoppingArray) {
		if (model.clickState == 1) {
			[headDeleteArray addObject:model];
		} else {
			NSMutableArray *cellDeleteArray = [[NSMutableArray alloc]init];
			for (ShoppingCellModel *cellModel in model.datas) {
				if (cellModel.clickState == 1) {
					[cellDeleteArray addObject:cellModel];
				}
			}
			NSMutableArray *dataArray = [NSMutableArray arrayWithArray:model.datas];
			for (ShoppingCellModel *cellModel in cellDeleteArray) {
				if ([dataArray containsObject:cellModel]) {
					[dataArray removeObject:cellModel];
				}
			}
			model.datas = dataArray;
		}
	}
	NSMutableArray *shopArray = [NSMutableArray arrayWithArray:_shoppingArray];
	for (ShoppingModel *model in headDeleteArray) {
		if ([shopArray containsObject:model]) {
			[shopArray removeObject:model];
		}
	}
	_shoppingArray = shopArray;
	_dataArray = [_shoppingArray copy];
	[self calculationPrice];
	[self reloadData];
	if (!shopArray.count) {
		self.alpha = 0;
		[UIView animateWithDuration:0.3 animations:^{
			self.alpha = 1;
		}];
	}
}

@end
