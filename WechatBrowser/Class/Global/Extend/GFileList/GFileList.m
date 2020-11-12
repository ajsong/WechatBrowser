//
//  GFileList.m
//
//  Created by ajsong on 15/6/30.
//  Copyright (c) 2014 @jsong. All rights reserved.
//

#import "GFileList.h"
#import "GFileContent.h"
#import "GFileFont.h"

@interface GFileList ()<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray *_ms;
	UITableView *_tableView;
	NSString *_path;
	NSMutableArray *_images;
}
@end

@implementation GFileList

- (instancetype)initWithFolderPath:(NSString*)folderPath{
	self = [super init];
	if (self) {
		_folderPath = folderPath;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self getFiles];
	
	if (![_path isEqualToString:[[Global getTmp]trim:@"tmp/"]]) {
		UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44+24, 44)];
		UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
		btn.titleLabel.font = FONT(14);
		btn.backgroundColor = [UIColor clearColor];
		btn.adjustsImageWhenHighlighted = NO;
		[btn setBackgroundImage:[IMG(@"return")overlayWithColor:COLORNAVTEXT] forState:UIControlStateNormal];
		[btn addTarget:self action:^(id target, id sender) {
			[[target navigationController] popViewControllerAnimated:YES];
		}];
		[itemView addSubview:btn];
		UIImageView *cross = [[UIImageView alloc]initWithFrame:CGRectMake(btn.right, 0, 24, 44)];
		cross.image = [IMG(@"cross")overlayWithColor:COLORNAVTEXT];
		cross.clipsToBounds = YES;
		cross.contentMode = UIViewContentModeScaleAspectFill;
		[itemView addSubview:cross];
		[cross clickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
			UIViewController *viewController = nil;
			for (NSInteger i=[target navigationController].viewControllers.count-2; i>=0; i--) {
				if (![[target navigationController].viewControllers[i] isKindOfClass:[GFileList class]]) {
					viewController = [target navigationController].viewControllers[i];
					break;
				}
			}
			[[target navigationController] popToViewController:viewController animated:YES];
		}];
		[self.navigationItem setItemWithCustomView:itemView itemType:KKNavigationItemTypeLeft];
		
		KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"清空" textColor:COLORNAVTEXT fontSize:14 itemType:KKNavigationItemTypeRight];
		[item addTarget:self action:^(id target, id sender) {
			if (_ms.isArray) {
				[UIAlertController alert:@"确定全部清空吗？" submit:@"确定" block:^(NSInteger buttonIndex) {
					if (buttonIndex==1) {
						for (int row=0; row<_ms.count; row++) {
							NSString *path = [_path stringByAppendingPathComponent:_ms[row]];
							if ([Global folderExist:path]) {
								[Global deleteDir:path killme:YES];
							} else {
								[Global deleteFile:path];
							}
						}
						[_ms removeAllObjects];
						_ms = [[NSMutableArray alloc]init];
						[_tableView reloadData];
					}
				}];
			}
		}];
	} else {
		KKNavigationBarItem *item = [self.navigationItem setItemWithImage:[IMG(@"more")overlayWithColor:COLORNAVTEXT] size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeRight];
		NSMutableArray *actions = [[NSMutableArray alloc]init];
		YCMenuAction *action = [YCMenuAction actionWithTitle:@"退出登录" image:nil handler:^(YCMenuAction *action) {
			[@"person" deleteUserDefaults];
			[ProgressHUD showSuccess:@"成功退出登录"];
		}];
		[actions addObject:action];
		action = [YCMenuAction actionWithTitle:@"本地字体" image:nil handler:^(YCMenuAction *action) {
			GFileFont *e = [[GFileFont alloc]init];
			[self.navigationController pushViewController:e animated:YES];
		}];
		[actions addObject:action];
		NSInteger byte = [Global getCachesSize];
		action = [YCMenuAction actionWithTitle:FORMAT(@"清除缓存(%@)", [Global formatSize:byte unit:nil]) image:nil handler:^(YCMenuAction *action) {
			[Global removeDiskCache];
			[ProgressHUD showSuccess:@"清除成功"];
		}];
		[actions addObject:action];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
			dispatch_async(dispatch_get_main_queue(), ^{
				YCMenuView *menuView = [YCMenuView menuWithActions:actions width:140*SCREEN_SCALE relyonView:item.barButtonItem];
				menuView.font = FONT(13);
				[item addTarget:self action:^(id target, id sender) {
					[menuView show];
				}];
			});
		});
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (!self.title.length) self.title = @"列表";
	self.view.backgroundColor = COLORBACK;
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	_ms = [[NSMutableArray alloc]init];
	_images = [[NSMutableArray alloc]init];
	if (!_folderPath) _folderPath = @"tmp";
	
	_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height) style:UITableViewStyleGrouped];
	_tableView.estimatedSectionHeaderHeight = 0;
	_tableView.estimatedSectionFooterHeight = 0;
	_tableView.backgroundColor = [UIColor clearColor];
	_tableView.separatorColor = COLOR_GE_LIGHT;
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[_tableView addHeaderWithTarget:self action:@selector(getFiles)];
	[self.view addSubview:_tableView];
}

