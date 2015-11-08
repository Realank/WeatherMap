//
//  ProvinceUnselectedCollectionViewCell.m
//  WeatherMap
//
//  Created by Realank on 15/10/16.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "ProvinceUnselectedCollectionViewCell.h"

@interface ProvinceUnselectedCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation ProvinceUnselectedCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    UIColor *color = [[UIColor alloc]initWithRed:140/255.0 green:182/255.0 blue:209/255.0 alpha:1];
//    self.layer.cornerRadius = 4;
//    self.clipsToBounds = YES;
//    self.layer.borderWidth = 1;
//    self.layer.borderColor = color.CGColor;
    
    self.titleLable.textColor = [UIColor whiteColor];
    self.titleLable.backgroundColor = color;
    self.titleLable.layer.cornerRadius = 10;
    self.titleLable.clipsToBounds = YES;
//    self.nameLabel.textColor = graycolor;
}

-(void) setTitle:(NSString *)title andName:(NSString *)name {
    self.titleLable.text = title;
    self.nameLabel.text = name;
}

@end
