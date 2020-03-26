//
//  ios_sdk.h
//  ios-sdk
//
//  Created by wyh on 2019/10/10.
//  Copyright © 2019 uni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebRTC/WebRTC.h>
//! Project version number for ios_sdk.
FOUNDATION_EXPORT double ios_sdkVersionNumber;

//! Project version string for ios_sdk.
FOUNDATION_EXPORT const unsigned char ios_sdkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ios_sdk/PublicHeader.h>

@interface ios_sdk : NSObject
- (void)initialize;
- (void)unInitialize;
- (void)joinMeeting:(int)meetingNum displayName:(NSString*_Nullable)displayName callback:(nullable void (^)(NSDictionary* _Nullable result,NSString* _Nullable error))callback;
- (void)openAudio;
- (void)closeAudio:(void(^_Nullable)(NSString* _Nullable result))callback;
- (void)openVideo:(void(^)(RTCVideoTrack* localVideoTrack))callback;
- (void)closeVideo:(void(^_Nullable)(NSString* _Nullable result))callback;
- (void)sendMessage:(NSString*_Nullable)data to:(NSString*_Nullable) to callback:(void(^_Nullable)(NSString* _Nullable result))callback;
- (void)handUp:(void(^_Nullable)(NSString* _Nullable result))callback;
- (void)handDown:(void(^_Nullable)(NSString* _Nullable result))callback;
- (void)leaveMeeting:(void(^_Nullable)(NSString* _Nullable result))callback;
- (void)mutaAll:(void(^_Nullable)(NSString* _Nullable result))callback;
- (void)unMutaAll:(void(^_Nullable)(NSString* _Nullable result))callback;
- (void)endMeeting:(void(^)(NSString* result))callback;
- (void)setHost:(NSNumber*_Nullable)id callback:(void(^_Nullable)(NSString* _Nullable result))callback;
- (void)setEventCallback:(void(^_Nullable)(NSString* _Nullable even_type,NSNumber* _Nullable id,NSString* _Nullable type,NSString* _Nullable display))callback;
- (void)setReceiveChatMsg:(void(^_Nullable)(NSNumber* _Nullable fromId,NSString* data,NSString* to))callback;
- (void)setReceiveRemoteStream:(void(^)(RTCMediaStream* stream,NSNumber* id,NSString* mediatype))callback;
@end





