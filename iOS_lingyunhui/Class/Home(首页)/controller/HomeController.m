//
//  HomeController.m
//  iOS_linyunhui
//
//  Created by 刘琛 on 16/5/16.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import "HomeController.h"
#import "HTHeadNavView.h"
#import "HomeCellModel.h"
#import "HomeGroupModel.h"
#import "HomeCollectionCell.h"
#import "HaedForCellView.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "HomePushViewController.h"

static NSString *homeCollectionViewCell = @"homeCollectionView";
static NSString *homeHeadCell = @"homeHeadCell";

@interface HomeController ()<HTHeadViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,NJKWebViewProgressDelegate,UIWebViewDelegate>

@property (nonatomic, strong) UIView *menu;

@property (nonatomic, strong) HTHeadNavView *head;

@property (nonatomic, strong) UILabel *allLabel;

@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, strong) UICollectionView *collectView;

@property (nonatomic, strong) BMKLocationService *locService;

@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;

@property (nonatomic, strong)  NSString *showmeg;;

@property (nonatomic, strong) NJKWebViewProgressView *webViewProgressView;
@property (nonatomic, strong) NJKWebViewProgress *webViewProgress;

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarItem.title = @"1231";
//    self.view.backgroundColor = [UIColor greenColor];
    
    CGRect rect = CGRectMake(0, 20, ScreenWidth, 42);
    
    NSArray *array1 = @[@"最新",@"4S店咨询",@"厂端资讯"];
    
    _head = [[HTHeadNavView alloc] initWithFrame:rect AndFirstArray:array1 AndAddress:nil];
    _head.delegate = self;
    [self.view addSubview:_head];
    
    _menu = [[UIView alloc] initWithFrame:CGRectMake(0, -ScreenHeight - 20, ScreenWidth, ScreenHeight - 22)];
    _menu.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.643];
    [_menu bk_whenTapped:^{
        [self hidenMenuAndShowHead];
    }];
    [self.view addSubview:_menu];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 42)];
    view.backgroundColor = [UIColor whiteColor];
    [_menu addSubview:view];
    
    _allLabel = [[UILabel alloc] initWithFrame:CGRectMake(-70, 0, 70, 40)];
    _allLabel.text = @"全部频道";
    _allLabel.textColor = [UIColor redColor];
    _allLabel.font = [UIFont systemFontOfSize:15];
    _allLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:_allLabel];
    
    _finishButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth + 50, 0, 50, 40)];
    _finishButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_finishButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [_finishButton bk_whenTapped:^{
        [self hidenMenuAndShowHead];
    }];
    [view addSubview:_finishButton];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    layout.minimumLineSpacing = 5;
    
    
    _collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 40, ScreenWidth - 0, ScreenHeight - 22 - 42)collectionViewLayout:layout];
    _collectView.delegate = self;
    _collectView.dataSource = self;
    _collectView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [_collectView setBackgroundColor:[UIColor clearColor]];
    [_collectView registerNib:[UINib nibWithNibName:@"HomeCollectionCell" bundle:nil] forCellWithReuseIdentifier:homeCollectionViewCell];
    [_collectView registerNib:[UINib nibWithNibName:@"HaedForCellView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:homeHeadCell];
    [_collectView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footForCell"];
    [_menu addSubview:_collectView];
    
    //定位服务
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    [_locService startUserLocationService];
    
    
    _webViewProgress = [[NJKWebViewProgress alloc] init];
    _webViewProgress.webViewProxyDelegate = self;
    _webViewProgress.progressDelegate = self;
    
    CGRect navBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0,
                                 navBounds.size.height - 2,
                                 navBounds.size.width,
                                 2);
    _webViewProgressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _webViewProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_webViewProgressView setProgress:0 animated:YES];
    [self.navigationController.navigationBar addSubview:_webViewProgressView];
}

- (void)hidenMenuAndShowHead {
    [UIView animateWithDuration:0.35 animations:^{
        _allLabel.frame = CGRectMake(-70, 0, 70, 40);
        _menu.frame = CGRectMake(0, -ScreenHeight - 22, ScreenWidth, ScreenHeight - 22);
        _finishButton.frame = CGRectMake(ScreenWidth + 50, 0, 50, 40);
    }];
    
    [self.head upAndDownReduction];
}

#pragma mark HeadDelegate

- (void)showSecondMenu {
    [UIView animateWithDuration:0.35 animations:^{
        _menu.frame = CGRectMake(0, 22, ScreenWidth, ScreenHeight - 22);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            _allLabel.frame = CGRectMake(10, 0, 70, 40);
            _finishButton.frame = CGRectMake(ScreenWidth -50 -10, 0, 50, 40);
        }];
    });
}

#pragma mark CollectView 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(72, 28);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:homeCollectionViewCell forIndexPath:indexPath];
    cell.homeLabel.text = @"我日爆炸了";
    cell.layer.borderColor = [UIColor colorWithWhite:0.914 alpha:1.000].CGColor;
    cell.layer.borderWidth = 1;
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HaedForCellView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:homeHeadCell forIndexPath:indexPath];
        cell.titleLabel.text = @"总部的新闻:";
        
        return cell;
    }else {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footForCell" forIndexPath:indexPath];
        return view;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(ScreenWidth, 50);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(ScreenWidth, 20);
}

#pragma mark web

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url = request.URL.absoluteString;

    if (url.length) {
        HomePushViewController *push = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomePushViewController"];
        push.url = url;
        
        [self.navigationController pushViewController:push animated:YES];
        return NO;
    }
    return YES;
}

#pragma mark 百度地图定位


//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    [_locService stopUserLocationService];
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    
    BMKGeoCodeSearch *geo = [[BMKGeoCodeSearch alloc] init];
    geo.delegate = self;
    
    BMKReverseGeoCodeOption *reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
    //需要逆地理编码的坐标位置
    reverseGeoCodeOption.reverseGeoPoint = pt;
    [geo reverseGeoCode:reverseGeoCodeOption];
}


- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    

    if (error == BMK_SEARCH_NO_ERROR)
    {
        
        [_head resetLocation:result.addressDetail.city];

    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_webViewProgressView setProgress:progress animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
