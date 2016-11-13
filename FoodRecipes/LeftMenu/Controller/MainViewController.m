//
//  MainViewController.m
//  SideViewController
//
//  Created by YouXianMing on 16/6/6.
//  Copyright © 2016年 YouXianMing. All rights reserved.
//

#import "MainViewController.h"
#import "MobFoodSecondViewController.h"
#import "MobFoodListViewController.h"
#import "MobFoodDetailViewController.h"
#import "MobAdViewController.h"
#import "MobMenuCollectionCell.h"
#import "MobFoodListCell.h"
#import "MobRecommendModel.h"
#import "MobFoodClassModel.h"
#import "MobFoodRecipes.h"
#import "MXScrollView.h"
#import "MJRefresh.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define adViewHWRate 0.6

@interface MainViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) MXImageScrollView *adsView;
@property (nonatomic, strong) UIView *collectionViewContainer;
@property (strong, nonatomic) UITableView *tableview;
@property (nonatomic, assign) CGSize size;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *collectionViewDataArray;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) MobFoodCategoryModel *model;

@property (nonatomic, strong) NSMutableArray *recommendDataArray;
@property (nonatomic, strong) NSMutableArray *checkedDataArray;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, strong) NSString *recommendFilePath;
@property (nonatomic, strong) NSString *advertiseCachesFilePath;
@property (nonatomic, assign) BOOL shouldShow;
@property (nonatomic, strong) GADBannerView *banner;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.shadowOffset = CGSizeMake(-2, 0);
    self.view.layer.shadowColor = [UIColor colorWithRed:255 / 255.0 green:148 / 255.0 blue:116 / 255.0 alpha:1].CGColor;
    self.view.layer.shadowOpacity = 0.5;
    // 设置view和请求数据
    [self setupAdvertisementView];
    [self setupCollectionView];
    [self setupBannerView];
    [self setupTableview];
    [self fetchCollectionViewData];
    [self fetchRecommendData];
    [self setupBannerView];
    
    self.scrollView.mj_header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshRecommendData)];
    
    
    //    [MobAPI sendRequest:[MOBAWeatherRequest citiesRequest] onResult:^(MOBAResponse *response) {
    //        [MobProvinceModel faf_setupObjectClassInArray:^NSDictionary *{
    //            return @{
    //                     @"city" : @"MobCityModel",
    //                     };
    //        }];
    //        [MobCityModel faf_setupObjectClassInArray:^NSDictionary *{
    //            return @{
    //                     @"district" : @"MobDistrictModel"
    //                     };
    //        }];
    //        NSArray *cityArray = [MobProvinceModel faf_objectArrayWithKeyValuesArray:response.responder[@"result"]];
    //        [cityArray makeObjectsPerformSelector:@selector(print)];
    //    }];
    
    //    [MobAPI sendRequest:[MOBAWeatherRequest searchRequestByCity:@"郫县" province:@"四川"] onResult:^(MOBAResponse *response) {
    //        if (response.error) {
    //            NSLog(@"刷新失败,请稍后重试");
    //        } else {
    //            MobWeatherModel *model = [MobWeatherModel faf_objectArrayWithKeyValuesArray:response.responder[@"result"]].firstObject;
    //            NSLog(@"%@", model);
    //        }
    //    }];
    
    //    [MobAPI sendRequest:[MOBAIdRequest idcardRequestByCardno:@"511002198812036819"] onResult:^(MOBAResponse *response) {
    //        MobIdentifierModel *model = [MobIdentifierModel faf_objectWithKeyValues:response.responder[@"result"]];
    //        NSLog(@"%@", model.area);
    //    }];
    
    //    [MobAPI sendRequest:[MOBAHistoryRequest historyRequestWithDay:@"0814"] onResult:^(MOBAResponse *response) {
    //        NSArray *historyArray = [MobHistoryDayModel faf_objectArrayWithKeyValuesArray:response.responder[@"result"]];
    //        [historyArray makeObjectsPerformSelector:@selector(print)];
    //    }];    
}

