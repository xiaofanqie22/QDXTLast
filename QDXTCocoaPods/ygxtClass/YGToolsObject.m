//
//  YGToolsObject.m
//  ygxtClass
//
//  Created by kaili on 2018/10/24.
//  Copyright © 2018年 kaili. All rights reserved.
//

#import "YGToolsObject.h"
#import <sys/utsname.h>

@implementation YGToolsObject{
    NSString *  String;
}


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+(NSString * )cutPicture:(UIView * )v{
    CGSize s = v.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImageJPEGRepresentation(image, 0.1f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithFormat:@"data:image/jpeg;base64,%@",encodedImageStr];
}

+(NSString *)getNowTimeTimestamp3{
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
-(void)toStartRecordWithTimeStr:(NSString * )timeStr{
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
    //录音设置
    NSMutableDictionary * recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式
    [recordSetting  setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率（HZ）
    [recordSetting setValue:[NSNumber numberWithFloat:4000] forKey:AVSampleRateKey];
    //录音通道数
    [recordSetting setValue:[NSNumber  numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数
    [recordSetting  setValue:[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting  setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    NSDate * senddate = [NSDate date];
    
    NSDateFormatter * dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"yyyyMMddhhmmss"];
    
    String=[dateformatter stringFromDate:senddate];
    
   self.urlPlay =[NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",String]]];
    //self.cafFilePath
    
    NSError * error ;
    //初始化AVAudioRecorder
    self.recorder = [[AVAudioRecorder alloc]initWithURL:self.urlPlay settings:recordSetting error:&error];
    //开启音量监测
    self.recorder.meteringEnabled = YES;
    self.recorder.delegate = self;
    if(error){
        self.vioceStatus = @"2";
    }
    if([_recorder prepareToRecord]){
        //开始
        [_recorder record];
        self.vioceStatus = @"1";
    }
    float voiceSize = self.recorder.currentTime;
    if (voiceSize > [timeStr floatValue]){
        [self toStopRecord];
    }
    
}
//结束录音
-(NSString * )toStopRecord{
    float voiceSize = self.recorder.currentTime;
    NSLog(@"-----------%f",voiceSize);
    if (voiceSize < 0.15) {
        self.vioceStatus = @"3";
    }
    [self.recorder stop];
    return [self dataToBASE64];
    //return [self toChangeMP3];
   // return [self];
}

-(NSString * )toChangeMP3{
    NSString *cafFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",String]] ;//原caf文件位置
    //NSLog(@"")
    NSString *mp3FilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",String]];//转化过后的MP3文件位置
    @try {
        int read, write;
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        if(pcm == NULL)
        {
            NSLog(@"file not found");
        }
        else
        {
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header,跳过头文件 有的文件录制会有音爆，加上此句话去音爆
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, 44100);//11025.0
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            do {
                read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer, write, 1, mp3);
            } while (read != 0);
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
           // return YES;
        }
        //return NO;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        //return NO;
    }
    @finally {
        NSData *data= [NSData dataWithContentsOfFile:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",String]]];//此处可以打断点看下data文件的大小，如果太小，很可能是个空文件
        NSLog(@"---------%@",data);
      //return   [self dataToBASE64WithData:data];
        NSLog(@"执行完成");
    }
}

//- (NSString *)dataToBASE64WithData:(NSData * )mp3Data{
- (NSString *)dataToBASE64{
    NSData *mp3Data = [NSData dataWithContentsOfURL:self.urlPlay];
    NSString *_encodedImageStr = [mp3Data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSLog(@"_encodedImageStr_encodedImageStr%@",_encodedImageStr);
    self.postDic = @{@"data":_encodedImageStr,@"mine":@"caf",@"status":self.vioceStatus};
    return [self convertToJsonData:self.postDic];
}
//json转字符串
-(NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}

//获取当前时间戳
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

//获取当前时间戳
-(NSDictionary *)toGetAppInfo{
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary];
    //获取设备的型号
    NSString *deviceModel = [self judgeIphoneType];
    //获取系统版本号
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    //app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    //系统编号
    NSString *deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [infoDic setValue:@"YGXT-MOBILE" forKey:@"appType"];
    [infoDic setValue:app_Version forKey:@"appVer"];
    [infoDic setValue:deviceModel forKey:@"mno"];
    [infoDic setValue:@"iOS" forKey:@"osType"];
    [infoDic setValue:sysVersion forKey:@"osVer"];
    [infoDic setValue:deviceUUID forKey:@"sno"];
    [infoDic setValue:[NSNumber numberWithInteger:3] forKey:@"type"];
    return infoDic;
}


#pragma mark -- 判断手机型号
-(NSString*)judgeIphoneType {
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString * phoneType = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    // simulator 模拟器
    
    if ([phoneType isEqualToString:@"i386"])   return @"Simulator";
    
    if ([phoneType isEqualToString:@"x86_64"])  return @"Simulator";
    
    //  常用机型  不需要的可自行删除
    
    if([phoneType  isEqualToString:@"iPhone1,1"])  return @"iPhone 2G";
    
    if([phoneType  isEqualToString:@"iPhone1,2"])  return @"iPhone 3G";
    
    if([phoneType  isEqualToString:@"iPhone2,1"])  return @"iPhone 3GS";
    
    if([phoneType  isEqualToString:@"iPhone3,1"])  return @"iPhone 4";
    
    if([phoneType  isEqualToString:@"iPhone3,2"])  return @"iPhone 4";
    
    if([phoneType  isEqualToString:@"iPhone3,3"])  return @"iPhone 4";
    
    if([phoneType  isEqualToString:@"iPhone4,1"])  return @"iPhone 4S";
    
    if([phoneType  isEqualToString:@"iPhone5,1"])  return @"iPhone 5";
    
    if([phoneType  isEqualToString:@"iPhone5,2"])  return @"iPhone 5";
    
    if([phoneType  isEqualToString:@"iPhone5,3"])  return @"iPhone 5c";
    
    if([phoneType  isEqualToString:@"iPhone5,4"])  return @"iPhone 5c";
    
    if([phoneType  isEqualToString:@"iPhone6,1"])  return @"iPhone 5s";
    
    if([phoneType  isEqualToString:@"iPhone6,2"])  return @"iPhone 5s";
    
    if([phoneType  isEqualToString:@"iPhone7,1"])  return @"iPhone 6 Plus";
    
    if([phoneType  isEqualToString:@"iPhone7,2"])  return @"iPhone 6";
    
    if([phoneType  isEqualToString:@"iPhone8,1"])  return @"iPhone 6s";
    
    if([phoneType  isEqualToString:@"iPhone8,2"])  return @"iPhone 6s Plus";
    
    if([phoneType  isEqualToString:@"iPhone8,4"])  return @"iPhone SE";
    
    if([phoneType  isEqualToString:@"iPhone9,1"])  return @"iPhone 7";
    
    if([phoneType  isEqualToString:@"iPhone9,2"])  return @"iPhone 7 Plus";
    
    if([phoneType  isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    
    if([phoneType  isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    
    if([phoneType  isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    
    if([phoneType  isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    
    if([phoneType  isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    
    if([phoneType  isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if([phoneType  isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    
    if([phoneType  isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    
    if([phoneType  isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    
    if([phoneType  isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    
    return phoneType;
    
}

@end
