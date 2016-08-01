//
//  HomeTabbarController.m
//  iOS_lingyunhui
//
//  Created by 刘琛 on 16/7/26.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import "HomeTabbarController.h"

@interface HomeTabbarController ()

@end

@implementation HomeTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cannelLogin) name:CannelLoginFailure object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cannelLogin {
    
    self.selectedIndex = 0;
    
}
@end
