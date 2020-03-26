//
//  VideoCallViewController.m
//  GJJanusDemo
//
//  Created by melot on 2018/3/20.
//  Copyright © 2018年 MirrorUncle. All rights reserved.
//

#import "VideoCallViewController.h"
#import "GJJanusVideoRoom.h"
#import "UNJanusControlView.h"
#import "PersonVideoView.h"
#import "VideoCallMemberTableView.h"
#import "VideoMessageView.h"
#import "MBProgressHUD.h"
#import "UNPublicDefine.h"
#import <Masonry.h>
#import "Utils.h"
//监听电话
#import <CallKit/CXCallObserver.h>
#import <CallKit/CXCall.h>
//#import "ZipArchive.h"

//#define ROOM_ID 19911024
#define ROOM_ID 1234

//#error 请自行搭建janus服务器。https://janus.conf.meetecho.com/index.html
//#define SERVER_ADDR @"ws://10.0.2.68:8188" //8188端口为ws使用。杭州服务器地址
//#define SERVER_ADDR @"http://172.19.17.117:8080"
//#define SERVER_ADDR @"https://58.144.150.173:8081"
//#define SERVER_ADDR @"https://58.144.150.249:8081"
//#define SERVER_ADDR @"https://58.144.150.173:8081"
#define SERVER_ADDR @"ws://58.144.150.212:8188"
@interface GJSliderView:UISlider{
    UILabel * _titleLab;
    UILabel * _valueLab;
    
}
@property(nonatomic,copy)NSString* title;
@end
@implementation GJSliderView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLab = [[UILabel alloc]init];
        [_titleLab setFont:[UIFont systemFontOfSize:15]];
        [_titleLab setTextColor:[UIColor whiteColor]];
        [_titleLab setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_titleLab];
        _valueLab = [[UILabel alloc]init];
        [_valueLab setFont:[UIFont systemFontOfSize:12]];
        [_valueLab setTextAlignment:NSTextAlignmentCenter];
        [_valueLab setTextColor:[UIColor whiteColor]];
        self.value = 0;
        [self addSubview:_valueLab];
        
    }
    return self;
}

-(void)setValue:(float)value{
    [super setValue:value];
    _valueLab.text = [NSString stringWithFormat:@"%0.2f",value];
}

-(void)setValue:(float)value animated:(BOOL)animated{
    [super setValue:value animated:animated];
    _valueLab.text = [NSString stringWithFormat:@"%0.2f",value];
}
#define xRate 0.3
#define yRate 0.5

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGRect rect = frame;
    rect.origin = CGPointZero;
    rect.size.width = frame.size.width * xRate;
    _titleLab.frame = rect;
    
    rect.origin.x = CGRectGetMaxX(rect);
    rect.size.width = frame.size.width*(1-xRate);
    rect.size.height = frame.size.height * yRate;
    _valueLab.frame = rect;
}

-(void)setTitle:(NSString *)title{
    [_titleLab setText:title];
}

-(NSString *)title{
    return _titleLab.text;
}

-(CGRect)trackRectForBounds:(CGRect)bounds{
    CGRect rect = bounds;
    rect.size.height = 3;
    rect.size.width = bounds.size.width * (1-xRate);
    rect.origin.x = bounds.size.width - rect.size.width;
    rect.origin.y = (bounds.size.height - rect.size.height)* yRate;
    return rect;
};

@end

@interface VideoCallViewController ()<GJJanusVideoRoomDelegate, UNJanusControlViewDelegate,personVideoViewDelegate,VideoMemberDelegate,UITextFieldDelegate,CXCallObserverDelegate>{
    UIScrollView* _controlView;
    
    UIButton* _startBtn;
    UIButton* _switchCameraBtn;
    UIButton* _streamMirrorBtn;
    UIButton* _previewMirrorBtn;
    UIButton* _startStickerBtn;
    UIButton* _sizeChange;
    NSMutableArray<UIView*>* _controlBtns;
    NSArray<NSString*>* _stickerPath;
    NSDictionary* _pushSize;
    UIButton* _faceStickerBtn;
    UIButton* _videoOrientationBtn;
    
    
    GJSliderView* _brigntSlider;
    GJSliderView* _rubbySlider;
    GJSliderView* _softenSlider;
    GJSliderView* _slenderSlider;
    GJSliderView* _enlargementSlider;
    
    dispatch_source_t _timer;
    
    dispatch_source_t _netTimer;
    
}

typedef NS_ENUM(NSInteger, AudioPlayType) {
    HeadPhoneType = 0,
    HeadsetType =1,
    BluetoothHeadsetType = 2,
    SpeakerType = 3,
    
};

@property(retain,nonatomic)GJJanusVideoRoom* videoRoom;

@property(retain,nonatomic)UIButton* exitBtn;

@property(retain,nonatomic)UIView* localView;

@property(retain,nonatomic)NSMutableDictionary<NSNumber*,KKRTCCanvas*>* remotes;

@property (nonatomic, strong) UIScrollView *videoScollerV;

@property (nonatomic, strong)NSMutableArray *joinRoomPersonArray;

@property (nonatomic, strong)NSMutableArray *joinRoomTagArray;

@property (nonatomic, strong) UNJanusControlView *janusControlView;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *voiceStateButton;

@property (nonatomic, strong) UIButton *leftBtn;

@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, assign) NSInteger currentPlayId;

@property (nonatomic, strong) UIView *fullScreenView;

@property (nonatomic, strong) UIButton *outFullBtn;

@property (nonatomic, strong) UIButton *VideoFullBtn;

@property (nonatomic,strong) PersonVideoView *currentPersonView;

@property (nonatomic,strong) PersonVideoView *minePersonView;

@property (nonatomic, strong) UIButton *voiceBtn;

@property (nonatomic, strong) UIButton *cameraBtn;

@property (nonatomic, strong) UIButton *speakerBtn;

@property (nonatomic, strong) UIView *fullControlView;

@property (nonatomic, strong) UIView *fullControlHead;

@property (nonatomic, strong) UILabel *screenHeadLab;

@property (nonatomic, strong) UIButton *memberBtn;

@property (nonatomic, strong) VideoCallMemberTableView *memberTableView;

@property (nonatomic, strong) NSDictionary *selfDic;

@property (nonatomic, assign) NSInteger  nowNetWorkStatus; // 1 网络  2无网络

@property (nonatomic, assign) BOOL isAutoContact;

@property (nonatomic, assign) NSInteger cacheId;

@property (nonatomic, assign) BOOL isOpenSpeak;

@property (nonatomic, strong) VideoMessageView *messageView;

@property (nonatomic, strong) CXCallObserver *callObserver;

@property (nonatomic, assign) AudioPlayType audioType;

@property (nonatomic, assign) AudioPlayType lastAudioType;

@end

@implementation VideoCallViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // KKRTCCanvas 和声网sdk一样也是用这个东西来实现视频的展示 同样的里面有uiview来用
    
    [self connectWebSocket];
    // [self userMonitorNetWork];
    //    NSString* path = [[NSBundle mainBundle]pathForResource:@"track_data" ofType:@"dat"];
    //    [_videoRoom prepareVideoEffectWithBaseData:path];
    
    [self buildUI];
    //  [self updateFrame];
      [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSetMeetingRoomView:) name:@"VideoRoomPerson" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userListeNetWorkStatus) name:UNLISTENNETWORK object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userReContactNetWork) name:UNRECONTACTETWORK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAutoDismissSelf) name:@"userAutoDismissSelf" object:nil];
   // [(AppDelegate*)[UIApplication sharedApplication].delegate networkReachability];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(audioRouteChangeListenerCallback:)
     name:AVAudioSessionRouteChangeNotification
     object:[AVAudioSession sharedInstance]];
    self.callObserver = [CXCallObserver new];
    [self.callObserver setDelegate:self queue:dispatch_get_main_queue()];
    
}



#pragma  mark - 音频播放声道选择
- (void)userCheckAudioPlay{
    if ([self isBleToothOutput]) {
        if (self.audioType == BluetoothHeadsetType) {
            return;
        }
        self.audioType = BluetoothHeadsetType;
    }else if ([self hasHeadset]) {
        if (self.audioType == HeadsetType) {
            return;
        }
        self.audioType = HeadsetType;
    }else{
        if (self.isOpenSpeak == YES) {
            if (self.audioType == SpeakerType) {
                return;
            }
            self.audioType = SpeakerType;
        }else{
            if (self.audioType == HeadPhoneType) {
                return;
            }
           self.audioType = HeadPhoneType;
        }
       
    }
    
    [self userSetPlayAudioType:self.audioType];
}

- (void)userSetPlayAudioType:(AudioPlayType )type{
        if (type == HeadPhoneType || type == HeadsetType ) {
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        }else if (type == BluetoothHeadsetType){
            AVAudioSessionPortDescription* bluetoothPort = [self bluetoothAudioDevice];
            [[AVAudioSession sharedInstance] setPreferredInput:bluetoothPort error:nil];
        }else{
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        }
    
   
}



-(void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call{
    
    
}

- (void)userAutoDismissSelf{
    
    if ([Utils hasMissNetworkReachability]) {
        [self closeButtonAction];
    }else{
        [_videoRoom stopPrewViewWithUid:0];
        [_videoRoom leaveRoom:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"stopListenAudioStatus" object:nil];
                [self dismissViewControllerAnimated:YES completion:^{
                    if(self->_netTimer){
                        dispatch_source_cancel(self->_netTimer);
                        self->_netTimer = nil;
                    }
                }];
            });
        });
    }
    
    
}

- (void)forceExit{
   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(forceExit) object:nil];
    [_videoRoom stopPrewViewWithUid:0];
    [_videoRoom leaveRoom:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopListenAudioStatus" object:nil];
            [self dismissViewControllerAnimated:YES completion:^{
                if(self->_netTimer){
                    dispatch_source_cancel(self->_netTimer);
                    self->_netTimer = nil;
                }
            }];
        });
    });
}

/**
 *  监听耳机插入拔出状态的改变
 *  @param notification 通知
 */
