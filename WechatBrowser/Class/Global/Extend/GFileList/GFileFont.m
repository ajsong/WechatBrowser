//
//  GFileFont.m
//
//  Created by ajsong on 2018/7/6.
//  Copyright (c) 2014 @jsong. All rights reserved.
//

#import "GFileFont.h"

@interface GFileFont ()<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray *_ms;
	UITableView *_table;
}
@end

@implementation GFileFont

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"支持字体";
	self.view.backgroundColor = COLORBACK;
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"等宽字体" textColor:COLORNAVTEXT fontSize:14 itemType:KKNavigationItemTypeRight];
	[item.contentBarItem setTitle:@"全部字体" forState:UIControlStateSelected];
	[item addTarget:self action:^(id target, id sender) {
		UIButton *contentBarItem = (UIButton*)sender;
		contentBarItem.selected = !contentBarItem.selected;
		[target findFontName:contentBarItem.selected];
	}];

	[self findFontName:NO];

	_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	_table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	_table.separatorColor = COLOR_GE_LIGHT;
	_table.backgroundColor = [UIColor clearColor];
	_table.estimatedRowHeight = 0;
	_table.estimatedSectionHeaderHeight = 0;
	_table.estimatedSectionFooterHeight = 0;
	_table.dataSource = self;
	_table.delegate = self;
	_table.sectionIndexColor = COLORMAIN;
	[self.view addSubview:_table];
}

- (void)findFontName:(BOOL)monospaced{
	NSString *words = @"ABCabc1234567890";
	NSMutableArray *array = [[NSMutableArray alloc]init];
	for (NSString *familyName in [UIFont familyNames]) {
		NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
		for (NSString *fontName in fontNames) {
			if (monospaced) {
				CGFloat width = -1;
				BOOL found = YES;
				for (int k=0; k<words.length; k++) {
					unichar word = [words characterAtIndex:k];
					CGSize size = [FORMAT(@"%C", word) autoWidth:[UIFont fontWithName:fontName size:16] height:16];
					if (width<0) {
						width = size.width;
					} else if (width!=size.width) {
						found = NO;
						break;
					}
				}
				if (found) {
					[array addObject:FORMAT(@"%s", [fontName UTF8String])];
				}
			} else {
				[array addObject:FORMAT(@"%s", [fontName UTF8String])];
			}
		}
	}
	_ms = [array arrayWithPinYinFirstLetterFormat];
	[_table reloadData];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return _ms.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [_ms[section][@"content"]count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return _ms[section][@"firstLetter"];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	NSString *string = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n字体效果 1234567890";
	CGSize s = [string autoHeight:[UIFont fontWithName:_ms[section][@"content"][row] size:15*SCREEN_SCALE] width:tableView.width-13*SCREEN_SCALE*2];
	return s.height+(8+14+8)*SCREEN_SCALE;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	cell.backgroundColor = [UIColor whiteColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	for (UIView *subview in cell.contentView.subviews) {
		[subview removeFromSuperview];
	}
	
	NSString *fontName = _ms[section][@"content"][row];
	NSString *string = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n字体效果 1234567890";
	CGSize s = [string autoHeight:[UIFont fontWithName:fontName size:15*SCREEN_SCALE] width:tableView.width-13*SCREEN_SCALE*2];
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(13*SCREEN_SCALE, 0, tableView.width-13*SCREEN_SCALE*2, s.height+(8+14+8)*SCREEN_SCALE)];
	view.backgroundColor = COLORWHITE;
	[cell.contentView addSubview:view];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 8*SCREEN_SCALE, view.width, s.height)];
	label.text = string;
	label.textColor = COLOR333;
	label.font = [UIFont fontWithName:fontName size:15*SCREEN_SCALE];
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	[view addSubview:label];
	
	label = [[UILabel alloc]initWithFrame:label.frameBottom];
	label.height = 14*SCREEN_SCALE;
	label.text = fontName;
	label.textColor = COLOR333;
	label.font = FONT(12);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	[Global copyString:_ms[section][@"content"][row]];
	[ProgressHUD showSuccess:@"已复制"];
}
//添加索引栏标题数组
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
	NSMutableArray *array = [[NSMutableArray alloc]init];
	for (NSDictionary *dict in _ms) {
		[array addObject:dict[@"firstLetter"]];
	}
	return array;
}
//点击索引栏标题时执行
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
	return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) {
		self.view = nil;
	}
}

@end
