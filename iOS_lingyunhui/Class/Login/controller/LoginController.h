//
//  LoginController.h
//  iOS_linyunhui
//
//  Created by 刘琛 on 16/5/16.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *Login;
@property (weak, nonatomic) IBOutlet UIButton *forgot;
@property (weak, nonatomic) IBOutlet UIButton *regisn;
@property (weak, nonatomic) IBOutlet UIButton *weixin;

@property (nonatomic, strong) NSString *goUrl;

- (IBAction)loginAction:(id)sender;

- (IBAction)forgetAction:(id)sender;

- (IBAction)registAction:(id)sender;

- (IBAction)wenxinLogin:(id)sender;

@end
