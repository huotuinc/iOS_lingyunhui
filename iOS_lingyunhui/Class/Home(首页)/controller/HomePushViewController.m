//
//  HomePushViewController.m
//  iOS_lingyunhui
//
//  Created by 刘琛 on 16/5/31.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import "HomePushViewController.h"
#import "NSDictionary+HuoBanMallSign.h"
#import "MallPayModel.h"
#import "WXApi.h"
#import "payRequsestHandler.h"
#import <BlocksKit/UIBarButtonItem+BlocksKit.h>

@interface HomePushViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) UIProgressView *progressView;

@property(nonatomic,strong) NSString * orderNo;       //订单号
@property(nonatomic,strong) NSString * priceNumber;  //订单价格
@property(nonatomic,strong) NSString * proDes;       //订单描述
/**支付的url*/
@property(nonatomic,strong) NSString * ServerPayUrl;

@property(nonatomic,strong) PayModel * paymodel;

@property(nonatomic,strong) NSMutableString * debugInfo;

@property(nonatomic,strong) MJRefreshNormalHeader * header;

@end

@implementation HomePushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, self.view.bounds.size.height - 64)];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.customUserAgent = app.userAgent;
    [self.view addSubview:self.webView];
    
    [self AddMjRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAgent) name:ResetAllWebAgent object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goNextUrl:) name:GoToNextWeb object:nil];
}

- (void)resetAgent {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.webView.customUserAgent = app.userAgent;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (_url.length) {
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
        [self.webView loadRequest:req];
    }
    
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar addSubview:_progressView];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_progressView removeFromSuperview];
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

- (void)goNextUrl:(NSNotification *) note{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GoToNextWeb object:nil];
    
    NSString * backUrl = [note.userInfo objectForKey:@"url"];
    if (backUrl) {
        NSURL * newUrl = [NSURL URLWithString:backUrl];
        NSURLRequest * req = [[NSURLRequest alloc] initWithURL:newUrl];
        [self.webView loadRequest:req];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goNextUrl:) name:GoToNextWeb object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goNextUrl:) name:GoToNextWeb object:nil];
    }
}

