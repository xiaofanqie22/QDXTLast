//
//  TSFRequest.h
//  MyAndroidAPP
//
//  Created by 积分宝 on 16/9/28.
//  Copyright © 2016年 积分宝. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface TSFRequest : NSObject
/*
 *创建单例
 */
+ (instancetype)sharedRequest;
//
-(void)get:(NSString *)urlString BodyDic:(NSMutableDictionary *)bodyDic withToken:(NSString * )tokenStr DataBlock:(void (^)(id))dataBlock ErrorBlock:(void (^)(id))ErrBlock;

@end
