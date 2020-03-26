//
//  PublicFun.m
//  ygxtClass
//
//  Created by baiping on 2020/3/10.
//  Copyright © 2020 kaili. All rights reserved.
//

#import "PublicFun.h"
#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "MBProgressHUD.h"
#import "MBProgressHUD+MJ.h"
#define HORIZONTAL_SPACE 30//水平间距
#define VERTICAL_SPACE 50//竖直间距
#define CG_TRANSFORM_ROTATION (M_PI_2 / 3)//旋转角度(正旋45度 || 反旋45度)
#define ADAPTIVE_PROPORTION SCREEN_WIDTH/ IP6_WIDTH
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define setFont(size)  [UIFont systemFontOfSize:size]
#define IP6_WIDTH 750.00

static MBProgressHUD* hud=nil;


@implementation PublicFun




+ (UIImage*)createImageWithColor:(UIColor
                                  *) color
{
    
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f
                           );
    
    UIGraphicsBeginImageContext(rect.size
                                );
    
    CGContextRef context = UIGraphicsGetCurrentContext
    ();
    
    CGContextSetFillColorWithColor(context, [color CGColor
                                             ]);
    
    CGContextFillRect
    (context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext
    ();
    
    UIGraphicsEndImageContext
    ();
    
    return theImage;
}
//按屏幕比例设置字体
+(UIFont *)setFont:(CGFloat)fontsize IsBold:(BOOL)isBold
{
    CGFloat scrW = [[UIApplication sharedApplication] statusBarFrame].size.width;
    //plus
    if (scrW > 410) {
        UIFont*font = isBold?[UIFont boldSystemFontOfSize:(fontsize * 2 * ADAPTIVE_PROPORTION * 0.82)]: [UIFont systemFontOfSize:(fontsize * 2 * ADAPTIVE_PROPORTION * 0.82)];
        return font;
        
    }
    // 6 7
    else if(scrW > 370 && scrW < 410)
    {
        UIFont*font = isBold?[UIFont boldSystemFontOfSize:(fontsize * 2 * ADAPTIVE_PROPORTION * 0.88)]:[UIFont systemFontOfSize:(fontsize * 2 * ADAPTIVE_PROPORTION * 0.88)];
        return font;
    }
    // 5 5s 4s
    else
    {
        UIFont*font = isBold?[UIFont boldSystemFontOfSize:(fontsize * 2 * ADAPTIVE_PROPORTION * 1)]:[UIFont systemFontOfSize:(fontsize * 2 * ADAPTIVE_PROPORTION * 1)];
        return font;
    }
}

#pragma mark nsdata转dic
+(NSDictionary *)getDicFromData:(NSData *)data
{
    //获得的json先转换成字符串
    NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    APPLog(@"NSData 转 receiveStr =%@",receiveStr);
    
    //字符串再生成NSData
    NSData * data1 = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //APPLog(@"NSData 转 NSDictionary =%@",dictionary);
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingMutableContainers error:nil];
    
    return dictionary;
}


#pragma mark 判断字符串格式大小（size）
+(CGSize)ComputeLabelSizeWithString:(NSString *)string
                               Font:(UIFont *)font
                           MaxWeith:(CGFloat) maxWeith
                        LineSpacing:(CGFloat) lineSpacing
{
    if (!string)
        string = @"";
    
    UILabel *testLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, maxWeith, 0)];
    testLabel.numberOfLines = 0;
    testLabel.font = font;
    
    NSMutableAttributedString *replyStr = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [replyStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    
    testLabel.attributedText = replyStr;
    [testLabel sizeToFit];
    
    return testLabel.frame.size;
}

