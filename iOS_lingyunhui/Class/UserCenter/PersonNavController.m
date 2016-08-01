//
//  PersonNavController.m
//  iOS_lingyunhui
//
//  Created by 刘琛 on 16/7/26.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import "PersonNavController.h"

@interface PersonNavController ()

@end

@implementation PersonNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [path stringByAppendingPathComponent:ButtomBarItems];
    BarItemMenus *bars = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    if (bars) {
        BarItem *bar = bars.bottomMenus[3];
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