#pragma mark web

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    
    NSString *tempUrl = webView.URL.absoluteString;
    if ([tempUrl rangeOfString:@"AppAlipay.aspx"].location != NSNotFound) {

            self.ServerPayUrl = [tempUrl copy];
            NSRange trade_no = [tempUrl rangeOfString:@"trade_no="];
            NSRange customerID = [tempUrl rangeOfString:@"customerID="];
            //            NSRange paymentType = [url rangeOfString:@"paymentType="];
            NSRange trade_noRange = {trade_no.location + 9,customerID.location-trade_no.location-10};
            NSString * trade_noss = [tempUrl substringWithRange:trade_noRange];//订单号
            self.orderNo = trade_noss;
            //            NSString * payType = [url substringFromIndex:paymentType.location+paymentType.length];
            // 1.得到data
            NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * filename = [[array objectAtIndex:0] stringByAppendingPathComponent:PayTypeflat];
            NSData *data = [NSData dataWithContentsOfFile:filename];
            // 2.创建反归档对象
            NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            // 3.解码并存到数组中
            NSArray *namesArray = [unArchiver decodeObjectForKey:PayTypeflat];
            NSMutableString * url = [NSMutableString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:WebSit]];
            [url appendFormat:@"%@?orderid=%@",@"/order/GetOrderInfo",trade_noss];
            NSString * to = [NSDictionary ToSignUrlWithString:tempUrl];
            [UserLoginTool ordorRequestGet:to parame:nil success:^(id json) {
                LWLog(@"%@",json);
                if ([json[@"code"] integerValue] == 200) {
                    self.priceNumber = json[@"data"][@"Final_Amount"];
                    //                    NSLog(@"%@",self.priceNumber);
                    NSString * des =  json[@"data"][@"ToStr"]; //商品描述
                    //                    NSLog(@"%@",json[@"data"][@"ToStr"]);
                    self.proDes = [des copy];
                    //                    NSLog(@"%@",self.proDes);
                    if(namesArray.count == 1){
                        MallPayModel * pay =  namesArray.firstObject;  //300微信  400支付宝
                        self.paymodel = pay;
                        if ([pay.payType integerValue] == 300) {//300微信
                            
                            UIAlertController *aa = [UIAlertController alertControllerWithTitle:@"支付方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                            [aa addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            }]];
                            [aa addAction:[UIAlertAction actionWithTitle:@"微信支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                NSString * filename = [[array objectAtIndex:0] stringByAppendingPathComponent:PayTypeflat];
                                NSData *data = [NSData dataWithContentsOfFile:filename];
                                // 2.创建反归档对象
                                NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                                // 3.解码并存到数组中
                                NSArray *namesArray = [unArchiver decodeObjectForKey:PayTypeflat];
                                [self WeiChatPay:namesArray[0]];
                            }]];
                            [self presentViewController:aa animated:YES completion:nil];
                        }
                        if ([pay.payType integerValue] == 400) {//400支付宝
                            
                            UIAlertController *aa = [UIAlertController alertControllerWithTitle:@"支付方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                            [aa addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            }]];
                            [aa addAction:[UIAlertAction actionWithTitle:@"支付宝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                PayModel * paymodel =  namesArray[0];
                                PayModel *cc =  [paymodel.payType integerValue] == 400?namesArray[0]:namesArray[1];
                                if (cc.webPagePay) {//网页支付
                                    NSRange parameRange = [self.ServerPayUrl rangeOfString:@"?"];
                                    NSString * par = [self.ServerPayUrl substringFromIndex:(parameRange.location+parameRange.length)];
                                    NSArray * arr = [par componentsSeparatedByString:@"&"];
                                    __block NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                                    [arr enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
                                        NSArray * aa = [obj componentsSeparatedByString:@"="];
                                        NSDictionary * dt = [NSDictionary dictionaryWithObject:aa[1] forKey:aa[0]];
                                        [dict addEntriesFromDictionary:dt];
                                    }];
                                    NSString * js = [NSString stringWithFormat:@"utils.Go2Payment(%@, %@, 1, false)",dict[@"customerID"],dict[@"trade_no"]];
                                    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable str , NSError * _Nullable error) {
                                        
                                    }];
                                }else{
                                    [self MallAliPay:cc];
                                }
                            }]];
                            [self presentViewController:aa animated:YES completion:nil];
                            
                        }
                    }else if(namesArray.count == 2){
                        
                        UIAlertController *aa = [UIAlertController alertControllerWithTitle:@"支付方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                        [aa addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        }]];
                        [aa addAction:[UIAlertAction actionWithTitle:@"微信支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString * filename = [[array objectAtIndex:0] stringByAppendingPathComponent:PayTypeflat];
                            NSData *data = [NSData dataWithContentsOfFile:filename];
                            // 2.创建反归档对象
                            NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                            // 3.解码并存到数组中
                            NSArray *namesArray = [unArchiver decodeObjectForKey:PayTypeflat];
                            [self WeiChatPay:namesArray[0]];
                        }]];
                        [aa addAction:[UIAlertAction actionWithTitle:@"支付宝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            PayModel * paymodel =  namesArray[0];
                            PayModel *cc =  [paymodel.payType integerValue] == 400?namesArray[0]:namesArray[1];
                            if (cc.webPagePay) {//网页支付
                                NSRange parameRange = [self.ServerPayUrl rangeOfString:@"?"];
                                NSString * par = [self.ServerPayUrl substringFromIndex:(parameRange.location+parameRange.length)];
                                NSArray * arr = [par componentsSeparatedByString:@"&"];
                                __block NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                                [arr enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
                                    NSArray * aa = [obj componentsSeparatedByString:@"="];
                                    NSDictionary * dt = [NSDictionary dictionaryWithObject:aa[1] forKey:aa[0]];
                                    [dict addEntriesFromDictionary:dt];
                                }];
                                NSString * js = [NSString stringWithFormat:@"utils.Go2Payment(%@, %@, 1, false)",dict[@"customerID"],dict[@"trade_no"]];
                                [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable str , NSError * _Nullable error) {
                                    
                                }];
                            }else{
                                [self MallAliPay:cc];
                            }
                        }]];
                        [self presentViewController:aa animated:YES completion:nil];
                    }
                    
                }
                
            } failure:^(NSError *error) {
                LWLog(@"xxx");
            }];
            decisionHandler(WKNavigationResponsePolicyCancel);
    }else if ([tempUrl rangeOfString:@"/UserCenter/Login.aspx"].location !=  NSNotFound) {
        
        [UIViewController ToRemoveSandBoxDate];
        NSString *goUrl = [[NSString alloc] init];
        if ([tempUrl rangeOfString:@"redirectUrl="].location != NSNotFound) {
            NSArray *array = [tempUrl componentsSeparatedByString:@"redirectUrl="];
            NSString *str = array[1];
            if (str.length != 0) {
                goUrl = [str stringByRemovingPercentEncoding];
                if ([goUrl rangeOfString:@"http:"].location == NSNotFound) {
                    goUrl = [NSString stringWithFormat:@"%@%@",@"http://olquan.huobanj.cn", goUrl];
                }
            }
        }else {
            NSString * uraaa = MKMainUrl;
            NSString * ddd = [NSString stringWithFormat:@"%@/%@/index.aspx?back=1",uraaa,HuoBanMallBuyApp_Merchant_Id];
            goUrl = ddd;
        }
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginController *login = [story instantiateViewControllerWithIdentifier:@"LoginController"];
        login.goUrl = goUrl;
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];
        [self presentViewController:loginNav animated:YES completion:nil];
        
    }else if (tempUrl.length) {
        if ([tempUrl isEqualToString:_url]) {
            decisionHandler(WKNavigationResponsePolicyAllow);
        }else {
            HomePushViewController *push = [[HomePushViewController alloc] init];
            push.url = tempUrl;
            
            [self.navigationController pushViewController:push animated:YES];
            decisionHandler(WKNavigationResponsePolicyCancel);
        }
    }else{
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_header endRefreshing];
    [webView evaluateJavaScript:@"__getShareStr()" completionHandler:^(id _Nullable shareStr, NSError * _Nullable error) {
        NSString *str = shareStr;
        if (str.length != 0) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"home_title_right_share"] style:UIBarButtonItemStylePlain handler:^(id sender) {
                [self shareSdkSha];
            }];
        }else {
            self.navigationItem.rightBarButtonItem = nil;
        }
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
    self.progressView.trackTintColor = HuoBanMallBuyNavColor;
    
    
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


