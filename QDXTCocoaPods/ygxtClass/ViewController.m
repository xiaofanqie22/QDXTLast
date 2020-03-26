//
//  ViewController.m
//  ygxtClass
//
//  Created by kaili on 2018/8/20.
//  Copyright © 2018年 kaili. All rights reserved.
//
#import "ViewController.h"
#import <SafariServices/SafariServices.h>
#import  <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <MediaPlayer/MPVolumeView.h>
#import "VideoSession.h"
#import "VideoSession.h"
#import "VideoViewLayouter.h"
#import "KeyCenter.h"
#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import <AVFoundation/AVFoundation.h>
#import "YGToolsObject.h"
#import "TSFRequest.h"
#import "GJJanusVideoRoom.h"
// TODO 这里需要删除
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "PersonVideoView.h"
#import "VideoCallViewController.h"
#import "GJJanusListenRole.h"
#import "GJJanusVideoRoom.h"
#import "UNJanusControlView.h"
#import "PersonVideoView.h"
#import "VideoCallMemberTableView.h"
#import "VideoMessageView.h"
#import "MBProgressHUD.h"
#import "UNPublicDefine.h"
#import <Masonry.h>
#import "Utils.h"
#import "PublicFun.h"
//监听电话
#import "OSProgressView.h"

#define Screen_Width  [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define WEAKSELF __weak __typeof(self)weakSelf = self;
#define OS_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface ViewController() <UIWebViewDelegate,UIScrollViewDelegate,LeftBodyCellDelegate,GJJanusVideoRoomDelegate>{
    UIWebView * webView;
    UIWebView * nextwebView;
    BOOL isLoad;
    UIButton * butn;
    UIWebView * classWebview;
    UIWebView * mediaWebview;
    UIWebView * nowWebview;
    long  teacherUid;
    long shareId;
    BOOL isShare;
    VideoSession *shareSession;
    NSMutableArray * shareSessionsArr;
    BOOL isOpenKJ;//是否打开课件
    BOOL shareModel;
    NSString * lastRequestUrlStr;
    NSMutableArray * nextWebviewArr;
    UIWebView * lastWebview;
    NSTimer * netTimer;
    long  userId;
    BOOL isFirstLive;
    NSMutableArray<UIView*>* _controlBtns;
    NSArray<NSString*>* _stickerPath;
    NSDictionary* _pushSize;
    
    UIScrollView* _controlView;
    
    UIButton* _startBtn;
    UIButton* _switchCameraBtn;
    UIButton* _streamMirrorBtn;
    UIButton* _previewMirrorBtn;
    UIButton* _startStickerBtn;
    UIButton* _sizeChange;
    UIButton* _faceStickerBtn;
    UIButton* _videoOrientationBtn;
    

    
    dispatch_source_t _timer;
    
    dispatch_source_t _netTimer;

    //    UIAlertView * myAlert;
}

typedef NS_ENUM(NSInteger, AudioPlayType) {
    HeadPhoneType = 0,
    HeadsetType =1,
    BluetoothHeadsetType = 2,
    SpeakerType = 3,
    
};


@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (strong, nonatomic)  UIView *remoteContainerView;
@property (strong, nonatomic)  UIView * shareView;
@property (strong, nonatomic)  UIButton * testView;
@property (weak, nonatomic) IBOutlet UIButton *broadcastButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *sessionButtons;
@property (weak, nonatomic) IBOutlet UIButton *audioMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *enhancerButton;
@property (assign, nonatomic) BOOL isBroadcaster;
@property (assign, nonatomic) BOOL isMuted;
@property (assign, nonatomic) BOOL shouldEnhancer;
@property (strong, nonatomic) NSMutableArray<VideoSession *> *videoSessions;
@property (strong, nonatomic) VideoSession *fullSession;
@property (strong, nonatomic) VideoViewLayouter *viewLayouter;
@property (assign, nonatomic) CGFloat  height;
@property(strong,nonatomic) YGToolsObject * toolObject;
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

@property (nonatomic, assign) AudioPlayType audioType;

@property (nonatomic, assign) AudioPlayType lastAudioType;

@property (nonatomic, assign) BOOL isFrist;

@property (assign, nonatomic) long myId;

@property (assign, nonatomic) BOOL isStarted;
@property (assign, nonatomic) BOOL isLoad;
@property (assign, nonatomic) BOOL isFinished;


@property (strong, nonatomic) UIWebView *webview1;
@property (strong, nonatomic) UIWebView *webview2;
@property (strong, nonatomic) UIWebView *webview3;
@property (strong, nonatomic) UIWebView *webview4;


@end


@implementation ViewController

- (UIWebView *)webview1{
    if (!_webview1) {
        _webview1 = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _webview1.hidden = YES;
        _webview1.allowsInlineMediaPlayback = YES;
        _webview1.mediaPlaybackRequiresUserAction = NO;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://qd.jiayou9.com/homework_mobile/#/student/homeworks?open=open"]];
        _webview1.scrollView.bounces=NO;
        [_webview1 loadRequest:request];
        [self.view addSubview:_webview1];
    }
    return _webview1;
}

- (UIWebView *)webview2{
    if (!_webview2) {
        _webview2 = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _webview2.hidden = YES;
        _webview2.allowsInlineMediaPlayback = YES;
        _webview2.mediaPlaybackRequiresUserAction = NO;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://qd.jiayou9.com/wrong_mobile/#/?open=open"]];
        _webview2.scrollView.bounces=NO;
        [_webview2 loadRequest:request];
        [self.view addSubview:_webview2];
    }
    return _webview2;
}

