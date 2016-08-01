
//  HomeViewController.m
//  HuoBanMallBuy
//
//  Created by lhb on 15/9/5.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "HomeViewController.h"
#import <BlocksKit+UIKit.h>
#import <MJRefresh.h>
#import "UIViewController+NAV.h"
#import "MJExtension.h"
#import "PushWebViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "NSDictionary+HuoBanMallSign.h"
#import "AppDelegate.h"
#import "MidTabelViewCell.h"
#import "UIViewController+MonitorNetWork.h"
#import "PayModel.h"
#import <SDWebImageManager.h>
#import "WXApi.h"
#import "payRequsestHandler.h"
#import "UserLoginTool.h"
#import <SVProgressHUD.h>
#import "UserInfo.h"
#import "MallPayModel.h"
#import "AppConfig.h"

@interface HomeViewController()<UIWebViewDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,WKUIDelegate,WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *homeWebView;


@property (strong, nonatomic) UIWebView *homeBottonWebView;

/***/
@property(nonatomic,strong) NSMutableString * debugInfo;
/**
 *  是否显示返回按钮
 *  1、表示显示
 *  2、表示不显示
 */
@property(nonatomic,assign) BOOL showBackArrows;

/**底部网页约束高度*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeBottonWebViewHeight;
/**图标*/
@property (nonatomic,strong) UIButton * backArrow;
/**返回按钮*/
@property (nonatomic,strong) UIButton * leftOption;

/**刷新按钮标*/
@property (nonatomic,strong) UIButton * refreshBtn;
/**分享按钮*/
@property (nonatomic,strong) UIButton * shareBtn;

/**登陆后的背景遮罩*/
@property (nonatomic,strong) UIView * backView;

@property(nonatomic,strong) NSString * orderNo;       //订单号
@property(nonatomic,strong) NSString * priceNumber;  //订单价格
@property(nonatomic,strong) NSString * proDes;       //订单描述
/**支付的url*/
@property(nonatomic,strong) NSString * ServerPayUrl;

@property(nonatomic,strong) PayModel * paymodel;

@property (strong, nonatomic) UIProgressView *progressView;

@property (nonatomic, assign) BOOL bingWeixin;

@property (nonatomic, strong) NSString *bingWeixinUrl;

@end


@implementation HomeViewController


- (NSMutableString *)debugInfo{
    
    if (_debugInfo == nil) {
        
        _debugInfo = [NSMutableString string];
    }
    return _debugInfo;

}


- (UIButton *)backArrow{
    if (_backArrow == nil) {
        _backArrow = [[UIButton alloc] init];
        _backArrow.frame = CGRectMake(0, 0, 25, 25);
        [_backArrow addTarget:self action:@selector(BackToWebView) forControlEvents:UIControlEventTouchUpInside];
        [_backArrow setBackgroundImage:[UIImage imageNamed:@"main_title_left_back"] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backArrow];
    }
    return _backArrow;
}

- (UIButton *)leftOption{
    
    if (_leftOption == nil) {
        _leftOption = [[UIButton alloc] init];
        _leftOption.frame = CGRectMake(0, 0, 25, 25);
        [_leftOption addTarget:self action:@selector(GoToLeft) forControlEvents:UIControlEventTouchUpInside];
        [_leftOption setBackgroundImage:[UIImage imageNamed:@"main_title_left_sideslip"] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftOption];
    }
    return _leftOption;
}


- (UIButton *)shareBtn{
    if (_shareBtn == nil) {
        _shareBtn = [[UIButton alloc] init];
        _shareBtn.frame = CGRectMake(0, 0, 25, 25);
        _shareBtn.userInteractionEnabled = NO;
        [_shareBtn addTarget:self action:@selector(shareBtnClicks) forControlEvents:UIControlEventTouchUpInside];
        [_shareBtn setBackgroundImage:[UIImage imageNamed:@"home_title_right_share"] forState:UIControlStateNormal];
    }
    return _shareBtn;
}