//计算公式cell高度
+ (CGFloat)computeFormulaHeightWithFormulaStr:(NSString *)formula{
    
    CGFloat leftMar = [PublicFun ComputeLabelSizeWithString:@"公式：" Font:setFont(17) MaxWeith:SCREEN_WIDTH LineSpacing:0].width + 45 * ADAPTIVE_PROPORTION;
    CGFloat maxWidth = SCREEN_WIDTH - leftMar - 30 * ADAPTIVE_PROPORTION;
    
    CGFloat formulaHeight = [PublicFun ComputeLabelSizeWithString:formula Font:setFont(17) MaxWeith:maxWidth LineSpacing:0].height;
    
    return MAX(90 * ADAPTIVE_PROPORTION, formulaHeight + 50 * ADAPTIVE_PROPORTION);
}

#pragma mark - 拨打电话


//获得设备型号
+ (NSString *)getCurrentDeviceModel
{
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = (char*)malloc(size);
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPhone10,3"])   return @"iPhoneX";

    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

//#色值转uicolor
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    if ([stringToConvert hasPrefix:@"#"])
    {
        stringToConvert = [stringToConvert substringFromIndex:1];
    }
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    
    unsigned hexNum;
    
    if (![scanner scanHexInt:&hexNum])
    {
        return nil;
    }
    return [PublicFun colorWithRGBHex:hexNum];
}
+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
    int r = (hex >> 16) & 0xFF;
    
    int g = (hex >> 8) & 0xFF;
    
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (NSString *)typeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}


#pragma mark - ProgressHUD
+(void)showProgressHUD:(NSString*)title view:(UIView*)view{
    hud = [[MBProgressHUD alloc]initWithView:view];
    [view addSubview:hud];
    hud.labelText = title;
    hud.dimBackground = NO;
    [hud show:YES];
}


+(void)showProgressHUDWithWindow:(NSString*)title
{
    UIWindow*windows=[UIApplication sharedApplication].keyWindow;
    MBProgressHUD* hud = [[MBProgressHUD alloc]initWithView:windows];
    [windows addSubview:hud];
    hud.labelText = title;
    hud.dimBackground = NO;
    [hud show:YES];
}

+(void)showSuccessHUDWithWindow:(NSString*)title
{
    [MBProgressHUD showSuccess:title];
    
    //    UIWindow*windows=[UIApplication sharedApplication].keyWindow;
    //    MBProgressHUD* hud = [[MBProgressHUD alloc]initWithView:windows];
    //    [windows addSubview:hud];
    //    hud.dimBackground =dimBackground;
    //    hud.labelText = title;
    //    [hud show:YES];
}

+(void)MBProgressHUDShowTitleStr:(NSString *)titleStr
{
    [self hiddenProgressHUD];
    UIView *view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //    hud.backgroundColor = ColorFromRGB(0x343637, 0.5);
    hud.labelText = titleStr;
    hud.dimBackground = NO;
    // 设置图片
//    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", @"success.png"]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:1.2];
}


+(void)MBProgressHUDShowError:(NSString *)error{
    [PublicFun hiddenProgressHUD];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD showError:error];
    });
}

+(void)MBProgressHUDShowErrorLong:(NSString *)error{
    [PublicFun hiddenProgressHUD];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD showError:error];
    });
}


+(void)MBProgressHUDMessage:(NSString *)message{
    [PublicFun hiddenProgressHUD];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD showError:message];
    });
}



+(void)MBProgressHUDShowTitleStr:(NSString *)titleStr HiddenAfterDelay:(NSInteger)delayTime
{
    [self hiddenProgressHUD];
    UIView *view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //    hud.backgroundColor = ColorFromRGB(0x343637, 0.5);
    hud.labelText = titleStr;
    hud.dimBackground = NO;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", @"success.png"]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:delayTime];
}



+(void)hiddenProgressHUD
{
    [hud removeFromSuperview];
    UIWindow*windows=[UIApplication sharedApplication].keyWindow;
    for (UIView*view in [windows subviews]) {
        if ([view isKindOfClass:[MBProgressHUD class]]) {
            view.hidden=YES;
            [view removeFromSuperview];
        }
    }
}



//拨打电话


