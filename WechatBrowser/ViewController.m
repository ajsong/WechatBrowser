//
//  ViewController.m
//  WechatBrowser
//
//  Created by ajsong on 2019/7/2.
//  Copyright © 2019 @MARIO. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>{
	NSArray *_ms;
	UISearchBar *_searchBar;
	NSString *_curUrl;
}
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	_curUrl = @"";
	_ms = @[@"重新加载", @"后退一页", @"前进一页", @"复制URL", @"复制HTML", @"运行DEBUG"];
	[self setHtml:@"<!doctype html><html style=\"font-size:100px;\"><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=320,minimum-scale=1.0,maximum-scale=1.0,initial-scale=1.0,user-scalable=no\"><style>html,body{margin:0;padding:0;height:100%;background:#fff;}body>#container{width:100%;height:100%;background:url(logo@2x.png) no-repeat center center;background-size:1.2rem 1.2rem;}</style></head><body><div id='container'></div></body></html>" baseURL:[NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath]];
	
	_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 274*SCREEN_SCALE, 34)];
	_searchBar.backgroundColor = COLORRGB(@"e2e2e2");
	_searchBar.layer.masksToBounds = YES;
	_searchBar.layer.cornerRadius = _searchBar.height/2;
	_searchBar.tintColor = COLOR_SYSTEM_BLUE;
	_searchBar.placeholder = @"在百度中搜索，或者输入一个网址";
	_searchBar.searchBarStyle = UISearchBarStyleDefault;
	[_searchBar setImage:IMG(@"search") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
	_searchBar.delegate = self;
	_searchBar.returnKeyType = UIReturnKeyGo;
	if (@available(iOS 13.0, *)) {
		UITextField *searchField = _searchBar.searchTextField;
		searchField.font = [UIFont systemFontOfSize:13];
		searchField.backgroundColor = COLORCLEAR;
	} else {
		// Fallback on earlier versions
	}
	//searchField.textColor = COLORWHITE;
	//UIButton *clearButton = [searchField valueForKey:@"_clearButton"];
	//[clearButton addTarget:self action:^(id target, id sender) {
	//	[self backgroundTap];
	//	[_searchBar becomeFirstResponder];
	//}];
	[[_searchBar.subviews[0]subviews][0] removeFromSuperview];
	[self.navigationItem setItemWithCustomView:_searchBar itemType:KKNavigationItemTypeCenter];
	
	KKNavigationBarItem *item = [self.navigationItem setItemWithImage:[IMG(@"more") overlayWithColor:COLOR444] size:CGSizeMake(44, 44) itemType:KKNavigationItemTypeRight];
	[item addTarget:self action:^(id target, id sender) {
		[self showMenu];
	}];
}

- (void)OutletDidFinishLoad:(NSString *)url html:(NSString *)html{
	if ([url hasPrefix:@"file://"]) return;
	if ([url hasPrefix:@"https://"]) {
		[_searchBar setImage:IMG(@"ssl") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
	} else {
		[_searchBar setImage:IMG(@"search") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
	}
	_searchBar.text = url;
	_curUrl = url;
}


- (void)backgroundTap{
	[_searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	[self dismissActionView];
	if (@available(iOS 13.0, *)) {
		UITextField *searchField = searchBar.searchTextField;
		[searchField performSelector:@selector(selectAll:) withObject:nil afterDelay:0];
	} else {
		// Fallback on earlier versions
	}
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[self backgroundTap];
	NSString *url = searchBar.text;
	if (![url preg_test:@"^https?:"] && [url preg_test:@"^[\\w-_]+(\\.[\\w-_]+)+([\\w-.,@?^=%&:/~+#]*[\\w-@?^=%&/~+#])?$"]) url = FORMAT(@"http://%@", url);
	if (![url preg_test:@"^https?:"]) url = FORMAT(@"https://www.baidu.com/s?wd=%@", url);
	self.url = url;
}

- (void)showMenu{
	UIView *view = [self.view viewWithTag:PRESENT_ACTION_TAG];
	if (view) {
		if (view.isHidden) {
			[self presentActionView:view always:YES inView:self.view direction:DYActionViewRight closing:nil closeCompletion:nil];
		} else {
			[self dismissActionView];
		}
		return;
	}
	
	view = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/7*3, self.view.height)];
	view.backgroundColor = COLORWHITE;
	
	UITableView *tableView = [[UITableView alloc]initWithFrame:view.bounds];
	tableView.separatorColor = COLOR_GE_LIGHT;
	tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
	tableView.backgroundColor = [UIColor clearColor];
	tableView.estimatedRowHeight = 0;
	tableView.estimatedSectionHeaderHeight = 0;
	tableView.estimatedSectionFooterHeight = 0;
	tableView.dataSource = self;
	tableView.delegate = self;
	[view addSubview:tableView];
	
	[self presentActionView:view always:YES inView:self.view direction:DYActionViewRight closing:nil closeCompletion:nil];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return _ms.count;
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 44*SCREEN_SCALE;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	//NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	for (UIView *subview in cell.contentView.subviews) {
		[subview removeFromSuperview];
	}
	
	UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 44*SCREEN_SCALE)];
	[cell.contentView addSubview:view];
	
	UIImageView *ico = [[UIImageView alloc]initWithFrame:CGRectMake(5*SCREEN_SCALE, (view.height-24*SCREEN_SCALE)/2, 24*SCREEN_SCALE, 24*SCREEN_SCALE)];
	ico.image = [UIImage imageNamed:FORMAT(@"ico%02ld", (long)row+1)];
	[view addSubview:ico];
	
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(ico.right+5*SCREEN_SCALE, 0, view.width-(ico.right+5*SCREEN_SCALE), view.height)];
	label.text = _ms[row];
	label.textColor = COLORTEXT;
	label.font = FONT(11);
	label.backgroundColor = [UIColor clearColor];
	[view addSubview:label];
	
	return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	//NSInteger section = indexPath.section;
	[self dismissActionView];
	if (!self.url.length) return;
	NSInteger row = indexPath.row;
	switch (row) {
		case 0:{
			[self reload];
			break;
		}
		case 1:{
			if (self.webView.canGoBack) {
				[self.webView goBack];
			}
			break;
		}
		case 2:{
			if (self.webView.canGoForward) {
				[self.webView goForward];
			}
			break;
		}
		case 3:{
			[Global copyString:_curUrl];
			[ProgressHUD showSuccess:@"复制成功"];
			break;
		}
		case 4:{
			[Global copyString:self.getHtml];
			[ProgressHUD showSuccess:@"复制成功"];
			break;
		}
		case 5:{
			//	NSString *path = [[NSBundle mainBundle]pathForResource:@"vconsole.min.js" ofType:nil];
			//	NSString *filename = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
			//	WKUserScript *script = [[WKUserScript alloc] initWithSource:filename injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
			//	[UserContentController addUserScript:script];
			NSString *jsPath = [[NSBundle mainBundle]pathForResource:@"vconsole.min" ofType:@"js"];
			NSData *jsData = [NSData dataWithContentsOfFile:jsPath];
			NSString *jsString = [[NSString alloc]initWithData:jsData encoding:NSUTF8StringEncoding];
			[self javascript:jsString completion:^(id obj, NSError *error) {
				if (error) {
					[ProgressHUD showError:@"网站无法注入VConsole"];
					NSLog(@"%@", error);
				}
			}];
			break;
		}
	}
}

@end
