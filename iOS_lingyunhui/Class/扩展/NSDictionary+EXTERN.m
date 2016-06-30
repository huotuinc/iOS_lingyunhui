//
//  NSDictionary+EXTERN.m
//  fanmore---
//
//  Created by lhb on 15/5/29.
//  Copyright (c) 2015年 HT. All rights reserved.
//  进行字典asig参数的拼接

#import "NSDictionary+EXTERN.h"
#import "MD5Encryption.h"


@implementation NSDictionary (EXTERN)



+ (NSString *)asignWithMutableDictionary:(NSMutableDictionary *)dict{
    
    //计算asign参数
    NSArray * arr = [dict allKeys];
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        return [obj1 compare:obj2] == NSOrderedDescending;
    }];
    NSMutableString * signCap = [[NSMutableString alloc] init];
    //进行asign拼接
    for (NSString * dicKey in arr) {
       [signCap appendString:[NSString stringWithFormat:@"%@",[dict valueForKey:dicKey]]];
    }

    return [MD5Encryption md5by32:signCap];
}


//+ (NSString *)asignByWeiXinPayMutableDictionary:(NSMutableDictionary *)dict{
//    //计算asign参数
//    NSArray * arr = [dict allKeys];
//    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
//        return [obj1 compare:obj2] == NSOrderedDescending;
//    }];
//    NSMutableString * signCap = [[NSMutableString alloc] init];
//    //进行asign拼接
//    for (NSString * dicKey in arr) {
//        [signCap appendString:[NSString stringWithFormat:@"%@&%@",dicKey,[dict valueForKey:dicKey]]];
//    }
//    NSString * aaa= [signCap substringToIndex:signCap.length];
//    [NSString stringWithFormat:@"%@&%@",aaa,WeiXinPaySigNkey];
//    
//    return nil;
//}
@end