- (void)setupAdvertisementView
{
    _size = [UIScreen mainScreen].bounds.size;
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_scrollView];
    self.scrollView.showsVerticalScrollIndicator = NO;
    MXImageScrollView *adsView = [[MXImageScrollView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.width * adViewHWRate)];
    adsView.showAnimotion = YES;
    adsView.scrollIntervalTime = 500;
    adsView.animotionType = kMXTransitionReveal;
    adsView.animotionDirection = kMXTransitionDirectionFromRight;
    adsView.pageControlPosition = kMXPageControlPositionBottom;
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"advertisement"];
    [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
    _advertiseCachesFilePath = [docDir stringByAppendingPathComponent:@"caches.dat"];
    NSArray *adArray = [NSArray arrayWithContentsOfFile:self.advertiseCachesFilePath];
    
    if (adArray.count > 0) {
        NSMutableArray *adModelArray = [NSMutableArray array];
        NSMutableArray *adImgArray = [NSMutableArray array];
        for(NSInteger i = 0; i < adArray.count; i++){
            NSString *json = adArray[i];
            NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *valueDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            MobAdvertiseModel *model = [MobAdvertiseModel faf_objectWithKeyValues:valueDict];
            [adModelArray addObject:model];
            [adImgArray addObject:model.imgUrl];
        }
        adsView.images = adImgArray;
        __weak MainViewController *weakSelf = self;
        adsView.tapImageHandle = ^(NSInteger index) {
            [weakSelf.navBar removeFromSuperview];
            weakSelf.navBar = nil;
            MobAdViewController *vc = [[MobAdViewController alloc] init];
            vc.adModel = adModelArray[index];
            [weakSelf.navController pushViewController:vc animated:YES];
        };
    }
    [self.scrollView addSubview:adsView];
    _adsView = adsView;
    [self fetchAdvertisementData];
}

- (void)setupCollectionView
{
    _cellHeight = 90;
    UIView *collectionViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.size.width * adViewHWRate + 10, self.size.width, _cellHeight + 30)];
    collectionViewContainer.layer.borderWidth = 1;
    collectionViewContainer.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05].CGColor;
    collectionViewContainer.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:collectionViewContainer];
    _collectionViewContainer = collectionViewContainer;
    UILabel *checkView = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, self.size.width - 15, 20)];
    checkView.text = @"菜谱分类";
    checkView.textColor = [UIColor colorWithRed:255 / 255.0 green:148 /255.0 blue:116 / 255.0 alpha:1];
    checkView.font = [UIFont boldSystemFontOfSize:17];
    [collectionViewContainer addSubview:checkView];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.minimumInteritemSpacing = 20;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(_cellHeight, _cellHeight);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, checkView.frame.origin.y + checkView.frame.size.height, collectionViewContainer.frame.size.width, _cellHeight + 5) collectionViewLayout:flowLayout];
    [_collectionView registerNib:[UINib nibWithNibName:@"MobMenuCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"menuCell"];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [collectionViewContainer addSubview:_collectionView];
}

- (void)setupBannerView
{
    _banner = [[GADBannerView alloc] initWithFrame:CGRectMake(0, self.collectionViewContainer.frame.origin.y + self.collectionViewContainer.frame.size.height + 2, Width, 50)];
    self.banner.adUnitID = AdMobBannerID;
    self.banner.rootViewController = self;
    self.banner.delegate = self;
    GADRequest *request = [GADRequest request];
    [self.banner loadRequest:request];
    [self.scrollView addSubview:self.banner];
    self.shouldShow = YES;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    if (self.shouldShow) {
        self.shouldShow = NO;
        __weak MainViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.3 animations:^{
                
                weakSelf.tableview.y += 50;
                weakSelf.tableview.contentSize = CGSizeMake(Width, weakSelf.tableview.contentSize.height + 50);
                [weakSelf.view layoutIfNeeded];
            }];
        });
    }
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (!self.shouldShow) {
        self.shouldShow = YES;
        __weak MainViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                
                weakSelf.tableview.y -= 50;
                weakSelf.tableview.contentSize = CGSizeMake(Width, weakSelf.tableview.contentSize.height - 50);
                [weakSelf.view layoutIfNeeded];
            }];
        });
    }
}

- (void)setupTableview
{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, self.collectionViewContainer.frame.origin.y + self.collectionViewContainer.frame.size.height, self.size.width, 128)];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.scrollEnabled = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.rowHeight = 97;
    [self.scrollView addSubview:self.tableview];
    [self.tableview registerNib:[UINib nibWithNibName:@"MobFoodListCell" bundle:nil] forCellReuseIdentifier:@"recommendCell"];
}

