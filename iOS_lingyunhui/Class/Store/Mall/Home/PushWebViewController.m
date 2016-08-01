//
//  PushWebViewController.m
//  HuoBanMallBuy
//
//  Created by lhb on 15/10/9.
//  Copyright (c) 2015年 HT. All rights reserved.
//  跳转的网页页面

#import "PushWebViewController.h"
#import "WXApi.h"
#import "payRequsestHandler.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "PayModel.h"
#import "AFNetworking.h"
#import "NSDictionary+HuoBanMallSign.h"
#import "UIViewController+MonitorNetWork.h"
#import <MJRefresh.h>
#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>
#import "UserLoginTool.h"
#import <SVProgressHUD.h>
#import "UserInfo.h"
#import "AppDelegate.h"
#import "MallPayModel.h"

@interface PushWebViewController ()<UIWebViewDelegate,UIActionSheetDelegate,NJKWebViewProgressDelegate,WKUIDelegate,WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;
/***/
@property(nonatomic,strong) NSMutableString * debugInfo;

/**刷新按钮标*/
@property (nonatomic,strong) UIButton * refreshBtn;
/**分享按钮*/
@property (nonatomic,strong) UIButton * shareBtn;
@property(nonatomic,strong) NSString * orderNo;       //订单号
@property(nonatomic,strong) NSString * priceNumber;  //订单价格
@property(nonatomic,strong) NSString * proDes;       //订单描述


@property(nonatomic,strong) PayModel * paymodel;

/**支付的url*/
@property(nonatomic,strong) NSString * ServerPayUrl;

@property (strong, nonatomic) UIProgressView *progressView;

//@property (nonatomic, strong) NJKWebViewProgressView *webViewProgressView;
//@property (nonatomic, strong) NJKWebViewProgress *webViewProgress;
@property (nonatomic, assign) BOOL bingWeixin;

@end


@implementation PushWebViewController



- (UIButton *)shareBtn{
    if (_shareBtn == nil) {
        _shareBtn = [[UIButton alloc] init];
        _shareBtn.frame = CGRectMake(0, 0, 25, 25);
        _shareBtn.userInteractionEnabled = NO;
        [_shareBtn addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_shareBtn setBackgroundImage:[UIImage imageNamed:@"home_title_right_share"] forState:UIControlStateNormal];
    }
    return _shareBtn;
}


-(UIButton *)refreshBtn{
    if (_refreshBtn == nil) {
        _refreshBtn = [[UIButton alloc] init];
        _refreshBtn.frame = CGRectMake(0, 0, 25, 25);
        [_refreshBtn addTarget:self action:@selector(refreshToWebView) forControlEvents:UIControlEventTouchUpInside];
        [_refreshBtn setBackgroundImage:[UIImage imageNamed:@"main_title_left_refresh"] forState:UIControlStateNormal];
        [_refreshBtn setBackgroundImage:[UIImage imageNamed:@"loading"] forState:UIControlStateHighlighted];
    }
    return _refreshBtn;
}


- (NSMutableString *)debugInfo{
    
    if (_debugInfo == nil) {
        
        _debugInfo = [NSMutableString string];
    }
    return _debugInfo;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)forBarMetrics:UIBarMetricsDefault];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.customUserAgent = app.userAgent;
    [self.view addSubview:self.webView];
    
    NSURL * urlStr = [NSURL URLWithString:_funUrl];
    NSURLRequest * req = [[NSURLRequest alloc] initWithURL:urlStr];
    self.webView.tag = 20;
    [self.webView loadRequest:req];
    
    //加载刷新控件
    [self AddMjRefresh];
    
    
    self.shareBtn.hidden = YES;
 
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.shareBtn]];
    [UIViewController MonitorNetWork];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(back) name:@"payback" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAgent) name:ResetAllWebAgent object:nil];
}

- (void)resetAgent {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.webView.customUserAgent = app.userAgent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar addSubview:_progressView];
}


- (void)AddMjRefresh{
    // 添加下拉刷新控件
    MJRefreshNormalHeader * header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    header.stateLabel.hidden = YES;
    header.arrowView.image= nil;
    self.webView.scrollView.mj_header = header;
}


/*
 *网页下拉刷新
 */
- (void)loadNewData{
    
    [self.webView reload];
}



/**
 *  返回
 */
- (void)back{
    
    [self.webView goBack];
}

/**
 *  刷新
 */
- (void)refreshToWebView{
   
    
    [_refreshBtn setBackgroundImage:[UIImage imageNamed:@"loading"] forState:UIControlStateNormal];
    self.refreshBtn.userInteractionEnabled = NO;
    [self.webView reload];
}


/**
 *  分享
 */
- (void)shareBtnClick{

    
    [self shareSdkSha];
}


