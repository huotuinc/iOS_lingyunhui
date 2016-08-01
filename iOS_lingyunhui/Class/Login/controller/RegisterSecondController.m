//
//  RegisterSecondController.m
//  iOS_FanmoreIndiana
//
//  Created by 刘琛 on 16/1/21.
//  Copyright © 2016年 刘琛. All rights reserved.
//

#import "RegisterSecondController.h"
#import <BlocksKit/UIBarButtonItem+BlocksKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "MD5Encryption.h"
#import "UserLoginTool.h"

@interface RegisterSecondController ()

@end

@implementation RegisterSecondController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    self.registerButton.layer.cornerRadius = 5;
    
    if (_isphoneLogin) {
        self.title = @"快速注册";
    }
    if (_isWeixinLogin) {
        self.title = @"绑定手机号";
    }
    if (_isForget) {
        self.title = @"忘记密码";
    }
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"返回" style:UIBarButtonItemStylePlain handler:^(id sender) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    [self.password becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.password resignFirstResponder];
    
}

- (IBAction)registerUser:(id)sender {
    
    NSString *passwordNumber = self.password.text;
    NSString *passwordSecond = self.secondPassWord.text;
    if ([passwordNumber isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"密码不能为空"];
    }else if (passwordNumber.length < 6 || passwordNumber.length > 16) {
        [SVProgressHUD showErrorWithStatus:@"密码长度6-16位"];
    }else if (![passwordNumber isEqualToString:passwordSecond]){
        [SVProgressHUD showErrorWithStatus:@"输入的密码不一致"];
    }else {
        if (_isForget) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userName"] = _phone;
            dic[@"password"] =  passwordNumber;
            
            [UserLoginTool loginRequestPostWithFile:@"/ArvatoUser/ModifyPassword" parame:dic success:^(id json) {
                LWLog(@"%@", json);
                if ([json[@"code"] intValue] == 200) {
                    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else if ([json[@"code"] intValue] == 403) {
                    [SVProgressHUD showErrorWithStatus:@"账号不存在"];
                }
            } failure:^(NSError *error) {
                
            } withFileKey:nil];
        }
        if (_isphoneLogin) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"mobile"] = _phone;
            dic[@"password"] =  passwordNumber;
            [UserLoginTool loginRequestPostWithFile:@"/ArvatoUser/RegisterByMobile" parame:dic success:^(id json) {
                LWLog(@"%@", json);
                if ([json[@"code"] integerValue] == 200) {
                    UserInfo *user = [UserInfo mj_objectWithKeyValues:json[@"data"]];
                    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    NSString *fileName = [path stringByAppendingPathComponent:UserInfoLYH];
                    [NSKeyedArchiver archiveRootObject:user toFile:fileName];
                    [[NSUserDefaults standardUserDefaults] setObject:user.userId forKey:LYHUserId];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:Success forKey:LoginStatus];
                    
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [app resetUserAgent:_goUrl];
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            } failure:^(NSError *error) {
                
            } withFileKey:nil];
            
        }
        if (_isWeixinLogin) {
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"openid"] = _weixin.openid;
            dic[@"unionId"] = _weixin.unionid;
            dic[@"sex"] = _weixin.sex;
            dic[@"nickname"] = _weixin.nickname;
            dic[@"wxHead"] = _weixin.headimgurl;
            dic[@"city"] = _weixin.city;
            dic[@"country"] = _weixin.country;
            dic[@"province"] = _weixin.province;
            dic[@"mobile"] = self.phone;
            dic[@"password"] = passwordNumber;
            
            [UserLoginTool loginRequestPostWithFile:@"/ArvatoUser/RegisterByWeiXin" parame:dic success:^(id json) {
                
                UserInfo *user = [UserInfo mj_objectWithKeyValues:json[@"data"]];
                NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                NSString *fileName = [path stringByAppendingPathComponent:UserInfoLYH];
                [NSKeyedArchiver archiveRootObject:user toFile:fileName];
                [[NSUserDefaults standardUserDefaults] setObject:user.userId forKey:LYHUserId];
                
                [[NSUserDefaults standardUserDefaults] setObject:Success forKey:LoginStatus];
                
                AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [app resetUserAgent:_goUrl];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } failure:^(NSError *error) {
                
            } withFileKey:nil];
        }
    }
    
}


- (void)loginSuccessWith:(NSDictionary *) dic {
    
    
}


@end