-(UIButton *)refreshBtn{
    if (_refreshBtn == nil) {
        _refreshBtn = [[UIButton alloc] init];
        _refreshBtn.frame = CGRectMake(0, 0, 25, 25);
        [_refreshBtn addTarget:self action:@selector(refreshToWebViews) forControlEvents:UIControlEventTouchUpInside];
        [_refreshBtn setBackgroundImage:[UIImage imageNamed:@"main_title_left_refresh"] forState:UIControlStateNormal];
        [_refreshBtn setBackgroundImage:[UIImage imageNamed:@"loading"] forState:UIControlStateHighlighted];
    }
    return _refreshBtn;
}

/**
 *  刷新
 */
- (void)refreshToWebViews{
     [_refreshBtn setBackgroundImage:[UIImage imageNamed:@"loading"] forState:UIControlStateNormal];
    self.refreshBtn.userInteractionEnabled = NO;

    [self.homeWebView reload];
}

/**
 *  分享
 */
- (void)shareBtnClicks{
    [self shareSdkSha];
}




/**
 *  分享url处理
 */
- (NSString *) toCutew:(NSString *)urs{
    
    NSString * gduid = [[NSUserDefaults standardUserDefaults] objectForKey:LYHUserId];
    
    NSRange rang = [urs rangeOfString:@"?"];
    
    if (rang.location != NSNotFound) {
        NSString * back = [urs substringFromIndex:rang.location + 1];
        
        NSArray * aa =  [back componentsSeparatedByString:@"&"];
        
        __block NSMutableArray * todelete = [NSMutableArray arrayWithArray:aa];
        
        NSArray * key = @[@"unionid",@"appid",@"sign"];
        [aa enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [key enumerateObjectsUsingBlock:^(NSString * key, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj containsString:key]) {
                    [todelete removeObject:obj];
                }
            }];
        }];
        
        NSMutableString * cc = [[NSMutableString alloc] init];
        [todelete enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *  stop) {
            
            [cc appendFormat:@"%@&",obj];
        }];
        [cc appendFormat:@"gduid=%@",gduid];
        
        NSString * ee = [urs substringToIndex:rang.location+1];
        
        NSString * dd = [NSString stringWithFormat:@"%@%@",ee,cc];
        
        
        return dd;
    }else {
        return urs;
    }
    
}

- (void)shareSdkSha{
    
    //1、创建分享参数
#pragma mark 分享修改
    
    [self.homeWebView evaluateJavaScript:@"__getShareStr()" completionHandler:^(id _Nullable shareStr, NSError * _Nullable error) {
        
        NSString *str = shareStr;
        
        NSArray *array = [str componentsSeparatedByString:@"^"];
        if (array.count != 4) {
            return;
        }
        NSString *temp = [self toCutew:array[2]];
        
        //1、创建分享参数
        NSArray* imageArray = @[[NSURL URLWithString:array[3]]];
        if (imageArray) {
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            [shareParams SSDKSetupShareParamsByText:array[1]
                                             images:imageArray
                                                url:[NSURL URLWithString:temp]
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


- (void)viewDidLoad{
    [super viewDidLoad];
//    WKWebsiteDataRecord *rec = [
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.homeWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 50)];
    self.homeWebView.navigationDelegate = self;
    self.homeWebView.UIDelegate = self;
    self.homeWebView.tag = 100;
    self.homeWebView.customUserAgent = app.userAgent;
//    self.homeWebView
    [self.homeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.HomeWebUrl]]];
    [self.view addSubview:self.homeWebView];
    
    self.homeBottonWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _homeWebView.frame.size.height, ScreenWidth, 50)];
    self.homeBottonWebView.tag = 20;
    self.homeBottonWebView.delegate = self;
    [self.homeBottonWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.HomeButtomUrl]]];
    [self.view addSubview:self.homeBottonWebView];

    
    self.navigationController.navigationBar.alpha = 0;
    self.navigationController.navigationBar.barTintColor = HuoBanMallBuyNavColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftOption];
    
    //集成刷新控件
    [self AddMjRefresh];
    self.shareBtn.hidden = YES;
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.shareBtn]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetHomeWebAgent) name:ResetAllWebAgent object:nil];
    
    [UIViewController MonitorNetWork];
    
    [self initWebViewProgress];
}



