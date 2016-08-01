//
//  RegisterSecondController.h
//  iOS_FanmoreIndiana
//
//  Created by 刘琛 on 16/1/21.
//  Copyright © 2016年 刘琛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterSecondController : UIViewController


@property (nonatomic, strong) NSString *phone;

@property (weak, nonatomic) IBOutlet UITextField *password;

@property (strong, nonatomic) IBOutlet UITextField *secondPassWord;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (nonatomic, assign) BOOL isForget;

@property (nonatomic, assign) BOOL isWeixinLogin;

@property (nonatomic, assign) BOOL isphoneLogin;

@property (nonatomic, strong) WeixinUserInfo *weixin;

@property (nonatomic, strong) NSString *goUrl;

- (IBAction)registerUser:(id)sender;


@end
