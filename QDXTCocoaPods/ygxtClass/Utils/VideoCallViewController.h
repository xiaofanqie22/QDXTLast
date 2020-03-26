//
//  VideoCallViewController.h
//  GJJanusDemo
//
//  Created by melot on 2018/3/20.
//  Copyright © 2018年 MirrorUncle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCallViewController : UIViewController
@property(nonatomic,copy)NSString* userName;
@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic, assign) NSInteger userid;
@property (nonatomic,assign)NSInteger serviceId;
@property (nonatomic, assign) NSInteger wsPort;
@property (nonatomic, copy) NSString *urlAddress;
@property (nonatomic, copy) NSString *type;



//@property (nonatomic, strong) UIImage *userImage;

@end
