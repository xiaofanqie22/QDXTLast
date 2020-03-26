//
//  GJJanusVideoRoom.m
//  GJJanusDemo
//
//  Created by melot on 2018/3/14.
//

#import "GJJanusVideoRoom.h"
#import "Tools.h"
#import "GJJanusListenRole.h"
#import "GJJanusPublishRole.h"
#import <WebRTC/RTCSessionDescription.h>
#import <WebRTC/WebRTC.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCCameraPreviewView.h>
#import <WebRTC/RTCLogging.h>
#import <UIKit/UIView.h>
#import "KKRTCDefine+private.h"
#import "KKRTCVideoCapturer.h"
//#import "GJLog.h"
typedef enum VideoRoomMessageId{
    kVideoRoomJoin = 10 ,
}VideoRoomMessageId;

//#define GOOGLE_ICE @"stun:stun.l.google.com:19302"



static NSString* vidoeRoomMessage[] = {
    @"join",
};


@implementation GJJanusView
+(Class)layerClass{
    return [RTCCameraPreviewView class];
}
@end



@interface GJJanusVideoRoom()<GJJanusDelegate,GJJanusRoleDelegate,GJJanusListenRoleDelegate>
{
    NSInteger _userID;
    NSString* _userName;
    
    NSString* _myID;
    NSString* _myPvtId;
    
    
    //    KKRTCVideoCapturer* _hideCamera;
    NSRecursiveLock*    _lock;//
    
}
@property(nonatomic,strong)NSMutableDictionary<NSNumber*,GJJanusListenRole*>* remotes;
@property(nonatomic,strong,readonly)GJJanus* janus;
@property(nonatomic,assign)NSInteger roomID;
@property(nonatomic, assign) NSInteger screenPublishId;


@end

static GJJanusVideoRoom* _shareJanusInstance;
@implementation GJJanusVideoRoom

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (_shareJanusInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareJanusInstance = [super allocWithZone:zone];
        });
    }
    return _shareJanusInstance;
}
+(instancetype)shareInstanceWithServer:(NSURL*)server delegate:(id<GJJanusVideoRoomDelegate>)delegate{
    // if (_shareJanusInstance == nil) {
    _shareJanusInstance = [[GJJanusVideoRoom alloc]initWithServer:server delegate:delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userNeedReContactLietenAudio) name:@"userNeedReContactLietenAudio" object:nil];
    //    }else{
    //        if (_shareJanusInstance.delegate != delegate){
    //        _shareJanusInstance.delegate = delegate;
    //        }
    //        if (![_shareJanusInstance.janus.server.absoluteString isEqualToString:server.absoluteString]) {
    //            [_shareJanusInstance updateJanusWithServer:server];
    //        }
    //    }
    return _shareJanusInstance;
}

-(instancetype)initWithServer:(NSURL *)server delegate:(id<GJJanusVideoRoomDelegate>)delegate{
    if (self = [super init]) {
        _delegate = delegate;
        _janus = [[GJJanus alloc]initWithServer:server delegate:self];
        _remotes = [NSMutableDictionary dictionaryWithCapacity:1];
        _canvas = [NSMutableDictionary dictionaryWithCapacity:2];
        _publlisher = [[GJJanusPublishRole alloc]initWithJanus:_janus delegate:self];
        _cameraPosition = AVCaptureDevicePositionFront;
        _lock = [[NSRecursiveLock alloc]init];
        RTCSetMinDebugLogLevel(RTCLoggingSeverityInfo);
    }
    return self;
}

- (void)userReConnectSocket{
    [_janus reConnectSocket];
}

- (void)userUserBackCamera:(BOOL)isBackCamera{
    if (isBackCamera == YES) {
        self.cameraPosition = AVCaptureDevicePositionBack;
    }else{
        self.cameraPosition = AVCaptureDevicePositionFront;
    }
}

- (void)usermuteAudio:(BOOL)muteAudio  block:(CompleteCallback)callback{
    [self.publlisher usermuteAudio:muteAudio block:^(NSError *error) {
        if (!error) {
            callback(YES,nil);
        }else{
            callback(NO,error);
        }
    }];
    
}

- (void)userRecontactNetWoruWithAudio{
    [self.publlisher userResetrtcAudioTrack];
}

