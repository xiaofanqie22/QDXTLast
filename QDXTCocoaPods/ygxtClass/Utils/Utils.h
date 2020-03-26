//
//  Utils.h
//  UniudcOA
//
//  Created by Chen Jimmy on 2018/6/20.
//  Copyright © 2018年 shanshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface Utils : NSObject

/** 获取最上层window */
+ (UIWindow *)getTopWindow;
/** 中文转拼音 */
+ (NSString *)chineseToPinYin:(NSString *)chinese;
/** 字符串是否为空或nil */
+ (BOOL)isEmptyString:(NSString *)string;
/** 去除字符串前后空格 */
+ (NSString *)trimString:(NSString *)string;
/** 字符串range内用string替换后是否符合保留remain位小数 */
+ (BOOL)isValidNumberChangeCharactersInRange:(NSRange)range original:(NSString *)original replacementString:(NSString *)string remain:(NSInteger)remain;
/** 密码是否符合要求 */
+ (NSString *)isValidPassword:(NSString *)password;
/** 由颜色创建image */
+ (UIImage*) createImageWithColor: (UIColor*) color height:(CGFloat)height;
/** 图片截图为size大小 */
+ (UIImage*)imageCompressWithSimple:(UIImage*)image scaledToSize:(CGSize)size;
/** 字母顺序排序 */
+ (NSArray *)sortAlphaKeys:(NSArray *)keys;
/** 打电话 */
+ (void)call:(NSString *)phoneNumber;
/** 打开URL */
+ (void)openURL:(NSString *)urlString;
/** 添加http，https获取完整网址 */
+ (NSString *)getCompleteWebsite:(NSString *)urlStr;
/** 获取字符串中的链接 */
+ (NSArray<NSTextCheckingResult *> *)linkRanges:(NSString *)string;

/** 获取当前显示的controller */
+ (UIViewController *)getCurrentDisplayController;
/** 获取上层显示的controller */
+ (UIViewController *)_topViewController:(UIViewController *)vc;
/** 显示alert弹框 */
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg actions:(NSArray *)actions cancelTitle:(NSString *)cancelTitle;
/** alert是否正显示 */
+ (BOOL)isAlertShow;
/** 隐藏alert */
+ (void)hideAlert;

/** 根据属性创建UILabel */
+(UILabel *)creatLabeWithTextColor:(UIColor *)color fontSize:(NSInteger )fontSize textAlignment:(NSTextAlignment )textAlignment;

/** 获取路径下文件大小 */
+ (CGFloat) getFileSize:(NSString *)path;

/**获取字节数*/
+ (NSInteger)getToInt:(NSString *)nameText;

/**判断是否手机*/
+ (BOOL)isValidateTelephone:(NSString *)mobile;

/**判断是否邮箱*/
+ (BOOL)isValidateEmail:(NSString *)email;

/**手机型号名*/
+ (NSString *)getDeviceName;

/**普通的获取UUID的方法*/
+ (NSString *)getUUID;

/**普通的Label宽度*/
+ (NSInteger)widthForLabelHeight: (CGFloat)labelHeight withText: (NSString *)strText font:(UIFont *)font;

+(UIColor*)mostColor:(UIImage*)image;

/**用户Token失效*/
+(void)userTokenTimeoutNeedLoginAgain;

+(NSString *)convertToJsonData:(NSDictionary *)dict;

/**获取信号强度*/
+ (int)getSignalStrength;

+ (NSString *)time:(NSNumber *)timestamp;

+ (BOOL)checkCamera;

+ (NSString *)encodeToPercentEscapeString: (NSString *) input;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString *)contentTypeWithImageData: (NSData *)data;

+ (BOOL )hasMissNetworkReachability;

+ (void)userAddGuideView;

+ (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
@end