- (UIWebView *)webview3{
    if (!_webview3) {
        _webview3 = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _webview3.hidden = YES;
        _webview3.allowsInlineMediaPlayback = YES;
        _webview3.mediaPlaybackRequiresUserAction = NO;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://qd.jiayou9.com/note_app/#/?open=open"]];
        _webview3.scrollView.bounces=NO;
        [_webview3 loadRequest:request];
        [self.view addSubview:_webview3];
    }
    return _webview3;
}

- (UIWebView *)webview4{
    if (!_webview4) {
        _webview4 = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _webview4.hidden = YES;
        _webview4.allowsInlineMediaPlayback = YES;
        _webview4.mediaPlaybackRequiresUserAction = NO;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://qd.jiayou9.com/schedule_mobile/#/my/course?open=open"]];
        _webview4.scrollView.bounces=NO;
        [_webview4 loadRequest:request];
        [self.view addSubview:_webview4];
    }
    return _webview4;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.isFrist= YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL flag;
    NSError *setCategoryError = nil;
    nextWebviewArr = [[NSMutableArray alloc]initWithCapacity:0];
    flag = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    [self setStatusBarBackgroundColor:[UIColor colorWithRed:48/255.f green:48/255.f blue:48/255.f alpha:1.0]];
    self.toolObject = [[YGToolsObject alloc]init];
    self.height = 0;
    NSString * urlStr = [NSString stringWithFormat:@"https://qd.jiayou9.com/mobile_phone/#/?t=%@",[self getNowTimeTimestamp3]];
    NSURL *url = [NSURL URLWithString:urlStr];
    webView = [[UIWebView alloc] init];
    if (self.view.frame.size.width > self.view.frame.size.height) {
        webView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    }else{
        webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    webView.delegate = self;
    webView.scrollView.bounces=NO;
    webView.mediaPlaybackRequiresUserAction = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    NSString *js = @"window.open = function(url, d1, d2) { window.location = \"open://\" + url;}";
    [webView stringByEvaluatingJavaScriptFromString:js];

    NSString *jsnew = @"window.close = function() {window.location.assign(\"back://\" + window.location);};";
     
    [webView stringByEvaluatingJavaScriptFromString:jsnew];


    lastWebview = webView;
    [self.view addSubview:webView];
    
    isLoad = NO;
    
    mediaWebview = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mediaWebview.backgroundColor = [UIColor whiteColor];
    self.roomName = @"";
    self.clientRole = AgoraRtc_ClientRole_Audience;
    self.view.backgroundColor = [UIColor whiteColor];
    self.videoSessions = [[NSMutableArray alloc] init];
    shareSessionsArr = [[NSMutableArray alloc]init];
    [self updateButtonsVisiablity];
    self.remoteContainerView = [[UIView alloc]initWithFrame:CGRectMake(55, 10, 150, self.height)];
    self.remoteContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.remoteContainerView];
    
    self.shareView = [[UIView alloc]init];
    [self.view addSubview:self.shareView];
    
    webView.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startNet) name:@"startNet"object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endNet) name:@"endNet"object:nil];
    
    [self buildUI];

    
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
    _fullScreenView.hidden = YES;
    _fullScreenView.frame = CGRectMake(0, kSafeTopHeight,Screen_Width,  Screen_Height - kSafeTopHeight);
    _localView.userInteractionEnabled = NO;
    _localView.hidden = YES;
    _localView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_localView];
    [self.view addSubview:self.janusControlView];
    self.view.backgroundColor = RGBAColor(35, 35, 35, 1);
    [self.view addSubview:self.videoScollerV];
    [self.view addSubview:self.leftBtn];
    [self.view addSubview:self.rightBtn];
    self.fullControlHead.hidden = YES;
    self.fullControlView.hidden = YES;
    self.janusControlView.hidden = YES;
    
}

- (void)connectWebSocket{
    
    self.urlAddress=@"wss://janus.jiayou9.com/ws";
    self.wsPort=8188;
    self.userName=@"ios";
    self.videoRoom = [GJJanusVideoRoom shareInstanceWithServer:[NSURL URLWithString: self.urlAddress] delegate:self];
    // 视频播放的角度，不设置的话会随着横屏之后 旋转90°
    self.videoRoom.outOrientation = UIInterfaceOrientationLandscapeRight;
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
    localConfig.pushSize = CGSizeMake(240, 135); // pc端p屏幕比例16：9
//    localConfig.fps = 20;
//    localConfig.videoBitrate = 128*1000;
//    localConfig.audioBitrate = 200*1000;
//    localConfig.frequency = 44100;
    _videoRoom.localConfig = localConfig;
}

-(void)endNet{
}

-(void)startNet{
    if (netTimer == nil) {
        netTimer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:netTimer forMode:NSRunLoopCommonModes];
    }
    [netTimer fire];
}
-(void)timerRun{
    NSMutableDictionary * postDic = [self.toolObject toGetAppInfo];
    NSString * tokenStr = [self toGetToken];
    
    if (!tokenStr){
        
    }else{
        [[TSFRequest sharedRequest]get:@"https://api.yunguxt.com/auth/user/app/hbt" BodyDic:postDic withToken:tokenStr DataBlock:^(id data) {
            NSLog(@"成功了！！！！！！");
        } ErrorBlock:^(id error) {
            NSLog(@"shibail！！！！！！");
        }];
    }
}