- (void)usermuteVideo:(BOOL)muteVideo  block:(CompleteCallback)callback{
    [self.publlisher usermuteVideo:muteVideo block:^(NSError *error) {
        if (!error) {
            callback(YES,nil);
        }else{
            callback(NO,error);
        }
    }];
}

- (void)userStartReceiveVideoStream:(NSInteger )publisherID{
    AUTO_LOCK(_lock)
    for (GJJanusListenRole *listener in self.videoListenerArray) {
        if (listener.ID == publisherID) {
            [self startListenRemote:listener];
            break;
        }
    }
}

- (void)userEndReceivceVideoStream:(NSInteger )publisherID{
    AUTO_LOCK(_lock)
    for (GJJanusListenRole *listener in self.videoListenerArray) {
        if (listener.ID == publisherID) {
            [listener.peerConnection close];
            listener.peerConnection = nil;
            break;
        }
    }
}


-(void)setPreviewMirror:(BOOL)previewMirror{
    _previewMirror = previewMirror;
    [_publlisher.renderView setInputRotation:previewMirror?kGPUImageFlipHorizonal:kGPUImageNoRotation atIndex:0];
}

-(void)setStreamMirror:(BOOL)streamMirror{
    _streamMirror = streamMirror;
    _publlisher.localCamera.streamMirror = streamMirror;
}

-(void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition{
    _cameraPosition = cameraPosition;
    _publlisher.localCamera.cameraPosition = cameraPosition;
}

-(void)updateJanusWithServer:(NSURL*)server{
    if (![_janus.server.absoluteString isEqualToString:server.absoluteString]) {
        [_janus destorySession];
        _janus = [[GJJanus alloc]initWithServer:server delegate:self];
    }
}

- (void)createRoomWithRoomId:(NSInteger )roomId block:(CompleteCallback)callback{
    AUTO_LOCK(_lock)
    WK_SELF;
    [_publlisher createRoomWithRoomId:roomId blcok:^(NSError *error) {
        if (error == nil) {
            [wkSelf.delegate GJJanusVideoRoom:wkSelf createRoomWithID:roomId];
        }
    }];
}


- (void)userSendMessage:(NSString  *)message isToAll:(BOOL)isToAll block:(CompleteCallback)callback;{
    [_publlisher userSendMessage:message isToAll:isToAll block:^(NSError *error) {
        if (!error) {
            callback(YES,nil);
        }else{
            callback(NO,error);
        }
    }];
}

-(void)joinRoomWithRoomID:(NSInteger)roomID userId:(NSInteger)userId userName:(NSString*)userName completeCallback:(CompleteMyCallback)callback{
    AUTO_LOCK(_lock)
    _roomID = roomID;
    _userName = userName;
    
    WK_SELF;
    [_publlisher joinRoomWithRoomID:roomID userId:userId userName:userName block:^(NSError *error, long myId) {
        if (callback) {
            callback(error == nil,error, myId);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [wkSelf.delegate GJJanusVideoRoom:wkSelf didJoinRoomWithID:wkSelf.publlisher.ID];
            });
        }
    }];
}




-(void)leaveRoom:(void(^_Nullable )(void))leaveBlock{
    AUTO_LOCK(_lock)
    WK_SELF;
    for (GJJanusListenRole* listenRole  in _remotes.allValues) {
        [listenRole leaveRoom:nil];
    }
    [_remotes removeAllObjects];
    [_publlisher leaveRoom:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (leaveBlock) {
                leaveBlock();
            }else{
                [wkSelf.delegate GJJanusVideoRoomDidLeaveRoom:wkSelf];
            }
        });
        
    }];
    
    [_janus disconnectSocket];
}

- (BOOL)startStickerWithImages:(NSArray<GJOverlayAttribute*>* _Nonnull)images fps:(NSInteger)fps updateBlock:(OverlaysUpdate _Nullable )updateBlock{
    
    return [_publlisher.localCamera startStickerWithImages:images fps:fps updateBlock:updateBlock];
}

- (void)chanceSticker{
    [_publlisher.localCamera chanceSticker];
}

-(void)setOutOrientation:(UIInterfaceOrientation)outOrientation{
    _publlisher.localCamera.outputOrientation = outOrientation;
}
-(UIInterfaceOrientation)outOrientation{
    return _publlisher.localCamera.outputOrientation;
}