- (void)audioRouteChangeListenerCallback:(NSNotification *)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason   = [[interuptionDict
                                      valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    [self userCheckAudioPlay];
      NSLog(@"xxxx音道变化状态——————%ld",routeChangeReason);
//    switch (routeChangeReason) {
//
//        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
//            DLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
//
//
//            [self unjanusControlView:self.janusControlView didOpenSpeaker: self.isOpenSpeak];
//            //插入耳机时关闭扬声器播放
//            // [self.agoraKit setEnableSpeakerphone:NO];
//            break;
//        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
//            DLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
//            [self unjanusControlView:self.janusControlView didOpenSpeaker: self.isOpenSpeak];
//            //拔出耳机时的处理为开启扬声器播放
//            // [self.agoraKit setEnableSpeakerphone:YES];
//            break;
//        case AVAudioSessionRouteChangeReasonCategoryChange:
//            // called at start - also when other audio wants to play
//            //            [self unjanusControlView:self.janusControlView didOpenSpeaker: !self.janusControlView.isOpenSpeaker];
//            //            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
//            break;
//    }
}

-(void)stopNetTimer{
    if(_timer){
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}


- (void)connectWebSocket{
    NSArray *serviceArray = @[@"ws://58.144.150.212:8188",@"ws://58.144.150.249:8188",@"ws://58.144.150.173:8188"];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    NSString *roomIDRemoveZero = [NSString stringWithFormat:@"%ld",self.roomId];
    //self.nickNameLab.text =[NSString stringWithFormat:@"%@/%@/%ld" ,roomIDRemoveZero,self.urlAddress,self.wsPort];
    self.roomId = 1235;//[roomIDRemoveZero integerValue];
    self.urlAddress=@"119.3.0.139";
    self.wsPort=8188;
    self.userName=@"ios";
    self.userid=691;
    if (self.urlAddress && self.wsPort) {
        NSString *urlString = [NSString stringWithFormat:@"ws://%@:%ld",self.urlAddress,(long)self.wsPort];
        _videoRoom = [GJJanusVideoRoom shareInstanceWithServer:[NSURL URLWithString: urlString] delegate:self];
    }else{
        _videoRoom = [GJJanusVideoRoom shareInstanceWithServer:[NSURL URLWithString:serviceArray[self.serviceId>serviceArray.count -1?0:self.serviceId]] delegate:self];
    }
    
    
    //设置1为占位id
    self.currentPlayId = 1;
    if(_videoRoom)
        _remotes = [NSMutableDictionary dictionaryWithCapacity:2];
    _controlBtns = [NSMutableArray arrayWithCapacity:2];
    _pushSize = @{@"360*640":[NSValue valueWithCGSize:CGSizeMake(360, 640)],
                  @"720*960":[NSValue valueWithCGSize:CGSizeMake(720, 960)],
                  @"640*480":[NSValue valueWithCGSize:CGSizeMake(640, 480)],
                  };
    _stickerPath = @[@"bear",@"bd",@"hkbs",@"lb",@"null"];
    
    GJJanusPushlishMediaConstraints* localConfig = [[GJJanusPushlishMediaConstraints alloc]init];
    //    localConfig.pushSize = [_pushSize.allValues[_sizeChange.tag % _pushSize.count] CGSizeValue];
    localConfig.pushSize = CGSizeMake(240,240*(Screen_Height - Screen_Width/4)/Screen_Width);
    localConfig.fps = 20;
    localConfig.videoBitrate = 128*1000;
    localConfig.audioBitrate = 200*1000;
    localConfig.frequency = 44100;
    //        localConfig.audioEnable = NO;
    _videoRoom.localConfig = localConfig;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.janusControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.videoScollerV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.offset(Screen_Width/4);
    }];
    
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view).offset(2);
        make.height.offset(Screen_Width/4);
        make.width.offset(30);
    }];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.right.equalTo(self.view).offset(-2);
        make.height.offset(Screen_Width/4);
        make.width.offset(30);
    }];
    
}


-(void)dealloc{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
   // [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [_videoRoom chanceVideoEffect];
    [_videoRoom.videoListenerArray removeAllObjects];
    [_callObserver setDelegate:nil queue:dispatch_get_main_queue()];
    _callObserver = nil;
    
    
}
-(void)buildUI{
    _localView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height - Screen_Width/4)];
    
    self.fullControlHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Height, 45)];
    self.fullControlHead.backgroundColor = RGBAColor(35, 35, 35, 0.7);
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, 30, 44)];
    [button setImage:[UIImage imageNamed:@"faceBack"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(userOutShareScreen) forControlEvents:UIControlEventTouchUpInside];
    self.outFullBtn = button;
    
    [self.fullControlHead addSubview:self.outFullBtn];
    [self.fullControlHead addSubview:self.screenHeadLab];
    [self.fullControlHead addSubview:self.memberBtn];
    
    self.fullControlView = [[UIView  alloc] init];
    self.fullControlView.backgroundColor = [UIColor clearColor];
    
    self.fullScreenView = [[UIView  alloc] initWithFrame:CGRectMake((Screen_Width - Screen_Height)/2 , (Screen_Height - Screen_Width)/2, Screen_Height, Screen_Width)];
    [_fullScreenView addSubview:self.fullControlView];
    [_fullScreenView addSubview:self.fullControlHead];
    [_fullScreenView addSubview:self.memberTableView];
    [self.fullControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.fullScreenView);
        make.width.offset(55);
        make.right.equalTo(self.fullScreenView).offset(-15);
    }];
    [self.fullControlView addSubview:self.voiceBtn];
    [self.fullControlView addSubview:self.speakerBtn];
    [self.fullControlView addSubview:self.cameraBtn];
    NSArray *array = @[self.voiceBtn,self.speakerBtn,self.cameraBtn];
    [array mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:(Screen_Width - 165) / 4 leadSpacing:(Screen_Width - 165) / 4 tailSpacing:(Screen_Width - 165) / 4];
    
    [array mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullControlView);
        make.width.offset(55);
    }];
    
    CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI*0.5);
    _fullScreenView.transform = transform;
    _fullScreenView.frame = CGRectMake(0, kSafeTopHeight,Screen_Width,  Screen_Height - kSafeTopHeight);
    _localView.userInteractionEnabled = NO;
    _localView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_localView];
    [self.view addSubview:self.janusControlView];
    self.view.backgroundColor = RGBAColor(35, 35, 35, 1);
    [self.view addSubview:self.videoScollerV];
    [self.view addSubview:self.leftBtn];
    [self.view addSubview:self.rightBtn];
    [self.view addSubview:self.messageView];
    self.fullControlHead.hidden = YES;
    self.fullControlView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    self.messageView.closeBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view endEditing:YES];
            if (weakSelf.messageView.hidden == NO) {
                [UIView animateWithDuration:0.3 animations:^{
                    weakSelf.messageView.frame = CGRectMake(0, Screen_Height, Screen_Width, Screen_Height/2.0);
                } completion:^(BOOL finished) {
                    weakSelf.messageView.hidden = YES;
                }];
            }
        });
    };
    //  [self startVideo];
}




- (void)userSetMeetingRoomView:(NSNotification *)notic{
    NSArray *list = notic.object;
    NSMutableArray *selfDicArry = [NSMutableArray array];
    NSDictionary *selfDic = [ NSDictionary dictionary];
    NSMutableArray *newAddPersonArray = [NSMutableArray array];
    for (NSDictionary * dic in list) {
        BOOL isSaved = NO;
        for (NSDictionary *savedDic in self.joinRoomPersonArray) {
            if ([dic[@"id"] integerValue] == [savedDic[@"id"]integerValue]) {
                isSaved = YES;
            }else{
                [savedDic setValue:dic[@"mutevideo"] forKey:@"mutevideo"] ;
            }
            
        }
        if (isSaved == NO){
            //if (isSaved == NO && [dic[@"id"] integerValue] != [self.selfDic[@"id"]integerValue]) {
            [newAddPersonArray addObject:dic];
        }
    }
    NSInteger userid = self.videoRoom.publlisher.ID;
    [self.joinRoomPersonArray addObjectsFromArray:newAddPersonArray];
    for (NSDictionary *dic in self.joinRoomPersonArray) {
        if ([dic[@"id"] integerValue] == userid) {
             [selfDicArry addObject:dic];

        }
       
    }
    
    if (selfDicArry.count > 1 && self.isAutoContact == YES) {
        for (NSDictionary *dic in selfDicArry) {
            if ([dic[@"id"] integerValue] == [self.selfDic[@"id"] integerValue]) {
                [selfDicArry removeObject:dic];
                [self.joinRoomPersonArray removeObject:dic];
                break;
            }
        }
    }
    
    selfDic = selfDicArry[0];
    if ([selfDic allKeys].count > 0) {
        [self.joinRoomPersonArray removeObject:selfDic];
        [self.joinRoomPersonArray insertObject:selfDic atIndex:0];
    }
    
    if(self.joinRoomPersonArray.count > 1){
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"meetingRoomMoreThanOne"];
        [[NSUserDefaults standardUserDefaults] synchronize];
      //  [[NSNotificationCenter defaultCenter] postNotificationName:@"meetingMemberMoreThanOneStartListenAudio" object:nil];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"meetingRoomMoreThanOne"];
         [[NSUserDefaults standardUserDefaults] synchronize];
      // [[NSNotificationCenter defaultCenter] postNotificationName:@"meetingMemberLessThanTneStartListenAudio" object:nil];
    }
    
    [self setViewRoomPersonView];
}



- (void)setViewRoomPersonView{
    __weak  typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.memberTableView.dataSourceArray = self.joinRoomPersonArray;
        NSInteger userid = self.videoRoom.publlisher.ID;
        for (int i = 0 ; i< weakSelf.joinRoomPersonArray.count; i++)
        {
            if(![weakSelf.joinRoomTagArray containsObject:[NSString stringWithFormat:@"%ld",[weakSelf.joinRoomPersonArray[i][@"id"]integerValue]]]){
                PersonVideoView *view = [[PersonVideoView alloc] initWithFrame:CGRectMake(Screen_Width/4 *i, 0, Screen_Width/4, Screen_Width/4)];
                
                view.delegate = self;
                view.tag = [weakSelf.joinRoomPersonArray[i][@"id"] integerValue];
                view.nickName.text = weakSelf.joinRoomPersonArray[i][@"display"];
                view.iconUrl = weakSelf.joinRoomPersonArray[i][@"imgurl"];
//                [view.iconImageV sd_setImageWithURL:[NSURL URLWithString:view.iconUrl] placeholderImage:[UIImage imageNamed:@"默认男头像"] options:SDWebImageRefreshCached completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//
//                }];
               
                [weakSelf.joinRoomTagArray addObject: [NSString stringWithFormat:@"%ld",[weakSelf.joinRoomPersonArray[i][@"id"]integerValue]]];
                [weakSelf.videoScollerV addSubview:view];
                if ([weakSelf.joinRoomPersonArray[i][@"id"] integerValue]==userid)
                {
                    view.VideoId = 0;
                    self.minePersonView = view;
                    [self userControlFirstNoVideoWidgetShow];
                }
                if (!self.currentPersonView &&self.isAutoContact == NO ) {
                    self.currentPersonView =self.minePersonView;
                }else if (self.currentPersonView &&self.isAutoContact == YES  ){
                    if (self.currentPersonView.tag == view.tag) {
                        self.currentPersonView = view;
                    }
                }else if (self.currentPersonView && (self.cacheId == view.tag )){
                    self.currentPersonView.isCurrentSelect = NO;
                    self.currentPersonView = view;

                }
            }
            
        }
//        if (!self.currentPersonView ) {
//            self.currentPlayId = 1;
//            if (self.minePersonView) {
//                self.currentPersonView = self.minePersonView;
//            }else{
//                for (PersonVideoView *view in self.videoScollerV.subviews) {
//                    if (view.frame.origin.x == 0 && [view isKindOfClass:[PersonVideoView class]]) {
//                        view.VideoId = 0;
//                        self.minePersonView = view;
//                        self.currentPersonView = self.minePersonView;
//
//                    }
//                }
//
//            }
//            [self userControlFirstNoVideoWidgetShow];
//
//        }
        //self.currentPersonView.isCurrentSelect = YES;
        self.videoScollerV.contentSize = CGSizeMake(Screen_Width/4*self.joinRoomTagArray.count, 0);
        self.leftBtn.hidden = self.joinRoomTagArray.count> 4?NO:YES;
        self.rightBtn.hidden = self.joinRoomTagArray.count> 4?NO:YES;
        
    });
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)userOutShareScreen{
    [self userOutShareScreen:NO];
}

