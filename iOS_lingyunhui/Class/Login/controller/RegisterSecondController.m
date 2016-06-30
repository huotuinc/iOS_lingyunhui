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

@interface RegisterSecondController ()

@end

@implementation RegisterSecondController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    self.registerButton.layer.cornerRadius = 5;
    
    if (self.isForget) {
        self.title = @"快速注册";
    }else {
        self.title = @"找回密码";
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
    if ([passwordNumber isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"密码不能为空"];
    }else if (passwordNumber.length < 6 || passwordNumber.length > 16) {
        [SVProgressHUD showErrorWithStatus:@"密码长度6-16位"];
    }
    else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"password"] = [MD5Encryption md5by32:passwordNumber];
        dic[@"phone"] = self.phone;
        dic[@"type"] = @1;
        [UserLoginTool loginRequestPostWithFile:@"reg" parame:dic success:^(id json) {
            LWLog(@"%@",json);
            if ([json[@"systemResultCode"] intValue] == 1 && [json[@"resultCode"] intValue]==1) {
                [self loginSuccessWith:json[@"resultData"]];
            }else {
                
            }
           
        } failure:^(NSError *error) {
            LWLog(@"%@",error);
        } withFileKey:nil];
    }
    
}


- (void)loginSuccessWith:(NSDictionary *) dic {
    
//    UserModel *user = [UserModel mj_objectWithKeyValues:dic[@"user"]];
//    LWLog(@"userModel: %@",user);
//    
//    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *fileName = [path stringByAppendingPathComponent:UserInfo];
//    [NSKeyedArchiver archiveRootObject:user toFile:fileName];
//    [[NSUserDefaults standardUserDefaults] setObject:Success forKey:LoginStatus];
//    //保存新的token
//    [[NSUserDefaults standardUserDefaults] setObject:user.token forKey:AppToken];
//    //app是否在审核
//    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",user.forIosCheck] forKey:AppExamine];
//    LWLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:AppExamine]);
//    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
