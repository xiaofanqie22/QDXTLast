//
//  VideoReceiveMessageTableViewCell.h
//  UniudcOA
//
//  Created by LIjun on 2019/7/18.
//  Copyright © 2019 shanshan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoReceiveMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;

@end

NS_ASSUME_NONNULL_END