- (void)getFiles{
	[_ms removeAllObjects];
	_ms = [[NSMutableArray alloc]init];
	NSMutableArray *ms = nil;
	NSArray *pathArr = @[@"document", @"tmp", @"caches"];
	NSInteger index = [pathArr indexOfObject:_folderPath];
	switch (index) {
		case 0:{
			ms = [NSMutableArray arrayWithArray:[Global getFileListFromDocument]];
			_path = [Global getDocument];
			break;
		}
		case 1:{
			ms = [NSMutableArray arrayWithArray:[Global getFileListFromTmp]];
			_path = [Global getTmp];
			break;
		}
		case 2:{
			ms = [NSMutableArray arrayWithArray:[Global getFileListFromCaches]];
			_path = [Global getCaches];
			break;
		}
		default:{
			ms = [NSMutableArray arrayWithArray:[Global getFileList:_folderPath]];
			_path = _folderPath;
			break;
		}
	}
	NSMutableArray *folder = [[NSMutableArray alloc]init];
	NSMutableArray *file = [[NSMutableArray alloc]init];
	for (int row=0; row<ms.count; row++) {
		NSString *path = [_path stringByAppendingPathComponent:ms[row]];
		if ([Global folderExist:path]) {
			[folder addObject:ms[row]];
		} else {
			[file addObject:ms[row]];
		}
	}
	for (int i=0; i<folder.count; i++) {
		[_ms addObject:folder[i]];
	}
	for (int i=0; i<file.count; i++) {
		[_ms addObject:file[i]];
	}
	//NSLog(@"%@", _ms);
	[_tableView reloadData];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return !_ms.isArray ? 1 : _ms.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return tableView.height;
	return 50*SCREEN_SCALE;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 0.00001;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
		[cell setSeparatorInset:UIEdgeInsetsMake(0, 14*SCREEN_SCALE, 0, 0)];
	}
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
	if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
		[cell setPreservesSuperviewLayoutMargins:NO];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}
	cell.textLabel.text = nil;
	cell.detailTextLabel.text = nil;
	cell.imageView.image = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.font = FONT(14);
	cell.detailTextLabel.font = FONT(13);
	cell.detailTextLabel.textColor = COLOR999;
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if (!_ms) return cell;
	if (_ms.count<=0) {
		for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.width, tableView.height)];
		label.text = @"没有任何文件(夹)";
		label.textColor = COLOR999;
		label.textAlignment = NSTextAlignmentCenter;
		label.font = FONT(14);
		label.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:label];
		return cell;
	}
	if (_ms.count<=row) return cell;
	for (UIView *subview in cell.contentView.subviews) {
		[subview removeFromSuperview];
	}
	
	cell.backgroundColor = [UIColor whiteColor];
	cell.textLabel.text = _ms[row];
	NSString *path = [_path stringByAppendingPathComponent:_ms[row]];
	if ([Global folderExist:path]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[_images addObject:[NSNull null]];
	} else {
		NSData *data = [Global getFileData:path];
		if ([data isImage]) {
			UIImage *image = [UIImage imageWithData:data];
			image = [image fitToSize:CGSizeMake(80*SCREEN_SCALE, 80*SCREEN_SCALE)];
			cell.imageView.image = image;
			if ([data isGIF]) {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
					dispatch_async(dispatch_get_main_queue(), ^{
						GIFImageView *imageView = [[GIFImageView alloc]initWithFrame:cell.imageView.bounds];
						imageView.image = [GIFImage imageWithData:data];
						[cell.imageView addSubview:imageView];
						cell.imageView.image = nil;
					});
				});
			}
			cell.detailTextLabel.text = FORMAT(@"%@(%@)", [Global formatSize:[Global fileSize:path] unit:nil], data.suffix);
			[_images addObject:cell.imageView];
		} else {
			cell.detailTextLabel.text = FORMAT(@"%@(%@)", [Global formatSize:[Global fileSize:path] unit:nil], [path getSuffix]);
			[_images addObject:[NSNull null]];
		}
	}
	
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return;
	NSInteger row = indexPath.row;
	NSString *path = [_path stringByAppendingPathComponent:_ms[row]];
	if ([Global folderExist:path]) {
		GFileList *e = [[GFileList alloc]init];
		e.title = _ms[row];
		e.folderPath = path;
		[self.navigationController pushViewController:e animated:YES];
	} else {
		NSData *data = [Global getFileData:path];
		if ([data isImage]) {
			MJPhotos *photo = [[MJPhotos alloc] init];
			photo.srcImageView = _images[row];
			photo.image = [GIFImage imageWithData:data];
			photo.title = _ms[row];
			
			MJPhotosBrowser *browser = [[MJPhotosBrowser alloc]init];
			browser.photos = @[photo];
			browser.showInfo = YES;
			[browser show];
		} else {
			GFileContent *e = [[GFileContent alloc]init];
			e.title = _ms[row];
			e.filePath = path;
			[self.navigationController pushViewController:e animated:YES];
		}
	}
}

