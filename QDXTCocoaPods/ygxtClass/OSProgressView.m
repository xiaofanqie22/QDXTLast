//
//  OSProgressView.m
//  ygxtClass
//
//  Created by baiping on 2020/3/10.
//  Copyright © 2020 kaili. All rights reserved.
//

#import "OSProgressView.h"
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define Color_APPMain_Blue ColorFromRGB(0x38a6ec, 1)
#define ColorFromRGB(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define OS_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface OSProgressView()


@property (strong, nonatomic) UIView *progressView;

@property (strong, nonatomic) UIView *bgView;


@end

@implementation OSProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        _progressView = [[UIView alloc]initWithFrame:CGRectZero];
        _bgView = [[UIView alloc]initWithFrame:frame];
        _bgView.backgroundColor = COLOR(185, 185, 185, 1);
        _progressView.backgroundColor = Color_APPMain_Blue;
        
        [self addSubview:_bgView];
        [self addSubview:_progressView];

    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    self.progressView.frame = CGRectMake(0, 0, progress * OS_SCREEN_WIDTH, 2);
}


@end
