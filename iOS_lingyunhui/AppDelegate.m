//
//  AppDelegate.m
//  iOS_lingyunhui
//
//  Created by 刘琛 on 16/5/27.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import "AppDelegate.h"
//微信SDK头文件
#import "WXApi.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#import <SVProgressHUD.h>
#import "LWNewFeatureController.h"
#import "HomeTabbarController.h"
@interface AppDelegate ()


@property (nonatomic, strong) NSString *Agent;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //初始化agent
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _Agent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UIViewController alloc] init];
    
    [self _initShare];
    
    
    [self appGetConfig];
    
    [SVProgressHUD setMinimumDismissTimeInterval:2];
    
    
    
    return YES;
}

- (void)_initShare {
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:ShareSDKAppKey
     
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ),
                            ]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class] delegate:self];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:XinLangAppkey
                                           appSecret:XinLangAppSecret
                                         redirectUri:XinLangRedirectUri
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:WeiXinAppID
                                       appSecret:WeiXinAppSecret];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:QQAppKey
                                      appKey:QQappSecret
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
}

- (void)appGetConfig {
    
    
    
    UserInfo *user = nil;
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [path stringByAppendingPathComponent:UserInfoLYH];
    user =  [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:LYHUserId];
    NSString *tempUserId = [NSString stringWithFormat:@"%@", userID];
    if (tempUserId.length == 0) {
        dic[@"userId"] = @"";
    }else {
        dic[@"userId"] = userID;
    }
    if (user) {
        if (user.unionId) {
            dic[@"unionId"] = user.unionId;
        }else {
            dic[@"unionId"] = @"";
        }
        if (user.openId) {
            dic[@"openId"] = user.openId;
        }else {
            dic[@"openId"] = @"";
        }
    }else {
        dic[@"unionId"] = @"";
        dic[@"openId"] = @"";
    }
    
    [UserLoginTool loginRequestGet:@"/ArvatoConfig/GetArvatoConfig?" parame:dic success:^(id json) {
        LWLog(@"%@",json);
        if ([json[@"code"] integerValue] == 200) {
            UserInfo *user = [UserInfo mj_objectWithKeyValues:json[@"data"][@"userInfo"]];
            
            NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *fileName = [path stringByAppendingPathComponent:UserInfoLYH];
            [NSKeyedArchiver archiveRootObject:user toFile:fileName];
            [[NSUserDefaults standardUserDefaults] setObject:user.userId forKey:LYHUserId];
            
            if (![user.userId isEqualToNumber:@0]) {
                
            }else {
                [[NSUserDefaults standardUserDefaults] setObject:Failure forKey:LoginStatus];
            }
            
            [self resetUserAgent:nil];
            
            AppConfig *appConfig = [AppConfig mj_objectWithKeyValues:json[@"data"][@"appConfig"]];
            NSString *fileConfig = [path stringByAppendingPathComponent:LYHAppConfig];
            [NSKeyedArchiver archiveRootObject:appConfig toFile:fileConfig];
            
            [BarItemMenus mj_setupObjectClassInArray:^NSDictionary *{
                return @{@"bottomMenus":@"BarItem"};
            }];
            BarItemMenus *meun = [BarItemMenus mj_objectWithKeyValues:json[@"data"]];
            NSString *filemeun = [path stringByAppendingPathComponent:ButtomBarItems];
            [NSKeyedArchiver archiveRootObject:meun toFile:filemeun];
            
            [self getConfigSuccsee];
        }
    } failure:^(NSError *error) {
        LWLog(@"%@",error);
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)resetUserAgent:(NSString *) goUrl {
    
    
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //add my info to the new agent
    NSString *newAgent = nil;
    UserInfo * usaa = nil;
    
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [path stringByAppendingPathComponent:UserInfoLYH];
    usaa =  [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:LYHUserId];
    //    NSString *tempUserId = [(NSNumber*)userID  stringValue]
    if ([NSString stringWithFormat:@"%@", userID].length == 0) {
        userID = @"";
    }
    if (usaa) {
        if (usaa.unionId) {
        }else {
            usaa.unionId = @"";
        }
        if (usaa.openId) {
        }else {
            usaa.openId= @"";
        }
    }else {
        usaa = [[UserInfo alloc] init];
        usaa.openId = @"";
        usaa.unionId = @"";
    }
    
    NSString *str = [MD5Encryption md5by32:[NSString stringWithFormat: @"%@%@%@%@",userID, usaa.unionId, usaa.openId, HTYMRSCREAT]];
    
    
    newAgent = [_Agent stringByAppendingString:[NSString stringWithFormat: @";mobile;hottec:%@:%@:%@:%@;",str,userID, usaa.unionId, usaa.openId]];
    
    
    self.userAgent = newAgent;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ResetAllWebAgent object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (goUrl) {
            NSDictionary * objc = [NSDictionary dictionaryWithObject:goUrl forKey:@"url"];
            [[NSNotificationCenter defaultCenter] postNotificationName:GoToNextWeb object:nil userInfo:objc];
        }
    });
    
}


- (void)getConfigSuccsee {
//    //版本新特性
//    NSString * appVersion = [[NSUserDefaults standardUserDefaults] stringForKey:LocalAppVersion];
//    if (appVersion) {
//        
//        if ([appVersion isEqualToString:AppVersion]) {//相等
//            
//            
//        }else{//不相等
//            [[NSUserDefaults standardUserDefaults] setObject:AppVersion forKey:LocalAppVersion];
//            LWNewFeatureController *new = [[LWNewFeatureController alloc] init];
//            self.window.rootViewController = new;
//            [self.window makeKeyAndVisible];
//        }
//        
//    }else{//没有版本号
//        //
//        [[NSUserDefaults standardUserDefaults] setObject:AppVersion forKey:LocalAppVersion];
//        LWNewFeatureController *new = [[LWNewFeatureController alloc] init];
//        self.window.rootViewController = new;
//        [self.window makeKeyAndVisible];
//    }
    
    
    
    UIStoryboard *stroy = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HomeTabbarController *tab = [stroy instantiateViewControllerWithIdentifier:@"HomeTabbarController"];
    self.window.rootViewController = tab;
    [self.window makeKeyAndVisible];

}
@end
