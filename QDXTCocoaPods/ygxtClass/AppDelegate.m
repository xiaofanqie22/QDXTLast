//
//  AppDelegate.m
//  ygxtClass
//
//  Created by kaili on 2018/8/20.
//  Copyright © 2018年 kaili. All rights reserved.
//

#import "AppDelegate.h"
#import "VideoCallViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    if (@available(iOS 11.0, *)) {
//        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    } else {
//        // Fallback on earlier versions
//    }
    
//    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    // Override point for customization after application launch.
    

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"-------退出后台了");
    NSNotification *notification =[NSNotification notificationWithName:@"endNet" object:nil userInfo:nil];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"执行了");
    NSNotification *notification =[NSNotification notificationWithName:@"startNet" object:nil userInfo:nil];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
//    [self toUploadHeard];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)toUploadHeard{


}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window

{
    
    if (self.rotateDirection == 1)
        
    {
        
        return UIInterfaceOrientationMaskLandscapeRight; // 支持右屏旋转
        
    }
    
    return UIInterfaceOrientationMaskPortrait;
    
}


@end