- (void)showMemberList{
    [UIView animateWithDuration:0.5 animations:^{
        self.memberTableView.frame = CGRectMake(Screen_Height - 150 - kSafeBottomHeight, 0, 150 + kSafeBottomHeight, Screen_Width);
    }];
}

#pragma mark VideoMemberDelegate
- (void)userCloseMemberList{
    [UIView animateWithDuration:0.5 animations:^{
        self.memberTableView.frame = CGRectMake(Screen_Height, 0, 150 + kSafeBottomHeight, Screen_Width);
    }];
}

- (void)userOutShareScreen:(BOOL)isDismissNetwork {
    [_videoRoom userEndReceivceVideoStream:self.currentPlayId];
    for(UIView *subView in self.fullScreenView.subviews){
        if ([subView isKindOfClass:[RTCEAGLVideoView class]]) {
            [subView removeFromSuperview];
        }else if ([subView isKindOfClass:[GJImageView class]]){
            [subView removeFromSuperview];
        }
    }
    if (isDismissNetwork != YES) {
        self.currentPlayId = 1;
        if (self.janusControlView.silenceButton.selected == YES) {
            self.janusControlView.alterLab.hidden = YES;
        }else{
            self.janusControlView.alterLab.hidden = NO;
        }
    }
    [self.fullScreenView removeFromSuperview];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)fullControlButtonClick:(UIButton *)sender{
    if (sender == self.voiceBtn) {
        [self unjanusControlView:self.janusControlView didOpenSpeaker:self.voiceBtn.selected];
    }else if (sender == self.speakerBtn){
        [self unjanusControlView:self.janusControlView didSetSilent:self.speakerBtn.selected];
    }else if (sender == self.cameraBtn){
        [self unjanusControlView:self.janusControlView didOpenCamera:self.cameraBtn.selected];
    }
}


#pragma mark personVideoViewDelegate
-(void)userChangeMeetingPersonWithVideoPublisherId:(NSInteger)VideoId screenPublisherId:(NSInteger)screenId nickName:(NSString *)nickName personView:(PersonVideoView *)personView{
    
    if(self.nowNetWorkStatus == 2){
        //[MBManager showBriefAlert:@"当前网络已失去链接,请稍后再试"];
        return;
    }
    
    self.cacheId = 0;
    self.currentPersonView.isCurrentSelect = NO;
    self.currentPersonView = personView;
    self.currentPersonView.isCurrentSelect = YES;
    [self userControlNoVideoWidgetShowHide:YES];
//    [self.janusControlView.userIconImageV sd_setImageWithURL:[NSURL URLWithString:personView.iconUrl] placeholderImage:[UIImage imageNamed:@"默认男头像"] options:SDWebImageRefreshCached completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//
//    }];
    //  [self.janusControlView.userIconImageV sd_setImageWithURL:[NSURL URLWithString:personView.iconUrl] placeholderImage:[UIImage imageNamed:@"默认男头像.png"]];
    if (personView.videoBtn.hidden == NO && personView.screenBtn.hidden == NO) {
        if (self.currentPlayId == VideoId) {
            [self userClickVideoBtnWithPublisherId:VideoId nickName:personView.nickName.text personView:personView];
            return ;
        }
        UIAlertController *alterC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *shareScreenAction = [UIAlertAction actionWithTitle:@"播放桌面共享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self userClickShareScreenBtnWithPublisherId:screenId nickName:personView.nickName.text personView:personView];
        }];
        
        UIAlertAction *videoAction = [UIAlertAction actionWithTitle:@"播放视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self userClickVideoBtnWithPublisherId:VideoId nickName:personView.nickName.text personView:personView];
        }];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [shareScreenAction setValue:RGBAColor(50, 50, 50, 1) forKey:@"_titleTextColor"];
        [videoAction setValue:RGBAColor(50, 50, 50, 1) forKey:@"_titleTextColor"];
        [alterC addAction:shareScreenAction];
        [alterC addAction:videoAction];
        [alterC addAction:cancelAction];
        
        [self presentViewController:alterC animated:YES completion:nil];
    }else if(personView.videoBtn.hidden == NO){
        [self userClickVideoBtnWithPublisherId:VideoId nickName:nickName personView:personView];
    }else if (personView.screenBtn.hidden == NO){
        [self userControlNoVideoWidgetShowHide:NO];
        
        [self userClickShareScreenBtnWithPublisherId:screenId nickName:nickName personView:personView];
    }else{
        [self userEndPlayingStreamWithID:self.currentPlayId];
        self.janusControlView.nickNameLab.text = personView.nickName.text;
        [self userControlNoVideoWidgetShowHide:NO];
    }
    
}


-(void)userClickVideoBtnWithPublisherId:(NSInteger)VideoId nickName:(NSString *)nickName personView:(PersonVideoView *)personView{
    if ([self userEndPlayingStreamWithID:VideoId]) {
        if (VideoId == 0) {
            [_videoRoom startPrewViewWithCanvas:[KKRTCCanvas canvasWithUid:0 view:self.localView renderMode:KKRTC_Render_Hidden]];
            self.currentPlayId = VideoId;
            self.janusControlView.nickNameLab.text = nickName;
            self.janusControlView.voiceImageV.hidden  = YES;
            //[self.localView bringSubviewToFront:self.nickNameLab];
            return;
        }
      //  [MBManager showLoadingWithTitle:@"正在加载视频"];
        //        self.currentPersonView = personView;
        [_videoRoom userStartReceiveVideoStream:VideoId];
        self.currentPlayId = VideoId;
        self.janusControlView.nickNameLab.text = nickName;
        self.janusControlView.voiceImageV.hidden  = YES;
        
    }else{
        //self.janusControlView.nickNameLab.text = @"";
        if(self.currentPersonView == self.minePersonView){
            if (self.janusControlView.isSilent == YES) {
                self.janusControlView.alterLab.hidden = YES;
                self.janusControlView.voiceImageV.hidden = NO;
            }else{
                self.janusControlView.alterLab.hidden = NO;
                self.janusControlView.voiceImageV.hidden = YES;
            }
        }else{
            self.janusControlView.alterLab.hidden = YES;
            self.janusControlView.voiceImageV.hidden = NO;
        }
        self.janusControlView.userIconImageV.hidden = NO;
    }
    
}

-(void)userClickShareScreenBtnWithPublisherId:(NSInteger)screenId nickName:(NSString *)nickName personView:(PersonVideoView *)personView{
    self.screenHeadLab.text = [NSString stringWithFormat:@"%@正在共享桌面",nickName];
    if(self.messageView.hidden == NO){
        [UIView animateWithDuration:0.3 animations:^{
            if(self.messageView.selectPersonView.hidden == NO){
                self.messageView.selectPersonView.alpha = 0.0;
            }
            self.messageView.frame = CGRectMake(0, Screen_Height, Screen_Width, Screen_Height/2.0);
        } completion:^(BOOL finished) {
            if(self.messageView.selectPersonView.hidden == NO){
                self.messageView.selectPersonView.hidden = YES;
                [self.messageView.typeBtn setImage:[UIImage imageNamed:@"message_jt_down"]forState:UIControlStateNormal];
                
            }
            self.messageView.hidden = YES;
        }];
    }
    if ([self userEndPlayingStreamWithID:screenId]) {
        [self stopTimer];
        [self userCreateTimer];
     //   [MBManager showLoadingWithTitle:@"正在加载桌面共享"];
        [_videoRoom userStartReceiveVideoStream:screenId];
        self.currentPlayId = screenId;
    }else{
        //self.janusControlView.nickNameLab.text = @"";
        if(self.currentPersonView == self.minePersonView){
            if (self.janusControlView.isSilent == YES) {
                self.janusControlView.alterLab.hidden = YES;
                self.janusControlView.voiceImageV.hidden = NO;
            }else{
                self.janusControlView.alterLab.hidden = NO;
                self.janusControlView.voiceImageV.hidden = YES;
            }
        }else{
            self.janusControlView.alterLab.hidden = YES;
            self.janusControlView.voiceImageV.hidden = NO;
        }
        self.janusControlView.userIconImageV.hidden = NO;
    }
}


- (BOOL)userEndPlayingStreamWithID:(NSInteger )ID{
    BOOL isdisPlay = NO;
        for(UIView *subView in self.localView.subviews){
        if ([subView isKindOfClass:[RTCEAGLVideoView class]]) {
            [subView removeFromSuperview];
            isdisPlay = YES;
        }else if ([subView isKindOfClass:[GJImageView class]]){
            [subView removeFromSuperview];
            isdisPlay = YES;
        }
        
    }
    if (isdisPlay == YES) {
        [_videoRoom userEndReceivceVideoStream:self.currentPlayId];
        //[self.currentPlayBtn setImage:[UIImage imageNamed:@"videoIcon"] forState:UIControlStateNormal];
        self.localView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Screen_Width/4);
    }
    if (self.currentPlayId == ID && self.isAutoContact != YES) {
        self.currentPlayId = 1;
        return NO;
    }
    self.currentPlayId = 1;
    return YES;
}




- (void)userControlFirstNoVideoWidgetShow{
    self.janusControlView.nickNameLab.text = self.minePersonView.nickName.text;
    self.janusControlView.userIconImageV.hidden = NO;
//    [self.janusControlView.userIconImageV sd_setImageWithURL:[NSURL URLWithString:self.minePersonView.iconUrl] placeholderImage:[UIImage imageNamed:@"默认男头像"] options:SDWebImageRefreshCached completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//
//    }];
    if (self.speakerBtn.selected  == NO) {
        self.janusControlView.alterLab.hidden = NO;
        self.janusControlView.voiceImageV.hidden = YES;
    }else{
        self.janusControlView.alterLab.hidden = YES;
        self.janusControlView.voiceImageV.hidden = NO;
    }
}

