//
//  Utils.m
//  UniudcOA
//
//  Created by Chen Jimmy on 2018/6/20.
//  Copyright © 2018年 shanshan. All rights reserved.
//

#import "Utils.h"
#include <sys/sysctl.h>
#include "UNPublicDefine.h"




#define yearTag @"(-|.|/|年)"

#define monthTag @"(-|.|/|月)"

#define dayTag @"(号|日)"
#define yearMatchs @"([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})"

#define bigMonthMatchs [NSString stringWithFormat: @"(((0[13578]|1[02])%@((0[1-9]|[12][0-9]|3[01]|([1-9]|[12][0-9]|3[01])))|([13578]|1[02])%@((0[1-9]|[12][0-9]|3[01]|([1-9]|[12][0-9]|3[01]))))",monthTag,monthTag]

#define smallMonthMatchs [NSString stringWithFormat:@"(((0[469]|11)|([469]|11))%@(((0[1-9]|[12][0-9]|30)|([1-9]|[12][0-9]|30))))|((02|2)%@((0[1-9]|[1][0-9]|2[0-9])|([1-9]|[1][0-9]|2[0-9])))))",monthTag,monthTag]

#define leapYearMatch @"((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))-(02|2)-29"



@implementation Utils

+ (UIWindow *)getTopWindow {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    return window;
}

+ (NSString *)chineseToPinYin:(NSString *)chinese {
    if (chinese == nil) {
        return nil;
    }
    NSString *pinYin = nil;
    NSMutableString *mutableString = [NSMutableString stringWithString:chinese];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    mutableString = (NSMutableString *)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    if (mutableString.length >0) {
        pinYin = [mutableString stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return pinYin;
}

+ (BOOL)isEmptyString:(NSString *)string {
    if (string == nil) {
        return YES;
    }
    NSString *toString = [Utils trimString:string];
    if ([toString isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

+ (NSString *)trimString:(NSString *)string {
    if (string == nil) {
        return @"";
    }
    NSString *trim = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trim;
}

+ (BOOL)isValidNumberChangeCharactersInRange:(NSRange)range original:(NSString *)original replacementString:(NSString *)string remain:(NSInteger)remain {
    // remain为小数位数
    NSScanner      *scanner    = [NSScanner scannerWithString:string];
    NSCharacterSet *numbers;
    NSRange         pointRange = [original rangeOfString:@"."];
    
    if ( (pointRange.length > 0) && (pointRange.location < range.location  || pointRange.location > range.location + range.length) )
    {
        numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    }
    else
    {
        numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    }
    
    if ( [original isEqualToString:@""] && [string isEqualToString:@"."] )
    {
        return NO;
    }
    
    NSString *tempStr = [original stringByAppendingString:string];
    NSUInteger strlen = [tempStr length];
    if(pointRange.length > 0 && pointRange.location > 0){ //判断输入框内是否含有“.”。
        if([string isEqualToString:@"."]){ //当输入框内已经含有“.”时，如果再输入“.”则被视为无效。
            return NO;
        }
        if(strlen > 0 && (strlen - pointRange.location) > remain+1){ //当输入框内已经含有“.”，当字符串长度减去小数点前面的字符串长度大于需要要保留的小数点位数，则视当次输入无效。
            return NO;
        }
    }
    
    NSString *buffer;
    if ( ![scanner scanCharactersFromSet:numbers intoString:&buffer] && ([string length] != 0) )
    {
        return NO;
    }
    
    NSString *stringAfterChange = [original stringByReplacingCharactersInRange:range withString:string];
    if ([stringAfterChange hasPrefix:@" "]) {
        return NO;
    }
    return YES;
}

+ (NSString *)isValidPassword:(NSString *)password {
    BOOL result = NO;
    if ([password length] >= 6 && [password length] <= 18){
        //数字条件
        NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
        //符合数字条件的有几个
        NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:password
                                                                           options:NSMatchingReportProgress
                                                                             range:NSMakeRange(0, password.length)];
        
        //英文字条件
        NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:password
                                                                                 options:NSMatchingReportProgress
                                                                                   range:NSMakeRange(0, password.length)];
        
        if(tNumMatchCount >= 1 && tLetterMatchCount >= 1){
            result = YES;
        }
        
    }
    if (!result) {
        return @"密码长度为6-18位,并包含字母和数字";
    }
    return nil;
}

+ (UIImage*)createImageWithColor: (UIColor*) color height:(CGFloat)height
{
    if (height <= 1) {
        height = 1;
    }
    CGRect rect=CGRectMake(0,0, 1, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage*)imageCompressWithSimple:(UIImage*)image scaledToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -排序
+ (NSArray *)sortAlphaKeys:(NSArray *)keys {
    NSArray *sortKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableArray *finalKeys = [NSMutableArray arrayWithArray:sortKeys];
    if ([finalKeys containsObject:@"#"]) {
        [finalKeys removeObject:@"#"];
        [finalKeys addObject:@"#"];
    }
    return [NSArray arrayWithArray:finalKeys];
}

#pragma mark - 电话
+ (void)call:(NSString *)phoneNumber
{
    NSString * str=[[NSString alloc] initWithFormat:@"tel:%@",phoneNumber];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
        UIAlertAction *ensure = [UIAlertAction actionWithTitle:@"呼叫"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                                                       }];
        [Utils showAlertWithTitle:phoneNumber message:nil actions:@[ensure] cancelTitle:@"取消"];
    }
}

+ (void)openURL:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                    if (!success) {
                       // [MBManager showBriefAlert:@"网址链接错误"];
                    }
                }];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }else{
          // [MBManager showBriefAlert:@"网址链接错误"];
        }
    }
}

