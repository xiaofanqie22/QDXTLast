//
//  GJJanusPublishRole.m
//  GJJanus
//
//  Created by melot on 2018/4/3.
//  Copyright © 2018年 MirrorUncle. All rights reserved.
//

#import "GJJanusPublishRole.h"
#import "GJJanusListenRole.h"
#import "GJJanusMediaConstraints+private.h"
#import "RTCFactory.h"

//#import "GJLog.h"
static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";
@interface GJJanusPublishRole(){
}

@property (nonatomic, strong) RTCAudioTrack *rtcAudioTrack;
@property (nonatomic, strong) RTCVideoTrack *rtcVideoTrack;
@property (nonatomic, strong) RTCRtpSender *videoSender;

@property(nonatomic,strong)RTCPeerConnection* audioPeerConnection;
@property(nonatomic,strong)RTCPeerConnection* videoPeerConnection;
@property(nonatomic,strong)RTCPeerConnection* screenPeerConnection;

@property (nonatomic, assign)BOOL isUserCloseVideo;

@property (nonatomic, assign) float lostPackage;

@property (nonatomic, assign) float allSendPackage;

@property (nonatomic, assign) NSInteger needMakeNum;

@end
@implementation GJJanusPublishRole
@synthesize mediaConstraints = _mediaConstraints;
@synthesize localCamera = _localCamera;
//@dynamic mediaConstraints;
+(instancetype)roleWithDic:(NSDictionary*)dic janus:(GJJanus*)janus delegate:(id<GJJanusRoleDelegate>)delegate{
    GJJanusPublishRole* publish = [[GJJanusPublishRole alloc]initWithJanus:janus delegate:delegate];
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
        self.pType = kPublishTypePublish;
        //        if (self.janus.sessionID != 0) {
        //            [self attachWithCallback:nil];
        //        }
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelListenAudioStatus) name:@"stopListenAudioStatus" object:nil];
    }
    return self;
}

-(void)setMediaConstraints:(GJJanusPushlishMediaConstraints *)mediaConstraints{
    _mediaConstraints = mediaConstraints;
    
    CGSize pushSize = mediaConstraints.pushSize;
    GJPixelFormat format = {.mType = GJPixelType_YpCbCr8BiPlanar_Full,.mWidth = pushSize.width,.mHeight = pushSize.height};
    self.localCamera.pixelFormat = format;
    self.localCamera.frameRate = mediaConstraints.fps;
}

-(KKRTCVideoCapturer *)localCamera{
    if (_localCamera == nil) {
        _localCamera = [[KKRTCVideoCapturer alloc]initWithDelegate:self.videoSource];
        if (self.mediaConstraints) {
            CGSize pushSize = self.mediaConstraints.pushSize;
            GJPixelFormat format = {GJPixelType_YpCbCr8Planar_Full,pushSize.width,pushSize.height};
            _localCamera.pixelFormat = format;
            _localCamera.frameRate = self.mediaConstraints.fps;
        }
    }
    return _localCamera;
}

-(GJImageView *)renderView{
    return self.localCamera.previewView;
}


-(RTCPeerConnection *)audioPeerConnection{
    if (_audioPeerConnection == nil) {
        RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
        NSMutableDictionary* optionalDic = [NSMutableDictionary dictionaryWithCapacity:1];
        optionalDic[@"DtlsSrtpKeyAgreement"] = @"true";
        if (!_audioPeerConnection) {
            RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc]
                                                initWithMandatoryConstraints:nil
                                                optionalConstraints:optionalDic];
            
            _audioPeerConnection = [[RTCFactory shareFactory].peerConnectionFactory
                                    peerConnectionWithConfiguration:configuration
                                    constraints:constraints
                                    delegate:self];
            
        }
    }
    return _audioPeerConnection;
}

-(RTCPeerConnection *)createVideoConnect{
//    if (_videoPeerConnection == nil) {
        RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
        NSMutableDictionary* optionalDic = [NSMutableDictionary dictionaryWithCapacity:1];
        optionalDic[@"DtlsSrtpKeyAgreement"] = @"true";
//        if (!_videoPeerConnection) {
            RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc]
                                                initWithMandatoryConstraints:nil
                                                optionalConstraints:optionalDic];
            
        RTCPeerConnection *connection = [[RTCFactory shareFactory].peerConnectionFactory
                                    peerConnectionWithConfiguration:configuration
                                    constraints:constraints
                                    delegate:self];
            
