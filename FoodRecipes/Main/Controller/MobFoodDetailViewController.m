//
//  MobFoodDetailViewController.m
//  Recorder
//
//  Created by WinterChen on 16/8/14.
//  Copyright © 2016年 WinterChen. All rights reserved.
//

#import "MobFoodDetailViewController.h"
#import "AppDelegate.h"
#import "MobFoodMethodCell.h"
#import "UIImageView+WebCache.h"
#import "WinSocialShareTool.h"

@interface MobFoodDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *foodTitle;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeightConstriants;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *summary;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraints;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (nonatomic, assign) BOOL collected;
@property (nonatomic, strong) NSString *v;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSMutableArray *cellHeightArray;

@end

@implementation MobFoodDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shareIcon"] style:UIBarButtonItemStyleDone target:self action:@selector(shareItemClicked)];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    self.indicatorView.color = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1];
    [self.view addSubview:self.indicatorView];
    [self fetchCollectData];
    
    self.imgHeightConstriants.constant = 0;
    self.foodTitle.text = self.model.recipe.title;
    NSString *recipes = [[[self.model.recipe.ingredients substringWithRange:NSMakeRange(1, self.model.recipe.ingredients.length - 2)] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"材料：" withString:@""];
    self.desc.text = recipes ?: @"略";
    
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.scrollEnabled = NO;
    [self.tableview registerNib:[UINib nibWithNibName:@"MobFoodMethodCell" bundle:nil] forCellReuseIdentifier:@"methodCell"];
    CGFloat tableViewHeight = 0;
    for (NSInteger i = 0; i < self.model.recipe.method.count; i++) {
        MobFoodClassItemMethodModel *methodModel = self.model.recipe.method[i];
        CGFloat cellHeight = [methodModel.step boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 27, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height + 5;
        cellHeight += methodModel.img ? ([UIScreen mainScreen].bounds.size.width - 60) * 311 / 414.0 + 10  : 10;
        [self.cellHeightArray addObject:@(cellHeight)];
        tableViewHeight += cellHeight;
    }
    self.tableViewHeightConstraints.constant = tableViewHeight;
    
    self.summary.text = self.model.recipe.sumary;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCheckedData" object:self.model userInfo:@{@"checkData" : @(YES)}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.summary.frame.origin.y + self.summary.frame.size.height + 10);
}

- (void)fetchCollectData
{
    self.v = @",";
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).uid == nil) {
        return;
    }
    [MobAPI sendRequestWithInterface:@"/ucache/getall" param:@{@"key" : APPKey, @"table" : @"prefer", @"k" : [self codeStringWithOriginalString:((AppDelegate *)[UIApplication sharedApplication].delegate).uid encode:YES]} onResult:^(MOBAResponse *response) {
        if (!response.error) {
            NSArray *dataArray = response.responder[@"result"][@"data"];
            self.v = dataArray.firstObject[@"v"];
            NSArray *collectArray = [self.v componentsSeparatedByString:@","];
            NSString *key = [[self.model.menuId substringWithRange:NSMakeRange(8, 2)] stringByAppendingFormat:@"/%@", [[self.model.menuId substringFromIndex:10] stringByReplacingOccurrencesOfString:@"0" withString:@""]];
            if ([collectArray containsObject:key]) {
                [self.collectButton setImage:[UIImage imageNamed:@"collectDone"] forState:UIControlStateNormal];
                self.collected = YES;
            }
        }
    }];
}

// Base64编码和解码
- (NSString *)codeStringWithOriginalString:(NSString *)originalString encode:(BOOL)encode
{
    if (encode) {
        return [[[originalString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"=" withString:@""];
    } else {
        NSString *decodeString = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:originalString options:0] encoding:NSUTF8StringEncoding];
        if (decodeString.length == 0) {
            originalString = [originalString stringByAppendingString:@"="];
            decodeString = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:originalString options:0] encoding:NSUTF8StringEncoding];
        }
        return decodeString;
    }
    return nil;
}

