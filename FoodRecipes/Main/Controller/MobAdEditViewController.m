//
//  MobAdEditViewController.m
//  FoodRecipes
//
//  Created by WinterChen on 16/8/22.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobAdEditViewController.h"
#import "MobAdEditCell.h"

@interface MobAdEditViewController ()

@property (nonatomic, strong) UIView *addView;
@property (strong, nonatomic) UITextView *imgUrl;
@property (strong, nonatomic) UITextView *redirectUrl;
@property (strong, nonatomic) UITextView *titleName;
@property (strong, nonatomic) UIButton *addButton;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSMutableArray *dataArray;
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
    [self.view addSubview:self.indicatorView];
    
    [self setupAddView];
    [self setupTableview];
    [self setupViewStyle];
    [self addDone];
    [self fetchAdvertisementData];
//    self.imgUrl.text = @"http://pic.9ht.com/up/2015-5/2015531102710.jpg";
//    self.redirectUrl.text = @"http://www.vw.com.cn/cn.html";
//    self.titleName.text = @"大众汽车";
}

- (void)setupAddView
{
    _size = [UIScreen mainScreen].bounds.size;
    _addView = [[UIView alloc] initWithFrame:CGRectMake(0, -270, _size.width, 270)];
    _addView.hidden = YES;
    _addView.backgroundColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1];
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
    [self updateAddViewLocation:YES];
    [self updateConfirmButtonTitle:@"确定添加"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(addDone)];
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
    [MobAPI sendRequestWithInterface:@"/ucache/getall" param:@{@"key" : APPKey, @"table" : @"advertisement", @"page" : @"1", @"size" : @"20"} onResult:^(MOBAResponse *response) {
        [self.indicatorView stopAnimating];
        if (response.error) {
            [FAFProgressHUD show:@"查询数据失败" icon:nil view:self.view color:nil];
        } else {
            self.dataArray = [NSMutableArray arrayWithArray:response.responder[@"result"][@"data"]];
            [self.tableView reloadData];
        }
    }];
}

- (void)confirmAddButtonClick
{
    [self.indicatorView startAnimating];
    if (self.imgUrl.text.length != 0 && self.redirectUrl.text.length != 0 && self.titleName.text.length != 0) {
        [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : APPKey, @"table" : @"advertisement", @"k" : [self codeStringWithOriginalString:self.imgUrl.text], @"v" : [self codeStringWithOriginalString:[self.redirectUrl.text stringByAppendingFormat:@",%@", self.titleName.text]]} onResult:^(MOBAResponse *response) {
            [self.indicatorView stopAnimating];
            NSString *keyWord = [self.addButton.titleLabel.text substringFromIndex:2];
            if (response.error) {
                [FAFProgressHUD show:[keyWord stringByAppendingString:@"失败,请稍后重试"] icon:nil view:self.view color:nil];
            } else {
                [FAFProgressHUD show:[keyWord stringByAppendingString:@"成功"] icon:nil view:self.view color:nil];
                [self addDone];
                NSDictionary *object = @{@"k" : self.imgUrl.text, @"v" : [self.redirectUrl.text stringByAppendingFormat:@",%@", self.titleName.text]};
                self.imgUrl.text = nil;
                self.redirectUrl.text = nil;
                self.titleName.text = nil;
                if (self.indexPath) {
                    [self.dataArray removeObjectAtIndex:self.indexPath.row];
                    self.indexPath = nil;
                }
                [self.dataArray insertObject:object atIndex:0];
                [self.tableView reloadData];
            }
        }];
    } else {
        [FAFProgressHUD showError:@"还未填写完成" toView:self.view];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MobAdEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adEditCell"];
    
    [cell setupDataWithDict:self.dataArray[indexPath.row]];
    
    return cell;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [self.indicatorView startAnimating];
        [MobAPI sendRequestWithInterface:@"/ucache/del" param:@{@"key" : APPKey, @"table" : @"advertisement", @"k" : [self codeStringWithOriginalString:self.dataArray[indexPath.row][@"k"]],} onResult:^(MOBAResponse *response) {
            [self.indicatorView stopAnimating];
            if (response.error) {
                [FAFProgressHUD show:@"删除失败,请稍后重试" icon:nil view:self.view color:nil];
            } else {
                [FAFProgressHUD show:@"删除成功" icon:nil view:self.view color:nil];
                [self.dataArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }];
    __weak MobAdEditViewController *weakSelf = self;
    UITableViewRowAction *topRowAction =[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑\n置顶" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        weakSelf.indexPath = indexPath;
        NSDictionary *dict = self.dataArray[indexPath.row];
        self.imgUrl.text = dict[@"k"];
        NSArray *array = [dict[@"v"] componentsSeparatedByString:@","];
        self.redirectUrl.text = array.firstObject;
        self.titleName.text = array.lastObject;
        [self addNewItem];
        [self updateConfirmButtonTitle:@"位置更新"];
    }];
    return @[deleteAction,topRowAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self addDone];
}

@end
