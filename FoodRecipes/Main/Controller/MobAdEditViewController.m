//
//  MobAdEditViewController.m
//  FoodRecipes
//
//  Created by WinterChen on 16/8/22.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobAdEditViewController.h"
#import "MobAdEditCell.h"
#import "MobAdViewController.h"

@interface MobAdEditViewController ()

@property (nonatomic, strong) UIView *addView;
@property (strong, nonatomic) UITextView *imgUrl;
@property (strong, nonatomic) UITextView *redirectUrl;
@property (strong, nonatomic) UITextView *titleName;
@property (strong, nonatomic) UIButton *addButton;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSMutableArray *onlineDataArray;
@property (nonatomic, strong) NSMutableArray *offlineDataArray;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation MobAdEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"广告管理";
    self.view.backgroundColor = [UIColor whiteColor];
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.center = self.view.center;
    self.indicatorView.color = [UIColor grayColor];
    [self.navigationController.navigationBar addSubview:self.indicatorView];
    
    [self setupAddView];
    [self setupTableview];
    [self setupViewStyle];
    [self addDone];
    [self fetchAdvertisementData];
    self.imgUrl.text = @"http://sc.wenweipo.com/pic/20120309/20120309141737_88049.jpg";
    self.redirectUrl.text = @"http://news.baidu.com/ns?tn=news&word=郫县";
    self.titleName.text = @"郫县房价";
}

- (void)setupAddView
{
    _size = [UIScreen mainScreen].bounds.size;
    _addView = [[UIView alloc] initWithFrame:CGRectMake(0, -270, _size.width, 270)];
    _addView.hidden = YES;
    _addView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    [self.view addSubview:_addView];
    _imgUrl = [self createViewItemWithTitle:@"广告图片地址" sequence:0];
    _redirectUrl = [self createViewItemWithTitle:@"广告跳转地址" sequence:1];
    _titleName = [self createViewItemWithTitle:@"广告标题" sequence:2];
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addButton.frame = CGRectMake(0, 0, _size.width * 0.5, 30);
    addButton.center = CGPointMake(_size.width * 0.5, _titleName.frame.origin.y + _titleName.frame.size.height + 30);
    addButton.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:148 /255.0 blue:116 / 255.0 alpha:1];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addView addSubview:addButton];
    [addButton addTarget:self action:@selector(confirmAddButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _addButton = addButton;
}

- (UITextView *)createViewItemWithTitle:(NSString *)title sequence:(NSInteger)sequence
{
    UILabel *titleName = [[UILabel alloc] initWithFrame:CGRectMake(15, 5 + 70 * sequence, self.size.width - 30, 20)];
    titleName.text = title;
    titleName.font = [UIFont boldSystemFontOfSize:17];
    titleName.textColor = [UIColor colorWithRed:255 / 255.0 green:148 /255.0 blue:116 / 255.0 alpha:1];
    [self.addView addSubview:titleName];
    UITextView *textview = [[UITextView alloc] initWithFrame:CGRectMake(15, 25 + 70 * sequence, self.size.width - 30, 50)];
    textview.font = [UIFont boldSystemFontOfSize:15];
    textview.textColor = [UIColor colorWithRed:255 / 255.0 green:148 /255.0 blue:116 / 255.0 alpha:1];
    textview.backgroundColor = [UIColor clearColor];
    [self.addView addSubview:textview];
    return textview;
}

- (void)setupTableview
{
    self.tableView.rowHeight = 80;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"MobAdEditCell" bundle:nil] forCellReuseIdentifier:@"adEditCell"];
}

- (void)setupViewStyle
{
    self.imgUrl.layer.borderWidth = 1;
    self.imgUrl.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05].CGColor;
    self.imgUrl.layer.cornerRadius = 5;
    self.imgUrl.layer.masksToBounds = YES;
    self.redirectUrl.layer.borderWidth = 1;
    self.redirectUrl.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05].CGColor;
    self.redirectUrl.layer.cornerRadius = 5;
    self.redirectUrl.layer.masksToBounds = YES;
    self.titleName.layer.borderWidth = 1;
    self.titleName.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05].CGColor;
    self.titleName.layer.cornerRadius = 5;
    self.titleName.layer.masksToBounds = YES;
    self.addButton.layer.cornerRadius = 5;
    self.addButton.layer.masksToBounds = YES;
}

