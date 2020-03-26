//
//  GJJanusRole.m
//  GJJanus
//
//  Created by melot on 2018/4/3.
//  Copyright © 2018年 MirrorUncle. All rights reserved.
//

#import "GJJanusRole.h"
#import "GJJanusListenRole.h"
#import "RTCFactory.h"

//#define GOOGLE_ICE @"stun:stun.l.google.com:19302"
@interface GJJanusRole()
{
    GJJanusRoleStatus _status;
}
@end
@implementation GJJanusRole
@dynamic delegate;

+(instancetype)roleWithDic:(NSDictionary*)dic janus:(GJJanus*)janus delegate:(id<GJJanusRoleDelegate>)delegate{
    GJJanusRole* publish = [[GJJanusRole alloc]initWithJanus:janus delegate:delegate];
    if([dic[@"mediatype"] isEqualToString:@"audio"]){
        publish.ID = [[[NSString stringWithFormat:@"%@",dic[@"id"]]  stringByAppendingString:@"01"] integerValue];
    }else if ([dic[@"mediatype"] isEqualToString:@"video"]){
        publish.ID = [[[NSString stringWithFormat:@"%@",dic[@"id"]] stringByAppendingString:@"02"] integerValue];
    }else{
        publish.ID = [[[NSString stringWithFormat:@"%@",dic[@"id"]] stringByAppendingString:@"03"] integerValue];
    }
    publish.display = dic[@"display"];
    publish.mediaType = dic[@"mediatype"];
    publish.audioCode = dic[@"audio_codec"];
    publish.videoCode = dic[@"video_codec"];
    return publish;
}
-(instancetype)initWithJanus:(GJJanus*)janus delegate:(id<GJJanusRoleDelegate>)delegate{
    self = [super initWithJanus:janus delegate:delegate];
    if (self) {
        // self.opaqueId = [NSString stringWithFormat:@"videoroomtest-%@",randomString(12)];
        self.pluginName = @"janus.plugin.videoroom";
        
    }
    return self;
}
-(void)setStatus:(GJJanusRoleStatus)status{
    _status = status;
}
- (BOOL)attachWithCallback:(AttchResult)resultCallback{
    self.status = kJanusRoleStatusAttaching;
    WK_SELF;
    return [super attachWithHandleType:GJJanusMessageHandleType Callback:^(NSError *error) {
        if (error == nil) {
            wkSelf.status = kJanusRoleStatusAttached;
        }else{
            wkSelf.status = kJanusRoleStatusDetached;
        }
        if (resultCallback) {
            resultCallback(error);
        }
    }];
}

-(RTCPeerConnection *)peerConnection{
    if (_peerConnection == nil) {
        RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
        NSMutableDictionary* optionalDic = [NSMutableDictionary dictionaryWithCapacity:1];
        optionalDic[@"DtlsSrtpKeyAgreement"] = @"true";
        if (!_peerConnection) {
            RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc]
                                                initWithMandatoryConstraints:nil
                                                optionalConstraints:optionalDic];
            
            _peerConnection = [[RTCFactory shareFactory].peerConnectionFactory
                               peerConnectionWithConfiguration:configuration
                               constraints:constraints
                               delegate:self];
            
        }
    }
    return _peerConnection;
}

-(void)detachWithCallback:(DetachedResult)result{
    if(self.status <= kJanusRoleStatusDetaching)return;
    self.status = kJanusRoleStatusDetaching;
    WK_SELF;
    [super detachWithCallback:^(){
        wkSelf.status = kJanusRoleStatusDetached;
    }];
    [self destoryRTCPeer];
    
}

- (void)createRoomWithRoomId:(NSInteger )roomID blcok:(RoleCreateRoomCallback)block{
    self.status = kJanusRoleStatusAttaching;
    [super attachWithHandleType:GJJanusMessageHandleType  Callback:^(NSError *error) {
        if (!error) {
            NSDictionary* msg;
            msg = @{ @"request": @"create", @"description": @"uWorker meeting", @"room": @(roomID),@"bitrate": @(128000), @"bitrate_cap": @(YES),@"publishers": @(50), @"notify_joining": @(YES),@"ptype":@"publisher"};
            [self sendMessage:msg  Type:GJJanusMessageHandleType callback:^(NSDictionary *msg, NSDictionary *jsep) {
                if (msg[@"error"] != nil ) {
                    NSError* error =  errorWithCode([msg[@"error_code"] intValue], msg[@"error"]);
                    if (error.code == 427) {
                        block(nil);
                    }else{
                        block(error);
                    }
                    
                }else{
                    block(nil);
                }
            }];
        }
    }];
    
    
    [super attachWithHandleType:GJJanusAudioHandleType Callback:^(NSError *error) {
        if (!error) {
          
        }
    }];
    
    [super attachWithHandleType:GJJanusVideoHandleType Callback:^(NSError *error) {
        if (!error) {
          
        }
    }];
    
    [super attachWithHandleType:GJJanusScreenHandleType Callback:^(NSError *error) {
        if (!error) {
          
        }
    }];
}