-(NSString *)toGetToken{
    JSContext *context = [lastWebview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *textJS = [NSString stringWithFormat:@"localStorage.getItem('access_token')"];
    NSString * tokenStr =  [[context evaluateScript:textJS] toString];
    return tokenStr;
}


//设置状态栏背景颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    
    
    if (@available(iOS 13.0, *)) {
        
        // iOS 13  弃用keyWindow属性  从所有windowl数组中取
        
        UIView *statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame] ;
        
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = color;
        }
        
        [[UIApplication sharedApplication].keyWindow addSubview:statusBar];
    
        
    }else{
        
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = color;
        }
        
    }
     
    
}

//设置字体颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;//白色
}


-(void)dealloc{
    [netTimer invalidate];
}

#pragma mark--------调整方向---------
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

-(NSString *)getNowTimeTimestamp3{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; //
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    return timeSp;
}

-(void)click:(UIButton * )btn{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.remoteContainerView removeFromSuperview];
        self.shareView.frame = CGRectMake(0, 0, 0, 0);
    });
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{

    [PublicFun hiddenProgressHUD];
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"YunGuiBridge"]=self;
    JSValue *Callback = context[@"receive"];
    [Callback callWithArguments:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
 
    [PublicFun showProgressHUD:@"" view:self.view];
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"YunGuiBridge"]=self;
    JSValue *Callback = context[@"receive"];
    [Callback callWithArguments:nil];
    /**
    NSString *url = webView.request.URL.absoluteString;
    if ([@"https://qd.jiayou9.com/homework_mobile/#/student/homeworks?open=open" containsString:url]) {
        [self.webview1 removeFromSuperview];
        _webview1 = nil;
    }
    
    if ([@"https://qd.jiayou9.com/wrong_mobile/#/?open=open" containsString:url]) {
        [self.webview2 removeFromSuperview];
        _webview2 = nil;
    }
    
    if ([@"https://qd.jiayou9.com/note_app/#/?open=open" containsString:url]) {
        [self.webview3 removeFromSuperview];
        _webview3 = nil;
    }
    
    if ([@"https://qd.jiayou9.com/schedule_mobile/#/my/course?open=open" containsString:url]) {
        [self.webview4 removeFromSuperview];
        _webview4 = nil;
    }
     */
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *URL = request.URL;

    if ([URL.absoluteString hasPrefix:@"https://qd.jiayou9.com"] && [URL.absoluteString hasSuffix:@"open=open"]) {
        return YES;
    }

    BOOL isIntercepted = [[AlipaySDK defaultService] payInterceptorWithUrl:[request.URL absoluteString] fromScheme:@"ApliaySheme" callback:^(NSDictionary *result) {
    }];
    if (isIntercepted) {
        return NO;
    }
 
    NSLog(@"--------%@",URL);
    if  ([URL.absoluteString rangeOfString:@"open="].location != NSNotFound){
        if(![URL.absoluteString isEqualToString:lastRequestUrlStr]){
            if (![URL.absoluteString hasPrefix:@"https://qd.jiayou9.com"]) {
                
            }
            UIWebView *  nextwebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            nextwebView.delegate = self;
            nextwebView.allowsInlineMediaPlayback = YES;
            nextwebView.mediaPlaybackRequiresUserAction = NO;
            NSString *urlString = URL.absoluteString;
            urlString = [urlString stringByReplacingOccurrencesOfString:@"open://" withString:@"https://qd.jiayou9.com"];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            nextwebView.scrollView.bounces=NO;
            [nextwebView loadRequest:request];
            [self.view addSubview:nextwebView];
            lastRequestUrlStr = URL.absoluteString;
            lastWebview = nextwebView;
            [nextWebviewArr addObject:nextwebView];
            return NO;
        }else{
            return YES;
        }
    }
    if ([[request.URL absoluteString] containsString:@"weixin://"]) {
        BOOL wechat = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"weixin://"]];
        if(!wechat){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"检测到未安装微信客户端！" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            // 弹出对话框
            [self presentViewController:alert animated:true completion:nil];
        }
        
    }
    NSLog(@"--%@",URL);
    NSString *completeString = [URL absoluteString];
    
    //第一步:检测链接中的特殊字段
    NSString *needCheckStr = @"https://qd.jiayou9.com/preparation_pad/#/detail";
    NSRange jumpRange = [completeString rangeOfString:needCheckStr];
    if (jumpRange.location != NSNotFound) {
        if(isLoad == NO){
            isLoad = YES;
            nextwebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            nextwebView.delegate = self;
            nextwebView.mediaPlaybackRequiresUserAction = NO;
            nextwebView.backgroundColor = [UIColor whiteColor];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            NSLog(@"%@",URL);
            [nextwebView loadRequest:request];
            [self.view addSubview:nextwebView];
            return NO;
        }
    }
    
    [self webview1];
    [self webview2];
    [self webview3];
    [self webview4];

    
    return YES;
}

