//
//  VideoCallMemberTableView.m
//  UniudcOA
//
//  Created by LIjun on 2019/6/25.
//  Copyright © 2019 shanshan. All rights reserved.
//

#import "VideoCallMemberTableView.h"
#import "VideoMemberTableViewCell.h"
#import <Masonry.h>
#include "UNPublicDefine.h"
#define cellId @"VideoMemberTableViewCell"
@interface VideoCallMemberTableView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView *headView;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic,strong) UILabel *memberNumLab;
@end
@implementation VideoCallMemberTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self registerNib:[UINib nibWithNibName:@"VideoMemberTableViewCell" bundle:nil] forCellReuseIdentifier:cellId];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.dataSource = self;
        self.delegate = self;
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews{
    self.tableHeaderView = self.headView;
    [self.headView addSubview:self.closeBtn];
    [self.headView addSubview:self.memberNumLab];
    self.headView.frame = CGRectMake(0, 0, self.frame.size.width, 45);
    [self.memberNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headView).offset(15);
        make.centerY.equalTo(self.headView);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headView).offset(-20 - kSafeBottomHeight);
        make.centerY.equalTo(self.headView);
        make.width.height.offset(45);
    }];
}

-(void)userCloseMemberView{
    if (self.memberDelegate && [self.memberDelegate respondsToSelector:@selector(userCloseMemberList)]) {
        [self.memberDelegate userCloseMemberList];
    }
}

-(void)setDataSourceArray:(NSMutableArray *)dataSourceArray{
    _dataSourceArray = dataSourceArray;
    self.memberNumLab.text = [NSString stringWithFormat:@"参与人(%ld)",_dataSourceArray.count];
    [self reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VideoMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < self.dataSourceArray.count) {
        NSDictionary *dic = self.dataSourceArray[indexPath.row];
        cell.userNameLab.text = dic[@"display"];
//        [cell.memberIconImageV sd_setImageWithURL:[NSURL URLWithString:dic[@"imgurl"]] placeholderImage:[UIImage imageNamed:@"默认男头像.png"]];
    }
    return cell;
}


-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"closeMember"] forState:UIControlStateNormal];
        [_closeBtn addTarget: self action:@selector(userCloseMemberView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(UILabel *)memberNumLab{
    if (!_memberNumLab) {
        _memberNumLab = [[UILabel alloc] init];
//        _memberNumLab.textColor = RGBAColor(50, 50, 50, 1);
        _memberNumLab.font = [UIFont boldSystemFontOfSize:14];
    }
    return _memberNumLab;
}

-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] init];
        _headView.backgroundColor = [UIColor whiteColor];
    }
    return _headView;
}
@end
