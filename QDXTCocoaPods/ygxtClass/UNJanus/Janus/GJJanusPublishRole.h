//
//  GJJanusPublishRole.h
//  GJJanus
//
//  Created by melot on 2018/4/3.
//  Copyright © 2018年 MirrorUncle. All rights reserved.
//

#import "GJJanusRole.h"
#import "GJJanusMediaConstraints.h"
#import <WebRTC/RTCCameraPreviewView.h>
#import "KKRTCVideoCapturer.h"


@class GJImageView;
typedef void (^RoleSendOfferSuccessCallBack)(void);
typedef void(^RoleMuteVideoCallback)(NSError* error);
typedef void(^RoleMuteAudioallback)(NSError* error);
typedef void (^RoleSendMessageCallBack)(NSError* error);
@interface GJJanusPublishRole : GJJanusRole
@property(nonatomic,strong)GJJanusPushlishMediaConstraints* mediaConstraints;
@property(nonatomic,retain)GJImageView* renderView;
@property(nonatomic,readonly)KKRTCVideoCapturer* localCamera;
@property(nonatomic,strong)RTCAudioSource* audioSource;
@property(nonatomic,strong)RTCVideoSource* videoSource;

- (void)userResetrtcAudioTrack;

@property (nonatomic, assign)GJJanusHandleType handleType;

- (void)usermuteAudio:(BOOL)muteAudio  block:(RoleMuteAudioallback)callback;
- (void)usermuteVideo:(BOOL)muteVideo  block:(RoleMuteVideoCallback)callback;
- (void)userSendMessage:(NSString  *)message isToAll:(BOOL)isToAll block:(RoleSendMessageCallBack)callback;
-(void)startPreview;
-(void)stopPreview;
//- (RTCRtpSender *)createAudioSender;
@end