//        }
//    }
    return connection;
}

-(RTCPeerConnection *)screenPeerConnection{
    if (_screenPeerConnection == nil) {
        RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
        NSMutableDictionary* optionalDic = [NSMutableDictionary dictionaryWithCapacity:1];
        optionalDic[@"DtlsSrtpKeyAgreement"] = @"true";
        if (!_screenPeerConnection) {
            RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc]
                                                initWithMandatoryConstraints:nil
                                                optionalConstraints:optionalDic];
            
            _screenPeerConnection = [[RTCFactory shareFactory].peerConnectionFactory
                                     peerConnectionWithConfiguration:configuration
                                     constraints:constraints
                                     delegate:self];
            
        }
    }
    return _screenPeerConnection;
}

-(RTCVideoSource *)videoSource{
    if (_videoSource == nil) {
        _videoSource = [[RTCFactory shareFactory].peerConnectionFactory videoSource];
    }
    return _videoSource;
}

-(RTCAudioSource*)audioSource{
    if (_audioSource == nil) {
        _audioSource = [[RTCFactory shareFactory].peerConnectionFactory audioSourceWithConstraints:[self.mediaConstraints getAudioConstraints]];
    }
    return _audioSource;
}

- (RTCRtpSender *)createAudioSender:(BOOL)enabled {
    RTCAudioSource *source = self.audioSource;
    self.rtcAudioTrack = [[RTCFactory shareFactory].peerConnectionFactory audioTrackWithSource:source
                                                                                       trackId:kARDAudioTrackId];
    self.rtcAudioTrack.isEnabled = enabled;
    
    RTCMediaStream *mediaStream = [[RTCFactory shareFactory].peerConnectionFactory mediaStreamWithStreamId:kARDMediaStreamId];
    [mediaStream addAudioTrack:self.rtcAudioTrack];
    [self.audioPeerConnection addStream:mediaStream];
    // 添加 local video track
    return nil;
//    RTCRtpSender *sender = [self.audioPeerConnection senderWithKind:kRTCMediaStreamTrackKindAudio streamId:kARDMediaStreamId];
//    sender.track = self.rtcAudioTrack;
//    return sender
}

- (RTCRtpSender *)createVideoSender:(BOOL)enabled {
    self.videoPeerConnection = [self createVideoConnect];
    self.videoSender =
    [self.videoPeerConnection senderWithKind:kRTCMediaStreamTrackKindVideo streamId:kARDMediaStreamId];
    self.rtcVideoTrack = [[RTCFactory shareFactory].peerConnectionFactory videoTrackWithSource:self.videoSource trackId:kARDVideoTrackId];
    self.rtcVideoTrack.isEnabled = enabled;
     self.videoSender.track = self.rtcVideoTrack;
    return  self.videoSender;
}

-(void)startPreview{
    [self.localCamera startPreview];
}

-(void)stopPreview{
    if (![self.localCamera.camera isRunning]) {
        return;
    }
    [self.localCamera stopPreview];
}

