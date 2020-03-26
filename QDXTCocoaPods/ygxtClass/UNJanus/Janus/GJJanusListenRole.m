//
//  GJJanusListenRole.m
//  GJJanus
//
//  Created by melot on 2018/4/3.
//  Copyright © 2018年 MirrorUncle. All rights reserved.
//

#import "GJJanusListenRole.h"
#import "GJJanusMediaConstraints+private.h"

@interface GJJanusListenRole()
{
    RTCVideoTrack* _videoTrack;
    RTCAudioTrack *_audioTrack;
    CGSize  _renderSize;
}

@property (nonatomic, assign) float lostPackage;

@property (nonatomic, assign) float allReceivePackage;

@property (nonatomic, assign) NSInteger needMakeNum;

@property (nonatomic, assign) NSInteger needExitNum;


@end
@implementation GJJanusListenRole
@dynamic delegate;
+(instancetype)roleWithDic:(NSDictionary*)dic janus:(GJJanus*)janus delegate:(id<GJJanusRoleDelegate>)delegate{
    GJJanusListenRole* publish = [[GJJanusListenRole alloc]initWithJanus:janus delegate:delegate];
    if([dic[@"mediatype"] isEqualToString:@"audio"]){
        publish.ID = [[[NSString stringWithFormat:@"%@",dic[@"id"]]  stringByAppendingString:@"01"] integerValue];
    }else if ([dic[@"mediatype"] isEqualToString:@"video"]){
        publish.ID = [[[NSString stringWithFormat:@"%@",dic[@"id"]] stringByAppendingString:@"02"] integerValue];
    }else{
        publish.ID = [[[NSString stringWithFormat:@"%@",dic[@"id"]] stringByAppendingString:@"03"] integerValue];
    }
   
    publish.display = dic[@"display"];
    publish.audioCode = dic[@"audio_codec"];
    publish.videoCode = dic[@"video_codec"];
    return publish;
}

-(instancetype)initWithJanus:(GJJanus *)janus delegate:(id<GJJanusPluginDelegate>)delegate{
    self = [super initWithJanus:janus delegate:delegate];
    if (self) {
        self.pType = kPublishTypeLister;
        self.mediaConstraints = [[GJJanusMediaConstraints alloc]init];
        self.mediaConstraints.audioEnable = YES;
        self.mediaConstraints.videoEnalbe = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelListenAudioStatus) name:@"stopListenAudioStatus" object:nil];
    }
    return self;
}



-(void)joinRoomWithRoomID:(NSInteger)roomID userId:(NSInteger)userId userName:(NSString *)userName block:(RoleJoinMyRoomCallback)block{
   // NSAssert(roomID > 0,@"参数有误");
    
    if (self.attached == NO && self.status == kJanusRoleStatusDetached) {
        WK_SELF;
        NSInteger handle;
        if ([self.mediaType isEqualToString:@"audio"]) {
            handle = GJJanusAudioHandleType;
        }else  if ([self.mediaType isEqualToString:@"video"]) {
            handle = GJJanusVideoHandleType;
        }else if([self.mediaType isEqualToString:@"screen"] || [self.mediaType isEqualToString:@"screenvideo"]) {
            handle = GJJanusScreenHandleType;
        }else{
            handle = GJJanusMessageHandleType;
        }
        [self attachWithHandleType:handle  Callback:^(NSError *error) {
            if (error == nil) {
                if (wkSelf) {
                    [wkSelf joinRoomWithRoomID:roomID userId:userId userName:userName block:^(NSError *error, long myId) {
                        block(error, myId);
                    }];
                }else{
                    block(errorWithCode(-1, @"已经释放"), 0);
                }
            }else{
                block(error, 0);
            }
            
        }];
        return;
    }
    
    [super joinRoomWithRoomID:roomID userId:userId userName:userName block:block];
}

-(void)leaveRoom:(RoleLeaveRoomCallback)leaveBlock{
    [self detachWithCallback:^{
        if (leaveBlock) {
            leaveBlock();
        }
    }];
}

-(void)handleRemoteJesp:(NSDictionary *)jsep{
    RTCSdpType sdpType = RTCSdpTypeAnswer;
    if ([jsep[@"type"] isEqualToString:@"answer"]) {
        sdpType = RTCSdpTypeAnswer;
      //  NSAssert(0, @"not handle");
    }else if ([jsep[@"type"] isEqualToString:@"offer"]){
        sdpType = RTCSdpTypeOffer;
    }else{
       // NSAssert(0, @"not handle");
    }
    RTCSessionDescription* sessionDest = [[RTCSessionDescription alloc]initWithType:sdpType sdp:jsep[@"sdp"]];
    WK_SELF;
    [self.peerConnection setRemoteDescription:sessionDest completionHandler:^(NSError * _Nullable error) {
        if (error == nil) {
            [wkSelf.peerConnection answerForConstraints:[wkSelf.mediaConstraints getAnserConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
                if (error == nil) {
                     RTCSessionDescription *rtcsdp;
                   
                    if(sdp.type == RTCSdpTypeAnswer &&  [self.mediaType isEqualToString:@"audio"]){
                        NSString *temp=@"a=rtpmap:111";
                        NSMutableString* localsdp=[[NSMutableString alloc]initWithString:sdp.sdp];
                        NSRange rangeindex=[localsdp rangeOfString:temp];
                        if(rangeindex.location > 0){
                            [localsdp insertString:@"a=rtcp-fb:111 nack\r\n"  atIndex:rangeindex.location];
                            NSString* sdpdes = [NSString stringWithString: localsdp];
                            rtcsdp = [[RTCSessionDescription alloc]initWithType:sdp.type sdp:sdpdes];
                        }else{
                            rtcsdp = sdp;
                        }
                        
                    }else
                    {
                        rtcsdp = sdp;
                    }
                    
                    [wkSelf.peerConnection setLocalDescription:rtcsdp completionHandler:^(NSError * _Nullable error) {
                        if (error) {
                            assert(0);
                        }
                    }];
                    NSDictionary* jsep = @{@"type":@"answer",@"sdp":sdp.sdp};
                    [wkSelf prepareLocalJesp:jsep];
                }else{
                   // assert(0);
                }
            }];
        }else{
           // assert(0);
        }
    }];
}

