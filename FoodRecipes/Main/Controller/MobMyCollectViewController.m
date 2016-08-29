//
//  MobMyCollectViewController.m
//  FoodRecipes
//
//  Created by WinterChen on 16/8/23.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobMyCollectViewController.h"
#import "MobFoodDetailViewController.h"
#import "AppDelegate.h"
#import "MobFoodListCell.h"
#import "MobFoodClassModel.h"

@interface MobMyCollectViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation MobMyCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的收藏";
    [self.tableView registerNib:[UINib nibWithNibName:@"MobFoodListCell" bundle:nil] forCellReuseIdentifier:@"collectListCell"];
    self.tableView.rowHeight = 97;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).uid == nil) {
        [FAFProgressHUD showError:@"您还未登录" toView:self.view];
        return;
    }
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.center = self.view.center;
    self.indicatorView.color = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1];
    [self.view addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    [MobAPI sendRequestWithInterface:@"/ucache/get" param:@{@"key" : APPKey, @"table" : @"prefer", @"k" : [self codeStringWithOriginalString:((AppDelegate *)[UIApplication sharedApplication].delegate).uid]} onResult:^(MOBAResponse *response) {
        [self.indicatorView stopAnimating];
        if (!response.error) {
            NSDictionary *dataDict = response.responder[@"result"];
            __block NSString *vString = dataDict[@"v"];
            NSArray *collectArray = [vString componentsSeparatedByString:@","];
            if (collectArray.count == 2) {
                [FAFProgressHUD show:@"您还没有收藏任何美食" icon:nil view:self.view color:nil];
                return;
            }
            __block NSInteger finishRequestCount = 0;
            for (NSInteger i = 0; i < collectArray.count - 2; i++) {
                [self.dataArray addObject:@""];
            }
            for (NSInteger i = 0; i < collectArray.count - 2; i++) {
                NSArray *idArray = [collectArray[i] componentsSeparatedByString:@"/"];
                NSString *menuId = [[@"00100010" stringByAppendingString:idArray.firstObject] stringByAppendingString:[[NSString stringWithFormat:@"%li", (long)(10000000000 + ((NSString *)idArray.lastObject).integerValue)] substringFromIndex:1]];
                [self.indicatorView startAnimating];
                __block BOOL hasError = NO;
                [MobAPI sendRequestWithInterface:@"/v1/cook/menu/query" param:@{@"key" : APPKey, @"id" : menuId} onResult:^(MOBAResponse *response) {
                    if (!response.error) {
                        MobFoodClassItemModel *model = [self convertRecommendModelWithDictionary:response.responder[@"result"] ];
                        if (model) {
                            [self.dataArray replaceObjectAtIndex:i withObject:model];
                        }
                    } else {
                        vString = [vString stringByReplacingOccurrencesOfString:[collectArray[i] stringByAppendingString:@","] withString:@""];
                        hasError = YES;
                    }
                    finishRequestCount++;
                    if (finishRequestCount == (collectArray.count - 2)) {
                        [self.dataArray removeObject:@""];
                        [self.tableView reloadData];
                        [self.indicatorView stopAnimating];
                        if (self.dataArray.count == 0) {
                            [FAFProgressHUD show:@"您还没有收藏任何美食" icon:nil view:self.view color:nil];
                        }
                        if (hasError) {
                            [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : APPKey, @"table" : @"prefer", @"k" : [self codeStringWithOriginalString:((AppDelegate *)[UIApplication sharedApplication].delegate).uid], @"v" : [self codeStringWithOriginalString:vString]} onResult:nil];
                        }
                    }
                }];
            }
        } else {
            [self.indicatorView stopAnimating];
            [FAFProgressHUD showError:response.error.userInfo.allValues.firstObject toView:self.view];
        }
    }];
}

// 推荐列表转模型
- (MobFoodClassItemModel *)convertRecommendModelWithDictionary:(NSDictionary *)dict
{
    [MobFoodClassItemModel faf_setupObjectClassInArray:^NSDictionary *{ return @{@"recipe" : @"MobFoodClassItemRecipeModel"}; }];
    [MobFoodClassItemRecipeModel faf_setupObjectClassInArray:^NSDictionary *{ return @{@"method" : @"MobFoodClassItemMethodModel"}; }];
    MobFoodClassItemModel *model = [MobFoodClassItemModel faf_objectWithKeyValues:dict];
    return model;
}

// Base64编码和解码
- (NSString *)codeStringWithOriginalString:(NSString *)originalString
{
    return [[[[[originalString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"=" withString:@""] stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MobFoodListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collectListCell" forIndexPath:indexPath];
    
    [cell setupData:self.dataArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    MobFoodDetailViewController *vc = [[MobFoodDetailViewController alloc] init];
    MobFoodClassItemModel *model = self.dataArray[indexPath.row];
    vc.model = model;
    vc.title = model.name;
    vc.cid = model.menuId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
