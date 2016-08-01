//
//  RegisterFirstController.m
//  iOS_FanmoreIndiana
//
//  Created by 刘琛 on 16/1/21.
//  Copyright © 2016年 刘琛. All rights reserved.
//

#import "RegisterFirstController.h"
#import "RegisterSecondController.h"
#import "UIButton+CountDown.h"
#import <BlocksKit/UIView+BlocksKit.h>

@interface RegisterFirstController ()<UIAlertViewDelegate,UITextFieldDelegate>

@end

@implementation RegisterFirstController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    self.countdown.layer.masksToBounds = YES;
    self.countdown.layer.cornerRadius = 5;
    [self.countdown bk_whenTapped:^{
        [self getSecurtityCode];
    }];
    
    self.next.layer.cornerRadius = 5;
    if (_isphoneLogin) {
        self.title = @"快速注册";
    }
    if (_isWeixinLogin) {
        self.title = @"绑定手机号";
    }
    if (_isForget) {
        self.title = @"忘记密码";
    }
    
    [self.phone becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.phone resignFirstResponder];
    
    [self.security resignFirstResponder];
}


- (void)getSecurtityCode {
    
    NSString *phoneNumber = self.phone.text;
    if ([phoneNumber isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"手机号不能为空"];
    }else if (![self checkTel:phoneNumber]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
    }else {
    
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"mobile"] = phoneNumber;
        [UserLoginTool loginRequestPostWithFile:@"/ArvatoMessage/SendCode" parame:dic success:^(id json) {
            LWLog(@"%@", json);
            if ([json[@"code"] integerValue] == 200) {
                [SVProgressHUD showSuccessWithStatus:@"验证码发送成功"];
                [self settime];
            }
        } failure:^(NSError *error) {
            
        } withFileKey:nil];
        
    }
}


- (IBAction)goNext:(id)sender {
    
    if (!self.security.text.length) {//验证码不能为空
        
        [SVProgressHUD showErrorWithStatus:@"验证码不能为空"];
        return;
    }else if (!self.phone.text.length) {//手机号不能为空
        
        [SVProgressHUD showErrorWithStatus:@"手机号不能为空"];
        return;
    }else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSString *str = _security.text;
        dic[@"mobile"] = self.phone.text;
        dic[@"code"] = str;
        [UserLoginTool loginRequestPostWithFile:@"/ArvatoMessage/VerifyCode" parame:dic success:^(id json) {
            
            LWLog(@"%@", json);
            if ([json[@"code"] integerValue] == 200) {
                RegisterSecondController *second = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterSecondController"];
                second.isForget = _isForget;
                second.isWeixinLogin = _isWeixinLogin;
                second.isphoneLogin = _isphoneLogin;
                second.phone = self.phone.text;
                second.goUrl = self.goUrl;
                second.weixin = self.weixin;
                [self.navigationController pushViewController:second animated:YES];
            }
        } failure:^(NSError *error) {
            
        } withFileKey:nil];
    }
    
    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.security) {
        if (range.location>= 4){
            return NO;
        }
    }else {
        if (range.location>= 11){
            return NO;
        }
    }
    return YES;
}


/**
 *  验证手机号的正则表达式
 */
-(BOOL) checkTel:(NSString *) phoneNumber{
    NSString *regex = @"^(1)\\d{10}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:phoneNumber];
    
    if (!isMatch) {
        return NO;
    }
    return YES;
}


- (void)settime{
    
    /*************倒计时************/
    __block int timeout=59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.countdown setText:@"验证码"];
                //                [captchaBtn setTitle:@"" forState:UIControlStateNormal];
                //                [captchaBtn setBackgroundImage:[UIImage imageNamed:@"resent_icon"] forState:UIControlStateNormal];
                self.countdown.userInteractionEnabled = YES;
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //                NSLog(@"____%@",strTime);
                [self.countdown setText:[NSString stringWithFormat:@"%@s",strTime]];
                self.countdown.userInteractionEnabled = NO;
                
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}



@end