-(void)setLocalConfig:(GJJanusPushlishMediaConstraints *)localConfig{
    AUTO_LOCK(_lock)
    
    [_publlisher setMediaConstraints:localConfig];
    
}

-(GJJanusPushlishMediaConstraints *)localConfig{
    AUTO_LOCK(_lock)
    return _publlisher.mediaConstraints;
}


- (BOOL)startMyPrewViewWithCanvas:(KKRTCCanvas*)canvas{
    _publlisher.renderView.frame = canvas.view.bounds;
    _publlisher.renderView.frame = canvas.view.bounds;
    canvas.renderView = _publlisher.renderView;
    switch (canvas.renderMode) {
        case KKRTC_Render_Hidden:
            canvas.renderView.contentMode = UIViewContentModeScaleAspectFill;
            break;
        case KKRTC_Render_Fit:
            canvas.renderView.contentMode = UIViewContentModeScaleAspectFit;
        case KKRTC_Render_Fill:
            canvas.renderView.contentMode = UIViewContentModeScaleToFill;
        default:
            break;
    }
    [canvas.view addSubview:self.publlisher.renderView];
    _canvas[@(canvas.uid)] = canvas;
    return YES;
}

-(BOOL)startPrewViewWithCanvas:(KKRTCCanvas*)canvas{
    AUTO_LOCK(_lock)
    if (canvas.uid == 0 || canvas.uid == _publlisher.ID) {
        // [_publlisher startPreview];
        _publlisher.renderView.frame = canvas.view.bounds;
        _publlisher.renderView.frame = canvas.view.bounds;
        canvas.renderView = _publlisher.renderView;
        switch (canvas.renderMode) {
            case KKRTC_Render_Hidden:
                canvas.renderView.contentMode = UIViewContentModeScaleAspectFill;
                break;
            case KKRTC_Render_Fit:
                canvas.renderView.contentMode = UIViewContentModeScaleAspectFit;
            case KKRTC_Render_Fill:
                canvas.renderView.contentMode = UIViewContentModeScaleToFill;
            default:
                break;
        }
        [canvas.view addSubview:self.publlisher.renderView];
    }else{
        runAsyncInMainDispatch(^{
            GJJanusListenRole* role = self->_remotes[@(canvas.uid)];
            [role.renderView removeFromSuperview];
            role.renderView.frame = canvas.view.bounds;
            [canvas.view addSubview:role.renderView];
            canvas.renderView = role.renderView;
        });
    }
    _canvas[@(canvas.uid)] = canvas;
    return YES;
}

-(KKRTCCanvas*)stopPrewViewWithUid:(NSUInteger)uid{
    AUTO_LOCK(_lock)
    //    NSLog(@"%lu",(unsigned long)uid);
    KKRTCCanvas* canvas = _canvas[@(uid)];
    if (uid == 0 || uid == _publlisher.ID) {
        //[_publlisher stopPreview];
    }else{
        GJJanusListenRole* role = _remotes[@(canvas.uid)];
      //  [canvas.view removeObserver:self forKeyPath:@"frame"];
        role.renderView = nil;
        [_canvas removeObjectForKey:@(uid)];
    }
    return canvas;
}

- (void)startListenRemote:(GJJanusListenRole*)remoteRole{
    AUTO_LOCK(_lock)
    NSLog(@"%s", remoteRole.description.UTF8String);
    _remotes[@(remoteRole.ID)] = remoteRole;
    WK_SELF;
    [remoteRole joinRoomWithRoomID:wkSelf.roomID userId:0 userName:nil block:^(NSError *error, long myId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wkSelf.delegate GJJanusVideoRoom:wkSelf newRemoteJoinWithID:remoteRole.ID];
        });
    }];
}


- (void)startListenAudioRemote:(GJJanusListenRole*)remoteRole{
    AUTO_LOCK(_lock)
    NSLog(@"%s", remoteRole.description.UTF8String);
    _remotes[@(remoteRole.ID)] = remoteRole;
    WK_SELF;
    [remoteRole joinRoomWithRoomID:wkSelf.roomID userId:0 userName:nil block:^(NSError *error, long myId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wkSelf.delegate GJJanusVideoRoom:wkSelf newRemoteAudioJoinWithID:remoteRole.ID];
        });
    }];
}