+ (NSString *)getCompleteWebsite:(NSString *)urlStr{
    NSString *returnUrlStr = nil;
    NSString *scheme = nil;
    urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (urlStr != nil) && (urlStr.length != 0) ) {
        NSRange  urlRange = [urlStr rangeOfString:@"://"];
        if (urlRange.location == NSNotFound) {
            returnUrlStr = [NSString stringWithFormat:@"http://%@", urlStr];
        } else {
            scheme = [urlStr substringWithRange:NSMakeRange(0, urlRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                returnUrlStr = urlStr;
            }
        }
    }
    return returnUrlStr;
}

+ (NSArray<NSTextCheckingResult *> *)linkRanges:(NSString *)string {
    NSError *err = nil;
    
    NSString *urlRegulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&;*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&;*+?:_/=<>]*)?)";
    NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:urlRegulaStr
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&err];
    NSString  *ipRegulaStr =@"((http[s]{0,1}|ftp):\\/\\/[\\w\\-]+(\\.[\\w\\-]+)+([\\w\\-\\.,@?^=%&;:\\/~\\+#]*[\\w\\-\\@?^=%&;\\/~\\+#])?$)";
    NSRegularExpression *ipRegex = [NSRegularExpression regularExpressionWithPattern:ipRegulaStr
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&err];
    
    /** 时间*/
    
    NSString *time1 = [NSString stringWithFormat:@"((%@%@(%@|%@|%@))%@)",yearMatchs,yearTag,bigMonthMatchs,smallMonthMatchs,leapYearMatch,dayTag];
    NSRegularExpression *timeRegex1 = [NSRegularExpression regularExpressionWithPattern:time1
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&err];
    
    NSString  *time2 =[NSString stringWithFormat:@"(%@%@(%@|%@|%@))",yearMatchs,yearTag,bigMonthMatchs,smallMonthMatchs,leapYearMatch];
    NSRegularExpression *timeRegex2 = [NSRegularExpression regularExpressionWithPattern:time2
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&err];
    
    NSString *time3 = [NSString stringWithFormat:@"(((%@|%@)%@)|%@%@)",bigMonthMatchs,smallMonthMatchs,dayTag,leapYearMatch,dayTag];
    NSRegularExpression *timeRegex3 = [NSRegularExpression regularExpressionWithPattern:time3
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&err];
    
    if (urlRegex && ipRegex && timeRegex1&& timeRegex2  && timeRegex3  ){
        NSMutableArray *matches = [NSMutableArray array];
        
        // 合并
        NSArray *urlMatches = [urlRegex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
        if (urlMatches.count > 0) {
            NSMutableArray *strArray = [NSMutableArray array];
            for (NSTextCheckingResult *match in urlMatches) {
                NSString *str = [string substringWithRange:match.range];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:str forKey:@"text"];
                [dic setObject:@"url" forKey:@"type"];
                [strArray addObject:dic];
                
            }
            [matches addObjectsFromArray:strArray];
            for (NSDictionary * dic in strArray) {
                
                string =  [string stringByReplacingOccurrencesOfString:dic[@"text"] withString:@""];
            }
            
        }
        NSArray *ipMatches = [ipRegex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
        
        if (ipMatches.count > 0) {
            NSMutableArray *strArray = [NSMutableArray array];
            for (NSTextCheckingResult *match in ipMatches) {
                NSString *str = [string substringWithRange:match.range];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:str forKey:@"text"];
                [dic setObject:@"url" forKey:@"type"];
                [strArray addObject:dic];
                
            }
            [matches addObjectsFromArray:strArray];
            for (NSDictionary * dic in strArray) {
                
                string =  [string stringByReplacingOccurrencesOfString:dic[@"text"] withString:@""];
            }
            
        }
        
        NSArray *timeMatches1 = [timeRegex1 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
        if (timeMatches1.count > 0) {
            if([string containsString:@"."]||[string containsString:@"/"]||[string containsString:@"年"]||[string containsString:@"月"]||[string containsString:@"-"]||[string containsString:@"号"]||[string containsString:@"日"]){
                NSMutableArray *strArray = [NSMutableArray array];
                for (NSTextCheckingResult *match in timeMatches1) {
                    NSString *str = [string substringWithRange:match.range];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:str forKey:@"text"];
                    [dic setObject:@"date" forKey:@"type"];
                    [strArray addObject:dic];
                    
                }
                [matches addObjectsFromArray:strArray];
                for (NSDictionary * dic in strArray) {
                    
                    string =  [string stringByReplacingOccurrencesOfString:dic[@"text"] withString:@""];
                }
            }
            
            
        }
        
        NSArray *timeMatches2 = [timeRegex2 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
        if (timeMatches2.count > 0) {
            if([string containsString:@"."]||[string containsString:@"/"]||[string containsString:@"年"]||[string containsString:@"月"]||[string containsString:@"-"]||[string containsString:@"号"]||[string containsString:@"日"]){
                NSMutableArray *strArray = [NSMutableArray array];
                for (NSTextCheckingResult *match in timeMatches2) {
                    NSString *str = [string substringWithRange:match.range];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:str forKey:@"text"];
                    [dic setObject:@"date" forKey:@"type"];
                    [strArray addObject:dic];
                    
                }
                [matches addObjectsFromArray:strArray];
                for (NSDictionary * dic in strArray) {
                    
                    string =  [string stringByReplacingOccurrencesOfString:dic[@"text"] withString:@""];
                }
            }
        }
        
        NSArray *timeMatches3 = [timeRegex3 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
        
        if (timeMatches3.count > 0) {
            if([string containsString:@"."]||[string containsString:@"/"]||[string containsString:@"年"]||[string containsString:@"月"]||[string containsString:@"-"]||[string containsString:@"号"]||[string containsString:@"日"]){
                NSMutableArray *strArray = [NSMutableArray array];
                for (NSTextCheckingResult *match in timeMatches3) {
                    NSString *str = [string substringWithRange:match.range];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:str forKey:@"text"];
                    [dic setObject:@"date" forKey:@"type"];
                    [strArray addObject:dic];
                    
                }
                [matches addObjectsFromArray:strArray];
                for (NSDictionary * dic in strArray) {
                    
                    string =  [string stringByReplacingOccurrencesOfString:dic[@"text"] withString:@""];
                }
            }
        }
        
        //         NSArray *timeMatches4 = [timeRegex4 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
        //
        //        if (timeMatches4.count > 0) {
        //            NSMutableArray *strArray = [NSMutableArray array];
        //            for (NSTextCheckingResult *match in timeMatches4) {
        //                NSString *str = [string substringWithRange:match.range];
        //                [strArray addObject:str];
        //            }
        //              [matches addObjectsFromArray:strArray];
        //            for (NSString * str in strArray) {
        //                string =  [string stringByReplacingOccurrencesOfString:str withString:@""];
        //            }
        //
        //        }
        /*
         NSArray *timeMatches5 = [timeRegex5 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         
         NSArray *timeMatches6 = [timeRegex6 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         
         NSArray *timeMatches7 = [timeRegex7 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         
         NSArray *timeMatches8 = [timeRegex8 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         
         NSArray *timeMatches9 = [timeRegex9 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         
         NSArray *timeMatches10 = [timeRegex10 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         
         NSArray *timeMatches11 = [timeRegex11 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         
         NSArray *timeMatches12 = [timeRegex12 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         
         NSArray *timeMatches13 = [timeRegex13 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         
         NSArray *timeMatches14 = [timeRegex14 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         
         NSArray *timeMatches15 = [timeRegex15 matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
         */
        //        NSMutableArray *matches = [NSMutableArray arrayWithArray:urlMatches];
        //        [matches addObjectsFromArray:ipMatches];
        //
        //        [matches addObjectsFromArray:timeMatches1];
        //       [matches addObjectsFromArray:timeMatches2];
        //        [matches addObjectsFromArray:timeMatches3];
        //        [matches addObjectsFromArray:timeMatches4];
        //        [matches addObjectsFromArray:timeMatches5];
        //        [matches addObjectsFromArray:timeMatches6];
        //        [matches addObjectsFromArray:timeMatches7];
        //        [matches addObjectsFromArray:timeMatches8];
        //        [matches addObjectsFromArray:timeMatches9];
        //        [matches addObjectsFromArray:timeMatches10];
        //        [matches addObjectsFromArray:timeMatches11];
        //        [matches addObjectsFromArray:timeMatches12];
        //        [matches addObjectsFromArray:timeMatches13];
        //        [matches addObjectsFromArray:timeMatches14];
        //        [matches addObjectsFromArray:timeMatches15];
        
        
        
        return [NSArray arrayWithArray:matches];
    }
    //    if (urlRegex) {
    //        //url
    //        NSArray *urlMatches = [urlRegex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    //        return urlMatches;
    //    }
    //    if (ipRegex) {
    //        //ip
    //        NSArray *ipMatches = [ipRegex matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    //        return ipMatches;
    //    }
    return nil;
}

