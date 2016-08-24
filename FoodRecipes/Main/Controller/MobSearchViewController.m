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

@interface MobSearchViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UITextField *search;

@end

@implementation MobSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MobFoodListCell" bundle:nil] forCellReuseIdentifier:@"searchListCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 97;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    headerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    UITextField *search = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, headerView.frame.size.width - 80, 30)];
    search.borderStyle = UITextBorderStyleRoundedRect;
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
    self.tableView.tableHeaderView = headerView;
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.center = self.view.center;
    self.indicatorView.color = [UIColor grayColor];
    [self.view addSubview:self.indicatorView];
}

- (void)searchFoodRecipes
{
    [self.view endEditing:YES];
    if (self.dataArray.count == 0) {
        [self.indicatorView startAnimating];
        self.tableView.mj_footer = nil;
    }
    NSInteger pageMod = self.dataArray.count % 20;
    if (pageMod != 0) {
        [self.tableView.mj_footer endRefreshing];
        [FAFProgressHUD showError:@"没有更多数据" icon:nil color:nil];
        return;
    }
    [MobAPI sendRequestWithInterface:@"/v1/cook/menu/search" param:@{@"key" : APPKey, @"name" : self.search.text ?: self.search.placeholder, @"page" : @(self.dataArray.count / 20 + 1)} onResult:^(MOBAResponse *response) {
        if (self.tableView.mj_footer == nil) {
            self.tableView.mj_footer = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(searchFoodRecipes)];
        }
        [self.tableView.mj_footer endRefreshing];
        if (self.indicatorView) {
            [self.indicatorView stopAnimating];
        }
        if (response.error) {
            [FAFProgressHUD showError:@"查询不到数据" icon:nil color:nil];
        } else {
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
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MobFoodListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchListCell"];
    
    [cell setupData:self.dataArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];    
    MobFoodDetailViewController *vc = [[MobFoodDetailViewController alloc] init];
    MobFoodClassItemModel *model = self.dataArray[indexPath.row];
    vc.title = model.name;
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.dataArray = nil;
    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchFoodRecipes];
    return YES;
}


- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