- (void)fetchAdvertisementData
{
    __weak MainViewController *weakSelf = self;
    [MobAPI sendRequestWithInterface:@"/ucache/getall" param:@{@"key" : APPKey, @"table" : @"advertisement", @"page" : @"1", @"size" : AdvertisementRequestCount} onResult:^(MOBAResponse *response) {
        if (!response.error) {
            NSArray *adArray = response.responder[@"result"][@"data"];
            NSMutableArray *adCachesArray = [NSMutableArray array];
            NSMutableArray *adModelArray = [NSMutableArray array];
            NSMutableArray *adImgArray = [NSMutableArray array];
            for (NSInteger i = 0; i < adArray.count; i++) {
                NSString *jsonValue = [WinDataCode win_DecryptAESData:[GTMBase64 decodeString:adArray[i][@"v"]] app_key:Secret];
                NSData *jsonData = [jsonValue dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *valueDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                MobAdvertiseModel *model = [MobAdvertiseModel faf_objectWithKeyValues:valueDict];
                if (model.valid) {
                    [adCachesArray addObject:jsonValue];
                    [adModelArray addObject:model];
                    [adImgArray addObject:model.imgUrl];
                }
            }
            [adCachesArray writeToFile:self.advertiseCachesFilePath atomically:YES];
            if (adModelArray.count > 0) {
                self.adsView.images = adImgArray;
                self.adsView.tapImageHandle = ^(NSInteger index){
                    [weakSelf.navBar removeFromSuperview];
                    weakSelf.navBar = nil;
                    MobAdViewController *vc = [[MobAdViewController alloc] init];
                    vc.adModel = adModelArray[index];
                    [weakSelf.navController pushViewController:vc animated:YES];
                };
            }
        }
    }];
}

- (void)fetchCollectionViewData
{
    NSDictionary *cachesDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"homeCategoryData" ofType:@"plist"]];
    [self convertModelWithDictionary:cachesDict];
    //请求网络数据
    //    [MobAPI sendRequestWithInterface:@"/v1/cook/category/query" param:@{@"key" : APPKey} onResult:^(MOBAResponse *response) {
    //        if (!response.error) {
    //            [response.responder[@"result"] writeToFile:cachesFilePath atomically:YES];
    //            [self convertModelWithDictionary:response.responder[@"result"]];
    //        }
    //    }];
}

- (void)convertModelWithDictionary:(NSDictionary *)dict
{
    [MobFoodCategoryModel faf_setupObjectClassInArray:^NSDictionary *{
        return @{@"childs" : @"MobFoodCategoryChildsModel"};
    }];
    [MobFoodCategoryChildsModel faf_setupObjectClassInArray:^NSDictionary *{
        return @{@"childs" : @"MobFoodChildsModel"};
    }];
    [MobFoodChildsModel faf_setupObjectClassInArray:^NSDictionary *{
        return @{@"childs" : @"MobFoodCategoryInfoModel"};
    }];
    _model = [MobFoodCategoryModel faf_objectWithKeyValues:dict];
}

- (void)fetchRecommendData
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveRecommendDataOrCheckedData:) name:@"updateCheckedData" object:nil];
    [self initManagementContext];
    // 暂时加载本地推荐数据
    NSArray *recommendArray = [NSArray arrayWithContentsOfFile:self.recommendFilePath];
    recommendArray = recommendArray ?: [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"recommendData" ofType:@"plist"]];
    for (NSInteger i = 0; i < recommendArray.count; i++) {
        [self.recommendDataArray addObject:[self convertRecommendModelWithDictionary:recommendArray[i]]];
    }
    // 请求网络推荐列表
    [self fetchLeastRecommendListData];
    
    // 查看数据
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MobFoodRecipes"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"checkData=%@", @(YES)];
    NSArray *checkedArray = [self.context executeFetchRequest:request error:nil];
    if (checkedArray.count > 0) {
        NSInteger repeateCount = checkedArray.count >= 5 ? 5 : checkedArray.count;
        for (NSInteger i = 0; i < repeateCount; i++) {
            MobFoodRecipes *foodRecipes = checkedArray[i];
            [self.checkedDataArray addObject:[self getbackMobFoodClassItemModelWithRecommendModel:foodRecipes]];
        }
    }
    [self refreshTableview];
}

