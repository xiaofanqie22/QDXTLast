//
//  ViewController.h
//  ygxtClass
//
//  Created by kaili on 2018/8/20.
//  Copyright © 2018年 kaili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSObjcDelegate <JSExport>
- (id)sendMessage2Native:(NSString *)str1 :(NSString * )str2;
@end

@class LiveRoomViewController;
@protocol LiveRoomVCDelegate <NSObject>
- (void)liveVCNeedClose:(LiveRoomViewController *)liveVC;
@end

@interface ViewController : UIViewController<UIWebViewDelegate,JSObjcDelegate>


@property(nonatomic,copy)NSString* userName;
@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic,assign)NSInteger serviceId;
@property (nonatomic, assign) NSInteger wsPort;
@property (nonatomic, copy) NSString *urlAddress;
@property (nonatomic, copy) NSString *type;

@property (copy, nonatomic) NSString *roomName;
@property (weak, nonatomic) id<LiveRoomVCDelegate> delegate;

@end