- (void)startVideoListenRemote:(GJJanusListenRole*)remoteRole{
    AUTO_LOCK(_lock)
    NSLog(@"%s", remoteRole.description.UTF8String);
    _remotes[@(remoteRole.ID)] = remoteRole;
    remoteRole.mediaType = @"video";
    WK_SELF;
    [remoteRole joinRoomWithRoomID:wkSelf.roomID userId:0 userName:nil block:^(NSError *error, long myId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wkSelf.delegate GJJanusVideoRoom:wkSelf newRemoteJoinWithID:remoteRole.ID];
        });
    }];
}


-(void)stopListernRemote:(GJJanusListenRole*)remoteRole{
    AUTO_LOCK(_lock)
    NSLog(@"%s", remoteRole.description.UTF8String);
    [_remotes removeObjectForKey:@(remoteRole.ID)];
}


-(BOOL)prepareVideoEffectWithBaseData:(NSString *)baseDataPath{
    return [_publlisher.localCamera prepareVideoEffectWithBaseData:baseDataPath];
}
-(void)chanceVideoEffect{
    [_publlisher.localCamera chanceVideoEffect];
}

-(BOOL)updateFaceStickerWithTemplatePath:(NSString *)path{
    return [_publlisher.localCamera updateFaceStickerWithTemplatePath:path];
}

-(void)setSkinRuddy:(NSInteger)skinRuddy{
    _publlisher.localCamera.skinRuddy = skinRuddy;
}
-(NSInteger)skinRuddy{
    return _publlisher.localCamera.skinRuddy;
}

-(void)setSkinSoften:(NSInteger)skinSoften{
    _publlisher.localCamera.skinSoften = skinSoften;
}
-(NSInteger)skinSoften{
    return _publlisher.localCamera.skinSoften;
}

-(void)setSkinBright:(NSInteger)skinBright{
    _publlisher.localCamera.skinBright = skinBright;
}
-(NSInteger)skinBright{
    return _publlisher.localCamera.skinBright;
}

-(void)setEyeEnlargement:(NSInteger)eyeEnlargement{
    _publlisher.localCamera.eyeEnlargement = eyeEnlargement;
}
-(NSInteger)eyeEnlargement{
    return _publlisher.localCamera.eyeEnlargement;
}

-(void)setFaceSlender:(NSInteger)faceSlender{
    _publlisher.localCamera.faceSlender = faceSlender;
}
-(NSInteger)faceSlender{
    return _publlisher.localCamera.faceSlender;
}

#pragma mark delegate

-(void)janus:(GJJanus *)janus createComplete:(NSError *)error{
    AUTO_LOCK(_lock)
    NSLog(@"success8888");
     WK_SELF;
    // NSAssert(error == nil, error.description);
    if (error == nil) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",error);
            
            // GJLOG(GNULL, GJ_LOGERROR, "attachToJanus error:%s",error.description.UTF8String);
            [wkSelf.delegate GJJanusVideoRoom:wkSelf fatalErrorWithID:KKRTCError_Server_Error];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            //            GJLOG(GNULL, GJ_LOGERROR, "createComplete error:%s",error.description.UTF8String);
            [wkSelf.delegate GJJanusVideoRoom:self fatalErrorWithID:KKRTCError_Server_Error];
        });
    }
}

-(void)janusDestory:(GJJanus*)janus{
    NSLog(@"%s", janus.description.UTF8String);
}

-(void)GJJanusRole:(GJJanusRole *)role joinRoomWithResult:(NSError *)error{
    AUTO_LOCK(_lock)
     WK_SELF;
   // NSAssert(error == nil, error.description);
    if (role.ID == _publlisher.ID) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wkSelf.delegate GJJanusVideoRoom:self didJoinRoomWithID:role.ID];
        });
    }else{
        assert(0);
    }
}

-(void)GJJanusRole:(GJJanusRole*)role leaveRoomWithResult:(NSError*)error{
    AUTO_LOCK(_lock)
   // NSAssert(error == nil, error.description);
    if (role.ID == _publlisher.ID) {
        [self.janus destorySession];
    }
}

-(void)GJJanusRole:(GJJanusRole *)role saveVideoListenRole:(GJJanusListenRole *)remoteRole{
    BOOL iscontain = NO;
    for (GJJanusListenRole *listener in self.videoListenerArray) {
        if (listener.ID == remoteRole.ID) {
            iscontain = YES;
            break;
        }
    }
    if (iscontain == NO) {
        if (remoteRole.ID%100 == 3) {
            self.screenPublishId = remoteRole.ID;
        }
        [self.videoListenerArray addObject:remoteRole];
        if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusVideoRoom:addVideoListenerID:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                  [self.delegate GJJanusVideoRoom:self addVideoListenerID:remoteRole.ID];
            });
          
        }
    }
    
}