- (void)userControlNoVideoWidgetShowHide:(BOOL)hide{
    self.janusControlView.userIconImageV.hidden = hide;
    self.janusControlView.voiceImageV.hidden = hide;
    if(self.currentPersonView == self.minePersonView){
        if (self.speakerBtn.selected  == NO) {
            // self.janusControlView.alterLab.hidden = NO;
            self.janusControlView.voiceImageV.hidden = YES;
        }else{
            //  self.janusControlView.alterLab.hidden = YES;
            self.janusControlView.voiceImageV.hidden = NO;
        }
    }else{
        self.janusControlView.alterLab.hidden = self.speakerBtn.selected;
    }
}

- (void)userCreateTimer{
    self.fullControlHead.hidden = NO;
    self.fullControlView.hidden = NO;
    self.memberTableView.frame = CGRectMake(Screen_Height, 0, 150 + kSafeBottomHeight, Screen_Width);
    __block NSInteger time = 5;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, time *NSEC_PER_SEC), 1 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        //在这里执行事件
        [self stopTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fullControlHead.hidden = YES;
            self.fullControlView.hidden = YES;
        });
    });
    dispatch_resume(_timer);
}


-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin UserChangeVideoEnable:(BOOL)isEnable andClient:(NSInteger)clientId{
    for (NSNumber * keyStr in  _videoRoom.canvas.allKeys) {
        if ([keyStr integerValue]/100 == clientId  ||[keyStr integerValue] == clientId) {
            KKRTCCanvas* canvas = _videoRoom.canvas[keyStr];
            if (canvas) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *idStr = [NSString stringWithFormat:@"%@",keyStr];
                    NSString *typeId = [idStr substringWithRange:NSMakeRange(idStr.length - 2, 2)];
                    for(UIView *subView in canvas.view.subviews){
                        if ([subView isKindOfClass:[RTCEAGLVideoView class]]) {
                            [subView removeFromSuperview];
                        }
                    }
                    if ([typeId isEqualToString:@"03"]) {
                        [self.fullScreenView removeFromSuperview];
                        self.janusControlView.screenBtn.hidden = YES;
                        [UIApplication sharedApplication].statusBarHidden = NO;
                    }
                    
                    
                });
            }
        }
    }
    
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin allmuteAudio:(BOOL)end{
    if (self.janusControlView.isSilent == NO) {
        __weak typeof(self) weakSelf = self;
        [_videoRoom usermuteAudio:YES block:^(BOOL isSuccess, NSError *error) {
            if (isSuccess == YES) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.janusControlView.silenceButton.selected = NO;
                    weakSelf.speakerBtn.selected = NO;
                    [weakSelf.janusControlView updateSilenceState:NO];
                });
            }
        }];
    }
}


-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin didJoinRoomWithID:(NSUInteger )clientID{
    
}
-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin newRemoteJoinWithID:(NSUInteger )clientID{
    
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin endMeeting:(BOOL)end{
    if (end == YES) {
        [self closeButtonAction];
    }
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin userReceiveMessageData:(NSDictionary *)data{
    if (data[@"id"]) {
        NSMutableDictionary *messageDic = [NSMutableDictionary dictionary];
        for (NSDictionary *dic in self.joinRoomPersonArray) {
            if ([dic[@"id"] intValue] == [data[@"id"] intValue]) {
                [messageDic setObject:data[@"data"] forKey:@"message"];
                [messageDic setObject:dic[@"display"] forKey:@"name"];
                [messageDic setObject:dic[@"imgurl"] forKey:@"url"];
                [messageDic setObject:@"receive" forKey:@"type"];
                [self.messageView.dataArray addObject:messageDic];
                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.janusControlView.redPoint.hidden = !self.messageView.hidden;
            [self.messageView.tableView reloadData];
            [self.messageView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messageView.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        });
        
    }
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin createRoomWithID:(NSUInteger)roomId{
    __weak typeof(self) weakSelf = self;
    [_videoRoom joinRoomWithRoomID:self.roomId userId:self.userid
                          userName:self.userName completeCallback:^(BOOL isSuccess, NSError *error, long myId) {
                              if(!error){
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if (self.janusControlView.cameraButton.selected == YES) {
                                          self.minePersonView.videoBtn.hidden = NO;
                                      }
                                      if (weakSelf.isAutoContact == YES) {
                                          [self.videoRoom userRecontactNetWoruWithAudio];
                                          if (self.janusControlView.silenceButton.selected == YES) {
                                              [self unjanusControlView:self.janusControlView didSetSilent:NO];
                                          }
                                          
                                          NSString *currentPlayId = [NSString stringWithFormat:@"%ld",self.currentPlayId];
                                          if (currentPlayId.length > 1) {
                                              NSString *tagString = [currentPlayId substringWithRange:NSMakeRange(currentPlayId.length - 2, 2)];
                                              if (self.currentPersonView.tag == self.currentPlayId/100) {
                                                  if ([tagString isEqualToString:@"02"]) {
                                                      [weakSelf userClickVideoBtnWithPublisherId:weakSelf.currentPlayId nickName:weakSelf.currentPersonView.nickName.text personView:weakSelf.currentPersonView];
                                                      
                                                  }else if ([tagString isEqualToString:@"03"]) {
                                                      [weakSelf userClickShareScreenBtnWithPublisherId:weakSelf.currentPlayId nickName:weakSelf.currentPersonView.nickName.text personView:weakSelf.currentPersonView];
                                                  }
                                              }
                                          }else if(weakSelf.currentPlayId == 0){
                                              if (self.janusControlView.cameraButton.selected == YES) {
                                                  [self->_videoRoom usermuteVideo:NO block:^(BOOL isSuccess, NSError *error) {
                                                      
                                                  }];
                                                  
                                              }
                                              [self userChangeMeetingPersonWithVideoPublisherId:weakSelf.currentPersonView.VideoId screenPublisherId:self.currentPersonView.screenId  nickName:self.currentPersonView.nickName.text personView:self.currentPersonView];
                                              
                                              self.isAutoContact = NO;
                                          }else if (weakSelf.currentPlayId == 1){
                                              [self userChangeMeetingPersonWithVideoPublisherId:weakSelf.currentPersonView.VideoId screenPublisherId:self.currentPersonView.screenId  nickName:self.currentPersonView.nickName.text personView:self.currentPersonView];
                                              self.isAutoContact = NO;
                                          }
                                      }
                                  });
                              }else if (error.code == 432){
                                  [Utils showAlertWithTitle:@"提示" message:@"入会人数已达到限制值,无法进入会议" actions:@[] cancelTitle:@"确定"];
                              }
                              dispatch_async(dispatch_get_main_queue(), ^{
                                 // [MBManager hideAlert];
                              });
                              
                              
                              
                          }];
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin leavingRoom:(NSInteger)clientID{
    CGFloat removeX = 0.0;
    
    for (PersonVideoView *personView in self.videoScollerV.subviews) {
        if (personView.tag == clientID || personView.tag == clientID/100) {
            if(self.currentPersonView == personView){
                
                self.currentPersonView = self.minePersonView;
                self.currentPersonView.isCurrentSelect = YES;
                [self userChangeMeetingPersonWithVideoPublisherId:self.minePersonView.VideoId screenPublisherId:self.minePersonView.screenId nickName:self.minePersonView.nickName.text personView:self.minePersonView];
                self.cacheId = personView.tag;
            }
            removeX = personView.frame.origin.x;
            [personView removeFromSuperview];
            [self.joinRoomTagArray removeObject:[NSString stringWithFormat:@"%ld",personView.tag]];
            self.videoScollerV.contentSize = CGSizeMake(self.videoScollerV.contentSize.width - Screen_Width/4, 0);
            //  __weak typeof(self) weakSelf = self;
            for (NSDictionary *dic in self.joinRoomPersonArray) {
                if ([dic[@"id"] integerValue] == personView.tag) {
                    [self.joinRoomPersonArray removeObject:dic];
                    break;
                }
            }
        }
    }
    self.memberTableView.dataSourceArray = self.joinRoomPersonArray;
    if (removeX > 0) {
        for (PersonVideoView *personView in self.videoScollerV.subviews) {
            if (personView.frame.origin.x > removeX) {
                personView.frame = CGRectMake(personView.frame.origin.x - Screen_Width/4, 0, Screen_Width/4, Screen_Width/4 );
            }
        }
    }
    
    
    self.leftBtn.hidden = self.joinRoomTagArray.count> 4?NO:YES;
    self.rightBtn.hidden = self.joinRoomTagArray.count> 4?NO:YES;
    
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin remoteLeaveWithID:(NSUInteger )clientID{
    KKRTCCanvas* canvas = [_videoRoom stopPrewViewWithUid:clientID];
    if (canvas) {
        //  [self deleteRemoteView:canvas.view];
        [_remotes removeObjectForKey:@(clientID)];
    }
}


-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin addVideoListenerID:(NSInteger)clientID{
    for (PersonVideoView *view in self.videoScollerV.subviews) {
        if (view.tag == clientID/100) {
            NSString *idStr = [NSString stringWithFormat:@"%ld",clientID];
            NSString *typeId = [idStr substringWithRange:NSMakeRange(idStr.length - 2, 2)];
            if ([typeId isEqualToString:@"02"]) {
                view.videoBtn.hidden = NO;
                view.VideoId = clientID;
                if (self.cacheId == view.tag && self.currentPersonView == view) {
                    [self userChangeMeetingPersonWithVideoPublisherId:view.VideoId screenPublisherId:view.screenId nickName:view.nickName.text personView:view];
                }
            }else if ([typeId isEqualToString:@"03"] ){
                view.screenBtn.hidden = NO;
                view.screenId = clientID;
                self.janusControlView.screenBtn.hidden = NO;
                if (self.isAutoContact != YES) {
                    if (view.videoBtn.hidden == YES) {
                        [self userControlNoVideoWidgetShowHide:NO];
                    }
                    self.currentPersonView.isCurrentSelect = NO;
                    self.currentPersonView = view;
                    self.currentPersonView.isCurrentSelect = YES;
                    self.janusControlView.voiceImageV.hidden = NO;
//                    [self.janusControlView.userIconImageV sd_setImageWithURL:[NSURL URLWithString:view.iconUrl] placeholderImage:[UIImage imageNamed:@"默认男头像"] options:SDWebImageRefreshCached completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//
//                    }];
                    
                    //                    [self.janusControlView.userIconImageV sd_setImageWithURL:[NSURL URLWithString:view.iconUrl] placeholderImage:[UIImage imageNamed:@"默认男头像.png"]];
                    [self userClickShareScreenBtnWithPublisherId:view.screenId nickName:view.nickName.text personView:view];
                }
            }
            
            
        }
    }
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin removeVideoListenerID:(NSInteger)clientID{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (PersonVideoView *view in self.videoScollerV.subviews) {
            if (view.tag == clientID/100) {
                NSString *idStr = [NSString stringWithFormat:@"%ld",clientID];
                NSString *typeId = [idStr substringWithRange:NSMakeRange(idStr.length - 2, 2)];
                if ([typeId isEqualToString:@"02"]) {
                   // [MBManager hideAlert];
                    view.videoBtn.hidden = YES;
                    [view.videoBtn setImage:[UIImage imageNamed:@"videoIcon"] forState:UIControlStateNormal];
                    view.VideoId = 1;
                }else if ([typeId isEqualToString:@"03"]){
                 //   [MBManager hideAlert];
                    view.screenBtn.hidden = YES;
                    self.janusControlView.screenBtn.hidden = YES;
                    view.screenId = 1;
                }
            }
        }
        self.localView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Screen_Width/4);
        self.janusControlView.nickNameLab.text =@"";
        if (self.currentPlayId == clientID) {
            self.currentPlayId = 1;
        }
    });
    
}


-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin firstFrameDecodeWithSize:(CGSize)size uid:(NSUInteger)clientID{
  //  [MBManager hideAlert];
    NSString *idStr = [NSString stringWithFormat:@"%ld",clientID];
    NSString *typeId = [idStr substringWithRange:NSMakeRange(idStr.length - 2, 2)];
    float AspectRatio =  size.width/size.height;
    if (self.isAutoContact == YES) {
        self.isAutoContact = NO;
    }
    if([typeId isEqualToString:@"02"]){
        self.localView.frame = CGRectMake((Screen_Width - (Screen_Height - Screen_Width/4) *AspectRatio)/2, 0, (Screen_Height - Screen_Width/4) *AspectRatio, (Screen_Height - Screen_Width/4));
    }
    KKRTCCanvas* remote = [KKRTCCanvas canvasWithUid:clientID view:[typeId isEqualToString:@"02"]?self.localView:self.fullScreenView renderMode:KKRTC_Render_Hidden];
    if ([_videoRoom startPrewViewWithCanvas:remote]) {
        // [self.localView bringSubviewToFront:self.nickNameLab];
        if ([typeId isEqualToString:@"03"]) {
            [UIApplication sharedApplication].statusBarHidden = YES;
            [self.view addSubview:self.fullScreenView];
            
            [self.fullScreenView bringSubviewToFront:self.fullControlView];
            [self.fullScreenView bringSubviewToFront:self.fullControlHead];
            [self.fullScreenView bringSubviewToFront:self.memberTableView];
        }
        
        _remotes[@(clientID)] = remote;
    }else{
        assert(0);
    }
}

-(void)stopTimer{
    if(_timer){
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin renderSizeChangeWithSize:(CGSize)size uid:(NSUInteger)clientID{
  //  [MBManager hideAlert];
    NSString *idStr = [NSString stringWithFormat:@"%ld",clientID];
    NSString *typeId = [idStr substringWithRange:NSMakeRange(idStr.length - 2, 2)];
    float AspectRatio =  size.width/size.height;
    if([typeId isEqualToString:@"02"]){
        self.localView.frame = CGRectMake((Screen_Width - (Screen_Height - Screen_Width/4) *AspectRatio)/2, 0, (Screen_Height - Screen_Width/4) *AspectRatio, (Screen_Height - Screen_Width/4));
    }
    KKRTCCanvas* remote = [KKRTCCanvas canvasWithUid:clientID view:[typeId isEqualToString:@"02"]?self.localView:self.fullScreenView renderMode:KKRTC_Render_Hidden];
    if ([_videoRoom startPrewViewWithCanvas:remote]) {
        // [self.localView bringSubviewToFront:self.nickNameLab];
        if ([typeId isEqualToString:@"03"]) {
            [UIApplication sharedApplication].statusBarHidden = YES;
            [self.view addSubview:self.fullScreenView];
            [self.fullScreenView bringSubviewToFront:self.fullControlView];
            [self.fullScreenView bringSubviewToFront:self.fullControlHead];
            [self.fullScreenView bringSubviewToFront:self.memberTableView];
        }
        
        _remotes[@(clientID)] = remote;
    }else{
        //        [self deleteRemoteView:view];
        assert(0);
    }
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom*)plugin netBrokenWithID:(KKRTCNetBrokenReason)reason{
    __weak typeof(self) weakSelf = self;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(forceExit) object:nil];
    switch (reason) {
        case KKRTCNetBroken_websocketFail:
        case KKRTCNetBroken_websocketClose:
        {
            if ([Utils hasMissNetworkReachability]) {
                [weakSelf disMissContactToResetVideoStatus];
                return;
            }
            [_videoRoom stopPrewViewWithUid:0];
            [_videoRoom leaveRoom:nil];
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"stopListenAudioStatus" object:nil];
                [self dismissViewControllerAnimated:YES completion:^{
                    if(self->_netTimer){
                        dispatch_source_cancel(self->_netTimer);
                        self->_netTimer = nil;
                    }
                }];
            });
            break;
        }
            
        default:
            break;
    }
}


