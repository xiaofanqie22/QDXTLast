//
//  VideoSession.m
//  OpenLive
//
//  Created by GongYuhua on 2016/9/12.
//  Copyright © 2016年 Agora. All rights reserved.
//

#import "VideoSession.h"

@implementation VideoSession
- (instancetype)initWithUid:(NSUInteger)uid {
    if (self = [super init]) {
        self.uid = uid;
        self.hostingView = [[UIView alloc] init];
        self.hostingView.tag = uid;
        // TODO 这里的uidu需要替换
        self.hostingView.translatesAutoresizingMaskIntoConstraints = NO;
        self.hostingView.userInteractionEnabled = NO;
        self.hostingView.backgroundColor = [UIColor clearColor];
        self.canvas = [KKRTCCanvas canvasWithUid:uid view:self.hostingView renderMode:KKRTC_Render_Hidden];
    }
    return self;
}

+ (instancetype)localSession {
    return [[VideoSession alloc] initWithUid:0];
}
@end
