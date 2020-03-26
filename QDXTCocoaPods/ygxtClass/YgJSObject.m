//
//  YgJSObject.m
//  ygxtClass
//
//  Created by kaili on 2018/9/6.
//  Copyright © 2018年 kaili. All rights reserved.
//

#import "YgJSObject.h"

@implementation YgJSObject

//一下方法都是只是打了个log 等会看log 以及参数能对上就说明js调用了此处的iOS 原生方法
-(void)dianji
{
    NSLog(@"this is ios TestNOParameter");
}
-(void)dianji:(NSString *)message
{
    NSLog(@"this is ios TestOneParameter=%@",message);
}
-(void)dianji:(NSString *)message1 :(NSString *)message2
{
    NSLog(@"this is ios TestTowParameter=%@  Second=%@",message1,message2);
}


@end
