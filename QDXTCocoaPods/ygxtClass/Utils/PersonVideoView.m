//
//  PersonVideoView.m
//  UniudcOA
//
//  Created by LIjun on 2019/4/9.
//  Copyright © 2019 shanshan. All rights reserved.
//

#import "PersonVideoView.h"

@implementation PersonVideoView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = (PersonVideoView *) [[NSBundle mainBundle]loadNibNamed:@"PersonVideoView" owner:nil options:nil].lastObject;
        self.frame = frame;
        self.iconImageV.layer.cornerRadius = self.frame.size.width/9*2.5;
        self.iconImageV.layer.masksToBounds = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [tapGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

-(void)setIsCurrentSelect:(BOOL)isCurrentSelect{
    _isCurrentSelect = isCurrentSelect;
    if (_isCurrentSelect == YES) {
        self.layer.borderWidth= 0.5;
        //self.layer.borderColor = RGBAColor(170, 170, 170, 1).CGColor;
    }else{
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (IBAction)userClickVideoBtn:(id)sender {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(userClickVideoBtnWithPublisherId:nickName:)]) {
//        [self.delegate userClickVideoBtnWithPublisherId:self.VideoId nickName:self.nickName.text];
//    }
}
- (IBAction)userClickShareScreenBtn:(id)sender {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(userClickShareScreenBtnWithPublisherId:nickName:)]) {
//        [self.delegate userClickShareScreenBtnWithPublisherId:self.screenId nickName:self.nickName.text];
//    }
    
}

-(void)tap:(UITapGestureRecognizer*)reg{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userChangeMeetingPersonWithVideoPublisherId:screenPublisherId:nickName:personView:)]) {
        [self.delegate userChangeMeetingPersonWithVideoPublisherId:self.VideoId screenPublisherId:self.screenId nickName:self.nickName.text personView:self];
    }
    
    /*
    if (self.videoBtn.hidden == NO && self.screenBtn.hidden == NO) {
        if (self.clickBlock) {
            self.clickBlock(self.screenId, self.VideoId,self.videoBtn);
        }
    }else if (self.videoBtn.hidden == NO){
        if (self.delegate && [self.delegate respondsToSelector:@selector(userClickVideoBtnWithPublisherId:nickName:videoBtn:)]) {
            [self.delegate userClickVideoBtnWithPublisherId:self.VideoId nickName:self.nickName.text videoBtn:self.videoBtn];
            //
        }
    }else if (self.screenBtn.hidden == NO){
        if (self.delegate && [self.delegate respondsToSelector:@selector(userClickShareScreenBtnWithPublisherId:nickName:)]) {
            [self.delegate userClickShareScreenBtnWithPublisherId:self.screenId nickName:self.nickName.text];
        }
    }
     */
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
