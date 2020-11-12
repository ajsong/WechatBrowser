/**
 MJ友情提示：
 1. 添加头部控件的方法
 [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
 或者
 [self.tableView addHeaderWithCallback:^{ }];
 
 2. 添加尾部控件的方法
 [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
 或者
 [self.tableView addFooterWithCallback:^{ }];
 
 3. 可以在MJRefreshConst.h和MJRefreshConst.m文件中自定义显示的文字内容和文字颜色
 
 4. 本框架兼容iOS6\iOS7，iPhone\iPad横竖屏
 
 5.自动进入刷新状态
 1> [self.tableView headerBeginRefreshing];
 2> [self.tableView footerBeginRefreshing];
 
 6.结束刷新
 1> [self.tableView headerEndRefreshing];
 2> [self.tableView footerEndRefreshing];
 
 7.设置箭头与文字(也可以不设置,默认的文字在MJRefreshConst中修改)
 self.tableView.headerArrowImageName = @"blueArrow";
 self.tableView.headerPullToRefreshText = @"下拉就可以刷新啦";
 self.tableView.headerReleaseToRefreshText = @"松开马上刷新了";
 self.tableView.headerRefreshingText = @"正在帮你刷新中,不客气";
 
 self.tableView.footerArrowImageName = @"redArrow";
 self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
 self.tableView.footerReleaseToRefreshText = @"松开马上加载更多数据了";
 self.tableView.footerRefreshingText = @"正在帮你加载中,不客气";
*/
#import "UIScrollView+MJRefresh.h"
#import "MJRefreshConst.h"