-(BOOL)toAddNextWebViewWithStr:(NSString * )completeString withStr:(NSString * )needCheckStr withUrl:(NSURL * )URL{
    NSRange jumpRange = [completeString rangeOfString:needCheckStr];
    if (jumpRange.location != NSNotFound) {
        if(isLoad == NO){
            isLoad = YES;
            nextwebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            nextwebView.delegate = self;
            nextwebView.scrollView.bounces=NO;
            nextwebView.mediaPlaybackRequiresUserAction = NO;
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            NSLog(@"%@",URL);
            [nextwebView loadRequest:request];
            [self.view addSubview:nextwebView];
            if([needCheckStr isEqualToString:@"qd.jiayou9.com/schedule_mobile/#/mall/video"]){
                [self hengFullScreenWithPlayerView];
            }
            return NO;
        }
    }
    return YES;
}

//横屏
- (void)hengFullScreenWithPlayerView{
    AppDelegate *appdelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    appdelegate.rotateDirection = 1;
    if ([UIDevice currentDevice].orientation != 1){
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait]
                                    forKey:@"orientation"];
        
    }
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight]
     
                                forKey:@"orientation"];
    
}

- (void)shuFullScreenWithPlayerView{
    AppDelegate *appdelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    appdelegate.rotateDirection = 0;
    if ([UIDevice currentDevice].orientation != 4){
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight]
                                    forKey:@"orientation"];
        
    }
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
}



- (void)rtcEngine:(AgoraRtcEngineKit *)engine
  didVideoEnabled:(BOOL)enabled byUid:(NSUInteger)uid{
}

- (void)loadAgoraKit {
  
}

- (void)startConnect{
    if (self.roomId != 0 && userId != 0 && _videoRoom == nil) {
        [self connectWebSocket];
    }
}

