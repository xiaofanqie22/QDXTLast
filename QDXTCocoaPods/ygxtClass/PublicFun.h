//
//  PublicFun.h
//  OASystem
//
//  Created by BoGeGe on 2017/2/23.
//  Copyright © 2017年 BoGeGe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PublicFun : NSObject

+ (UIImage*)createImageWithColor:(UIColor*) color;
//按屏幕比例设置字体
+(UIFont *)setFont:(CGFloat)fontsize IsBold:(BOOL)isBold;

#pragma mark nsdata转dic
+(NSDictionary *)getDicFromData:(NSData *)data;

#pragma mark 判断字符串格式大小（size）
+(CGSize)ComputeLabelSizeWithString:(NSString *)string
                               Font:(UIFont *)font
                           MaxWeith:(CGFloat) maxWeith
                        LineSpacing:(CGFloat) lineSpacing;

//计算公式cell高度
+ (CGFloat)computeFormulaHeightWithFormulaStr:(NSString *)formula;

//获得设备型号
+ (NSString *)getCurrentDeviceModel;

#pragma mark - 拨打电话
+(void)makephonecall:(NSString *)number;

//#色值转uicolor
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)colorWithRGBHex:(UInt32)hex;

//获取文件图片类型
+ (NSString *)typeForImageData:(NSData *)data;

//添加到任意view
+(void)showProgressHUD:(NSString*)title view:(UIView*)view;

//添加到window
+(void)showProgressHUDWithWindow:(NSString*)title;

+(void)MBProgressHUDShowTitleStr:(NSString *)titleStr;

+(void)MBProgressHUDShowError:(NSString *)error;

+(void)MBProgressHUDShowTitleStr:(NSString *)titleStr HiddenAfterDelay:(NSInteger)delayTime;
+(void)MBProgressHUDMessage:(NSString *)message;
+(void)MBProgressHUDShowErrorLong:(NSString *)error;

+(void)hiddenProgressHUD;

//拨打电话
+ (void)callPhoneStr:(NSString*)phoneStr withVC:(UIViewController *)selfvc;

/**
 * 开始到结束的秒差
 */
+ (int)dateTimeDifferenceWithStartTime:(NSDate *)startDate endTime:(NSDate *)endDate;

/**
 * 时间表述(时间戳)
 */
+(NSString *)dateTimeStringWithTimeInterval:(double)timeInterval;

+(NSString *)dateTimeStringWithTimeInterval:(double)timeInterval andTimeFormate:(NSDateFormatter *)timeFormate;

+ (UIResponder *)resPonder:(UIView *)view  nextResponderWithClass:(Class)class;
+ (NSString *)chatDateTimeStringWithTimeInterval:(double)timeInterval;

//比较两个日期大小
+ (NSInteger)compareDate:(NSDate *)startDate withDate:(NSDate *)endDate;

//从url获取图片
+ (UIImage *) getImageFromURL:(NSString *)fileURL;


//获取window当前控制器
+ (UIViewController *)getCurrentVC;

//设置富文本
+ (NSAttributedString *)findString:(NSString *)string WithSelectStr:(NSString *)selectStr withColor:(UIColor *)exchangeColor;

+ (NSArray *)setupMenuArr;

//归档路径
+ (NSString *)getKeyedAchievePath;

//归档路径
+ (NSString *)getKeyedAchievePath:(NSString *)pathStr;


+(UIColor *)getColorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha;

// 根据图片url获取图片尺寸
//+(CGSize)getImageSizeWithURL:(id)imageURL;

//跳到指定的控制器
+ (UIViewController *)GetNextResponderWithClass:(Class)classStr andNaviVC:(UINavigationController *)naviVC;

//通过给的NSDate类型获取星期几
+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate;


/**
 获取考勤的日期

 @param inputDate 日期
 @return
 */
+ (NSString *)AttendaceGetWeekDay: (NSDate*)inputDate;

//计算当前时间的下一个整点
+ (NSString *)preNextDate:(NSDate *)nowDate;

//可是控制器的跟控制器
+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController*)rootViewController;



/**
 根据目标图片制作一个盖水印的图片
 
 @param originalImage 源图片
 @param title 水印文字
 @param markFont 水印文字font(如果不传默认为23)
 @param markColor 水印文字颜色(如果不传递默认为源图片的对比色)
 @return 返回盖水印的图片
 */
+ (UIImage *)getWaterMarkImage: (UIImage *)originalImage andTitle: (NSString *)title andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor;

/**
 生成一张文字水印图片

 @param width 图片宽度
 @param height 图片高度
 @param title 文字
 @param markFont 文字字体
 @param markColor 文字颜色
 @param backgroundColor 图片背景色
 @return 图片
 */
+ (UIImage *)getWarterImageWithWidth: (CGFloat)width Height:(CGFloat)height andTitle: (NSString *)title andMarkFont: (UIFont *)markFont andMarkColor: (UIColor *)markColor BackgroundColor: (UIColor *)backgroundColor;

#pragma mark -------时间相关-----------------
+ (NSString *)getNowDateByFormatterString:(NSString *)formatterString;


@end

