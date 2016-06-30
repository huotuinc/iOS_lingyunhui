//
//  UITableView+CJ.m
//  minipartner
//
//  Created by Cai Jiang on 2/9/15.
//  Copyright (c) 2015 Cai Jiang. All rights reserved.
//

#import "UITableView+CJ.h"

@implementation UITableView (CJ)

-(void)removeSpaces{
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


-(void)cleanSelection{
    [self selectRowAtIndexPath:Nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}



@end
