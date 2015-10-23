//
//  PopUpBigViewForNotice.m
//  HongKongAirlines
//
//  Created by Realank on 15/9/9.
//  Copyright (c) 2015年 BBDTEK. All rights reserved.
//

#import "PopUpBigViewForNotice.h"

#define TopMargin 40
#define ButtomMargin 40
#define LeftRightMargin 20
#define HeadHeight 40
#define FootHeight 60

#define UI_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define RGB(r, g, b)   ([UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1])
#define TINT_COLOER RGB(0,128,255)

#define CONTENT_FONT_SIZE ([UIFont systemFontOfSize:15.0f])

@interface PopUpBigViewForNotice ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UIButton *checkBox;

@end

@implementation PopUpBigViewForNotice

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setContent:(NSString *)content {
    _content = content;
    [self configView];
}
- (void)configView {
    
    UIView *blackView = [[UIView alloc]initWithFrame:self.bounds];
    blackView.backgroundColor = [UIColor clearColor];
    blackView.alpha = 0.8f;
    CGRect backFrame = CGRectMake(LeftRightMargin, UI_SCREEN_HEIGHT, self.frame.size.width - 2*LeftRightMargin, self.frame.size.height - TopMargin - ButtomMargin);
    if (self.noticeFrameHeight > 120) {
        backFrame = CGRectMake(LeftRightMargin, UI_SCREEN_HEIGHT, self.frame.size.width - 2*LeftRightMargin, self.noticeFrameHeight);
    }
    UIView *backView = [[UIView alloc]initWithFrame:backFrame];
    backView.layer.masksToBounds = YES;
    backView.layer.cornerRadius = 6.0f;
    backView.backgroundColor = [UIColor whiteColor];
    backView.alpha = 1;
    float tableviewY = 10;
    float tableviewH = backFrame.size.height - FootHeight - 10;
    if (self.title && ![self.title isEqualToString:@""]) {
        UILabel *header = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, backFrame.size.width, HeadHeight)];
        header.font = [UIFont systemFontOfSize:18.0f];
        header.textColor = [UIColor blackColor];
        header.textAlignment = NSTextAlignmentCenter;
        header.text = self.title;
        header.backgroundColor = RGB(248, 248, 248);
        [backView addSubview:header];
        tableviewY = HeadHeight;
        tableviewH -= HeadHeight;
        
    }
    
    if (self.agreementText && ![self.agreementText isEqualToString:@""]) {
        tableviewH -= 35;
        self.checkBox = [[UIButton alloc]initWithFrame:CGRectMake(15, tableviewH + tableviewY + 7, 18, 15)];

        [self.checkBox setBackgroundImage:[UIImage imageNamed:@"checkBox_unselected"]forState:UIControlStateNormal];
        [self.checkBox setBackgroundImage:[UIImage imageNamed:@"checkBox_selected"]forState:UIControlStateSelected];
        self.checkBox.selected = NO;
        [self.checkBox addTarget:self action:@selector(clickAgreement) forControlEvents:UIControlEventTouchUpInside];
        UILabel *agreementLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, tableviewH + tableviewY - 2, backFrame.size.width - 45, 35)];
        agreementLabel.text = self.agreementText;
        agreementLabel.numberOfLines = 0;
        agreementLabel.textColor = [UIColor blackColor];
        agreementLabel.font = [UIFont systemFontOfSize:13.0f];
        [backView addSubview:self.checkBox];
        [backView addSubview:agreementLabel];
        
    }
    
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, tableviewY, backFrame.size.width, tableviewH) style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    //tableView.showsVerticalScrollIndicator = NO;
    [backView addSubview:tableView];
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, backFrame.size.height - FootHeight, backFrame.size.width, FootHeight)];
    footView.backgroundColor = RGB(248, 248, 248);
    
    CGFloat centerX = footView.frame.size.width/2;
    CGFloat centerY = footView.frame.size.height/2;
    
    UIButton *confirmBtn = [[UIButton alloc]initWithFrame:CGRectMake(centerX - 95/2, centerY - 35/2, 95, 35)];
    confirmBtn.backgroundColor = [UIColor whiteColor];
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = 6.0f;
    confirmBtn.layer.borderColor = TINT_COLOER.CGColor;
    confirmBtn.layer.borderWidth = 1.0f;
    [confirmBtn setTitleColor:TINT_COLOER forState:UIControlStateNormal];
    if (self.fistButtonText && self.fistButtonText.length > 0) {
        [confirmBtn setTitle:self.fistButtonText forState:UIControlStateNormal];
    } else {
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    }
    
    [confirmBtn addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:confirmBtn];
    if (self.isTwoBtn) {
        CGRect frame = confirmBtn.frame;
        float margin = (backView.frame.size.width - 30 - frame.size.width*2)/3;
        
        frame.origin.x = 15 + 2*margin + frame.size.width;
        confirmBtn.frame = frame;
//        [confirmBtn setTitle:STR(@"继续") forState:UIControlStateNormal];
        if (self.fistButtonText && self.fistButtonText.length > 0) {
            [confirmBtn setTitle:self.fistButtonText forState:UIControlStateNormal];
        } else {
            [confirmBtn setTitle:@"继续" forState:UIControlStateNormal];
        }
        frame.origin.x = 15 + margin;
        UIButton *cancelBtn = [[UIButton alloc]initWithFrame:frame];
        cancelBtn.backgroundColor = [UIColor whiteColor];
        cancelBtn.layer.masksToBounds = YES;
        cancelBtn.layer.cornerRadius = 6.0f;
        cancelBtn.layer.borderColor = TINT_COLOER.CGColor;
        cancelBtn.layer.borderWidth = 1.0f;
        [cancelBtn setTitleColor:TINT_COLOER forState:UIControlStateNormal];
//        [cancelBtn setTitle:STR(@"返回") forState:UIControlStateNormal];
        if (self.secondButtonText && self.secondButtonText.length > 0) {
            [cancelBtn setTitle:self.secondButtonText forState:UIControlStateNormal];
        } else {
            [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
        }
        [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:cancelBtn];
    }
    
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, footView.frame.size.width, 1)];
    line.backgroundColor = RGB(209, 209, 209);
    [footView addSubview:line];
    
    [backView addSubview:footView];
    
    [self addSubview:blackView];
    [self addSubview:backView];
    
    [UIView animateWithDuration:0.25 animations:^{
        blackView.backgroundColor = [UIColor blackColor];
        CGRect frame = backView.frame;
        if (self.noticeFrameHeight > 120) {
            frame.origin.y = (UI_SCREEN_HEIGHT - self.noticeFrameHeight)/2;
            
        } else {
            frame.origin.y = TopMargin;
        }
        
        backView.frame = frame;
        
    }];
    
}

- (void)clickAgreement {
    self.checkBox.selected = !self.checkBox.selected;
}


#pragma mark tableviewdelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        NSDictionary *attribute = @{NSFontAttributeName:CONTENT_FONT_SIZE};
        CGSize size = [self.content boundingRectWithSize:CGSizeMake(tableView.frame.size.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, tableView.frame.size.width - 30,size.height)];
        label.textColor = RGB(100, 100, 100);
        label.text = self.content;
        label.numberOfLines=0;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = CONTENT_FONT_SIZE;
        [cell.contentView addSubview:label];
  
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *attribute = @{NSFontAttributeName:CONTENT_FONT_SIZE};
    CGSize size = [self.content boundingRectWithSize:CGSizeMake(tableView.frame.size.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    return size.height + 10;
}

- (void)confirmBtnClick {
    if (self.isTwoBtn) {
        if (self.checkBox.selected) {
            if (self.delegateForConfirmBtn) {
                [self.delegateForConfirmBtn didTapConfirm];
            }
            [self removeFromSuperview];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请确认已阅读、并同意免责条款" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } else {
        [self removeFromSuperview];
    }
    

}
- (void)cancelBtnClick {

    [self removeFromSuperview];
    
}


@end
