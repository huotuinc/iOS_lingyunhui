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



@interface UserLoginTool()

@end



@implementation UserLoginTool

+ (void)loginRequestGet:(NSString *)urlStr parame:(NSMutableDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure{
    
    NSMutableDictionary * paramsOption = [NSMutableDictionary dictionary];
//    paramsOption[@"appSecret"] = HTYMRSCREAT;
//    paramsOption[@"timestamp"] = apptimesSince1970;
//    paramsOption[@"operation"] = OPERATION_parame;
//    paramsOption[@"version"] =AppVersion;
//    NSString * token = [[NSUserDefaults standardUserDefaults] stringForKey:AppToken];
//    paramsOption[@"token"] = token?token:@"";
//    paramsOption[@"imei"] = DeviceNo;
    if (params != nil) { //传入参数不为空
        [paramsOption addEntriesFromDictionary:params];
    }
    paramsOption[@"sign"] = [NSDictionary asignWithMutableDictionary:paramsOption];  //计算asign
    [paramsOption removeObjectForKey:@"appSecret"];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager GET:urlStr parameters:paramsOption progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        LWLog(@"%@",task.originalRequest);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        LWLog(@"%@",task);
        failure(error);
        [SVProgressHUD showErrorWithStatus:@"无法连接到服务器"];
    }];
//    NSMutableString * url = [NSMutableString stringWithFormat:@"%@/%@",MainUrl,urlStr];
    
    
    
}






+ (void)loginRequestPostWithFile:(NSString *)urlStr parame:(NSMutableDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure withFileKey:(NSString *)key{
    
    
//    //   AFHTTPRequestOperationManager * manager  = [AFHTTPRequestOperationManager manager];
//    NSMutableDictionary * paramsOption = [NSMutableDictionary dictionary];
//    paramsOption[@"appSecret"] = HTYMRSCREAT;
//    paramsOption[@"timestamp"] = apptimesSince1970;
//    paramsOption[@"operation"] = OPERATION_parame;
//    paramsOption[@"version"] =AppVersion;
//    NSString * token = [[NSUserDefaults standardUserDefaults] stringForKey:AppToken];
//    paramsOption[@"token"] = token?token:@"";
//    paramsOption[@"imei"] = DeviceNo;
//    if (params != nil) { //传入参数不为空
//        [paramsOption addEntriesFromDictionary:params];
//    }
//    if (key != nil) {
//        NSData *data = [[paramsOption objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        [paramsOption removeObjectForKey:key];
//        paramsOption[@"profileData"] = str;
//    }
//    
//    paramsOption[@"sign"] = [NSDictionary asignWithMutableDictionary:paramsOption];
//    [paramsOption removeObjectForKey:@"appSecret"];
//    
//    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:MKMainUrl customHeaderFields:nil];
//    
//    MKNetworkOperation *op = [engine operationWithPath:urlStr params:paramsOption httpMethod:@"POST"];
//    
//    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//        success(completedOperation.responseJSON);
//    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//        failure(error);
//        [SVProgressHUD showErrorWithStatus:@"无法连接到服务器"];
//    }];
//    
//    [engine enqueueOperation:op];
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


@end
