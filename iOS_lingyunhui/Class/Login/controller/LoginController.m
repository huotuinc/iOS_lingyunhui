//
//  LoginController.m
//  iOS_linyunhui
//
//  Created by 刘琛 on 16/5/16.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import "LoginController.h"
#import <BlocksKit/UIView+BlocksKit.h>
#import "WXApi.h"
#import <ShareSDK/ShareSDK.h>
#import "MD5Encryption.h"
#import "RegisterFirstController.h"
#import <BlocksKit/UIBarButtonItem+BlocksKit.h>
@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"取消" style:UIBarButtonItemStylePlain handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CannelLoginFailure object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



- (IBAction)loginAction:(id)sender {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (self.userName.text.length != 0 && self.password.text.length != 0) {
        
        if (self.password.text.length < 6 || self.password.text.length > 16) {
            [SVProgressHUD showErrorWithStatus:@"密码长度6-16位"];
        }else {
            
            dic[@"mobile"] = self.userName.text;
            
            dic[@"password"] = self.password.text;
            
            [SVProgressHUD showWithStatus:@"登录中"];
            [UserLoginTool loginRequestPostWithFile:@"/ArvatoUser/LoginByMobile" parame:dic success:^(id json) {
                LWLog(@"%@",json);
                [SVProgressHUD dismiss];
                if ([json[@"code"] integerValue] == 200) {
                    UserInfo *user = [UserInfo mj_objectWithKeyValues:json[@"data"]];
                    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    NSString *fileName = [path stringByAppendingPathComponent:UserInfoLYH];
                    [NSKeyedArchiver archiveRootObject:user toFile:fileName];
                    [[NSUserDefaults standardUserDefaults] setObject:user.userId forKey:LYHUserId];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:Success forKey:LoginStatus];
                    
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [app resetUserAgent:_goUrl];
                    
                    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            } failure:^(NSError *error) {
                LWLog(@"%@",error);
            } withFileKey:nil ];
            

        }
    }
}


//忘记密码
- (IBAction)forgetAction:(id)sender {
    
    RegisterFirstController *reg = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterFirstController"];
    reg.isphoneLogin = NO;
    reg.isWeixinLogin = NO;
    reg.isForget = YES;
    [self.navigationController pushViewController:reg animated:YES];
    
    
}

//手机注册
- (IBAction)registAction:(id)sender {
    
    RegisterFirstController *reg = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterFirstController"];
    reg.isphoneLogin = YES;
    reg.isWeixinLogin = NO;
    reg.isForget = NO;
    reg.goUrl = self.goUrl;
    [self.navigationController pushViewController:reg animated:YES];
}


//微信授权登录
- (IBAction)wenxinLogin:(id)sender {
    
    self.weixin.userInteractionEnabled = NO;
    
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess) {
            LWLog(@"%@",user);
            
            
            WeixinUserInfo *weixin = [[WeixinUserInfo alloc] init];
            weixin.city = user.rawData[@"city"];
            weixin.country = user.rawData[@"country"];
            weixin.headimgurl = user.rawData[@"headimgurl"];
            weixin.language = user.rawData[@"language"];
            weixin.nickname = user.rawData[@"nickname"];
            weixin.openid = user.rawData[@"openid"];
            weixin.province = user.rawData[@"province"];
            weixin.sex = user.rawData[@"sex"];
            weixin.unionid = user.rawData[@"unionid"];

            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"unionId"] = weixin.unionid;
            dic[@"openId"] = weixin.openid;
            
            
            [UserLoginTool loginRequestPostWithFile:@"/ArvatoUser/LoginByWeiXin" parame:dic success:^(id json) {
                LWLog(@"%@",json);
                if ([json[@"code"] intValue] == 200) {
                    UserInfo *user = [UserInfo mj_objectWithKeyValues:json[@"data"]];
                    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    NSString *fileName = [path stringByAppendingPathComponent:UserInfoLYH];
                    [NSKeyedArchiver archiveRootObject:user toFile:fileName];
                    [[NSUserDefaults standardUserDefaults] setObject:user.userId forKey:LYHUserId];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:Success forKey:LoginStatus];
                    
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [app resetUserAgent:_goUrl];
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                }else if ([json[@"code"] intValue] == 403){
                    
                    RegisterFirstController *reg = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterFirstController"];
                    reg.isphoneLogin = NO;
                    reg.isWeixinLogin = YES;
                    reg.isForget = NO;
                    reg.weixin = weixin;
                    [self.navigationController pushViewController:reg animated:YES];
                    
                }else {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", json[@"msg"]]];
                }
            } failure:^(NSError *error) {
                LWLog(@"%@", error);
            } withFileKey:nil];
            
        }else {
            self.weixin.userInteractionEnabled = YES;
            LWLog(@"%@",error);
        }
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}



- (void)loginSuccessWith:(NSDictionary *) dic {
    

}
@end
