//
//  UNJanusControlView.m
//  UniudcOA
//
//  Created by hu on 2019/3/14.
//  Copyright © 2019 shanshan. All rights reserved.
//

#import "UNJanusControlView.h"
#import <Masonry.h>
#import "UNPublicDefine.h"
#import "Utils.h"
@implementation UNJanusControlView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.lightImageV];
        [self addSubview:self.screenBtn];
        [self addSubview:self.userIconImageV];
        [self addSubview:self.voiceImageV];
        [self addSubview:self.alterLab];
        [self addSubview:self.pickupButton];
        [self addSubview:self.addRoleButton];
        [self addSubview:self.silenceButton];
        [self addSubview:self.speakerButton];
        [self addSubview:self.cameraButton];
        [self addSubview:self.closeButton];
        [self addSubview:self.changeCamereButton];
        [self addSubview:self.nickNameLab];
        [self addSubview:self.messageBtn];
        [self.messageBtn addSubview:self.redPoint];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self).offset(-120 - Screen_Width/4);
                make.centerX.equalTo(self);
                make.size.mas_offset(CGSizeMake(100, 40));
            }];
    
    NSArray *array = @[ self.speakerButton,self.silenceButton, self.cameraButton];
   // NSArray *array = @[self.silenceButton, self.speakerButton];
    [array mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:(Screen_Width - 180) / 4 leadSpacing:(Screen_Width - 180) / 4 tailSpacing:(Screen_Width - 180) / 4];
    [array mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.closeButton.mas_bottom).offset(20);
    }];
    
    [self.lightImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.silenceButton);
        make.width.height.offset(84);
    }];
    

//    [self.speakerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.speakerButton.mas_bottom).offset(10);
//        make.centerX.equalTo(self.speakerButton);
//        make.height.offset(14);
//        make.width.offset(70);
//    }];
//
//
//    [self.silenceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.speakerLabel);
//        make.centerX.equalTo(self.silenceButton);
//        make.height.offset(14);
//        make.width.offset(70);
//    }];
//
//    [self.cameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.speakerLabel);
//        make.centerX.equalTo(self.cameraButton);
//        make.height.offset(14);
//        make.width.offset(75);
//    }];
    
//    [self.changeCamereLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.speakerLabel);
//        make.centerX.equalTo(self.changeCamereButton);
//        make.height.offset(14);
//        make.width.offset(75);
//    }];
    
    [self.addRoleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.top.equalTo(self).offset(kStatusBarHeight+15);
        make.width.height.offset(30);
    }];
    
    [self.messageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.addRoleButton);
        make.right.mas_equalTo(self.addRoleButton.mas_left).offset(-25);
        make.width.height.offset(30);
    }];
    
    [self.redPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageBtn).offset(0);
        make.right.equalTo(self.messageBtn).offset(0);
        make.width.height.offset(10);
    }];
    
    [self.nickNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.addRoleButton);
        make.centerX.equalTo(self);
        
    }];
    
    [self.screenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.width.offset(98);
        make.height.offset(35);
        make.top.equalTo(self.addRoleButton.mas_bottom).offset(40);
    }];
    
    [self.userIconImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.height.offset(Screen_Width/4);
        make.top.equalTo(self.screenBtn.mas_bottom).offset(40);
    }];
    
    [self.voiceImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.offset(Screen_Width/3);
        make.height.offset(40);
        make.top.mas_equalTo(self.userIconImageV.mas_bottom).offset(20);
    }];
    
    [self.alterLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.height.offset(30);
        make.width.offset([Utils widthForLabelHeight:20 withText:self.alterLab.text font:[UIFont systemFontOfSize:13]] + 40);
        make.bottom.mas_equalTo(self.closeButton.mas_top).offset(-60);
    }];
}

#pragma mark -

- (void)setIsSilent:(BOOL)isSilent {
    _isSilent = isSilent;
    
    [self updateSilenceState:_isSilent];
}

- (void)setIsOpenSpeaker:(BOOL)isOpenSpeaker {
    _isOpenSpeaker = isOpenSpeaker;
    
    [self updateSpeakerState:_isOpenSpeaker];
}

- (void)setIsOpenCamera:(BOOL)isOpenCamera {
    _isOpenCamera = isOpenCamera;
    
    [self updateCameraState:_isOpenCamera];
}

#pragma mark -

- (void)pickupButtonAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(unjanusControlView:didPickUp:)]) {
        [_delegate unjanusControlView:self didPickUp:YES];
    }
}

- (void)addRoleButtonAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(unjanusControlViewDidAddRole:)]) {
        [_delegate unjanusControlViewDidAddRole:self];
    }
}

- (void)silenceButtonAction:(UIButton *)sender
{
    
    if (_delegate && [_delegate respondsToSelector:@selector(unjanusControlView:didSetSilent:)]) {
        [_delegate unjanusControlView:self didSetSilent:self.silenceButton.selected];
    }
}