#pragma mark 分享
- (void)shareSdkSha{
    
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
                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                       message:nil
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"确定"
                                                                             otherButtonTitles:nil];
                                   [alertView show];
                                   break;
                               }
                               case SSDKResponseStateFail:
                               {
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                                   message:[NSString stringWithFormat:@"%@",error]
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil, nil];
                                   [alert show];
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


/**
 *  微信支付
 */
- (void)WeiChatPay:(PayModel *)model{
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [self PayByWeiXinParame:model];
    if(dict != nil){
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        [WXApi sendReq:req];
    }else{
        NSLog(@"提示信息----微信预支付失败");
    }
}


/**
 *  微信支付预zhifu
 */
- (NSMutableDictionary *)PayByWeiXinParame:(PayModel *)paymodel{
    
    payRequsestHandler * payManager = [[payRequsestHandler alloc] init];
    [payManager setKey:paymodel.appKey];
    
    //    NSLog(@"%@-----%@ -----",paymodel.appId,paymodel.partnerId);
    BOOL isOk = [payManager init:paymodel.appId mch_id:paymodel.partnerId];
    if (isOk) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
        params[@"appid"] = paymodel.appId;
        params[@"mch_id"] =paymodel.partnerId;     //微信支付分配的商户号
        params[@"nonce_str"] = noncestr; //随机字符串，不长于32位。推荐随机数生成算法
        params[@"trade_type"] = @"APP";   //取值如下：JSAPI，NATIVE，APP，WAP,详细说明见参数规定
        params[@"body"] = MallName; //商品或支付单简要描述
        //        NSLog(@"self.proDes%@",self.proDes);
        NSString * uraaa = [[NSUserDefaults standardUserDefaults] objectForKey:WebSit];
        NSMutableString * urls = [NSMutableString stringWithString:uraaa];
        [urls appendString:paymodel.notify];
        params[@"notify_url"] = urls;  //接收微信支付异步通知回调地址
        params[@"out_trade_no"] = self.orderNo; //订单号
        params[@"spbill_create_ip"] = @"192.168.1.1"; //APP和网页支付提交用户端ip，Native支付填调用微信支付API的机器IP。
        params[@"total_fee"] = [NSString stringWithFormat:@"%.f",[self.priceNumber floatValue] * 100];  //订单总金额，只能为整数，详见支付金额
        params[@"device_info"] = ([[UIDevice currentDevice].identifierForVendor UUIDString]);
        params[@"attach"] = [NSString stringWithFormat:@"%@_0",HuoBanMallBuyApp_Merchant_Id];
        //获取prepayId（预支付交易会话标识）
        NSString * prePayid = nil;
        prePayid  = [payManager sendPrepay:params];
        //        [payManager getDebugifo];
        //        NSLog(@"%@",[payManager getDebugifo]);
        if ( prePayid != nil) {
            //获取到prepayid后进行第二次签名
            NSString    *package, *time_stamp, *nonce_str;
            //设置支付参数
            time_t now;
            time(&now);
            time_stamp  = [NSString stringWithFormat:@"%ld", now];
            nonce_str	= [WXUtil md5:time_stamp];
            //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
            //package       = [NSString stringWithFormat:@"Sign=%@",package];
            package         = @"Sign=WXPay";
            //第二次签名参数列表
            NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
            [signParams setObject: paymodel.appId  forKey:@"appid"];
            [signParams setObject: nonce_str    forKey:@"noncestr"];
            [signParams setObject: package      forKey:@"package"];
            [signParams setObject: paymodel.partnerId   forKey:@"partnerid"];
            [signParams setObject: time_stamp   forKey:@"timestamp"];
            [signParams setObject: prePayid     forKey:@"prepayid"];
            //生成签名
            NSString *sign  = [payManager createMd5Sign:signParams];
            //添加签名
            [signParams setObject: sign forKey:@"sign"];
            [_debugInfo appendFormat:@"第二步签名成功，sign＝%@\n",sign];
            //返回参数列表
            return signParams;
        }else{
            [_debugInfo appendFormat:@"获取prepayid失败！\n"];
        }
        
    }
    return nil;
}
/**
 *  商城支付宝支付
 */
- (void)MallAliPay:(PayModel *)pay{
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