/**
 * 开始到结束的秒差(NSData)
 */
+ (int)dateTimeDifferenceWithStartTime:(NSDate *)startDate endTime:(NSDate *)endDate{
    NSTimeInterval start = [startDate timeIntervalSince1970] * 1;
    NSTimeInterval end = [endDate timeIntervalSince1970] * 1;
    NSTimeInterval value = end - start;
    
    return (int)value;
}

+ (NSString *)chatDateTimeStringWithTimeInterval:(double)timeInterval {
    NSDate *nowDate = [NSDate date];
    NSTimeInterval nowTimeInterval = [nowDate timeIntervalSince1970] * 1;
    
    if (timeInterval > 9999999999) {
        timeInterval /= 1000;
    }
    
    double secondNum = nowTimeInterval - timeInterval;
    
    if (secondNum < 5) {
        return @"刚刚";
    }
    else if(secondNum < 60)
    {
        return [NSString stringWithFormat:@"%d秒前",(int)secondNum];
    }
    else if(secondNum < (60 * 60))
    {
        return [NSString stringWithFormat:@"%d分钟前",(int)(secondNum / 60)];
    }
    else if(secondNum < (60 * 60 * 24))
    {
        return [NSString stringWithFormat:@"%d分钟前",(int)(secondNum / (60 * 60))];
    }
    else if(secondNum <= (60 * 60 * 24 * 3))
    {
        return [NSString stringWithFormat:@"%d天前",(int)(secondNum / (60 * 60 * 24))];
    }
    
    else {
        NSDate *date               = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *dateString       = [formatter stringFromDate: date];
        return dateString;
    }
}
/**
 * 时间表述(时间戳)
 */
+(NSString *)dateTimeStringWithTimeInterval:(double)timeInterval
{
    NSDate *nowDate = [NSDate date];
    NSTimeInterval nowTimeInterval = [nowDate timeIntervalSince1970] * 1;
    
    if (timeInterval > 9999999999) {
        timeInterval /= 1000;
    }
    
    double secondNum = nowTimeInterval - timeInterval;
    
    if (secondNum < 5) {
        return @"刚刚";
    }
    else if(secondNum < 60)
    {
        return [NSString stringWithFormat:@"%d秒前",(int)secondNum];
    }
    else if(secondNum < (60 * 60))
    {
        return [NSString stringWithFormat:@"%d分钟前",(int)(secondNum / 60)];
    }
    else if(secondNum < (60 * 60 * 24))
    {
        return [NSString stringWithFormat:@"%d分钟前",(int)(secondNum / (60 * 60))];
    }
    else if(secondNum < (60 * 60 * 24 * 7))
    {
        return [NSString stringWithFormat:@"%d天前",(int)(secondNum / (60 * 60 * 24))];
    }
    else if(secondNum < (60 * 60 * 24 * 30))
    {
        return [NSString stringWithFormat:@"%d周前",(int)(secondNum / (60 * 60 * 24 * 7))];
    }
    else if(secondNum < (60 * 60 * 24 * 365))
    {
        return [NSString stringWithFormat:@"%d个月前",(int)(secondNum / (60 * 60 * 24 * 30))];
    }
    else if(secondNum < (60 * 60 * 24 * 365 * 10))
    {
        return [NSString stringWithFormat:@"%d年前",(int)(secondNum / (60 * 60 * 24 * 365))];
    }
    else
        return @"很久很久以前";
}



/**
 * 时间表述(时间戳)
 */
+(NSString *)dateTimeStringWithTimeInterval:(double)timeInterval andTimeFormate:(NSDateFormatter *)timeFormate
{
    //    时间戳转时间的方法
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *confromTimespStr = [timeFormate stringFromDate:confromTimesp];
    return confromTimespStr;
}


//响应者链
+ (UIResponder *)resPonder:(UIView *)view  nextResponderWithClass:(Class)class {
    UIResponder *nextResponder = view;
    while (nextResponder) {
        nextResponder = nextResponder.nextResponder;
        if ([nextResponder isKindOfClass:class]) {
            return nextResponder;
        }
    }
    return nil;
}




