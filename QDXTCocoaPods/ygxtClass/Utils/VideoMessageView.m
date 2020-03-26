//
//  VideoMessageView.m
//  UniudcOA
//
//  Created by LIjun on 2019/7/17.
//  Copyright © 2019 shanshan. All rights reserved.
//

#import "VideoMessageView.h"
#import "VideoSendMessageTableViewCell.h"
#import "VideoReceiveMessageTableViewCell.h"
#import "UNPublicDefine.h"
#define receiveCellID @"VideoReceiveMessageTableViewCell"
#define sendCellId @"VideoSendMessageTableViewCell"

@interface VideoMessageView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *headView;

@property (nonatomic,strong) UIButton *closeBtn;

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation VideoMessageView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = (VideoMessageView *) [[NSBundle mainBundle]loadNibNamed:@"VideoMessageView" owner:nil options:nil].lastObject;
        self.frame = frame;
        self.type = AllPersonReceiveType;
        [self userRegisterTableCellNib];
    }
    return self;
}

- (void)userRegisterTableCellNib{
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoReceiveMessageTableViewCell" bundle:nil] forCellReuseIdentifier:receiveCellID];
     [self.tableView registerNib:[UINib nibWithNibName:@"VideoSendMessageTableViewCell" bundle:nil] forCellReuseIdentifier:sendCellId];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.headView addSubview:self.titleLab];
    [self.headView addSubview:self.closeBtn];
   // self.tableView.tableHeaderView = self.headView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.headView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CGFLOAT_MIN;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.dataArray[indexPath.row];
    if([dic[@"type"] isEqualToString:@"send"]){
        VideoSendMessageTableViewCell *sendCell = [tableView dequeueReusableCellWithIdentifier:sendCellId];
        sendCell.nameLab.text = dic [@"name"];
        sendCell.contentLab.text = dic[@"message"];
//        [sendCell.userIcon sd_setImageWithURL:[NSURL URLWithString:dic[@"url"]] placeholderImage:[UIImage imageNamed:@"默认男头像.png"]];
        return sendCell;
    }else{
        VideoReceiveMessageTableViewCell *receiveCell = [tableView dequeueReusableCellWithIdentifier:receiveCellID];
        receiveCell.nameLab.text = dic [@"name"];
        receiveCell.contentLab.text = dic[@"message"];
//         [receiveCell.userIcon sd_setImageWithURL:[NSURL URLWithString:dic[@"url"]] placeholderImage:[UIImage imageNamed:@"默认男头像.png"]];
        return receiveCell;
    }
   
}

- (IBAction)hostAction:(id)sender {
    [self usersSelectPerson:sender];
    self.type = HostPersonReceiveType;
}

- (IBAction)allPersonAction:(id)sender {
    [self usersSelectPerson:sender];
    self.type = AllPersonReceiveType;
  
}

- (void)userCloseMessageView{
    if(self.selectPersonView.hidden == NO){
    [UIView animateWithDuration:0.3 animations:^{
        self.selectPersonView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.selectPersonView.hidden = YES;
        [self.typeBtn setImage:[UIImage imageNamed:@"message_jt_down"] forState:UIControlStateNormal];
    }];
    }
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)usersSelectPerson:(id)sender{
    UIButton *btn = (UIButton *)sender;
    [self.typeBtn setTitle:btn.titleLabel.text forState:UIControlStateNormal];
    [self.typeBtn setImage:[UIImage imageNamed:@"message_jt_down"] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3 animations:^{
        self.selectPersonView.alpha = 0.0;
      
    } completion:^(BOOL finished) {
        self.selectPersonView.hidden = YES;
    }];
}

- (IBAction)showPersonAction:(id)sender {
    return;
    if(self.selectPersonView.hidden == YES){
        self.selectPersonView.alpha = 0.0;
        self.selectPersonView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
             self.selectPersonView.alpha = 1.0;
        [self.typeBtn setImage:[UIImage imageNamed:@"message_jt_up"]forState:UIControlStateNormal];
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
             self.selectPersonView.alpha = 0.0;
        [self.typeBtn setImage:[UIImage imageNamed:@"message_jt_down"]forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
             self.selectPersonView.hidden = YES;
        }];
    }
}

-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray= [NSMutableArray array];
    }
    return _dataArray;
}

-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 60)];
        _headView.backgroundColor = [UIColor whiteColor];
    }
    return _headView;
}

-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, Screen_Width - 110, 30)];
        _titleLab.text = @"聊天消息";
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = RGBAColor(50, 50, 50, 1);
        _titleLab.font = [UIFont systemFontOfSize:15];
    }
    return _titleLab;
}

-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"messageview_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(userCloseMessageView) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.frame = CGRectMake(Screen_Width - 55, 10, 40, 40);
    }
    return _closeBtn;
}
@end