- (void)disMissContactToResetVideoStatus{
    self.nowNetWorkStatus = 2;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].statusBarHidden == YES) {
            [self userOutShareScreen:YES];
        }
        if ([Utils isAlertShow]) {
            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
        
        [Utils showAlertWithTitle:@"温馨提示" message:@"您已断开网络链接,正在等待网络重连...." actions:nil cancelTitle:@"确定"];
        
        
        
    });
}

- (void)userAutoRecontactNetWork{
    self.selfDic = self.joinRoomPersonArray[0];
    [self.joinRoomTagArray removeAllObjects];
    [self.joinRoomPersonArray removeAllObjects];
    [_videoRoom.videoListenerArray removeAllObjects];
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
   // [MBManager showBriefAlert:@"您已成功恢复网络"];
    
    // self.janusControlView.cameraButton.selected = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for(UIView *view in self.localView.subviews){
            [view removeFromSuperview];
        }
        for (UIView *view in self.videoScollerV.subviews) {
            [view removeFromSuperview];
        }
        
    });
    self.isAutoContact = YES;
    // self.currentPlayId = 1;
    [_videoRoom createRoomWithRoomId:self.roomId block:^(BOOL isSuccess, NSError *error) {
        
    }];
    //    [_videoRoom joinRoomWithRoomID:self.roomId
    //                          userName:self.userName completeCallback:^(BOOL isSuccess, NSError *error) {
    //
    //                              dispatch_async(dispatch_get_main_queue(), ^{
    //                                  [MBManager hideAlert];
    //                              });
    //                          }];
    
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin fatalErrorWithID:(KKRTCErrorCode)errorCode{
    NSLog(@"success");
    [_videoRoom createRoomWithRoomId:self.roomId block:^(BOOL isSuccess, NSError *error) {
            if (error) {
            NSLog(@"%@",@"xxxxxxxxx");
        }else{
            NSLog(@"%@",@"xxxxxxxxx");

        }
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(self.messageView.hidden == NO){
        [UIView animateWithDuration:0.3 animations:^{
            if(self.messageView.selectPersonView.hidden == NO){
                self.messageView.selectPersonView.alpha = 0.0;
            }
            self.messageView.frame = CGRectMake(0, Screen_Height, Screen_Width, Screen_Height/2.0);
        } completion:^(BOOL finished) {
            if(self.messageView.selectPersonView.hidden == NO){
                self.messageView.selectPersonView.hidden = YES;
                [self.messageView.typeBtn setImage:[UIImage imageNamed:@"message_jt_down"]forState:UIControlStateNormal];
            }
            self.messageView.hidden = YES;
        }];
    }
    
    NSString *idStr = [NSString stringWithFormat:@"%ld",self.currentPlayId];
    if(idStr.length < 3){
        return;
    }
    NSString *typeId = [idStr substringWithRange:NSMakeRange(idStr.length - 2, 2)];
    if ([typeId isEqualToString:@"03"]) {
        if (self.fullControlHead.hidden == YES && self.fullControlView.hidden == YES) {
            [self userCreateTimer];
        }else{
            [self stopTimer];
            self.fullControlHead.hidden = YES;
            self.fullControlView.hidden = YES;
        }
    }
    
}

-(void)GJJanusVideoRoomDidLeaveRoom:(GJJanusVideoRoom *)plugin{
    NSLog(@"leave");
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



- (void)closeButtonAction
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(forceExit) object:nil];
     [self performSelector:@selector(forceExit) withObject:nil afterDelay:1];
   
    //    [_videoRoom userReConnectSocket];
    //    [_videoRoom userEndReceivceVideoStream:self.currentPlayId];
    [_videoRoom leaveRoom:^{
        
    }];
    
    
}

#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([Utils trimString:textField.text].length < 1){
       // [MBManager showBriefAlert:@"你输入的信息为空"];
        return YES;
    }
    
    [_videoRoom userSendMessage:textField.text isToAll:self.messageView.type == AllPersonReceiveType? YES:NO block:^(BOOL isSuccess, NSError *error) {
        if (isSuccess == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                extern NSString *BASEURL;
                NSMutableDictionary *messageDic = [NSMutableDictionary dictionary];
                [messageDic setObject:textField.text forKey:@"message"];
                [messageDic setObject:@"aaa" forKey:@"name"];
                [messageDic setObject:@"send" forKey:@"type"];
                [self.messageView.dataArray addObject:messageDic];
                [self.messageView.tableView reloadData];
                [self.messageView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messageView.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                self.messageView.messageTF.text = @"";
            });
        }
    }];
    return YES;
}


#pragma mark - UNJanusControlViewDelegate
-(void)unjanusControlViewShowSendMessageView:(UNJanusControlView *)janusControlView{
    if (self.messageView.hidden == YES) {
        self.messageView.hidden = NO;
        self.janusControlView.redPoint.hidden = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.messageView.frame = CGRectMake(0, Screen_Height/2.0, Screen_Width, Screen_Height/2.0);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            if(self.messageView.selectPersonView.hidden == NO){
                self.messageView.selectPersonView.alpha = 0.0;
            }
            self.messageView.frame = CGRectMake(0, Screen_Height, Screen_Width, Screen_Height/2.0);
        } completion:^(BOOL finished) {
            if(self.messageView.selectPersonView.hidden == NO){
                self.messageView.selectPersonView.hidden = YES;
                [self.messageView.typeBtn setImage:[UIImage imageNamed:@"message_jt_down"]forState:UIControlStateNormal];
            }
            self.messageView.hidden = YES;
        }];
    }
}


