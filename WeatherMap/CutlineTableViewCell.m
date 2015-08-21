//
//  CutlineTableViewCell.m
//  WeatherMap
//
//  Created by Realank on 15/8/21.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import "CutlineTableViewCell.h"

@implementation CutlineTableViewCell

- (void)setCutlineModel:(NSArray *)cutlineModel {
    _cutlineModel = cutlineModel;
    _cutlineName.text = cutlineModel[0];
    
    NSUInteger rgbColor = [cutlineModel[1] integerValue];
    _cutlineColor.backgroundColor = [UIColor colorWithRed:rgbColor/0x10000/255.0 green:rgbColor%0x10000/0x100/255.0 blue:rgbColor%0x100/255.0 alpha:0.6];
}

@end