+ (UIViewController *)getViewController:(UIView *)view
{
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - 全局alert 显示与隐藏
+ (UIViewController *)getCurrentDisplayController {
    UIWindow *window = [Utils getTopWindow];
    UIViewController *resultVC;
    resultVC = [Utils _topViewController:[window rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [Utils _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if (vc.presentedViewController && ![vc.presentedViewController isKindOfClass:[UIAlertController class]]) {
        // 视图是被presented出来的
        vc = vc.presentedViewController;
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg actions:(NSArray *)actions cancelTitle:(NSString *)cancelTitle {
    NSString *finalTitle = title;
    if (finalTitle == nil) {
        finalTitle = @"提示";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:finalTitle message:msg preferredStyle:UIAlertControllerStyleAlert];
    if (actions != nil && [actions count] > 0) {
        for (UIAlertAction *action in actions) {
            [alert addAction:action];
        }
    }
    if (cancelTitle != nil) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];
    }
    
    UIViewController *topController = [Utils getCurrentDisplayController];
    if (![Utils isAlertShow]) {
        [topController presentViewController:alert animated:YES completion:nil];
    }
}

+ (BOOL)isAlertShow {
    UIViewController *topController = [Utils getCurrentDisplayController];
    if (topController.presentedViewController && [topController.presentedViewController isKindOfClass:[UIAlertController class]]) {
        return YES;
    }
    return NO;
    
}

+ (void)hideAlert {
    UIViewController *topController = [Utils getCurrentDisplayController];
    if (topController) {
        if ([topController isKindOfClass:[UIAlertController class]]) {
            UIAlertController *alert = (UIAlertController *)topController;
            [alert dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
#pragma 获取文件大小
+ (CGFloat) getFileSize:(NSString *)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }
    return filesize;
}

+(UILabel *)creatLabeWithTextColor:(UIColor *)color fontSize:(NSInteger )fontSize textAlignment:(NSTextAlignment )textAlignment{
    UILabel *label = [[UILabel alloc] init];
    if (color) {
        label.textColor = color;
    }
    if (fontSize > 0) {
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    if (textAlignment) {
        label.textAlignment = textAlignment;
    }
    
    return label;
}


+ (NSString *)getDeviceName
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char machine[size];
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    NSLog(@"model : %@",platform);
    if ([platform isEqualToString:@"iPhone1,1"]) {
        platform = @"iPhone";
    } else if ([platform isEqualToString:@"iPhone1,2"]) {
        platform = @"iPhone3G";
    } else if ([platform isEqualToString:@"iPhone2,1"]) {
        platform = @"iPhone3GS";
    } else if ([platform isEqualToString:@"iPhone3,1"] || [platform isEqualToString:@"iPhone3,2"]||[platform isEqualToString:@"iPhone3,3"]) {
        platform = @"iPhone4";
    } else if ([platform isEqualToString:@"iPhone4,1"]) {
        platform = @"iPhone4S";
    } else if ([platform isEqualToString:@"iPhone5,1"] || [platform isEqualToString:@"iPhone5,2"]) {
        platform = @"iPhone5";
    }else if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"]) {
        platform = @"iPhone5C";
    }else if ([platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"]) {
        platform = @"iPhone5S";
    }else if ([platform isEqualToString:@"iPhone7,1"]) {
        platform = @"iPhone6Plus";
    }else if ([platform isEqualToString:@"iPhone7,2"]) {
        platform = @"iPhone6";
    }else if ([platform isEqualToString:@"iPhone8,1"]) {
        platform = @"iPhone6s";
    }else if ([platform isEqualToString:@"iPhone8,2"]) {
        platform = @"iPhone6sPlus";
    }else if ([platform isEqualToString:@"iPhone8,4"]) {
        platform = @"iPhoneSE";
    }else if ([platform isEqualToString:@"iPhone9,1"] || [platform isEqualToString:@"iPhone9,3"]) {
        platform = @"iPhone7";
    }else if ([platform isEqualToString:@"iPhone9,2"] || [platform isEqualToString:@"iPhone9,4"]) {
        platform = @"iPhone7Plus";
    }else if ([platform isEqualToString:@"iPhone10,1"] || [platform isEqualToString:@"iPhone10,4"]) {
        platform = @"iPhone8";
    }else if ([platform isEqualToString:@"iPhone10,2"] || [platform isEqualToString:@"iPhone10,4"]) {
        platform = @"iPhone8Plus";
    }else if ([platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"]) {
        platform = @"iPhoneX";
    }else if ([platform isEqualToString:@"iPhone11,8"] ){
        return @"iPhone XR";
    }else if ([platform isEqualToString:@"iPhone11,2"] ){
        return@"iPhone XS";
    }else if ([platform isEqualToString:@"iPhone11,4"] || [platform isEqualToString:@"iPhone11,6"]){
        return@"iPhone XS Max";
    }else if ([platform isEqualToString:@"iPod4,1"]) {
        platform = @"iPod touch4";
    }else if ([platform isEqualToString:@"iPod5,1"]) {
        platform = @"iPod touch5";
    }else if ([platform isEqualToString:@"iPod3,1"]) {
        platform = @"iPod touch3";
    }else if ([platform isEqualToString:@"iPod2,1"]) {
        platform = @"iPod touch2";
    }else if ([platform isEqualToString:@"iPod1,1"]) {
        platform = @"iPod touch";
    } else if ([platform isEqualToString:@"iPad3,2"] || [platform isEqualToString:@"iPad3,1"]) {
        platform = @"iPad3";
    } else if ([platform isEqualToString:@"iPad2,2"] || [platform isEqualToString:@"iPad2,1"] || [platform isEqualToString:@"iPad2,3"] || [platform isEqualToString:@"iPad2,4"]) {
        platform = @"iPad2";
    }else if ([platform isEqualToString:@"iPad1,1"]) {
        platform = @"iPad1";
    }else if ([platform isEqualToString:@"iPad2,5"] || [platform isEqualToString:@"iPad2,6"] || [platform isEqualToString:@"iPad2,7"]) {
        platform = @"ipad mini";
    } else if ([platform isEqualToString:@"iPad3,3"] || [platform isEqualToString:@"iPad3,4"] || [platform isEqualToString:@"iPad3,5"] || [platform isEqualToString:@"iPad3,6"]) {
        platform = @"ipad3";
    } else if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"] || [platform isEqualToString:@"x86_32"]) {
        platform = @"Simulator";
    } else {
        platform = [UIDevice currentDevice].model;
    }
    return platform;
}

// 普通的获取UUID的方法
+ (NSString *)getUUID {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    return result;
}



+ (NSInteger)getToInt:(NSString *)nameText
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [nameText dataUsingEncoding:enc];
    return [da length];
}

+ (BOOL)isValidateTelephone:(NSString *)mobile
{
    if ([mobile length] != 11) {
        return NO;
    }
    //修改电话号码限制规则
    //    NSString *regex = @"0{0,1}(13[0-9]|14[0-9]|15[0-9]|18[0-9])[0-9]{8}$";
    NSString *regex = @"0{0,1}1[0-9]{10}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:mobile];
    if (!isMatch) {
        return NO;
    }
    return YES;
}

+ (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/**普通的Label宽度*/
+ (NSInteger)widthForLabelHeight: (CGFloat)labelHeight withText: (NSString *)strText font:(UIFont *)font{
    if (!strText) {
        strText = @"";
    }
    CGSize constraint = CGSizeMake(CGFLOAT_MAX , labelHeight);
    CGRect size = [strText boundingRectWithSize:constraint
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:@{NSFontAttributeName: font}
                                        context:nil];
    return ceilf(size.size.width);
}

//根据图片获取图片的主色调
+(UIColor*)mostColor:(UIImage*)image{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    //第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
    CGSize thumbSize=CGSizeMake(image.size.width, image.size.height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 thumbSize.width,
                                                 thumbSize.height,
                                                 8,//bits per component
                                                 thumbSize.width*4,
                                                 colorSpace,
                                                 bitmapInfo);
    
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, image.CGImage);
    CGColorSpaceRelease(colorSpace);
    
    //第二步 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData (context);
    if (data == NULL) return nil;
    NSCountedSet *cls=[NSCountedSet setWithCapacity:thumbSize.width*thumbSize.height];
    
    for (int x=0; x<thumbSize.width; x++) {
        for (int y=0; y<thumbSize.height; y++) {
            int offset = 4*(x*y);
            int red = data[offset];
            int green = data[offset+1];
            int blue = data[offset+2];
            int alpha =  data[offset+3];
            if (alpha>0) {//去除透明
                if (red==255&&green==255&&blue==255) {//去除白色
                }else if(red==0&&green==0&&blue==0){
                    //去除黑色
                }else {
                    NSArray *clr=@[@(red),@(green),@(blue),@(alpha)];
                    [cls addObject:clr];
                }
                
            }
        }
    }
    CGContextRelease(context);
    //第三步 找到出现次数最多的那个颜色
    NSEnumerator *enumerator = [cls objectEnumerator];
    NSArray *curColor = nil;
    NSArray *MaxColor=nil;
    NSUInteger MaxCount=0;
    while ( (curColor = [enumerator nextObject]) != nil )
    {
        NSUInteger tmpCount = [cls countForObject:curColor];
        if ( tmpCount < MaxCount ) continue;
        MaxCount=tmpCount;
        MaxColor=curColor;
        
    }
    return [UIColor colorWithRed:([MaxColor[0] intValue]/255.0f) green:([MaxColor[1] intValue]/255.0f) blue:([MaxColor[2] intValue]/255.0f) alpha:([MaxColor[3] intValue]/255.0f)];
}


/**用户Token失效*/
+ (void)userTokenTimeoutNeedLoginAgain{
   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:nil];
}

+(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
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
    
    //  [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}



//获取网络信号强度（dBm）
+ (int)getSignalStrength{
    if (kSafeTopHeight > 0) {
        id statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
        id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
        UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
        int signalStrength = 0;
        
        NSArray *subviews = [[foregroundView subviews][2] subviews];
        
        for (id subview in subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                signalStrength = [[subview valueForKey:@"numberOfActiveBars"] intValue];
                break;
            }else if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                signalStrength = [[subview valueForKey:@"numberOfActiveBars"] intValue];
                break;
            }
        }
        return signalStrength;
    } else {
        
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
        NSString *dataNetworkItemView = nil;
        int signalStrength = 0;
        
        for (id subview in subviews) {
            
            if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]] && [[self getNetworkType] isEqualToString:@"WIFI"] && ![[self getNetworkType] isEqualToString:@"NONE"]) {
                dataNetworkItemView = subview;
                signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
                break;
            }
            if ([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]] && ![[self getNetworkType] isEqualToString:@"WIFI"] && ![[self getNetworkType] isEqualToString:@"NONE"]) {
                dataNetworkItemView = subview;
                signalStrength = [[dataNetworkItemView valueForKey:@"_signalStrengthRaw"] intValue];
                break;
            }
        }
        return signalStrength;
    }
}