- (void)unjanusControlView:(UNJanusControlView *)janusControlView didClose:(BOOL)isClosed
{
    [self closeButtonAction];
}

- (void)unjanusControlView:(UNJanusControlView *)janusControlView didOpenSpeaker:(BOOL)isOpen
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.nowNetWorkStatus == 2){
          //  [MBManager showBriefAlert:@"当前网络已失去链接,请稍后再试"];
            return;
        }
        if(([self isBleToothOutput] || [self hasHeadset])&&!isOpen){
         //   [MBManager showBriefAlert:@"你已连接耳机"];
            return;
        }
        
        //    dispatch_async(dispatch_get_main_queue(), ^{
        //    [AVAudioSession sharedInstance]
        self.janusControlView.isOpenSpeaker = !isOpen;
        self.janusControlView.speakerButton.selected = !isOpen;
        self.voiceBtn.selected = !isOpen;
        self.isOpenSpeak = !isOpen;
        if (isOpen == NO) {
            self.audioType = SpeakerType;
            [self userSetPlayAudioType:SpeakerType];
        }else{
            [self userCheckAudioPlay];
        }
        
        //  [[AVAudioSession sharedInstance] setActive:NO error:nil];
//        if (isOpen) {
//            if([self bluetoothAudioDevice]){
//                AVAudioSessionPortDescription* bluetoothPort = [self bluetoothAudioDevice];
//                [[AVAudioSession sharedInstance] setPreferredInput:bluetoothPort error:nil];
//                //     [[AVAudioSession sharedInstance] setActive:YES error:nil];
//
//                NSLog(@"111111");
//            }else{
//                // AVAudioSessionPortDescription* builtinPort = [self builtinAudioDevice];
//                [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
//                // [[AVAudioSession sharedInstance] setActive:YES error:nil];
//
//            }
//        }else {
//            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
//            // [[AVAudioSession sharedInstance] setActive:YES error:nil];
//            NSLog(@"3333");
//        }
    });
   
    
    
    //  });
    
    
    
}


/**
 *  判断是否有耳机
 *
 *  @return 判断是否有耳机
 */
- (BOOL)hasHeadset {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    AVAudioSessionRouteDescription *currentRoute = [audioSession currentRoute];

    for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
        if ([[output portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            return YES;
        }
    }
    return NO;
}

- (AVAudioSessionPortDescription*)builtinAudioDevice
{
    NSArray* builtinRoutes = @[AVAudioSessionPortBuiltInMic];
    return [self audioDeviceFromTypes:builtinRoutes];
}

- (AVAudioSessionPortDescription*)bluetoothAudioDevice
{
    NSArray* bluetoothRoutes = @[AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP];
    return [self audioDeviceFromTypes:bluetoothRoutes];
}

- (AVAudioSessionPortDescription*)audioDeviceFromTypes:(NSArray*)types
{
    NSArray *routes = [[AVAudioSession sharedInstance]availableInputs];
    for (AVAudioSessionPortDescription *route in routes) {
        if([types containsObject:route.portType]){
            return route;
        }
    }
    return nil;
}

-(BOOL)isBleToothOutput

{
    
    AVAudioSessionRouteDescription *currentRount = [AVAudioSession sharedInstance].currentRoute;
    AVAudioSessionPortDescription *outputPortDesc = currentRount.outputs[0];
    if([outputPortDesc.portType isEqualToString:@"BluetoothA2DPOutput"] || [outputPortDesc.portType isEqualToString:@"BluetoothHFP"]){
        
        NSLog(@"当前输出的线路是蓝牙输出，并且已连接");
        return YES;
        
    }else{
        
        NSLog(@"当前是spearKer输出");
        
        return NO;
        
    }
    
}

- (void)unjanusControlView:(UNJanusControlView *)janusControlView didSetSilent:(BOOL)isSilent
{
    if(self.nowNetWorkStatus == 2){
       // [MBManager showBriefAlert:@"当前网络已失去链接,请稍后再试"];
        return;
    }
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (!granted) {
            [Utils showAlertWithTitle:@"温馨提示" message:@"请前往设置中打开Uworker的麦克风权限" actions:nil cancelTitle:@"确定"];
            
        }else{
            [self userOpenAudioWithSilent:isSilent];
        }
    }];
    
    
    
}

-(void)userOpenAudioWithSilent:(BOOL)isSilent{
    [_videoRoom usermuteAudio:isSilent block:^(BOOL isSuccess, NSError *error) {
        if (isSuccess == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.janusControlView.lightImageV.hidden = YES;
                self.janusControlView.silenceButton.selected = !isSilent;
                self.speakerBtn.selected = !isSilent;
                self.janusControlView.alterLab.hidden = !isSilent;
                //[self.janusControlView updateSilenceState:!isSilent];
                if(self.currentPersonView == self.minePersonView){
                    if (self.janusControlView.isSilent == isSilent) {
                        self.janusControlView.alterLab.hidden = YES;
                        self.janusControlView.voiceImageV.hidden = NO;
                    }else{
                        self.janusControlView.alterLab.hidden = NO;
                        self.janusControlView.voiceImageV.hidden = YES;
                    }
                }
                if(self.currentPlayId !=1){
                    self.janusControlView.voiceImageV.hidden = YES;
                }
                
            });
        }
    }];
}

- (void)unjanusControlView:(UNJanusControlView *)janusControlView didOpenCamera:(BOOL)isOpen
{
    if(self.nowNetWorkStatus == 2){
     //   [MBManager showBriefAlert:@"当前网络已失去链接,请稍后再试"];
        return;
    }
    
    if (![Utils checkCamera]) {
        [Utils showAlertWithTitle:@"温馨提示" message:@"请前往设置中打开Uworker的相机权限" actions:nil cancelTitle:@"确定"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [_videoRoom usermuteVideo:isOpen block:^(BOOL isSuccess, NSError *error) {
        if (isSuccess == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.janusControlView.cameraButton.selected = !isOpen;
                weakSelf.cameraBtn.selected = !isOpen;
                [weakSelf.janusControlView updateCameraState:!isOpen];
                
                //当前直接关闭移除自身的播放视图
                
                if (isOpen == NO) {
                    self.minePersonView.videoBtn.hidden = NO;
                }else {
                    self.minePersonView.videoBtn.hidden = YES;
                    
                }
                //判断当前是否选中自己 若不在播放 自动播放自己
                if (self.currentPersonView == self.minePersonView) {
                    if (self.currentPlayId == 1 ) {
                        [self userChangeMeetingPersonWithVideoPublisherId:self.minePersonView.VideoId screenPublisherId:self.minePersonView.screenId nickName:self.minePersonView.nickName.text personView:self.minePersonView];
                    }else if (self.currentPlayId == 0){
                        self.currentPlayId = 1;
                        if (self.janusControlView.isSilent == YES) {
                            self.janusControlView.alterLab.hidden = YES;
                            self.janusControlView.voiceImageV.hidden = NO;
                        }else{
                            self.janusControlView.alterLab.hidden = NO;
                            self.janusControlView.voiceImageV.hidden = YES;
                        }
                        self.janusControlView.userIconImageV.hidden = NO;
                        // [self.currentPlayBtn setImage:[UIImage imageNamed:@"videoIcon"] forState:UIControlStateNormal];
                        for(UIView *subView in self.localView.subviews){
                            if ( [subView isKindOfClass:[GJImageView class]]) {
                                [subView removeFromSuperview];
                            }
                        }
                    }
                }
                
                
                
                
                
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.janusControlView.cameraButton.userInteractionEnabled = YES;
        });
    }];
    
}

- (void)unjanusControlView:(UNJanusControlView *)janusControlView didCameraBack:(BOOL)isBack{
    [_videoRoom userUserBackCamera:isBack];
}


- (void)unjanusControlView:(UNJanusControlView *)janusControlView openShareScreen:(BOOL)isBack{
    for (PersonVideoView *view in self.videoScollerV.subviews) {
        if ([view isKindOfClass:[PersonVideoView class]]) {
            if (view.screenBtn.hidden == NO) {
                if(self.nowNetWorkStatus == 2){
                    //[MBManager showBriefAlert:@"当前网络已失去链接,请稍后再试"];
                    return;
                }
                
                self.currentPersonView.isCurrentSelect = NO;
                self.currentPersonView = view;
                self.currentPersonView.isCurrentSelect = YES;
                [self userControlNoVideoWidgetShowHide:NO];
//                [self.janusControlView.userIconImageV sd_setImageWithURL:[NSURL URLWithString:view.iconUrl] placeholderImage:[UIImage imageNamed:@"默认男头像"] options:SDWebImageRefreshCached completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//
//                }];
                [self userClickShareScreenBtnWithPublisherId:view.screenId nickName:view.nickName.text personView:view];
                break;
                
            }
        }
    }
}

- (void)unjanusControlViewDidAddRole:(UNJanusControlView *)janusControlView{
    if(self.messageView.hidden == NO){
        [UIView animateWithDuration:0.3 animations:^{
            if(self.messageView.selectPersonView.hidden == NO){
                self.messageView.selectPersonView.alpha = 0.0;
            }
            self.messageView.frame = CGRectMake(0, Screen_Height, Screen_Width, Screen_Height/2.0);
        } completion:^(BOOL finished) {
            if(self.messageView.selectPersonView.hidden == NO){
                self.messageView.selectPersonView.hidden = YES;
                [self.messageView.typeBtn setImage:[UIImage imageNamed:@"message_jt_down"]forState:UIControlStateNormal];
                
            }
            self.messageView.hidden = YES;
        }];
    }
 
    
    
}

- (void)MoveVideoViewClick:(UIButton *)sender{
    if (sender.tag == 1001) {
        if (self.videoScollerV.contentOffset.x < 2) {
            self.videoScollerV.contentOffset = CGPointMake(0, 0);
        }else{
            self.videoScollerV.contentOffset = CGPointMake(self.videoScollerV.contentOffset.x  - Screen_Width/4, 0);
        }
    }else{
        NSLog(@"%f___%f",self.videoScollerV.contentOffset.x +Screen_Width/4 + self.videoScollerV.frame.size.width,self.videoScollerV.contentSize.width);
        if (!(self.videoScollerV.contentOffset.x +Screen_Width/4 + self.videoScollerV.frame.size.width <  self.videoScollerV.contentSize.width)) {
            self.videoScollerV.contentOffset = CGPointMake(self.videoScollerV.contentSize.width - self.videoScollerV.frame.size.width, 0);
        }else{
            self.videoScollerV.contentOffset = CGPointMake(self.videoScollerV.contentOffset.x  + Screen_Width/4, 0);
        }
    }
}


- (void)userListeNetWorkStatus{
    self.nowNetWorkStatus = 2;
}

- (void)userReContactNetWork{
    if (self.nowNetWorkStatus == 2) {
        self.nowNetWorkStatus = 1;
        [self userAutoRecontactNetWork];
    }
}

/*
 - (void)userMonitorNetWork{
 
 __block  AFNetworkReachabilityManager *netWorkReachability = [AFNetworkReachabilityManager sharedManager];
 __weak AFNetworkReachabilityManager *weakNetWorkReachability = netWorkReachability;
 [weakNetWorkReachability startMonitoring];
 __weak typeof(self) weakSelf = self;
 [weakNetWorkReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
 switch (status) {
 case AFNetworkReachabilityStatusNotReachable:{
 NSLog(@"无网络");
 weakSelf.nowNetWorkStatus = 2;
 break;
 }
 default:{
 if (weakSelf.nowNetWorkStatus == 2) {
 weakSelf.nowNetWorkStatus = 1;
 [weakSelf userAutoRecontactNetWork];
 }
 break;
 }
 
 
 }
 }];
 }
 */
#pragma mark - Getter

-(VideoCallMemberTableView *)memberTableView{
    if (!_memberTableView) {
        _memberTableView = [[VideoCallMemberTableView alloc] initWithFrame:CGRectMake(Screen_Height, 0, 150+ kSafeBottomHeight, Screen_Width) style:UITableViewStylePlain];
        _memberTableView.memberDelegate = self;
    }
    return _memberTableView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        _closeButton.backgroundColor = [UIColor redColor];
        _closeButton.clipsToBounds = YES;
        _closeButton.layer.cornerRadius = 30;
        _closeButton.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2 - 30, CGRectGetMaxY([UIScreen mainScreen].bounds) - 80, 60, 60);
        [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UIButton *)memberBtn {
    if (!_memberBtn) {
        _memberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_memberBtn addTarget:self action:@selector(showMemberList) forControlEvents:UIControlEventTouchUpInside];
        _memberBtn.frame = CGRectMake(Screen_Height - 60 - kSafeBottomHeight,10, 35, 35);
        [_memberBtn setImage:[UIImage imageNamed:@"memberIcon"] forState:UIControlStateNormal];
    }
    return _memberBtn;
}