- (void)shareItemClicked
{
    NSString *imgKey = nil;
    NSMutableArray *shareImgs = [NSMutableArray array];
    for (NSInteger i = self.model.recipe.method.count - 1; i >= 0; i--) {
        MobFoodClassItemMethodModel *methodModel = self.model.recipe.method[i];
        imgKey = methodModel.img ?: nil;
        if (imgKey) {
            UIImage *shareImg = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imgKey] ?: [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgKey];
            if (shareImg) {
                [shareImgs addObject:[self resizeImg:shareImg]];
                break;
            }
            imgKey = nil;
        }
    }
    if (shareImgs.count == 0) {
        [shareImgs addObject:[self resizeImg:[UIImage imageNamed:@"shareDefault"]]];
    }
    [WinSocialShareTool win_shareTitle:self.model.recipe.title.length > 0 ? self.model.recipe.title : @"美食菜谱" images:shareImgs content:self.model.recipe.sumary.length > 0 ? self.model.recipe.sumary : @"美食秘方" urlString:@"http://app.weibo.com" recommendCid:self.cid];
}

- (UIImage *)resizeImg:(UIImage *)shareImg
{
    NSUInteger shareImgLength =  UIImageJPEGRepresentation(shareImg, 1).length;
    if (shareImgLength > 1024 * 32.0) {
        NSData *compressedData = UIImageJPEGRepresentation(shareImg, ((1024 * 32.0) / shareImgLength));
        shareImg = [UIImage imageWithData:compressedData];
    }
    return shareImg;
}

#pragma mark tableview代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.recipe.method.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MobFoodMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"methodCell"];
    if (cell == nil) {
        cell = [MobFoodMethodCell mobFoodMethodCell];
    }
    
    [cell setupData:self.model.recipe.method[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((NSNumber *)self.cellHeightArray[indexPath.row]).floatValue;
}

- (IBAction)collectButtonClick:(id)sender
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).uid == nil) {
        [[[UIAlertView alloc] initWithTitle:@"登录提示" message:@"\n您还没有进行登录!\n马上去登录?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"取消", @"确定", nil] show];
        return;
    }
    NSString *newKey = [[self.model.menuId substringWithRange:NSMakeRange(8, 2)] stringByAppendingFormat:@"/%@,", [[self.model.menuId substringFromIndex:10] stringByReplacingOccurrencesOfString:@"0" withString:@""]];
    if (self.collected) {
        self.v = [self.v stringByReplacingOccurrencesOfString:newKey withString:@""];
    } else {
        self.v = [newKey stringByAppendingString:self.v];
    }
    [self.indicatorView startAnimating];
    [MobAPI sendRequestWithInterface:@"/ucache/put" param:@{@"key" : APPKey, @"table" : @"prefer", @"k" : [self codeStringWithOriginalString:((AppDelegate *)[UIApplication sharedApplication].delegate).uid encode:YES], @"v" : [self codeStringWithOriginalString:self.v encode:YES]} onResult:^(MOBAResponse *response) {
        [self.indicatorView stopAnimating];
        if (!response.error) {
            self.collected = !self.collected;
            UIImage *img = [UIImage imageNamed:self.collected ? @"collectDone" : @"collect"];
            [self.collectButton setImage:img forState:UIControlStateNormal];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeftView" object:[self screenView:self.view] userInfo:@{@"title" : self.title}];
    }
}

- (UIImageView *)screenView:(UIView *)view
{
    // 1.开启上下文,使用参数之后,截出来的是原图（YES  0.0 质量高）
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0.0);
    // 2.将View的图层渲染到上下文
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    // 3.获取此时上下文中的图片
    UIImage *snapshortImg = UIGraphicsGetImageFromCurrentImageContext();
    // 4.关闭上下文
    UIGraphicsEndImageContext();
    return [[UIImageView alloc] initWithImage:snapshortImg];
}

- (NSMutableArray *)cellHeightArray
{
    if (_cellHeightArray == nil) {
        _cellHeightArray = [NSMutableArray array];
    }
    return _cellHeightArray;
}

@end