-(void)joinRoomWithRoomID:(NSInteger)roomID userId:(NSInteger)userId userName:(NSString *)userName block:(RoleJoinMyRoomCallback)block{
   // NSAssert(roomID > 0 && userName.length > 1,@"参数有误");
    if (self.attached == NO) {
        WK_SELF;
        [self attachWithHandleType:GJJanusMessageHandleType Callback:^(NSError *error) {
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
    
    [super joinRoomWithRoomID:roomID  userId:userId userName:userName block:^(NSError* error, long myId){
        if (error == nil) {
            NSLog(@"success");
        }
        if (block){
            block(error, myId);
        }
    }];
    
}

- (void)userResetrtcAudioTrack{
    [self.videoPeerConnection close];
    [self.videoPeerConnection removeTrack:self.videoSender];
    self.rtcAudioTrack = nil;
}


- (void)usermuteAudio:(BOOL)muteAudio block:(RoleMuteAudioallback)callback{
    NSDictionary* msg;
    if (muteAudio) {
        msg = @{ @"request": @"muteAudio"};
        [self sendMessage:msg  Type:GJJanusAudioHandleType callback:^(NSDictionary *msg, NSDictionary *jsep) {
            self.mediaConstraints.audioEnable = !muteAudio;
            self.rtcAudioTrack.isEnabled = self.mediaConstraints.audioEnable;
            if (msg[@"error"] != nil ) {
                NSError* error =  errorWithCode([msg[@"error_code"] intValue], msg[@"error"]);
                callback(error);
            }else{
                callback(nil);
            }
        }];
        return;
    }
    if (muteAudio == YES) {
        msg = @{ @"request": @"muteAudio"};
    }else{
        msg = @{ @"request": @"unmuteAudio"};
    }
    if(!self.rtcAudioTrack){
        msg = @{ @"request": @"unmuteAudio"};
        [self createAudioSender:self.mediaConstraints.audioEnable];
        [self sendOffer:GJJanusAudioHandleType successCallBack:^{
            [self sendMessage:msg  Type:GJJanusAudioHandleType callback:^(NSDictionary *msg, NSDictionary *jsep) {
                self.mediaConstraints.audioEnable = YES;
                self.rtcAudioTrack.isEnabled = self.mediaConstraints.audioEnable;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getSenderStats) object:nil];
                    [self performSelector:@selector(getSenderStats) withObject:nil afterDelay:3];
                });
                if (msg[@"error"] != nil ) {
                    NSError* error =  errorWithCode([msg[@"error_code"] intValue], msg[@"error"]);
                    callback(error);
                }else{
                    callback(nil);
                }
            }];            
        }];
    }else{
        [self sendMessage:msg  Type:GJJanusAudioHandleType callback:^(NSDictionary *msg, NSDictionary *jsep) {
            self.mediaConstraints.audioEnable = !muteAudio;
            self.rtcAudioTrack.isEnabled = self.mediaConstraints.audioEnable;
            if (msg[@"error"] != nil ) {
                NSError* error =  errorWithCode([msg[@"error_code"] intValue], msg[@"error"]);
                callback(error);
            }else{
                callback(nil);
            }
        }];
    }
}

- (void)userSendMessage:(NSString  *)message isToAll:(BOOL)isToAll block:(RoleSendMessageCallBack)callback{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"chat" forKey:@"request"];
    [dic setObject:message forKey:@"data"];
    if (isToAll) {
        [dic setObject:@"all" forKey:@"to"];
    }else{
        [dic setObject:@"host" forKey:@"to"];
    }
    
    [self sendMessage:dic Type:GJJanusMessageHandleType callback:^(NSDictionary *msg, NSDictionary *jsep) {
        if([msg[@"chat"]  intValue] == 1){
            callback(nil);
        }else{
            NSError *error;
            callback(error);
        }
    }];
}

- (void)usermuteVideo:(BOOL)muteVideo  block:(RoleMuteVideoCallback)callback{
    NSDictionary* msg;
    if (muteVideo == YES) {
        self.localCamera.previewView.hidden = YES;
        msg = @{ @"request": @"unpublish"};
    }else{
        self.localCamera.previewView.hidden = NO;
        msg = @{ @"request": @"publish"};
    }
    if (muteVideo == NO) {
        [self.localCamera startProduce];
        [self startPreview];
        [self createVideoSender:YES];
        NSLog(@"打开或者关闭--打开");
         [self sendMessage:msg  Type:GJJanusVideoHandleType callback:^(NSDictionary *msg, NSDictionary *jsep) {
           [self sendOffer:GJJanusVideoHandleType successCallBack:^{
//                self.mediaConstraints.videoEnalbe = !muteVideo;
//                self.rtcVideoTrack.isEnabled = self.mediaConstraints.videoEnalbe;
                if (msg[@"error"] != nil ) {
                    NSError* error =  errorWithCode([msg[@"error_code"] intValue], msg[@"error"]);
                    callback(error);
                }else{
                    callback(nil);
                }
                
            }];
        }];
        return;
    }
    
   

    [self sendMessage:msg  Type:GJJanusVideoHandleType callback:^(NSDictionary *msg, NSDictionary *jsep) {
        if (msg[@"error"] != nil ) {
            NSError* error =  errorWithCode([msg[@"error_code"] intValue], msg[@"error"]);
            callback(error);
            
        }else{
            self.isUserCloseVideo = YES;
            [self.videoPeerConnection close];
            [self.videoPeerConnection removeTrack:self.videoSender];
            [self.localCamera.camera stopCameraCapture];
            callback(nil);
        }
        
    }];
    
    
}