- (UIButton *)voiceStateButton {
    if (!_voiceStateButton) {
        _voiceStateButton = [[UIButton alloc] init];
        _voiceStateButton.backgroundColor = [UIColor redColor];
        _voiceStateButton.clipsToBounds = YES;
        _voiceStateButton.layer.cornerRadius = 30;
        _voiceStateButton.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2 - 30, CGRectGetMaxY([UIScreen mainScreen].bounds) - 220, 60, 60);
        [_voiceStateButton setTitle:@"静音" forState:UIControlStateNormal];
    }
    return _voiceStateButton;
}

-(UILabel *)screenHeadLab{
    if (!_screenHeadLab ) {
        _screenHeadLab = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, Screen_Height - 140, 45)];
        _screenHeadLab.textColor = [UIColor whiteColor];
        _screenHeadLab.textAlignment = NSTextAlignmentCenter;
        _screenHeadLab.font = [UIFont systemFontOfSize:16];
    }
    return _screenHeadLab;
}

- (UNJanusControlView *)janusControlView {
    if (!_janusControlView) {
        _janusControlView = [[UNJanusControlView alloc] init];
        
        _janusControlView.delegate = self;
        _janusControlView.userInteractionEnabled = YES;
        //        if (!self.message) {
        //            _janusControlView.addRoleButton.hidden = YES;
        //        }
    }
    return _janusControlView;
}

-(NSMutableArray *)joinRoomPersonArray{
    if (!_joinRoomPersonArray) {
        _joinRoomPersonArray = [NSMutableArray array];
    }
    return _joinRoomPersonArray;
}

-(NSMutableArray *)joinRoomTagArray{
    if(!_joinRoomTagArray){
        _joinRoomTagArray = [NSMutableArray array];
    }
    return _joinRoomTagArray;
}

