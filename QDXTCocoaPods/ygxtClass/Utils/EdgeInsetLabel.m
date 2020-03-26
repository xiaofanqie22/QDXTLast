//
//  EdgeInsetLabel.m
//  UniudcOA
//
//  Created by LIjun on 2019/4/3.
//  Copyright © 2019 shanshan. All rights reserved.
//

#import "EdgeInsetLabel.h"

@implementation EdgeInsetLabel


- (instancetype)init {
    if (self = [super init]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _textInsets)];
    
}

@end
