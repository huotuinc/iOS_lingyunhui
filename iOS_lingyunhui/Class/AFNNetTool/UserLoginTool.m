//
//  UserLoginTool.m
//  fanmore---
//
//  Created by lhb on 15/5/21.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "UserLoginTool.h"
#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+EXTERN.h"
#import "MD5Encryption.h"


@interface UserLoginTool()

@end



@implementation UserLoginTool

+ (void)loginRequestGet:(NSString *)urlStr parame:(NSMutableDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure{
    
    NSMutableDictionary * paramsOption = [NSMutableDictionary dictionary];
    paramsOption[@"customerid"] = HuoBanMallBuyApp_Merchant_Id;
    NSDate * timestamp = [[NSDate alloc] init];
    NSString *timeSp = [NSString stringWithFormat:@"%lld", (long long)[timestamp timeIntervalSince1970] * 1000];  //转化为UNIX时间戳
    paramsOption[@"appid"] = HuoBanMallBuyAppId;
    paramsOption[@"timestamp"] = timeSp;
    paramsOption[@"operation"]=@"app";
    
    if (params != nil) { //传入参数不为空
        [paramsOption addEntriesFromDictionary:params];
    }
    paramsOption[@"sign"] = [self  test:paramsOption];  //计算asign
    [paramsOption removeObjectForKey:@"appSecret"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", MKMainUrl,urlStr];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:paramsOption progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        LWLog(@"%@",task.originalRequest);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        LWLog(@"%@",task);
        failure(error);
        [SVProgressHUD showErrorWithStatus:@"无法连接到服务器"];
    }];
    
    
    
}






+ (void)loginRequestPostWithFile:(NSString *)urlStr parame:(NSMutableDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure withFileKey:(NSString *)key{
    
    
    NSMutableDictionary * paramsOption = [NSMutableDictionary dictionary];
    paramsOption[@"customerid"] = HuoBanMallBuyApp_Merchant_Id;
    NSDate * timestamp = [[NSDate alloc] init];
    NSString *timeSp = [NSString stringWithFormat:@"%lld", (long long)[timestamp timeIntervalSince1970] * 1000];  //转化为UNIX时间戳
    paramsOption[@"appid"] = HuoBanMallBuyAppId;
    paramsOption[@"timestamp"] = timeSp;
    paramsOption[@"operation"]=@"app";
    
    if (params != nil) { //传入参数不为空
        [paramsOption addEntriesFromDictionary:params];
    }
    paramsOption[@"sign"] = [self  test:paramsOption];  //计算asign
    [paramsOption removeObjectForKey:@"appSecret"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", MKMainUrl,urlStr];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:paramsOption progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        LWLog(@"%@",task.originalRequest);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        LWLog(@"%@",task);
        failure(error);
        [SVProgressHUD showErrorWithStatus:@"无法连接到服务器"];
    }];
}


+ (void)ordorRequestGet:(NSString *)urlStr parame:(NSMutableDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager GET:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        LWLog(@"%@",task.originalRequest);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        LWLog(@"%@",task);
        failure(error);
        [SVProgressHUD showErrorWithStatus:@"无法连接到服务器"];
    }];
    
    
}

+ (NSString *)test:(NSMutableDictionary *)parame{
    if (parame == nil) {
        return nil;
    }
    NSMutableDictionary * innerParame = [[NSMutableDictionary alloc] initWithDictionary:parame];
    //计算asign参数
    NSArray * arr = [innerParame allKeys];
    [arr enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * cc =[NSString stringWithFormat:@"%@", [parame objectForKey:obj]];
        if (cc.length==0) {
            [innerParame removeObjectForKey:obj];
        }
    }];
    //计算asign参数
    arr = [innerParame allKeys];
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        return [obj1 compare:obj2] == NSOrderedDescending;
    }];
    NSMutableString * signCap = [[NSMutableString alloc] init];
    //进行asign拼接
    for (NSString * dicKey in arr) {
        [signCap appendString:[NSString stringWithFormat:@"%@=%@&",[dicKey lowercaseString] ,[parame valueForKey:dicKey]]];
    }
    NSString * aa = [signCap substringToIndex:signCap.length-1];
    NSString * cc  = [NSString stringWithFormat:@"%@%@",aa, HTYMRSCREAT];
//    NSString *unicodeStr = [NSString stringWithCString:[cc  UTF8String] encoding:NSUTF8StringEncoding];
//    LWLog(@"%@",unicodeStr);
    return [MD5Encryption md5by32:cc];
}

@end