//比较两个日期大小
+ (NSInteger)compareDate:(NSDate *)startDate withDate:(NSDate *)endDate{
    
    int comparisonResult;
    NSComparisonResult result = [startDate compare:endDate];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending:
            comparisonResult = 1;
            break;
            //date02比date01小
        case NSOrderedDescending:
            comparisonResult = -1;
            break;
            //date02=date01
        case NSOrderedSame:
            comparisonResult = 0;
            break;
        default:
            break;
    }
    return comparisonResult;
}



+ (UIImage *) getImageFromURL:(NSString *)fileURL
{
    
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}



+ (UIViewController *)getCurrentVC {
    
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    if (!window) {
        return nil;
    }
    UIView *tempView;
    for (UIView *subview in window.subviews) {
        if ([[subview.classForCoder description] isEqualToString:@"UILayoutContainerView"]) {
            tempView = subview;
            break;
        }
    }
    if (!tempView) {
        tempView = [window.subviews lastObject];
    }
    
    id nextResponder = [tempView nextResponder];
    while (![nextResponder isKindOfClass:[UIViewController class]] || [nextResponder isKindOfClass:[UINavigationController class]] || [nextResponder isKindOfClass:[UITabBarController class]]) {
        tempView =  [tempView.subviews firstObject];
        
        if (!tempView) {
            return nil;
        }
        nextResponder = [tempView nextResponder];
    }
    return  (UIViewController *)nextResponder;
}






//归档路径
+ (NSString *)getKeyedAchievePath {
    NSString *filepath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSString *path = [filepath stringByAppendingPathComponent:@"user.data"];
    return path;
}