- (void)speakerButtonAction:(UIButton *)sender
{
   
    
    if (_delegate && [_delegate respondsToSelector:@selector(unjanusControlView:didOpenSpeaker:)]) {
        [_delegate unjanusControlView:self didOpenSpeaker:self.isOpenSpeaker];
    }
}

- (void)cameraButtonAction:(UIButton *)sender
{
  
    if (_delegate && [_delegate respondsToSelector:@selector(unjanusControlView:didOpenCamera:)]) {
        self.cameraButton.userInteractionEnabled = NO;
        [_delegate unjanusControlView:self didOpenCamera:self.cameraButton.selected];
    }
}

- (void)closeButtonAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(unjanusControlView:didClose:)]) {
        [_delegate unjanusControlView:self didClose:YES];
    }
}

- (void)changeCameraButtonAction:(UIButton *)sender
{
    self.changeCamereButton.selected =!self.changeCamereButton.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(unjanusControlView:didCameraBack:)]) {
        [_delegate unjanusControlView:self didCameraBack: self.changeCamereButton.selected];
    }
}

- (void)userLookScreen:(UIButton *)sender{
    if(self.delegate && [_delegate respondsToSelector:@selector(unjanusControlView:openShareScreen:)]){
        [_delegate unjanusControlView:self openShareScreen:YES];
    }
}

- (void)showMessageView:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(unjanusControlViewShowSendMessageView:)]) {
        [self.delegate unjanusControlViewShowSendMessageView:self];
    }
}

- (void)updateSilenceState:(BOOL)isSilent
{
    if (isSilent) {
        self.silenceLabel.text = @"静音";
    } else {
        self.silenceLabel.text = @"取消静音";
    }
}

- (void)updateSpeakerState:(BOOL)isOpen
{
    if (isOpen) {
        self.speakerLabel.text = @"关闭免提";
    } else {
        self.speakerLabel.text = @"打开免提";
    }
}

- (void)updateCameraState:(BOOL)isOpen
{
    if (isOpen) {
        self.cameraLabel.text = @"关闭摄像头";
    } else {
        self.cameraLabel.text = @"打开摄像头";
    }
}

#pragma mark -

