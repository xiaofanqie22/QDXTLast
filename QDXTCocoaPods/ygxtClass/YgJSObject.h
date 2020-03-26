//
//  YgJSObject.h
//  ygxtClass
//
//  Created by kaili on 2018/9/6.
//  Copyright © 2018年 kaili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol YgJSObjectProtocol <JSExport>

//此处我们测试几种参数的情况
-(void)dianji;
-(void)dianji:(NSString *)message;
-(void)dianji:(NSString *)message1 :(NSString *)message2;

@end

@interface YgJSObject : NSObject<YgJSObjectProtocol>

@end