- (void)AddMjRefresh{
    // 添加下拉刷新控件
    MJRefreshNormalHeader * header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    header.stateLabel.hidden = YES;
    header.arrowView.image= nil;
    self.homeWebView.scrollView.mj_header = header;

}




/*
 *网页下拉刷新
 */
- (void)loadNewData{
    [self.homeWebView reload];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
    
    [self.homeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_HomeWebUrl]]];
    [self.homeBottonWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_HomeButtomUrl]]];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}


/**
 *  网页
 */
- (void)BackToWebView{
    if ([self.homeWebView canGoBack]) {
        [self.homeWebView goBack];
    }
}

- (void)GoToLeft {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CannelLoginFailure object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIView *)ReturnNavPictureWithName:(NSString *)name andTwo:(NSString *)share{
 
    return nil;
}

- (UIView *)ReturnNavPictureWithName:(NSString *)name{
    
    UIButton *leftbutton = [[UIButton alloc] init];
    if ([name isEqualToString:@"home_title_left_menu"]) {
        leftbutton.tag = 0;
    }else{
        leftbutton.tag = 1;
    }
    leftbutton.frame = CGRectMake(0, 0, 25, 25);
    [leftbutton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [leftbutton setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    return leftbutton;
}


- (void)ocappCallJspoc{
    [self.homeWebView evaluateJavaScript:@"alert(1);" completionHandler:^(id _Nullable tempStr, NSError * _Nullable error) {
        
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
//                [self.homeWebView stringByEvaluatingJavaScriptFromString:js];
                [self.homeWebView evaluateJavaScript:js completionHandler:^(id _Nullable js, NSError * _Nullable error) {
                    
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
    BOOL isOk = [payManager init:self.paymodel.appId mch_id:self.paymodel.partnerId];
    if (isOk) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
        params[@"appid"] = paymodel.appId;
        params[@"mch_id"] = paymodel.partnerId;     //微信支付分配的商户号
        params[@"nonce_str"] = noncestr; //随机字符串，不长于32位。推荐随机数生成算法
        params[@"trade_type"] = @"APP";   //取值如下：JSAPI，NATIVE，APP，WAP,详细说明见参数规定
        params[@"body"] = MallName; //商品或支付单简要描述
        NSMutableString * urls = [[NSUserDefaults standardUserDefaults] objectForKey:WebSit];
        [urls appendString:paymodel.notify];
        params[@"notify_url"] = urls;  //接收微信支付异步通知回调地址
        
        NSString * order = [NSString stringWithFormat:@"%@_%@_%d",self.orderNo,HuoBanMallBuyApp_Merchant_Id,(arc4random() % 900 + 100)];
        params[@"out_trade_no"] = order; //订单号
        params[@"spbill_create_ip"] = @"192.168.1.1"; //APP和网页支付提交用户端ip，Native支付填调用微信支付API的机器IP。
        params[@"total_fee"] = [NSString stringWithFormat:@"%.f",[self.priceNumber floatValue] * 100];  //订单总金额，只能为整数，详见支付金额
        params[@"device_info"] = ([[UIDevice currentDevice].identifierForVendor UUIDString]);
        params[@"attach"] = [NSString stringWithFormat:@"%@_0",HuoBanMallBuyApp_Merchant_Id];
        //获取prepayId（预支付交易会话标识）
        NSString * prePayid = nil;
        prePayid  = [payManager sendPrepay:params];
//        NSLog(@"xcaccasc%@",[payManager getDebugifo]);
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
            [signParams setObject: paymodel.appId   forKey:@"appid"];
            [signParams setObject: nonce_str    forKey:@"noncestr"];
            [signParams setObject: package      forKey:@"package"];
            [signParams setObject: @"1251040401"   forKey:@"partnerid"];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.homeWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_progressView removeFromSuperview];
}
#pragma mark UIWebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *temp = request.URL.absoluteString;
    NSString *url = [temp lowercaseString];

    
    if ([temp isEqualToString:self.HomeButtomUrl]) {
        return YES;
    }else if([url rangeOfString:@"http://wpa.qq.com/msgrd?v=3&uin"].location != NSNotFound){
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]]; //拨号
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/cn/app/qq/id451108668?mt=12"]]; //拨号
        }
        return NO;
    }else {
        
        NSRange range = [url rangeOfString:@"back"];
        NSString * newUrls = nil;
        if (range.location != NSNotFound) {
            
            newUrls = [url stringByReplacingCharactersInRange:range withString:@"back=1"];
        }else{
            newUrls = [NSString stringWithFormat:@"%@?back=1",url];
        }
        
//        NSRange ran = [newUrls rangeOfString:@"aspx"];
////        NSString * newUrl = nil;
//        if (ran.location != NSNotFound) {
//            NSRange cc = NSMakeRange(ran.location+ran.length, 1);
//            newUrl = [newUrls stringByReplacingCharactersInRange:cc withString:@"?"];
//        }
//        NSString * dddd = [NSDictionary ToSignUrlWithString:newUrl];
//        NSURL * urlStr = [NSURL URLWithString:dddd];
        NSURLRequest * req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:newUrls]];
        [self.homeWebView loadRequest:req];
        return NO;
    }
    return YES;
}