//归档路径
+ (NSString *)getKeyedAchievePath:(NSString *)pathStr {
    NSString *filepath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSString *path = [filepath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data",pathStr]];
    return path;
}




//16进制颜色(html颜色值)字符串转为UIColor
+(UIColor *)getColorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha {
    //删除字符串中的空格
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor blackColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor blackColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
    
}

//默认alpha值为1
+ (UIColor *)getColorWithHexString:(NSString *)stringToConvert {
    return [self getColorWithHexString:stringToConvert alpha:1.0f];
}


// 根据图片url获取图片尺寸
+(CGSize)getImageSizeWithURL:(id)imageURL
{
    NSURL* URL = nil;
    if([imageURL isKindOfClass:[NSURL class]]){
        URL = imageURL;
    }
    if([imageURL isKindOfClass:[NSString class]]){
        URL = [NSURL URLWithString:imageURL];
    }
    if(URL == nil)
        return CGSizeZero;                  // url不正确返回CGSizeZero
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    NSString* pathExtendsion = [URL.pathExtension lowercaseString];
    
    CGSize size = CGSizeZero;
    if([pathExtendsion isEqualToString:@"png"]){
        size =  [self getPNGImageSizeWithRequest:request];
    }
    else if([pathExtendsion isEqual:@"gif"])
    {
        size =  [self getGIFImageSizeWithRequest:request];
    }
    else{
        size = [self getJPGImageSizeWithRequest:request];
    }
    if(CGSizeEqualToSize(CGSizeZero, size))                    // 如果获取文件头信息失败,发送异步请求请求原图
    {
        NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
        UIImage* image = [UIImage imageWithData:data];
        if(image)
        {
            size = image.size;
        }
    }
    return size;
}

//  获取PNG图片的大小
+(CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 8)
    {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
//  获取gif图片的大小
+(CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 4)
    {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
//  获取jpg图片的大小
+(CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }
    
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}




+ (UIViewController *)GetNextResponderWithClass:(Class)classStr andNaviVC:(UINavigationController *)naviVC{
    UIViewController *popVC = nil;
    for (UIViewController * nextVC in naviVC.childViewControllers) {
        if ([nextVC isKindOfClass:classStr]) {
            popVC = nextVC;
            break;
        }
    }
    return popVC;
}


+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    BOOL isToday = NO;
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *todayStr = [dateFormatter stringFromDate:currentDate];
    
    if ([todayStr isEqualToString:[dateFormatter stringFromDate:inputDate]]) {
        isToday = YES;
    }
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    NSString *weekString = [weekdays objectAtIndex:theComponents.weekday];
    
    return isToday ? @"今天": weekString;
}

+ (NSString *)AttendaceGetWeekDay: (NSDate*)inputDate {
    NSTimeInterval timeInterval = [inputDate timeIntervalSince1970] * 1;
    NSDate *nowDate = [NSDate date];
    NSTimeInterval nowTimeInterval = [nowDate timeIntervalSince1970] * 1;
    
    if (timeInterval > 9999999999) {
        timeInterval /= 1000;
    }
    
    double secondNum = nowTimeInterval - timeInterval;
    NSString *day = @"";
    NSInteger num = (int)(secondNum / (60 * 60 * 24));
    if (num == 0) {
        day = @"(今天)";
    }else if (num == 1) {
        day = @"(昨天)";
    }else if (num == 2) {
        day = @"(前天)";
    }
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    NSString *weekString = [weekdays objectAtIndex:theComponents.weekday];
    
    return [NSString stringWithFormat:@"%@%@",weekString,day];
    
}
+ (NSString *)preNextDate:(NSDate *)nowDate{
    
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:nowDate];
    
    NSInteger currentYear = (NSInteger)components.year;
    NSInteger currentMonth = (NSInteger)components.month;
    NSInteger currentDay =  (NSInteger)components.day;
    NSInteger currentHour = (NSInteger)components.hour;
    NSInteger currentMinite = (NSInteger)components.minute;
    //默认选择从下个小时整点开始
    NSString *preTimeStr = nil;
    if (currentHour >= 0 && currentHour < 23) {
        currentHour ++;
        currentMinite =0;
        preTimeStr = [NSString stringWithFormat:@"%zd-%.2zd-%.2zd %.2zd:%.2zd",currentYear,currentMonth,currentDay,currentHour,currentMinite];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    return preTimeStr;
}


+ (NSString *)getNowDateByFormatterString:(NSString *)formatterString{
    NSDate * nowDate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:formatterString];
    return  [[dateformatter stringFromDate:nowDate] copy];
}


+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController*)rootViewController
{
    if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else {
        return rootViewController;
    }
}