#pragma mark --------h5监听方法------------
- (id)sendMessage2Native:(NSString *)str1 :(NSString * )str2{
    //是否打开课件
    WEAKSELF
    if ([str1 isEqualToString:@"setLive"]) {
        NSDictionary * dic = [YGToolsObject dictionaryWithJsonString:str2];
        self.roomName = [dic objectForKey:@"channel"];
        if (self.roomName != nil && self.roomName.length > 0) {
            NSArray *a1 = [str2 componentsSeparatedByString:@"_"];
            self.roomId = [a1[1] integerValue];
        }
        userId = [[dic objectForKey:@"id"]longValue];
        [self startConnect];
        //老师
        if (userId  >= 1000000000) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadAgoraKit];
                BOOL videoStatus = false;
                if ([[dic objectForKey:@"video"]isEqualToString:@""]) {
                    videoStatus = YES;
                }else{
                    videoStatus = NO;
                }
                BOOL audioStatus = false;
                if ([[dic objectForKey:@"audio"]isEqualToString:@""]) {
                    audioStatus = YES;
                }else{
                    audioStatus = NO;
                }
                if (videoStatus) {
                    if (_videoRoom.videoMute) {
                        [self startVideo:true isMy:true];
                    }
                }else{
                    if (!_videoRoom.videoMute) {
                        [self startVideo:false isMy:true];

                    }
                }
                
                [self unjanusControlView:self.janusControlView didSetSilent:audioStatus];

            });
        }
        //学生
        else{
            BOOL videoStatus = false;
            if ([[dic objectForKey:@"video"]isEqualToString:@""]) {
                videoStatus = YES;
            }else{
                videoStatus = NO;
            }
            BOOL audioStatus = false;
            if ([[dic objectForKey:@"audio"]isEqualToString:@""]) {
                audioStatus = YES;
            }else{
                audioStatus = NO;
            }
            if (!videoStatus) {
                for (GJJanusListenRole *rrr in self.videoRoom.publishers) {
                    if ([rrr.display containsString: [NSString stringWithFormat:@"%ld",userId]]) {
                        self.myId = userId;
                        // 先播放视频
                        [_videoRoom usermuteVideo:false block:^(BOOL isSuccess, NSError *error) {
                            if (isSuccess == YES) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //当前直接关闭移除自身的播放视图
                                    [weakSelf.videoRoom startVideoListenRemote:rrr];
                                });
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                weakSelf.janusControlView.cameraButton.userInteractionEnabled = YES;
                            });
                        }];
                    }
                }
            }else{
               
            }
            
            if (!audioStatus) {
                [self unjanusControlView:self.janusControlView didSetSilent:false];
            }else{
                [self unjanusControlView:self.janusControlView didSetSilent:true];
            }
             
        }
        if (isFirstLive == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //            [self loadAgoraKit];
            });
        }
        isFirstLive = YES;
    }
    NSLog(@"---%@--%@",str1,str2);
    if ([str1 isEqualToString:@"setCW"]) {
        if ([str2 isEqualToString:@"1"]) {
            self.remoteContainerView.frame = CGRectMake(0, 0, 0, 0);
            isOpenKJ = YES;
        }else{
            [self.view addSubview:self.remoteContainerView];
            isOpenKJ = NO;
            [self updateInterfaceWithAnimation:NO];
        }
    }
    //获取亮度
    if([str1 isEqualToString:@"getLight"]){
        CGFloat value = [UIScreen mainScreen].brightness;
        return [NSString stringWithFormat:@"%f",value * 100];
    }
    //获取亮度
    if([str1 isEqualToString:@"alterShow"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.remoteContainerView removeFromSuperview];
            self.shareView.frame = CGRectMake(0, 0, 0, 0);
        });
    }
    //获取声音
    if([str1 isEqualToString:@"getAudio"]){
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        CGFloat volume = audioSession.outputVolume;
        NSLog(@"%f",volume);
        return [NSString stringWithFormat:@"%f",volume * 100];
    }
    //调节亮度
    if([str1 isEqualToString:@"setLight"]){
        float rate = [str2 floatValue]/100;
        [[UIScreen mainScreen] setBrightness:rate];
    }
    //获取版本号
    if([str1 isEqualToString:@"getSystem"]){
        return @"IOS";
    }
    //加入频道
    if([str1 isEqualToString:@"setChannel"]){
        self.roomName = str2;
        NSArray *a1 = [str2 componentsSeparatedByString:@"_"];
        self.roomId = [a1[1] integerValue];
        self.height = self.height + 80;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.remoteContainerView.frame = CGRectMake(50, 10, 150, self.height);
            [self.view addSubview:self.remoteContainerView];
        });
        //        [self updateInterfaceWithAnimation:NO];
    }
    //学生频道
    if([str1 isEqualToString:@"studentChannel"]){
     
    }
    //老师频道
    if([str1 isEqualToString:@"teacherChannel"]){
        NSDictionary * dic = [YGToolsObject dictionaryWithJsonString:str2];
        if ([[dic objectForKey:@"video"]containsString:@"video_PC"]) {
            self.clientRole = AgoraRtc_ClientRole_Audience;
            for (int i = 0; i < self.videoSessions.count; i ++) {
                VideoSession * nowSession = self.videoSessions[i];
                NSLog(@"userIduserId--%ld",userId);
                if (nowSession.uid == userId) {
                    [self.videoSessions removeObject:nowSession];
                }
            }
        }else{
            [self.videoSessions removeAllObjects];
            self.clientRole = AgoraRtc_ClientRole_Broadcaster;
            self.viewLayouter.roleIndex = 1;
        }
    }
    if([str1 isEqualToString:@"goToClass"]){
        
        classWebview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
        classWebview.delegate = self;
        classWebview.scrollView.bounces=NO;
        classWebview.allowsInlineMediaPlayback = YES;
        classWebview.mediaPlaybackRequiresUserAction = NO;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:str2]];
        [classWebview loadRequest:request];
        lastWebview = classWebview;
        [self.view addSubview:classWebview];
        NSString *needCheckStr = @"https://qd.jiayou9.com/record";
        NSRange jumpRange = [str2 rangeOfString:needCheckStr];
        if (jumpRange.location != NSNotFound) {
        }else{
            [self updateInterfaceWithAnimation:NO];
            [self.view addSubview:self.remoteContainerView];
        }
        [self hengFullScreenWithPlayerView];
        //        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
    //setChannel
    if([str1 isEqualToString:@"shareState"]){
        //shareModel = YES;
        NSDictionary * dic =
        [self dictionaryWithJsonString:str2];
        if([[dic objectForKey:@"speed"]intValue] == 1){
            shareId = [[dic objectForKey:@"streamId"]longValue];
            isShare = YES;
            [shareSessionsArr removeAllObjects];
            shareSession = [self videoSessionOfUid:shareId];
            [shareSessionsArr addObject:shareSession];
            [self updateInterfaceWithAnimation:NO];
        }else{
            shareId = [[dic objectForKey:@"streamId"]longValue];
            isShare = NO;
            [self updateInterfaceWithAnimation:NO];
        }
    }
    //截图
    if([str1 isEqualToString:@"capture"]){
        NSDictionary * picData = @{@"data":[YGToolsObject cutPicture:self.view]};
        JSContext *context = [classWebview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        //oc 调用 js
        NSString * picDataStr = [self.toolObject convertToJsonData:picData];
        NSString *textJS = [NSString stringWithFormat:@"jsGetCaptureFromNative(%@)",picDataStr];
        [context evaluateScript:textJS];
    }
    //返回上级
    if( [str1 isEqualToString:@"goback"] ||[str1 isEqualToString:@"goBack"]){
        isLoad = NO;
        lastRequestUrlStr = @"";
        isShare = NO;
        NSLog(@"nextWebviewArr--%@",nextWebviewArr);
        if(nextWebviewArr.count != 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIWebView * lastWebView =(UIWebView * )nextWebviewArr.lastObject;
                [lastWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
                [nextwebView removeFromSuperview];
                [nextWebviewArr.lastObject removeFromSuperview];
                [nextWebviewArr removeObject:nextWebviewArr.lastObject];
            });
        }
        lastRequestUrlStr = @"";
        isLoad = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [nextwebView removeFromSuperview];
        });
    }
    if([str1 isEqualToString:@"goback"] ||[str1 isEqualToString:@"goBack"]){
        lastRequestUrlStr = @"";
        isLoad = NO;
        isShare = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shuFullScreenWithPlayerView];
            [self.remoteContainerView removeFromSuperview];
            self.height = 0;
            if(self.videoSessions && self.videoSessions.count != 0){
                [self.videoSessions removeAllObjects];
            }
            if(shareSessionsArr && shareSessionsArr.count != 0){
                [shareSessionsArr removeAllObjects];
            }
            NSString * str2 = @"";
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:str2]];
            [classWebview loadRequest:request];
            classWebview.delegate = nil;
            [classWebview removeFromSuperview];
        });
    }
    //开始录音
    if([str1 isEqualToString:@"startRecord"]){
        [self.toolObject toStartRecordWithTimeStr:str2];
    }
    //结束录音
    if([str1 isEqualToString:@"stopRecord"]){
        return   [self.toolObject toStopRecord];
    }
    return nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
 
    [PublicFun hiddenProgressHUD];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}



