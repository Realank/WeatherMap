//
//  CutlineTableViewCell.h
//  WeatherMap
//
//  Created by Realank on 15/8/21.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CutlineTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cutlineName;
@property (weak, nonatomic) IBOutlet UIView *cutlineColor;
@property (strong, nonatomic) NSArray *cutlineModel;

- (void)setCutlineModel:(NSArray *)cutlineModel;

@end
