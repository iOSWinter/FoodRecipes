//
//  MobFoodSecondViewController.m
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobFoodSecondViewController.h"
#import "MobViewCell.h"
#import "MobFoodListViewController.h"

@interface MobFoodSecondViewController ()

@end

@implementation MobFoodSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 70;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    NSMutableDictionary *c = [NSMutableDictionary dictionary];
//    for (NSInteger i = 0; i < self.model.childs.count; i++) {
//        NSMutableDictionary *d = [NSMutableDictionary dictionary];
//        d[@"cid"] = self.model.childs[i].categoryInfo.ctgId;
//        d[@"img"] = @"";
//        c[self.model.childs[i].categoryInfo.name] = d;
//    }
//    BOOL success = [@{self.model.categoryInfo.ctgId : @[c, self.model.categoryInfo.name]} writeToFile:@"/Users/iecd/Desktop/list.plist" atomically:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.model.childs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MobViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [MobViewCell mobViewCell];
    }
    
    [cell setupDataWithModel:self.model.childs[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    MobFoodListViewController *vc = [[MobFoodListViewController alloc] init];
    MobFoodChildsModel *childs = self.model.childs[indexPath.row];
    vc.cid = childs.categoryInfo.ctgId;
    vc.title = childs.categoryInfo.name;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
