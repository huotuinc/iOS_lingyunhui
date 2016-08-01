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

@interface HomeController ()<WKUIDelegate,WKNavigationDelegate>

//@property (nonatomic, strong) UIView *menu;

//@property (nonatomic, strong) HTHeadNavView *head;

//@property (nonatomic, strong) UILabel *allLabel;

//@property (nonatomic, strong) UIButton *finishButton;

//@property (nonatomic, strong) UICollectionView *collectView;

//@property (nonatomic, strong) BMKLocationService *locService;
//
//@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;

//@property (nonatomic, strong)  NSString *showmeg;

@property (strong, nonatomic) UIProgressView *progressView;

@property(nonatomic,strong) MJRefreshNormalHeader * header;

@property (nonatomic, strong) NSString *homeUrl;

@end

@implementation HomeController

//- (void)viewDidLoad {
//    [super viewDidLoad];

//    self.tabBarItem.title = @"1231";
//    self.view.backgroundColor = [UIColor greenColor];
    
//    CGRect rect = CGRectMake(0, 20, ScreenWidth, 42);
//    
//    NSArray *array1 = @[@"最新",@"4S店咨询",@"厂端资讯"];
    
//    _head = [[HTHeadNavView alloc] initWithFrame:rect AndFirstArray:array1 AndAddress:nil];
//    _head.delegate = self;
//    [self.view addSubview:_head];
//    
//    _menu = [[UIView alloc] initWithFrame:CGRectMake(0, -ScreenHeight - 20, ScreenWidth, ScreenHeight - 22)];
//    _menu.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.643];
//    [_menu bk_whenTapped:^{
//        [self hidenMenuAndShowHead];
//    }];
//    [self.view addSubview:_menu];
//    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 42)];
//    view.backgroundColor = [UIColor whiteColor];
//    [_menu addSubview:view];
//    
//    _allLabel = [[UILabel alloc] initWithFrame:CGRectMake(-70, 0, 70, 40)];
//    _allLabel.text = @"全部频道";
//    _allLabel.textColor = [UIColor redColor];
//    _allLabel.font = [UIFont systemFontOfSize:15];
//    _allLabel.textAlignment = NSTextAlignmentCenter;
//    [view addSubview:_allLabel];
//    
//    _finishButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth + 50, 0, 50, 40)];
//    _finishButton.titleLabel.font = [UIFont systemFontOfSize:15];
//    [_finishButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
//    [_finishButton bk_whenTapped:^{
//        [self hidenMenuAndShowHead];
//    }];
//    [view addSubview:_finishButton];
//    
//    
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
//    layout.minimumLineSpacing = 5;
//    
//    
//    _collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 40, ScreenWidth - 0, ScreenHeight - 22 - 42)collectionViewLayout:layout];
//    _collectView.delegate = self;
//    _collectView.dataSource = self;
//    _collectView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
//    [_collectView setBackgroundColor:[UIColor clearColor]];
//    [_collectView registerNib:[UINib nibWithNibName:@"HomeCollectionCell" bundle:nil] forCellWithReuseIdentifier:homeCollectionViewCell];
//    [_collectView registerNib:[UINib nibWithNibName:@"HaedForCellView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:homeHeadCell];
//    [_collectView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footForCell"];
//    [_menu addSubview:_collectView];
//    
//    //定位服务
//    _locService = [[BMKLocationService alloc] init];
//    _locService.delegate = self;
//    [_locService startUserLocationService];
    
    
//}

