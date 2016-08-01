//
//  AppDelegate.h
//  iOS_lingyunhui
//
//  Created by 刘琛 on 16/5/27.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong,  nonatomic) UIWindow *window;

@property (nonatomic , strong) NSString *userAgent;

- (void)resetUserAgent:(NSString *) goUrl;

@end