-(void)remoteReConnect{
    [self.peerConnection close];
    self.peerConnection = nil;
    self.pType = kPublishTypeLister;
    self.attached = NO;
    self.status = kJanusRoleStatusDetached;
    [self joinRoomWithRoomID:self.roomID userId:self.userId userName:self.userName block:^(NSError *error, long myId) {
        
    }];
}

-(void)joinRoomWithRoomID:(NSInteger)roomID userId:(NSInteger)userId userName:(NSString *)userName block:(RoleJoinMyRoomCallback)block{
    self.roomID = roomID;
    self.userId = userId;
    self.userName = userName;
    NSDictionary* msg;
    WK_SELF;
    if (self.pType == kPublishTypePublish) {

        extern NSString *BASEURL;
        if (userName == nil) {
            msg = @{ @"request": @"join", @"room": @(roomID), @"ptype": @"publisher",@"terminal":@"ios",@"id":@(userId),@"imgurl":@"",@"version":@"1"};
        }else{
            msg = @{ @"request": @"join", @"room": @(roomID), @"ptype": @"publisher",@"display":userName,@"terminal":@"ios",@"id":@(userId),@"imgurl":@"",@"version":@"1"};
        }
    }else{
        
        NSString *idStr = [NSString stringWithFormat:@"%lu",(unsigned long)self.ID];
        msg = @{ @"request": @"join", @"room": @(roomID), @"ptype": @"listener",@"feed": @([[idStr substringToIndex:idStr.length - 2]integerValue]),@"private_id": self.privateID > 0 ? @(self.privateID) : @(self.privateIDNew),@"mediatype":self.mediaType};
    }
    
    self.status = kJanusRoleStatusJoining;
    [self.janus sendMessage:msg handleId:self.handleId callback:^(NSDictionary *msg, NSDictionary *jsep) {
        
        if (msg[@"error"] != nil ) {
            NSError* error =  errorWithCode([msg[@"error_code"] intValue], msg[@"error"]);
            block(error, 0);
        }else {

            wkSelf.status = kJanusRoleStatusJoined;
            if([wkSelf.mediaType isEqualToString:@"audio"]){
                wkSelf.ID = [[[NSString stringWithFormat:@"%@",msg[@"id"]]  stringByAppendingString:@"01"] integerValue];
            }else if ([wkSelf.mediaType isEqualToString:@"video"]){
                wkSelf.ID = [[[NSString stringWithFormat:@"%@",msg[@"id"]] stringByAppendingString:@"02"] integerValue];
            }else if ([wkSelf.mediaType isEqualToString:@"screen"]||[wkSelf.mediaType isEqualToString:@"screenvideo"]){
                wkSelf.ID = [[[NSString stringWithFormat:@"%@",msg[@"id"]] stringByAppendingString:@"03"] integerValue];
            }
            else{
                wkSelf.ID = wkSelf.ID = [msg[@"id"] integerValue];
                
            }
            
            if (msg[@"list"] !=nil) {
                NSArray *personArray = msg[@"list"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoRoomPerson" object:personArray];
            }
            
            wkSelf.privateID = [msg[@"private_id"] integerValue];
            wkSelf.privateIDNew = wkSelf.privateID;
            block(nil, [msg[@"id"] longValue]);
            if (msg[@"publishers"] != nil) {
                NSArray* list = msg[@"publishers"];
                for (NSDictionary* item in list) {
                   
                    GJJanusListenRole* listener = [GJJanusListenRole roleWithDic:item janus:wkSelf.janus delegate:self.delegate];
                    listener.privateID = [item[@"id"] integerValue];
                    if (listener.privateIDNew <= 0) {
                        listener.privateIDNew = listener.privateID;
                    }
                    listener.opaqueId = wkSelf.opaqueId;
                    listener.mediaType = item[@"mediatype"];
                    if([item[@"mediatype"] isEqualToString:@"audio"]){
                        listener.ID = [[[NSString stringWithFormat:@"%@",item[@"id"]]  stringByAppendingString:@"01"] integerValue];
                    }else if ([item[@"mediatype"] isEqualToString:@"video"]){
                        listener.ID = [[[NSString stringWithFormat:@"%@",item[@"id"]] stringByAppendingString:@"02"] integerValue];
                    }else if ([item[@"mediatype"] isEqualToString:@"screen"]||[item[@"mediatype"] isEqualToString:@"screenvideo"]){
                        listener.ID = [[[NSString stringWithFormat:@"%@",item[@"id"]] stringByAppendingString:@"03"] integerValue];
                    }
                    else{
                        listener.ID = [item[@"id"] integerValue];
                    }
                    if ([listener.mediaType isEqualToString:@"audio"]) {
                         [wkSelf.delegate GJJanusRole:wkSelf didJoinRemoteAudioRole:listener];
                    }else{
                        [wkSelf.delegate GJJanusRole:wkSelf didJoinRemoteRole:listener];
                    }
                   
  
            }
            }
            if (jsep) {
                [wkSelf handleRemoteJesp:jsep];
            }
        }
        
    }];
}
-(void)leaveRoom:(RoleLeaveRoomCallback)leaveBlock{
    NSDictionary* msg = @{ @"request": @"leave"};
    WK_SELF;
    if (self.status > kJanusRoleStatusJoining) {
        self.status = kJanusRoleStatusLeaveing;
        [self.janus sendMessage:msg handleId:self.handleId callback:^(NSDictionary *msg, NSDictionary *jsep) {
            wkSelf.status = kJanusRoleStatusLeaved;
            id leave = msg[@"leaving"];
            [wkSelf destoryRTCPeer];
            NSAssert([leave isKindOfClass:[NSString class]],@"接收的json 格式有误");
            leaveBlock();
            if ([msg[@"leaving"] isEqualToString:@"ok"]) {
                
            }else{
                assert(0);
            }
        }];
    }
}

-(void)destoryRTCPeer{
    if (_peerConnection) {
        [_peerConnection close];
        _peerConnection = nil;
    }
}

-(void)dealloc{
    [self destoryRTCPeer];
}

-(void)newRemoteFeed:(GJJanusListenRole*)listener{
    assert(0);
    [self.delegate GJJanusRole:self didJoinRemoteRole:listener];
}

-(void)handleRemoteJesp:(NSDictionary *)jsep{
    assert(0);
}

#pragma mark janus delegate

- (void)pluginWebrtcState:(BOOL)on{
    
}

-(void)pluginDTLSHangupWithReson:(NSString *)reason{
    if (self.status == kJanusRoleStatusJoined) {
        //        assert(0);
        WK_SELF;
        [self leaveRoom:^{
            [wkSelf joinRoomWithRoomID:wkSelf.roomID userId:self.userId userName:wkSelf.display block:^(NSError *error, long myId) {
                //                assert(0);
            }];
        }];
    }
}

-(void)pluginDetached{
    [super pluginDetached];
    self.status = kJanusRoleStatusDetached;
}

- (void)pluginUpdateMediaState:(BOOL)on type:(KKRTCMediaType)type{
    //        GJAssert(0, "media false");
    NSLog(@"pluginUpdateMediaState:%d, type:%ld",on,(long)type);
    //        GJLOG(GNULL, GJ_LOGDEBUG, "pluginUpdateMediaState:%d, type:%ld",on,(long)type);
}

#pragma mark webrtc delegate

/** Called when the SignalingState changed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeSignalingState:(RTCSignalingState)stateChanged{
    
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
          didAddStream:(RTCMediaStream *)stream {
    RTCLog(@"Stream was add.");
    
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       didRemoveStream:(RTCMediaStream *)stream {
    RTCLog(@"Stream was removed.");
    
}

/** Called when negotiation is needed, for example ICE has restarted. */
- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection{
   // assert(0);
    
}

/** Called any time the IceConnectionState changes. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceConnectionState:(RTCIceConnectionState)newState{
}

/** Called any time the IceGatheringState changes. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceGatheringState:(RTCIceGatheringState)newState{
    if (newState == RTCIceGatheringStateComplete ) {
        NSDictionary* publish = @{ @"completed":@YES};
        
        [self sendTrickleCandidate:publish];
    }
}

/** New ice candidate has been found. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didGenerateIceCandidate:(RTCIceCandidate *)candidate{
    //    NSDictionary* jsep = @{@"type":@(sdp.type),@"sdp":sdp.sdp};
    NSDictionary* publish ;
    if (candidate) {
        publish = @{ @"candidate":candidate.sdp, @"sdpMid":candidate.sdpMid, @"sdpMLineIndex": @(candidate.sdpMLineIndex)};
    }else{
        publish = @{ @"completed":@YES};
        
    }
    [self sendTrickleCandidate:publish];
}

/** Called when a group of local Ice candidates have been removed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates{
    
}

/** New data channel has been opened. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didOpenDataChannel:(RTCDataChannel *)dataChannel{
    
}

@end

