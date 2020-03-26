//
//  GJJanusRole.h
//  GJJanus
//
//  Created by melot on 2018/4/3.
//  Copyright © 2018年 MirrorUncle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "GJJanusPlugin.h"
#import "GJJanusMediaConstraints.h"
#import "Tools.h"


@class GJJanusRole;
@class GJJanusListenRole;
@protocol GJJanusRoleDelegate<GJJanusPluginDelegate>
- (void)GJJanusRole:(GJJanusRole*)role joinRoomWithResult:(NSError*)error;
- (void)GJJanusRole:(GJJanusRole*)role leaveRoomWithResult:(NSError*)error;
- (void)GJJanusRole:(GJJanusRole*)role UserChangeVideoEnable:(BOOL)isEnable  andID:(NSUInteger )clientID;
- (void)GJJanusRole:(GJJanusRole*)role didJoinRemoteRole:(GJJanusListenRole*)remoteRole;
- (void)GJJanusRole:(GJJanusRole*)role didJoinRemoteAudioRole:(GJJanusListenRole*)remoteRole;
- (void)GJJanusRole:(GJJanusRole*)role didLeaveRemoteRoleWithUid:(NSUInteger)uid;
- (void)GJJanusRole:(GJJanusRole*)role remoteUnPublishedWithUid:(NSUInteger)uid;
- (void)GJJanusRole:(GJJanusRole*)role AdminCloseUnPublishedWithMessageData:(NSDictionary *)dic;
- (void)GJJanusRole:(GJJanusRole*)role remoteDetachWithUid:(NSUInteger)uid;
- (void)GJJanusRole:(GJJanusRole*)role endMeeting:(BOOL)end;
- (void)GJJanusRole:(GJJanusRole*)role saveVideoListenRole:(GJJanusListenRole *)remoteRole;
- (void)GJJanusRole:(GJJanusRole*)role allmuteAudio:(BOOL)end;
- (void)GJJanusRole:(GJJanusRole*)role userGetMessageData:(NSDictionary *)dic;
@end

typedef enum _PublishType{
    kPublishTypeLister,
    kPublishTypePublish,
}PublishType;

typedef enum {
    kJanusRoleStatusDetached,
    kJanusRoleStatusDetaching,
    kJanusRoleStatusAttaching,
    kJanusRoleStatusAttached,
    kJanusRoleStatusJoining,
    kJanusRoleStatusJoined,
    kJanusRoleStatusLeaveing,
    kJanusRoleStatusLeaved,
}GJJanusRoleStatus;


typedef void(^RoleJoinRoomCallback)(NSError* error);
typedef void(^RoleJoinMyRoomCallback)(NSError* error, long myId);

typedef void(^RoleCreateRoomCallback)(NSError* error);
typedef void(^RoleLeaveRoomCallback)(void);

@interface GJJanusRole:GJJanusPlugin <RTCPeerConnectionDelegate>
@property(nonatomic,assign)NSUInteger ID;
@property(nonatomic,assign)NSInteger roomID;
@property(nonatomic,assign)NSInteger privateID;
@property(nonatomic,assign)NSInteger privateIDNew;
@property(nonatomic,copy) NSString *mediaType;
@property(nonatomic,assign)NSUInteger userId;
@property(nonatomic,copy) NSString *userName;

@property(nonatomic,strong)GJJanusMediaConstraints* mediaConstraints;
@property(nonatomic,weak)id<GJJanusRoleDelegate> delegate;

@property(nonatomic,copy)NSString* display;
@property(nonatomic,assign)PublishType pType;
@property(nonatomic,assign)GJJanusRoleStatus status;

@property(nonatomic,copy)NSString* audioCode;
@property(nonatomic,copy)NSString* videoCode;

@property(nonatomic,strong)RTCPeerConnection* peerConnection;


+(instancetype)roleWithDic:(NSDictionary*)dic janus:(GJJanus*)janus delegate:(id<GJJanusRoleDelegate>)delegate;
//-(instancetype)initWithDelegate:(id<GJJanusRoleDelegate>)delegate;

- (void)createRoomWithRoomId:(NSInteger )roomID blcok:(RoleCreateRoomCallback)blcok;
-(void)joinRoomWithRoomID:(NSInteger)roomID userId:(NSInteger)userId userName:(NSString*)userName block:(RoleJoinMyRoomCallback)block;
-(void)leaveRoom:(RoleLeaveRoomCallback)leaveBlock;


- (void)remoteReConnect;
-(void)handleRemoteJesp:(NSDictionary*)jsep;
-(void)prepareLocalJesp:(NSDictionary*)jsep;
@end


