//
//  PopUpBigViewForNotice.h
//  HongKongAirlines
//
//  Created by Realank on 15/9/9.
//  Copyright (c) 2015年 BBDTEK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopUpBigViewConfrimDelegate <NSObject>

-(void) didTapConfirm;

@end

@interface PopUpBigViewForNotice : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *agreementText;
@property (nonatomic, copy) NSString *fistButtonText;
@property (nonatomic, copy) NSString *secondButtonText;
@property (nonatomic, assign) NSInteger noticeFrameHeight;
@property (nonatomic, assign) BOOL isTwoBtn;
@property (nonatomic, weak) id<PopUpBigViewConfrimDelegate> delegateForConfirmBtn;

@property (nonatomic, assign) BOOL isNeedCheck; //是否需要左下角框

@end