-(void)leaveRoom:(RoleLeaveRoomCallback)leaveBlock{
    //    [super leaveRoom:^() {
    //        leaveBlock();
    //    }];
    
    if (self.isUserCloseVideo) {
        self.isUserCloseVideo = NO;
        return;
    }
    
    if (self.audioPeerConnection.iceConnectionState !=RTCIceConnectionStateNew ) {
        [self.audioPeerConnection close];
        self.audioPeerConnection = nil;
    }
    
    if (self.screenPeerConnection.iceConnectionState !=RTCIceConnectionStateNew ) {
        [self.screenPeerConnection close];
        self.screenPeerConnection = nil;
    }
    
    if (self.videoPeerConnection.iceConnectionState !=RTCIceConnectionStateNew) {
        [self.videoPeerConnection close];
        self.videoPeerConnection = nil;
        // if (self.localCamera ) {
        [self.localCamera stopProduce];
        //  }
    }
    
    
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
    }else if ([jsep[@"type"] isEqualToString:@"offer"]){
        sdpType = RTCSdpTypeOffer;
        //NSAssert(0, @"not handle");
    }else{
       // NSAssert(0, @"not handle");
    }
    
    RTCPeerConnection *connection;
    
    if (self.handleType == GJJanusAudioHandleType) {
        
        connection = self.audioPeerConnection;
    }if (self.handleType == GJJanusVideoHandleType) {
        connection = self.videoPeerConnection;
    }if (self.handleType == GJJanusScreenHandleType) {
        connection = self.screenPeerConnection;
    }
    RTCSessionDescription* sessionDest = [[RTCSessionDescription alloc]initWithType:sdpType sdp:jsep[@"sdp"]];
    [connection setRemoteDescription:sessionDest completionHandler:^(NSError * _Nullable error) {

    }];
}

