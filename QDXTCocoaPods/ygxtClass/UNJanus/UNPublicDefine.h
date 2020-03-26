//
//  UNPublicDefine.h
//  UniudcOA
//
//  Created by shanshan on 2018/6/13.
//  Copyright © 2018年 shanshan. All rights reserved.
//

#ifndef UNPublicDefine_h
#define UNPublicDefine_h

#define UNColorFromRGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define Main_Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width       [[UIScreen mainScreen] bounds].size.width



#define IOS10                   ( [[[UIDevice currentDevice] systemVersion] integerValue]==10?YES:NO)

#ifndef weakify
#if __has_feature(objc_arc)
#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")
#else
#define weakify ( x ) \
_Pragma("chang diagnostic push") \
_Pragma("chang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("chang diagnostic pop")
#endif
#endif

#ifndef strongify
#if __has_feature(objc_arc)
#define strongify( x ) \
_Pragma("chang diagnostic push") \
_Pragma("chang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("chang diagnostic pop")
#else
#define strongify( x ) \
_Pragma("chang diagnostic push") \
_Pragma("chang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("chang diagnostic pop")
#endif
#endif

#define Screen_Width  [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

#define NavBarBackColor [UIColor colorWithRed:234/255.0f green:237/255.0f blue:240/255.0f alpha:1]
//#define kSafeTopHeight           ((int)((Screen_Height/Screen_Width)*100) == 216) ? 44 : 0
//#define kSafeBottomHeight        ((int)((Screen_Height/Screen_Width)*100) == 216)? 34 : 0
#define RGBAColor(r,g,b,a) [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]

#define IphoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iPHoneXr
#define IphoneX_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhoneXs
#define IphoneX_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhoneXs Max
#define IphoneX_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

#define IphoneX_Later ((IphoneX==YES || IphoneX_Xs ==YES || IphoneX_Xs_Max== YES || IphoneX_Xr== YES) ? YES : NO)

#define kSafeBottomHeight (((IphoneX_Later) ? 34.f : 0.0f))
#define kSafeTopHeight (((IphoneX_Later) ? 44.0f :0.0f))
#define kStatusBarHeight (CGFloat)(IphoneX_Later?(44.0):(20.0))
#define kTopBarHeight          (((IphoneX_Later) ? 88.0f :64.0f))
#define kBottomBarHeight         (((IphoneX_Later) ? 94.0f :60))

#define GaodeMapIOSAK  @"cb56b3e75227a6fd4f8aac720e5dd7ba"
#define GaodeMapWEBAK  @"67081324286a72ef7b36ce650093b615"

#define BaiduMapIOSAK  @"YZfthglgWi6F2N96i8FGANXgfGzrNmNW"
#define BaiduMapWebAK  @"i0g0kHyWdGxaMygc4GBryDGK5hdZ479e"
#define OA_JG_APPKEY @"11716653043f717c69963466"

#define WeChat_AppSecret  @"4d8a26eebd21dde8d59169c383cfc259"
#define WeChat_AppId  @"wxd1de485fe305f969"
#define WX_ACCESS_TOKEN @"access_token"
#define WX_OPEN_ID @"openid"
#define WX_REFRESH_TOKEN @"refresh_token"
#define WX_BASE_URL @"https://api.weixin.qq.com/sns"

#define RecordsPerPage  15

#define GQ_CoreSD
//#define BASEURL @"http://180.101.204.69:81"
//#define BASEURL @"http://172.19.18.67:81"



#define ServiceDefaultUrl @"https://uworker.unicloud.com"
#define MeetingOrderServiceUrl @"https://uworker.unicloud.com/api/meeting"
#define WebRtcServiceUrl   @"https://webrtc.unicloud.com/coworker"

//#define ServiceDefaultUrl @"http://58.144.150.29:8848"
//#define ServiceDefaultUrl @"http://10.0.54.2:20080"
//#define MeetingOrderServiceUrl @"http://58.144.150.29:8848/api/meeting"


//#define BASEURL @"https://172.19.18.167:443"
//#define BASEURL @"http://220.194.70.104:81"

//#define BASEURL @"10.0.53.142"   //test environment

#define LockBaseUrl  @"https://iot.unicloud.com/office"
#define LockVedioBaseUrl @"https://iot.unicloud.com/office"

#define VERSIONCODE  ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])
#define OSVersion    ([[UIDevice currentDevice] systemVersion])
#define AppVersion  ([NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"])
#define KeyWindowSubView 10001
#define RequestTimeout 30

#define UNAcceptMailIMAPServer @"hwhzimap.qiye.163.com"
#define UNSendMailSMTPServer @"hwhzsmtp.qiye.163.com"
#define UNAcceptiCloudMailIMAPServer @"popmail.unicloud.com"
#define UNSendiCloudMailSMTPServer @"popmail.unicloud.com"
#define UNAcceptMailIMAPPort 993
#define UNSendMailSMTPPort 994
#define UNAcceptiCloudMailIMAPPort 993
#define UNSendiCloudMailSMTPPort 587
//#define BASEURL @"http://10.0.0.21:80"
#define UNLoginAccountKey @"Uniudc_Login_Account_Key"
#define UNLoginPasswordKey @"Uniudc_Login_Password_Key"
#define UNLoginTokenKey @"Uniudc_Login_Token_Key"
#define UNMailAccountKey @"Uniudc_Mail_Account_Key"
#define UNMailPasswordKey @"Uniudc_Mail_Password_key"
#define VideoMeetingMessage @"videoMeetingmessage"


#define UNResultCode @"success"
#define UNResultErrorMessage @"mesaage"
#define UNResultData @"data"
#define UNSuccessCode @"200"
#define UNTokenExpired @"208"

#define UNREPLYMAILSUCCESSNOTIFY @"Notify_Reply_Mail_Success"
#define UNRECEIVENEWMAIL @"Notify_Receive_New_Mail"

#define MsgSend @"发送"
#define MsgCancel @"取消"
#define MsgFrom @"发件人"
#define MsgOrigin @"分割线"
#define MsgSending @"发送中..."
#define MsgTo @"收件人"
#define MsgCc @"抄送"
#define MsgBcc @"密送"
#define MsgSubject @"主题"
#define MsgDate @"日期"
#define MsgReply @"回复"
#define MsgForward @"转发"
#define MsgDelete @"删除"
#define MsgMove @"移动"
#define MsgAttachment @"附件"
#define MsgYes @"Yes"
#define MsgNo @"No"
#define MsgLoading @"加载中"
#define MsgSendSuccess @"发送成功"
#define MsgSendFailed @"发送失败"

#define UNINBOXFOLDER @"INBOX"
#define UNINBOXFOLDERNAME @"收件箱"
#define UNSENDBOXFOLDER @"已发送"

#define UNWRITEMAILBOX @"sendBoxAtt"

#define UNCLOCKINDISTANCE 500

#define UNCHECKUPDATEAPP @"checkUpdateApp"

#define UNRELOADCARDLIST @"reloadCardList"
#define UNRELOADCARDDETAIL @"reloadCardDetail"
#define UNSTARTLISTENNET @"unStartListenNet"
#define UNDOWNLOADFIlELIST @"UNDownloadFileList"

#define UNUSERCARDSAVE @"userCardSave"
#define UNUSERHOMEPAGESEARCHRECORDS @"userHomePageSeaechRecords"

#define  UNUSERRELOADINVOICEFOLDERLIST      @"userReloadInvoiceFolferList"
#define  UNUSERRELOADINVOICELIST      @"userReloadInvoiceList"
#define  UNUSERRELOADHOMEDATE      @"userReloadHomeDate"
#define  UNRESELECTINVOICELIST      @"userReselectInvoiceList"
#define UNWORKFLOWUSERINFO @"UNWorkFlowUserInfo"

#define UNCUSTOMIZEURL @"UNCustomizeUrl"
#define UNCUSTOMIZEURLPORT @"UNCustomizeUrlPort"

#define UNWORKFLOWOPENURLINFO @"UNWorkFlowOpenUrlInfo"

#define UNLISTENNETWORK @"unListenNetwork"
#define UNRECONTACTETWORK @"unrecontactNetwork"


#define UNREOADALLWEBCONTENT @"unReloadAllWebContent" //刷新整个界面
#define UNUSERCARDEMAIL @"usercardmail"

#define UNCANCELDOWNLOAD @"cancelDownLoad"

#define UNWORKFLOWMYWAITNUM @"UNWorkFlowMyWaitNum"
#define UNIMUNREADNUM @"UNIMUnreadNum"

#define UNGROUPVIDEOMEETINGSTART @"ungropuvideomeetingstart"

#define MsgSendNoContact    @"收件人不存在"
#endif /* UNPublicDefine_h */

#ifdef DEBUG
#define DLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define DLog(format, ...)
#endif
