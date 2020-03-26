//
//  GJJanusPlugin.h
//  GJJanusDemo
//
//  Created by melot on 2018/3/14.
//

#import <Foundation/Foundation.h>
#import "GJJanus.h"

@class GJJanusPlugin;
@protocol GJJanusPluginDelegate<NSObject>
@end

@interface Jesp:NSObject

@end
typedef void(^AttchResult)(NSError* error);
typedef void(^DetachedResult)(void);

typedef NS_ENUM(NSInteger, GJJanusHandleType) {
    GJJanusMessageHandleType = 0,
    GJJanusAudioHandleType = 1,
    GJJanusVideoHandleType = 2,
    GJJanusScreenHandleType = 3,
};


@interface GJJanusPlugin : NSObject<GJJanusPluginHandleProtocol>
@property(nonatomic,copy)NSString* opaqueId;
@property(nonatomic,copy)NSString* pluginName;

#pragma mark seession分离
@property(nonatomic,retain)NSNumber* handleId;
@property(nonatomic,retain)NSNumber* audioHandleId;
@property(nonatomic,retain)NSNumber* videoHandleId;
@property (nonatomic, retain) NSNumber *screenHandleId;

@property(nonatomic,weak)id<GJJanusPluginDelegate> delegate;
@property(nonatomic,strong,readonly)GJJanus* janus;
@property(nonatomic,retain)NSMutableDictionary* transactions;
@property(nonatomic,assign)BOOL attached;


-(instancetype)initWithJanus:(GJJanus*)janus delegate:(id<GJJanusPluginDelegate>)delegate;
-(BOOL)attachWithHandleType:(GJJanusHandleType)type Callback:(AttchResult)resultCallback;
-(void)detachWithCallback:(DetachedResult)resultCallback;

-(void)sendMessage:(NSDictionary*)msg Type:(GJJanusHandleType)type callback:(PluginRequestCallback)resultCallback;
-(void)sendMessage:(NSDictionary*)msg jsep:(NSDictionary*)jsep  Type:(GJJanusHandleType)type callback:(PluginRequestCallback)callback;
-(void)sendTrickleCandidate:(NSDictionary*)candidate;
@end
