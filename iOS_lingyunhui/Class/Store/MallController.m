//
//  MallController.m
//  iOS_linyunhui
//
//  Created by 刘琛 on 16/5/25.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import "MallController.h"
#import "HomeViewController.h"

@interface MallController ()

@end

@implementation MallController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString * login = [[NSUserDefaults standardUserDefaults] objectForKey:LoginStatus];
    if ([login isEqualToString:Success]) {
        
        HomeViewController *home = [[HomeViewController alloc] init];
        UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:home];
        NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileConfig = [path stringByAppendingPathComponent:LYHAppConfig];
        AppConfig *config = [NSKeyedUnarchiver unarchiveObjectWithFile:fileConfig];
        home.HomeButtomUrl = config.mallBottomUrl;
        home.HomeWebUrl = [NSString stringWithFormat:@"%@?back=1", config.mallUrl];
        [self presentViewController:homeNav animated:YES completion:nil];
    }else {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginController *login = [story instantiateViewControllerWithIdentifier:@"LoginController"];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];
        [self presentViewController:loginNav animated:YES completion:nil];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