// 逐条请求推荐数据
- (void)fetchRecommendModelWithRecommendListArray:(NSArray *)listArray
{
    __block NSInteger finishRequestCount = 0;
    for (NSInteger i = 0; i < listArray.count; i++) {
        if (i >= self.recommendDataArray.count) {
            [self.recommendDataArray addObject:@""];
        }
        MobRecommendModel *recommendModel = listArray[i];
        [MobAPI sendRequestWithInterface:@"/v1/cook/menu/query" param:@{@"key" : APPKey, @"id" : recommendModel.cid} onResult:^(MOBAResponse *response) {
            if (!response.error) {
                MobFoodClassItemModel *model = [self convertRecommendModelWithDictionary:response.responder[@"result"] ];
                if (model) {
                    [self.recommendDataArray replaceObjectAtIndex:i withObject:model];
                }
                finishRequestCount++;
                if (finishRequestCount == listArray.count) {
                    [self.scrollView.mj_header endRefreshing];
                    [[MobFoodClassItemModel faf_keyValuesArrayWithObjectArray:self.recommendDataArray] writeToFile:self.recommendFilePath atomically:YES];
                    [self refreshTableview];
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

// 模型转换
- (MobFoodClassItemModel *)getbackMobFoodClassItemModelWithRecommendModel:(MobFoodRecipes *)foodRecipes
{
    MobFoodClassItemModel *model = [[MobFoodClassItemModel alloc] init];
    model.thumbnail = foodRecipes.img;
    model.name = foodRecipes.name;
    model.menuId = foodRecipes.cid;
    MobFoodClassItemRecipeModel *recipeModel = [[MobFoodClassItemRecipeModel alloc] init];
    recipeModel.method = [MobFoodClassItemMethodModel faf_objectArrayWithKeyValuesArray:[NSKeyedUnarchiver unarchiveObjectWithData:foodRecipes.method]];
    recipeModel.img = foodRecipes.img;
    recipeModel.title = foodRecipes.title;
    recipeModel.sumary = foodRecipes.summary;
    recipeModel.ingredients = foodRecipes.desc;
    model.recipe = recipeModel;
    return model;
}

// 查看数据更新通知
- (void)saveRecommendDataOrCheckedData:(NSNotification *)noti
{
    MobFoodClassItemModel *model = noti.object;
    [self updateFoodRecipesDataBasesWithModel:model];
    BOOL shouldInsert = YES;
    for (MobFoodClassItemModel *model1 in self.checkedDataArray) {
        if ([model1.menuId isEqualToString:model.menuId]) {
            shouldInsert = NO;
            break;
        }
    }
    if (shouldInsert) {
        [self.checkedDataArray insertObject:model atIndex:0];
    }
    if (self.checkedDataArray.count > 5) {
        [self.checkedDataArray removeLastObject];
    }
    [self refreshTableview];
}

// 更新本地数据库
- (void)updateFoodRecipesDataBasesWithModel:(MobFoodClassItemModel *)model
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MobFoodRecipes"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"cid=%@", model.menuId];
    MobFoodRecipes *foodRecipes = [self.context executeFetchRequest:request error:nil].firstObject;
    if (foodRecipes == nil) {
        foodRecipes = [NSEntityDescription insertNewObjectForEntityForName:@"MobFoodRecipes" inManagedObjectContext:self.context];
        foodRecipes.cid = model.menuId;
        foodRecipes.img = model.thumbnail;
        foodRecipes.title = model.recipe.title;
        foodRecipes.name = model.name;
        foodRecipes.desc = model.recipe.ingredients;
        foodRecipes.method = [NSKeyedArchiver archivedDataWithRootObject:[MobFoodClassItemMethodModel faf_keyValuesArrayWithObjectArray:model.recipe.method]];
        foodRecipes.summary = model.recipe.sumary;
    }
    foodRecipes.date = [NSDate date];
    foodRecipes.checkData = @(YES);
    [self.context save:nil];
}

// 加载最新推荐数据
- (void)fetchLeastRecommendListData
{
    [MobAPI sendRequestWithInterface:@"/ucache/getall" param:@{@"key" : APPKey, @"table" : @"recommend", @"page" : @"1", @"size" : @"10"} onResult:^(MOBAResponse *response) {
        if (response.error == nil) {
            [MobRecommendModel faf_setupReplacedKeyFromPropertyName:^NSDictionary *{ return @{@"cid" : @"k"}; }];
            NSArray *recommendArray = [MobRecommendModel faf_objectArrayWithKeyValuesArray:response.responder[@"result"][@"data"]];
            [self fetchRecommendModelWithRecommendListArray:recommendArray];
        }
    }];
}

// 下拉刷新
- (void)refreshRecommendData
{
    [self fetchLeastRecommendListData];
    [self fetchAdvertisementData];
    self.banner.delegate = self;
}

// 刷新tableview
- (void)refreshTableview
{
    self.tableview.frame = CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, 97 * (self.recommendDataArray.count +  self.checkedDataArray.count) + 35 * ((self.recommendDataArray.count > 0 ? 1 : 0) + (self.checkedDataArray.count > 0 ? 1 : 0)));
    self.scrollView.contentSize = CGSizeMake(self.size.width, self.tableview.frame.origin.y + self.tableview.frame.size.height + 64);
    [self.tableview reloadData];
}

- (void)setRefresh:(BOOL)refresh
{
    if (refresh) {
        self.adsView.scrollIntervalTime = 5;
    }
}

// 初始化
- (void)initManagementContext
{
reStart:{
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"recommend"];
    [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"db.sqlite"];
    _recommendFilePath = [docDir stringByAppendingPathComponent:@"recommend.dat"];
    NSError *error = nil;
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:filePath] options:nil error:&error];
    if (error) {
        [[NSFileManager defaultManager] removeItemAtPath:docDir error:nil];
        goto reStart;
    } else {
        _context = [[NSManagedObjectContext alloc] init];
        _context.persistentStoreCoordinator = store;
    }
}
}

#pragma mark CollectionView的代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionViewDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MobMenuCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"menuCell" forIndexPath:indexPath];
    
    [cell setupData:self.collectionViewDataArray[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navBar removeFromSuperview];
    self.navBar = nil;
    if (self.model) {
        if ([((NSDictionary *)self.collectionViewDataArray[indexPath.row]).allKeys.firstObject isEqualToString:@"jingxuan"]) {
            MobFoodListViewController *vc= [[MobFoodListViewController alloc] init];
            vc.title = @"精选美食";
            [self.navController pushViewController:vc animated:YES];
        } else {
            MobFoodSecondViewController *vc = [[MobFoodSecondViewController alloc] init];
            vc.model = self.model.childs[indexPath.row - 1];
            vc.title = self.model.childs[indexPath.row - 1].categoryInfo.name;
            [self.navController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark TableView的代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.recommendDataArray.count > 0 ? 1 : 0) + (self.checkedDataArray.count > 0 ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.recommendDataArray.count : self.checkedDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MobFoodListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recommendCell"];
    
    [cell setupData:indexPath.section == 0 ? self.recommendDataArray[indexPath.row] : self.checkedDataArray[indexPath.row]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 35)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, headerView.frame.size.width - 15, headerView.frame.size.height)];
    title.text = section == 0 ? @"今日推荐" : @"最近查看";
    title.font = [UIFont boldSystemFontOfSize:17];
    title.textColor = [UIColor colorWithRed:255 / 255.0 green:148 /255.0 blue:116 / 255.0 alpha:1];
    [headerView addSubview:title];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navBar removeFromSuperview];
    self.navBar = nil;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MobFoodDetailViewController *vc = [[MobFoodDetailViewController alloc] init];
    MobFoodClassItemModel *model = indexPath.section == 0 ? self.recommendDataArray[indexPath.row] : self.checkedDataArray[indexPath.row];
    vc.title = model.name;
    vc.model = model;
    vc.cid = model.menuId;
    [self.navController pushViewController:vc animated:YES];
}

- (NSArray *)collectionViewDataArray
{
    return @[@{@"jingxuan" : @"精选"}, @{@"caipin" : @"菜品",}, @{@"caixi" : @"菜系"}, @{@"gongneng" : @"功能"}, @{@"renqun" : @"人群"}, @{@"gongyi" : @"工艺"}];
}

- (NSMutableArray *)recommendDataArray
{
    if (_recommendDataArray == nil) {
        _recommendDataArray = [NSMutableArray array];
    }
    return _recommendDataArray;
}

- (NSMutableArray *)checkedDataArray
{
    if (_checkedDataArray == nil) {
        _checkedDataArray = [NSMutableArray array];
    }
    return _checkedDataArray;
}

@end
