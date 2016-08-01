//
//  LYHNavController.m
//  iOS_linyunhui
//
//  Created by 刘琛 on 16/5/25.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import "LYHNavController.h"

@interface LYHNavController ()

@end

@implementation LYHNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [path stringByAppendingPathComponent:ButtomBarItems];
    BarItemMenus *bars = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    if (bars) {
        BarItem *bar = bars.bottomMenus[1];
        self.tabBarItem.title = bar.name;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
