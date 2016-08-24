//
//  MobFoodListViewController.m
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobFoodListViewController.h"
#import "MobFoodDetailViewController.h"
#import "MobAdViewController.h"
#import "MobFoodClassModel.h"
#import "MobCarefulSelectionModel.h"
#import "MobFoodListCell.h"
#import "MJRefresh.h"

@interface MobFoodListViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) NSInteger loadMoreCount;
@property (nonatomic, strong) NSString *pageFilePath;

@end

@implementation MobFoodListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MobFoodListCell" bundle:nil] forCellReuseIdentifier:@"listCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 97;
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.center = self.view.center;
    self.indicatorView.color = [UIColor grayColor];
    [self.view addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"pageCaches"];
    [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
    self.pageFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.cid]];
    NSNumber *page = [NSArray arrayWithContentsOfFile:self.pageFilePath].firstObject;
    
    self.page = page ? page.integerValue : 1;
    self.totalPage = 10000;
    [self loadMoreData];
}

- (void)loadMoreData
{
    [self fetchDataWithLoadMore:YES];
}

- (void)fetchDataWithLoadMore:(BOOL)loadMore
{
    NSInteger page;
    if (loadMore) {
        if (self.totalPage != 10000) {
            self.loadMoreCount++;
        }
        page = (self.page + self.loadMoreCount) > self.totalPage ? (self.page + self.loadMoreCount) - self.totalPage : (self.page + self.loadMoreCount);
    } else {
        self.loadMoreCount = 0;
        page = self.page == 1 ? self.totalPage : self.page - 1;
        self.page = page;
        
        [@[@(page)] writeToFile:self.pageFilePath atomically:YES];
    }
    if (self.cid) {
        [MobAPI sendRequestWithInterface:@"/v1/cook/menu/search" param:@{@"key" : APPKey, @"cid" : self.cid , @"page" : @(page)} onResult:^(MOBAResponse *response) {
            [self updateIndicatorView];
            if (response.error) {
                [FAFProgressHUD showError:@"数据加载失败" icon:nil color:nil];
            } else {
                NSInteger totalCount = ((NSNumber *)response.responder[@"total"]).integerValue;
                self.totalPage = (totalCount / 20) + (totalCount % 20 != 0 ? 1 : 0);
                [MobFoodClassModel faf_setupObjectClassInArray:^NSDictionary *{
                    return @{@"list" : @"MobFoodClassItemModel"};
                }];
                [MobFoodClassItemModel faf_setupObjectClassInArray:^NSDictionary *{
                    return @{@"recipe" : @"MobFoodClassItemRecipeModel"};
                }];
                [MobFoodClassItemRecipeModel faf_setupObjectClassInArray:^NSDictionary *{
                    return @{@"method" : @"MobFoodClassItemMethodModel"};
                }];
                MobFoodClassModel *model = [MobFoodClassModel faf_objectWithKeyValues:response.responder];
                if (loadMore) {
                    [self.dataArray addObjectsFromArray:model.list];
                } else {
                    self.dataArray = [NSMutableArray arrayWithArray:model.list];
                }
                [self.tableView reloadData];
            }
        }];
    } else {
        [MobAPI sendRequestWithInterface:@"/wx/article/search" param:@{@"key" : APPKey, @"cid" : @(27), @"page" : @(page)} onResult:^(MOBAResponse *response) {
            [self updateIndicatorView];
            if (response.error) {
                [FAFProgressHUD showError:@"数据加载失败" icon:nil color:nil];
            } else {
                NSInteger totalCount = ((NSNumber *)response.responder[@"result"][@"total"]).integerValue;
                self.totalPage = (totalCount / 20) + (totalCount % 20 != 0 ? 1 : 0);
                [MobCarefulSelectionModel faf_setupReplacedKeyFromPropertyName:^NSDictionary *{
                    return @{@"currentId" : @"id"};
                }];
                NSArray *objectArray = [MobCarefulSelectionModel faf_objectArrayWithKeyValuesArray:response.responder[@"result"][@"list"]];
                if (loadMore) {
                    [self.dataArray addObjectsFromArray:objectArray];
                } else {
                    self.dataArray = [NSMutableArray arrayWithArray:objectArray];
                }
                [self.tableView reloadData];
            }
        }];
    }
}

- (void)updateIndicatorView
{
    if (self.tableView.mj_header == nil) {
        self.tableView.mj_header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchDataWithLoadMore:)];
    }
    if (self.tableView.mj_footer == nil) {
        self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    }
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    if (self.indicatorView) {
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
        self.indicatorView = nil;
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MobFoodListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
    if (cell == nil) {
        cell = [MobFoodListCell mobFoodListCell];
    }
    
    [cell setupData:self.dataArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    if (self.cid) {
        MobFoodDetailViewController *vc = [[MobFoodDetailViewController alloc] init];
        MobFoodClassItemModel *model = self.dataArray[indexPath.row];
        vc.model = model;
        vc.title = model.name;
        vc.cid = model.menuId;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        MobAdViewController *vc = [[MobAdViewController alloc] init];
        vc.link = ((MobCarefulSelectionModel *)self.dataArray[indexPath.row]).sourceUrl;
        vc.title = self.title;
        vc.model = self.dataArray[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