- (UIButton *)leftBtn{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.tag = 1001;
        [_leftBtn addTarget:self action:@selector(MoveVideoViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [_leftBtn setImage:[UIImage imageNamed:@"webrtc_left"] forState:UIControlStateNormal];
        _leftBtn.hidden = YES;
    }
    return _leftBtn;
}

-(UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.tag = 1002;
        [_rightBtn addTarget:self action:@selector(MoveVideoViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [_rightBtn setImage:[UIImage imageNamed:@"webrtc_right"] forState:UIControlStateNormal];
        _rightBtn.hidden = YES;
    }
    return _rightBtn;
}

-(UIScrollView *)videoScollerV{
    if (!_videoScollerV) {
        _videoScollerV = [[UIScrollView alloc] init];
    }
    return _videoScollerV;
}

-(UIButton *)voiceBtn{
    if (!_voiceBtn) {
        _voiceBtn = [[UIButton alloc] init];
        
        [_voiceBtn setImage:[UIImage imageNamed:@"video_speaker"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage imageNamed:@"video_nospeaker"] forState:UIControlStateSelected];
        [_voiceBtn addTarget:self action:@selector(fullControlButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _voiceBtn;
}


-(UIButton *)speakerBtn{
    if (!_speakerBtn) {
        _speakerBtn = [[UIButton alloc] init];
        [_speakerBtn setImage:[UIImage imageNamed:@"wetrtc_silence"] forState:UIControlStateNormal];
        [_speakerBtn setImage:[UIImage imageNamed:@"wetrtc_nosilence"] forState:UIControlStateSelected];
        [_speakerBtn addTarget:self action:@selector(fullControlButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speakerBtn;
}

-(UIButton *)cameraBtn{
    if (!_cameraBtn) {
        _cameraBtn = [[UIButton alloc] init];
        [_cameraBtn setImage:[UIImage imageNamed:@"webrtc_camera"] forState:UIControlStateNormal];
        [_cameraBtn setImage:[UIImage imageNamed:@"webrtc_nocamera"] forState:UIControlStateSelected];
        [_cameraBtn addTarget:self action:@selector(fullControlButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBtn;
}

-(VideoMessageView *)messageView{
    if (!_messageView) {
        _messageView = [[VideoMessageView alloc] initWithFrame:CGRectMake(0, Screen_Height, Screen_Width, Screen_Height/3*2)];
        _messageView.hidden = YES;
        _messageView.messageTF.delegate = self;
    }
    return _messageView;
}

#pragma mark 暂时未用代码
#pragma mark 暂时未用代码
#pragma mark 暂时未用代码
#pragma mark 暂时未用代码
#pragma mark 暂时未用代码
#pragma mark - WeChat
#pragma mark - master版本设置底部状态栏用
//                if ([view.nickName.text isEqualToString:[UNLoginController sharedInstance].selfInfoModel.name]) {
//                    UILabel *label = [[UILabel alloc] init];
//                    label.text = weakSelf.joinRoomPersonArray[i][@"display"];
//                    label.textColor = [UIColor whiteColor];
//                    label.font = [UIFont systemFontOfSize:14];
//                    [weakSelf.videoRoom startPrewViewWithCanvas:[KKRTCCanvas canvasWithUid:0 view:view renderMode:KKRTC_Render_Hidden]];
//                    for(UIView *subView in view.subviews){
//                        if ([subView isKindOfClass:[GJImageView class]]) {
//                            [subView addSubview:label];
//                            [label mas_makeConstraints:^(MASConstraintMaker *make) {
//                                    make.centerX.equalTo(subView);
//                                    make.bottom.equalTo(subView).offset(-15);
//                            }];
//                        subView.hidden = YES;
//                        }
//                    }
//                }

/*
 __weak typeof(view) weakView = view;
 view.clickBlock = ^{
 
 __strong typeof(weakView) strongView = weakView;
 for(UIView *subView in strongView.subviews){
 if ([subView isKindOfClass:[RTCEAGLVideoView class]]) {
 for (RTCEAGLVideoView *oldView in weakSelf.localView.subviews) {
 [oldView removeFromSuperview];
 for (PersonVideoView *personView in weakSelf.videoScollerV.subviews) {
 if (personView.tag == oldView.tag) {
 [personView addSubview:oldView];
 [oldView mas_makeConstraints:^(MASConstraintMaker *make) {
 make.edges.equalTo(personView);
 }];
 }
 }
 }
 [weakSelf.localView addSubview:subView];
 subView.tag = strongView.tag;
 [subView mas_remakeConstraints:^(MASConstraintMaker *make) {
 make.edges.equalTo(weakSelf.localView);
 }];
 }else if ([subView isKindOfClass:[GJImageView class]]){
 if (weakSelf.janusControlView.cameraButton.selected == YES) {
 return ;
 }
 for (GJImageView *oldView in weakSelf.localView.subviews) {
 [oldView removeFromSuperview];
 for (PersonVideoView *personView in weakSelf.videoScollerV.subviews) {
 if (personView.tag == oldView.tag) {
 [personView addSubview:oldView];
 [oldView mas_makeConstraints:^(MASConstraintMaker *make) {
 make.edges.equalTo(personView);
 }];
 }
 }
 }
 // self.titleLab.text = view.nickName.text;
 [weakSelf.localView addSubview:subView];
 subView.tag = strongView.tag;
 [subView mas_remakeConstraints:^(MASConstraintMaker *make) {
 make.edges.equalTo(weakSelf.localView);
 }];
 }
 }
 
 };*/
/*
 @interface GJVideoBoxView:PersonVideoView
 {
 CGPoint _startPoint;
 CGRect _startFrame;
 
 CGRect _originFrame;
 }
 @end
 @implementation GJVideoBoxView
 
 -(instancetype)initWithFrame:(CGRect)frame{
 self = [super initWithFrame:frame];
 
 if (self) {
 UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
 [tapGesture setNumberOfTapsRequired:2];
 [self addGestureRecognizer:tapGesture];
 }
 return self;
 }
 -(void)tap:(UITapGestureRecognizer*)reg{
 if (self.superview) {
 if (CGRectEqualToRect(self.frame, self.superview.frame)) {
 [UIView animateWithDuration:0.2 animations:^{
 self.frame = _originFrame;
 }];
 }else{
 _originFrame = self.frame;
 [UIView animateWithDuration:0.2 animations:^{
 self.frame = self.superview.frame;
 }];
 }
 }
 }
 
 //-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
 //    if (self.superview) {
 //        _startPoint = [touches.anyObject  locationInView:self.superview];
 //        _startFrame = self.frame;
 //    }else{
 //        _startPoint = CGPointMake(-1, -1);
 //    }
 //}
 //-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
 //    if (_startPoint.x > 0) {
 //        CGPoint point = [touches.anyObject locationInView:self.superview];
 //        CGFloat offestX = point.x - _startPoint.x;
 //        CGFloat offestY = point.y - _startPoint.y;
 //        CGRect frame = _startFrame;
 //        frame.origin.x += offestX;
 //        frame.origin.y += offestY;
 //        self.frame = frame;
 //    }
 //}
 
 -(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
 
 }
 
 -(void)dealloc{
 [self removeGestureRecognizer:nil];
 }
 @end
 */
- (void)startVideo
{
    
    /*
     GJJanusPushlishMediaConstraints* localConfig = _videoRoom.localConfig;
     localConfig.pushSize = [_pushSize.allValues[_sizeChange.tag % _pushSize.count] CGSizeValue];
     //            localConfig.fps = 15;
     //            localConfig.videoBitrate = 600*1000;
     //            localConfig.audioBitrate = 200*1000;
     //            localConfig.frequency = 44100;
     //            //    localConfig.audioEnable = NO;
     //            _videoRoom.localConfig = localConfig;
     if (self.roomId) {
     [_videoRoom joinRoomWithRoomID:self.roomId userName:_userName completeCallback:^(BOOL isSuccess, NSError *error) {
     
     NSLog(@"joinRoomWithRoomID:%@", error);
     }];
     }
     */
}

- (void)voiceStateButtonAction
{
    
}



/*
 - (void)userChanegeRemoteViewShow:(UIView *)view ishowNoVideoImage:(BOOL) isShow{
 if (isShow == YES) {
 dispatch_async(dispatch_get_main_queue(), ^{
 for(UIView *subView in view.subviews){
 if ([subView isKindOfClass:[RTCEAGLVideoView class]]) {
 subView.hidden = NO;
 }
 }
 for(UIView *subView in self.localView.subviews){
 if ([subView isKindOfClass:[RTCEAGLVideoView class]] &&subView.tag == view.tag) {
 subView.hidden = NO;
 }
 }
 });
 }else{
 dispatch_async(dispatch_get_main_queue(), ^{
 for(UIView *subView in view.subviews){
 if ([subView isKindOfClass:[RTCEAGLVideoView class]]) {
 subView.hidden = YES;
 }
 for(UIView *subView in self.localView.subviews){
 if ([subView isKindOfClass:[RTCEAGLVideoView class]] &&subView.tag == view.tag) {
 subView.hidden = YES;
 }
 }
 }
 
 
 });
 
 
 }
 }
 */
//-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin addVideoTrackWithUid:(NSUInteger)uid{

//}
//
//-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin delVideoTrackWithUid:(NSUInteger)uid{
//    KKRTCCanvas* canvas = _remotes[@(uid)];
//    [self deleteRemoteView:canvas.view];
//    [_remotes removeObjectForKey:@(uid)];
//}

/*
 -(void)updateFrame{
 CGRect rect = self.view.bounds;
 // _localView.frame = rect;
 rect.size.height *= 0.4;
 rect.origin.y = 64;
 _controlView.frame = rect;
 
 NSInteger maxHCount = 4,maxWCount = 3;
 CGSize itemSize;
 NSInteger wMarggin = 10, hMarggin = 10;
 itemSize.height = (_controlView.frame.size.height - hMarggin*(maxHCount+1))/ maxHCount;
 itemSize.width = (_controlView.frame.size.width - wMarggin*(maxWCount+1))/ maxWCount;
 rect.origin = CGPointZero;
 rect.size = itemSize;
 
 _controlView.contentSize = CGSizeMake(_controlView.frame.size.width*((_controlBtns.count-1)/(maxHCount*maxWCount)+1), _controlView.frame.size.height);
 
 for (int i = 0; i<_controlBtns.count; i++) {
 rect.origin.x = wMarggin + (itemSize.width + wMarggin)*(i/maxHCount);
 rect.origin.y = hMarggin + (itemSize.height + hMarggin)*(i%maxHCount);
 _controlBtns[i].frame = rect;
 }
 }
 
 -(void)sliderScroll:(GJSliderView*)slider{
 
 if(slider == _brigntSlider){
 _videoRoom.skinBright = slider.value * 100;
 }else if (slider == _rubbySlider){
 _videoRoom.skinRuddy = slider.value * 100;
 
 }else if (slider == _softenSlider){
 _videoRoom.skinSoften = slider.value * 100;
 
 }else if (slider == _slenderSlider){
 _videoRoom.faceSlender = slider.value * 100;
 
 }else if (slider == _enlargementSlider){
 _videoRoom.eyeEnlargement = slider.value * 100;
 }else{
 assert(0);
 }
 }
 
 -(void)btnSelect:(UIButton*)btn{
 btn.selected = !btn.selected;
 if (btn == _startBtn) {
 _sizeChange.enabled = !btn.selected;
 if (btn.selected) {
 
 
 GJJanusPushlishMediaConstraints* localConfig = _videoRoom.localConfig;
 localConfig.pushSize = [_pushSize.allValues[_sizeChange.tag % _pushSize.count] CGSizeValue];
 //            localConfig.fps = 15;
 //            localConfig.videoBitrate = 600*1000;
 //            localConfig.audioBitrate = 200*1000;
 //            localConfig.frequency = 44100;
 //            //    localConfig.audioEnable = NO;
 _videoRoom.localConfig = localConfig;
 
 [_videoRoom joinRoomWithRoomID:self.roomId userName:_userName completeCallback:^(BOOL isSuccess, NSError *error) {
 if(isSuccess == NO)btn.selected = NO;
 NSLog(@"joinRoomWithRoomID:%@", error);
 }];
 }else{
 [_videoRoom leaveRoom:^{
 
 }];
 }
 
 }else if (btn == _previewMirrorBtn){
 _videoRoom.previewMirror = btn.selected;
 }else if(btn == _streamMirrorBtn){
 _videoRoom.streamMirror = btn.selected;
 }else if(btn == _switchCameraBtn){
 if (_videoRoom.cameraPosition == AVCaptureDevicePositionBack) {
 _videoRoom.cameraPosition =  AVCaptureDevicePositionFront;
 }else{
 _videoRoom.cameraPosition =  AVCaptureDevicePositionBack;
 }
 }else if (btn == _sizeChange){
 _sizeChange.tag ++;
 [_sizeChange setTitle:_pushSize.allKeys[_sizeChange.tag%_pushSize.count] forState:UIControlStateNormal];
 GJJanusPushlishMediaConstraints* localConfig = _videoRoom.localConfig;
 localConfig.pushSize = [_pushSize.allValues[_sizeChange.tag % _pushSize.count] CGSizeValue];
 _videoRoom.localConfig = localConfig;
 }else  if (btn == _videoOrientationBtn){
 _videoOrientationBtn.tag++;
 _videoRoom.outOrientation = _videoOrientationBtn.tag % 4 + 1;
 switch (_videoRoom.outOrientation) {
 case UIInterfaceOrientationPortrait:
 [_videoOrientationBtn setTitle:@"视图方向:正" forState:UIControlStateNormal];
 break;
 case UIInterfaceOrientationPortraitUpsideDown:
 [_videoOrientationBtn setTitle:@"视图方向:倒" forState:UIControlStateNormal];
 break;
 case UIInterfaceOrientationLandscapeLeft:
 [_videoOrientationBtn setTitle:@"视图方向:左" forState:UIControlStateNormal];
 break;
 case UIInterfaceOrientationLandscapeRight:
 [_videoOrientationBtn setTitle:@"视图方向:右" forState:UIControlStateNormal];
 break;
 
 default:
 assert(0);
 break;
 }
 }else if (btn == _startStickerBtn){
 
 }else{
 assert(0);
 }
 }
 
 -(UIImage*)getSnapshotImageWithSize:(CGSize)size{
 static   NSDateFormatter *formatter ;
 if (formatter == nil) {
 formatter = [[NSDateFormatter alloc] init];
 [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss:SSS"];
 }
 
 NSString *dateTime = [formatter stringFromDate:[NSDate date]];
 
 CGRect rect = CGRectMake(0, 0, size.width, size.height);
 NSDictionary* attr = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
 
 static CGPoint fontPoint ;
 if (fontPoint.y < 0.0001) {
 CGSize fontSize = [dateTime sizeWithAttributes:attr];
 fontPoint.x = (size.width - fontSize.width)*0.5;
 fontPoint.y = (size.height - fontSize.height)*0.5;
 }
 //    _timeLab.text = dateTime;
 UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
 CGContextRef context = UIGraphicsGetCurrentContext();
 CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor);
 CGContextFillRect(context, rect);
 //    [dateTime drawInRect:rect withAttributes:attr];
 [dateTime drawAtPoint:fontPoint withAttributes:attr];
 //    [_timeLab drawViewHierarchyInRect:_timeLab.bounds afterScreenUpdates:NO];
 UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return image;
 }
 
 #define MARGGING 10
 #define ITEM_COUNT 4
 -(void)addRemoteView:(UIView*)view withSize:(CGSize)size{
 
 [UIView animateWithDuration:0.5 animations:^{
 [self.view addSubview:view];
 //        [self.view insertSubview:view belowSubview:self.janusControlView];
 view.frame = [self getFrameWithIndex:_remotes.count withSize:(CGSize)size];
 }];
 
 }
 -(CGRect)getFrameWithIndex:(NSInteger)index withSize:(CGSize)size{
 CGSize frameSize = self.view.bounds.size;
 CGFloat height = 90;
 CGFloat width = (frameSize.width - ITEM_COUNT * MARGGING)*1.0/ITEM_COUNT;
 NSInteger col = index % ITEM_COUNT;
 NSInteger rows = index / ITEM_COUNT +1 ;
 CGRect frame = CGRectMake( (MARGGING + width)*col, frameSize.height -  (MARGGING + height)*rows, width, height);
 
 //  CGFloat rate =  size.height /size.width;
 //    if(frame.size.width / frame.size.height > size.width / size.height){
 //        size.height = frame.size.height;
 //        size.width = size.height / rate;
 //    }else{
 size.width = frame.size.width;
 size.height = frame.size.height ;
 //    }
 frame.origin.x += (frame.size.width - size.width)/2.0;
 frame.origin.y += (frame.size.height - size.height)/2.0;
 frame.size = size;
 return frame;
 }
 
 -(void)deleteRemoteView:(UIView*)view{
 
 [UIView animateWithDuration:0.5 animations:^{
 KKRTCCanvas* remote = nil;
 for (int i = 0; i < _remotes.count; i++) {
 if (!remote) {
 if (_remotes.allValues[i].view == view) {
 remote = _remotes.allValues[i];
 [view removeFromSuperview];
 }
 }else{
 CGSize size = _remotes.allValues[i-1].view.frame.size;
 _remotes.allValues[i].view.frame = [self getFrameWithIndex:i-1 withSize:size];
 }
 
 }
 }];
 
 }
 */
@end