-(void)prepareLocalJesp:(NSDictionary *)jsep{
    NSDictionary* msg = @{@"request": @"start", @"room": @(self.roomID)};
    [self.janus sendMessage:msg jsep:jsep handleId:self.handleId  callback:^(NSDictionary *msg, NSDictionary *jsep) {
        if ([msg[@"started"] isEqualToString:@"ok"]) {
            //                            GJAssert([msg[@"room"] integerValue] == wkself.roomID,"应该是对方已经下线了，稍后会收到下线消息，忽略");
        }else{
            //            NSAssert(0,@"应该是对方已经下线了，稍后会收到下线消息，忽略");
        }
    }];
}

-(RTCEAGLVideoView *)renderView{
    if (_renderView == nil) {
        _renderView = [[RTCEAGLVideoView alloc] init];
        _renderView.userInteractionEnabled = NO;
        _renderView.delegate = self;
        if (_videoTrack) {
            [_videoTrack addRenderer:_renderView];
        }
    }
    
    return _renderView;
}

-(void)pluginHandleMessage:(NSDictionary *)msg jsep:(NSDictionary *)jsep transaction:(NSString*)transaction{
    NSLog(@"not handle:%@",msg);
    
    if (jsep != nil) {
        assert(0);
    }
}

- (NSUInteger)getMyUserId{
    return self.userId;
}

-(void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream{
    runAsyncInMainDispatch(^{
        if(stream.videoTracks.count > 0){
            RTCVideoTrack* videoTrack = stream.videoTracks[0];
            [videoTrack addRenderer:self.renderView];
            self->_videoTrack = videoTrack;
 
        }
        
        if(stream.audioTracks.count > 0){
            RTCAudioTrack *audioTrack =stream.audioTracks[0];
              self->_audioTrack = audioTrack;
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getStats) object:nil];
                 [self performSelector:@selector(getStats) withObject:nil afterDelay:3];
            });
        }
        
    });
}

-(void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveStream:(RTCMediaStream *)stream{
    _videoTrack = nil;
    _audioTrack = nil;
    _renderSize = CGSizeZero;
}

-(void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size{
    if (CGSizeEqualToSize(_renderSize, CGSizeZero)) {
        _renderSize = size;
        [self.delegate janusListenRole:self firstRenderWithSize:size];
    }else{
        [self.delegate janusListenRole:self renderSizeChangeWithSize:size];
    }
}


- (void)getStats{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getStats) object:nil];
    });
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"meetingRoomMoreThanOne"] isEqualToString:@"NO"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(getStats) withObject:nil afterDelay:3];
        });
        return;
    }
    
    if (_audioTrack && self.peerConnection) {
        [self.peerConnection statsForTrack:self->_audioTrack statsOutputLevel:RTCStatsOutputLevelStandard completionHandler:^(NSArray<RTCLegacyStatsReport *> * _Nonnull stats) {
            for (RTCLegacyStatsReport *report  in stats) {
                if([report.type isEqualToString:@"ssrc"]){
                    if (report.values[@"packetsLost"] &&report.values[@"packetsReceived"]) {
                        self.lostPackage = [report.values[@"packetsLost"] floatValue] - self.lostPackage;
                        self.allReceivePackage = [report.values[@"packetsReceived"] floatValue] - self.allReceivePackage;
                        float cer =  self.lostPackage/self.allReceivePackage;
                        if (self.allReceivePackage == 0) {
                             self.needMakeNum = 0;
                            self.needExitNum ++;
                            if (self.needExitNum == 3) {
                                self.needExitNum = 0;
                                [super remoteReConnect];
                            }
                        }else{
                            if (cer > 0.4){
                            //[MBManager showBriefAlert:@"当前您的通话网络不佳"];
                            }
                            
//                            self.needExitNum = 0;
//                            if (cer > 0.4){
//                                self.needMakeNum ++;
//                                if(self.needMakeNum == 3){
//                                    self.needMakeNum = 0;
//                                     [MBManager showBriefAlert:@"当前您的通话网络不佳"];
//                                   // [[NSNotificationCenter defaultCenter] postNotificationName:@"userAutoDismissSelf" object:nil];
//                                }
//                            }else if(cer > 0.15 && cer < 0.4){
//                                self.needMakeNum = 0;
//                                [MBManager showBriefAlert:@"当前您的通话网络不佳"];
//                            }
                        }
                        
                       
                    }
                }

            }
        }];
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(getStats) withObject:nil afterDelay:3];
    });


}

- (void)cancelListenAudioStatus{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getStats) object:nil];
    });
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)dealloc{
    //    GJLOG(GNULL, GJ_LOGINFO,"%s",self.description.UTF8String);
}
@end

