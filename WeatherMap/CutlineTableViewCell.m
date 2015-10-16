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

    _cutlineColor.backgroundColor = cutlineModel[1];
}

@end
