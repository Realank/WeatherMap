//
//  ProvinceSelectedCollectionViewCell.m
//  WeatherMap
//
//  Created by Realank on 15/10/16.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "ProvinceSelectedCollectionViewCell.h"

@interface ProvinceSelectedCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ProvinceSelectedCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    UIColor *color = [[UIColor alloc]initWithRed:52/255.0 green:174.0/255.0 blue:255/255.0 alpha:1];
    self.layer.cornerRadius = 6;
    self.clipsToBounds = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = color.CGColor;
    
    self.titleLable.textColor = [UIColor whiteColor];
    self.titleLable.backgroundColor = color;
    
    self.nameLabel.textColor = color;
}

-(void) setTitle:(NSString *)title andName:(NSString *)name {
    self.titleLable.text = title;
    self.nameLabel.text = name;
}
@end
