//
//  HomePushViewController.h
//  iOS_lingyunhui
//
//  Created by 刘琛 on 16/5/31.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayModel.h"

@interface HomePushViewController : UIViewController
@property (strong, nonatomic) WKWebView *webView;

@property (nonatomic, strong) NSString *url;
@end