- (void)shareSdkSha{
    
    //1、创建分享参数
#pragma mark 分享修改
    
    [self.webView evaluateJavaScript:@"__getShareStr()" completionHandler:^(id _Nullable str, NSError * _Nullable error) {
        
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



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (actionSheet.tag == 500) {//单个微信支付
        NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * filename = [[array objectAtIndex:0] stringByAppendingPathComponent:PayTypeflat];
        NSData *data = [NSData dataWithContentsOfFile:filename];
        // 2.创建反归档对象
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        // 3.解码并存到数组中
        NSArray *namesArray = [unArchiver decodeObjectForKey:PayTypeflat];
        [self WeiChatPay:namesArray[0]];
    }else if (actionSheet.tag == 700){// 单个支付宝支付
        //NSLog(@"支付宝%ld",(long)buttonIndex);
//        [self MallAliPay:self.paymodel];
    }else if(actionSheet.tag == 900){//两个都有的支付
        //0
        //1
        NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * filename = [[array objectAtIndex:0] stringByAppendingPathComponent:PayTypeflat];
        NSData *data = [NSData dataWithContentsOfFile:filename];
        // 2.创建反归档对象
        NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        // 3.解码并存到数组中
        NSArray *namesArray = [unArchiver decodeObjectForKey:PayTypeflat];
        if (buttonIndex==0) {//支付宝
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
        }
        if (buttonIndex==1) {//微信
            PayModel * paymodel =  namesArray[0];
            if ([paymodel.payType integerValue] == 300) {
                [self WeiChatPay:namesArray[0]];
            }else{
                [self WeiChatPay:namesArray[1]];//微信
            }
            
        }
        
    }
    
}
/**
 *  商城支付宝支付
 */
- (void)MallAliPay:(PayModel *)pay{

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

- (void)dealloc{
//    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_progressView removeFromSuperview];
}

#pragma mark wk

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSString *temp = webView.URL.absoluteString;
    NSString *url = [temp lowercaseString];
    if ([url isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
    if ([url rangeOfString:@"/UserCenter/Login.aspx"].location != NSNotFound) {
        [UIViewController ToRemoveSandBoxDate];
        NSString *goUrl = [[NSString alloc] init];
        if ([url rangeOfString:@"redirectUrl="].location != NSNotFound) {
            NSArray *array = [url componentsSeparatedByString:@"redirectUrl="];
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
        decisionHandler(WKNavigationResponsePolicyCancel);
        
    }else{
        NSRange range = [url rangeOfString:@"AppAlipay.aspx"];
        
        if (range.location != NSNotFound) {
            self.ServerPayUrl = [url copy];
            NSRange trade_no = [url rangeOfString:@"trade_no="];
            NSRange customerID = [url rangeOfString:@"customerID="];
            //            NSRange paymentType = [url rangeOfString:@"paymentType="];
            NSRange trade_noRange = {trade_no.location + 9,customerID.location-trade_no.location-10};
            NSString * trade_noss = [url substringWithRange:trade_noRange];//订单号
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
            NSString * to = [NSDictionary ToSignUrlWithString:url];
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
                            UIActionSheet * aa =  [[UIActionSheet alloc] initWithTitle:@"支付方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信", nil];
                            aa.tag = 500;//单个微信支付
                            [aa showInView:self.view];
                        }
                        if ([pay.payType integerValue] == 400) {//400支付宝
                            UIActionSheet * aa =  [[UIActionSheet alloc] initWithTitle:@"支付方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"支付宝", nil];
                            aa.tag = 700;//单个支付宝支付
                            [aa showInView:self.view];
                        }
                    }else if(namesArray.count == 2){
                        UIActionSheet * aa =  [[UIActionSheet alloc] initWithTitle:@"支付方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"支付宝",@"微信", nil];
                        aa.tag = 900;//两个都有的支付
                        [aa showInView:self.view];
                    }
                    
                }
                
            } failure:^(NSError *error) {
                LWLog(@"xxx");
            }];
            decisionHandler(WKNavigationResponsePolicyCancel);
        }
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    [webView evaluateJavaScript:@"__getShareStr()" completionHandler:^(id _Nullable shareStr, NSError * _Nullable error) {
        NSString *str = shareStr;
        if (str.length != 0) {
            self.shareBtn.hidden = NO;
        }else {
            self.shareBtn.hidden = YES;
        }
    }];
    
    [_refreshBtn setBackgroundImage:[UIImage imageNamed:@"main_title_left_refresh"] forState:UIControlStateNormal];
    
    self.refreshBtn.userInteractionEnabled = YES;
    
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        NSString *str = title;
        self.title = str;
    }];

    _shareBtn.userInteractionEnabled = YES;
    [self.webView.scrollView.mj_header endRefreshing];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    _shareBtn.userInteractionEnabled = NO;
}
- (void)restPushWebAgent {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.webView.customUserAgent = app.userAgent;
}

/**
 *  初始化进度条
 */
- (void)initWebViewProgress {
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    self.progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    self.progressView.tintColor = [UIColor greenColor];
    self.progressView.trackTintColor = HuoBanMallBuyNavColor;
    [self.navigationController.navigationBar addSubview:_progressView];
    
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




@end