- (void)addNewItem
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateAddViewLocation:YES];
        [self updateConfirmButtonTitle:@"确定添加"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(addDone)];
    });
}

- (void)addDone
{
    [self updateAddViewLocation:NO];
    [self.view endEditing:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStyleDone target:self action:@selector(addNewItem)];
}

- (void)updateConfirmButtonTitle:(NSString *)title
{
    [self.addButton setTitle:title forState:UIControlStateNormal];
}

- (void)updateAddViewLocation:(BOOL)show
{
    self.addView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.addView.frame = CGRectMake(0, show ? 0 : -270, self.size.width, 270);
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.addView.hidden = !show;
    }];
}

- (void)fetchAdvertisementData
{
    [self.indicatorView startAnimating];
    [MobAPI sendRequestWithInterface:@"/ucache/getall" param:@{@"key" : APPKey, @"table" : @"advertisement", @"page" : @"1", @"size" : @"50"} onResult:^(MOBAResponse *response) {
        [self.indicatorView stopAnimating];
        if (response.error) {
            [FAFProgressHUD show:@"查询数据失败" icon:nil view:self.view color:nil];
        } else {
            NSArray *dataArray = response.responder[@"result"][@"data"];
            for (NSInteger i = 0; i < dataArray.count; i++) {
                NSDictionary *dict = dataArray[i];
                NSString *functionMark = [dict[@"v"] componentsSeparatedByString:@","].lastObject;
                if (functionMark.integerValue == 0) {
                    [self.offlineDataArray addObject:dict];
                } else {
                    [self.onlineDataArray addObject:dict];
                }
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)confirmAddButtonClick
{
    [self.indicatorView startAnimating];
    if (self.imgUrl.text.length != 0 && self.redirectUrl.text.length != 0 && self.titleName.text.length != 0) {
        [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : APPKey, @"table" : @"advertisement", @"k" : [self codeStringWithOriginalString:self.imgUrl.text], @"v" : [self codeStringWithOriginalString:[self.redirectUrl.text stringByAppendingFormat:@",%@,0", self.titleName.text]]} onResult:^(MOBAResponse *response) {
            [self.indicatorView stopAnimating];
            NSString *keyWord = [self.addButton.titleLabel.text substringFromIndex:2];
            if (response.error) {
                [FAFProgressHUD show:[keyWord stringByAppendingString:@"失败,请稍后重试"] icon:nil view:self.view color:nil];
            } else {
                [FAFProgressHUD show:[keyWord stringByAppendingString:@"成功"] icon:nil view:self.view color:nil];
                [self addDone];
                NSDictionary *object = @{@"k" : self.imgUrl.text, @"v" : [self.redirectUrl.text stringByAppendingFormat:@",%@,0", self.titleName.text]};
                self.imgUrl.text = nil;
                self.redirectUrl.text = nil;
                self.titleName.text = nil;
                if (self.indexPath) {
                    [self.offlineDataArray removeObjectAtIndex:self.indexPath.row];
                    self.indexPath = nil;
                }
                [self.offlineDataArray insertObject:object atIndex:0];
                [self.tableView reloadData];
            }
        }];
    } else {
        [FAFProgressHUD showError:@"还未填写完成" toView:self.view];
        [self.indicatorView stopAnimating];
    }
}

// Base64编码和解码
- (NSString *)codeStringWithOriginalString:(NSString *)originalString
{
    return [[[[[originalString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"=" withString:@""] stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark Tableview的代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.offlineDataArray.count > 0 ? 2 : self.onlineDataArray.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.onlineDataArray.count;
    } else if (section == 1) {
        return self.offlineDataArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MobAdEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adEditCell"];
    
    [cell setupDataWithDict:indexPath.section == 0 ? self.onlineDataArray[indexPath.row] : self.offlineDataArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0 : 35;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? @"已上线" : @"已下线";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak MobAdEditViewController *weakSelf = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [weakSelf.indicatorView startAnimating];
        [MobAPI sendRequestWithInterface:@"/ucache/del" param:@{@"key" : APPKey, @"table" : @"advertisement", @"k" : [weakSelf codeStringWithOriginalString:indexPath.section == 0 ? weakSelf.onlineDataArray[indexPath.row][@"k"] : weakSelf.offlineDataArray[indexPath.row][@"k"]],} onResult:^(MOBAResponse *response) {
            [weakSelf.indicatorView stopAnimating];
            if (response.error) {
                [FAFProgressHUD show:@"删除失败,请稍后重试" icon:nil view:weakSelf.view color:nil];
            } else {
                [FAFProgressHUD show:@"删除成功" icon:nil view:weakSelf.view color:nil];
                [indexPath.section == 0 ? weakSelf.onlineDataArray : weakSelf.offlineDataArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }];
    
    UITableViewRowAction *topRowAction =[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:indexPath.section == 0 ? @"下线" : @"上线" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [weakSelf.indicatorView startAnimating];
        NSString *k = indexPath.section == 0 ? weakSelf.onlineDataArray[indexPath.row][@"k"] : weakSelf.offlineDataArray[indexPath.row][@"k"];
        NSString *v = indexPath.section == 0 ? [self.onlineDataArray[indexPath.row][@"v"] stringByReplacingOccurrencesOfString:@",1" withString:@",0"] : [self.offlineDataArray[indexPath.row][@"v"] stringByReplacingOccurrencesOfString:@",0" withString:@",1"];
        [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : APPKey, @"table" : @"advertisement", @"k" : [self codeStringWithOriginalString:k], @"v" : [self codeStringWithOriginalString:v]} onResult:^(MOBAResponse *response) {
            [weakSelf.indicatorView stopAnimating];
            if (!response.error) {
                if (indexPath.section == 0) {
                    [weakSelf.offlineDataArray insertObject:@{@"k" : k, @"v" : v} atIndex:0];
                    [weakSelf.onlineDataArray removeObjectAtIndex:indexPath.row];
                } else {
                    [weakSelf.onlineDataArray insertObject:@{@"k" : k, @"v" : v} atIndex:0];
                    [weakSelf.offlineDataArray removeObjectAtIndex:indexPath.row];
                }
                [tableView reloadData];
            } else {
                [FAFProgressHUD show:@"操作失败,请稍后重试" icon:nil view:weakSelf.view color:nil];
            }
        }];
    }];
    
    UITableViewRowAction *editRowAction =[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        weakSelf.indexPath = indexPath;
        NSDictionary *dict = self.offlineDataArray[indexPath.row];
        self.imgUrl.text = dict[@"k"];
        NSArray *array = [dict[@"v"] componentsSeparatedByString:@","];
        self.redirectUrl.text = array.firstObject;
        self.titleName.text = array[1];
        [weakSelf addNewItem];
        [weakSelf updateConfirmButtonTitle:@"位置更新"];
    }];
    editRowAction.backgroundColor = [UIColor orangeColor];
    
    return indexPath.section == 0 ? @[deleteAction, topRowAction] : @[deleteAction, editRowAction, topRowAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self addDone];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    MobAdViewController *vc = [[MobAdViewController alloc] init];
    NSArray *vArray = [(indexPath.section == 0 ? self.onlineDataArray : self.offlineDataArray)[indexPath.row][@"v"] componentsSeparatedByString:@","];
    vc.link = vArray.firstObject;
    vc.title = vArray[1];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self addDone];
}


- (NSMutableArray *)onlineDataArray
{
    if (_onlineDataArray == nil) {
        _onlineDataArray = [NSMutableArray array];
    }
    return _onlineDataArray;
}

- (NSMutableArray *)offlineDataArray
{
    if (_offlineDataArray == nil) {
        _offlineDataArray = [NSMutableArray array];
    }
    return _offlineDataArray;
}

@end
