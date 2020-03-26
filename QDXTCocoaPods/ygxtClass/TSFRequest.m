//
//  TSFRequest.m
//  MyAndroidAPP
//
//  Created by 积分宝 on 16/9/28.
//  Copyright © 2016年 积分宝. All rights reserved.
//

#import "TSFRequest.h"
static id _instace;
@interface TSFRequest ()



@end

@interface AFHTTPSessionManager (Shared)
// 设置为单利
+ (instancetype)sharedManager;
@end

@implementation AFHTTPSessionManager (Shared)
+ (instancetype)sharedManager {
    static AFHTTPSessionManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [AFHTTPSessionManager manager];
        _instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain", @"text/json", @"text/javascript", @"text/html", @"image/jpeg", @"image/png",nil];
    });
    return _instance;
}
@end

//
@implementation TSFRequest

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}
- (id)copyWithZone:(NSZone *)zone{
    return _instace;
}

+ (instancetype)sharedRequest{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

-(void)get:(NSString *)urlString BodyDic:(NSMutableDictionary *)bodyDic withToken:(NSString * )tokenStr DataBlock:(void (^)(id))dataBlock ErrorBlock:(void (^)(id))ErrBlock{
    //创建管理者对象(session)
    AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedManager];
    //设置允许请求的类别
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    if (tokenStr != nil || ![tokenStr isEqualToString:@""])
    {
        [manager.requestSerializer setValue:tokenStr forHTTPHeaderField:@"Authorization"];
    }
    [manager GET:urlString parameters:bodyDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            dataBlock(dic);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            ErrBlock(error);
        }];
}


@end