-(void)pluginHandleMessage:(NSDictionary *)msg jsep:(NSDictionary *)jsep transaction:(NSString*)transaction{
    
    NSString* event = msg[@"videoroom"];
    if([event isEqualToString:@"event"]){
        if (msg [@"joining"] !=nil) {
            NSDictionary *dic =msg [@"joining"];
            NSMutableArray *array = [NSMutableArray arrayWithObject:dic];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoRoomPerson" object:array];
        }
        
        if (msg[@"publishers"] != nil) {
            NSArray* list = msg[@"publishers"];
            for (NSDictionary* item in list) {
 
                GJJanusListenRole* listener = [GJJanusListenRole roleWithDic:item janus:self.janus delegate:self.delegate];
                listener.privateID = [item[@"id"] integerValue];
                listener.privateIDNew = listener.privateID;
                listener.opaqueId = self.opaqueId;
                if([item[@"mediatype"] isEqualToString:@"audio"]){
                    listener.ID = [[[NSString stringWithFormat:@"%@",item[@"id"]]  stringByAppendingString:@"01"] integerValue];
                }else if ([item[@"mediatype"] isEqualToString:@"video"]){
                    listener.ID = [[[NSString stringWithFormat:@"%@",item[@"id"]] stringByAppendingString:@"02"] integerValue];
                }else if ([item[@"mediatype"] isEqualToString:@"screen"] ||[item[@"mediatype"] isEqualToString:@"screenvideo"]){
                    listener.ID = [[[NSString stringWithFormat:@"%@",item[@"id"]] stringByAppendingString:@"03"] integerValue];
                    if(msg[@"timer_id"]){
                        [self sendMessage:@{@"id":@6901,@"request":@"timers",@"room":@(self.roomID),@"timer_id":msg[@"timer_id"]} Type:GJJanusMessageHandleType callback:^(NSDictionary *msg, NSDictionary *jsep) {
                        }];
                    }
                }
                else{
                    listener.ID = [item[@"id"] integerValue];
                }
                listener.mediaType = item[@"mediatype"];
                // self.ID = listener.ID;
                if ([listener.mediaType isEqualToString:@"audio"]) {
                    [self.delegate GJJanusRole:self didJoinRemoteAudioRole:listener];
                }else{
                    [self.delegate GJJanusRole:self didJoinRemoteRole:listener];
                }
              
            }
        }else if(msg[@"leaving"] != nil){
            id leave = msg[@"leaving"];
            if ([leave isKindOfClass:[NSString class]]) {
                assert(0);
            }else{
                NSInteger leaveId = [leave unsignedIntegerValue];
                [self.delegate GJJanusRole:self didLeaveRemoteRoleWithUid:leaveId];
            }
        }else if(msg[@"error"] != nil){
            //  NSAssert(0, @"not handle");
        }else if(msg[@"unpublished"] != nil){
            NSUInteger unpubId = [msg[@"unpublished"] unsignedIntegerValue];
            if([msg[@"mediatype"] isEqualToString:@"audio"]){
                unpubId = [[[NSString stringWithFormat:@"%ld",unpubId]  stringByAppendingString:@"01"] integerValue];
            }else if ([msg[@"mediatype"] isEqualToString:@"video"]){
               unpubId = [[[NSString stringWithFormat:@"%ld",unpubId] stringByAppendingString:@"02"] integerValue];
            }else if ([msg[@"mediatype"] isEqualToString:@"screen"]||[msg[@"mediatype"] isEqualToString:@"screenvideo"]){
                unpubId = [[[NSString stringWithFormat:@"%ld",unpubId] stringByAppendingString:@"03"] integerValue];
            }
            
            [self.delegate GJJanusRole:self remoteUnPublishedWithUid:unpubId];
        }else if (msg[@"muteVideo"] !=nil){
//            NSString *clientId = msg[@"muteVideo"];
//            [self.delegate GJJanusRole:self UserChangeVideoEnable:NO andID:[clientId integerValue]];
        }else if (msg[@"unmuteVideo"] !=nil){
//            NSString *clientId = msg[@"unmuteVideo"];
//            [self.delegate GJJanusRole:self UserChangeVideoEnable:YES andID:[clientId integerValue ]];
        }else if(msg[@"allmute"]){
            [self.delegate GJJanusRole:self allmuteAudio:YES];
        }else if([msg[@"configure"] isEqualToString:@"chat"] && msg[@"configure"]){
            [self.delegate GJJanusRole:self userGetMessageData:msg];
        }else if([msg[@"configure"] isEqualToString:@"turn_screen"] && msg[@"configure"]){
            if ([msg[@"on"] boolValue] == NO) {
               [self.delegate GJJanusRole:self AdminCloseUnPublishedWithMessageData:msg];
            }
           
        }
    }else if([event isEqualToString:@"destroyed"]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusRole:endMeeting:)]) {
            [self.delegate GJJanusRole:self endMeeting:YES];
        }
        // NSAssert(0, @"The room has been destroyed!");
    }else if([event isEqualToString:@"slow_link"]){
    }else{
        //NSAssert(0, @"not handle");
    }
}

-(void)configBitrateWithConnection:(RTCPeerConnection*)Connection{
    if (self.mediaConstraints.videoBitrate > 0) {
        NSArray<RTCRtpSender *> *senders = Connection.senders;
        for (RTCRtpSender *sender in senders) {
            if (sender.track != nil) {
                if ([sender.track.kind isEqualToString:kARDVideoTrackKind]) {
                    RTCRtpParameters *parametersToModify = sender.parameters;
                    for (RTCRtpEncodingParameters *encoding in parametersToModify.encodings) {
                        encoding.maxBitrateBps = @(self.mediaConstraints.videoBitrate);
                    }
                    [sender setParameters:parametersToModify];
                }
            }
        }
    }
}