- (void)userNeedReContactLietenAudio{
    GJJanusListenRole *listen = [[GJJanusListenRole alloc] init];
}

- (void)GJJanusRole:(GJJanusRole *)role didJoinRemoteRole:(GJJanusListenRole *)remoteRole {
    AUTO_LOCK(_lock)
    NSLog(@"%s", remoteRole.description.UTF8String);
    
    if (self.publishers == nil) {
        self.publishers = [NSMutableArray new];
    }
    BOOL isFlag = false;
      for (GJJanusListenRole *rolenew in self.publishers) {
          if (rolenew.ID == role.ID) {
              isFlag = true;
              break;
          }
      }
      if (!isFlag) {
          /**
          GJJanusListenRole *role1 = [GJJanusListenRole new];
          role1.ID = remoteRole.ID;
          role1.display = remoteRole.display;
          role1.privateIDNew = remoteRole.privateIDNew;
          role1.privateID = remoteRole.privateID;
          role1.userId = remoteRole.userId;
          role1.userName = remoteRole.userName;
          role1.roomID = remoteRole.roomID;
          role1.pType = remoteRole.pType;
          role1.mediaType = remoteRole.mediaType;
          role1.videoCode = remoteRole.videoCode;
          role1.audioCode = remoteRole.audioCode;
           */
          [self.publishers addObject:remoteRole];
      }
    
    [self startListenRemote:remoteRole];
}

- (void)GJJanusRole:(GJJanusRole *)role didJoinRemoteAudioRole:(GJJanusListenRole *)remoteRole {
    AUTO_LOCK(_lock)
    NSLog(@"%s", remoteRole.description.UTF8String);
    
    if (self.publishers == nil) {
        self.publishers = [NSMutableArray new];
    }
    BOOL isFlag = false;
    for (GJJanusListenRole *rolenew in self.publishers) {
        if (rolenew.ID == role.ID) {
            isFlag = true;
            break;
        }
    }
    if (!isFlag) {
        /**
        GJJanusListenRole *role1 = [GJJanusListenRole new];
        role1.ID = remoteRole.ID;
        role1.display = remoteRole.display;
        role1.privateIDNew = remoteRole.privateIDNew;
        role1.privateID = remoteRole.privateID;
        role1.userId = remoteRole.userId;
        role1.userName = remoteRole.userName;
        role1.roomID = remoteRole.roomID;
        role1.pType = remoteRole.pType;
        role1.mediaType = remoteRole.mediaType;
        role1.videoCode = remoteRole.videoCode;
        role1.audioCode = remoteRole.audioCode;
         */
        [self.publishers addObject:remoteRole];
    }
    [self startListenAudioRemote:remoteRole];
}



-(void)GJJanusRole:(GJJanusRole *)role remoteUnPublishedWithUid:(NSUInteger)uid{
    for (GJJanusListenRole *listener in self.videoListenerArray) {
        if (listener.ID == uid) {
            [self.videoListenerArray removeObject:listener];
            if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusVideoRoom:removeVideoListenerID:)]) {
                [self.delegate GJJanusVideoRoom:self removeVideoListenerID:listener.ID];
            }
            break;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusVideoRoom:UserChangeVideoEnable:andClient:)]) {
        [self.delegate GJJanusVideoRoom:self UserChangeVideoEnable:NO andClient:uid];
    }
    
}

- (void)GJJanusRole:(GJJanusRole*)role AdminCloseUnPublishedWithMessageData:(NSDictionary *)dic{
    for (GJJanusListenRole *listener in self.videoListenerArray) {
        if (listener.ID == self.screenPublishId) {
            [self.videoListenerArray removeObject:listener];
            if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusVideoRoom:removeVideoListenerID:)]) {
                [self.delegate GJJanusVideoRoom:self removeVideoListenerID:listener.ID];
            }
            break;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusVideoRoom:UserChangeVideoEnable:andClient:)]) {
        [self.delegate GJJanusVideoRoom:self UserChangeVideoEnable:NO andClient:self.screenPublishId];
    }
}

