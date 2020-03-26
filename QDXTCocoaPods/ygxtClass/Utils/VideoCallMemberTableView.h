//
//  VideoCallMemberTableView.h
//  UniudcOA
//
//  Created by LIjun on 2019/6/25.
//  Copyright © 2019 shanshan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoMemberDelegate <NSObject>

@optional
- (void)userCloseMemberList;

@end

@interface VideoCallMemberTableView : UITableView
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, weak) id <VideoMemberDelegate> memberDelegate;
@end