//添加本地视频
- (void)addLocalSession:(long)localUid{
    [self videoSessionOfUid:localUid];
    [self updateInterfaceWithAnimation:YES];
}
#pragma mark------调节声音------

-(NSString * )cutPicture:(UIView * )v{
    CGSize s = v.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImageJPEGRepresentation(image, 0.1f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSLog(@"%@",encodedImageStr);
    return [NSString stringWithFormat:@"data:image/jpeg;base64,%@",encodedImageStr];
}

- (BOOL)isBroadcaster {
    return true;
}

- (VideoViewLayouter *)viewLayouter {
    if (!_viewLayouter) {
        _viewLayouter = [[VideoViewLayouter alloc] init];
        _viewLayouter.leftBodyCellDelegate = self;
    }
    return _viewLayouter;
}

- (void)setClientRole:(AgoraRtcClientRole)clientRole {
    
    if (self.isBroadcaster) {
        self.shouldEnhancer = YES;
    }
    [self updateButtonsVisiablity];
}

- (VideoSession *)fetchSessionOfUid:(NSUInteger)uid {
    for (VideoSession *session in self.videoSessions) {
        if (session.uid == uid) {
            return session;
        }
    }
    return nil;
}


- (VideoSession *) videoSessionOfUid:(NSUInteger)uid {
    VideoSession *fetchedSession = [self fetchSessionOfUid:uid];
    if (fetchedSession) {
        return fetchedSession;
    } else {
        VideoSession *newSession = [[VideoSession alloc] initWithUid:uid];
        [self.videoSessions addObject:newSession];
        [self updateInterfaceWithAnimation:YES];
        return newSession;
    }
}


- (void)setIsMuted:(BOOL)isMuted {
    _isMuted = isMuted;
    [self.audioMuteButton setImage:[UIImage imageNamed:(isMuted ? @"btn_mute_cancel" : @"btn_mute")] forState:UIControlStateNormal];
}

- (void)setVideoSessions:(NSMutableArray<VideoSession *> *)videoSessions {
    _videoSessions = videoSessions;
    if (self.remoteContainerView) {
        [self updateInterfaceWithAnimation:YES];
    }
}

- (void)setFullSession:(VideoSession *)fullSession {
    _fullSession = fullSession;
    if (self.remoteContainerView) {
        [self updateInterfaceWithAnimation:YES];
    }
}

- (void)updateButtonsVisiablity {
    [self.broadcastButton setImage:[UIImage imageNamed:self.isBroadcaster ? @"btn_join_cancel" : @"btn_join"] forState:UIControlStateNormal];
    for (UIButton *button in self.sessionButtons) {
        button.hidden = !self.isBroadcaster;
    }
}


- (void)setIdleTimerActive:(BOOL)active {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].idleTimerDisabled = !active;
    });
}

- (void)alertString:(NSString *)string {
    if (!string.length) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateInterfaceWithAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self updateInterface];
        }];
    } else {
        [self updateInterface];
    }
}
#pragma mark--------更新UI------
- (void)updateInterface {
    NSMutableArray *displaySessions = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.videoSessions.count; i ++) {
        VideoSession * nowSession = self.videoSessions[i];
        if (nowSession.uid >=  1000000000) {
            [displaySessions addObject:nowSession];
        }
    }
    for (int i = 0; i < self.videoSessions.count; i ++) {
        VideoSession * nowSession = self.videoSessions[i];
        if (nowSession.uid <=  1000000000) {
            [displaySessions addObject:nowSession];
        }
    }
    for (int i = 0; i  < displaySessions.count; i++) {
        VideoSession * nowSession = displaySessions[i];
        if (nowSession.uid >=  1000000000) {
            teacherUid = nowSession.uid;
        }
    }
    if (isShare == YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.shareView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.shareView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:self.shareView];
        });
        [self.viewLayouter layoutSessions:shareSessionsArr fullSession:self.fullSession inContainer:self.shareView withShare:isShare];
        for (int i = 0; i < shareSessionsArr.count; i ++) {
            VideoSession * nowSession = shareSessionsArr[i];
        }
    }else{
        
        for (int i = 0; i < displaySessions.count; i ++) {
            VideoSession * nowSession = displaySessions[i];
            if (nowSession.uid == 0 || nowSession.uid == shareId) {
                [displaySessions removeObject:nowSession];
            }
        }
         
        dispatch_async(dispatch_get_main_queue(), ^{
            self.shareView.frame = CGRectMake(0, 0, 0, 0);
            self.remoteContainerView.frame = CGRectMake(50, 10, 120, 80 * displaySessions.count);
        });
        [self.viewLayouter layoutSessions:displaySessions fullSession:self.fullSession inContainer:self.remoteContainerView withShare:isShare];
    }
    [self setStreamTypeForSessions:displaySessions fullSession:self.fullSession];
}

- (void)setStreamTypeForSessions:(NSArray<VideoSession *> *)sessions fullSession:(VideoSession *)fullSession {
    if (fullSession) {
        for (VideoSession *session in sessions) {
     
        }
    } else {
        for (VideoSession *session in sessions) {
        }
    }
}

