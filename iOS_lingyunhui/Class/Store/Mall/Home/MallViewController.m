//
//  MallViewController.m
//  iOS_FanmoreIndiana
//
//  Created by 刘琛 on 16/3/16.
//  Copyright © 2016年 刘琛. All rights reserved.
//

#import "MallViewController.h"
#import "LoginController.h"
#import "HomeViewController.h"

@interface MallViewController ()

@property (nonatomic, assign) BOOL isFromBar;

@end

@implementation MallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isFromBar = YES;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dontGotoMall) name:CannelLoginFailure object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(gotoMallSecond) name:GotoMallSecond object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_isFromBar) {
        
//        [self gotoMall];
    }
    

}

//- (void)gotoMall {
//    [UserLoginTool loginRequestGet:@"getMallLoginUrl" parame:nil success:^(id json) {
//        LWLog(@"%@", json);
//        if ([json[@"systemResultCode"] intValue] == 1 && [json[@"resultCode"] intValue] == 1) {
//            
//            HomeViewController *home = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
//            home.homeUrl = json[@"resultData"][@"loginUrl"];
//            home.buttomUrl = json[@"resultData"][@"bottomNavUrl"];
//            
//            [[NSUserDefaults standardUserDefaults] setObject:json[@"resultData"][@"orderRequestUrl"] forKey:WebSit];
//            
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
//            [self presentViewController:nav animated:YES completion:nil];
//            
////            [self.navigationController pushViewController:home animated:YES];
//            
//        }
//    } failure:^(NSError *error) {
//        LWLog(@"%@", error);
//    }];
//}

- (void)dontGotoMall {
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:CannelLoginFailure object:nil];
    
    self.isFromBar = NO;
}

- (void)gotoMallSecond {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:GotoMallSecond object:nil];
    self.isFromBar = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
