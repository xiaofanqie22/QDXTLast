//
//  GJJanusPlugin.m
//  GJJanusDemo
//
//  Created by melot on 2018/3/14.
//

#import "GJJanusPlugin.h"
#import "Tools.h"
@interface GJJanusPlugin()
{
}
@end
@implementation GJJanusPlugin

- (instancetype)initWithJanus:(GJJanus*)janus delegate:(id<GJJanusPluginDelegate>) delegate{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _transactions = [NSMutableDictionary dictionaryWithCapacity:5];
        _janus = janus;
    }
    return self;
}


-(void)sendMessage:(NSDictionary*)msg jsep:(NSDictionary*)jsep Type:(GJJanusHandleType)type callback:(PluginRequestCallback)callback{
    NSNumber *handleId ;
    if(type == GJJanusMessageHandleType){
        handleId = self.handleId;
    }else if (type == GJJanusAudioHandleType){
        handleId = self.audioHandleId;
    }else if (type == GJJanusVideoHandleType){
        handleId = self.videoHandleId;
    }else{
        handleId = self.screenHandleId;
    }
    
    [self.janus sendMessage:msg jsep:jsep handleId:handleId callback:callback];
}

-(void)sendMessage:(NSDictionary*)msg Type:(GJJanusHandleType)type callback:(PluginRequestCallback)callback{
    return [self sendMessage:msg jsep:nil Type:type  callback:callback];
}

-(void)sendTrickleCandidate:(NSDictionary*)candidate{
    [self.janus sendTrickleCandidate:candidate handleId:self.handleId];
}

-(BOOL)attachWithHandleType:(GJJanusHandleType)type  Callback:(AttchResult)resultCallback{
    WK_SELF;
    [_janus attachPlugin:self callback:^(NSNumber *handleID, NSError *error) {
        if (type == GJJanusMessageHandleType) {
            wkSelf.handleId = handleID;
        }else if (type == GJJanusAudioHandleType){
            wkSelf.audioHandleId = handleID;
        }else if (type == GJJanusVideoHandleType){
            wkSelf.videoHandleId = handleID;
        }else {
            wkSelf.screenHandleId = handleID;
            
        }
        // NSLog(@"初始化%@",handleID);
        wkSelf.attached = (error == nil);
        resultCallback(error);
    }];
    return YES;
}

-(void)detachWithCallback:(DetachedResult)resultCallback{
    WK_SELF;
    [_janus detachPlugin:self callback:^(void) {
        wkSelf.attached = NO;//attached要在回调里面修改
        if (resultCallback) {
            resultCallback();
        }
    }];
}

-(void)pluginDetached{
    _attached = NO;
}

- (void)pluginHandleMessage:(NSDictionary *)msg jsep:(NSDictionary *)jsep transaction:(NSString *)transaction {
    assert(0);
}

- (void)pluginMediaState:(BOOL)on type:(NSString *)media {
    
}

- (void)pluginWebrtcState:(BOOL)on {
    
}

- (void)pluginDTLSHangupWithReson:(NSString *)reason {
    
}


- (void)pluginUpdateMediaState:(BOOL)on type:(KKRTCMediaType)media {
    
}


- (void)pluginHangup{
    
}
@end