//- (void)hidenMenuAndShowHead {
//    [UIView animateWithDuration:0.35 animations:^{
//        _allLabel.frame = CGRectMake(-70, 0, 70, 40);
//        _menu.frame = CGRectMake(0, -ScreenHeight - 22, ScreenWidth, ScreenHeight - 22);
//        _finishButton.frame = CGRectMake(ScreenWidth + 50, 0, 50, 40);
//    }];
//    
//    [self.head upAndDownReduction];
//}
//
//#pragma mark HeadDelegate
//
//- (void)showSecondMenu {
//    [UIView animateWithDuration:0.35 animations:^{
//        _menu.frame = CGRectMake(0, 22, ScreenWidth, ScreenHeight - 22);
//    }];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:0.25 animations:^{
//            _allLabel.frame = CGRectMake(10, 0, 70, 40);
//            _finishButton.frame = CGRectMake(ScreenWidth -50 -10, 0, 50, 40);
//        }];
//    });
//}
//
//#pragma mark CollectView 
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 3;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return 10;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(72, 28);
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    HomeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:homeCollectionViewCell forIndexPath:indexPath];
//    cell.homeLabel.text = @"我日爆炸了";
//    cell.layer.borderColor = [UIColor colorWithWhite:0.914 alpha:1.000].CGColor;
//    cell.layer.borderWidth = 1;
//    return cell;
//    
//}
//
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        
//        HaedForCellView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:homeHeadCell forIndexPath:indexPath];
//        cell.titleLabel.text = @"总部的新闻:";
//        
//        return cell;
//    }else {
//        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footForCell" forIndexPath:indexPath];
//        return view;
//    }
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    return CGSizeMake(ScreenWidth, 50);
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    return CGSizeMake(ScreenWidth, 20);
//}
//#pragma mark 百度地图定位
//
//
////处理位置坐标更新
//- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
//{
//    
//    [_locService stopUserLocationService];
//    
//    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
//    
//    BMKGeoCodeSearch *geo = [[BMKGeoCodeSearch alloc] init];
//    geo.delegate = self;
//    
//    BMKReverseGeoCodeOption *reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
//    //需要逆地理编码的坐标位置
//    reverseGeoCodeOption.reverseGeoPoint = pt;
//    [geo reverseGeoCode:reverseGeoCodeOption];
//}
//
//
//- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
//    
//
//    if (error == BMK_SEARCH_NO_ERROR)
//    {
//        
//        [_head resetLocation:result.addressDetail.city];
//
//    }
//}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, ScreenHeight -44 - 20)];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.customUserAgent = app.userAgent;
    [self.view addSubview:_webView];
    
    [self AddMjRefresh];
    
    [self initWebViewProgress];
    
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [path stringByAppendingPathComponent:ButtomBarItems];
    BarItemMenus *bars = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    if (bars) {        
        BarItem *bar = bars.bottomMenus[0];
        self.homeUrl = bar.url;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAgent) name:ResetAllWebAgent object:nil];
}

- (void)resetAgent {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.webView.customUserAgent = app.userAgent;
}

- (void)AddMjRefresh{
    
    //    // 添加下拉刷新控件
    MJRefreshNormalHeader * header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    header.stateLabel.hidden = YES;
    header.arrowView.image= nil;
    _header = header;
    self.webView.scrollView.mj_header = header;
    
}



/*
 *网页下拉刷新
 */
- (void)loadNewData{
    [self.webView reload];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.tabBarController.tabBar.hidden = NO;
    
    [self.view addSubview:_progressView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_homeUrl]]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_progressView removeFromSuperview];
}

#pragma mark web

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    
    NSString *url = webView.URL.absoluteString;
    
    
    if (url.length) {
        if ([url isEqualToString:_homeUrl]) {
            decisionHandler(WKNavigationResponsePolicyAllow);
        }else {
            HomePushViewController *push = [[HomePushViewController alloc] init];
            push.url = url;
        
            [self.navigationController pushViewController:push animated:YES];
            decisionHandler(WKNavigationResponsePolicyCancel);
        }
    }else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [_header endRefreshing];
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        self.title = title;
    }];
    [webView evaluateJavaScript:@"__getShareStr()" completionHandler:^(id _Nullable shareStr, NSError * _Nullable error) {
    }];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(nonnull NSString *)message initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(BOOL))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 *  初始化进度条
 */
- (void)initWebViewProgress {
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, 0, ScreenWidth, progressBarHeight);
//    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    self.progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    self.progressView.tintColor = [UIColor greenColor];
    self.progressView.trackTintColor = [UIColor whiteColor];
    
    
}

// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

#pragma mark 页面分享 

- (void)shareSDk {
    //1、创建分享参数
#pragma mark 分享修改
    
    [self.webView evaluateJavaScript:@"__getShareStr()" completionHandler:^(id _Nullable shareStr, NSError * _Nullable error) {
        
        NSString *str = shareStr;
        
        NSArray *array = [str componentsSeparatedByString:@"^"];
        if (array.count != 4) {
            return;
        }
        
        //1、创建分享参数
        NSArray* imageArray = @[[NSURL URLWithString:array[3]]];
        if (imageArray) {
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            [shareParams SSDKSetupShareParamsByText:array[1]
                                             images:imageArray
                                                url:[NSURL URLWithString:array[2]]
                                              title:array[0]
                                               type:SSDKContentTypeAuto];
            //2、分享（可以弹出我们的分享菜单和编辑界面）
            [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                     items:nil
                               shareParams:shareParams
                       onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                           
                           switch (state) {
                               case SSDKResponseStateSuccess:
                               {
                                   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"分享成果" message:nil preferredStyle:UIAlertControllerStyleAlert];
                                   [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                       
                                   }])];
                                   [self presentViewController:alertController animated:YES completion:nil];
                                   break;
                               }
                               case SSDKResponseStateFail:
                               {
                                   
                                   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"分享成果" message:[NSString stringWithFormat:@"%@",error] preferredStyle:UIAlertControllerStyleAlert];
                                   [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                       
                                   }])];
                                   [self presentViewController:alertController animated:YES completion:nil];
                                   break;
                               }
                               default:
                                   break;
                           }
                           
                       }];
            
        }
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