#pragma mark - TableView Cell Delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	if (!_ms.isArray) return NO;
	NSString *root = [[Global getTmp]trim:@"tmp/"];
	NSString *path = [_path stringByAppendingPathComponent:_ms[indexPath.row]];
	if ([path isEqualToString:[root stringByAppendingPathComponent:@"Documents/"]] ||
		 [path isEqualToString:[root stringByAppendingPathComponent:@"Library/"]] ||
		 [path isEqualToString:[root stringByAppendingPathComponent:@"tmp/"]]) {
		return NO;
	}
	return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView setEditing:NO animated:YES];
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
		//NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		NSString *path = [_path stringByAppendingPathComponent:_ms[row]];
		if ([Global folderExist:path]) {
			[Global deleteDir:path killme:YES];
		} else {
			[Global deleteFile:path];
		}
		[_ms removeObjectAtIndex:row];
		if (_ms.count>0) {
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
		} else {
			[tableView reloadData];
		}
	}];
	//deleteAction.backgroundColor = COLORRGB(@"f5475e");
	
	return @[deleteAction];
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
	UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
		//NSInteger section = indexPath.section;
		NSInteger row = indexPath.row;
		NSString *path = [_path stringByAppendingPathComponent:_ms[row]];
		if ([Global folderExist:path]) {
			[Global deleteDir:path killme:YES];
		} else {
			[Global deleteFile:path];
		}
		[_ms removeObjectAtIndex:row];
		if (_ms.count>0) {
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
		} else {
			[tableView reloadData];
		}
		completionHandler (YES);
	}];
	//deleteAction.backgroundColor = _btnColor ? _btnColor : SHOPPING_BUTTON_COLOR;
	UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
	return config;
}
#endif

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) {
		self.view = nil;
	}
}

@end
