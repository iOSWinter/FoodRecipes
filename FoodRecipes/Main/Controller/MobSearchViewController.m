//
//  MobSearchViewController.m
//  FoodRecipes
//
//  Created by WinterChen on 16/8/22.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobSearchViewController.h"
#import "MobFoodDetailViewController.h"
#import "MobFoodListCell.h"
#import "MJRefresh.h"

@interface MobSearchViewController () <UITextFieldDelegate, CSBBannerViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *recordDataArray;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UITextField *search;
@property (nonatomic, strong) NSString *recordFilePath;
@property (nonatomic, assign) BOOL searchResult;
@property (nonatomic, strong) NSString *lastString;
@property (nonatomic, strong) NSMutableArray *lastDataArray;
@property (nonatomic, assign) BOOL didShow;
@property (nonatomic, assign) BOOL shouldHide;
@property (nonatomic, strong) UIView *headerView;

@end

@implementation MobSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"searchRecord"];
    [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
    self.recordFilePath = [docDir stringByAppendingPathComponent:@"record.dat"];
    self.recordDataArray = [NSMutableArray arrayWithContentsOfFile:self.recordFilePath];
    self.recordDataArray = self.recordDataArray ?: [NSMutableArray array];
    [self showRecord];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    headerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    UITextField *search = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, headerView.frame.size.width - 80, 30)];
    search.borderStyle = UITextBorderStyleRoundedRect;
    search.clearButtonMode = UITextFieldViewModeWhileEditing;
    search.placeholder = @"请输入查询内容";
    search.text = self.search.text;
    search.font = [UIFont boldSystemFontOfSize:15];
    search.textColor = [UIColor colorWithRed:255 / 255.0 green:148 /255.0 blue:116 / 255.0 alpha:1];
    search.returnKeyType = UIReturnKeySearch;
    search.delegate = self;
    [headerView addSubview:search];
    _search = search;
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    searchButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 65, 0, 65, 50);
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    searchButton.tintColor = [UIColor orangeColor];
    [searchButton addTarget:self action:@selector(searchFoodRecipes) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:searchButton];
    CSBBannerView *banner = [[CSBBannerView alloc] initWithFrame:CGRectMake(0, search.y + search.height + 10, Width, 50)];
    banner.delegate = self;
    [banner loadAd];
    [headerView addSubview:banner];
    _headerView = headerView;
    self.tableView.tableHeaderView = headerView;
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.center = self.view.center;
    self.indicatorView.color = [UIColor grayColor];
    [self.view addSubview:self.indicatorView];
}
// banner的代理
- (void)csbBannerViewShowFailure:(NSString *)errorMsg
{
    self.shouldHide = YES;
    if (self.didShow == YES) {
        self.didShow = NO;
        self.headerView.height = 50;
        self.tableView.tableHeaderView = self.headerView;
    }
}
- (void)csbBannerViewShowSuccess
{
    self.shouldHide = NO;
    if (self.didShow == NO) {
        self.didShow = YES;
        self.headerView.height = 100;
        self.tableView.tableHeaderView = self.headerView;
    }
}
- (void)csbBannerViewRemoved
{
    if (self.didShow && self.shouldHide == YES) {
        self.didShow = NO;
        self.headerView.height = 50;
        self.tableView.tableHeaderView = self.headerView;
    }
}

- (void)searchFoodRecipes
{
    [self.view endEditing:YES];
    if (self.dataArray.count == 0) {
        [self.indicatorView startAnimating];
    }
    NSInteger pageMod = self.dataArray.count % 20;
    if (pageMod != 0) {
        [self.tableView.mj_footer endRefreshing];
        [FAFProgressHUD showError:@"没有更多数据" icon:nil color:nil];
        return;
    }
    [MobAPI sendRequestWithInterface:@"/v1/cook/menu/search" param:@{@"key" : APPKey, @"name" : self.search.text ?: self.search.placeholder, @"page" : @(self.dataArray.count / 20 + 1)} onResult:^(MOBAResponse *response) {
        [self.tableView.mj_footer endRefreshing];
        if (self.indicatorView) {
            [self.indicatorView stopAnimating];
        }
        if (response.error) {
            [FAFProgressHUD showError:@"查询不到数据" icon:nil color:nil];
            [self.tableView reloadData];
        } else {
            if (self.tableView.mj_footer == nil) {
                self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(searchFoodRecipes)];
            }
            self.searchResult = YES;
            [self.tableView registerNib:[UINib nibWithNibName:@"MobFoodListCell" bundle:nil] forCellReuseIdentifier:@"searchListCell"];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView.rowHeight = 97;
            if ([self.recordDataArray containsObject:self.search.text]) {
                [self.recordDataArray removeObject:self.search.text];
            }
            [self.recordDataArray insertObject:self.search.text atIndex:0];
            // 320*480 320*568 375*667 414*736
            if (self.search.text.length > 0) {
                NSInteger recordCount = (NSInteger)(([UIScreen mainScreen].bounds.size.height - 50 - 64) / 44);
                [self.recordDataArray.count > recordCount ? [self.recordDataArray subarrayWithRange:NSMakeRange(0, recordCount - 1)] : self.recordDataArray writeToFile:self.recordFilePath atomically:YES];
            }
            
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
            [self.dataArray addObjectsFromArray:model.list];
            [self.tableView reloadData];
            _lastString = self.search.text;
            _lastDataArray = [NSMutableArray arrayWithArray:self.dataArray];
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResult ? self.dataArray.count : self.recordDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchResult) {
        MobFoodListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchListCell"];
        
        [cell setupData:self.dataArray[indexPath.row]];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recordCell"];
        
        cell.textLabel.text = self.recordDataArray[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.searchResult) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
        MobFoodDetailViewController *vc = [[MobFoodDetailViewController alloc] init];
        MobFoodClassItemModel *model = self.dataArray[indexPath.row];
        vc.title = model.name;
        vc.model = model;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSString *searchKey = self.recordDataArray[indexPath.row];
        self.search.text = searchKey;
        [self searchFoodRecipes];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length == 1 && [string isEqualToString:@""]) {
        [self showRecord];
    }
    [self.dataArray removeAllObjects];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self showRecord];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchFoodRecipes];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:_lastString]) {
        self.dataArray = _lastDataArray;
    }
}

- (void)showRecord
{
    [self.dataArray removeAllObjects];
    [self.tableView.mj_footer removeFromSuperview];
    self.tableView.mj_footer = nil;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"recordCell"];
    self.tableView.rowHeight = 44;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.searchResult = NO;
    [self.tableView reloadData];
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
