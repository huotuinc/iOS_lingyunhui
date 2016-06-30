//
//  NSDictionary+EXTERN.h
//  fanmore---
//
//  Created by lhb on 15/5/29.
//  Copyright (c) 2015年 HT. All rights reserved.
//  进行字典asig参数的拼接

#import <Foundation/Foundation.h>

@interface NSDictionary (EXTERN)

/**
 *  通过字典计算网络请求的asign值
 */
+ (NSString *)asignWithMutableDictionary:(NSMutableDictionary *)dict;


/**
 *  通过字典计算计算微信支付asign值
 */
+ (NSString *)asignByWeiXinPayMutableDictionary:(NSMutableDictionary *)dict;

@end
