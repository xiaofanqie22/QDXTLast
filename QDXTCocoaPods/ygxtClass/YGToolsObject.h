//
//  YGToolsObject.h
//  ygxtClass
//
//  Created by kaili on 2018/10/24.
//  Copyright © 2018年 kaili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "lame.h"

@interface YGToolsObject : NSObject<AVAudioRecorderDelegate>

@property(nonatomic,strong)NSURL * urlPlay;
@property(nonatomic,strong)AVAudioRecorder * recorder;
@property(nonatomic,strong)NSDictionary * postDic;
@property(nonatomic,strong)NSString * vioceStatus;
@property(nonatomic,strong)NSString * cafFilePath;
@property(nonatomic,strong)NSString * mp3FilePath;
//把json字符串转为字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

//把视图转为base64字符串
+(NSString * )cutPicture:(UIView * )v;

//获取当前的时间字符串
+(NSString *)getNowTimeTimestamp3;

//开始录音
-(void)toStartRecordWithTimeStr:(NSString * )timeStr;

//结束录音
-(NSString * )toStopRecord;

//字典转字符串
-(NSString *)convertToJsonData:(NSDictionary *)dict;

//获取当前时间戳
-(NSString *)getNowTimeTimestamp3;

//获取当前时间戳
-(NSMutableDictionary *)toGetAppInfo;

@end
