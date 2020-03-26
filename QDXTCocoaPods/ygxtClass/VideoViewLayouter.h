//
//  VideoViewLayouter.h
//  OpenLive
//
//  Created by GongYuhua on 2016/9/12.
//  Copyright © 2016年 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoSession.h"

@protocol LeftBodyCellDelegate <NSObject>
- (void)selectedItemButton:(NSInteger)index;
@end

@interface VideoViewLayouter : NSObject
@property(nonatomic,weak)id<LeftBodyCellDelegate>   leftBodyCellDelegate;
@property(nonatomic,assign)NSInteger roleIndex;
- (void)layoutSessions:(NSArray<VideoSession *> *)sessions
           fullSession:(VideoSession *)fullSession
           inContainer:(UIView *)container;
- (void)layoutSessions:(NSArray<VideoSession *> *)sessions
           fullSession:(VideoSession *)fullSession
           inContainer:(UIView *)container withShare:(BOOL)share;
@end
