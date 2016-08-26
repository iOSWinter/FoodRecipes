//
//  MobRecommendViewController.m
//  FoodRecipes
//
//  Created by WinterChen on 16/8/25.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobRecommendViewController.h"
#import "MobRecommendModel.h"
#import "MobFoodClassModel.h"
#import "MobFoodListCell.h"

@interface MobRecommendViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation MobRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"推荐管理";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 97;
    [self.tableView registerNib:[UINib nibWithNibName:@"MobFoodListCell" bundle:nil] forCellReuseIdentifier:@"recommendCell"];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.center = self.view.center;
    self.indicatorView.color = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1];
    [self.view addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    [MobAPI sendRequestWithInterface:@"/ucache/getall" param:@{@"key" : APPKey, @"table" : @"recommend", @"page" : @"1", @"size" : @"100"} onResult:^(MOBAResponse *response) {
        if (response.error == nil) {
            [MobRecommendModel faf_setupReplacedKeyFromPropertyName:^NSDictionary *{ return @{@"cid" : @"k"}; }];
            NSArray *recommendArray = [MobRecommendModel faf_objectArrayWithKeyValuesArray:response.responder[@"result"][@"data"]];
            [self fetchRecommendModelWithRecommendListArray:recommendArray];
        }
    }];
}

// 逐条请求推荐数据
- (void)fetchRecommendModelWithRecommendListArray:(NSArray *)listArray
{
    __block NSInteger finishRequestCount = 0;
    for (NSInteger i = 0; i < listArray.count; i++) {
        [self.dataArray addObject:@""];
        MobRecommendModel *recommendModel = listArray[i];
        [MobAPI sendRequestWithInterface:@"/v1/cook/menu/query" param:@{@"key" : APPKey, @"id" : recommendModel.cid} onResult:^(MOBAResponse *response) {
            if (!response.error) {
                MobFoodClassItemModel *model = [self convertRecommendModelWithDictionary:response.responder[@"result"] ];
                if (model) {
                    [self.dataArray replaceObjectAtIndex:i withObject:model];
                }
                finishRequestCount++;
                if (finishRequestCount == listArray.count) {
                    [self.tableView reloadData];
                    [self.indicatorView stopAnimating];
                }
            }
        }];
    }
}

// 推荐列表转模型
- (MobFoodClassItemModel *)convertRecommendModelWithDictionary:(NSDictionary *)dict
{
    [MobFoodClassItemModel faf_setupObjectClassInArray:^NSDictionary *{ return @{@"recipe" : @"MobFoodClassItemRecipeModel"}; }];
    [MobFoodClassItemRecipeModel faf_setupObjectClassInArray:^NSDictionary *{ return @{@"method" : @"MobFoodClassItemMethodModel"}; }];
    MobFoodClassItemModel *model = [MobFoodClassItemModel faf_objectWithKeyValues:dict];
    return model;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MobFoodListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recommendCell" forIndexPath:indexPath];
    
    [cell setupData:self.dataArray[indexPath.row]];
    
    return cell;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak MobRecommendViewController *weakSelf = self;
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.indicatorView startAnimating];
        MobFoodClassItemModel *model = weakSelf.dataArray[indexPath.row];
        [MobAPI sendRequestWithInterface:@"/ucache/del" param:@{@"key" : APPKey, @"table" : @"recommend", @"k" : [weakSelf codeStringWithOriginalString:model.menuId],} onResult:^(MOBAResponse *response) {
            [weakSelf.indicatorView stopAnimating];
            [FAFProgressHUD show:response.error ? @"删除失败" : @"删除成功" icon:nil view:weakSelf.view color:nil];
            if (!response.error) {
                [weakSelf.dataArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }];
    UITableViewRowAction *upper = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.indicatorView startAnimating];
        MobFoodClassItemModel *model = weakSelf.dataArray[indexPath.row];
        [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : APPKey, @"table" : @"recommend", @"k" : [weakSelf codeStringWithOriginalString:model.menuId], @"v" : [weakSelf codeStringWithOriginalString:@"YES"]} onResult:^(MOBAResponse *response) {
            [weakSelf.indicatorView stopAnimating];
            [FAFProgressHUD show:response.error ? @"操作失败" : @"置顶成功" icon:nil view:weakSelf.view color:nil];
            if (!response.error) {
                [weakSelf.dataArray insertObject:weakSelf.dataArray[indexPath.row] atIndex:0];
                [weakSelf.dataArray removeObjectAtIndex:indexPath.row + 1];
                [tableView reloadData];
            }
        }];
    }];
    return @[delete, upper];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Base64编码和解码
- (NSString *)codeStringWithOriginalString:(NSString *)originalString
{
    return [[[[[originalString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"=" withString:@""] stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
