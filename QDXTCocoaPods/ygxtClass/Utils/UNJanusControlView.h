//
//  UNJanusControlView.h
//  UniudcOA
//
//  Created by hu on 2019/3/14.
//  Copyright © 2019 shanshan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UNJanusControlView;
#import "EdgeInsetLabel.h"
#import <FLAnimatedImage.h>
#import <FLAnimatedImageView.h>
NS_ASSUME_NONNULL_BEGIN

@protocol UNJanusControlViewDelegate <NSObject>

- (void)unjanusControlView:(UNJanusControlView *)janusControlView didClose:(BOOL)isClosed;
- (void)unjanusControlView:(UNJanusControlView *)janusControlView didSetSilent:(BOOL)isSilent;
- (void)unjanusControlView:(UNJanusControlView *)janusControlView didOpenSpeaker:(BOOL)isOpen;
- (void)unjanusControlView:(UNJanusControlView *)janusControlView didOpenCamera:(BOOL)isOpen;
- (void)unjanusControlView:(UNJanusControlView *)janusControlView didPickUp:(BOOL)isPickUp;
- (void)unjanusControlView:(UNJanusControlView *)janusControlView didCameraBack:(BOOL)isBack;
- (void)unjanusControlView:(UNJanusControlView *)janusControlView openShareScreen:(BOOL)isBack;
- (void)unjanusControlViewDidAddRole:(UNJanusControlView *)janusControlView;
- (void)unjanusControlViewShowSendMessageView:(UNJanusControlView *)janusControlView;

@end

@interface UNJanusControlView : UIView

@property (nonatomic, strong) UIButton *silenceButton;
@property (nonatomic, strong) UILabel *silenceLabel;
@property (nonatomic, strong) UIButton *speakerButton;
@property (nonatomic, strong) UILabel *speakerLabel;
@property (nonatomic, strong) UILabel *cameraLabel;
@property (nonatomic, strong) UILabel *changeCamereLabel;
@property (nonatomic, strong) UILabel *nickNameLab;
@property (nonatomic, strong) UIButton *messageBtn;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *pickupButton;
@property (nonatomic, strong) UIButton *changeCamereButton;
@property (nonatomic, strong) UIButton *addRoleButton;
@property (nonatomic, strong) UIImageView *lightImageV;
@property (nonatomic, strong) UIButton *screenBtn;
@property (nonatomic, strong) UIImageView *userIconImageV;
@property (nonatomic, strong) FLAnimatedImageView *voiceImageV;
@property (nonatomic, strong) EdgeInsetLabel *alterLab;
@property (nonatomic, weak) id <UNJanusControlViewDelegate> delegate;
@property (nonatomic, assign) BOOL isSilent;
@property (nonatomic, assign) BOOL isOpenSpeaker;
@property (nonatomic, assign) BOOL isOpenCamera;
@property (nonatomic, strong) UIView *redPoint;

- (void)updateSilenceState:(BOOL)isSilent;
- (void)updateSpeakerState:(BOOL)isOpen;
- (void)updateCameraState:(BOOL)isOpen;

@end

NS_ASSUME_NONNULL_END