- (UIButton *)pickupButton {
    if (!_pickupButton) {
        _pickupButton = [[UIButton alloc] init];
        [_pickupButton setImage:[UIImage imageNamed:@"video_up"] forState:UIControlStateNormal];
        [_pickupButton addTarget:self action:@selector(pickupButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pickupButton;
}

- (UIButton *)addRoleButton {
    if (!_addRoleButton) {
        _addRoleButton = [[UIButton alloc] init];
        [_addRoleButton setImage:[UIImage imageNamed:@"webrtc_addrole"] forState:UIControlStateNormal];
        [_addRoleButton addTarget:self action:@selector(addRoleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addRoleButton;
}

- (UIButton *)silenceButton {
    if (!_silenceButton) {
        _silenceButton = [[UIButton alloc] init];
        [_silenceButton setImage:[UIImage imageNamed:@"wetrtc_silence"] forState:UIControlStateNormal];
        [_silenceButton setImage:[UIImage imageNamed:@"wetrtc_nosilence"] forState:UIControlStateSelected];
        [_silenceButton addTarget:self action:@selector(silenceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _silenceButton;
}

- (UIButton *)speakerButton {
    if (!_speakerButton) {
        _speakerButton = [[UIButton alloc] init];
        [_speakerButton setImage:[UIImage imageNamed:@"video_speaker"] forState:UIControlStateNormal];
         [_speakerButton setImage:[UIImage imageNamed:@"video_nospeaker"] forState:UIControlStateSelected];
        [_speakerButton addTarget:self action:@selector(speakerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speakerButton;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [[UIButton alloc] init];
        [_cameraButton setImage:[UIImage imageNamed:@"webrtc_camera"] forState:UIControlStateNormal];
        [_cameraButton setImage:[UIImage imageNamed:@"webrtc_nocamera"] forState:UIControlStateSelected];
        [_cameraButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)changeCamereButton {
    if (!_changeCamereButton) {
        _changeCamereButton = [[UIButton alloc] init];
        [_changeCamereButton setImage:[UIImage imageNamed:@"camera_back"] forState:UIControlStateNormal];
        [_changeCamereButton setImage:[UIImage imageNamed:@"camera_front"] forState:UIControlStateSelected];
        [_changeCamereButton addTarget:self action:@selector(changeCameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeCamereButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"videoCall_off"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)silenceLabel {
    if (!_silenceLabel) {
        _silenceLabel = [[UILabel alloc] init];
        _silenceLabel.textColor = [UIColor whiteColor];
        _silenceLabel.textAlignment = NSTextAlignmentCenter;
        _silenceLabel.font = [UIFont systemFontOfSize:14];
        _silenceLabel.text = @"取消静音";
    }
    return _silenceLabel;
}

- (UILabel *)speakerLabel {
    if (!_speakerLabel) {
        _speakerLabel = [[UILabel alloc] init];
        _speakerLabel.textColor = [UIColor whiteColor];
        _speakerLabel.textAlignment = NSTextAlignmentCenter;
        _speakerLabel.font = [UIFont systemFontOfSize:14];
        _speakerLabel.text = @"打开免提";
    }
    return _speakerLabel;
}

- (UILabel *)cameraLabel {
    if (!_cameraLabel) {
        _cameraLabel = [[UILabel alloc] init];
        _cameraLabel.textColor = [UIColor whiteColor];
        _cameraLabel.textAlignment = NSTextAlignmentCenter;
        _cameraLabel.font = [UIFont systemFontOfSize:14];
        _cameraLabel.text = @"打开摄像头";
      //  _cameraLabel.hidden = YES;
    }
    return _cameraLabel;
}

-(UIButton *)screenBtn{
    if (!_screenBtn) {
        _screenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_screenBtn setImage:[UIImage imageNamed:@"screenLogo"] forState:UIControlStateNormal];
        [_screenBtn addTarget:self action:@selector(userLookScreen:) forControlEvents:UIControlEventTouchUpInside];
        _screenBtn.hidden = YES;
    }
    return _screenBtn;
}

-(UIImageView *)userIconImageV{
    if (!_userIconImageV) {
        _userIconImageV = [[UIImageView alloc] init];
        extern NSString *BASEURL;
//        [_userIconImageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASEURL, [UNLoginController sharedInstance].selfInfoModel.headImg]] placeholderImage:[UIImage imageNamed:@"默认男头像"] options:SDWebImageRefreshCached completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//            
//        }];
        
//        [_userIconImageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASEURL, [UNLoginController sharedInstance].selfInfoModel.headImg]] placeholderImage:[UIImage imageNamed:@"默认男头像"]];
        _userIconImageV.layer.masksToBounds = YES;
        _userIconImageV.layer.cornerRadius = Screen_Width/8;
        
    }
    return _userIconImageV;
}

- (UIImageView *)lightImageV{
    if (!_lightImageV) {
        _lightImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_light"]];
    }
    return _lightImageV;
}

-(FLAnimatedImageView *)voiceImageV{
    if (!_voiceImageV) {
        _voiceImageV = [[FLAnimatedImageView alloc] init];
        NSString *filepath = [[NSBundle bundleWithPath:[[NSBundle mainBundle] bundlePath]] pathForResource:@"videovoice.gif" ofType:nil];
        NSData *imagedata = [NSData dataWithContentsOfFile:filepath];
        FLAnimatedImage *image=  [FLAnimatedImage animatedImageWithGIFData:imagedata];
        _voiceImageV.animatedImage= image;
        _voiceImageV.hidden = YES;
    }
    return _voiceImageV;
}

- (EdgeInsetLabel *)alterLab{
    if (!_alterLab) {
        _alterLab = [[EdgeInsetLabel alloc] init];
        _alterLab.textInsets = UIEdgeInsetsMake(0, 20, 0, 20);
        _alterLab.text = @"您还未开启语音";
        [_alterLab sizeToFit];
        _alterLab.font = [UIFont systemFontOfSize:13];
        _alterLab.backgroundColor = [UIColor blackColor];
        _alterLab.textColor = RGBAColor(153, 153, 153, 1);
        _alterLab.layer.masksToBounds = YES;
        _alterLab.layer.cornerRadius = 8;
    }
    return _alterLab;
}

- (UILabel *)changeCamereLabel {
    if (!_changeCamereLabel) {
        _changeCamereLabel = [[UILabel alloc] init];
        _changeCamereLabel.textColor = [UIColor whiteColor];
        _changeCamereLabel.textAlignment = NSTextAlignmentCenter;
        _changeCamereLabel.font = [UIFont systemFontOfSize:14];
        _changeCamereLabel.text = @"切换摄像头";
    }
    return _changeCamereLabel;
}

-(UILabel *)nickNameLab{
    if (!_nickNameLab ) {
        _nickNameLab = [[UILabel alloc] init];
        _nickNameLab.font = [UIFont systemFontOfSize:18];
        _nickNameLab.textColor = [UIColor whiteColor];
       
    }
    return _nickNameLab;
}


-(UIButton *)messageBtn{
    if (!_messageBtn) {
        _messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_messageBtn setImage:[UIImage imageNamed:@"video_message"] forState:UIControlStateNormal];
        [_messageBtn addTarget:self action:@selector(showMessageView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageBtn;
}

-(UIView *)redPoint{
    if (!_redPoint) {
        _redPoint = [[UIView alloc] init];
        _redPoint.layer.cornerRadius = 5;
        _redPoint.layer.masksToBounds = YES;
        _redPoint.backgroundColor = RGBAColor(251, 15, 48, 1);
        _redPoint.hidden = YES;
    }
    return _redPoint;
}
@end