//检查当前是否连网
+ (BOOL)whetherConnectedNetwork
{
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    
    
    return YES ;
}

//获取网络类型
+ (NSString *)getNetworkType {
    if (![self whetherConnectedNetwork]) return @"NONE";
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSString *type = @"NONE";
    for (id subview in subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
            switch (networkType) {
                case 0:
                    type = @"NONE";
                    break;
                case 1:
                    type = @"2G";
                    break;
                case 2:
                    type = @"3G";
                    break;
                case 3:
                    type = @"4G";
                    break;
                case 5:
                    type = @"WIFI";
                    break;
            }
        }
    }
    return type;
}

+ (NSString *)time:(NSNumber *)timestamp {
    if (!timestamp) {
        return @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setAMSymbol:@"上午"];
    [formatter setPMSymbol:@"下午"];
    
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *messageTime = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]/1000];
    NSString *showTime = nil;
    
  
    return showTime;
}

+ (BOOL)checkCamera{
    // 判断是否有摄像头权限
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

+ (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    NSString *encodedString = (NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,                                                                  (CFStringRef)input,(CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",NULL, kCFStringEncodingUTF8));
    
    
    return encodedString;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
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


+ (NSString *)contentTypeWithImageData: (NSData *)data {
    
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
            
        case 0xFF:
            
            return @"jpeg";
            
        case 0x89:
            
            return @"png";
            
        case 0x47:
            
            return @"gif";
            
        case 0x49:
            
        case 0x4D:
            
            return @"tiff";
            
        case 0x52:
            
            if ([data length] < 12) {
                
                return nil;
                
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                
                return @"webp";
                
            }
            
            return nil;
            
    }
    
    return nil;
}


+ (BOOL )hasMissNetworkReachability
{
   
    return NO;
}

+ (void)userAddGuideView{
    
}

+(BOOL)isFirstLauch{
    //获取当前版本号
    //    NSString *currentAppVersion = [SBCommonMethod currentVersionString];
    //获取上次启动应用保存的appVersion
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
    //版本升级或首次登录
    if (version == nil || ![version isEqualToString:AppVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:AppVersion forKey:@"version"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }else{
        return NO;
    }
}

//压缩大图片，保持原来比例缩放
+ (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(sourceImage, compression);
    //NSLog(@"Before compressing quality, image size = %ld KB",data.length/1024);
    if (data.length < defineWidth) {
        return sourceImage;
    }
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(sourceImage, compression);
        //NSLog(@"Compression = %.1f", compression);
        //NSLog(@"In compressing quality loop, image size = %ld KB", data.length / 1024);
        if (data.length < defineWidth * 0.9) {
            min = compression;
        } else if (data.length > defineWidth) {
            max = compression;
        } else {
            break;
        }
    }
    //NSLog(@"After compressing quality, image size = %ld KB", data.length / 1024);
    if (data.length < defineWidth) {
        return [UIImage imageWithData:data];
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > defineWidth && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)defineWidth / data.length;
        //NSLog(@"Ratio = %.1f", ratio);
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
        NSLog(@"In compressing size loop, image size = %ld KB", data.length / 1024);
    }
    NSLog(@"After compressing size loop, image size = %ld KB", data.length / 1024);
    return [UIImage imageWithData:data];
}
@end
