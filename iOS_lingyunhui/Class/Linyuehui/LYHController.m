//
//  LYHController.m
//  iOS_linyunhui
//
//  Created by 刘琛 on 16/5/25.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import "LYHController.h"
#import <BlocksKit/UIBarButtonItem+BlocksKit.h>

@interface LYHController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) UIProgressView *progressView;

@property(nonatomic,strong) MJRefreshNormalHeader * header;

@property (nonatomic, strong) NSString *LYHUrl;

@end

@implementation LYHController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight -44 - 64)];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.customUserAgent = app.userAgent;
    [self.view addSubview:_webView];
    
    [self AddMjRefresh];
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [path stringByAppendingPathComponent:ButtomBarItems];
    BarItemMenus *bars = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    BarItem *bar = bars.bottomMenus[1];
    self.LYHUrl = bar.url;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAgent) name:ResetAllWebAgent object:nil];
    
    [self initWebViewProgress];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_progressView removeFromSuperview];
}


/*
 *网页下拉刷新
 */
- (void)loadNewData{
    [self.webView reload];
}
#pragma mark web

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSString *url = webView.URL.absoluteString;
    if (url.length) {
        HomePushViewController *push = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomePushViewController"];
        push.url = url;
        
        [self.navigationController pushViewController:push animated:YES];
        decisionHandler(WKNavigationResponsePolicyCancel);
    }else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"__getShareStr()" completionHandler:^(id _Nullable shareStr, NSError * _Nullable error) {
        NSString *str = shareStr;
        if (str.length != 0) {
            self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"home_title_right_share"] style:UIBarButtonItemStylePlain handler:^(id sender) {
//                [self ]
            }];
        }else {
            self.navigationController.navigationItem.rightBarButtonItem = nil;
        }
    }];
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        self.title = title;
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
//    CGRect barFrame = CGRectMake(0, 0, ScreenWidth, progressBarHeight);
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
