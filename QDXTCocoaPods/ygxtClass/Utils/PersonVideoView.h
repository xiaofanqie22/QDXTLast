//
//  PersonVideoView.h
//  UniudcOA
//
//  Created by LIjun on 2019/4/9.
//  Copyright © 2019 shanshan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonVideoView;
@protocol personVideoViewDelegate<NSObject>
/*
- (void)userClickShareScreenBtnWithPublisherId:(NSInteger )screenId nickName:(NSString *)nickName;

- (void)userClickVideoBtnWithPublisherId:(NSInteger)VideoId nickName:(NSString *)nickName videoBtn:(UIButton *)videoBtn;
*/
- (void)userChangeMeetingPersonWithVideoPublisherId:(NSInteger)VideoId screenPublisherId:(NSInteger)screenId nickName:(NSString *)nickName personView:(PersonVideoView *)personView;
@end



//typedef void (^userClickVideoView)(NSInteger screenId,NSInteger videoId,UIButton *videoBtn);

@interface PersonVideoView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nickName;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageV;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIButton *screenBtn;
@property (assign, nonatomic) BOOL isCurrentSelect;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, assign) NSInteger VideoId;
@property (nonatomic, assign) NSInteger screenId;

@property (nonatomic, weak) id <personVideoViewDelegate> delegate;
//@property (nonatomic, copy)userClickVideoView clickBlock;
@end

