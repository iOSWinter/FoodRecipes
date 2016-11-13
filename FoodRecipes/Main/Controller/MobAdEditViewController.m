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
#import "MobAdvertiseModel.h"

@interface MobAdEditViewController ()

@property (nonatomic, strong) UIControl *control;
@property (nonatomic, strong) UIView *addView;
@property (strong, nonatomic) UITextView *imgUrl;
@property (strong, nonatomic) UITextView *redirectUrl;
@property (strong, nonatomic) UITextView *titleName;
@property (nonatomic, strong) UITextView *type;
@property (strong, nonatomic) UIButton *addButton;
@property (nonatomic, assign) BOOL valid;
@property (nonatomic, assign) BOOL valided;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSMutableArray *onlineDataArray;
@property (nonatomic, strong) NSMutableArray *offlineDataArray;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIBarButtonItem *totalItem;
@property (nonatomic, strong) UIBarButtonItem *operateItem;

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
    self.totalItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:nil action:nil];
    self.operateItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStyleDone target:self action:@selector(addNewItem)];
    self.navigationItem.rightBarButtonItems = @[self.operateItem, self.totalItem];
    
    [self setupAddView];
    [self setupTableview];
    [self setupViewStyle];
    [self addDone];
    [self fetchAdvertisementData];
    self.imgUrl.text = @"http://img.mmjpg.com/2016/737/12.jpg";
    self.redirectUrl.text = @"http://www.mmjpg.com/mm/737";
    self.titleName.text = @"今日美图推荐";
    self.type.text = @"1";
}

- (void)setupAddView
{
    _size = [UIScreen mainScreen].bounds.size;
    _control = [[UIControl alloc] initWithFrame:self.navigationController.view.bounds];
    _control.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [_control addTarget:self action:@selector(addDone) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:_control];
    _addView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _size.width - 30, 230)];
    _addView.center = CGPointMake(_control.center.x, 200);
    _addView.layer.cornerRadius = 5;
    _addView.layer.masksToBounds = YES;
    _addView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    [_control addSubview:_addView];
    _imgUrl = [self createViewItemWithTitle:@"图片地址" sequence:0];
    _redirectUrl = [self createViewItemWithTitle:@"广告链接" sequence:1];
    _titleName = [self createViewItemWithTitle:@"广告标题" sequence:2];
    _type = [self createViewItemWithTitle:@"广告类型" sequence:3];
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addButton.frame = CGRectMake(0, 0, _size.width * 0.5, 30);
    addButton.center = CGPointMake(_addView.frame.size.width * 0.5, _type.frame.origin.y + _type.frame.size.height + 20);
    addButton.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:148 /255.0 blue:116 / 255.0 alpha:1];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addView addSubview:addButton];
    [addButton addTarget:self action:@selector(confirmAddButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _addButton = addButton;
    _control.x = -_size.width;
}

- (UITextView *)createViewItemWithTitle:(NSString *)title sequence:(NSInteger)sequence
{
    CGFloat textViewHeight = 45;
    if (sequence > 1) {
        textViewHeight = 35;
    }
    UILabel *titleName = [[UILabel alloc] initWithFrame:CGRectMake(0, sequence > 2 ? 10 + 50 * sequence - 10 : 10 + 50 * sequence, 40, textViewHeight)];
    titleName.text = title;
    titleName.textAlignment = NSTextAlignmentCenter;
    titleName.numberOfLines = 0;
    titleName.font = [UIFont systemFontOfSize:14];
    titleName.textColor = [UIColor colorWithRed:255 / 255.0 green:148 /255.0 blue:116 / 255.0 alpha:1];
    [self.addView addSubview:titleName];
    UITextView *textview = [[UITextView alloc] initWithFrame:CGRectMake(titleName.width, titleName.y, _addView.frame.size.width - titleName.width - 5, textViewHeight)];
    textview.font = [UIFont boldSystemFontOfSize:15];
    textview.textColor = [UIColor colorWithRed:255 / 255.0 green:148 /255.0 blue:116 / 255.0 alpha:1];
    textview.backgroundColor = [UIColor clearColor];
    textview.layer.borderWidth = 1;
    textview.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05].CGColor;
    textview.layer.cornerRadius = 5;
    textview.layer.masksToBounds = YES;
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
    self.addButton.layer.cornerRadius = 5;
    self.addButton.layer.masksToBounds = YES;
}