-(void)GJJanusRole:(GJJanusRole *)role endMeeting:(BOOL)end{
    if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusVideoRoom:endMeeting:)]) {
        [self.delegate GJJanusVideoRoom:self  endMeeting:YES];
    }
}

-(void)GJJanusRole:(GJJanusRole *)role UserChangeVideoEnable:(BOOL)isEnable andID:(NSUInteger)clientID{
    if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusVideoRoom:UserChangeVideoEnable:andClient:)]) {
        [self.delegate GJJanusVideoRoom:self UserChangeVideoEnable:isEnable andClient:clientID];
    }
}

-(void)GJJanusRole:(GJJanusRole *)role allmuteAudio:(BOOL)end{
    if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusVideoRoom:allmuteAudio:)]) {
        [self.delegate GJJanusVideoRoom:self allmuteAudio:YES];
    }
}

- (void)GJJanusRole:(GJJanusRole *)role userGetMessageData:(NSDictionary *)dic{
    if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusVideoRoom:userReceiveMessageData:)]) {
        [self.delegate GJJanusVideoRoom:self userReceiveMessageData:dic];
    }
}


- (void)GJJanusRole:(GJJanusRole *)role didLeaveRemoteRoleWithUid:(NSUInteger)uid{
    AUTO_LOCK(_lock)
    NSLog(@"%lu",(unsigned long)uid);
     WK_SELF;
    if (self.delegate && [self.delegate respondsToSelector:@selector(GJJanusVideoRoom:leavingRoom:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wkSelf.delegate GJJanusVideoRoom:self leavingRoom:uid];
        });
    }
    GJJanusListenRole* leaveRole = _remotes[@(uid)]?_remotes[@(uid)]:_remotes[@(uid/100)];
    if (leaveRole) {
        NSInteger clientID = _remotes[@(uid)]?uid:uid/100;
        [_remotes removeObjectForKey:@(clientID)];
        [leaveRole detachWithCallback:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wkSelf.delegate GJJanusVideoRoom:self remoteLeaveWithID:clientID];
        });
    }
}

-(void)GJJanusRole:(GJJanusRole *)role remoteDetachWithUid:(NSUInteger)uid{
    AUTO_LOCK(_lock)
    NSLog(@"%lu",(unsigned long)uid);
     WK_SELF;
    GJJanusListenRole* leaveRole = _remotes[@(uid)];
    if (leaveRole) {
        [_remotes removeObjectForKey:@(uid)];
        [role detachWithCallback:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wkSelf.delegate GJJanusVideoRoom:self remoteLeaveWithID:uid];
        });
    }
}

-(void)janusListenRole:(GJJanusListenRole *)role firstRenderWithSize:(CGSize)size{
    runAsyncInMainDispatch(^{
        if ([self.delegate respondsToSelector:@selector(GJJanusVideoRoom:firstFrameDecodeWithSize:uid:)]) {
            [self.delegate GJJanusVideoRoom:self firstFrameDecodeWithSize:size uid:role.ID];
        }
    });
}

-(void)janusListenRole:(GJJanusListenRole *)role renderSizeChangeWithSize:(CGSize)size{
    runAsyncInMainDispatch(^{
        if ([self.delegate respondsToSelector:@selector(GJJanusVideoRoom:renderSizeChangeWithSize:uid:)]) {
            [self.delegate GJJanusVideoRoom:self renderSizeChangeWithSize:size uid:role.ID];
        }
    });
}

-(void)janus:(GJJanus *)janus netBrokenWithID:(KKRTCNetBrokenReason)reason{
    [self leaveRoom:nil];
    runAsyncInMainDispatch(^{
        [self.delegate GJJanusVideoRoom:self netBrokenWithID:reason];
    });
}

//-(void)updateRenderViewFrame:(KKRTCCanvas*)canvas{
//    canvas.renderView.frame = canvas.view.bounds;
//}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
//    if ([keyPath isEqualToString:@"frame"]) {
//        KKRTCCanvas* canvas = (__bridge KKRTCCanvas *)(context);
//        [self updateRenderViewFrame:canvas];
//    }
//}
-(void)dealloc{
    [self.janus destorySession];
}

-(NSMutableArray *)videoListenerArray{
    if (!_videoListenerArray) {
        _videoListenerArray = [NSMutableArray array];
    }
    return _videoListenerArray;
}

@end