#pragma mark personVideoViewDelegate
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
            if(![weakSelf.joinRoomTagArray containsObject:[NSString stringWithFormat:@"%ld",(long)[weakSelf.joinRoomPersonArray[i][@"id"]integerValue]]]){
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
        [self startVideo:self.cameraBtn.selected isMy:true];
    }
}




-(void)userClickShareScreenBtnWithPublisherId:(NSInteger)screenId nickName:(NSString *)nickName personView:(PersonVideoView *)personView{
    self.screenHeadLab.text = [NSString stringWithFormat:@"%@正在共享桌面",nickName];

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
//        self.localView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Screen_Width/4);
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
    
    [self addVideoWithUserId:clientID isMy:true];
    
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom*)plugin newRemoteAudioJoinWithID:(NSUInteger)clientID{
    
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin endMeeting:(BOOL)end{
    if (end == YES) {
        [self closeButtonAction];
    }
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin userReceiveMessageData:(NSDictionary *)data{
 
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin createRoomWithID:(NSUInteger)roomId{
    WEAKSELF
    [_videoRoom joinRoomWithRoomID:self.roomId userId:userId
                          userName:[NSString stringWithFormat:@"用户%ld",userId] completeCallback:^(BOOL isSuccess, NSError *error, long myId) {
                  
                 if(!error){
                     weakSelf.myId = myId;
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (self.janusControlView.cameraButton.selected == YES) {
                                        self.minePersonView.videoBtn.hidden = NO;
                                    }
                                    if (self.isAutoContact == YES) {
                                        [self.videoRoom userRecontactNetWoruWithAudio];
                                        if (self.janusControlView.silenceButton.selected == YES) {
                                            [self unjanusControlView:self.janusControlView didSetSilent:NO];
                                        }
                                        
                                        NSString *currentPlayId = [NSString stringWithFormat:@"%ld",(long)self.currentPlayId];
                                        if (currentPlayId.length > 1) {
                                            NSString *tagString = [currentPlayId substringWithRange:NSMakeRange(currentPlayId.length - 2, 2)];
                                            if (self.currentPersonView.tag == self.currentPlayId/100) {
                                                if ([tagString isEqualToString:@"02"]) {
//                                                    [weakSelf userClickVideoBtnWithPublisherId:weakSelf.currentPlayId nickName:weakSelf.currentPersonView.nickName.text personView:weakSelf.currentPersonView];
                                                    
                                                }else if ([tagString isEqualToString:@"03"]) {
//                                                    [weakSelf userClickShareScreenBtnWithPublisherId:weakSelf.currentPlayId nickName:weakSelf.currentPersonView.nickName.text personView:weakSelf.currentPersonView];
                                                }
                                            }
                                        }else if(self.currentPlayId == 0){
                                            if (self.janusControlView.cameraButton.selected == YES) {
                                                [self->_videoRoom usermuteVideo:NO block:^(BOOL isSuccess, NSError *error) {
                                                    
                                                }];
                                                
                                            }
//                                            [self userChangeMeetingPersonWithVideoPublisherId:weakSelf.currentPersonView.VideoId screenPublisherId:self.currentPersonView.screenId  nickName:self.currentPersonView.nickName.text personView:self.currentPersonView];
                                            
                                            self.isAutoContact = NO;
                                        }else if (self.currentPlayId == 1){
//                                            [self userChangeMeetingPersonWithVideoPublisherId:weakSelf.currentPersonView.VideoId screenPublisherId:self.currentPersonView.screenId  nickName:self.currentPersonView.nickName.text personView:self.currentPersonView];
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
//                [self userChangeMeetingPersonWithVideoPublisherId:self.minePersonView.VideoId screenPublisherId:self.minePersonView.screenId nickName:self.minePersonView.nickName.text personView:self.minePersonView];
                self.cacheId = personView.tag;
            }
            removeX = personView.frame.origin.x;
            [personView removeFromSuperview];
            [self.joinRoomTagArray removeObject:[NSString stringWithFormat:@"%ld",(long)personView.tag]];
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
    
    // 移除播放的视图
    KKRTCCanvas* canvas = [_videoRoom stopPrewViewWithUid:clientID];
    if (canvas) {
        [_remotes removeObjectForKey:@(clientID)];
    }
    // 移除当前视图的数组
    // TODO 这个后面需要测试 
    VideoSession *deleteSession;
    for (VideoSession *session in self.videoSessions) {
        if (session.uid == clientID) {
            deleteSession = session;
        }
    }
    if (deleteSession) {
        [self.videoSessions removeObject:deleteSession];
        [deleteSession.hostingView removeFromSuperview];
        [self updateInterfaceWithAnimation:YES];
    }
}


-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin addVideoListenerID:(NSInteger)clientID{
    for (PersonVideoView *view in self.videoScollerV.subviews) {
        if (view.tag == clientID/100) {
            NSString *idStr = [NSString stringWithFormat:@"%ld",(long)clientID];
            NSString *typeId = [idStr substringWithRange:NSMakeRange(idStr.length - 2, 2)];
            if ([typeId isEqualToString:@"02"]) {
                view.videoBtn.hidden = NO;
                view.VideoId = clientID;
                if (self.cacheId == view.tag && self.currentPersonView == view) {
//                    [self userChangeMeetingPersonWithVideoPublisherId:view.VideoId screenPublisherId:view.screenId nickName:view.nickName.text personView:view];
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
                NSString *idStr = [NSString stringWithFormat:@"%ld",(long)clientID];
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
//        self.localView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - Screen_Width/4);
        self.janusControlView.nickNameLab.text =@"";
        if (self.currentPlayId == clientID) {
            self.currentPlayId = 1;
        }
    });
    
}


-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin firstFrameDecodeWithSize:(CGSize)size uid:(NSUInteger)clientID{
#warning 先出来后消失
    // TODO 先去掉
  //  [MBManager hideAlert];
    /**
    NSString *idStr = [NSString stringWithFormat:@"%lu",(unsigned long)clientID];
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
     */
}

-(void)stopTimer{
    if(_timer){
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

-(void)GJJanusVideoRoom:(GJJanusVideoRoom *)plugin renderSizeChangeWithSize:(CGSize)size uid:(NSUInteger)clientID{
  //  [MBManager hideAlert];
    NSString *idStr = [NSString stringWithFormat:@"%lu",(unsigned long)clientID];
    NSString *typeId = [idStr substringWithRange:NSMakeRange(idStr.length - 2, 2)];
//    float AspectRatio =  size.width/size.height;
    #warning 先出来后消失

    /**
    if([typeId isEqualToString:@"02"]){
        self.localView.frame = CGRectMake((Screen_Width - (Screen_Height - Screen_Width/4) *AspectRatio)/2, 0, (Screen_Height - Screen_Width/4) *AspectRatio, (Screen_Height - Screen_Width/4));
    }
     */
    /**
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
     */
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
    
 
    
    NSString *idStr = [NSString stringWithFormat:@"%ld",(long)self.currentPlayId];
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
    

    return YES;
}


#pragma mark - UNJanusControlViewDelegate
-(void)unjanusControlViewShowSendMessageView:(UNJanusControlView *)janusControlView{
 
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
          // 加入语音流
                
       
        }
    }];
}

#warning 关键的第一步
- (void)startVideo:(BOOL)isOpen isMy:(BOOL)isMy{
    if(self.nowNetWorkStatus == 2){
        return;
    }
    if (![Utils checkCamera]) {
        [Utils showAlertWithTitle:@"温馨提示" message:@"请前往设置中打开Uworker的相机权限" actions:nil cancelTitle:@"确定"];
        return;
    }
    WEAKSELF
    [_videoRoom usermuteVideo:isOpen block:^(BOOL isSuccess, NSError *error) {
        if (isSuccess == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //当前直接关闭移除自身的播放视图 播放自己的视图
                [weakSelf addVideoWithUserId:self.myId isMy:isMy];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.janusControlView.cameraButton.userInteractionEnabled = YES;
        });
    }];
    
}

- (void)startMyVideo:(long)clientId{
    VideoSession *videoSession = [self videoSessionOfUid:clientId];
    
    if (_videoRoom.publlisher.ID == self.myId) {
        [_videoRoom startPrewViewWithCanvas:videoSession.canvas];

    }else{
        if ([[NSString stringWithFormat:@"%ld", clientId] containsString:[NSString stringWithFormat:@"%ld", self.myId]] && self.myId) {
            [_videoRoom startMyPrewViewWithCanvas:videoSession.canvas];

        }else{
            [_videoRoom startPrewViewWithCanvas:videoSession.canvas];
        }
    }

    
}

- (void)receiveVideoL:(long)userId{
    [_videoRoom userStartReceiveVideoStream:userId];
}


- (void)addVideoWithUserId:(long)userIdNew isMy:(BOOL)isMy{
    if (isMy) {
        [self startMyVideo:userIdNew];
    }else{
        [self receiveVideoL:userIdNew];
    }

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
                [self userClickShareScreenBtnWithPublisherId:view.screenId nickName:view.nickName.text personView:view];
                break;
                
            }
        }
    }
}

- (void)unjanusControlViewDidAddRole:(UNJanusControlView *)janusControlView{

    
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




- (void)voiceStateButtonAction{
    
}

- (void)selectedItemButton:(NSInteger)index{
    //    if (index <1000000000) {
    //    }else{
    //      [self.rtcEngine disableVideo];
    NSLog(@"执行了21122---%ld-",(long)index);
    for (int i = 0; i < self.videoSessions.count; i ++) {
        VideoSession * nowSession = self.videoSessions[i];
        NSLog(@"userIduserId--%ld",userId);
        if (nowSession.uid == index) {
            [self.videoSessions removeObject:nowSession];
        }
    }
    [self updateInterface];


    JSContext *context = [lastWebview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *indexStr = [NSString stringWithFormat:@"%ld", (long)index];
    NSString *userIdStr = [NSString stringWithFormat:@"%ld", userId];
    if ([indexStr containsString:userIdStr]) {
        // 关闭视频
        [self->_videoRoom usermuteVideo:YES block:^(BOOL isSuccess, NSError *error) {
                                
        }];
        NSString *textJS = [NSString stringWithFormat:@"jsGetLiveFromNative(%ld)",(long)userId];
        [context evaluateScript:textJS];
        
    }else{
        NSString *textJS = [NSString stringWithFormat:@"jsGetLiveFromNative(%ld)",(long)index];
        [context evaluateScript:textJS];
    }
}

@end