- (void)addNewItem
{
    __weak MobAdEditViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf updateAddViewLocation:YES];
        [weakSelf updateConfirmButtonTitle:@"确定"];
        [weakSelf.imgUrl becomeFirstResponder];
        weakSelf.operateItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(addDone)];
        
    });
}

- (void)addDone
{
    [self updateAddViewLocation:NO];
    [self.addView endEditing:YES];
    self.operateItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStyleDone target:self action:@selector(addNewItem)];
}

- (void)updateConfirmButtonTitle:(NSString *)title
{
    [self.addButton setTitle:title forState:UIControlStateNormal];
}

- (void)updateAddViewLocation:(BOOL)show
{
    __weak MobAdEditViewController *weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.control.x = show ? 0 : -Width;
        [weakSelf.control layoutIfNeeded];
        [weakSelf.view layoutIfNeeded];
    }];
}

- (void)fetchAdvertisementData
{
    [self.indicatorView startAnimating];
    __weak MobAdEditViewController *weakSelf = self;
    [MobAPI sendRequestWithInterface:@"/ucache/getall" param:@{@"key" : APPKey, @"table" : @"advertisement", @"page" : @"1", @"size" : AdvertisementRequestCount} onResult:^(MOBAResponse *response) {
        [weakSelf.indicatorView stopAnimating];
        if (response.error) {
            [FAFProgressHUD show:@"查询数据失败" icon:nil view:weakSelf.view color:nil];
        } else {
            NSArray *dataArray = response.responder[@"result"][@"data"];
            for (NSInteger i = 0; i < dataArray.count; i++) {
                NSDictionary *dict = dataArray[i];
                NSString *jsonValue = [WinDataCode win_DecryptAESData:[GTMBase64 decodeString:dict[@"v"]] app_key:Secret];
                NSData *jsonData = [jsonValue dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *valueDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                MobAdvertiseModel *model = [MobAdvertiseModel faf_objectWithKeyValues:valueDict];
                if (model.valid) {
                    [weakSelf.onlineDataArray addObject:model];
                } else {
                    [weakSelf.offlineDataArray addObject:model];
                }
            }
            weakSelf.totalItem.title = [NSString stringWithFormat:@"%ld条", (weakSelf.onlineDataArray.count + weakSelf.offlineDataArray.count)];
            weakSelf.offlineDataArray = [NSMutableArray arrayWithArray:[weakSelf.offlineDataArray  sortedArrayUsingComparator:^NSComparisonResult(MobAdvertiseModel *obj1, MobAdvertiseModel *obj2) {
                NSString *link1 = obj1.link.lastPathComponent;
                NSString *link2 = obj2.link.lastPathComponent;
                return link1.integerValue < link2.integerValue;
            }]];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)confirmAddButtonClick
{
    [self.indicatorView startAnimating];
    if (self.imgUrl.text.length != 0 && self.redirectUrl.text.length != 0 && self.titleName.text.length != 0) {
//        NSArray *a = [NSArray arrayWithContentsOfFile:@"/Users/winterchen/Desktop/advertisementList.plist"];
//        for (NSDictionary *d in a) {
//            for (NSString *key in d) {
//                NSString *v = d[key];
//                if (![v isKindOfClass:[NSString class]]) {
//                    continue;
//                }
//                if ([v containsString:@".jpg"]) {
//                    self.imgUrl.text = v;
//                } else {
//                    self.redirectUrl.text = [v componentsSeparatedByString:@","].firstObject;
//                }
//            }
        NSString *keyString;
        if (self.indexPath) {
            keyString = ((MobAdvertiseModel *)self.offlineDataArray[self.indexPath.row]).key;
        } else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            keyString = [dateFormatter stringFromDate:[NSDate date]];
        }
        NSString *value = [NSString stringWithFormat:@"{\"key\":\"%@\",\"imgUrl\":\"%@\",\"title\":\"%@\",\"link\":\"%@\",\"valid\":\"%d\",\"valided\":\"%d\",\"type\":\"%@\"}", keyString, self.imgUrl.text, self.titleName.text, self.redirectUrl.text, self.valid, self.valided, self.type.text];
        __weak MobAdEditViewController *weakSelf = self;
        [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : APPKey, @"table" : @"advertisement", @"k" : [self codeStringWithOriginalString:keyString], @"v" : [self codeStringWithOriginalString:value]} onResult:^(MOBAResponse *response) {
            [weakSelf.indicatorView stopAnimating];
            NSString *keyWord = [weakSelf.addButton.titleLabel.text substringFromIndex:2];
            if (response.error) {
                [FAFProgressHUD showError:[keyWord stringByAppendingString:@"失败,请稍后重试"] toView:weakSelf.view];
            } else {
                [FAFProgressHUD showSuccess:[keyWord stringByAppendingString:@"成功"] toView:weakSelf.view];
                [self addDone];
                NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *valueDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                MobAdvertiseModel *model = [MobAdvertiseModel faf_objectWithKeyValues:valueDict];
                weakSelf.imgUrl.text = nil;
                weakSelf.redirectUrl.text = nil;
                weakSelf.titleName.text = nil;
                if (weakSelf.indexPath) {
                    [weakSelf.offlineDataArray replaceObjectAtIndex:weakSelf.indexPath.row withObject:model];
                    weakSelf.indexPath = nil;
                } else {
                    [weakSelf.offlineDataArray insertObject:model atIndex:0];
                }
                [weakSelf.tableView reloadData];
                self.valid = NO;
                self.valided = NO;
            }
        }];
//        }
    } else {
        [FAFProgressHUD showError:@"还未填写完成" toView:self.view];
        [self.indicatorView stopAnimating];
    }
}

// Base64编码
- (NSString *)codeStringWithOriginalString:(NSString *)originalString
{
    originalString = [WinDataCode win_EncryptAESData:originalString app_key:Secret];
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
    
    MobAdvertiseModel *model = indexPath.section == 0 ? self.onlineDataArray[indexPath.row] : self.offlineDataArray[indexPath.row];
    [cell setupDataWithModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak MobAdEditViewController *weakSelf = self;
    MobAdvertiseModel *model = indexPath.section == 0 ? self.onlineDataArray[indexPath.row] : self.offlineDataArray[indexPath.row];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [weakSelf.indicatorView startAnimating];
        [MobAPI sendRequestWithInterface:@"/ucache/del" param:@{@"key" : APPKey, @"table" : @"advertisement", @"k" : [weakSelf codeStringWithOriginalString:model.key]} onResult:^(MOBAResponse *response) {
            [weakSelf.indicatorView stopAnimating];
            if (response.error) {
                [FAFProgressHUD showError:@"删除失败,请稍后重试" toView:weakSelf.view];
            } else {
                [FAFProgressHUD showSuccess:@"删除成功" toView:weakSelf.view];
                [indexPath.section == 0 ? weakSelf.onlineDataArray : weakSelf.offlineDataArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }];
    
    UITableViewRowAction *topRowAction =[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:indexPath.section == 0 ? @"下线" : @"上线" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [weakSelf.indicatorView startAnimating];
        model.valid = indexPath.section == 0 ? NO : YES;
        model.valided = YES;
        NSDictionary *dict = [MobAdvertiseModel faf_keyValuesArrayWithObjectArray:@[model]].firstObject;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : APPKey, @"table" : @"advertisement", @"k" : [weakSelf codeStringWithOriginalString:model.key], @"v" : [weakSelf codeStringWithOriginalString:json]} onResult:^(MOBAResponse *response) {
            [weakSelf.indicatorView stopAnimating];
            if (!response.error) {
                if (indexPath.section == 0) {
                    [weakSelf.offlineDataArray insertObject:model atIndex:0];
                    [weakSelf.onlineDataArray removeObjectAtIndex:indexPath.row];
                } else {
                    [weakSelf.onlineDataArray insertObject:model atIndex:0];
                    [weakSelf.offlineDataArray removeObjectAtIndex:indexPath.row];
                }
                [tableView reloadData];
            } else {
                [FAFProgressHUD showError:@"操作失败,请稍后重试" toView:weakSelf.view];
            }
        }];
    }];
    
    UITableViewRowAction *editRowAction =[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        weakSelf.indexPath = indexPath;
        weakSelf.imgUrl.text = model.imgUrl;
        weakSelf.redirectUrl.text = model.link;
        weakSelf.titleName.text = model.title;
        weakSelf.type.text = [NSString stringWithFormat:@"%ld", model.type];
        weakSelf.valid = model.valid;
        weakSelf.valided = model.valided;
        [weakSelf addNewItem];
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
    MobAdvertiseModel *model = indexPath.section == 0 ? self.onlineDataArray[indexPath.row] : self.offlineDataArray[indexPath.row];
    vc.adModel = model;
    [self.navigationController pushViewController:vc animated:YES];
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