-(void)sendOffer:(GJJanusHandleType)type successCallBack:(RoleSendOfferSuccessCallBack)callBack{
    RTCMediaConstraints* constraints = [self.mediaConstraints getOfferConstraints];
    self.handleType = type;
    __weak GJJanusPublishRole* wkself = self;
    NSDictionary* msg =nil;
    
    NSNumber *handId;
    RTCPeerConnection *connection;
#warning 这里控制视频和音频本地流的开关
    if (type == GJJanusAudioHandleType) {
        msg =  @{@"request":@"configure",@"audio": @(YES),@"video": @(NO),@"screen":@(NO)};
        handId = self.audioHandleId;
        connection = self.audioPeerConnection;
    }if (type == GJJanusVideoHandleType) {
        msg =  @{@"request":@"configure",@"audio": @(NO) , @"video": @(YES),@"screen":@(NO)};
        handId = self.videoHandleId;
        connection = self.videoPeerConnection;
    }if (type == GJJanusScreenHandleType) {
        msg =  @{@"request":@"configure",@"audio": @(NO) , @"video": @(NO),@"screen":@(YES)};
        handId = self.screenHandleId;
        connection = self.screenPeerConnection;
    }
    [connection offerForConstraints:constraints
                  completionHandler:^(RTCSessionDescription *sdp,
                                      NSError *error) {
                      if (error == nil) {
                          RTCSessionDescription *rtcsdp;
                          if(sdp.type == RTCSdpTypeOffer && type == GJJanusAudioHandleType){
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
                          
                          RTCSessionDescription *sdpPreferringCodec =
                          [Tools descriptionForDescription:rtcsdp preferredVideoCodec:[wkself.mediaConstraints videoCode]];
                          //                                   dispatch_async(dispatch_get_main_queue(), ^{
                          [connection setLocalDescription:sdpPreferringCodec completionHandler:^(NSError * _Nullable error) {
                              assert(error == nil);
                              NSDictionary* jsep = @{@"type":@"offer",@"sdp":sdpPreferringCodec.sdp};
                              [wkself.janus sendMessage:msg jsep:jsep handleId:handId callback:^(NSDictionary *msg, NSDictionary *jsep) {
                                  if ([msg[@"configured"] isEqualToString:@"ok"]) {
                                      if (jsep) {
                                          [wkself handleRemoteJesp:jsep];
                                          callBack();
                                      }else{
                                          //       assert(0);
                                      }
                                  }else{
                                      //assert(0);
                                  }
                              }];
                          }];
                          [wkself configBitrateWithConnection:connection];
                          
                      }
                  }];
}

- (void)getSenderStats{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getSenderStats) object:nil];
    });


    if (self.audioPeerConnection && self.rtcAudioTrack) {
        [self.audioPeerConnection statsForTrack:self.rtcAudioTrack statsOutputLevel:RTCStatsOutputLevelStandard completionHandler:^(NSArray<RTCLegacyStatsReport *> * _Nonnull stats) {
            for (RTCLegacyStatsReport *report  in stats) {
                NSLog(@"xxxxxtype___%@",report.type);
                NSLog(@"xxxxxvlues___%@",report.values);
                if([report.type isEqualToString:@"ssrc"]){
                    if (report.values[@"packetsLost"] &&report.values[@"packetsSent"]) {
                        NSLog(@"sendPackage:%@",report.values[@"packetsSent"]);
                        
                      //  self.lostPackage = [report.values[@"packetsLost"] floatValue] - self.lostPackage;
                        self.allSendPackage = [report.values[@"packetsSent"] floatValue] - self.allSendPackage;
//                        if () {
//                            <#statements#>
//                        }
                      //  float cer =  self.lostPackage/self.allSendPackage;
                
                        if (self.allSendPackage == 0){
                           // [MBManager showBriefAlert:@"当前你的通话网络不佳"];
                            self.needMakeNum ++;
                            if(self.needMakeNum == 3){
                                self.needMakeNum = 0;
                                [super remoteReConnect];
                            }
                        }else{
                          self.needMakeNum = 0;
                        }
                    }
                }

            }
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(getSenderStats) withObject:nil afterDelay:3];
    });


}

- (void)cancelListenAudioStatus{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getSenderStats) object:nil];
    });
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc{
    NSLog(@"delloc:%p",self);
    //    GJLOG(GNULL, GJ_LOGINFO,"%s",self.description.UTF8String);
}

@end
