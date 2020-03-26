//
//  VideoMessageView.h
//  UniudcOA
//
//  Created by LIjun on 2019/7/17.
//  Copyright © 2019 shanshan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,VideoMessageReceiveType){
    AllPersonReceiveType,
    HostPersonReceiveType,
};
typedef void (^userCloseMessageViewBlock)(void);
@interface VideoMessageView : UIView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UIView *selectPersonView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (assign, nonatomic) VideoMessageReceiveType type;
@property (nonatomic, copy) userCloseMessageViewBlock closeBlock;
@end

NS_ASSUME_NONNULL_END