#pragma mark wkWebView

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    
   
    NSString *temp = webView.URL.absoluteString;
    NSString *url = [temp lowercaseString];
    if ([url isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
    if (webView.tag == 100) {
        if ([url rangeOfString:@"qq"].location !=  NSNotFound) {
            decisionHandler(WKNavigationResponsePolicyAllow);
        }
        if ([url rangeOfString:@"appalipay.aspx"].location != NSNotFound){
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
                LWLog(@"%@", json);
                if ([json[@"code"] integerValue] == 200) {
                    self.priceNumber = json[@"data"][@"Final_Amount"];
                    NSString * des =  json[@"data"][@"ToStr"]; //商品描述
                    self.proDes = des;
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
                
            }];
            decisionHandler(WKNavigationResponsePolicyCancel);
            
            
            
        }else{
            
            NSRange range = [url rangeOfString:@"__newframe"];
            if (range.location != NSNotFound) {
                UIStoryboard * mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                PushWebViewController * funWeb =  [mainStory instantiateViewControllerWithIdentifier:@"PushWebViewController"];
                funWeb.funUrl = url;
                [self.navigationController pushViewController:funWeb animated:YES];
                decisionHandler(WKNavigationResponsePolicyCancel);
            }else{
                
                NSRange range = [url rangeOfString:@"back"];
                if (range.location != NSNotFound) {
                    self.showBackArrows = YES;
                }else{
                    if ([temp isEqualToString:self.HomeWebUrl]) {
                        self.showBackArrows = YES;
                    }
                    self.showBackArrows = NO;
                }
                decisionHandler(WKNavigationResponsePolicyAllow);
            }
            
            
        }
        
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [_refreshBtn setBackgroundImage:[UIImage imageNamed:@"main_title_left_refresh"] forState:UIControlStateNormal];
    
    self.refreshBtn.userInteractionEnabled = YES;
    
    
    if (webView.tag == 100) {
        
        [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
            self.title = title;
        }];
        
        if (_showBackArrows) {//返回按钮
            
            [UIView animateWithDuration:0.05 animations:^{
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftOption];
            }];
        }else{
            [UIView animateWithDuration:0.05 animations:^{
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backArrow];
            }];
        }
        
        [webView evaluateJavaScript:@"__getShareStr()" completionHandler:^(id _Nullable shareStr, NSError * _Nullable error) {
            
            NSString *str = shareStr;
            if (str.length != 0) {
                self.shareBtn.hidden = NO;
            }else {
                self.shareBtn.hidden = YES;
            }
        }];
        
    }
    
    _shareBtn.userInteractionEnabled = YES;
    [self.homeWebView.scrollView.mj_header endRefreshing];
}



- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    _shareBtn.userInteractionEnabled = NO;
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
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)resetHomeWebAgent {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.homeWebView.customUserAgent = app.userAgent;
}

/**
 *  初始化进度条
 */
- (void)initWebViewProgress {
    
    [self.homeWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    self.progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    self.progressView.tintColor = [UIColor greenColor];
    self.progressView.trackTintColor = HuoBanMallBuyNavColor;
    
    
}

// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.homeWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
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


