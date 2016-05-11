//
//  CutlineTableViewCell.m
//  WeatherMap
//
//  Created by Realank on 15/8/21.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import "CutlineTableViewCell.h"

@interface CutlineTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *cutlineName;
@property (weak, nonatomic) IBOutlet UIView *cutlineColor;

@end

@implementation CutlineTableViewCell

- (void)setCutlineModel:(NSArray *)cutlineModel {
    _cutlineModel = cutlineModel;
    _cutlineName.text = cutlineModel[0];
    _cutlineName.layer.shadowColor = [UIColor blackColor].CGColor;
    _cutlineName.layer.shadowOpacity = 0.9;
    _cutlineName.layer.shadowRadius = 15.0;
    _cutlineName.layer.shadowOffset = CGSizeMake(0, 0);
    _cutlineName.layer.shouldRasterize = YES;
    //_cutlineName.textColor = cutlineModel[1];

    UIColor *color = cutlineModel[1];
    _cutlineColor.backgroundColor = color;
//    _cutlineColor.layer.borderColor = color.CGColor;
//    _cutlineColor.layer.borderWidth = 1;
    _cutlineColor.layer.cornerRadius = 5;
    _cutlineColor.layer.masksToBounds = YES;
}

@end