// 设置图片透明度
+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
// 生成一张文字背景水印图
+ (UIImage *)getWarterImageWithWidth: (CGFloat)width Height:(CGFloat)height andTitle: (NSString *)title andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor {
    
    //为了防止图片失真，绘制区域宽高和原始图片宽高一样
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    //sqrtLength：原始image的对角线length。在水印旋转矩阵中只要矩阵的宽高是原始image的对角线长度，无论旋转多少度都不会有空白。
    CGFloat sqrtLength = sqrt(width*width + height*height);
    //文字的属性
    NSDictionary *attr = @{
                           //设置字体大小
                           NSFontAttributeName: markFont,
                           //设置文字颜色
                           NSForegroundColorAttributeName :markColor,
                           };
    NSString* mark = title;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:mark attributes:attr];
    //绘制文字的宽高
    CGFloat strWidth = attrStr.size.width;
    CGFloat strHeight = attrStr.size.height;
    
    //开始旋转上下文矩阵，绘制水印文字
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //将绘制原点（0，0）调整到源image的中心
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(width/2, height/2));
    //以绘制原点为中心旋转
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(CG_TRANSFORM_ROTATION));
    //将绘制原点恢复初始值，保证当前context中心和源image的中心处在一个点(当前context已经旋转，所以绘制出的任何layer都是倾斜的)
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-width/2, -height/2));
    
    
    //计算需要绘制的列数和行数
    int horCount = sqrtLength / (strWidth + HORIZONTAL_SPACE) + 1;
    int verCount = sqrtLength / (strHeight + VERTICAL_SPACE) + 1;
    
    //此处计算出需要绘制水印文字的起始点，由于水印区域要大于图片区域所以起点在原有基础上移
    CGFloat orignX = -(sqrtLength-width)/2;
    CGFloat orignY = -(sqrtLength-height)/2;
    
    //在每列绘制时X坐标叠加
    CGFloat tempOrignX = orignX;
    //在每行绘制时Y坐标叠加
    CGFloat tempOrignY = orignY;
    for (int i = 0; i < horCount * verCount; i++) {
        [mark drawInRect:CGRectMake(tempOrignX, tempOrignY, strWidth, strHeight) withAttributes:attr];
        if (i % horCount == 0 && i != 0) {
            tempOrignX = orignX;
            tempOrignY += (strHeight + VERTICAL_SPACE);
        }else{
            tempOrignX += (strWidth + HORIZONTAL_SPACE);
        }
    }
    //根据上下文制作成图片
    UIImage *finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRestoreGState(context);
    
    return finalImg;
}
+ (UIImage *)getWarterImageWithWidth:(CGFloat)width Height:(CGFloat)height andTitle:(NSString *)title andMarkFont:(UIFont *)markFont andMarkColor:(UIColor *)markColor BackgroundColor:(UIColor *)backgroundColor {
    //为了防止图片失真，绘制区域宽高和原始图片宽高一样
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    //sqrtLength：原始image的对角线length。在水印旋转矩阵中只要矩阵的宽高是原始image的对角线长度，无论旋转多少度都不会有空白。
    CGFloat sqrtLength = sqrt(width*width + height*height);
    //文字的属性
    NSDictionary *attr = @{
                           //设置字体大小
                           NSFontAttributeName: markFont,
                           //设置文字颜色
                           NSForegroundColorAttributeName :markColor,
                           };
    NSString* mark = title;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:mark attributes:attr];
    //绘制文字的宽高
    CGFloat strWidth = attrStr.size.width;
    CGFloat strHeight = attrStr.size.height;
    
    //开始旋转上下文矩阵，绘制水印文字
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //将绘制原点（0，0）调整到源image的中心
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(width/2, height/2));
    //以绘制原点为中心旋转
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(CG_TRANSFORM_ROTATION));
    //将绘制原点恢复初始值，保证当前context中心和源image的中心处在一个点(当前context已经旋转，所以绘制出的任何layer都是倾斜的)
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-width/2, -height/2));
    
    
    //计算需要绘制的列数和行数
    int horCount = sqrtLength / (strWidth + HORIZONTAL_SPACE) + 1;
    int verCount = sqrtLength / (strHeight + VERTICAL_SPACE) + 1;
    
    //此处计算出需要绘制水印文字的起始点，由于水印区域要大于图片区域所以起点在原有基础上移
    CGFloat orignX = -(sqrtLength-width)/2;
    CGFloat orignY = -(sqrtLength-height)/2;
    
    //在每列绘制时X坐标叠加
    CGFloat tempOrignX = orignX;
    //在每行绘制时Y坐标叠加
    CGFloat tempOrignY = orignY;
    for (int i = 0; i < horCount * verCount; i++) {
        [mark drawInRect:CGRectMake(tempOrignX, tempOrignY, strWidth, strHeight) withAttributes:attr];
        if (i % horCount == 0 && i != 0) {
            tempOrignX = orignX;
            tempOrignY += (strHeight + VERTICAL_SPACE);
        }else{
            tempOrignX += (strWidth + HORIZONTAL_SPACE);
        }
    }
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
//    CGContextSetBlendMode(context, kCGBlendModeNormal);
//    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    //根据上下文制作成图片
    UIImage *finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRestoreGState(context);
    
    return finalImg;
}
@end
