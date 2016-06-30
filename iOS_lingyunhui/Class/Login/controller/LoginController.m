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

@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
            
            dic[@"username"] = self.userName.text;
            
            dic[@"password"] = [MD5Encryption md5by32:self.password.text];
            
            [SVProgressHUD showWithStatus:@"登录中"];
            [UserLoginTool loginRequestGet:@"login" parame:dic success:^(id json) {
                
                LWLog(@"%@",json);
                if ([json[@"systemResultCode"] intValue] == 1 && [json[@"resultCode"] intValue]==1) {
                    [SVProgressHUD dismiss];
                    [self loginSuccessWith:json[@"resultData"]];
                }else {
                    [SVProgressHUD showErrorWithStatus:json[@"resultDescription"]];
                }
                
            } failure:^(NSError *error) {
                
                LWLog(@"%@",error);
                
            }];
        }
    }
}

- (IBAction)forgetAction:(id)sender {
    
    RegisterFirstController *reg = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterFirstController"];
    reg.isForget = YES;
    [self.navigationController pushViewController:reg animated:YES];
    
    
}

- (IBAction)registAction:(id)sender {
    
    RegisterFirstController *reg = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterFirstController"];
    reg.isForget = NO;
    [self.navigationController pushViewController:reg animated:YES];
}

- (IBAction)wenxinLogin:(id)sender {
    
    self.weixin.userInteractionEnabled = NO;
    
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess) {
            LWLog(@"%@",user);
            
            NSString *unionid = [user.rawData objectForKey:@"unionid"];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"username"] = user.nickname;
            dic[@"unionId"] = unionid;
            dic[@"head"] = user.icon;
            dic[@"type"] = @"1";
            
            [SVProgressHUD showWithStatus:@"登录中"];
            
            [UserLoginTool loginRequestGet:@"authLogin" parame:dic success:^(id json) {
                LWLog(@"%@",json);
                if ([json[@"systemResultCode"] intValue] == 1 && [json[@"resultCode"] intValue]==1) {
                    [self loginSuccessWith:json[@"resultData"]];
                }
                [SVProgressHUD dismiss];
            } failure:^(NSError *error) {
                LWLog(@"%@",error);
                [SVProgressHUD dismiss];
                self.weixin.userInteractionEnabled = YES;
            }];
            
        }else {
            self.weixin.userInteractionEnabled = YES;
            LWLog(@"%@",error);
        }
    }];
    
}




- (void)loginSuccessWith:(NSDictionary *) dic {
    
//    UserModel *user = [UserModel mj_objectWithKeyValues:dic[@"user"]];
//    //    NSLog(@"userModel: %@",user);
//    
//    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *fileName = [path stringByAppendingPathComponent:UserInfo];
//    [NSKeyedArchiver archiveRootObject:user toFile:fileName];
//    [[NSUserDefaults standardUserDefaults] setObject:Success forKey:LoginStatus];
//    //app是否在审核
//    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",user.forIosCheck] forKey:AppExamine];
//    LWLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:AppExamine]);
//    //保存新的token
//    [[NSUserDefaults standardUserDefaults] setObject:user.token forKey:AppToken];
//    //购物车结算登陆时 需要提交数据
//    [self postDataToServe];
//    [self dismissViewControllerAnimated:YES completion:nil];
//    /**
//     *  //////
//     */
//    AdressModel *address = [AdressModel mj_objectWithKeyValues:dic[@"user"][@"appMyAddressListModel"]];
//    NSString *fileNameAdd = [path stringByAppendingPathComponent:DefaultAddress];
//    [NSKeyedArchiver archiveRootObject:address toFile:fileNameAdd];
//    
//    if (self.isFromMall) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:LoginFromMallNot object:nil];
//    }
    
    
}
@end
